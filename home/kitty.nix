{ ... }:

{
  programs.kitty = {
    enable = true;

    font = {
      name = "JetBrainsMono Nerd Font";
      size = 12.0;
    };

    extraConfig = ''
      bold_font        JetBrainsMono Nerd Font Bold
      italic_font      JetBrainsMono Nerd Font Italic
      bold_italic_font JetBrainsMono Nerd Font Bold Italic
    '';

    themeFile = "Nord";

    settings = {
      # Window
      window_padding_width = 10;
      background_opacity = "0.95";
      confirm_os_window_close = 0;

      # Cursor
      cursor_shape = "block";
      cursor_blink_interval = "-1";

      # Behavior
      scrollback_lines = 10000;
      copy_on_select = "clipboard";
      shell_integration = "enabled";

      # Hide tab bar (we use tmux)
      tab_bar_style = "hidden";

      # macOS
      macos_option_as_alt = "left";
      macos_quit_when_last_window_closed = "yes";
    };

    keybindings = {
      # Cmd+hjkl → Ctrl+hjkl for vim-tmux-navigator (thumb instead of pinky)
      "cmd+h" = "send_text all \\x08";
      "cmd+j" = "send_text all \\x0a";
      "cmd+k" = "send_text all \\x0b";
      "cmd+l" = "send_text all \\x0c";

      # Cmd → tmux operations (prefix is Ctrl+Space = \x00)
      "cmd+t" = "send_text all \\x00n";
      "cmd+w" = "send_text all \\x00x";
      "cmd+s" = "send_text all \\x00v";
      "cmd+shift+s" = "send_text all \\x00s";
      "cmd+f" = "send_text all \\x00f";
      "cmd+n" = "send_text all \\x00:new-session\\r";

      # Cmd+1-9 → tmux window switching
      "cmd+1" = "send_text all \\x001";
      "cmd+2" = "send_text all \\x002";
      "cmd+3" = "send_text all \\x003";
      "cmd+4" = "send_text all \\x004";
      "cmd+5" = "send_text all \\x005";
      "cmd+6" = "send_text all \\x006";
      "cmd+7" = "send_text all \\x007";
      "cmd+8" = "send_text all \\x008";
      "cmd+9" = "send_text all \\x009";

      # Cmd+[/] → prev/next tmux window
      "cmd+[" = "send_text all \\x00p";
      "cmd+]" = "send_text all \\x00N";
    };
  };
}
