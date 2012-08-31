-- Lock down local environment. Set function environment to the localization
-- table.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras.L);

local function wrapLocalisationTable(t)
	-- Create metatable for subentries in the table.
	local subMt = {
		__index = function(t, k)
			t[k] = ("[UL] %s"):format(tostring(k));
			return t[k];
		end,
	};
	-- Wrap existing subtables with the metatable.
	for k, v in pairs(t) do
		if(type(v) == "table") then
			t[k] = setmetatable(v, subMt);
		end
	end
	-- Wrap the table with metatables.
	return setmetatable(t, {
		__index = function(t, k)
			t[k] = setmetatable({}, subMt);
			return t[k];
		end,
	});
end

-- Special tables.
ActionClasses = wrapLocalisationTable({
	["Animate"] = {
		["Name"] = "Animate",
		["Tooltip"] = "Runs an animation on a display once.",
	},
	["AnimateRepeat"] = {
		["Name"] = "Animate",
		["Tooltip"] = "Runs an animation on a display repeatedly.",
	},
	["DisplayActivate"] = {
		["Name"] = "Show",
		["Tooltip"] = "Shows/Hides a display, with an optional delay and duration.",
	},
	["DisplayAlpha"] = {
		["Name"] = "Alpha",
		["Tooltip"] = "Changes the opacity of a display.",
	},
	["DisplayBarGlow"] = {
		["Name"] = "Bar Glow",
		["Tooltip"] = "Makes the bar glow.",
	},
	["DisplayBlend"] = {
		["Name"] = "Blend",
		["Tooltip"] = "Changes the blend mode of a display.",
	},
	["DisplayColor"] = {
		["Name"] = "Color",
		["Tooltip"] = "Changes the color of the display.",
	},
	["DisplayFont"] = {
		["Name"] = "Font",
		["Tooltip"] = "Changes the font of the display.",
	},
	["DisplayRotation"] = {
		["Name"] = "Rotation",
		["Tooltip"] = "Rotates the display.",
	},
	["DisplaySaturation"] = {
		["Name"] = "Saturation",
		["Tooltip"] = "Saturates/desaturates the display.",
	},
	["DisplayScale"] = {
		["Name"] = "Scale",
		["Tooltip"] = "Changes the size of the display.",
	},
	["DisplayText"] = {
		["Name"] = "Text",
		["Tooltip"] = "Changes the text of the display.",
	},
	["DisplayTexture"] = {
		["Name"] = "Texture",
		["Tooltip"] = "Changes the texture of the display.",
	},
	["DisplaySound"] = {
		["Name"] = "Sound (Display)",
		["Tooltip"] = "[DND] Plays a sound",
	},
});

AnimationClasses = wrapLocalisationTable({
	["Bounce"] = {
		["Name"] = "Bounce",
		["Tooltip"] = "",
	},
	["Bubble"] = {
		["Name"] = "Bubble",
		["Tooltip"] = "",
	},
	["Electric"] = {
		["Name"] = "Electric",
		["Tooltip"] = "",
	},
	["Fade"] = {
		["Name"] = "Fade",
		["Tooltip"] = "",
	},
	["Flame"] = {
		["Name"] = "Flame",
		["Tooltip"] = "",
	},
	["Flashing"] = {
		["Name"] = "Flashing",
		["Tooltip"] = "",
	},
	["Pulse"] = {
		["Name"] = "Pulse",
		["Tooltip"] = "",
	},
	["Spin"] = {
		["Name"] = "Spin",
		["Tooltip"] = "",
	},
	["Translate"] = {
		["Name"] = "Translate",
		["Tooltip"] = "",
	},
	["WaterDrop"] = {
		["Name"] = "Waterdrop",
		["Tooltip"] = "",
	},
	["Wiggle"] = {
		["Name"] = "Wiggle",
		["Tooltip"] = "",
	},
	["Zoom"] = {
		["Name"] = "Zoom",
		["Tooltip"] = "",
	},
	["ZoomSpin"] = {
		["Name"] = "Zoom and Spin",
		["Tooltip"] = "",
	},
});

