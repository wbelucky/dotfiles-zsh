{ config, pkgs, ... }:

{
  programs.tmux = {
    extraConfig = ''
      # https://blog.himanoa.net/entries/20/ WSLでWindowsクリップボードを使う
      if-shell 'test "$(uname -a | grep -i microsoft)" != ""'  ' \
        bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "cat | win32yank.exe -i"; \
        bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "cat | win32yank.exe -i";'
    '';
  };
}
