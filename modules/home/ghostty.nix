{ ... }:
{
  xdg.configFile."ghostty/config".text = ''
    theme = catppuccin-mocha
    font-family = JetBrainsMono Nerd Font
    font-size = 14
    background-opacity = 0.96
    window-padding-x = 8
    window-padding-y = 8
    macos-titlebar-style = tabs

    shell-integration = zsh
    shell-integration-features = cursor,sudo,title

    keybind = cmd+d=new_split:right
    keybind = cmd+shift+d=new_split:down
    keybind = cmd+left_bracket=previous_split
    keybind = cmd+right_bracket=next_split
    keybind = cmd+shift+left_bracket=resize_split:left,40
    keybind = cmd+shift+right_bracket=resize_split:right,40
    keybind = cmd+shift+enter=toggle_split_zoom
    keybind = cmd+w=close_surface

    copy-on-select = clipboard
    confirm-close-surface = false
    window-save-state = always
  '';
}
