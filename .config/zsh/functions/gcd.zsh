#!/usr/bin/env zsh
function gcd() {
	local dist=$(ghq list | fzf -q "$1")
	if [[ -n "$dist" ]]; then
		cd "$GHQ_ROOT/$dist"
		tmux rename-window "$(basename "$(pwd)")"
		return 0
	fi
	return 1
}
