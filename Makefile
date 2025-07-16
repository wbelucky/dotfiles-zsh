.PHONY: switch
switch:
	nix run home-manager/master -- switch --flake .#opteyo -b backup
.PHONY: clean
clean:
	nix-collect-garbage -d
