-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Trigger class for equipped item detection.
local Equipment = PowerAuras:RegisterTriggerClass("Equipment", {
	Parameters = {
		Type = 1, -- 1 = Equipment, 2 = Equipment Set.
		Set = 0, -- Used if type is 2. Otherwise, see Slots.
		Slots = { -- Allows ID's and string matches. -1 = Ignore, 0 = Nothing.
			["INVSLOT_HEAD"]     = -1,
			["INVSLOT_NECK"]     = -1,
			["INVSLOT_SHOULDER"] = -1,
			["INVSLOT_BODY"]     = -1,
			["INVSLOT_CHEST"]    = -1,
			["INVSLOT_WAIST"]    = -1,
			["INVSLOT_LEGS"]     = -1,
			["INVSLOT_FEET"]     = -1,
			["INVSLOT_WRIST"]    = -1,
			["INVSLOT_HAND"]     = -1,
			["INVSLOT_FINGER1"]  = -1,
			["INVSLOT_FINGER2"]  = -1,
			["INVSLOT_TRINKET1"] = -1,
			["INVSLOT_TRINKET2"] = -1,
			["INVSLOT_BACK"]     = -1,
			["INVSLOT_MAINHAND"] = -1,
			["INVSLOT_OFFHAND"]  = -1,
			["INVSLOT_TABARD"]   = -1,
		},
	},
	Events = {
		GET_ITEM_INFO_RECEIVED = "Equipment", -- May not be needed, test.
		PLAYER_EQUIPMENT_CHANGED = "Equipment",
	},
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
-- @param parameters The parameters to construct the trigger from.
function Equipment:New(parameters)
	-- Generate based upon the type.
	if(parameters["Type"] == 1) then
		-- Slots. Prepare them.
		local slots = {};
		for key, data in pairs(parameters["Slots"]) do
			if(type(data) == "string" or data > -1) then
				local slotID = _G[key];
				slots[slotID] = data;
				-- Is the data a string?
				if(type(data) == "string") then
					-- Split it, or turn it to a number.
					if(tonumber(data)) then
						slots[slotID] = tonumber(data);
					else
						slots[slotID] = { ("/"):split(data) };
						-- Convert string ID's to numbers.
						for i = 1, #(slots[slotID]) do
							if(tonumber(slots[slotID][i])) then
								slots[slotID][i] = tonumber(slots[slotID][i]);
							end
						end
					end
				end
			end
		end
		-- Generate function.
		return function()
			-- Iterate over the slots.
			for slotID, matches in pairs(slots) do
				-- Get the equipped item ID.
				local itemID = GetInventoryItemID("player", slotID);
				itemID = itemID or 0;
				-- Compare with our matches.
				if(type(matches) == "number" and itemID ~= matches) then
					return false;
				elseif(type(matches) == "table") then
					-- Iterate over names/ID's.
					local success = false;
					for i = 1, #(matches) do
						local match = matches[i];
						-- Change behaviour upon match type.
						if(type(match) == "number" and itemID == match) then
							success = true;
							break;
						elseif(type(match) == "string" and itemID > 0) then
							-- Check name.
							local name = GetItemInfo(itemID);
							-- Compare name with match.
							if(name and name:match(match)) then
								-- Matched just fine.
								success = true;
								break;
							end
						end
					end
					-- Succeeded?
					if(not success) then
						return false;
					end
				end
			end
			-- Getting here indicates success.
			return true;
		end;
	else
		-- Set.
		local match = parameters["Set"];
		return function()
			-- Iterate over equipment sets until we find the one with our
			-- stored ID.
			for i = 1, GetNumEquipmentSets() do
				local _, _, id, equipped = GetEquipmentSetInfo(i);
				if(id == match) then
					-- Is it equipped? You decide!
					return equipped;
				end
			end
			-- Fail by default.
			return false;
		end;
	end
end

--- Creates the controls for the basic activation editor frame.
-- @param frame The frame to apply controls to.
-- @param ... ID's to use for Get/SetParameter calls.
function Equipment:CreateTriggerEditor(frame, ...)
end

--- Upgrades the trigger from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The trigger parameters to upgrade.
function Equipment:Upgrade(version, params)
	
end