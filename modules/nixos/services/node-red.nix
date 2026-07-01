{ pkgs, lib, ... }:

{
  services.node-red = {
    enable = true;
    port = 1880;
    configFile = ./node-red-settings.js;
  };

  systemd.services.node-red.preStart = lib.mkAfter ''
    cd /var/lib/node-red
    if [ ! -d "node_modules/@opcua/for-node-red" ] || \
       [ ! -d "node_modules/node-red-contrib-modbus" ] || \
       [ ! -d "node_modules/node-red-dashboard" ] || \
       [ ! -d "node_modules/@node-red-contrib-themes" ]; then
      ${pkgs.nodejs}/bin/npm install --prefix /var/lib/node-red \
        "@opcua/for-node-red" \
        "node-red-contrib-modbus" \
        "node-red-dashboard" \
        "@node-red-contrib-themes/theme-collection@4" \
        --no-save --loglevel error
    fi
  '';

  systemd.services.node-red.path = with pkgs; [
    nodejs
    bash
    python3
    gnumake
    gcc
  ];
}