-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Callback function for the UI checkboxes. Updates the frame.
-- @param frame The frame to update.
local function GetBitFlag(frame)
	-- Split the ID of the frame.
	local _, id, _, index, shift, flag = PowerAuras:SplitNodeID(frame:GetID());
	local match = PowerAuras:GetParameter("Trigger", "Match", id, index);
	if(shift > 0) then
		flag = bit.lshift(flag, 4);
	end
	frame:SetChecked(bit.band(match, flag) > 0);
end

--- Callback function for the UI checkboxes. Updates the Match bits.
-- @param frame The frame that was clicked.
-- @param state The state of the checkbox.
local function SetBitFlag(frame, state)
	-- Split the ID of the frame.
	local _, id, _, index, shift, flag = PowerAuras:SplitNodeID(frame:GetID());
	if(shift > 0) then
		flag = bit.lshift(flag, 4);
	end
	-- Update the parameter.
	local match = PowerAuras:GetParameter("Trigger", "Match", id, index);
	match = bit.bxor(match, flag);
	PowerAuras:SetParameter("Trigger", "Match", match, id, index);
end

--- Trigger class definition.
local Specialisation = PowerAuras:RegisterTriggerClass("Specialisation", {
	--- Dictionary of default parameters this trigger uses.
	Parameters = {
		Match = 0x03, -- 0xF0 = Spec, 0x0F = Primary/Secondary.
	},
	--- Dictionary of events this trigger responds to.
	Events = {
		LEARNED_SPELL_IN_TAB = "Specialisation",
		ACTIVE_TALENT_GROUP_CHANGED = "Specialisation",
		PLAYER_TALENT_UPDATE = "Specialisation",
	},
	--- Dictionary of provider services required by this trigger type.
	Services = {
	},
	--- Dictionary of supported trigger > service conversions.
	ServiceMirrors = {
		Stacks  = "TriggerData",
		Text    = "TriggerData",
		Texture = "TriggerData",
		Timer   = "TriggerData",
	},
});

--- Constructs a new instance of the trigger and returns it.
-- @param parameters The parameters to construct the trigger from.
function Specialisation:New(parameters)
	-- Split the parameters.
	local spec = bit.rshift(bit.band(parameters["Match"] or 0xF3, 0xF0), 4);
	local group = bit.band(parameters["Match"] or 0xF3, 0x0F);

	-- Generate the function.
	return function()
		-- Talent group check.
		if(group > 0) then
			if(bit.band(group, 2^((GetActiveSpecGroup() or 1) - 1)) == 0) then
				-- Not in this talent group.
				return false;
			end
		end

		-- Specialisation check.
		if(spec > 0) then
			if(bit.band(spec, 2^((GetSpecialization() or 1) - 1)) == 0) then
				-- Not in this spec.
				return false;
			end
		end

		-- Passed.
		return true;
	end;
end

--- Creates the controls for the basic activation editor frame.
-- @param frame The frame to apply controls to.
-- @param ... ID's to use for Get/SetParameter calls.
function Specialisation:CreateTriggerEditor(frame, ...)
	-- We use the node ID's system here to save us some trouble.
	local action, trigger = ...;
	local baseID = PowerAuras:GetNodeID(nil, action, 0, trigger, 0, 0);

	-- Spec group checkboxes.
	for i = 1, GetNumSpecGroups() do
		local group = PowerAuras:Create("Checkbox", host);
		group:SetPadding(4, 0, 4, 0);
		group:SetRelativeWidth(1 / 2);
		group:SetText(L["SpecGroup"][i]);
		group:SetID(bit.bor(baseID, 2^(i - 1)));
		group.OnValueUpdated:Connect(SetBitFlag);
		group:ConnectParameter("Trigger", "Match", GetBitFlag, ...);
		GetBitFlag(group);
		frame:AddWidget(group);
	end

	frame:AddRow(4);

	-- Specialisation.
	for i = 1, GetNumSpecializations() do
		local spec = PowerAuras:Create("Checkbox", host);
		spec:SetPadding(4, 0, 4, 0);
		spec:SetRelativeWidth(1 / 3);
		spec:SetText(select(2, GetSpecializationInfo(i)));
		spec:SetID(bit.bor(baseID, 2^(i - 1), 0x40));
		spec.OnValueUpdated:Connect(SetBitFlag);
		spec:ConnectParameter("Trigger", "Match", GetBitFlag, ...);
		GetBitFlag(spec);
		frame:AddWidget(spec);
	end
end

--- Returns true if the trigger is considered a 'support' trigger and can
--  be shown as an additional trigger option within the simple activation
--  editor.
function Specialisation:IsSupportTrigger()
	return true;
end

--- Upgrades the trigger from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The trigger parameters to upgrade.
function Specialisation:Upgrade(version, params)
end