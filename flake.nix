{
  description = "Home Manager configuration";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # https://nixos-and-flakes.thiscute.world/nixos-with-flakes/downgrade-or-upgrade-packages
    nixpkgs-zk-14-2.url = "github:nixos/nixpkgs/7309a1da2598f7e791cd7fea932b30f88492cdef";
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
                pkgs-zk-14-2 = import args.nixpkgs-zk-14-2 {
                  inherit system;
                };
              };
            }
          ) hosts;
        };
      }
    );
}
