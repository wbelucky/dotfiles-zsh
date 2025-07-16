{
  description = "Home Manager configuration of opteyo";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, home-manager, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        formatter = pkgs.nixfmt-rfc-style;
        legacyPackages = {
          inherit (pkgs) home-manager;
          homeConfigurations."opteyo" = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;

            # Specify your home configuration modules here, for example,
            # the path to your home.nix.
            modules = [ 
              ./modules
              ({
                programs.git = {
                  userName = "wbelucky";
                  userEmail = "39439193+WBelucky@users.noreply.github.com";
                };
                home.username = "wbiraki";
                home.homeDirectory = "/home/wbiraki";
              })
            ];

            # Optionally use extraSpecialArgs
            # to pass through arguments to home.nix
          };
        };
      }
    );
}
