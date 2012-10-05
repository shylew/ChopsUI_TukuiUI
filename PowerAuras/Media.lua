-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Dictionary of all registered bar templates.
local BarTemplateSets = {};

--- Dictionary of all registered counter sets.
local CounterSets = {};

--- Dictionary of all registered font sets.
local FontSets = {};

--- Dictionary of all registered sound sets.
local SoundSets = {};

--- Dictionary of all registered texture sets.
local TextureSets = {};

--- Attempts to find the set name of a bar template.
-- @param template The bar template name.
-- @return The owning set name, or nil.
function PowerAuras:GetOwningBarTemplateSet(template)
	-- Run over all sets and templates until we find a match.
	for name, set in pairs(BarTemplateSets) do
		for _, setTemplate in set() do
			if(setTemplate == template) then
				return name;
			end
		end
	end
end

--- Attempts to find the set name of a counter.
-- @param path The counter path.
-- @return The owning set name, or nil.
function PowerAuras:GetOwningCounterSet(path)
	-- Run over all sets and sounds until we find a match.
	for name, set in pairs(CounterSets) do
		for _, counter in set() do
			if(counter == path) then
				return name;
			end
		end
	end
end

--- Attempts to find the set name of a font.
-- @param path The font path.
-- @return The owning set name, or nil.
function PowerAuras:GetOwningFontSet(path)
	-- Run over all sets and sounds until we find a match.
	for name, set in pairs(FontSets) do
		for _, font in set() do
			if(font == path) then
				return name;
			end
		end
	end
end

--- Attempts to find the set name of a sound.
-- @param path The sound path.
-- @return The owning set name, or nil.
function PowerAuras:GetOwningSoundSet(path)
	-- Run over all sets and sounds until we find a match.
	for name, set in pairs(SoundSets) do
		for _, sound in set() do
			if(sound == path) then
				return name;
			end
		end
	end
end

--- Attempts to find the set name of a texture.
-- @param path The texture path.
-- @return The owning set name, or nil.
function PowerAuras:GetOwningTextureSet(path)
	-- Run over all sets and textures until we find a match.
	for name, set in pairs(TextureSets) do
		for _, texture in set() do
			if(texture == path) then
				return name;
			end
		end
	end
end

--- Returns the requested bar template.
-- @param template The bar template name.
function PowerAuras:GetBarTemplate(template)
	-- Run over all sets and templates until we find a match.
	for name, set in pairs(BarTemplateSets) do
		for _, templateName, data in set() do
			if(templateName == template) then
				return data;
			end
		end
	end
	return nil;
end

--- Returns the requested counter name.
-- @param counter The counter path.
function PowerAuras:GetCounterName(counter)
	-- Run over all sets and counters until we find a match.
	for name, set in pairs(CounterSets) do
		for _, counterName, path in set() do
			if(path == counter) then
				return counterName;
			end
		end
	end
	return nil;
end

--- Returns the requested counter path.
-- @param counter The counter name.
function PowerAuras:GetCounterPath(counter)
	-- Run over all sets and counters until we find a match.
	for name, set in pairs(CounterSets) do
		for _, counterName, path in set() do
			if(counterName == counter) then
				return path;
			end
		end
	end
	return nil;
end

--- Returns the requested font name.
-- @param font The font path.
function PowerAuras:GetFontName(font)
	-- Run over all sets and fonts until we find a match.
	for name, set in pairs(FontSets) do
		for _, fontName, path in set() do
			if(path == font) then
				return fontName;
			end
		end
	end
	return nil;
end

--- Returns the requested font path.
-- @param font The font name.
function PowerAuras:GetFontPath(font)
	-- Run over all sets and fonts until we find a match.
	for name, set in pairs(FontSets) do
		for _, fontName, path in set() do
			if(fontName == font) then
				return path;
			end
		end
	end
	return nil;
end

--- Returns the table of bar template sets.
function PowerAuras:GetBarTemplateSets()
	return BarTemplateSets;
end

--- Returns the table of counter sets.
function PowerAuras:GetCounterSets()
	return CounterSets;
end

--- Returns the table of font sets.
function PowerAuras:GetFontSets()
	return FontSets;
end

--- Returns the table of sound sets.
function PowerAuras:GetSoundSets()
	return SoundSets;
end

--- Returns the table of texture sets.
function PowerAuras:GetTextureSets()
	return TextureSets;
end

--- Registers a new bar template set. If the set already exists, it is replaced.
-- @param name The name of the bar template set.
-- @param iter Iterator function for accessing bar templates.
function PowerAuras:RegisterBarTemplateSet(name, iter)
	-- Register and fire UI events.
	BarTemplateSets[name] = iter;
	self.OnOptionsEvent("BAR_TEMPLATE_SET_REGISTERED", name);
end

--- Registers a new counter set. If the set already exists, it is replaced.
-- @param name The name of the counter set.
-- @param iter Iterator function for accessing counter paths.
function PowerAuras:RegisterCounterSet(name, iter)
	-- Register and fire UI events.
	CounterSets[name] = iter;
	self.OnOptionsEvent("COUNTER_SET_REGISTERED", name);
