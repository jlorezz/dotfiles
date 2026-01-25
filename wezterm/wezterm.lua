local wezterm = require 'wezterm'
local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.adjust_window_size_when_changing_font_size = false
config.color_scheme = 'Catppuccin Mocha'
config.enable_tab_bar = false
config.font_size = 16.0
config.font = wezterm.font('JetBrains Mono')

-- Platform-specific settings
if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
	-- Windows: Keep title bar so window is draggable
	config.window_decorations = 'TITLE|RESIZE'
	config.window_background_opacity = 1.0
	-- Set WSL2 as default
	config.default_domain = 'WSL:Ubuntu'  -- Change to your distro name
else
	-- macOS settings
	config.macos_window_background_blur = 30
	config.window_decorations = 'RESIZE'
	config.window_background_opacity = 1.0
end

config.keys = {
	{
		key = 'q',
		mods = 'CTRL',
		action = wezterm.action.ToggleFullScreen,
	},
	{
		key = '\'',
		mods = 'CTRL',
		action = wezterm.action.ClearScrollback 'ScrollbackAndViewport',
	},
}

config.mouse_bindings = {
	{
		event = { Up = { streak = 1, button = 'Left' } },
		mods = 'CTRL',
		action = wezterm.action.OpenLinkAtMouseCursor,
	},
}

return config
