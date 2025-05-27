return {
	paddings = 3,
	group_paddings = 5,

	-- This is a font configuration for SF Pro and SF Mono (installed manually)
	font = require("helpers.default_font"),

	font = {
	  text = "JetBrainsMono Nerd Font", -- Used for text
	  numbers = "JetBrainsMono Nerd Font", -- Used for numbers
	  style_map = {
	    ["Regular"] = "Regular",
	    ["Semibold"] = "Medium",
	    ["Bold"] = "SemiBold",
	    ["Heavy"] = "Bold",
	    ["Black"] = "ExtraBold",
	  },
	},
}
