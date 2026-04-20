{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";
    prefix = "C-space";
    baseIndex = 1;
    escapeTime = 0;
    historyLimit = 50000;
    mouse = true;
    keyMode = "vi";
    terminal = "tmux-256color";
    sensibleOnTop = true;
    focusEvents = true;

    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
      yank
      {
        plugin = catppuccin;
        extraConfig = ''
          # Use nord-inspired colors with catppuccin framework
          set -g @catppuccin_flavor "frappe"
          set -g @catppuccin_window_status_style "rounded"

          # Status bar modules
          set -g @catppuccin_status_modules_right "battery session date_time"
          set -g @catppuccin_date_time_text "%H:%M"
        '';
      }
      battery
      resurrect
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '10'
        '';
      }
    ];

    extraConfig = ''
      # Auto-renumber windows on close
      set -g renumber-windows on

      set -g allow-passthrough on

      # True color support
      set -ag terminal-overrides ",xterm-256color:RGB"
      set -ag terminal-overrides ",ghostty:RGB"

      # Split panes with intuitive keys
      bind v split-window -h -c "#{pane_current_path}"
      bind s split-window -v -c "#{pane_current_path}"
      unbind '"'
      unbind %
      bind-key C-Space send-prefix

      # New window keeps current path
      bind n new-window -c "#{pane_current_path}"
      bind N next-window
      unbind c

      # Fuzzy session switcher (create or switch)
      bind f display-popup -E "~/.local/bin/tmux-sessionizer"

      # Resize panes with Ctrl+hjkl (hold prefix)
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # Open URLs from pane with fzf
      bind u run-shell -b "~/.local/bin/tmux-url-picker"

      # Quick reload
      bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded"
      bind R source-file ~/.config/tmux/tmux.conf \; display "Config reloaded"

      # Vi copy mode
      bind -T copy-mode-vi v send-keys -X begin-selection
      bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "pbcopy"

      # Don't rename windows automatically
      set -g allow-rename off

      # Activity monitoring
      setw -g monitor-activity on
      set -g visual-activity off
    '';
  };
}