DisplayClasses = wrapLocalisationTable({
	["Model"] = {
		["Name"] = "3D Model",
		["Tooltip"] = "Displays the 3D model of a unit or creature.",
		["Sources"] = "Advanced Options",
		["Add"]     = "Add 3D Model",
	},
	["Stacks"] = {
		["Name"] = "Stacks",
		["Tooltip"] = "Displays a textual stack counter.",
		["Sources"] = "Advanced Options",
		["Add"]     = "Add Stacks",
	},
	["Text"] = {
		["Name"] = "Text",
		["Tooltip"] = "Displays a string of text, with support for substituting values into it.",
		["Sources"] = "Advanced Options",
		["Add"]     = "Add Text",
	},
	["Texture"] = {
		["Name"] = "Texture",
		["Tooltip"] = "Displays a texture.",
		["Sources"] = "Advanced Options",
		["Add"]     = "Add Texture",
	},
	["Timer"] = {
		["Name"] = "Timer",
		["Tooltip"] = "Displays a textual timer.",
		["Sources"] = "Advanced Options",
		["Add"]     = "Add Timer",
	},
	["TimerBar"] = {
		["Name"] = "Timer Bar",
		["Tooltip"] = "Displays a timer bar.",
		["Sources"] = "Advanced Options",
		["Add"]     = "Add Timer Bar",
	},
});

LayoutClasses = wrapLocalisationTable({
	["Fixed"] = {
		["Name"] = "Fixed",
		["Tooltip"] = "",
	},
});

ServiceClasses = wrapLocalisationTable({
	["ActionTimer"] = {
		["Name"]    = "Time Activated (Action)",
		["Timer"]   = "Use Activation Time for Timer",
	},
	["ItemOffCooldown"] = {
		["Name"]    = "Stance",
		["Stacks"]  = "Use Item Stacks",
		["Text"]    = "Use Item Text",
		["Texture"] = "Use Item Texture",
		["Timer"]   = "Use Item Timer",
	},
	["SpellOffCooldown"] = {
		["Name"]    = "Stance",
		["Stacks"]  = "Use Spell Stacks",
		["Text"]    = "Use Spell Text",
		["Texture"] = "Use Spell Texture",
		["Timer"]   = "Use Spell Timer",
	},
	["Stance"] = {
		["Name"]    = "Stance",
		["Stacks"]  = "Use for Stacks",
		["Text"]    = "Use for Text",
		["Texture"] = "Use for Texture",
		["Timer"]   = "Use for Timer",
	},
	["Static"] = {
		["Name"]    = "Static",
		["Stacks"]  = "Use for Stacks",
		["Text"]    = "Use for Text",
		["Texture"] = "Use for Texture",
		["Timer"]   = "Use for Timer",
	},
	["TriggerData"] = {
		["Name"]    = "Trigger Data",
		["Stacks"]  = "Use for Stacks",
		["Text"]    = "Use for Text",
		["Texture"] = "Use for Texture",
		["Timer"]   = "Use for Timer",
	},
	["UnitAura"] = {
		["Name"]    = "Unit Buff/Debuff",
		["Stacks"]  = "Use Buff/Debuff Stacks",
		["Text"]    = "Use Buff/Debuff Text",
		["Texture"] = "Use Buff/Debuff Texture",
		["Timer"]   = "Use Buff/Debuff Timer",
	},
});

ServiceInterfaces = wrapLocalisationTable({
	["Stacks"]  = "Stacks",
	["Text"]    = "Text",
	["Texture"] = "Texture",
	["Timer"]   = "Timer",
});

