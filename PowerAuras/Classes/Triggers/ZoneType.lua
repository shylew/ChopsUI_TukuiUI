-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

-- Import zone data.
local ZoneFlags = PowerAuras.ZoneTypes;

--- Called when a UI frame has a state/item state update.
-- @param frame The UI widget.
-- @param ...   Arguments based upon the widget type.
local function OnUIFrameUpdated(frame, ...)
	-- Get the ID of the widget.
	local _, aID, _, tID, _, box = PowerAuras:SplitNodeID(frame:GetID());
	local match = PowerAuras:GetParameter("Trigger", "Match", aID, tID);
	-- Determine the frame type.
	if(box == 1) then
		match = bit.bxor(match, ZoneTypes["arena"]);
	elseif(box == 2) then
		match = bit.bxor(match, ZoneTypes["none"]);
	elseif(box == 3) then
		match = bit.bxor(match, ZoneTypes["pvp"]);
	elseif(box == 4 or box == 5) then
		match = bit.bxor(match, (...));
	end
	-- Update.
	PowerAuras:SetParameter("Trigger", "Match", match, aID, tID);
end

--- Updates an editor UI frame.
-- @param frame The frame to update.
-- @param match The match flags.
local function UpdateUIFrame(frame, match)
	-- Get the ID of the widget.
	local _, aID, _, tID, _, box = PowerAuras:SplitNodeID(frame:GetID());
	-- Determine the flag to use.
	if(box == 1) then
		frame:SetChecked(bit.band(match, ZoneTypes["arena"]) > 0);
	elseif(box == 2) then
		frame:SetChecked(bit.band(match, ZoneTypes["none"]) > 0);
	elseif(box == 3) then
		frame:SetChecked(bit.band(match, ZoneTypes["pvp"]) > 0);
	elseif(box == 4 or box == 5) then
		-- Update checked state of all items.
		local count = 0;
		for _, item in ipairs(frame.ItemsByKey["__ROOT__"]) do
			local key = item.Key;
			local checked = (bit.band(match, key) > 0);
			frame:SetItemChecked(key, checked);
			count = (checked and count + 1 or count);
		end
		-- More than one item checked?
		if(count > 1) then
			frame:SetRawText(L["Multiple"]);
		elseif(count == 0) then
			frame:SetRawText(L["None"]);
		else
			frame:SetRawText(L["Multiple"]);
			for _, flag in pairs(ZoneTypes) do
				if(frame.ItemsByKey[flag] and bit.band(match, flag) > 0) then
					-- Got it.
					frame:SetText(flag);
					break;
				end
			end
		end
	end
end

--- Trigger class definition.
local ZoneType = PowerAuras:RegisterTriggerClass("ZoneType", {
	--- Dictionary of default parameters this trigger uses.
	Parameters = {
		Match = 0xFFFFFFFF,
	},
	--- Dictionary of events this trigger responds to.
	Events = {
		UPDATE_INSTANCE_INFO = "ZoneType",
		PLAYER_DIFFICULTY_CHANGED = "ZoneType",
	},
	--- Dictionary of provider services required by this trigger type.
	Services = {},
	--- Dictionary of supported trigger > service conversions.
	ServiceMirrors = {
		Stacks  = "TriggerData",
		Text    = "TriggerData",
		Texture = "TriggerData",
		Timer   = "TriggerData",
	},
});

--- Constructs a new instance of the trigger and returns it.
-- @param params The parameters to construct the trigger from.
function ZoneType:New(params)
	-- Extract parameters.
	local match = params["Match"];

	-- Generate the function.
	return function()
		-- Get the current instance type.
		local _, zoneType, difficulty = GetInstanceInfo();
		-- Check for an exact match.
		if(bit.band(match, (ZoneTypes[zoneType] or 0)) > 0) then
			return true;
		elseif(zoneType == "party" or zoneType == "raid") then
			-- Check for special types.
			local flag = 0;
			if(zoneType == "party") then
				flag = (difficulty == 1 and ZoneFlags["Normal5"]
					or difficulty == 2 and ZoneFlags["Heroic5"]
					or flag);
			elseif(zoneType == "raid") then
				flag = (difficulty == 1 and ZoneFlags["Normal10"]
					or difficulty == 2 and ZoneFlags["Normal25"]
					or difficulty == 3 and ZoneFlags["Heroic10"]
					or difficulty == 4 and ZoneFlags["Heroic25"]
					or flag);
			end

			-- Check for a match now.
			if(bit.band(match, flag) > 0) then
				return true;
			end
		end
		-- Getting here is failure.
		return false;
	end;