end

--- Registers a new font set. If the set already exists, it is replaced.
-- @param name The name of the font set.
-- @param iter Iterator function for accessing font paths.
function PowerAuras:RegisterFontSet(name, iter)
	-- Register and fire UI events.
	FontSets[name] = iter;
	self.OnOptionsEvent("FONT_SET_REGISTERED", name);
end

--- Registers a new sound set. If the set already exists, it is replaced.
-- @param name The name of the sound set.
-- @param iter Iterator function for accessing sound paths.
function PowerAuras:RegisterSoundSet(name, iter)
	-- Register and fire UI events.
	SoundSets[name] = iter;
	self.OnOptionsEvent("SOUND_SET_REGISTERED", name);
end

--- Registers a new texture set. If the set already exists, it is replaced.
-- @param name The name of the texture set.
-- @param iter Iterator function for accessing texture paths.
function PowerAuras:RegisterTextureSet(name, iter)
	-- Register and fire UI events.
	TextureSets[name] = iter;
	self.OnOptionsEvent("TEXTURE_SET_REGISTERED", name);
end

--------------------------------------------------------------------------------
-- Default set implementations below here.
--------------------------------------------------------------------------------

--- Iterator function for accessing all preset aura textures.
-- @param prefix The path to the textures.
-- @param index  Current texture index.
local function iterator(prefix, index)
	-- Increment index.
	index = (index or 0) + 1;
	-- If we add textures, change this limit.
	if(index > 254) then
		return nil, nil;
	end
	-- Return next texture.
	return index, prefix:format(index);
end

-- Register texture set.
PowerAuras:RegisterTextureSet("Power Auras", function()
	return iterator, [[Interface\AddOns\PowerAuras\Textures\Aura%d.tga]], nil;
end);

do
	--- WoW textures set.
	local Textures = {
		-- auras types
		[1] = "Spells\\AuraRune_B",
		[2] = "Spells\\AuraRune256b",
		[3] = "Spells\\Circle",
		[4] = "Spells\\GENERICGLOW2B",
		[5] = "Spells\\GenericGlow2b1",
		[6] = "Spells\\ShockRingCrescent256",
		[7] = "SPELLS\\AuraRune1",
		[8] = "SPELLS\\AuraRune5Green",
		[9] = "SPELLS\\AuraRune7",
		[10] = "SPELLS\\AuraRune8",
		[11] = "SPELLS\\AuraRune9",
		[12] = "SPELLS\\AuraRune11",
		[13] = "SPELLS\\AuraRune_A",
		[14] = "SPELLS\\AuraRune_C",
		[15] = "SPELLS\\AuraRune_D",
		[16] = "SPELLS\\Holy_Rune1",
		[17] = "SPELLS\\Rune1d_GLOWless",
		[18] = "SPELLS\\Rune4blue",
		[19] = "SPELLS\\RuneBC1",
		[20] = "SPELLS\\RuneBC2",
		[21] = "SPELLS\\RUNEFROST",
		[22] = "Spells\\Holy_Rune_128",
		[23] = "Spells\\Nature_Rune_128",
		[24] = "SPELLS\\Death_Rune",
		[25] = "SPELLS\\DemonRune6",
		[26] = "SPELLS\\DemonRune7",
		[27] = "Spells\\DemonRune5backup",
		-- icon types
		[28] = "Particles\\Intellect128_outline",
		[29] = "Spells\\Intellect_128",
		[30] = "SPELLS\\GHOST1",
		[31] = "Spells\\Aspect_Beast",
		[32] = "Spells\\Aspect_Hawk",
		[33] = "Spells\\Aspect_Wolf",
		[34] = "Spells\\Aspect_Snake",
		[35] = "Spells\\Aspect_Cheetah",
		[36] = "Spells\\Aspect_Monkey",
		[37] = "Spells\\Blobs",
		[38] = "Spells\\Blobs2",
		[39] = "Spells\\GradientCrescent2",
		[40] = "Spells\\InnerFire_Rune_128",
		[41] = "Spells\\RapidFire_Rune_128",
		[42] = "Spells\\Protect_128",
		[43] = "Spells\\Reticle_128",
		[44] = "Spells\\Star2A",
		[45] = "Spells\\Star4",
		[46] = "Spells\\Strength_128",
		[47] = "Particles\\STUNWHIRL",
		[48] = "SPELLS\\BloodSplash1",
		[49] = "SPELLS\\DarkSummon",
		[50] = "SPELLS\\EndlessRage",
		[51] = "SPELLS\\Rampage",
		[52] = "SPELLS\\Eye",
		[53] = "SPELLS\\Eyes",
		[54] = "SPELLS\\Zap1b",
	};

	--- Stateless iterator function.
	-- @param prefix The path prefix to access the textures.
	-- @param index  The current iteration index.
	local function iterator(prefix, index)
		index = index + 1;
		if(Textures[index]) then
			return index, prefix:format(Textures[index]);
		else
			return nil, nil;
		end
	end

	-- Register WoW textures set.
	PowerAuras:RegisterTextureSet("WoW Textures", function()
		return iterator, [[%s]], 0;
	end);
