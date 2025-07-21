{
  description = "Home Manager configuration";

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
          homeConfigurations = {

            "ub-pm" = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;

            modules = [ 
              ./modules
              ({
                  # 
                  # programs.git = {
                  #   userName = "wbelucky";
                  #   userEmail = "39439193+WBelucky@users.noreply.github.com";
                  # };
                home.username = "wbelucky";
                home.homeDirectory = "/home/wbelucky";
              })
            ];
          };
          };
        };
      }
    );
}
