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

    # Unbind Ghostty defaults that conflict with our tmux bindings
    # Ghostty uses super+ internally — must unbind with super+ before cmd+ bindings work
    keybind = super+h=unbind
    keybind = super+j=unbind
    keybind = super+k=unbind
    keybind = super+l=unbind
    keybind = super+t=unbind
    keybind = super+w=unbind
    keybind = super+s=unbind
    keybind = super+shift+s=unbind
    keybind = super+f=unbind
    keybind = super+n=unbind
    keybind = super+[=unbind
    keybind = super+]=unbind
    keybind = super+shift+[=unbind
    keybind = super+shift+]=unbind
    keybind = super+1=unbind
    keybind = super+2=unbind
    keybind = super+3=unbind
    keybind = super+4=unbind
    keybind = super+5=unbind
    keybind = super+6=unbind
    keybind = super+7=unbind
    keybind = super+8=unbind
    keybind = super+9=unbind

    # Cmd+hjkl → Ctrl+hjkl for vim-tmux-navigator (thumb instead of pinky)
    keybind = cmd+h=text:\x08
    keybind = cmd+j=text:\x0a
    keybind = cmd+k=text:\x0b
    keybind = cmd+l=text:\x0c

    # Cmd → tmux operations (prefix is Ctrl+Space = \x00)
    keybind = cmd+t=text:\x00n
    keybind = cmd+w=text:\x00x
    keybind = cmd+s=text:\x00v
    keybind = cmd+shift+s=text:\x00s
    keybind = cmd+f=text:\x00f
    keybind = cmd+n=text:\x00:new-session\x0a
    keybind = cmd+1=text:\x00\x31
    keybind = cmd+2=text:\x00\x32
    keybind = cmd+3=text:\x00\x33
    keybind = cmd+4=text:\x00\x34
    keybind = cmd+5=text:\x00\x35
    keybind = cmd+6=text:\x00\x36
    keybind = cmd+7=text:\x00\x37
    keybind = cmd+8=text:\x00\x38
    keybind = cmd+9=text:\x00\x39
    keybind = cmd+[=text:\x00p
    keybind = cmd+]=text:\x00\x4e

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
