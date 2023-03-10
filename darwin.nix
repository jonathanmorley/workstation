# See https://daiderd.com/nix-darwin/manual/index.html#sec-options

{ pkgs, lib, config, specialArgs, ... }:
let
  netskope = (specialArgs // { netskope = false; }).netskope;
in
{
  # Nix configuration
  nix.settings = {
    trusted-users = ["@admin"];
    auto-optimise-store = true;
    experimental-features = "nix-command flakes";
  };

  environment.pathsToLink = [ "/share/zsh" ];
  environment.systemPath = [ config.homebrew.brewPrefix ];
  environment.shells = with pkgs; [ zsh ];
  environment.systemPackages = with pkgs; [
    # For python compilation
    gettext
  ];

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
    taps = ["homebrew/cask"];
    casks = [
      "1password"
      "docker"
      "firefox"
      "lulu"
      "microsoft-office"
      "raycast"
      "slack"
      "tailscale"
      "teamviewer"
      "visual-studio-code"
      "warp"
      "zoom"
    ];
  };

  security.pam.enableSudoTouchIdAuth = true;
  security.pki.certificateFiles = if netskope then [
    "/Library/Application Support/Netskope/STAgent/download/nscacert.pem"
  ] else [];

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
