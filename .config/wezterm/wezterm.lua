local wezterm = require 'wezterm'

return {
  color_scheme = 'Catppuccin Macchiato',
  font = wezterm.font('Dank Mono', { weight = 'Bold' } ),
  font_size = 16,
  enable_tab_bar = false,
  window_decorations = 'RESIZE',
  window_padding = {
    left = 25,
    right = 25,
    top = 25,
    bottom = 0,
  }
}
