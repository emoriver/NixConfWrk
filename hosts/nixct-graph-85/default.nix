{ config, modulesPath, pkgs, lib, ... }:
{
  imports = [ 
    (modulesPath + "/virtualisation/proxmox-lxc.nix")

    # pacchetti di sistema

    # utenti - !! -
    ../../modules/nixos/users/carpinera.nix

    # servizi
    #../../modules/nixos/services/node-red.nix
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
        3000 # Grafana
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
    #openFirewall = true;
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

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "0.0.0.0";
        http_port = 3000;
        domain = "grafana.easynet.local";
      };
      security = {
        admin_user = "admin";
        admin_password = "$__file{/var/lib/secrets/grafana-admin}";
        secret_key     = "$__file{/var/lib/secrets/grafana-secret-key}";
      };
      analytics.reporting_enabled = false;
    };

/*
    provision = {
      enable = true;
      datasources.settings.datasources = [{
        name = "Serraggi";
        type = "mssql";
        uid  = "serraggi";
        url  = "sqlserver.dominio.local:1433";
        user = "grafana_ro";
        jsonData = {
          database = "Tightening";
          encrypt = "false";   # "true" se il server ha un certificato valido
          maxOpenConns = 10;
        };
        secureJsonData.password = "$__file{/var/lib/secrets/mssql-grafana}";
      }];
      # dashboard versionate come JSON nel repo:
      dashboards.settings.providers = [{
        name = "default";
        options.path = "/etc/grafana-dashboards";
      }];
    };
*/  
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
    #git.enable = true;
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

  system.stateVersion = "25.11";
}
