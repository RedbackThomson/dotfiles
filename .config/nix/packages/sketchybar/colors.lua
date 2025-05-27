local colors = {
	black = 0xff232634,       -- mantle
	white = 0xffc6d0f5,       -- text
	red = 0xffe78284,         -- red
	green = 0xffa6d189,       -- green
	blue = 0xff8caaee,        -- blue
	yellow = 0xffe5c890,      -- yellow
	orange = 0xffef9f76,      -- peach
	magenta = 0xffca9ee6,     -- mauve
	grey = 0xff737994,        -- surface2
	transparent = 0x00000000,

	bar = {
		bg = 0xff303446,       -- base
		border = 0xff303446,   -- base
	},

	popup = {
		bg = 0xcc303446,       -- base with alpha (~80%)
		border = 0xff737994,   -- surface2
	},

	bg1 = 0xff414559,         -- surface0
	bg2 = 0xff51576d,         -- surface1
	bg3 = 0xff626880,         -- surface2

	with_alpha = function(color, alpha)
		if alpha > 1.0 or alpha < 0.0 then
			return color
		end
		return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
	end,
}

colors.bg0 = colors.transparent

return colors
