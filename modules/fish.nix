{
  lib,
  config,
  pkgs,
  ...
}@args: {
  home.packages = (with pkgs; [fish]);

  programs.tmux.extraConfig = ''
  set-option -g default-shell ${pkgs.fish}/bin/fish
  '';

  programs.bash = {
    enable = true;
    initExtra = lib.mkMerge [
      (
        lib.mkOrder 50 ''
        if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then
            . $HOME/.nix-profile/etc/profile.d/nix.sh;
        fi''
      )
      (
        lib.mkOrder 1500 ''
        if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
           exec tmux -2u new-session -A -s default-session
        fi''
      )
    ];
  };

  programs.fish = {
    enable = true;
    shellInit = ''
    if test -e $HOME/.nix-profile/etc/profile.d/nix.fish; . $HOME/.nix-profile/etc/profile.d/nix.fish; end
    '';
    interactiveShellInit = ''
    set fish_greeting ""
    # accept fish gray suggestion with C-j
    # ref: https://github.com/fish-shell/fish-shell/issues/8619
    bind -M insert \cj accept-autosuggestion

    # Fish git prompt
    set -gx __fish_git_prompt_showdirtystate yes
    set -gx __fish_git_prompt_showstashstate yes
    set -gx __fish_git_prompt_showuntrackedfiles yes
    set -gx __fish_git_prompt_showupstream yes

    set -gx __fish_git_prompt_color_branch yellow
    set -gx __fish_git_prompt_color_upstream_ahead green
    set -gx __fish_git_prompt_color_upstream_behind red

    # Status Chars
    set -gx __fish_git_prompt_char_dirtystate '🚧'
    set -gx __fish_git_prompt_char_stagedstate '🏁'
    set -gx __fish_git_prompt_char_untrackedfiles '✨'
    set -gx __fish_git_prompt_char_stashstate '📚'
    set -gx __fish_git_prompt_char_upstream_ahead '⏩'
    set -gx __fish_git_prompt_char_upstream_behind '⏪'

    set -gx TERM xterm-256color
    command -qv nvim && alias vim nvim
    command -qv nvim && alias v nvim
    '';
    shellAbbrs = {
      clip="xclip -selection c";
        d="docker";
        dc="docker compose";
        di="docker images";
        dlmv="mv (ls -td $HOME/Downloads/* | head -n 1) .";
        dps="docker ps";
        ga="git add";
        gap="git add -p";
        gc="git commit";
        gcd="ghq_change_directory";
        gf="git fetch";
        gq="ghq_change_directory";
        gcl="ghq get";
        gd="git diff";
        gdc="git diff --cached";
        gl="git log";
        # ref: https://zenn.dev/takuya/articles/7550d21ddd17f121602e#%E3%83%AA%E3%83%A2%E3%83%BC%E3%83%88%E3%83%AA%E3%83%9D%E3%82%B8%E3%83%88%E3%83%AA%E3%81%ABpush%E3%81%99%E3%82%8B
        gp="git push origin (git rev-parse --abbrev-ref HEAD)";
        gpl="git pull origin (git rev-parse --abbrev-ref HEAD)";
        grs="git reset";
        gs="git status";
        gsw="git switch";
        gw="git_log_switch";

        kc="kubectl";
        tf="terraform";
    };
    functions = {
      ghq_change_directory = ''
        set -l dist (ghq list | fzf -q "$argv[1]")
        if test -n "$dist"
          cd "$GHQ_ROOT/$dist"
          tmux rename-window (basename (pwd))
          return 0
        end
        return 1
      '';
      fish_user_key_dindings = ''
        fish_vi_key_bindings
      '';
      _prompt_dir = ''
        echo -n (set_color cyan)

        set matched_part (string match -r "^$GHQ_ROOT/github.com/(.*)" $PWD)

        set matched_part $matched_part[2]

        if test -n "$matched_part"
            echo -n " /$(prompt_pwd "$matched_part")"
        else
            echo -n (prompt_pwd)
        end
      '';
      _fish_prompt = ''
        _prompt_dir
        echo -n " "
        set -l last_status $status
        if [ $last_status -gt 0 ]
          echo -n (set_color red)"[$last_status] "
        end
        echo -n (set_color green)" "
      '';

    };
  };
}
