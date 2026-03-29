{
  lib,
  pkgs,
  ...
}:
{
  home-manager.sharedModules = lib.singleton {
    programs.tmux = {
      enable = true;
      terminal        = "screen-256color";
      prefix          = "C-a";
      baseIndex       = 1;
      escapeTime      = 0;
      historyLimit    = 1000000;
      keyMode         = "vi";
      sensibleOnTop   = true;
      mouse           = false;

      plugins = with pkgs.tmuxPlugins; [
        yank
        tmux-thumbs
        {
          plugin = resurrect;
          extraConfig = ''
            set -g @resurrect-strategy-nvim 'session'
          '';
        }
        {
          plugin = continuum;
          extraConfig = ''
            set -g @continuum-restore 'on'
          '';
        }
        {
          plugin = tmux-fzf;
          extraConfig = "";
        }
        {
          plugin = fzf-tmux-url;
          extraConfig = ''
            set -g @fzf-url-fzf-options '-p 60%,30% --prompt="   " --border-label=" Open URL "'
            set -g @fzf-url-history-limit '2000'
          '';
        }
        {
          plugin = catppuccin;
          extraConfig = ''
            set -g @catppuccin_window_left_separator ""
            set -g @catppuccin_window_right_separator " "
            set -g @catppuccin_window_middle_separator " █"
            set -g @catppuccin_window_number_position "right"
            set -g @catppuccin_window_default_fill "number"
            set -g @catppuccin_window_default_text "#W"
            set -g @catppuccin_window_current_fill "number"
            set -g @catppuccin_window_current_text "#W#{?window_zoomed_flag,(),}"
            set -g @catppuccin_status_modules_right "directory"
            set -g @catppuccin_status_modules_left "session"
            set -g @catppuccin_status_left_separator  " "
            set -g @catppuccin_status_right_separator " "
            set -g @catppuccin_status_right_separator_inverse "no"
            set -g @catppuccin_status_fill "icon"
            set -g @catppuccin_status_connect_separator "no"
            set -g @catppuccin_directory_text "#{b:pane_current_path}"
          '';
        }
        {
          plugin = tmux-sessionx;
          extraConfig = ''
            set -g @sessionx-bind 'o'
            set -g @sessionx-bind-zo-new-window 'ctrl-y'
            set -g @sessionx-auto-accept 'off'
            set -g @sessionx-x-path '~/dotfiles'
            set -g @sessionx-window-height '85%'
            set -g @sessionx-window-width '75%'
            set -g @sessionx-zoxide-mode 'on'
            set -g @sessionx-custom-paths-subdirectories 'false'
            set -g @sessionx-filter-current 'false'
          '';
        }
        {
          plugin = tmux-floax;
          extraConfig = ''
            set -g @floax-width '80%'
            set -g @floax-height '80%'
            set -g @floax-border-color 'magenta'
            set -g @floax-text-color 'blue'
            set -g @floax-bind 'p'
            set -g @floax-change-path 'true'
          '';
        }
      ];

      extraConfig = ''
        # Source reset config (create this file separately)
        source-file ~/.config/tmux/tmux.reset.conf

        # Terminal overrides
        set-option -g terminal-overrides ',xterm-256color:RGB'

        # Session behaviour
        set -g detach-on-destroy off
        set -g renumber-windows on
        set -g set-clipboard on
        set -g status-position top

        # Pane borders
        set -g pane-active-border-style 'fg=magenta,bg=default'
        set -g pane-border-style 'fg=brightblack,bg=default'
      '';
    };
    home.file.".config/tmux/tmux.reset.conf".text = ''
      unbind-key -a

      bind ^X lock-server
      bind ^C new-window -c "$HOME"
      bind ^D detach
      bind *  list-clients

      bind H previous-window
      bind L next-window
      bind r command-prompt "rename-window %%"
      bind R source-file ~/.config/tmux/tmux.conf
      bind ^A last-window
      bind ^W list-windows
      bind w  list-windows
      bind z  resize-pane -Z
      bind ^L refresh-client
      bind l  refresh-client

      bind |  split-window
      bind s  split-window -v -c "#{pane_current_path}"
      bind v  split-window -h -c "#{pane_current_path}"
      bind '"' choose-window

      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      bind -r -T prefix , resize-pane -L 20
      bind -r -T prefix . resize-pane -R 20
      bind -r -T prefix - resize-pane -D 7
      bind -r -T prefix = resize-pane -U 7

      bind :  command-prompt
      bind *  setw synchronize-panes
      bind P  set pane-border-status
      bind c  kill-pane
      bind x  swap-pane -D
      bind S  choose-session
      bind K  send-keys "clear"\; send-keys "Enter"

      bind-key -T copy-mode-vi v send-keys -X begin-selection
    '';
  };
}