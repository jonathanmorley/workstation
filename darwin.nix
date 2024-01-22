# See https://daiderd.com/nix-darwin/manual/index.html#sec-options

{ pkgs, lib, config, specialArgs, ... }:
let
  personal = builtins.elem "personal" specialArgs.profiles;
  cvent = builtins.elem "cvent" specialArgs.profiles;
in
{
  # Nix configuration
  nix.settings = {
    trusted-users = ["@admin"];
    # https://github.com/NixOS/nix/issues/7273
    auto-optimise-store = false;
    experimental-features = "nix-command flakes";
  };

  # https://github.com/LnL7/nix-darwin/issues/701
  documentation.enable = false;

  environment.pathsToLink = [ "/share/zsh" ];
  environment.systemPath = [ config.homebrew.brewPrefix ];
  environment.shells = with pkgs; [ zsh ];
  environment.systemPackages = with pkgs; [
    colima   # For docker
  ];

  environment.variables = {
    DOCKER_HOST = "unix:///Users/jonathan/.colima/default/docker.sock";
  };

  fonts = {
    fontDir.enable = true;
    fonts = [
      (pkgs.nerdfonts.override {
        fonts = ["FiraCode"];
      })
    ];
  };

  programs.zsh.enable = true;

  services.nix-daemon.enable = true;

  homebrew = {
    enable = true;
    onActivation.cleanup = "uninstall";
    casks = [
      "1password"
      # 1password extension does not like nix-installed FF
      "firefox"
      "raycast"
      "visual-studio-code"
      "warp"
    ]
    ++ lib.optional personal "lulu"
    ++ lib.optional cvent "microsoft-excel"
    ++ lib.optional cvent "microsoft-outlook";
  };

  security.pam.enableSudoTouchIdAuth = true;
  security.pki.certificateFiles = lib.optional cvent "/Library/Application Support/Netskope/STAgent/download/nscacert.pem";

  system.defaults.ActivityMonitor.IconType = 5; # CPU Usage
  system.defaults.NSGlobalDomain = {
    AppleEnableMouseSwipeNavigateWithScrolls = false;
    AppleEnableSwipeNavigateWithScrolls = false;
    AppleInterfaceStyle = "Dark";
    AppleKeyboardUIMode = 3; # full keyboard control
    InitialKeyRepeat = 10;
    KeyRepeat = 1;
    NSAutomaticCapitalizationEnabled = false;
    NSAutomaticDashSubstitutionEnabled = false;
    NSAutomaticPeriodSubstitutionEnabled = false;
    NSAutomaticQuoteSubstitutionEnabled = false;
    NSAutomaticSpellingCorrectionEnabled = false;
    NSTextShowsControlCharacters = true;
  };
  system.defaults.SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
  system.defaults.dock.dashboard-in-overlay = true;
  system.defaults.finder.ShowPathbar = true;
  system.defaults.trackpad.ActuationStrength = 0;
  system.defaults.trackpad.FirstClickThreshold = 0;
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToControl = true;
}