end

do
	--- Built-in sound files for the Power Auras sound file set.
	local Sounds = {
        "aggro",
        "bam",
        "cat2",
        "cookie",
        "moan",
        "phone",
        "shot",
        "sonar",
        "splash",
        "wilhelm",
        "huh_1",
        "bear_polar",
        "bigkiss",
        "BITE",
        "PUNCH",
        "burp4",
        "chimes",
        "Gasp",
        "hic3",
        "hurricane",
        "hyena",
        "Squeakypig",
        "panther1",
        "rainroof",
        "snakeatt",
        "sneeze",
        "thunder",
        "wickedmalelaugh1",
        "wlaugh",
        "wolf5",
        "swordecho",    
        "throwknife",
        "yeehaw",
        "Fireball", 
        "rocket", 
        "Arrow_Swoosh", 
        "ESPARK1", 
        "chant4", 
        "chant2", 
        "shipswhistle", 
        "kaching", 
        "heartbeat",
	};

	--- Stateless iterator function.
	-- @param prefix The path prefix to our builtin sounds.
	-- @param index  The current iteration index.
	local function iterator(prefix, index)
		index = index + 1;
		if(Sounds[index]) then
			return index, prefix:format(Sounds[index]), Sounds[index], false;
		else
			return nil, nil, nil, nil;
		end
	end

	-- Register PAC sounds set.
	PowerAuras:RegisterSoundSet("Power Auras", function()
		return iterator, [[Interface\AddOns\PowerAuras\Sounds\%s.ogg]], 0;
	end);
end

do
	--- Built-in sound files for the Power Auras sound file set.
	local Sounds = {
        "LEVELUP",
        "LOOTWINDOWCOINSOUND",
        "MapPing",
        "HumanExploration",
        "QUESTADDED",
        "QUESTCOMPLETED",
        "WriteQuest",
        "Fishing Reel in",
        "igPVPUpdate",
        "ReadyCheck",
        "RaidWarning",
        "AuctionWindowOpen",
        "AuctionWindowClose",
        "TellMessage",
        "igBackPackOpen",
        "UI_PowerAura_Generic",
	};

	--- Stateless iterator function.
	-- @param prefix The path prefix to our builtin counters.
	-- @param index  The current iteration index.
	local function iterator(prefix, index)
		index = index + 1;
		if(Sounds[index]) then
			return index, prefix:format(Sounds[index]), Sounds[index], true;
		else
			return nil, nil, nil, nil;
		end
	end

	-- Register PAC sounds set.
	PowerAuras:RegisterSoundSet("WoW Sounds", function()
		return iterator, "%s", 0;
	end);
end

