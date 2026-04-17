{ ... }:

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
    keybind = cmd+digit_1=text:\x00\x31
    keybind = cmd+digit_2=text:\x00\x32
    keybind = cmd+digit_3=text:\x00\x33
    keybind = cmd+digit_4=text:\x00\x34
    keybind = cmd+digit_5=text:\x00\x35
    keybind = cmd+digit_6=text:\x00\x36
    keybind = cmd+digit_7=text:\x00\x37
    keybind = cmd+digit_8=text:\x00\x38
    keybind = cmd+digit_9=text:\x00\x39
    keybind = cmd+shift+left_bracket=text:\x00p
    keybind = cmd+shift+right_bracket=text:\x00:next-window\x0a

    # Clickable links
    link-url = true



  '';
}
