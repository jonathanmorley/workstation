# See https://nix-community.github.io/home-manager/options.html

{ config, pkgs, lib, users, ssh, ...  }:
{
  home.stateVersion = "22.05";

  programs.alacritty = {
    enable = true;
    settings = {
      window.dimensions = {
        lines = 50;
        columns = 200;
      };
      window.padding = {
        x = 2;
        y = 2;
      };
      window.decorations = "buttonless";
      font.normal.family = "FiraCode Nerd Font";
    };
  };
  programs.bat.enable = true;
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    stdlib = ''
      use_asdf() {
        source_env "$(asdf direnv envrc "$@")"
      }
    '';
  };
  programs.exa = {
    enable = true;
    enableAliases = true;
  };
  programs.gh.enable = true;
  programs.git = {
    enable = true;
    delta.enable = true;
    userName = users.primaryUser.fullName;
    userEmail = users.primaryUser.email;
    signing.key = users.primaryUser.publicKey;
    signing.signByDefault = true;

    ignores = [
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

      # direnv integration
      ".envrc"
    ];
    extraConfig = {
      fetch.prune = true;
      rebase.autosquash = true;
      pull.rebase = true;
      push.default = "current";
      init.defaultBranch = "main";
      gpg.format = "ssh";
      gpg."ssh".program = ssh.signingProgram;
    };
  };
  programs.jq.enable = true;
  programs.neovim = {
    enable = true;
    coc = {
      enable = true;
      # Trigger completion on <c-space>
      # Accept suggestions with <cr>
      pluginConfig = ''
        inoremap <silent><expr> <c-space> coc#refresh()
        inoremap <silent><expr> <cr> coc#pum#visible() ? coc#_select_confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
      '';
    };
    plugins = with pkgs.vimPlugins; [
      airline
      coc-docker
      coc-eslint
      coc-git
      coc-java
      coc-jest
      coc-json
      coc-prettier
      coc-pyright
      coc-python
      coc-rust-analyzer
      coc-sh
      coc-toml
      coc-tsserver
      coc-yaml
      {
        plugin = nerdtree;
        # Start NERDTree and put the cursor back in the other window.
        # Close the tab if NERDTree is the only window remaining in it.
        config = ''
          autocmd VimEnter * NERDTree | wincmd p
          autocmd BufEnter * if winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif
        '';
      }
      nerdtree-git-plugin
      sleuth
    ];
    extraConfig = "let NERDTreeShowHidden=1";
    viAlias = true;
    vimAlias = true;
  };
  programs.nix-index.enable = true;
  programs.ssh = {
    enable = true;
    hashKnownHosts = true;
    matchBlocks."*".extraOptions.IdentityAgent = "\"${ssh.identityAgent}\"";
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
      disable = [
        "rustup"
        "node"
        "pip3"
      ];
    };
  };
  programs.zellij.enable = true;
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    history.path = "${config.xdg.dataHome}/zsh/zsh_history";
    enableAutosuggestions = true;
    enableCompletion = true;
    enableSyntaxHighlighting = true;
    initExtra = ''
      eval "$(${pkgs.zellij}/bin/zellij setup --generate-auto-start zsh)"
      . "${pkgs.asdf-vm}/share/asdf-vm/lib/asdf.sh"
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
    sessionVariables = {
      LESSHISTFILE = "${config.xdg.stateHome}/less/history";
      DIRENV_LOG_FORMAT = "";
    };
  };

  home.packages = with pkgs; [
    asdf-vm
    awscli2
    dotnet-sdk_7
    fd
    gh
    nodejs
    powershell
    python3
    ripgrep
  ];

  home.shellAliases = {
    cat = "bat";
    dockerv = "docker run --rm -it -v $(pwd):$(pwd) -w $(pwd)";
    darwin-switch = "(cd /tmp && darwin-rebuild switch --flake ~/.nixpkgs)";
  };

  home.file.".asdfrc" = {
    text = "legacy_version_file = yes";
  };

  home.file.".hammerspoon/init.lua" = {
    text = ''
      local log = hs.logger.new('init', 'info')

      hs.loadSpoon("SpoonInstall")
      spoon.SpoonInstall.use_syncinstall = true

      function apps()
        apps = {}
        for path in hs.fs.dir("~/Applications/Home Manager Apps/") do
          fullPath = "~/Applications/Home Manager Apps/" .. path
          info = hs.application.infoForBundlePath(fullPath)

          if next(info) ~= nil then
            apps[info["CFBundleDisplayName"]] = {
              icon = hs.image.imageFromAppBundle(info["CFBundleIdentifier"]),
              description = fullPath,
              fn = function()
                hs.application.open(info["CFBundleIdentifier"])
              end
            }
          end
        end
        return apps
      end

      spoon.SpoonInstall:andUse("Seal", {
        hotkeys = { toggle = { {"cmd"}, "space" } },
        fn = function(s)
          s:loadPlugins({"apps", "useractions"})
          s.plugins.useractions.actions = apps()
          s:refreshAllCommands()
        end,
        start = true,
      })
    '';
  };
}
