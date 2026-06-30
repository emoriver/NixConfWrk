nix{ pkgs, lib, ... }:

{
  services.node-red = {
    enable = true;
    port = 1880;
    configFile = ./node-red-settings.js;
  };

  systemd.services.node-red.preStart = lib.mkAfter ''
    cd /var/lib/node-red
    if [ ! -d node_modules/node-red-contrib-opcua ] || \
       [ ! -d "node_modules/@node-red-contrib-themes" ]; then
      ${pkgs.nodejs}/bin/npm install --prefix /var/lib/node-red \
        "node-red-contrib-opcua@0.2.336" \
        "node-red-contrib-modbus" \
        "@node-red-contrib-themes/theme-collection" \
        --no-save --loglevel error
    fi
  '';
}