do
	local Templates = {
		[1] = {
			Name = "Air",
			Type = "Horizontal",
			Size = { 256, 64 },
			StartInset = 0.12,
			EndInset = 0.12,
			Background = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Bgnd]],
			Fill = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Fill]],
			Flash = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Flash]],
			Frame = [[Interface\UnitPowerBarAlt\Air_Horizontal_Frame]],
			Spark = nil,
			FlashBlendMode = "ADD",
			SparkBlendMode = "ADD",
		},
		[2] = {
			Name = "Alliance",
			Type = "Horizontal",
			Size = { 256, 64 },
			StartInset = 0.14,
			EndInset = 0.14,
			Background = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Bgnd]],
			Fill = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Fill]],
			Flash = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Flash]],
			Frame = [[Interface\UnitPowerBarAlt\Alliance_Horizontal_Frame]],
			Spark = nil,
			FlashBlendMode = "ADD",
			SparkBlendMode = "ADD",
		},
		[3] = {
			Name = "Amber",
			Type = "Horizontal",
			Size = { 256, 64 },
			StartInset = 0.14,
			EndInset = 0.14,
			Background = [[Interface\UnitPowerBarAlt\Amber_Horizontal_Bgnd]],
			Fill = [[Interface\UnitPowerBarAlt\Amber_Horizontal_Fill]],
			Flash = [[Interface\UnitPowerBarAlt\Amber_Horizontal_Flash]],
			Frame = [[Interface\UnitPowerBarAlt\Amber_Horizontal_Frame]],
			Spark = nil,
			FlashBlendMode = "ADD",
			SparkBlendMode = "ADD",
		},
		[4] = {
			Name = "Bamboo",
			Type = "Horizontal",
			Size = { 256, 64 },
			StartInset = 0.1,
			EndInset = 0.1,
			Background = nil,
			Fill = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Fill]],
			Flash = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Flash]],
			Frame = [[Interface\UnitPowerBarAlt\Bamboo_Horizontal_Frame]],
			Spark = nil,
			FlashBlendMode = "ADD",
			SparkBlendMode = "ADD",
		},
		[5] = {
			Name = "Cho'gall",
			Type = "Horizontal",
			Size = { 256, 64 },
			StartInset = 0.24,
			EndInset = 0.24,
			Background = [[Interface\UnitPowerBarAlt\Chogall_Horizontal_Bgnd]],
			Fill = [[Interface\UnitPowerBarAlt\Chogall_Horizontal_Fill]],
			Flash = [[Interface\UnitPowerBarAlt\Chogall_Horizontal_Flash]],
			Frame = [[Interface\UnitPowerBarAlt\Chogall_Horizontal_Frame]],
			Spark = [[Interface\UnitPowerBarAlt\CHOGALL_HORIZONTAL_SPARK]],
			FlashBlendMode = "ADD",
			SparkBlendMode = "ADD",
		},
		[6] = {
			Name = "Darkmoon Faire",
			Type = "Horizontal",
			Size = { 256, 64 },
			StartInset = 0.22,
			EndInset = 0.22,
			Background = [[Interface\UnitPowerBarAlt\Darkmoon_Horizontal_Bgnd]],
			Fill = [[Interface\UnitPowerBarAlt\Darkmoon_Horizontal_Fill]],
			Flash = [[Interface\UnitPowerBarAlt\Darkmoon_Horizontal_Flash]],
			Frame = [[Interface\UnitPowerBarAlt\Darkmoon_Horizontal_Frame]],
			Spark = [[Interface\UnitPowerBarAlt\Darkmoon_Horizontal_Spark]],
			FlashBlendMode = "ADD",
			SparkBlendMode = "ADD",
		},
		[7] = {
			Name = "Deathwing (Blood)",
			Type = "Horizontal",
			Size = { 256, 64 },
			StartInset = 0.13,
			EndInset = 0.17,
			Background = [[Interface\UnitPowerBarAlt\DeathwingBlood_Horizontal_Bgnd]],
			Fill = [[Interface\UnitPowerBarAlt\DeathwingBlood_Horizontal_Fill]],
			Flash = [[Interface\UnitPowerBarAlt\DeathwingBlood_Horizontal_Flash]],
			Frame = nil,
			Spark = [[Interface\UnitPowerBarAlt\DeathwingBlood_Horizontal_Spark]],
			FlashBlendMode = "ADD",
			SparkBlendMode = "ADD",
		},
		[8] = {
			Name = "Druid",
			Type = "Horizontal",
			Size = { 256, 64 },
			StartInset = 0.14,
			EndInset = 0.14,
			Background = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Bgnd]],
			Fill = [[Interface\UnitPowerBarAlt\Druid_Horizontal_Fill]],
			Flash = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Flash]],
			Frame = [[Interface\UnitPowerBarAlt\Druid_Horizontal_Frame]],
			Spark = nil,
			FlashBlendMode = "ADD",
			SparkBlendMode = "ADD",
		},
		[9] = {
			Name = "Fancy Panda",
			Type = "Horizontal",
			Size = { 256, 64 },
			StartInset = 0.135,
			EndInset = 0.135,
			Background = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Bgnd]],
			Fill = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Fill]],
			Flash = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Flash]],
			Frame = [[Interface\UnitPowerBarAlt\FancyPanda_Horizontal_Frame]],
			Spark = nil,
			FlashBlendMode = "ADD",
			SparkBlendMode = "ADD",
		},
		[10] = {
			Name = "Fire",
			Type = "Horizontal",
			Size = { 256, 64 },
			StartInset = 0.14,
			EndInset = 0.14,
			Background = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Bgnd]],
			Fill = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Fill]],
			Flash = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Flash]],
			Frame = [[Interface\UnitPowerBarAlt\Fire_Horizontal_Frame]],
			Spark = nil,
			FlashBlendMode = "ADD",
			SparkBlendMode = "ADD",
		},
		[11] = {
			Name = "Fuel Gauge",
			Type = "Horizontal",
			Size = { 256, 64 },
			StartInset = 0.14,
			EndInset = 0.14,
			Background = [[Interface\UnitPowerBarAlt\FuelGauge_Horizontal_Bgnd]],
			Fill = [[Interface\UnitPowerBarAlt\FuelGauge_Horizontal_Fill]],
			Flash = [[Interface\UnitPowerBarAlt\FuelGauge_Horizontal_Flash]],
			Frame = [[Interface\UnitPowerBarAlt\FuelGauge_Horizontal_Frame]],
			Spark = [[Interface\UnitPowerBarAlt\FuelGauge_Horizontal_Spark]],
			FlashBlendMode = "ADD",
			SparkBlendMode = "BLEND",
		},
		[12] = {
			Name = "Generic",
			Type = "Horizontal",
			Size = { 256, 64 },
			StartInset = 0.14,
			EndInset = 0.14,
			Background = [[Interface\UnitPowerBarAlt\Generic1Player_Horizontal_Bgnd]],
			Fill = [[Interface\UnitPowerBarAlt\Generic1Player_Horizontal_Fill]],
			Flash = [[Interface\UnitPowerBarAlt\Generic1Player_Horizontal_Flash]],
			Frame = [[Interface\UnitPowerBarAlt\Generic1Player_Horizontal_Frame]],
			Spark = [[Interface\UnitPowerBarAlt\Generic1Player_Horizontal_Spark]],
			FlashBlendMode = "ADD",
			SparkBlendMode = "ADD",
		},
		[13] = {
			Name = "Horde",
			Type = "Horizontal",
			Size = { 256, 64 },
			StartInset = 0.14,
			EndInset = 0.14,
			Background = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Bgnd]],
			Fill = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Fill]],
			Flash = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Flash]],
			Frame = [[Interface\UnitPowerBarAlt\Horde_Horizontal_Frame]],
			Spark = nil,
			FlashBlendMode = "ADD",
			SparkBlendMode = "ADD",
		},
		[14] = {
			Name = "Ice",
			Type = "Horizontal",
			Size = { 256, 64 },
			StartInset = 0.14,
			EndInset = 0.14,
			Background = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Bgnd]],
			Fill = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Fill]],
			Flash = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Flash]],
			Frame = [[Interface\UnitPowerBarAlt\Ice_Horizontal_Frame]],
			Spark = nil,
			FlashBlendMode = "ADD",
			SparkBlendMode = "ADD",
		},
		[15] = {
			Name = "Map",
			Type = "Horizontal",
			Size = { 256, 64 },
			StartInset = 0.10,
			EndInset = 0.10,
			Background = [[Interface\UnitPowerBarAlt\Map_Horizontal_Bgnd]],
			Fill = [[Interface\UnitPowerBarAlt\Map_Horizontal_Fill]],
			Flash = [[Interface\UnitPowerBarAlt\Map_Horizontal_Flash]],
			Frame = [[Interface\UnitPowerBarAlt\Map_Horizontal_Frame]],
			Spark = nil,
			FlashBlendMode = "ADD",
			SparkBlendMode = "ADD",
		},
		[16] = {
			Name = "Meat",
			Type = "Horizontal",
			Size = { 256, 64 },
			StartInset = 0.135,
			EndInset = 0.135,
			Background = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Bgnd]],
			Fill = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Fill]],
			Flash = [[Interface\UnitPowerBarAlt\Meat_Horizontal_Flash]],
			Frame = [[Interface\UnitPowerBarAlt\Meat_Horizontal_Frame]],
			Spark = nil,
			FlashBlendMode = "ADD",
			SparkBlendMode = "ADD",
		},
		[17] = {
			Name = "Mechanical",
			Type = "Horizontal",
			Size = { 256, 64 },
			StartInset = 0.14,
			EndInset = 0.14,
			Background = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Bgnd]],
			Fill = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Fill]],
			Flash = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Flash]],
			Frame = [[Interface\UnitPowerBarAlt\Mechanical_Horizontal_Frame]],
			Spark = nil,
			FlashBlendMode = "ADD",
			SparkBlendMode = "ADD",
		},
		[18] = {
			Name = "Metal (Bronze)",
			Type = "Horizontal",
			Size = { 256, 64 },
			StartInset = 0.135,
			EndInset = 0.135,
			Background = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Bgnd]],
			Fill = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Fill]],
			Flash = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Flash]],
			Frame = [[Interface\UnitPowerBarAlt\MetalBronze_Horizontal_Frame]],
			Spark = nil,
			FlashBlendMode = "ADD",
			SparkBlendMode = "ADD",
		},
		[19] = {
			Name = "Metal (Eternium)",
			Type = "Horizontal",
			Size = { 256, 64 },
			StartInset = 0.135,
			EndInset = 0.135,
			Background = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Bgnd]],
			Fill = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Fill]],
			Flash = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Flash]],
			Frame = [[Interface\UnitPowerBarAlt\MetalEternium_Horizontal_Frame]],
			Spark = nil,
			FlashBlendMode = "ADD",
			SparkBlendMode = "ADD",
		},
		[20] = {
			Name = "Metal (Gold)",
			Type = "Horizontal",
			Size = { 256, 64 },
			StartInset = 0.135,
			EndInset = 0.135,
			Background = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Bgnd]],
			Fill = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Fill]],
			Flash = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Flash]],
			Frame = [[Interface\UnitPowerBarAlt\MetalGold_Horizontal_Frame]],
			Spark = nil,
			FlashBlendMode = "ADD",
			SparkBlendMode = "ADD",
		},
		[21] = {
			Name = "Metal (Plain)",
			Type = "Horizontal",
			Size = { 256, 64 },
			StartInset = 0.135,
			EndInset = 0.135,
			Background = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Bgnd]],
			Fill = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Fill]],
			Flash = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Flash]],
			Frame = [[Interface\UnitPowerBarAlt\MetalPlain_Horizontal_Frame]],
			Spark = nil,
			FlashBlendMode = "ADD",
			SparkBlendMode = "ADD",
		},
		[22] = {
			Name = "Metal (Rusted)",
			Type = "Horizontal",
			Size = { 256, 64 },
			StartInset = 0.135,
			EndInset = 0.135,
			Background = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Bgnd]],
			Fill = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Fill]],
			Flash = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Flash]],
			Frame = [[Interface\UnitPowerBarAlt\MetalRusted_Horizontal_Frame]],
			Spark = nil,
			FlashBlendMode = "ADD",
			SparkBlendMode = "ADD",
		},
		[23] = {
			Name = "Molten Rock",
			Type = "Horizontal",
			Size = { 256, 64 },
			StartInset = 0.14,
			EndInset = 0.14,
			Background = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Bgnd]],
			Fill = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Fill]],
			Flash = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Flash]],
			Frame = [[Interface\UnitPowerBarAlt\MoltenRock_Horizontal_Frame]],
			Spark = nil,
			FlashBlendMode = "ADD",
			SparkBlendMode = "ADD",
		},
		[24] = {
			Name = "Onyxia",
			Type = "Horizontal",
			Size = { 256, 64 },
			StartInset = 0.14,
			EndInset = 0.14,
			Background = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Bgnd]],
			Fill = [[Interface\UnitPowerBarAlt\Onyxia_Horizontal_Fill]],
			Flash = [[Interface\UnitPowerBarAlt\Onyxia_Horizontal_Flash]],
			Frame = [[Interface\UnitPowerBarAlt\Onyxia_Horizontal_Frame]],
			Spark = [[Interface\UnitPowerBarAlt\Onyxia_Horizontal_Spark]],
			FlashBlendMode = "ADD",
			SparkBlendMode = "ADD",
		},
		[25] = {
			Name = "Rock",
			Type = "Horizontal",
			Size = { 256, 64 },
			StartInset = 0.14,
			EndInset = 0.14,
			Background = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Bgnd]],
			Fill = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Fill]],
			Flash = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Flash]],
			Frame = [[Interface\UnitPowerBarAlt\Rock_Horizontal_Frame]],
			Spark = nil,
			FlashBlendMode = "ADD",
			SparkBlendMode = "ADD",
		},
		[26] = {
			Name = "Stone Design",
			Type = "Horizontal",
			Size = { 256, 64 },
			StartInset = 0.14,
			EndInset = 0.14,
			Background = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Bgnd]],
			Fill = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Fill]],
			Flash = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Flash]],
			Frame = [[Interface\UnitPowerBarAlt\StoneDesign_Horizontal_Frame]],
			Spark = nil,
			FlashBlendMode = "ADD",
			SparkBlendMode = "ADD",
		},
		[27] = {
			Name = "Stone Diamond",
			Type = "Horizontal",
			Size = { 256, 64 },
			StartInset = 0.14,
			EndInset = 0.14,
			Background = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Bgnd]],
			Fill = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Fill]],
			Flash = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Flash]],
			Frame = [[Interface\UnitPowerBarAlt\StoneDiamond_Horizontal_Frame]],
			Spark = nil,
			FlashBlendMode = "ADD",
			SparkBlendMode = "ADD",
		},
		[28] = {
			Name = "Stone Guard (Amethyst)",
			Type = "Horizontal",
			Size = { 256, 64 },
			StartInset = 0.14,
			EndInset = 0.14,
			Background = [[Interface\UnitPowerBarAlt\StoneGuard_Horizontal_Bgnd]],
			Fill = [[Interface\UnitPowerBarAlt\StoneGuardAmethyst_Horizontal_Fill]],
			Flash = [[Interface\UnitPowerBarAlt\StoneGuard_Horizontal_Flash]],
			Frame = [[Interface\UnitPowerBarAlt\StoneGuardAmethyst_Horizontal_Frame]],
			Spark = nil,
			FlashBlendMode = "ADD",
			SparkBlendMode = "ADD",
		},
		[29] = {
			Name = "Stone Guard (Cobalt)",
			Type = "Horizontal",
			Size = { 256, 64 },
			StartInset = 0.14,
			EndInset = 0.14,
			Background = [[Interface\UnitPowerBarAlt\StoneGuard_Horizontal_Bgnd]],
			Fill = [[Interface\UnitPowerBarAlt\StoneGuardCobalt_Horizontal_Fill]],
			Flash = [[Interface\UnitPowerBarAlt\StoneGuard_Horizontal_Flash]],
			Frame = [[Interface\UnitPowerBarAlt\StoneGuardCobalt_Horizontal_Frame]],
			Spark = nil,
			FlashBlendMode = "ADD",
			SparkBlendMode = "ADD",
		},
		[30] = {
			Name = "Stone Guard (Jade)",
			Type = "Horizontal",
			Size = { 256, 64 },
			StartInset = 0.14,
			EndInset = 0.14,
			Background = [[Interface\UnitPowerBarAlt\StoneGuard_Horizontal_Bgnd]],
			Fill = [[Interface\UnitPowerBarAlt\StoneGuardJade_Horizontal_Fill]],
			Flash = [[Interface\UnitPowerBarAlt\StoneGuard_Horizontal_Flash]],
			Frame = [[Interface\UnitPowerBarAlt\StoneGuardJade_Horizontal_Frame]],
			Spark = nil,
			FlashBlendMode = "ADD",
			SparkBlendMode = "ADD",
		},
		[31] = {
			Name = "Stone Guard (Jasper)",
			Type = "Horizontal",
			Size = { 256, 64 },
			StartInset = 0.14,
			EndInset = 0.14,
			Background = [[Interface\UnitPowerBarAlt\StoneGuard_Horizontal_Bgnd]],
			Fill = [[Interface\UnitPowerBarAlt\StoneGuardJasper_Horizontal_Fill]],
			Flash = [[Interface\UnitPowerBarAlt\StoneGuard_Horizontal_Flash]],
			Frame = [[Interface\UnitPowerBarAlt\StoneGuardJasper_Horizontal_Frame]],
			Spark = nil,
			FlashBlendMode = "ADD",
			SparkBlendMode = "ADD",
		},
		[32] = {
			Name = "Stone Tan",
			Type = "Horizontal",
			Size = { 256, 64 },
			StartInset = 0.14,
			EndInset = 0.14,
			Background = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Bgnd]],
			Fill = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Fill]],
			Flash = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Flash]],
			Frame = [[Interface\UnitPowerBarAlt\StoneTan_Horizontal_Frame]],
			Spark = nil,
			FlashBlendMode = "ADD",
			SparkBlendMode = "ADD",
		},
		[33] = {
			Name = "Undead Meat",
			Type = "Horizontal",
			Size = { 256, 64 },
			StartInset = 0.14,
			EndInset = 0.14,
			Background = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Bgnd]],
			Fill = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Fill]],
			Flash = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Flash]],
			Frame = [[Interface\UnitPowerBarAlt\UndeadMeat_Horizontal_Frame]],
			Spark = nil,
			FlashBlendMode = "ADD",
			SparkBlendMode = "ADD",
		},
		[34] = {
			Name = "Water",
			Type = "Horizontal",
			Size = { 256, 64 },
			StartInset = 0.14,
			EndInset = 0.14,
			Background = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Bgnd]],
			Fill = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Fill]],
			Flash = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Flash]],
			Frame = [[Interface\UnitPowerBarAlt\Water_Horizontal_Frame]],
			Spark = nil,
			FlashBlendMode = "ADD",
			SparkBlendMode = "ADD",
		},
		[35] = {
			Name = "Wooden Boards",
			Type = "Horizontal",
			Size = { 256, 64 },
			StartInset = 0.14,
			EndInset = 0.14,
			Background = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Bgnd]],
			Fill = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Fill]],
			Flash = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Flash]],
			Frame = [[Interface\UnitPowerBarAlt\WoodBoards_Horizontal_Frame]],
			Spark = nil,
			FlashBlendMode = "ADD",
			SparkBlendMode = "ADD",
		},
		[36] = {
			Name = "Wooden Planks",
			Type = "Horizontal",
			Size = { 256, 64 },
			StartInset = 0.14,
			EndInset = 0.14,
			Background = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Bgnd]],
			Fill = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Fill]],
			Flash = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Flash]],
			Frame = [[Interface\UnitPowerBarAlt\WoodPlank_Horizontal_Frame]],
			Spark = nil,
			FlashBlendMode = "ADD",
			SparkBlendMode = "ADD",
		},
		[37] = {
			Name = "Wooden Planks 2",
			Type = "Horizontal",
			Size = { 256, 64 },
			StartInset = 0.14,
			EndInset = 0.14,
			Background = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Bgnd]],
			Fill = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Fill]],
			Flash = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Flash]],
			Frame = [[Interface\UnitPowerBarAlt\WoodVerticalPlanks_Horizontal_Frame]],
			Spark = nil,
			FlashBlendMode = "ADD",
			SparkBlendMode = "ADD",
		},
		[38] = {
			Name = "Wood and Metal",
			Type = "Horizontal",
			Size = { 256, 64 },
			StartInset = 0.14,
			EndInset = 0.14,
			Background = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Bgnd]],
			Fill = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Fill]],
			Flash = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Flash]],
			Frame = [[Interface\UnitPowerBarAlt\WoodwithMetal_Horizontal_Frame]],
			Spark = nil,
			FlashBlendMode = "ADD",
			SparkBlendMode = "ADD",
		},
		[39] = {
			Name = "WoW UI",
			Type = "Horizontal",
			Size = { 256, 64 },
			StartInset = 0.14,
			EndInset = 0.14,
			Background = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Bgnd]],
			Fill = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Fill]],
			Flash = [[Interface\UnitPowerBarAlt\Generic1_Horizontal_Flash]],
			Frame = [[Interface\UnitPowerBarAlt\WoWUI_Horizontal_Frame]],
			Spark = nil,
			FlashBlendMode = "ADD",
			SparkBlendMode = "ADD",
		},
		[40] = {
			Name = "Sha Water",
			Type = "Horizontal",
			Size = { 256, 64 },
			StartInset = 0.14,
			EndInset = 0.14,
			Background = [[Interface\UnitPowerBarAlt\ShaWater_Horizontal_Bgnd]],
			Fill = [[Interface\UnitPowerBarAlt\ShaWater_Horizontal_Fill]],
			Flash = [[Interface\UnitPowerBarAlt\ShaWater_Horizontal_Flash]],
			Frame = nil,
			Spark = [[Interface\UnitPowerBarAlt\ShaWater_Horizontal_Spark]],
			FlashBlendMode = "ADD",
			SparkBlendMode = "ADD",
		},
		[41] = {
			Name = "Brewing Storm",
			Type = "Horizontal",
			Size = { 256, 64 },
			StartInset = 0.14,
			EndInset = 0.14,
			Background = [[Interface\UnitPowerBarAlt\BrewingStorm_Horizontal_Bgnd]],
			Fill = [[Interface\UnitPowerBarAlt\BrewingStorm_Horizontal_Fill]],
			Flash = [[Interface\UnitPowerBarAlt\BrewingStorm_Horizontal_Flash]],
			Frame = [[Interface\UnitPowerBarAlt\BrewingStorm_Horizontal_Frame]],
			Spark = [[Interface\UnitPowerBarAlt\BrewingStorm_Horizontal_Spark]],
			FlashBlendMode = "ADD",
			SparkBlendMode = "ADD",
		},
	};

	-- Sort the templates.
	table.sort(Templates, function(a, b) return a["Name"] < b["Name"]; end);

	--- Stateless iterator function.
	-- @param t     The table to iterate over.
	-- @param index The current iteration index.
	local function iterator(t, index)
		index = index + 1;
		if(t[index]) then
			return index, t[index]["Name"], t[index];
		else
			return nil, nil, nil;
		end
	end

	-- Register Blizzard bars set.
	PowerAuras:RegisterBarTemplateSet("WoW Bars", function()
		return iterator, Templates, 0;
	end);