TriggerClasses = wrapLocalisationTable({
	["Aggro"] = {
		["Name"]    = "Aggro",
		["Tooltip"] = "Activates whenever you gain aggro from an enemy.",
	},
	["ComboPoints"] = {
		["Name"]    = "Combo Points",
		["Tooltip"] = "Activates after a certain amount of combo points have been obtained.",
	},
	["Dependency"] = {
		["Name"]    = "Dependency",
		["Tooltip"] = "Activates whenever another action is activated.",
	},
	["DisplayState"] = {
		["Name"]    = "Display State",
		["Tooltip"] = "Activates whenever another display is shown.",
	},
	["Equipment"] = {
		["Name"]    = "Equipped Items",
		["Tooltip"] = "Activates whenever certain items are equipped.",
	},
	["GTFO"] = {
		["Name"]    = "GTFO",
		["Tooltip"] = "Activates whenever a GTFO alert is fired. Requires the GTFO addon.",
	},
	["ItemOffCooldown"] = {
		["Name"]    = "Item Off Cooldown",
		["Tooltip"] = "Activates whenever an item comes off cooldown.",
	},
	["KillingBlow"] = {
		["Name"]    = "Killing Blow",
		["Tooltip"] = "Activates for a short period after you strike a killing blow. Have no mercy!",
	},
	["Pet"] = {
		["Name"]    = "Pet",
		["Tooltip"] = "Activates whenever your pet is active.",
	},
	["PetStance"] = {
		["Name"]    = "Pet Stance",
		["Tooltip"] = "Activates based on your pet's active stance.",
	},
	["PlayerState"] = {
		["Name"]    = "Player Status",
		["Tooltip"] = "Activates whenever a player's status changes (such as PvP flags, combat status, etc).",
	},
	["PulseTest"] = {
		["Name"]    = "[Debug] PulseTest",
		["Tooltip"] = "Toggles a display on/off every few seconds. Debug only.",
	},
	["PvP"]       = {
		["Name"]    = "PvP",
		["Tooltip"] = "Activates based upon your PvP status.",
	},
	["Runes"] = {
		["Name"]    = "Runes",
		["Tooltip"] = "Activates based upon your available runes.",
	},
	["SpellAlert"]      = {
		["Name"]    = "Spell Alert",
		["Tooltip"] = "Activates whenever a certain spell has been cast.",
	},
	["Specialisation"] = {
		["Name"]    = "Specialization",
		["Tooltip"] = "Activates based upon your current active specialization and talent group.",
	},
	["SpellCharges"] = {
		["Name"]    = "Spell Charges",
		["Tooltip"] = "Activates based upon the number of remaining uses a spell has.",
	},
	["SpellOffCooldown"] = {
		["Name"]    = "Spell Off Cooldown",
		["Tooltip"] = "Activates whenever a spell is on/off cooldown.",
	},
	["Stacks"]      = {
		["Name"]    = "Stacks",
		["Tooltip"] = "Activates based upon an amount of stacks.",
	},
	["Stance"] = {
		["Name"]    = "Stance/Form",
		["Tooltip"] = "Activates whenever you enter a specific stance or shapeshift form.",
	},
	["Static"] = {
		["Name"]    = "Static",
		["Tooltip"] = "Keeps the display permanently active.",
	},
	["Talents"] = {
		["Name"]    = "Talents",
		["Tooltip"] = "Activates based upon your chosen talents.",
	},
	["Timer"] = {
		["Name"]    = "Timer",
		["Tooltip"] = "Activates when the time (active or remaining) exceeds a specified threshold.",
	},
	["Totems"] = {
		["Name"]    = "Totems",
		["Tooltip"] = "Activates based upon your active totems.",
	},
	["UnitAura"] = {
		["Name"]    = "Unit Buff/Debuff",
		["Tooltip"] = "Activates whenever a unit gains/loses a specified buff or debuff.",
	},
	["UnitAuraType"] = {
		["Name"]    = "Unit Buff/Debuff Type",
		["Tooltip"] = "Activates whenever a unit gains/loses a buff or debuff of a specific type.",
	},
	["UnitData"] = {
		["Name"]    = "Unit Information",
		["Tooltip"] = "Activates based upon the information of a unit, such as their class.",
	},
	["UnitExists"] = {
		["Name"]    = "Unit Exists",
		["Tooltip"] = "Activates based upon whether or not a unit exists.",
	},
	["UnitHealth"] = {
		["Name"]    = "Unit Health",
		["Tooltip"] = "Activates whenever a unit's health reaches a certain threshold.",
	},
	["UnitPower"] = {
		["Name"]    = "Unit Power",
		["Tooltip"] = "Activates when a unit's power level reaches a certain threshold.",
	},
	["WeaponEnchant"] = {
		["Name"]    = "Weapon Enchant",
		["Tooltip"] = "Activates based upon your active weapon enchants.",
	},
	["ZoneType"] = {
		["Name"]    = "Zone Type",
		["Tooltip"] = "Activates based upon the type of your current zone.",
	},
});

Buttons = {
	["Left"] = "Left Click",
	["Right"] = "Right Click",
};

