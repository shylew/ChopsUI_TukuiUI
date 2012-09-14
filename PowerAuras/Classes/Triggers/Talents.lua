-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Callback function for the UI checkboxes. Updates the frame.
-- @param frame The frame to update.
local function GetBitFlag(frame)
	-- Get the ID of this talent.
	local _, id, _, index, _, talent = PowerAuras:SplitNodeID(frame:GetID());
	-- Split the talent into the components.
	local row = bit.band(bit.rshift(talent, 3), 0xF);
	local col = bit.band(talent, 0x3);
	-- Get the bit for this talent.
	local m = PowerAuras:GetParameter("Trigger", "Match", id, index);
	frame:SetChecked(bit.band(bit.rshift(m, (row * 3) + (col - 1)), 0x1) == 1);
end

--- Callback function for the UI checkboxes. Updates the Match bits.
-- @param frame The frame that was clicked.
-- @param state The state of the checkbox.
local function SetBitFlag(frame, state)
	-- Get the ID of this talent.
	local _, id, _, index, _, talent = PowerAuras:SplitNodeID(frame:GetID());
	-- Split the talent into the components.
	local row = bit.band(bit.rshift(talent, 3), 0xF);
	local col = bit.band(talent, 0x3);
	-- Toggle the bit for this talent.
	local m = PowerAuras:GetParameter("Trigger", "Match", id, index);
	m = bit.bxor(m, 2^((row * 3) + (col - 1)));
	PowerAuras:SetParameter("Trigger", "Match", m, id, index);
end

--- Trigger class definition.
local Talents = PowerAuras:RegisterTriggerClass("Talents", {
	--- Dictionary of default parameters this trigger uses.
	Parameters = {
		Match = 0x00000000, -- Each talent is a single bit, from right to left
		                    -- being the first to last talents. A row with
		                    -- no bits set is ignored.
	},
	--- Dictionary of events this trigger responds to.
	Events = {
		PLAYER_TALENT_UPDATE = "Talents",
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
function Talents:New(parameters)
	-- Sort out the parameters.
	local match = parameters["Match"];

	-- Generate the check.
	return function()
		-- Save us some trouble if possible.
		if(match == 0) then
			return true;
		end

		-- Iterate over talent rows.
		for i = 0, GetMaxTalentTier() - 1 do
			local m = bit.band(bit.rshift(match, i * 3), 0x7);
			-- Anything to check on this row?
			if(m > 0) then
				-- Check if talents are selected.
				local _, _, _, _, selected;
				for j = 1, 3 do
					_, _, _, _, selected = GetTalentInfo((i * 3) + j);
					if(selected) then
						-- Matching this one?
						if(bit.band(m, 2^(j - 1)) == 0) then
							-- Failed.
							return false;
						end
						-- Otherwise, break (one talent per row!).
						break;
					end
				end
				-- Did you not select a talent?
				if(not selected) then
					-- Failed, we needed to find a talent (m is > 0).
					return false;
				end
			end
		end
		-- Getting here should be a success.
		return true;
	end;
end

--- Creates the controls for the basic activation editor frame.
-- @param frame The frame to apply controls to.
-- @param ... ID's to use for Get/SetParameter calls.
function Talents:CreateTriggerEditor(frame, ...)
	-- Use ID's for identifying each item.
	local action, trigger = ...;
	local baseID = PowerAuras:GetNodeID(nil, action, 0, trigger, 0, 0);

	-- Add checkboxes for each talent.
	-- Note: This breaks if there's > 3 talents/row or 9+ rows.
	for i = 0, GetMaxTalentTier() - 1 do
		for j = 1, 3 do
			local talent = PowerAuras:Create("Checkbox", host);
			talent:SetPadding(4, 0, 4, 0);
			talent:SetRelativeWidth(1 / 3);
			talent:SetText(GetTalentInfo((i * 3) + j));
			talent:SetID(bit.bor(baseID, bit.lshift(i, 3), j));
			talent.OnValueUpdated:Connect(SetBitFlag);
			talent:ConnectParameter("Trigger", "Match", GetBitFlag, ...);
			GetBitFlag(talent);
			frame:AddWidget(talent);
		end
		frame:AddRow(4);
	end
end

--- Returns true if the trigger is considered a 'support' trigger and can
--  be shown as an additional trigger option within the simple activation
--  editor.
function Talents:IsSupportTrigger()
	return true;
end

--- Upgrades the trigger from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The trigger parameters to upgrade.
function Talents:Upgrade(version, params)
end