{
  lib,
  config,
  pkgs,
  extraSpecialArgs,
  ...
}@args:

{
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "claude-code"
    ];

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
    # alacritty
    claude-code
    curl
    deno
    docker
    fd
    fzf
    gcc # for luasnip
    gh
    ghq
    go
    jq
    keychain
    (builtins.trace ''neovim ${neovim}'' neovim)
    nodejs_24
    nodePackages.pnpm
    ripgrep
    sheldon
    starship
    tmux
    zk
    zsh
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    ".markdownlinrc".source = ../.markdownlintrc;
    ".config/sheldon".source = ../.config/sheldon;
    ".config/zsh".source = ../.config/zsh;
    ".bin".source = ../.bin;
    ".zshrc".source = ../.zshrc;
    # ".codex".source = ../.codex;
    # ".config/systemd/user/ssh-agent.service".source = ./.config/systemd/user/ssh-agent.service;

  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/opteyo/etc/profile.d/hm-session-vars.sh
  #
  home = {
    sessionPath = [
      "$HOME/.local/bin/"
      "$HOME/.bin"
    ];
    sessionVariables = {
      EDITOR = "nvim";
      ZK_NOTEBOOK_DIR = "$HOME/ghq/github.com/wbelucky/diary-wb-ls/blog";
    };
  };

  programs.keychain = {
    # TODO: enabled = true
    enable = false;
    agents = [ "ssh" ];
    keys = lib.mkDefault [ "id_ed25519" ];
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.ripgrep = {
    enable = true;
    arguments = [
      "--engine=auto"
      "--hidden"
      "--glob=!.git/"
    ];
  };

  programs.tmux = {
    enable = true;
    extraConfig = ''
      set -s set-clipboard on
      set-option -g focus-events on
      # キーストロークのディレイを減らす
      set-option -sg escape-time 1
      # 操作入力後にprefixを押さずともtmux操作ができるms
      set-option -g repeat-time 0
      set-window-option -g mode-keys vi

      # これでちゃんとfish + tmuxでも色が出るようになった
      set-option -g default-terminal "tmux-256color"
      # https://stackoverflow.com/questions/60309665/neovim-colorscheme-does-not-look-right-when-using-nvim-inside-tmux
      set-option -ga terminal-overrides ",xterm-256color:Tc"

      # https://github.com/wookayin/python-imgcat?tab=readme-ov-file#notes
      set-option -g allow-passthrough on

      set -g status-fg white

      set-option -g default-shell ${pkgs.zsh}/bin/zsh

      unbind C-b
      set-option -g prefix M-d
      if-shell 'test -n "$SSH_CLIENT"' "set-option -g prefix M-f"


      bind -r k select-pane -U
      bind -r j select-pane -D
      bind -r h select-pane -L
      bind -r l select-pane -R
      bind -r M-f select-pane -t :.+
      bind -r M-d select-pane -t :.+

      # サイズ変更
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # open same directory when creating pane
      # https://qiita.com/bomcat/items/73de1105f7ffa0f93863
      bind c new-window -c '#{pane_current_path}'
      bind '"' split-window -c '#{pane_current_path}'
      bind % split-window -h -c '#{pane_current_path}'
      bind v new-window -c '#{pane_current_path}' 'ghq_change_directory & nvim +"Telescope git_files"'

      bind -r o run-shell 'xdg-open "$(tmux show-buffer)"'

      # Simply drag to select and release to copy.
      set-option -g mouse on

      # スクロールアップするとコピーモードに入る
      bind-key -n WheelUpPane if-shell -F -t = "#{mouse_any_flag}" "send-keys -M" "if -Ft= '#{pane_in_mode}' 'send-keys -M' 'select-pane -t=; copy-mode -e; send-keys -M'"

      # 最後までスクロールダウンするとコピーモードを抜ける
      bind-key -n WheelDownPane select-pane -t= \; send-keys -M

      # https://qiita.com/purutane/items/1d1dc4818013bbbaead4

      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "pbcopy"
      bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "pbcopy"
    '';
  };

  programs.git = {
    enable = true;
    userName = lib.mkDefault "wbelucky";
    userEmail = lib.mkDefault "39439193+WBelucky@users.noreply.github.com";
    extraConfig = {
      core = {
        editor = "nvim";
        pager = "LESSCHARSET=utf-8 less";
      };
      color.ui = "true";
      url."ssh://git@github.com/".insteadOf = "https://github.com/";
      github.user = config.programs.git.userName;
      difftool.nvimdiff = {
        cmd = "nvim -d \"$LOCAL\" \"$REMOTE\"";
        path = "";
      };
      merge = {
        tool = "vimfugitive";
      };
      mergetool.vimfugitive = {
        cmd = "nvim -f -c \"Gdiffsplit!\" \"$MERGED\"";
        trustExitCode = "true";
      };
      mergetool.prompt = "false";
      ghq = {
        vcs = "git";
        root = "~/ghq";
      };
      credential."https://github.com".helper = "!gh auth git-credential";
      credential."https://gist.github.com".helper = "!gh auth git-credential";
      pull.rebase = "false";
      init = {
        defaultBranch = "main";
        templatedir = "~/.git_template";
      };
      alias = {
        hist = "log --pretty=format:\"%Cgreen%h %Creset%cd %Cblue[%cn] %Creset%s%C(yellow)%d%C(reset)\" --graph --date=relative --decorate --all";
        llog = "log --graph --name-status --pretty=format:\"%C(red)%h %C(reset)(%cd) %C(green)%an %Creset%s %C(yellow)%d%Creset\" --date=relative";
        df = "!git hist | fzf | awk '{print $2}' | xargs -I {} git diff {}^ {}";
      };
    };
  };

  # programs.neovim.package = pkgs.neovim.overrideAttrs (oldAttrs: { version = "0.10.4"; src = pkgs.fetchFromGitHub { owner = "neovim"; repo = "neovim"; rev = "v0.10.4"; sha256 = "1dhqyfghcwfkp98j1b6mviwxz1fn1wn931z0w30lbrw3j5msh2sc"; }; });
  # programs.wezterm = {
  #   enable = true;
  #   extraConfig = builtins.readFile ../wezterm/wezterm.lua;
  # };
}
