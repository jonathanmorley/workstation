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
  programs.exa = {
    enable = true;
    enableAliases = true;
  };
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
    };
  };
  programs.git = {
    enable = true;
    delta.enable = true;
    userName = users.primaryUser.fullName;
    userEmail = users.primaryUser.email;
    signing.key = users.primaryUser.publicKey;
    signing.signByDefault = true;

    ignores = (if pkgs.stdenv.isDarwin then [
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
    ] else [
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
    ]) ++ [
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
    matchBlocks."*" = {
      extraOptions.IdentityAgent = "\"${ssh.identityAgent}\"";
      identityFile = "~/.ssh/id.pub";
      identitiesOnly = true;
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
      disable = [
        "rustup"
        "node"
        "pip3"
      ];
    };
  };
  programs.zellij.enable = false;
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    history.path = "${config.xdg.dataHome}/zsh/zsh_history";
    enableAutosuggestions = true;
    enableCompletion = true;
    enableSyntaxHighlighting = true;
    initExtra = ''
      eval "$($(brew --prefix)/bin/rtx activate -s zsh)"
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

  home.packages = with pkgs; [
    awscli2
    dotnet-sdk_7
    fd
    nodejs
    powershell
    python2
    python3
    ripgrep
    rustup
  ];

  home.sessionPath = [
    "$HOME/.cargo/bin"
  ];

  home.sessionVariables = {
    LESSHISTFILE = "${config.xdg.stateHome}/less/history";
  };

  home.shellAliases = {
    cat = "bat";
    dockerv = "docker run --rm -it -v $(pwd):$(pwd) -w $(pwd)";
    darwin-switch = "(cd /tmp && darwin-rebuild switch --flake ~/.nixpkgs)";
  };

  home.file.".asdfrc" = {
    text = "legacy_version_file = yes";
  };

  home.file.".ssh/id.pub" = {
    text = users.primaryUser.publicKey;
  };
}
