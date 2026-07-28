{ config, ... }:

{
  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "0"; # problema della sparizione dei menu
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
