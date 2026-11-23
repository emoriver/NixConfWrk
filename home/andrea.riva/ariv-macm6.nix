{
  pkgs,
  #pkgsUnstable,
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

  home.username = "andrea.riva";
  home.homeDirectory = "/Users/andrea.riva";
  home.stateVersion = "26.05";

  # Override darwin del modulo ghostty condiviso
  programs.ghostty = {
    package = pkgs.ghostty-bin; # pkgs.ghostty builda solo su Linux
    settings = {
      font-size = lib.mkForce 13;
      window-decoration = lib.mkForce true;
    };
  };

  # CLI con integrazione shell gestita da HM
  programs.fzf.enable = true; # ctrl-R, ctrl-T, alt-C
  programs.eza.enable = true; # alias ls/ll/la
  programs.bat.enable = true;
  programs.yazi.enable = true; # wrapper `y` che fa cd all'uscita

  home.packages = (
    with pkgs;
    [
      fd
      ripgrep
      jq
      yq-go

      nixd
      nixfmt

      #    ])
      #    ++ (with pkgsUnstable; [  # qui mettere le versioni dei programmi unstable (dal Mac ha poco senso perchè i GUI vanno nei cask)
      #    ]);
    ]
  );

  programs.zsh.shellAliases = {
    # applica la config (host dedotto da LocalHostName)
    rebuild = "sudo darwin-rebuild switch --flake ~/Documents/NixConfWrk";
    # aggiorna gli input del flake (lock condiviso con gli host NixOS!) e applica
    update = "nix flake update --flake ~/Documents/NixConfWrk && rebuild";
  };
}
