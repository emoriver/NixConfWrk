{ config, ... }:

{
  # Homebrew installato e gestito dal flake (nix-homebrew), usato solo per i cask.
  # taps/brews/casks/masApps sono liste: ogni host aggiunge i suoi nel proprio default.nix
  nix-homebrew = {
    enable        = true;
    enableRosetta = true;
    user          = config.system.primaryUser;
    autoMigrate   = true;
  };

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      upgrade    = true;
      cleanup    = "zap";   # rimuove (con dati in ~/Library) tutto ciò che non è dichiarato
    };
  };
}