Modifiers = {
	["Alt"] = "Alt",
	["Shift"] = "Shift",
	["Ctrl"] = "Ctrl",		
};

SpecGroup = {
	[1] = "Primary Talents",
	[2] = "Secondary Talents",
};

Down = "Down";
Up = "Up";

ModButtons1 = "%s-%s";
ModButtons2 = "%s-%s-%s";
ModButtons3 = "%s-%s-%s-%s";

TColon = "|cFFFFD200%s:|r";
TColon2 = "|cFFFFD200%s: |r%s";

NoDescription = "No description";

DialogResetProfile = "Reset current profile?";
DialogCreateProfile = "Enter a profile name:";
DialogDeleteProfile = "Delete profile %s?";
DialogRenameProfile = "Enter a new name:";

Accept = "Accept";
Cancel = "Cancel";

DeleteProfile = "Delete Profile";
RenameProfile = "Rename Profile";

DiscoModeEngage = "|cFFFF0000Di|r|cFFFF8000sco|r|cFFFFFF00 Mo|r|cFF008000de |r|cFF0000FFEn|r|cFF4B0082gag|r|cFF9400D3ed!|r";

DISPLAY_SOURCE_AUTO    = "Automatic";
DISPLAY_SOURCE_MANUAL  = "Manual";
DISPLAY_SOURCE_TRIGGER = "Trigger";

Error = "Error";

ErrorActionClassConstructed = "Action ID %s has already been constructed.";
ErrorActionClassExists = "Action class '%s' already exists.";
ErrorActionClassInvalid = "Action class '%s' is invalid.";
ErrorActionClassInvalidType = "Action class '%s' is of invalid type '%s'.";
ErrorActionClassMissing = "Action class '%s' does not exist.";
ErrorActionNotLoaded = "Action %s has not been loaded.";

ErrorAnimClassExists = "Animation class '%s' already exists.";
ErrorAnimClassInvalid = "Animation class '%s' is invalid.";
ErrorAnimClassInvalidType = "Animation class type '%s' does not exist.";
ErrorAnimClassMissing = "Animation class '%s' does not exist.";
ErrorAnimTypeInvalid = "Animation class '%s' does not support type '%s'.";

ErrorAuraIDInvalid = "Aura ID %s does not resolve to a valid aura.";
ErrorAuraDisplayIDInvalid = "Display ID %s does not resolve to a valid display.";
ErrorAuraActionIDInvalid = "Action ID %s does not resolve to a valid action.";
ErrorAuraProviderIDInvalid = "Provider ID %s does not resolve to a valid provider.";

ErrorDispatcherCircularDeps = "Actions contain circular/missing dependencies.";
ErrorDispatcherCircularDep = "Action %s depends upon: %s";
ErrorDispatcherCircularDepTitle = "Circular/Missing Dependencies:";

ErrorDisplayAction = "Could not assign action '%s' to display.";
ErrorDisplayNotLoaded = "Display %s has not been loaded.";
ErrorDisplayClassConstructed = "Display ID %s has already been constructed.";
ErrorDisplayClassExists = "Display class '%s' already exists.";
ErrorDisplayClassInvalid = "Invalid class (%s): Field '%s' is of type '%s', expected '%s'.";
ErrorDisplayClassInvalidAction = "Display class '%s' does not support action '%s'";
ErrorDisplayClassMissing = "Display class '%s' does not exist.";

ErrorLayoutClassConstructed = "Layout ID %s has already been constructed.";
ErrorLayoutClassExists = "Layout class '%s' already exists.";
ErrorLayoutClassInvalid = "Layout class '%s' is invalid.";
ErrorLayoutClassMissing = "Layout class '%s' does not exist.";
ErrorLayoutIDInvalid = "Layout ID %s does not resolve to a valid layout.";
ErrorLayoutNotLoaded = "Layout %s has not been loaded.";

ErrorOptionsNotEnabled = "The aura editor is unavailable as the options addon is %s.";

ErrorPluginFailed = "Failed to load plugin '%s': %s";

ErrorProfileIDInvalid = "Profile %s does not exist.";
ErrorProfileImport = "Profile import failed with error: %s";

ErrorSequenceIDInvalid = "Action %s does not have a sequence with index %s.";