end

do
	--- Built-in counter sets.
	local Counters = {
		{ "AccidentalPresidency", "" },
		{ "AccidentalPresidency", L["Transparent"] },
		{ "Crystal", "" },
		{ "Crystal", L["Transparent"] },
		{ "Digital", "" },
		{ "Digital", L["Transparent"] },
		{ "Monofonto", "" },
		{ "Monofonto", L["Transparent"] },
		{ "OCR", "" },
		{ "OCR", L["Transparent"] },
		{ "Original", "" },
		{ "Original", L["Transparent"] },
		{ "WhiteRabbit", "" },
		{ "WhiteRabbit", L["Transparent"] },
	};

	--- Stateless iterator function.
	-- @param prefix The path prefix to our builtin counters.
	-- @param index  The current iteration index.
	local function iterator(prefix, index)
		index = index + 1;
		if(Counters[index]) then
			local c = Counters[index];
			local name = c[1];
			if(c[2] ~= "") then
				name = ("%s (%s)"):format(c[1], c[2]);
			end
			return index, name, prefix:format(c[1], c[2]), c[2];
		else
			return nil, nil, nil, nil;
		end
	end

	-- Register PAC counters set.
	PowerAuras:RegisterCounterSet("Power Auras", function()
		return iterator,
			[[Interface\AddOns\PowerAuras\Counters\%s\Timers%s.tga]],
			0;
	end);
