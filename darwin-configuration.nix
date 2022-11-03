# See https://daiderd.com/nix-darwin/manual/index.html#sec-options

{ pkgs, lib, ... }:
{
  # Nix configuration
  nix.settings = {
    trusted-users = ["@admin"];
    auto-optimise-store = true;
    experimental-features = "nix-command flakes";
  };

  environment.pathsToLink = [ "/share/zsh" ];
  environment.systemPath = [ "/opt/homebrew/bin" ];
  environment.shells = with pkgs; [ zsh ];
  environment.systemPackages = with pkgs; [
    gettext
  ];

  programs.zsh.enable = true;

  services.nix-daemon.enable = true;

  homebrew.enable = true;
  homebrew.onActivation.cleanup = "zap";
  homebrew.taps = [
    "homebrew/cask"
    "homebrew/cask-fonts"
  ];
  homebrew.brews = [
    "asdf"
  ];
  homebrew.casks = [
    "1password"
    "alacritty"
    "docker"
    "firefox"
    "font-fira-code-nerd-font"
    "intellij-idea"
    "lulu"
    "microsoft-office"
    "slack"
    "visual-studio-code"
    "zoom"
  ];

  users.users.jonathan = {
    name = "jonathan";
    home = "/Users/jonathan";
    shell = pkgs.zsh;
  };

  security.pam.enableSudoTouchIdAuth = true;

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
