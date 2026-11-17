{ pkgs, ... }:

let
  user = "andrea.riva";
in
{
  system.primaryUser = user;   # richiesto per system.defaults e homebrew

  users.users.${user} = {
    home  = "/Users/${user}";
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;  # zsh di sistema con PATH di nix in /etc/zshrc
}
