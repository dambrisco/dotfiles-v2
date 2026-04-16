{
  description = "dotfiles-v2: nix-darwin + home-manager + declarative Homebrew";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    homebrew-core = { url = "github:homebrew/homebrew-core"; flake = false; };
    homebrew-cask = { url = "github:homebrew/homebrew-cask"; flake = false; };
    homebrew-bundle = { url = "github:homebrew/homebrew-bundle"; flake = false; };
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, nix-homebrew, ... }:
    let
      username = "dambrisco";
      system = "aarch64-darwin";

      mkHost = { hostname, profile }: nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = { inherit inputs username; };
        modules = [
          ./modules/darwin
          nix-homebrew.darwinModules.nix-homebrew
          home-manager.darwinModules.home-manager
          ({ ... }: {
            networking.hostName = hostname;
            networking.localHostName = hostname;

            users.users.${username} = {
              name = username;
              home = "/Users/${username}";
            };

            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "hm-backup";
            home-manager.extraSpecialArgs = { inherit inputs username; };
            home-manager.users.${username} = import ./modules/home;
          })
          ./profiles/base.nix
          profile
        ];
      };
    in {
      darwinConfigurations.personal = mkHost {
        hostname = "personal";
        profile = ./profiles/personal.nix;
      };
      darwinConfigurations.work = mkHost {
        hostname = "work";
        profile = ./profiles/work.nix;
      };
    };
}
