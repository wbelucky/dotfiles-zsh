.PHONY: switch
switch:
	home-manager switch --flake .#opteyo -b backup
.PHONY: clean
clean:
	nix-collect-garbage -d
