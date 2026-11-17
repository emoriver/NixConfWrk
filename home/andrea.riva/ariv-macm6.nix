{
  pkgs,
  pkgsUnstable,
  lib,
  ...
}:

{
  imports = [
    ../../modules/home/apps/starship.nix
    ../../modules/home/apps/git.nix
    ../../modules/home/apps/ghostty.nix
    ../../modules/home/apps/firefox.nix
  ];

  home.username      = "andrea.riva";
  home.homeDirectory = "/Users/andrea.riva";
  home.stateVersion  = "26.05";

  # Override darwin del modulo ghostty condiviso
  programs.ghostty = {
    package = pkgs.ghostty-bin;   # pkgs.ghostty builda solo su Linux
    settings = {
      font-size         = lib.mkForce 13;
      window-decoration = lib.mkForce true;
    };
  };

  home.packages =
    (with pkgs; [
      bat
      eza
      fd
      ripgrep
      fzf
      jq
      yq-go
      yazi

      nixd
      nixfmt
      nil

      zed-editor
    ])
    ++ (with pkgsUnstable; [
    ]);

  programs.zsh.shellAliases = {
    update = "sudo darwin-rebuild switch --flake ~/Documents/NixConfWrk#ariv-macm6";
  };
}
