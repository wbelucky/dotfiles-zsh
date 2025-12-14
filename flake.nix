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
   system-manager = {
      url = "github:numtide/system-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      flake-utils,
      system-manager,
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
        systemConfigs.default = system-manager.lib.makeSystemConfig {
          modules = [
            ({ config, lib, pkgs, ... }:

              {
                config = {
                  nixpkgs.hostPlatform = "x86_64-linux";

                  environment = {
                    systemPackages = with pkgs; [
                      docker
                      apparmor-parser
                      apparmor-utils
                    ];
                  };
                  systemd.services = {
                    docker = {
                      enable = true;
                      description = "Docker Application Container Engine";
                      documentation = [ "https://docs.docker.com" ];
                      wantedBy = [ "multi-user.target" ];
                      after = [ "network-online.target" ];
                      wants = [ "network-online.target" ];
                      requires = [ "apparmor.service" ];
                      serviceConfig = {
                        Type = "notify";
                        Environment = [
                          "PATH=${lib.makeBinPath [
                            pkgs.docker
                            pkgs.apparmor-parser
                            pkgs.apparmor-utils
                            pkgs.coreutils
                            pkgs.kmod
                          ]}:/usr/bin:/sbin"
                        ];
                        ExecStart = "${pkgs.docker}/bin/dockerd";
                        ExecStartPost = [
                          "${pkgs.coreutils}/bin/chmod 666 /var/run/docker.sock"
                          "${pkgs.coreutils}/bin/chown root:docker /var/run/docker.sock"
                        ];
                        ExecReload = "${pkgs.coreutils}/bin/kill -s HUP $MAINPID";
                        TimeoutStartSec = 0;
                        RestartSec = 2;
                        Restart = "always";
                        StartLimitBurst = 3;
                        StartLimitInterval = "60s";
                        LimitNOFILE = "infinity";
                        LimitNPROC = "infinity";
                        LimitCORE = "infinity";
                        TasksMax = "infinity";
                        Delegate = true;
                        KillMode = "process";
                        OOMScoreAdjust = -500;
                      };
                    };
                  };
                };
              })
          ];
        };
      }
    );
}
