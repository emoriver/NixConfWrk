{ config, ... }:

{
  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1"; # forza Wayland nativo per swipe gesture; se i menu tornano vuoti dopo un update, provare "0"
  };

  programs.firefox = {
    enable = true;
    configPath = "${config.xdg.configHome}/mozilla/firefox";
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
}