ErrorServiceClassMissing = "Service class '%s' does not exist.";
ErrorServiceClassInvalid = "Service class '%s' incorrectly implements interface '%s'.";
ErrorServiceImplemented = "Service class '%s' already implements '%s'.";
ErrorServiceImplementsInvalid = "Service class '%s' cannot implement '%s'.";
ErrorServiceImplementsMissing = "Service class '%s' does not implement '%s'.";
ErrorServiceInterfaceMissing = "Service interface '%s' does not exist.";
ErrorServiceInterfaceExists = "Service interface '%s' already exists.";

ErrorTriggerClassExists = "Trigger class '%s' already exists.";
ErrorTriggerClassInvalid = "Trigger class '%s' is invalid.";
ErrorTriggerClassMissing = "Trigger class '%s' does not exist.";
ErrorTriggerIDInvalid = "Action %s does not have a trigger with index %s.";
ErrorTriggerMissing = "Trigger ID %s is not defined.";

ErrorValidateActionsFailed = "%s actions failed dependency validation tests.";
ErrorValidateDisplaysFailed = "%s displays failed dependency validation tests.";

InfoHelpCmdUsage = "Usage: /powa <command>";
InfoHelpCmd = "/powa %s - %s";
InfoHelpCmdReset = "Resets your current active profile.";
InfoHelpCmdList = "Lists all profiles.";
InfoHelpCmdCurrent = "List current profile name.";
InfoHelpCmdDebug = "Shows the debug output window.";
InfoHelpCmdMigrate = "Upgrades any present 4.x profiles to 5.0.";

InfoProfile = "Current profile: %s";
InfoProfileList = "Existing profiles:";
InfoProfileMatch = "%s |cFF00FF00<Current>|r";
InfoProfileNotFound = "Profile '%s' could not be found, '%s' has been created/loaded instead.";

LegacyFailed = "Failed to upgrade 4.x auras (%d/%d processed).";
LegacySuccess = "Successfully upgraded 4.x auras (%d/%d processed).";

ProfileLoadDeferred     = "Profile '%s' will be loaded shortly due to background activity.";
ProfileLoadDeferredGo   = "Loading profile '%s'...";
ProfileUnloadDeferred   = "Your current profile will be unloaded shortly due to background activity.";
ProfileUnloadDeferredGo = "Unloading current profile...";

ResourceLogMsgUnloaded = "Successfully unloaded ${1} ${2}.";
ResourceLogMsgLoaded = "Successfully loaded ${1} ${2}.";
ResourceLogMsgDependencyFailed = "Failed to load ${1} ${2}: Dependency failed to load (${3} ${4}).";
ResourceLogMsgMissingClass = "Failed to load ${1} ${2}: Class ${3} not registered.";
ResourceLogMsgMissingTrigger = "Failed to load ${1} ${2}: Referenced trigger not found (${3}).";
ResourceLogMsgInvalidTarget = "Failed to load ${1} ${2}: Resource target is invalid (${3})."
ResourceLogMsgError = "Failed to load ${1} ${2}: ${3}";
ResourceLogMsgDependencyLoaded = "Failed to load ${1} ${2}: Dependency ${3} ${4} was already loaded.";
ResourceLogMsgMissingAction = "Failed to load ${1} ${2}: Action ${3} was not found.";
ResourceLogMsgMissingService = "Failed to load ${1} ${2}: Requires ${3} implementation of ${4}.";
ResourceLogMsgMissingInterface = "Failed to load ${1} ${2}: Provider requires ${3} service.";
ResourceLogMsgErrorTrigger = "Failed to load ${1} ${2}: Trigger ${3} failed to load.";

SourceAutoConfFail = "Failed to automatically configure source for display %d.";
TSourceAutoConfFail = "Failed to automatically configure trigger source: %s";
TSourceAutoConfNoMain = "No eligible triggers to configure from.";

Yes = "Yes";
No = "No";

Transparent = "Transparent";

