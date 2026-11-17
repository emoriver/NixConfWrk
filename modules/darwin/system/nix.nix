{ ... }:

{
  # Il daemon e /etc/nix/nix.conf li gestisce Determinate Nix:
  # nix-darwin non deve toccarli. Impostazioni custom -> /etc/nix/nix.custom.conf
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;
}
