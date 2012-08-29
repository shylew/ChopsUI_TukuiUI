-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Player class.
local _, PlayerClass = UnitClass("player");

--- List of supported unit classes for custom stance checks. Don't change
--  the assigned numbers, ever. You have up to 16 class slots, should last
--  a few expansions :)
local StanceClasses = {
	["PALADIN"] = 0,
	["DEATHKNIGHT"] = 1,
	["WARLOCK"] = 2,
	["HUNTER"] = 3,
};

-- Shift the indices over 3 bits.
for class, index in pairs(StanceClasses) do
	StanceClasses[class] = bit.lshift(index, 3);
end

--- Mapping of stance/form keys to ID's as defined by the API. Also allows for
--  custom stances/forms. Custom forms need to have bit 0x80 set to 1, and
--  allow up to 8 custom stances each. API stances shouldn't go over > 127.
local StanceMap = {
	-- Half-custom, half-hack, half-unused :)
	["NONE"] = 0,
	-- Death Knights (custom).
	["BLOOD_PRESENCE"] = bit.bor(0, StanceClasses["DEATHKNIGHT"], 0x80),
	["FROST_PRESENCE"] = bit.bor(1, StanceClasses["DEATHKNIGHT"], 0x80),
	["UNHOLY_PRESENCE"] = bit.bor(2, StanceClasses["DEATHKNIGHT"], 0x80),
	-- Druids.
	["CAT_FORM"]     = 1,
	["TREE_FORM"]    = 2,
	["TRAVEL_FORM"]  = 3,
	["AQUATIC_FORM"] = 4,
	["BEAR_FORM"]    = 5,
	["FLIGHT_FORM"]  = 27,
	["MOONKIN_FORM"] = 31,
	-- Huntards.
	["ASPECT_HAWK"] = bit.bor(0, StanceClasses["HUNTER"], 0x80),
	["ASPECT_FOX"] = bit.bor(1, StanceClasses["HUNTER"], 0x80),
	["ASPECT_PACK"] = bit.bor(2, StanceClasses["HUNTER"], 0x80),
	["ASPECT_CHEETAH"] = bit.bor(3, StanceClasses["HUNTER"], 0x80),
	["ASPECT_IRON_HAWK"] = bit.bor(4, StanceClasses["HUNTER"], 0x80),
	["ASPECT_BEAST"] = bit.bor(5, StanceClasses["HUNTER"], 0x80),
	-- Monks.
	["STURDY_OX_STANCE"] = 23,
	["FIERCE_TIGER_STANCE"] = 24,
	["WISE_SERPENT_STANCE"] = 20,
	-- Paladins (API doesn't define these).
	["SEAL_OF_TRUTH"] = bit.bor(0, StanceClasses["PALADIN"], 0x80),
	["SEAL_OF_RIGHTEOUSNESS"] = bit.bor(1, StanceClasses["PALADIN"], 0x80),
	["SEAL_OF_INSIGHT"] = bit.bor(2, StanceClasses["PALADIN"], 0x80),
	-- Priests,
	["SHADOWFORM"] = 28,
	-- Rogues.
	["STEALTH"] = 30,
	-- Warlocks.
	["METAMORPHOSIS"] = 22,
	["DARK_APOTHEOSIS"] = bit.bor(0, StanceClasses["WARLOCK"], 0x80),
	-- Warriors.
	["BATTLE_STANCE"]    = 17,
	["DEFENSIVE_STANCE"] = 18,
	["BERSERKER_STANCE"] = 19,
};

--- Mapping of stances to their ability ID's. Up to 8 custom stances per class
--  are supported.
local StanceAbilityIDs = {
	["DEATHKNIGHT"] = {
		[0] = 48263, -- Blood Presence
		[1] = 48266, -- Frost Presence
		[2] = 48265, -- Unholy Presence
	},
	["HUNTER"] = {
		[0] = 13165, -- Aspect of the Hawk
		[1] = 82661, -- Aspect of the Fox
		[2] = 13159, -- Aspect of the Pack
		[3] = 5118, -- Aspect of the Cheetah
		[4] = 109260, -- Aspect of the Iron Hawk
		[5] = 61648, -- Aspect of the Beast
	},
	["PALADIN"] = {
		[0] = 31801, -- Seal of Truth
		[1] = 20154, -- Seal of Righteousness
		[2] = 20165, -- Seal of Insight
	},
	["WARLOCK"] = {
		[0] = 114168, -- Dark Apotheosis
	},
};

--- Table for mapping stance keys to abilities. Helps with the UI localisation.
local StanceUIMapping = {
	["DEATHKNIGHT"] = {
		["BLOOD_PRESENCE"]  = 48263,
		["FROST_PRESENCE"]  = 48266,
		["UNHOLY_PRESENCE"] = 48265,
	},
	["DRUID"] = {
		["CAT_FORM"]     = 768,
		["TREE_FORM"]    = 33891,
		["TRAVEL_FORM"]  = 783,
		["AQUATIC_FORM"] = 1066,
		["BEAR_FORM"]    = 5487,
		["FLIGHT_FORM"]  = 33943, -- Either flight form works. This is normal.
		["MOONKIN_FORM"] = 24858,
	},
	["HUNTER"] = {
		["ASPECT_HAWK"]      = 13165,
		["ASPECT_FOX"]       = 82661,
		["ASPECT_PACK"]      = 13159,
		["ASPECT_CHEETAH"]   = 5118,
		["ASPECT_IRON_HAWK"] = 109260,
		["ASPECT_BEAST"]     = 61648,
	},
	["MONK"] = {
		["STURDY_OX_STANCE"]    = 115069,
		["FIERCE_TIGER_STANCE"] = 103985,
		["WISE_SERPENT_STANCE"] = 115070,
	},
	["PALADIN"] = {
		["SEAL_OF_TRUTH"]         = 31801,
		["SEAL_OF_RIGHTEOUSNESS"] = 20154,
		["SEAL_OF_INSIGHT"]       = 20165,
	},
	["PRIEST"] = {
		["SHADOWFORM"] = 15473,
	},
	["ROGUE"] = {
		["STEALTH"] = 1784,
	},
	["WARLOCK"] = {
		["METAMORPHOSIS"]   = 103958,
		["DARK_APOTHEOSIS"] = 114168,
	},
	["WARRIOR"] = {
		["BATTLE_STANCE"]    = 2457,
		["DEFENSIVE_STANCE"] = 71,
		["BERSERKER_STANCE"] = 2458,
	},
};