UnitAuraType = {
	[1]  = "Curse",
	[2]  = "Disease",
	[3]  = "Magic",
	[4]  = "Poison",
	[5]  = "Enrage",
	[6]  = "Debuff: Weakened Armor",
	[7]  = "Debuff: Physical Vulnerability",
	[8]  = "Debuff: Weakened Blows",
	[9]  = "Debuff: Mortal Wounds",
	[10] = "Debuff: Magic Vulnerability",
	[11] = "Debuff: Slow Casting",
	[12] = "Buff: Stats",
	[13] = "Buff: Stamina",
	[14] = "Buff: Attack Power",
	[15] = "Buff: Spell Power",
	[16] = "Buff: Haste",
	[17] = "Buff: Spell Haste",
	[18] = "Buff: Critical Strike",
	[19] = "Buff: Mastery",
};

UnitPower = {
	Mana          = "Mana",
	Rage          = "Rage",
	Focus         = "Focus",
	Energy        = "Energy",
	RunicPower    = "Runic Power",
	SoulShards    = "Soul Shards",
	Eclipse       = "Eclipse",
	HolyPower     = "Holy Power",
	LightForce    = "Chi",
	ShadowOrbs    = "Shadow Orbs",
	BurningEmbers = "Burning Embers",
	DemonicFury   = "Demonic Fury",
};

Units = wrapLocalisationTable({
	-- Single units.
	["single"]  = "Individuals",
	["player"]  = "Player",
	["target"]  = "Target",
	["focus"]   = "Focus",
	["pet"]     = "Pet",
	["vehicle"] = "Vehicle",
	-- Group units.
	["raid"]    = "Raid",
	["raidpet"]    = "Raid Pet",
	["party"]   = "Party",
	["partypet"]   = "Party Pet",
	["arena"]   = "Arena Opponents",
	["boss"]    = "Bosses",
	["group"]    = "Raid or Party",
	-- Formatters for groups.
	["raid%d"]   = "Member %d",
	["raidpet%d"]   = "Pet %d",
	["party%d"]  = "Member %d",
	["partypet%d"]  = "Pet %d",
	["arena%d"]  = "Opponent %d",
	["boss%d"]   = "Boss %d",
	["group%d"]   = "Member %d",
	-- Specifiers.
	["raid-all"]  = "All",
	["raid-any"]  = "Any",
	["raidpet-all"]  = "All",
	["raidpet-any"]  = "Any",
	["party-all"] = "All",
	["party-any"] = "Any",
	["partypet-all"]  = "All",
	["partypet-any"]  = "Any",
	["arena-all"] = "All",
	["arena-any"] = "Any",
	["boss-all"]  = "All",
	["boss-any"]  = "Any",
	["group-all"] = "All",
	["group-any"] = "Any",
});

ZoneType = wrapLocalisationTable({
	-- API types.
	["arena"]    = "Arena",
	["none"]     = "World",
	["pvp"]      = "Battleground",
	["raid"]     = "Raid",
	["party"]    = "Party",
	-- Special types.
	["Normal5"]  = "Normal",
	["Heroic5"]  = "Heroic",
	["Normal10"] = "Normal (10)",
	["Heroic10"] = "Heroic (10)",
	["Normal25"] = "Normal (25)",
	["Heroic25"] = "Heroic (25)",
});

-- Fill in units automatically.
for i = 1, math.max(_G.MAX_RAID_MEMBERS, _G.MAX_BOSS_FRAMES,
	_G.MAX_PARTY_MEMBERS, _G.MAX_ARENA_ENEMIES or 5) do
	-- Add unit ID's.
	if(i <= _G.MAX_RAID_MEMBERS) then
		Units[("raid%d"):format(i)] = Units["raid%d"]:format(i);
		Units[("raidpet%d"):format(i)] = Units["raidpet%d"]:format(i);
	end
	if(i <= _G.MAX_BOSS_FRAMES) then
		Units[("boss%d"):format(i)] = Units["boss%d"]:format(i);
	end
	if(i <= _G.MAX_PARTY_MEMBERS) then
		Units[("party%d"):format(i)] = Units["party%d"]:format(i);
		Units[("partypet%d"):format(i)] = Units["partypet%d"]:format(i);
	end
	if(i <= (_G.MAX_ARENA_ENEMIES or 5)) then
		Units[("arena%d"):format(i)] = Units["arena%d"]:format(i);
	end
	if(i <= math.max(_G.MAX_RAID_MEMBERS, _G.MAX_PARTY_MEMBERS)) then
		Units[("group%d"):format(i)] = Units["group%d"]:format(i);
	end
end