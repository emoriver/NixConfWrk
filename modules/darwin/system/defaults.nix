{ ... }:

{
  # Richiede system.primaryUser (impostato nel modulo utente)
  system.defaults = {
    dock = {
      autohide = true;
      show-recents = false;
      mru-spaces = false;

      # Angoli attivi: 1 off, 2 Mission Control, 3 Finestre app, 4 Scrivania,
      # 5 Salvaschermo, 10 Stop monitor, 12 Centro Notifiche, 13 Blocca schermo, 14 Nota rapida
      wvous-tr-corner = 4; # alto a destra -> Mostra scrivania
    };
    finder = {
      AppleShowAllExtensions = true;
      ShowPathbar = true;
      FXPreferredViewStyle = "Nlsv"; # vista elenco
    };
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
      ApplePressAndHoldEnabled = false;
    };
    trackpad.Clicking = true;

    # Scorciatoie di sistema (com.apple.symbolichotkeys).
    # ATTENZIONE: il dict viene scritto per intero -> le scorciatoie non dichiarate
    # tornano al default, le modifiche manuali in Impostazioni vengono sovrascritte.
    # parameters = [ ascii (65535 = nessuno) keycode modificatori ]
    # modificatori: cmd 1048576, opt 524288, ctrl 262144, shift 131072 (si sommano)
    CustomUserPreferences."com.apple.symbolichotkeys".AppleSymbolicHotKeys = {
      # 27 = Evidenzia la finestra successiva: cmd + tasto accanto all'1 (keycode 50 "|\")
      "27" = {
        enabled = true;
        value = {
          type = "standard";
          parameters = [
            96
            50
            1048576
          ];
        };
      };
    };
  };
}
