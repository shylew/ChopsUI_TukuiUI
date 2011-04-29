local T, C, L = unpack(Tukui)

Options = {
	-- Config for combo points
	["core"] = { 
		spacing = T.Scale(3), 
		width = T.Scale(50),  
		height = T.Scale(15), 
		anchor = {"CENTER", UIParent, "CENTER", -106, -200},
	},
	
	-- Coloring options
	["colors"] = { 
		[1] = {.69, .31, .31, 1},
		[2] = {.65, .42, .31, 1},
		[3] = {.65, .63, .35, 1},
		[4] = {.46, .63, .35, 1},
		[5] = {.33, .63, .33, 1},
	},
	
	-- Power plugin options
	["power"] = {
		power = false,
		width = T.Scale(262), -- perfectly fits width of combo points
		height = T.Scale(10),
	},
	
	-- Point display plugin options
	["points"] = {
		display = false,
	},
}