end

do
	--- Built-in font files for the Power Auras font file set.
	local Fonts = {
        { "Allstar", "All_Star_Resort" },
        { "Army", "Army" },
        { "Army Condensed", "Army_Condensed" },
        { "Army Expanded", "Army_Expanded" },
        { "Blazed", "Blazed" },
        { "Blox", "Blox2" },
        { "Cloister Black", "CloisterBlack" },
        { "Hexagon", "Hexagon" },
        { "Moonstar", "Moonstar" },
        { "Calibri", "Calibri" },
        { "Neon", "Neon" },
        { "Pulse Virgin", "Pulse_virgin" },
        { "Punk's Not Dead", "Punk_s_not_dead" },
        { "Starcraft", "Starcraft_Normal" },
        { "Whoa!", "whoa!" },
        { "DejaVu Sans", "DejaVu\\DejaVuSans" },
        { "DejaVu Sans Mono", "DejaVu\\DejaVuSansMono" },
        { "DejaVu Sans Serif", "DejaVu\\DejaVuSerif" },
	};

	--- Stateless iterator function.
	-- @param prefix The path prefix to our builtin counters.
	-- @param index  The current iteration index.
	local function iterator(prefix, index)
		index = index + 1;
		if(Fonts[index]) then
			return index, Fonts[index][1], prefix:format(Fonts[index][2]);
		else
			return nil, nil, nil;
		end
	end

	-- Register PAC fonts set.
	PowerAuras:RegisterFontSet("Power Auras", function()
		return iterator, [[Interface\AddOns\PowerAuras\Fonts\%s.ttf]], 0;
	end);
end

do
	--- Built-in font files for the WoW font file set.
	local Fonts = {
        { "Friz Quadrata", "FRIZQT__" },
        { "Arial Narrow", "ARIALN" },
        { "Morpheus", "MORPHEUS" },
        { "Skurri", "SKURRI" },
	};

	--- Stateless iterator function.
	-- @param prefix The path prefix to our builtin counters.
	-- @param index  The current iteration index.
	local function iterator(prefix, index)
		index = index + 1;
		if(Fonts[index]) then
			return index, Fonts[index][1], prefix:format(Fonts[index][2]);
		else
			return nil, nil, nil;
		end
	end

	-- Register fonts set.
	PowerAuras:RegisterFontSet("WoW Fonts", function()
		return iterator, [[Fonts\%s.ttf]], 0;
	end);
end