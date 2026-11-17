{ ... }:

{
  # Richiede system.primaryUser (impostato nel modulo utente)
  system.defaults = {
    dock = {
      autohide     = true;
      show-recents = false;
      mru-spaces   = false;
    };
    finder = {
      AppleShowAllExtensions = true;
      ShowPathbar            = true;
      FXPreferredViewStyle   = "Nlsv";   # vista elenco
    };
    NSGlobalDomain = {
      AppleShowAllExtensions   = true;
      KeyRepeat                = 2;
      InitialKeyRepeat         = 15;
      ApplePressAndHoldEnabled = false;
    };
    trackpad.Clicking = true;
  };
}
