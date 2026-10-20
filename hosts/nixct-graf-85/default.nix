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
        3100 # Loki (push da Serilog)
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
  # ssh #
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

  # grafana #
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

    # loki #
    services.loki = {
      enable = true;
      configuration = {
        auth_enabled = false;
        analytics.reporting_enabled = false;

        server = {
          http_listen_port = 3100;
          grpc_listen_port = 9096;
          log_level = "warn";
        };

        common = {
          path_prefix = "/var/lib/loki";
          replication_factor = 1;
          instance_addr = "127.0.0.1";
          ring.kvstore.store = "inmemory";
          storage.filesystem = {
            chunks_directory = "/var/lib/loki/chunks";
            rules_directory  = "/var/lib/loki/rules";
          };
        };

        schema_config.configs = [{
          from = "2026-10-01";
          store = "tsdb";
          object_store = "filesystem";
          schema = "v13";
          index = { prefix = "index_"; period = "24h"; };
        }];

        limits_config = {
          retention_period = "720h";          # 30 giorni
          allow_structured_metadata = true;
        };

        compactor = {
          working_directory = "/var/lib/loki/compactor";
          retention_enabled = true;
          delete_request_store = "filesystem";
        };
      };
    };

    provision = {
     enable = true;
     datasources.settings.datasources = [{
       name = "Loki";
       type = "loki";
       uid  = "loki";
       url  = "http://127.0.0.1:3100";
     }];
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
