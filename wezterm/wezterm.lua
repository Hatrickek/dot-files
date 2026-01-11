local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.font = wezterm.font("Iosevka Nerd Font", { weight = "Regular", italic = false })
config.color_scheme = "Gruvbox Dark (Gogh)"

return config
