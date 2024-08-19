# See https://nix-community.github.io/home-manager/options.xhtml
{
  config,
  pkgs,
  lib,
  profiles,
  username,
  sshKeys,
  ...
}: let
  personal = builtins.elem "personal" profiles;
  cvent = builtins.elem "cvent" profiles;
in {
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = username;
  home.homeDirectory = lib.mkForce (
    if pkgs.stdenv.isDarwin
    then "/Users/${username}"
    else "/home/${username}"
  );

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.05";

  programs.awscli.enable = true;
  programs.bat.enable = true;
  programs.chromium = {
    enable = true;
    package = pkgs.google-chrome;
  };
  programs.direnv.enable = true;
  programs.eza.enable = true;
  programs.fd.enable = true;
  programs.firefox = {
    enable = true;
    package = pkgs.firefox-bin;
  };
  programs.git = {
    enable = true;
    delta.enable = true;
    userName = "Jonathan Morley";
    userEmail =
      if cvent
      then "jmorley@cvent.com"
      else "morley.jonathan@gmail.com";
    signing.key = sshKeys."github.com";
    signing.signByDefault = true;
    ignores =
      if pkgs.stdenv.isDarwin
      then [
        ### macOS ###
        # General
        ".DS_Store"
        ".AppleDouble"
        ".LSOverride"

        # Icon must end with two \r
        "Icon"

        # Thumbnails
        "._*"

        # Files that might appear in the root of a volume
        ".DocumentRevisions-V100"
        ".fseventsd"
        ".Spotlight-V100"
        ".TemporaryItems"
        ".Trashes"
        ".VolumeIcon.icns"
        ".com.apple.timemachine.donotpresent"

        # Directories potentially created on remote AFP share
        ".AppleDB"
        ".AppleDesktop"
        "Network Trash Folder"
        "Temporary Items"
        ".apdisk"
      ]
      else [
        ### Linux ###
        "*~"

        # temporary files which can be created if a process still has a handle open of a deleted file
        ".fuse_hidden*"

        # KDE directory preferences
        ".directory"

        # Linux trash folder which might appear on any partition or disk
        ".Trash-*"

        # .nfs files are created when an open file is removed but is still being accessed
        ".nfs*"
      ];
    extraConfig = {
      core.sshCommand = "ssh -i ${builtins.toFile "github.com.pub" sshKeys."github.com"}";
      credential = {
        "https://gist.github.com" = {
          helper = "${pkgs.gh}/bin/gh auth git-credential";
          username = "jonathanmorley";
        };
        "https://github.com" = {
          helper = "${pkgs.gh}/bin/gh auth git-credential";
          username = "jonathanmorley";
        };
      };
      fetch.prune = true;
      rebase.autosquash = true;
      pull.rebase = true;
      push.default = "current";
      init.defaultBranch = "main";
      gpg.format = "ssh";
      gpg."ssh".program = lib.mkIf pkgs.stdenv.isDarwin "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
      http.postBuffer = 2097152000;
      https.postBuffer = 2097152000;
    };
    includes =
      lib.mkIf cvent
      (builtins.concatMap (org: [
          # Internal GitHub
          {
            condition = "hasconfig:remote.*.url:git@github.com:${org}-internal/**";
            contents = {
              core.sshCommand = "ssh -i ${builtins.toFile "cvent.pub" sshKeys.cvent}";
              user.signingKey = sshKeys.cvent;
              credential = {
                "https://gist.github.com" = {
                  username = "JMorley_cvent";
                };
                "https://github.com" = {
                  username = "JMorley_cvent";
                };
              };
            };
          }
        ]) ["cvent" "cvent-archive" "cvent-incubator" "cvent-test" "icapture" "jifflenow" "SHOFLO" "socialtables" "weddingspot"]
        ++ [
          # Stash
          {
            condition = "hasconfig:remote.*.url:ssh://git@*.cvent.*/**";
            contents = {
              core.sshCommand = "ssh -i ${builtins.toFile "cvent.pub" sshKeys.cvent}";
              user.signingKey = sshKeys.cvent;
            };
          }
        ]);
  };
  programs.java.enable = true;
  programs.jq.enable = true;
  programs.mise.enable = true;
  programs.neovim = {
    defaultEditor = true;
    enable = true;
    viAlias = true;
    vimAlias = true;
  };
  programs.nix-index = {
    enable = true;
    enableBashIntegration = false;
    enableZshIntegration = false;
  };
  programs.ripgrep.enable = true;
  programs.ssh = {
    enable = true;
    hashKnownHosts = true;
    matchBlocks."*" = {
      identityFile = lib.mkIf (builtins.hasAttr "ssh" sshKeys) (builtins.toFile "ssh.pub" sshKeys."ssh");
      identitiesOnly = true;
      extraOptions.IdentityAgent = lib.mkIf pkgs.stdenv.isDarwin "\"${config.home.homeDirectory}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\"";
    };
    matchBlocks."*.cvent.*" = lib.mkIf cvent {
      user = "jmorley";
    };
  };
  programs.starship.enable = true;
  programs.topgrade = {
    enable = true;
    settings = {
      misc = {
        assume_yes = true;
        pre_sudo = true;
        cleanup = true;
        disable = [
          "cargo"
          "containers"
          "dotnet"
          "helm"
          "node"
          "nix"
          "pip3"
          "pnpm"
          "rustup"
          "yarn"
        ];
      };
      commands = lib.optionalAttrs pkgs.stdenv.isDarwin {
        Nix = "darwin-rebuild switch --recreate-lock-file --refresh --flake ${config.home.homeDirectory}/.nixpkgs";
      };
    };
  };
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    history.path = "${config.xdg.dataHome}/zsh/zsh_history";
    autosuggestion.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    initExtra = ''
      export PATH="''${PATH}:''${HOME}/.cargo/bin"
    '';
    oh-my-zsh = {
      enable = true;
      plugins = [
        "gh"
        "git"
        "ripgrep"
        "rust"
        "vscode"
      ];
    };
  };

  home.packages = with pkgs;
    [
      coreutils
      dasel
      docker-client
      docker-buildx
      dogdns
      dotnet-sdk_7
      du-dust
      duf
      gettext # For compiling Python
      gnupg # For fetching Java
      gnugrep
      groff # Needed by awscli
      ipcalc
      nodejs
      nodePackages.pnpm
      oktaws
      openssl
      openssl.dev
      pkg-config
      python3
      rustup
      tree
      unixtools.watch
      vscode
    ]
    ++ lib.optional (! pkgs.stdenv.isDarwin) gh
    ++ lib.optional pkgs.stdenv.isDarwin colima
    ++ lib.optional personal tailscale
    ++ lib.optional cvent slack
    ++ lib.optional cvent zoom-us;

  home.shellAliases = {
    cat = "bat";
    dockerv = "docker run --rm -it -v $(pwd):$(pwd) -w $(pwd)";
    gls = ''git log --pretty='format:' --name-only | grep -oP "^''$(git rev-parse --show-prefix)\K.*" | cut -d/ -f1 | sort -u'';
    nix-clean = "sudo nix-collect-garbage --delete-older-than 30d";
  };

  # home.sessionVariables and home.sessionPath do not work on MacOS

  home.file."colima template" = lib.mkIf pkgs.stdenv.isDarwin {
    target = ".colima/_templates/default.yaml";
    source = (pkgs.formats.yaml {}).generate "default.yaml" {
      runtime = "docker";
      vmType = "vz";
      rosetta = true;
      network.address = true;
      mounts = [
        {
          location = "/tmp/colima";
          mountPoint = "/tmp/colima";
          writable = true;
        }
        {
          location = "/private/var/folders";
          mountPoint = "/private/var/folders";
          writable = true;
        }
        {
          location = "/Users/${username}";
          mountPoint = "/Users/${username}";
          writable = true;
        }
      ];
    };
  };
}
