-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Default icon path. Also used as the main fallback texture.
DefaultIcon = [[Interface\Icons\TEMP]];

--- Collection of possible display states.
DisplayStates = {
	Hide      = 0,
	BeginShow = 1,
	Show      = 2,
	BeginHide = 3,
};

--- Spells for GCD detection.
GCDSpells = {
	PALADIN = 635,       -- Holy Light
	PRIEST = 585,        -- Smite
	SHAMAN = 403,        -- Lightning Bolt
	WARRIOR = 5308,      -- Execute
	DRUID = 5176,        -- Wrath
	MAGE = 133,          -- Fireball
	WARLOCK = 686,       -- Shadow Bolt
	ROGUE = 1752,        -- Sinister Strike
	HUNTER = 982,        -- Revive Pet
	DEATHKNIGHT = 45902, -- Blood Strike
	MONK = 100787,       -- Tiger Palm (level 3).
};

--- List of all valid party unit ID's.
GroupUnitIDs = {
	["raid"] = {},
	["raidpet"] = {},
	["party"] = {},
	["partypet"] = {},
	["arena"] = {},
	["boss"] = {},
	["group"] = {},
};

for i = 1, math.max(MAX_RAID_MEMBERS, MAX_BOSS_FRAMES,
	MAX_PARTY_MEMBERS, MAX_ARENA_ENEMIES or 5) do
	-- Add unit ID's.
	if(i <= MAX_RAID_MEMBERS) then
		tinsert(GroupUnitIDs["raid"], ("%s%d"):format("raid", i));
		tinsert(GroupUnitIDs["raidpet"], ("%s%d"):format("raidpet", i));
	end
	if(i <= MAX_BOSS_FRAMES) then
		tinsert(GroupUnitIDs["boss"], ("%s%d"):format("boss", i));
	end
	if(i <= MAX_PARTY_MEMBERS) then
		tinsert(GroupUnitIDs["party"], ("%s%d"):format("party", i));
		tinsert(GroupUnitIDs["partypet"], ("%s%d"):format("partypet", i));
	end
	if(i <= (MAX_ARENA_ENEMIES or 5)) then
		tinsert(GroupUnitIDs["arena"], ("%s%d"):format("arena", i));
	end
	if(i <= math.max(_G.MAX_RAID_MEMBERS, _G.MAX_PARTY_MEMBERS)) then
		tinsert(GroupUnitIDs["group"], ("%s%d"):format("group", i));
	end
end

-- Numeric constants.
-- NOTE: Changing these will break existing variables.
-- NOTE: Changes here will need to be reflected in the metadata flag masks.
MAX_ACTIONS_PER_AURA       = 127;
MAX_ANIMATIONS_PER_CHANNEL = 63;
MAX_AURAS_PER_PROFILE      = 255;
MAX_CHANNELS_PER_DISPLAY   = 63;
MAX_DISPLAYS_PER_AURA      = 127;
MAX_LAYOUTS_PER_PROFILE    = 65535;
MAX_PROVIDERS_PER_AURA     = 65535;
MAX_REAL_AURAS_PER_PROFILE = MAX_AURAS_PER_PROFILE * 2;
MAX_SEQUENCES_PER_ACTION   = 63;
MAX_STATE_BUFFERS          = 2; -- Must be >= 2, not tested with > 2 however.
MAX_TRIGGERS_PER_ACTION    = 63;

MAX_ACTIONS_PER_PROFILE    = MAX_ACTIONS_PER_AURA * MAX_AURAS_PER_PROFILE;
MAX_DISPLAYS_PER_PROFILE   = MAX_DISPLAYS_PER_AURA * MAX_AURAS_PER_PROFILE;
MAX_PROVIDERS_PER_PROFILE  = MAX_PROVIDERS_PER_AURA * MAX_AURAS_PER_PROFILE;

--- Collection of all valid operator symbols.
Operators = {
	"<", ">", "~=", "==", "<=", ">="
};

--- Anchor points, in order.
Points = {
	"TOPLEFT", "TOP", "TOPRIGHT",
	"LEFT", "CENTER", "RIGHT",
	"BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT"
};

--- Anchor point types.
PointTypes = {
	["TOPLEFT"]     = "CORNER",
	["TOP"]         = "EDGE",
	["TOPRIGHT"]    = "CORNER",
	["LEFT"]        = "EDGE",
	["CENTER"]      = "CENTER",
	["RIGHT"]       = "EDGE",
	["BOTTOMLEFT"]  = "CORNER",
	["BOTTOM"]      = "EDGE",
	["BOTTOMRIGHT"] = "CORNER",
};

