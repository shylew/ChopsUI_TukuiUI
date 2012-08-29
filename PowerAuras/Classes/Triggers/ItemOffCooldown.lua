-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Trigger class definition.
local ItemOffCooldown = PowerAuras:RegisterTriggerClass("ItemOffCooldown", {
	--- Dictionary of default parameters this trigger uses.
	Parameters = {
		Match = "<Item Name or Slot (eg. Slot:Trinket1)>",
	},
	--- Dictionary of events this trigger responds to.
	Events = {
		BAG_UPDATE_COOLDOWN = "ItemOffCooldown",
		GET_ITEM_INFO_RECEIVED = "ItemOffCooldown",
	},
	--- Dictionary of provider services required by this trigger type.
	Services = {
	},
	--- Dictionary of services that this trigger can conver to.
	ServiceMirrors = {
		Timer   = "TriggerData",
		Stacks  = "TriggerData",
		Texture = "TriggerData",
		Text    = "TriggerData",
	},
});

--- Constructs a new instance of the trigger and returns it.
-- @param parameters The parameters to construct the trigger from.
function ItemOffCooldown:New(parameters)
	-- Extract parameters.
	local match     = parameters["Match"];
	-- local ignoreGCD = parameters["IgnoreGCD"];
	-- local ignoreEnd = parameters["IgnoreGCDEnd"];
	-- local usable    = parameters["Usable"];
	-- local known     = parameters["Known"];

	-- -- GCD detection.
	-- local gcdSpell = PowerAuras.GCDSpells[select(2, UnitClass("player"))];
	-- gcdSpell = tonumber(gcdSpell) or tostring(gcdSpell);
	-- local classGCD = 0;

	-- Store the item ID here.
	local itemID = (tonumber(match) or PowerAuras.ItemIDLookup[match] or 0);
	local isSlot, slotID = false, 0;

	-- Is this a slot?
	local temp = match:upper();
	local prefix, id = temp:match("%s*(SLOT)%s*:%s*([a-zA-Z0-9]+)%s*");
	if(prefix == "SLOT") then
		isSlot, slotID = true, _G["INVSLOT_" .. id] or 0;
	end

	-- Generate function.
	return function(self, buffer, action, store)
		-- We need an item ID. Got one?
		if(itemID == 0 and not isSlot) then
			itemID = PowerAuras.ItemIDLookup[match] or 0;
			if(itemID == 0) then
				-- Still failed.
				return false;
			end
		elseif(isSlot and slotID == 0) then
			-- Invalid slot.
			return false;
		end

		-- Check the cooldown.
		local start, duration, state;
		if(not isSlot) then
			start, duration = GetItemCooldown(itemID);
			-- If not on cooldown, we're a hit.
			state = (duration == 0);

			-- Update the store texture too.
			if(not store.Texture or store.Texture == "") then
				store.Texture = GetItemIcon(itemID);
			end
		else
			-- Get the item ID from the slot and check that.
			local oldID = itemID;
			itemID = GetInventoryItemID("player", slotID) or 0;
			if(itemID > 0) then
				start, duration = GetItemCooldown(itemID);
				state = (duration == 0);
			end

			-- Also set the texture in the store if needed.
			if(oldID ~= itemID and itemID > 0) then
				store.Texture = GetItemIcon(itemID);
			elseif(itemID == 0) then
				store.Texture = "";
			end
		end

		-- Sensible defaults in case of a bad situation.
		start, duration = start or 0, duration or 0;

		-- Update the timers and stuff.
		if(not state) then
			store.TimerStart = start;
			store.TimerEnd = (start + duration);
		else
			store.TimerStart = nil;
			store.TimerEnd = nil;
		end

		-- Done.
		return state;
	end;
end

--- Creates the controls for the basic activation editor frame.
-- @param frame The frame to apply controls to.
-- @param ... ID's to use for Get/SetParameter calls.
function ItemOffCooldown:CreateTriggerEditor(frame, ...)
	-- Spell match.
	local match = PowerAuras:Create("P_EditBox", frame);
	match:SetUserTooltip("ItemOffCooldown_Match");
	match:LinkParameter("Trigger", "Match", ...);
	match:SetPadding(4, 0, 2, 0);
	match:SetRelativeWidth(0.5);
	match:SetTitle(L["ItemOffCooldown_Match"]);
	frame:AddWidget(match);
end

--- Initialises the per-trigger data store. This can be used to hold
--  values which can then be exposed to other parts of the system.
-- @param params The parameters of this trigger.
-- @return An item to store, or nil.
function ItemOffCooldown:InitialiseDataStore(params)
	return {
		Texture = "",
		TimerStart = 0,
		TimerEnd = 2^31 - 1,
	};
end

--- Determines whether or not a trigger requires per-frame updates.
-- @param params The parameters of the trigger.
-- @return True if updates are required, false if not.
-- @return The first value is the default timed state on creation. The 
--         second boolean is whether or not the timed status is capable of
--         being toggled by the trigger.
function ItemOffCooldown:IsTimed(params)
	return true, false;
end

--- Upgrades the trigger from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The trigger parameters to upgrade.
function ItemOffCooldown:Upgrade(version, params)
end