end

--- Creates the controls for the basic activation editor frame.
-- @param frame The frame to apply controls to.
-- @param ... ID's to use for Get/SetParameter calls.
function ZoneType:CreateTriggerEditor(frame, ...)
	-- Special ID for UI stuff.
	local aID, tID = ...;
	local id = PowerAuras:GetNodeID(nil, aID, 0, tID, 0, 0);

	-- Add checkboxes for the non-special types.
	local LTypes = L["ZoneType"];
	local arena = PowerAuras:Create("Checkbox", frame);
	arena:SetPadding(4, 0, 2, 0);
	arena:SetRelativeWidth(1 / 3);
	arena:SetText(LTypes["arena"]);
	arena:SetID(bit.bor(id, 1));
	UpdateUIFrame(arena, PowerAuras:GetParameter("Trigger", "Match", ...));
	arena:ConnectParameter("Trigger", "Match", UpdateUIFrame, ...);
	arena.OnValueUpdated:Connect(OnUIFrameUpdated);
	frame:AddWidget(arena);

	local none = PowerAuras:Create("Checkbox", frame);
	none:SetPadding(2, 0, 2, 0);
	none:SetRelativeWidth(1 / 3);
	none:SetText(LTypes["none"]);
	none:SetID(bit.bor(id, 2));
	UpdateUIFrame(none, PowerAuras:GetParameter("Trigger", "Match", ...));
	none:ConnectParameter("Trigger", "Match", UpdateUIFrame, ...);
	none.OnValueUpdated:Connect(OnUIFrameUpdated);
	frame:AddWidget(none);

	local pvp = PowerAuras:Create("Checkbox", frame);
	pvp:SetPadding(2, 0, 4, 0);
	pvp:SetRelativeWidth(1 / 3);
	pvp:SetText(LTypes["pvp"]);
	pvp:SetID(bit.bor(id, 3));
	UpdateUIFrame(pvp, PowerAuras:GetParameter("Trigger", "Match", ...));
	pvp:ConnectParameter("Trigger", "Match", UpdateUIFrame, ...);
	pvp.OnValueUpdated:Connect(OnUIFrameUpdated);
	frame:AddWidget(pvp);
	frame:AddRow(4);

	-- Dropdowns for the raid/party ones.
	local party = PowerAuras:Create("SimpleDropdown", frame);
	party:SetPadding(4, 0, 2, 0);
	party:SetRelativeWidth(1 / 3);
	party:SetTitle(LTypes["party"]);
	party:AddCheckItem(ZoneTypes["party"], L["Any"], nil, true);
	party:AddCheckItem(ZoneTypes["Normal5"], LTypes["Normal5"], nil, true);
	party:AddCheckItem(ZoneTypes["Heroic5"], LTypes["Heroic5"], nil, true);
	party:SetID(bit.bor(id, 4));
	UpdateUIFrame(party, PowerAuras:GetParameter("Trigger", "Match", ...));
	party:ConnectParameter("Trigger", "Match", UpdateUIFrame, ...);
	party.OnValueUpdated:Connect(OnUIFrameUpdated);
	frame:AddWidget(party);

	local raid = PowerAuras:Create("SimpleDropdown", frame);
	raid:SetPadding(4, 0, 2, 0);
	raid:SetRelativeWidth(1 / 3);
	raid:SetTitle(LTypes["raid"]);
	raid:AddCheckItem(ZoneTypes["raid"], L["Any"], nil, true);
	raid:AddCheckItem(ZoneTypes["Normal10"], LTypes["Normal10"], nil, true);
	raid:AddCheckItem(ZoneTypes["Normal25"], LTypes["Normal25"], nil, true);
	raid:AddCheckItem(ZoneTypes["Heroic10"], LTypes["Heroic10"], nil, true);
	raid:AddCheckItem(ZoneTypes["Heroic25"], LTypes["Heroic25"], nil, true);
	raid:SetID(bit.bor(id, 5));
	UpdateUIFrame(raid, PowerAuras:GetParameter("Trigger", "Match", ...));
	raid:ConnectParameter("Trigger", "Match", UpdateUIFrame, ...);
	raid.OnValueUpdated:Connect(OnUIFrameUpdated);
	frame:AddWidget(raid);
end

--- Returns true if the trigger is considered a 'support' trigger and can
--  be shown as an additional trigger option within the simple activation
--  editor.
function ZoneType:IsSupportTrigger()
	return true;
end

--- Upgrades the trigger from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The trigger parameters to upgrade.
function ZoneType:Upgrade(version, params)
end