--- Logging level for the resource log. Log levels are numeric, the value
--  here represents the highest level log message allowed.
--  Recommended value: 2 (Errors + Warnings), Maximum value: 3 (All).
ResourceLoadLogLevel = 2;

--- Global dictionary of resource load states. If adding a state, ensure
--  the localization files also get an error message for the added key.
ResourceLoadMessageTypes = {
	Unloaded             = 0x1,
	Loaded               = 0x2,
	DependencyLoaded     = 0x10,
	DependencyFailed     = 0x20,
	MissingProvider      = 0x200,
	UnsupportedClass     = 0x400,
	MissingAction        = 0x800,
	MissingClass         = 0x1000,
	MissingResource      = 0x2000,
	UnsupportedAnimation = 0x4000,
	MissingTrigger       = 0x10000,
	MissingInterface     = 0x20000,
	MissingService       = 0x40000,
	InvalidTarget        = 0x80000,
	MissingLayout        = 0x400000,
	Error                = 0x800000,
	ErrorTrigger         = 0x1000000,
};

--- List of all resource types.
ResourceTypes = {
	"Action", "Animation", "Display", "Layout", "Service", "Trigger"	
};

--- List of all valid unit ID's. These do not include raid/party units.
SingleUnitIDs = {
	"player", "target", "focus", "pet", "vehicle"	
};

-- Match behaviour constants.
SPELL_MATCH_ANY          = 0x00000001;
SPELL_MATCH_ALL          = 0x00000002;
SPELL_MATCH_CALLBACK     = 0x00000004;

-- Automated flagging constants.
SPELL_MATCH_ACTION       = 0x00000010;
SPELL_MATCH_TRIGGER_TYPE = 0x00000020;
SPELL_MATCH_PROVIDER     = 0x00000040;
SPELL_MATCH_MASK         = 0x00000070;

--- Boundaries for power types. Format is Type => Number, where the number
--  is formatted as:
--  	0x80000000: If 1, infinite minimum (-math.huge).
--      0x40000000: Sign (1 if negative, 0 if positive)
--      0x3FFF0000: Minimum (range: 0-16383)
--      Same as above, but shifted right x16 for maximums.
--  This table is used for boundaries in the UI, and should represent the
--  min/max possible amounts taking into account talent/spec choices.
UnitPowerTypeBounds = {
	Mana          = 0x00008000, -- Minimum: 0, Maximum: #1.INF
	Rage          = 120,        -- Minimum: 0, Maximum: 100 (120: Glyph)
	Focus         = 100,        -- Minimum: 0, Maximum: 100
	Energy        = 100,        -- Minimum: 0, Maximum: 100
	RunicPower    = 100,        -- Minimum: 0, Maximum: 100
	SoulShards    = 3,          -- Minimum: 0, Maximum: 3
	Eclipse       = 0x40640064, -- Minimum: -100, Maximum: 100
	HolyPower     = 5,          -- Minimum: 0, Maximum: 3 (5: API internal)
	LightForce    = 5,          -- Minimum: 0, Maximum: 4 (5: Ascension talent)
	ShadowOrbs    = 3,          -- Minimum: 0, Maximum: 3
	BurningEmbers = 40,         -- Minimum: 0, Maximum: 40
	DemonicFury   = 1000,       -- Minimum: 0, Maximum: 1000
};

--- Collection of valid resource types to measure.
UnitPowerTypes = {
	Mana          = SPELL_POWER_MANA,
	Rage          = SPELL_POWER_RAGE,
	Focus         = SPELL_POWER_FOCUS,
	Energy        = SPELL_POWER_ENERGY,
	RunicPower    = SPELL_POWER_RUNIC_POWER,
	SoulShards    = SPELL_POWER_SOUL_SHARDS,
	Eclipse       = SPELL_POWER_ECLIPSE,
	HolyPower     = SPELL_POWER_HOLY_POWER,
	LightForce    = SPELL_POWER_LIGHT_FORCE,
	ShadowOrbs    = SPELL_POWER_SHADOW_ORBS,
	BurningEmbers = SPELL_POWER_BURNING_EMBERS,
	DemonicFury   = SPELL_POWER_DEMONIC_FURY,
};

--- Zone types and their bit offsets.
ZoneTypes = {
	-- API types.
	["arena"]    = 0x00000001,
	["none"]     = 0x00000002,
	["pvp"]      = 0x00000004,
	["raid"]     = 0x00000200,
	["party"]    = 0x00000400,
	-- Special types.
	["Normal5"]  = 0x00000008,
	["Heroic5"]  = 0x00000010,
	["Normal10"] = 0x00000020,
	["Heroic10"] = 0x00000040,
	["Normal25"] = 0x00000080,
	["Heroic25"] = 0x00000100,
};