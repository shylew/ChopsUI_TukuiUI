-- Lock down local environment.
local PowerAuras = _G["PowerAuras"];
setfenv(1, PowerAuras);

-- Load modules.
local SharedChecks = PowerAuras:GetModules("SharedChecks");

-- Upvalue the check functions.
local CheckUnit = SharedChecks.CheckUnitAura;

--- Data provider class service definition.
local Stacks = PowerAuras:RegisterServiceImplementation("UnitAura", "Stacks", {
	--- Default parameters table.
	Parameters = {
		Unit = PowerAuras:EncodeUnits("player"),
		Type = 1, -- 1 = Buff, 2 = Debuff.
		Matches = PowerAuras:EncodeMatch({
			-- Default settings at index #0, inherited if not specified.
			[0] = {
				-- Effect information.
				Effect = "<Buff/Debuff Name>",
				CastBy = "player",
				Stealable = false,
				-- Additional matching flags.
				Exact = false,
				IgnoreCase = true,
				Pattern = false,
				Tooltip = "",
				UseTooltip = false,
				-- Stacks matching.
				Count = 0,
				CountSource = 0,
				Operator = ">=",
			},
			-- Actual settings from #1 onwards.
			[1] = {
			},
		}),
	},
	--- Events table.
	Events = {
		ARENA_OPPONENT_UPDATE = true,
		INSTANCE_ENCOUNTER_ENGAGE_UNIT = true,
		PARTY_MEMBERS_CHANGED = true,
		PLAYER_FOCUS_CHANGED = true,
		PLAYER_TARGET_CHANGED = true,
		RAID_ROSTER_UPDATE = true,
		UNIT_AURA = true,
		UNIT_ENTERED_VEHICLE = true,
		UNIT_EXITED_VEHICLE = true,
		UNIT_PET = true,
	},
});

--- Constructor function for the provider service.
-- @param parameters Configuration parameters for the service.
function Stacks:New(parameters)
	-- Decode our matches parameter.
	local matches = PowerAuras:DecodeMatch(parameters["Matches"], true);
	local unit = PowerAuras:DecodeUnits(parameters["Unit"]);
	-- Further initialise our matches.
	for i = 1, #(matches) do
		-- If ignoring case, convert to lowercase.
		if(matches[i].IgnoreCase) then
			matches[i].Effect = matches[i].Effect:lower();
		end
	end

	-- Turn the type into a filter string.
	local filter = (parameters["Type"] == 2 and "HARMFUL" or "HELPFUL");
	local start = 1;

	-- Get defaults.
	local default = self:GetDefaultValues(parameters);

	-- Return the trigger.
	return function()
		-- Process units.
		local result, matchUnit, index, matchIndex = PowerAuras:CheckUnits(
			unit, CheckUnit, filter, matches, start
		);
		-- Store the index for faster rechecks.
		start = index;
		if(not result) then
			return default;
		end
		-- Now get the actual stacks data.
		local _, _, _, t0, _, _, _, _, _, _, _, _, _, t1, t2, t3, wtfIsThis = 
			UnitAura(matchUnit, index, filter);
		local match = matches[matchIndex];
		return (match.CountSource == 0 and t0
				or wtfIsThis ~= nil
					and (match.CountSource == 1 and t1
						or match.CountSource == 2 and t2
						or match.CountSource == 3 and t3)
				or default);
	end
end

--- Upgrades a service from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The parameter table to be updated.
function Stacks:Upgrade(version, params)
end

function Stacks:CreateEditor(frame, ...)
	-- Match creation dialog.
	local matchBox = PowerAuras:Create("UnitAuraMatchBox", frame,
		"Provider", ...);
	matchBox:SetTitle(L["Matches"]);
	matchBox:SetRelativeWidth(0.7);
	matchBox:SetPadding(4, 0, 2, 0);
	matchBox:SetText(PowerAuras:GetParameter("Provider", "Matches", ...));
	matchBox:ConnectParameter("Provider", "Matches", matchBox.SetText, ...);
	matchBox.OnValueUpdated:Connect(PowerAuras:FormatString([[
		local self, value = ...;
		PowerAuras:SetParameter("Provider", "Matches", value, ${...});
	]], ...));
	frame:AddWidget(matchBox);

	-- Effect type.
	local effectType = PowerAuras:Create("P_Dropdown", frame);
	effectType:SetTitle(L["Type"]);
	effectType:SetRelativeWidth(0.3);
	effectType:SetPadding(2, 0, 4, 0);
	effectType:AddCheckItem(1, L["Buff"]);
	effectType:AddCheckItem(2, L["Debuff"]);
	effectType:LinkParameter("Provider", "Type", ...);
	frame:AddWidget(effectType);

	-- Unit selection dialog.
	local unitBox = PowerAuras:Create("DialogBox", frame, nil, "UnitDialog",
		"Provider", "Unit", ...);
	unitBox:SetTitle(L["Unit"]);
	unitBox:SetRelativeWidth(0.7);
	unitBox:SetPadding(4, 0, 2, 0);
	unitBox:SetText(PowerAuras:GetParameter("Provider", "Unit", ...));
	unitBox:ConnectParameter("Provider", "Unit", unitBox.SetText, ...);
	unitBox.OnValueUpdated:Connect(PowerAuras:FormatString([[
		local self, value = ...;
		PowerAuras:SetParameter("Provider", "Unit", value, ${...});
	]], ...));
	frame:AddWidget(unitBox);
end