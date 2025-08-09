
{
  lib,
  config,
  pkgs,
  ...
}@args: 

let
  zshConfigEarlyInit = lib.mkOrder 900 ''
    setopt histignorealldups sharehistory
    # zstyle ':completion:*' auto-description 'specify: %d'
    # zstyle ':completion:*' completer _expand _complete _correct _approximate
    # zstyle ':completion:*' format 'Completing %d'
    # zstyle ':completion:*' group-name ""
    # zstyle ':completion:*' menu select=2
    # eval "$(dircolors -b)"

    # # https://discourse.nixos.org/t/need-help-understanding-how-to-escape-special-characters-in-the-list-of-str-type/11389
    # zstyle ':completion:*:default' list-colors ''${(s.:.)LS_COLORS}
    # zstyle ':completion:*' list-colors ""
    # zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
    # zstyle ':completion:*' matcher-list "" 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
    # zstyle ':completion:*' menu select=long
    # zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
    # zstyle ':completion:*' use-compctl false
    # zstyle ':completion:*' verbose true

    # zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
    # zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

    ZSH_CONFIG="$HOME/.config/zsh"

    # eval "$($HOME/.local/bin/mise activate zsh)"
    eval "$(sheldon source)"
    eval "$(starship init zsh)"
  '';

  zshConfig = lib.mkOrder 950 ''

for function in "$ZSH_CONFIG/functions"/*; do
  source $function
done
export ABBR_SET_EXPANSION_CURSOR=1
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
  '';
  zshConfigFinal = lib.mkOrder 1600 ''
  if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
    exec tmux -2u new-session -A -s default-session
  fi
  '';
in
{
  programs.zsh = {
    enable = true;
    shellAliases = {
      vim="nvim";
      ls="ls --color=auto";
      grep="grep --color=auto";
      fgrep="fgrep --color=auto";
      egrep="egrep --color=auto";
    };
    shellGlobalAliases = {
      G = "| grep";
    };
    completionInit ="autoload -Uz compinit && compinit";
    initContent = 
      lib.mkMerge [ zshConfigEarlyInit zshConfig zshConfigFinal ];
  };
}
