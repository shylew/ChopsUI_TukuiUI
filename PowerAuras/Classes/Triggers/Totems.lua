-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Totem spell ID's by their slot in the bits.
local TotemBitSlots = {
	-- Shaman totems.
	["SHAMAN"] = {
		[1]  = 120668,
		[2]  = 98008,
		[3]  = 2894,
		[4]  = 108269,
		[5]  = 2062,
		[6]  = 16190,
		[7]  = 8143,
		[8]  = 8177,
		[9]  = 8190,
		[10] = 5394,
		[11] = 2484,
		[12] = 3599,
		[13] = 51485,
		[14] = 108280,
		[15] = 108273,
		[16] = 108270,
	},
	["PALADIN"] = {
	},
	["DEATHKNIGHT"] = {
	},
	["DRUID"] = {
		[1] = 88747,
		[2] = 88747,
		[3] = 88747,
	},
	["MONK"] = {
	},
	["MAGE"] = {
	},
};

--- Copy of the above table, but mapping ID's to slots.
local ReverseTotemBits = {};
for class, totems in pairs(TotemBitSlots) do
	-- Create reverse table.
	local new = {};
	for slot, id in pairs(totems) do
		new[id] = bit.bor(new[id] or 0, 2^(slot - 1));
	end
	-- Store.
	ReverseTotemBits[class] = new;
end

--- Table for the UI. Categorises totems by their ingame slot.
local TotemsByUISlot = {
	["SHAMAN"] = {
		[1] = { -- Fire totems.
			[1] = 3,
			[2] = 9,
			[3] = 12,
		},
		[2] = { -- Earth totems.
			[1] = 5,
			[2] = 7,
			[3] = 11,
			[4] = 13,
			[5] = 16,
		},
		[3] = { -- Water totems.
			[1] = 6,
			[2] = 10,
			[3] = 14,
		},
		[4] = { -- Air totems.
			[1] = 1,
			[2] = 2,
			[3] = 4,
			[4] = 8,
			[5] = 15,
		},
		-- [5] = { -- Heart totems.
		-- },
	},
	["PALADIN"] = {
	},
	["DEATHKNIGHT"] = {
	},
	["DRUID"] = {
		[1] = {
			[1] = 1,
		},
		[2] = {
			[1] = 2,
		},
		[3] = {
			[1] = 3,
		},
	},
	["MONK"] = {
	},
	["MAGE"] = {
	},
};

-- Sort the class totems out.
for class, slots in pairs(TotemsByUISlot) do
	for _, indexes in pairs(slots) do
		table.sort(indexes, function(a, b)
			local name1 = GetSpellInfo(TotemBitSlots[class][a]);
			local name2 = GetSpellInfo(TotemBitSlots[class][b]);
			if(name1 and name2) then
				return name1 < name2;
			elseif(name1 and not name2) then
				return true;
			else
				return false;
			end
		end);
	end
end


