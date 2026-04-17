{ lib, ... }:

{
  xdg.configFile."ghostty/config".text = ''
    # Theme
    theme = nord

    # Font
    font-family = JetBrainsMono Nerd Font
    font-size = 12
    font-feature = calt
    font-feature = liga

    # Window
    window-height = 35
    window-width = 120
    window-padding-x = 10
    window-padding-y = 10
    window-padding-balance = true
    window-decoration = true
    background-opacity = 0.95

    # Cursor
    cursor-style = block
    cursor-style-blink = true

    # Behavior
    scrollback-limit = 10000
    copy-on-select = true
    confirm-close-surface = true
    clipboard-paste-protection = false

    # Shell integration
    shell-integration = detect
    shell-integration-features = cursor,sudo,title

    # Splits
    focus-follows-mouse = false

    # Force Ctrl+Space through to terminal (for tmux prefix)
    keybind = ctrl+space=unbind

    # Super+hjkl → Ctrl+hjkl for vim-tmux-navigator (thumb instead of pinky)
    keybind = super+h=text:\x08
    keybind = super+j=text:\x0a
    keybind = super+k=text:\x0b
    keybind = super+l=text:\x0c

    # Super → tmux operations (prefix is Ctrl+Space = \x00)
    keybind = super+t=text:\x00n
    keybind = super+w=text:\x00x
    keybind = super+s=text:\x00v
    keybind = super+shift+s=text:\x00s
    keybind = super+f=text:\x00f
    keybind = super+n=text:\x00:new-session\x0a
    keybind = super+1=text:\x00\x31
    keybind = super+2=text:\x00\x32
    keybind = super+3=text:\x00\x33
    keybind = super+4=text:\x00\x34
    keybind = super+5=text:\x00\x35
    keybind = super+6=text:\x00\x36
    keybind = super+7=text:\x00\x37
    keybind = super+8=text:\x00\x38
    keybind = super+9=text:\x00\x39
    keybind = super+[=text:\x00p
    keybind = super+]=text:\x00\x4e

    # Clickable links
    link-url = true
  '';

  # Disable macOS "Show Previous/Next Tab" menu shortcuts that intercept Cmd+Shift+[/]
  home.activation.ghosttyDefaults = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    /usr/bin/defaults write com.mitchellh.ghostty NSUserKeyEquivalents '{
        "Show Previous Tab" = "\0";
        "Show Next Tab" = "\0";
    }'
  '';
}
