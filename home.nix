# See https://nix-community.github.io/home-manager/options.xhtml
{
  config,
  pkgs,
  lib,
  profiles,
  username,
  ...
}: let
  personal = builtins.elem "personal" profiles;
  cvent = builtins.elem "cvent" profiles;

  personalPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN0l85pYmr5UV3FTMAQnmZYyv1wVNeKej4YnIP8sk5fW";
  cventPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO4ZtCTDz73hl3lja+B3yKSOSRVssUOpD/t7C1S19sC9";

  tomlFormat = pkgs.formats.toml {};
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
  home.stateVersion = "23.11";

  programs.bat.enable = true;
  programs.direnv.enable = true;
  programs.eza = {
    enable = true;
    enableAliases = true;
  };
  programs.git = {
    enable = true;
    delta.enable = true;
    userName = "Jonathan Morley";
    userEmail = "morley.jonathan@gmail.com";
    signing.key = personalPublicKey;
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
      credential = {
        "https://gist.github.com" = {
          helper = "${pkgs.gh}/bin/gh auth git-credential";
        };
        "https://github.com" = {
          helper = "${pkgs.gh}/bin/gh auth git-credential";
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
    includes = lib.mkIf cvent [
      # Use gitdir for the SSH key, because remotes aren't available
      {
        condition = "gitdir:**/emu/**";
        contents = {
          core = {
            sshCommand = "ssh -i ${builtins.toFile "cvent.pub" cventPublicKey}";
          };
        };
      }
      {
        condition = "gitdir:**/*-emu/**";
        contents = {
          core = {
            sshCommand = "ssh -i ${builtins.toFile "cvent.pub" cventPublicKey}";
          };
        };
      }
      {
        condition = "hasconfig:remote.*.url:git@github.com:cvent/**";
        contents = {
          user = {
            email = "jmorley@cvent.com";
          };
        };
      }
      {
        condition = "hasconfig:remote.*.url:git@github.com:cvent-internal/**";
        contents = {
          user = {
            email = "jmorley@cvent.com";
            signingKey = cventPublicKey;
          };
        };
      }
      {
        condition = "hasconfig:remote.*.url:git@github.com:cvent-test/**";
        contents = {
          user = {
            email = "jmorley@cvent.com";
          };
        };
      }
      {
        condition = "hasconfig:remote.*.url:git@github.com:cvent-test-internal/**";
        contents = {
          user = {
            email = "jmorley@cvent.com";
            signingKey = cventPublicKey;
          };
        };
      }
      {
        condition = "hasconfig:remote.*.url:git@github.com:SHOFLO/**";
        contents = {
          user = {
            email = "jmorley@cvent.com";
          };
        };
      }
      {
        condition = "hasconfig:remote.*.url:git@github.com:socialtables/**";
        contents = {
          user = {
            email = "jmorley@cvent.com";
          };
        };
      }
      {
        condition = "hasconfig:remote.*.url:ssh://git@*.cvent.*/**";
        contents = {
          user = {
            email = "jmorley@cvent.com";
          };
        };
      }
    ];
  };
  programs.jq.enable = true;
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
  programs.ssh = {
    enable = true;
    hashKnownHosts = true;
    matchBlocks."*" = {
      identityFile = builtins.toFile "personal.pub" personalPublicKey;
      identitiesOnly = true;
      extraOptions.IdentityAgent = lib.mkIf pkgs.stdenv.isDarwin "\"${config.home.homeDirectory}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\"";
    };
  };
  programs.starship = {
    enable = true;
    settings = {
      aws.symbol = "  ";
      conda.symbol = " ";
      dart.symbol = " ";
      directory.read_only = " ";
      docker_context.symbol = " ";
      elixir.symbol = " ";
      elm.symbol = " ";
      git_branch.symbol = " ";
      golang.symbol = " ";
      hg_branch.symbol = " ";
      java.symbol = " ";
      julia.symbol = " ";
      memory_usage.symbol = " ";
      nim.symbol = " ";
      nix_shell.symbol = " ";
      package.symbol = " ";
      perl.symbol = " ";
      php.symbol = " ";
      python.symbol = " ";
      ruby.symbol = " ";
      rust.symbol = " ";
      scala.symbol = " ";
      shlvl.symbol = " ";
      swift.symbol = "ﯣ ";
    };
  };
  programs.topgrade = {
    enable = true;
    settings = {
      misc = {
        assume_yes = true;
        pre_sudo = true;
        cleanup = true;
        disable = [
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
    enableAutosuggestions = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    initExtraBeforeCompInit = ''
      eval "$(${pkgs.mise}/bin/mise activate zsh)"
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
      _1password
      awscli2
      coreutils
      dasel
      docker-client
      dotnet-sdk_7
      du-dust
      fd
      gettext # For compiling Python
      gh
      gnupg # For fetching Java
      groff # Needed by awscli
      ipcalc
      mise
      nodejs
      oktaws
      openssl
      openssl.dev
      pkg-config
      python3
      ripgrep
      rustup
      tree
      unixtools.watch
    ]
    ++ lib.optional personal tailscale
    ++ lib.optional personal teamviewer
    ++ lib.optional cvent slack
    ++ lib.optional cvent zoom-us;

  home.shellAliases = {
    cat = "bat";
    dockerv = "docker run --rm -it -v $(pwd):$(pwd) -w $(pwd)";
  };

  # home.sessionVariables and home.sessionPath do not work on MacOS

  home.file.".config/mise/config.toml" = {
    source = tomlFormat.generate "mise.toml" {
      settings = {
        asdf_compat = true;
      };
    };
  };
}
