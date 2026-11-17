{
  description = "NixOS + Home Manager multi-host multi-user";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    impermanence.url = "github:nix-community/impermanence";

    flake-utils.url = "github:numtide/flake-utils";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # --- macOS ---
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    niri-flake = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, impermanence, flake-utils, nix-darwin, nix-homebrew, ... } @ inputs:
  let
    lib = nixpkgs.lib;

    mkNodeRedPackages = system:   # Packages per Node-RED (buildNpmPackage)
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in import ./modules/nixos/services/node-red-packages/default.nix {
        inherit pkgs;
      };

    mkPkgsUnstable = system: import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };

    hosts = {
      w541onnixos = {
        system     = "x86_64-linux";
        hostModule = ./hosts/w541onnixos;
        users = {
          emoriver = ./home/emoriver/w541onnixos.nix;
        };
      };
      t4801onnixos = {
        system     = "x86_64-linux";
        hostModule = ./hosts/t4801onnixos;
        users = {
          carpinera = ./home/carpinera/t4801onnixos.nix;
        };
      };
      carpinox1vm1 = {
        system     = "x86_64-linux";
        hostModule = ./hosts/carpinox1vm1;
        users = {
          carpinera = ./home/carpinera/carpinox1vm1.nix;
        };
      };
      p16s1onnixos = {
        system     = "x86_64-linux";
        #impermanence = true;
        hostModule = ./hosts/p16s1onnixos;
        users = {
          emoriver = ./home/emoriver/p16s1onnixos.nix;
          carpinera = ./home/carpinera/p16s1onnixos.nix;
        };
      };
      nixct-ndrdtb-82 = {
        system     = "x86_64-linux";
        hostModule = ./hosts/nixct-ndrdtb-82;
        users = {
          carpinera = ./home/carpinera/nixct-ndrdtb-82.nix;
        };
      };
      nixct-build-83 = {
        system     = "x86_64-linux";
        hostModule = ./hosts/nixct-build-83;
        users = {
          carpinera = ./home/carpinera/nixct-build-83.nix;
        };
      };
      nixct-pg-69 = {
        system     = "x86_64-linux";
        hostModule = ./hosts/nixct-pg-69;
        users = {
          carpinera = ./home/carpinera/nixct-pg-69.nix;
        };
      };      
      nixct-graf-85 = {
        system     = "x86_64-linux";
        hostModule = ./hosts/nixct-graf-85;
        users = {
          carpinera = ./home/carpinera/nixct-graf-85.nix;
        };
      };
    };

    mkNixos = name: cfg:
    let
      system        = cfg.system;
      pkgsUnstable  = mkPkgsUnstable system;

      extraModules = [];
    in
      lib.nixosSystem {
        inherit system;
        specialArgs = { inherit pkgsUnstable inputs; };
        modules = extraModules ++ [
          cfg.hostModule
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs    = true;
              useUserPackages  = true;
              extraSpecialArgs = { inherit pkgsUnstable inputs; };
              users            = lib.mapAttrs (user: path: import path) cfg.users;
              backupFileExtension = "backup";
            };
          }
        ];
      };

    # --- macOS (nix-darwin) ---
    darwinHosts = {
      ariv-macm6 = {
        system     = "aarch64-darwin";
        hostModule = ./hosts/ariv-macm6;
        users = {
          "andrea.riva" = ./home/andrea.riva/ariv-macm6.nix;
        };
      };
    };

    mkDarwin = name: cfg:
    let
      pkgsUnstable = mkPkgsUnstable cfg.system;
    in
      nix-darwin.lib.darwinSystem {
        specialArgs = { inherit pkgsUnstable inputs; };
        modules = [
          cfg.hostModule
          nix-homebrew.darwinModules.nix-homebrew
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs    = true;
              useUserPackages  = true;
              extraSpecialArgs = { inherit pkgsUnstable inputs; };
              users            = lib.mapAttrs (user: path: import path) cfg.users;
              backupFileExtension = "backup";
            };
          }
        ];
      };
  in
  let
    systems = [ "x86_64-linux" "aarch64-linux" ];
  in
  {
    nixosConfigurations  = lib.mapAttrs mkNixos hosts;
    darwinConfigurations = lib.mapAttrs mkDarwin darwinHosts;

    packages = lib.genAttrs systems (system: {
      nodeRedPackages = mkNodeRedPackages system;
    });
  };
}