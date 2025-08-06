{
  description = "Home Manager configuration";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # https://nixos-and-flakes.thiscute.world/nixos-with-flakes/downgrade-or-upgrade-packages
    nixpkgs-zk.url = "github:nixos/nixpkgs/920756a4ef5bb5e9f5d17599724b29f0ea6f4a9b"; # ZK 0.15.0
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      flake-utils,
      ...
    }@args:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        hosts = import ./hosts.nix;
      in
      {
        formatter = pkgs.nixfmt-rfc-style;
        legacyPackages = {
          inherit (pkgs) home-manager;
          homeConfigurations = builtins.mapAttrs (
            hostname: config:
            home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              modules = [
                ./modules
                config
              ];
              extraSpecialArgs = {
                pkgs-zk = import args.nixpkgs-zk {
                  inherit system;
                };
              };
            }
          ) hosts;
        };
      }
    );
}