--- Trigger class definition.
local Totems = PowerAuras:RegisterTriggerClass("Totems", {
	--- Dictionary of default parameters this trigger uses.
	Parameters = {
		-- Slots are numbered.
		[1] = 0x00000000,
		[2] = 0x00000000,
		[3] = 0x00000000,
		[4] = 0x00000000,
	},
	--- Dictionary of events this trigger responds to.
	Events = {
		PLAYER_TOTEM_UPDATE = "Totems",
		UPDATE_SHAPESHIFT_FORM = "Totems", -- Blizzard handles this for
		                                   -- positioning, but it's included
		                                   -- just in case.
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
function Totems:New(params)
	-- Extract the parameters. Just do a raw copy and save us some work.
	local matches = PowerAuras:CopyTable(params);
	local _, class = UnitClass("player");

	-- Generate the function.
	return function(self, buffer, action, store)
		-- Keep track of the one with the shortest duration.
		local earliest, time = 0, math.huge;

		-- Process the totems.
		for i = 1, MAX_TOTEMS do
			local match = matches[i];
			-- Handle special matches.
			if(match == 0x80000000 or match == 0x00000000) then
				-- Must have any totem in this slot.
				local state, _, start, duration = GetTotemInfo(i);
				if(not state and match ~= 0x00000000) then
					return false;
				elseif(state) then
					-- Will it finish sooner?
					if((start + duration) < time) then
						earliest = i;
						time = (start + duration);
					end
				end
			elseif(match == 0x40000000) then
				-- Must not have a totem in this slot.
				local state = GetTotemInfo(i);
				if(state) then
					return false;
				end
			else
				-- Handle normal matches.
				local state, name, start, duration, icon = GetTotemInfo(i);
				if(not state) then
					-- No totem in this slot. Expected one.
					return false;
				end

				-- Get the spell ID if possible.
				local id = PowerAuras.SpellIDLookup[name];
				if(id == 0) then
					-- Manual scanning, this will be slow.
					for j = 1, #(TotemBitSlots[class]) do
						local slotID = TotemBitSlots[class][j];
						-- Name check.
						local slotName = GetSpellInfo(slotID);
						if(slotName == name) then
							-- Match.
							id = slotID;
							break;
						end
					end
					-- Cache it manually.
					PowerAuras.SpellIDLookup[name] = id;
				end

				-- Got an ID now?
				if(id > 0) then
					-- Right, are we matching this totem?
					local offset = ReverseTotemBits[class][id] or 0;
					-- 2^0 = 0.5, which will never match anything.
					if(bit.band(match, offset) == 0) then
						-- We didn't hit a totem, and we required one.
						return false;
					else
						-- Will it finish sooner?
						if((start + duration) < time) then
							earliest = i;
							time = (start + duration);
						end
					end
				else
					-- Failed to figure out what the hell totem this is.
					return false;
				end
			end
		end

		-- Congratulations, totems. Update source data.
		if(earliest > 0) then
			local _, name, start, duration, icon = GetTotemInfo(earliest);
			store.Text["name"] = name;
			store.Texture      = icon;
			store.TimerStart   = start;
			store.TimerEnd     = (start + duration);
		else
			store.Text["name"] = "";
			store.Texture      = nil;
			store.TimerStart   = nil;
			store.TimerEnd     = nil;
		end
		return true;
	end;
end

--- Updates the match data for a totem slot.
-- @param frame The frame that was updated.
-- @param ...   Arguments from the update callbacks.
local function UpdateTotemSlot(frame, ...)
	-- Determine what we're updating.
	local _, aID, f1, tID, f2, slotID = PowerAuras:SplitNodeID(frame:GetID());
	if(f1 == 0 and f2 == 0) then
		-- Totem dropdown.
		local key = ...;
		-- XOR the existing flags and update.
		local match = PowerAuras:GetParameter("Trigger", slotID, aID, tID);
		if(key > 0) then
			match = bit.bxor(match, 2^(key - 1));
			match = bit.band(match, 0x0FFFFFFF);
		else
			-- Special key.
			if(key == -1) then
				match = 0x00000000;
			elseif(key == -2) then
				match = 0x80000000;
			elseif(key == -3) then
				match = 0x40000000;
			end
		end
		PowerAuras:SetParameter("Trigger", slotID, match, aID, tID);
	end
end

--- Updates a UI frame with information about a totem slot.
-- @param frame The frame to update.
-- @param slot  The slot index.
local function UpdateSlotUI(frame, slot)
	-- Determine what we're updating.
	local _, aID, f1, tID, f2, slotID = PowerAuras:SplitNodeID(frame:GetID());
	if(f1 == 0 and f2 == 0) then
		-- Totem dropdown.
		for i = 1, #(frame.ItemsByKey["__ROOT__"]) do
			local item = frame.ItemsByKey["__ROOT__"][i];
			local key = item.Key;
			local checked = (bit.band(slot, 2^(key - 1)) > 0);
			frame:SetItemChecked(key, checked);
			if(checked) then
				frame:SetRawText(L["Multiple"]);
			end
			-- Is this a negative (special) key?
			if(key < 0) then
				if(key == -1 and slot == 0x00000000) then
					frame:SetItemChecked(key, true);
					frame:SetText(key);
				elseif(key == -2 and slot == 0x80000000) then
					frame:SetItemChecked(key, true);
					frame:SetText(key);
				elseif(key == -3 and slot == 0x40000000) then
					frame:SetItemChecked(key, true);
					frame:SetText(key);
				end
			end
		end
	end
end

--- Creates the controls for the basic activation editor frame.
-- @param frame The frame to apply controls to.
-- @param ... ID's to use for Get/SetParameter calls.
function Totems:CreateTriggerEditor(frame, ...)
	-- Does this class have totems or not?
	local _, class = UnitClass("player");
	local slots = TotemsByUISlot[class];
	if(not slots or #(slots) == 0) then
		-- Just add a label.
		local l = PowerAuras:Create("Label", frame);
		l:SetText(L["ClassNoTotems"]);
		l:SetRelativeWidth(1.0);
		l:SetHeight(36);
		l:SetJustifyH("CENTER");
		l:SetJustifyV("MIDDLE");
		frame:AddWidget(l);
		return;
	end

	-- Get the parameter ID's.
	local aID, tID = ...;

	-- Add editor controls for each row.
	for i = 1, MAX_TOTEMS do
		-- Add a dropdown for this slot.
		local totems = PowerAuras:Create("SimpleDropdown", frame);
		local isEven = ((i % 2) == 0);
		totems:SetUserTooltip("Totems_Totem");
		totems:SetPadding((isEven and 2 or 4), 0, (isEven and 4 or 2), 0);
		totems:SetRelativeWidth(0.5);
		totems:SetID(PowerAuras:GetNodeID(nil, aID, 0, tID, 0, i));
		totems:SetTitle(L("SlotID", i));
		-- Add the totems for this class.
		local added = false;
		if(slots[i]) then
			added = true;
			-- Add the special options.
			totems:AddCheckItem(-1, L["AnyNone"]);
			totems:AddCheckItem(-2, L["Any"]);
			totems:AddCheckItem(-3, L["None"]);

			-- Add totems for this class.
			local indexes = slots[i];
			for _, index in ipairs(indexes) do
				local name = GetSpellInfo(TotemBitSlots[class][index]);
				totems:AddCheckItem(index, tostring(name), nil, true);
			end
		end
		-- Did we add totems?
		if(added) then
			-- Callbacks, add widget to frame.
			totems.OnValueUpdated:Connect(UpdateTotemSlot);
			totems:ConnectParameter("Trigger", i, UpdateSlotUI, ...);
			UpdateSlotUI(totems, PowerAuras:GetParameter("Trigger", i, ...));
			frame:AddWidget(totems);
			-- Add separation row.
			if(isEven) then
				frame:AddRow(4);
			end
		else
			totems:Recycle();
			break;
		end
	end
end

--- Initialises the per-trigger data store. This can be used to hold
--  values which can then be exposed to other parts of the system.
-- @param params The parameters of this trigger.
-- @return An item to store, or nil.
function Totems:InitialiseDataStore()
	return {
		TimerStart = 0,
		TimerEnd = 2^31 - 1,
		Texture = PowerAuras.DefaultIcon,
		Text = {
			["name"] = "",
		},
	};
end

--- Upgrades the trigger from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The trigger parameters to upgrade.
function Totems:Upgrade(version, params)
end