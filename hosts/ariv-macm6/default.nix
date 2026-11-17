{ pkgs, ... }:

{
  # ----- imports -----
  imports = [
    # sistema
    ../../modules/darwin/system/nix.nix
    ../../modules/darwin/system/defaults.nix
    ../../modules/darwin/system/fonts.nix
    ../../modules/darwin/system/security.nix
    ../../modules/darwin/homebrew.nix

    # utenti
    ../../modules/darwin/users/andrea.riva.nix
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  # ----- rete -----
  networking = {
    hostName = "ariv-macm6";
    computerName = "ariv-macm6";
    localHostName = "ariv-macm6";
  };

  # ----- pacchetti di sistema -----
  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  # ----- homebrew (specifico host) -----
  homebrew = {
    taps = [ ];
    brews = [ ];
    casks = [
      "firefox"
      "keepassxc"
      "obsidian"
      "shottr"
    ];
    masApps = {
      # "Xcode" = 497799835;
    };
  };

  # Non cambiare dopo il primo switch
  system.stateVersion = 6;
}
