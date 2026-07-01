{ config, modulesPath, pkgs, lib, ... }:
{
  imports = [ 
    (modulesPath + "/virtualisation/proxmox-lxc.nix")

    # pacchetti di sistema

    # utenti - !! -
    ../../modules/nixos/users/carpinera.nix

    # servizi
    ../../modules/nixos/services/postgresql.nix
  ];
  
  nix.settings = { sandbox = false; };  
  proxmoxLXC = {
    manageNetwork = false;
    privileged = true;
  };

  # ---------- Rete ----------
  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22 # SSH
        5432 # PostgreSQL
      ];
/*      
      allowedUDPPorts = [
        5353 # Utile per mDNS/Avahi
        1900 # UPnP/SSDP
        50300 # Soulseek
      ];
      allowedTCPPortRanges = [
        {
          from = 40000;
          to = 65535;
        } # porte dinamiche
      ];
      allowedUDPPortRanges = [
        {
          from = 57621;
          to = 57621;
        }
        {
          from = 49152;
          to = 65535;
        }
      ];
*/
    };
  };


  # ----- servizi di base -----
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
      KbdInteractiveAuthentication = false;
      UsePAM = true;
      AllowUsers = [ "carpinera" ];
      PermitEmptyPasswords = "no";
    };
  };

  security.pam.services.sshd.allowNullPassword = false;

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_18;

    extensions = ps: [ ps.timescaledb ];

    settings = {
      shared_preload_libraries = "timescaledb";
    };
  };


  # ----- impostazioni di nix -----
  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    warn-dirty = false;
    substituters = [
      "https://cache.nixos.org/"
      # Aggiungi altri se li usi (es. Cachix)
    ];
    # trusted-public-keys = [ ... ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };


  # ----- programmi e pacchetti di sistema host-level  -----
  programs = {
    zsh.enable = true;
    ssh.startAgent = true;
  };

  environment.systemPackages = with pkgs; [
    #vim
    git 
    curl 
    wget 
    htop 
    #btop 
    ripgrep 
    fd 
    unzip 
    zip 
    gnupg 
    tmux
    yazi
  ];

  services.fstrim.enable = false; # Let Proxmox host handle fstrim

  systemd.mounts = [{
    where = "/sys/kernel/debug";
    enable = false;
  }];

  system.stateVersion = "26.05";
}
