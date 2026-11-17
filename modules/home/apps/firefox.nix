{ config, lib, pkgs, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;

  # Hash dell'install path /Applications/Firefox.app/Contents/MacOS (cask).
  # Verificare con: cat ~/Library/Application\ Support/Firefox/installs.ini
  darwinInstallHash = "2656FF1E876E9973";
in
{
  # Solo Linux: forza Wayland nativo per swipe gesture; se i menu tornano vuoti dopo un update, provare "0"
  home.sessionVariables = lib.mkIf (!isDarwin) {
    MOZ_ENABLE_WAYLAND = "1";
  };

  programs.firefox = {
    enable = true;

    # macOS: app installata via cask (build Mozilla firmata), HM gestisce solo i profili
    # nel path di default (~/Library/Application Support/Firefox)
    package = lib.mkIf isDarwin null;
    configPath = lib.mkIf (!isDarwin) "${config.xdg.configHome}/mozilla/firefox";

    profiles.default = {
      id = 0;
      name = "default";
      isDefault = true;
      settings = {
        "browser.startup.homepage" = "https://nixos.org";
        "privacy.trackingprotection.enabled" = true;
      };
    };
  };

  # macOS: profiles.ini è un symlink read-only, Firefox non può scriverci la sezione
  # [Install<hash>] e crea un profilo suo. La dichiariamo noi, legata a Profiles/default.
  home.file."Library/Application Support/Firefox/profiles.ini" = lib.mkIf isDarwin {
    text = lib.mkAfter ''

      [Install${darwinInstallHash}]
      Default=Profiles/default
      Locked=1
    '';
  };
}