--- Trigger class for player stance/shapeshift.
local Stance = PowerAuras:RegisterTriggerClass("Stance", {
	Parameters = {
		-- Default matched stance based upon class. Pick ones that the class
		-- generally always has access to.
		Match = (PlayerClass == "DEATHKNIGHT" and "BLOOD_PRESENCE"
			or PlayerClass == "DRUID" and "CAT_FORM"
			or PlayerClass == "HUNTER" and "ASPECT_HAWK"
			or PlayerClass == "MONK" and "FIERCE_TIGER_STANCE"
			or PlayerClass == "PALADIN" and "SEAL_OF_TRUTH"
			or PlayerClass == "PRIEST" and "SHADOWFORM"
			or PlayerClass == "ROGUE" and "STEALTH"
			or PlayerClass == "WARLOCK" and "METAMORPHOSIS"
			or PlayerClass == "WARRIOR" and "BATTLE_STANCE"
			or "NONE");
	},
	Events = {
		UPDATE_BONUS_ACTIONBAR = "Stance",
		UPDATE_SHAPESHIFT_FORM = "Stance",
		UPDATE_SHAPESHIFT_FORMS = "Stance",
		UPDATE_SHAPESHIFT_USABLE = "Stance",
		UPDATE_POSSESS_BAR = "Stance", -- Blizzard code handles this.
	},
	Services = {},
	ServiceMirrors = {
		Text    = "Stance",
		Texture = "Stance",
		Timer   = "TriggerData",
		Stacks  = "TriggerData",
	},
});

--- Constructs a new instance of the trigger and returns it.
-- @param parameters The parameters to construct the trigger from.
function Stance:New(parameters)
	-- Generate the function.
	local match = StanceMap[parameters["Match"]];
	if(match <= 127) then
		-- Simple check.
		return ([[(GetShapeshiftFormID() or 0) == %d]]):format(match);
	else
		-- We're checking one that isn't defined by the API.
		match = bit.band(match, 0x7F);
		local matchClass = bit.band(match, 0x78);
		-- Cheat a bit, if you're not the correct class then just fail.
		if(StanceClasses[PlayerClass] ~= matchClass) then
			return [[false]];
		end
		-- Get the ability ID, and generate our function.
		local matchID = StanceAbilityIDs[PlayerClass][bit.band(match, 0x07)];
		return function()
			-- Iterate over forms.
			for i = 1, GetNumShapeshiftForms() do
				local _, name, active = GetShapeshiftFormInfo(i);
				if(active and PowerAuras.SpellIDLookup[name] == matchID) then
					return true;
				end
			end
			-- Fail by default.
			return false;
		end;
	end
end

do
	--- Tooltip function for the trigger editor.
	local function OnStanceTooltipShow(item, tooltip, key)
		-- Anchor the tooltip and make it show a spell.
		tooltip:SetOwner(item, "ANCHOR_RIGHT");
		for _, stances in pairs(StanceUIMapping) do
			if(stances[key]) then
				tooltip:SetSpellByID(stances[key]);
				return;
			end
		end
	end

	--- Creates the controls for the basic activation editor frame.
	-- @param frame The frame to apply controls to.
	-- @param ... ID's to use for Get/SetParameter calls.
	function Stance:CreateTriggerEditor(frame, ...)
		-- Add a dropdown for stance pickerydoos.
		local stance = PowerAuras:Create("P_Dropdown", frame);
		-- Add items.
		stance:AddCheckItem("NONE", NONE);
		for i = 1, #(CLASS_SORT_ORDER) do
			local class = CLASS_SORT_ORDER[i];
			-- Does this class have stances?
			if(StanceUIMapping[class]) then
				-- Add menu for class.
				stance:AddMenu(class, LOCALIZED_CLASS_NAMES_MALE[class]);
				local stances = StanceUIMapping[class];
				-- Add stances.
				for key, id in PowerAuras:ByKey(stances) do
					local name = GetSpellInfo(id);
					stance:AddCheckItem(key, name or key, false, false, class);
					stance:SetItemTooltip(key, OnStanceTooltipShow);
				end
			end
		end
		-- Link parameter and finish configuring.
		stance:SetUserTooltip("Stance_Match");
		stance:LinkParameter("Trigger", "Match", ...);
		stance:SetTitle(L["Stance"]);
		stance:SetPadding(4, 0, 2, 0);
		stance:SetRelativeWidth(0.5);
		-- Add dropdown to frame.
		frame:AddWidget(stance);
	end
end

--- Upgrades the trigger from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The trigger parameters to upgrade.
function Stance:Upgrade(version, params)
	
end