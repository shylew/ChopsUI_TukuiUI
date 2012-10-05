-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

-- Load modules.
local Coroutines = PowerAuras:GetModules("Coroutines");

--- Editor metadata module. Manages the data attached to each resource item.
local Metadata = PowerAuras:RegisterModule("Metadata");

--- Flags for the sources system.
Metadata.DISPLAY_SOURCEMASK     = 0x00000007;
Metadata.DISPLAY_SOURCE_AUTO    = 0x00000001; -- Automatic source config.
Metadata.DISPLAY_SOURCE_MANUAL  = 0x00000002; -- Manual source configuration.
Metadata.DISPLAY_SOURCE_TRIGGER = 0x00000004; -- Semi-automatic source config.

--- Flags for linked displays.
Metadata.DISPLAY_LINKMASK = 0x00000008;
Metadata.DISPLAY_LINK     = 0x00000008; -- Tie activation to parent.

--- Flags for inverted linked displays.
Metadata.DISPLAY_INVMASK    = 0x00000010;
Metadata.DISPLAY_INV_INVERT = 0x00000010;

-- More source flags. These ones are for determining what optional services
-- are enabled.
Metadata.DISPLAY_OPTMASK     = 0x000000F0;
Metadata.DISPLAY_OPT_STACKS  = 0x00000010;
Metadata.DISPLAY_OPT_TEXT    = 0x00000020;
Metadata.DISPLAY_OPT_TEXTURE = 0x00000040;
Metadata.DISPLAY_OPT_TIMER   = 0x00000080;

--- Unused bits/masks.
Metadata.DISPLAY_UNUSEDMASK = 0x0003FF00;

-- Trigger source config flags.
Metadata.TRIGGER_SOURCEMASK      = 0x0000000F;
Metadata.TRIGGER_SOURCE_AUTO     = 0x00000001; -- Main trigger on action.
Metadata.TRIGGER_SOURCE_MANUAL   = 0x00000002; -- Manual source configuration.
Metadata.TRIGGER_SOURCE_TRIGGER  = 0x00000004; -- Configures from a trigger.
Metadata.TRIGGER_SOURCE_AUTODISP = 0x00000008; -- Uses the Display.

--- Unused bits/masks.
Metadata.TRIGGER_UNUSEDMASK = 0x0003FFF0;

-- Data ID's are compacted into the flags field.
Metadata.ID_DISPLAYMASK  = 0xFE000000; -- Linked display ID.
Metadata.ID_DISPLAYSHIFT = 25;
Metadata.ID_TRIGGERMASK  = 0x01F80000; -- Activation action assumed.
Metadata.ID_TRIGGERSHIFT = 19;
Metadata.ID_FLAGMASK     = 0x00040000; -- This is a general purpose flag.
Metadata.ID_FLAGSHIFT    = 18;

-- Function upvalues.
local ConfigureSourceForDisplay;

--- Reconfigures the activation criteria of a display to match the one that
--  it links to.
local function ConfigureActivationForDisplay(id)
	-- Verify that the display exists.
	if(not PowerAuras:HasAuraDisplay(id)) then
		return;
	end

	-- Get linked display, check for existance.
	local vars = PowerAuras:GetAuraDisplay(id);
	local auraID = PowerAuras:SplitAuraDisplayID(id);
	local lID = Metadata:GetFlagID(vars["Flags"], "Display");
	lID = PowerAuras:GetAuraDisplayID(auraID, lID);
	
	-- Does it exist?
	if(not PowerAuras:HasAuraDisplay(lID)) then
		return;
	end

	-- Get parent information.
	local lVars = PowerAuras:GetAuraDisplay(lID);
	local lAID = lVars.Actions["DisplayActivate"];
	local lAVars = PowerAuras:GetAuraAction(lAID);

	-- Get our own information.
	local aID = vars.Actions["DisplayActivate"];
	local aVars = PowerAuras:GetAuraAction(aID);

	-- Sort out the sequences.
	for i = 1, math.max(#(aVars.Sequences), #(lAVars.Sequences)) do
		-- Get them.
		local seq = aVars.Sequences[i];
		local lSeq = lAVars.Sequences[i];
		-- Check for wrong counts.
		local conf = false;
		if(not seq or not lSeq) then
			if(not seq) then
				-- We don't have this sequence :(
				PowerAuras:CreateAuraActionSequence(aID, i);
				conf = true;
			elseif(not lSeq) then
				-- The #(aVars.Sequences) is too damn high!
				PowerAuras:DeleteAuraActionSequence(aID, i);
			end
		else
			conf = true;
		end

		-- Configure it?
		local seq = aVars.Sequences[i];
		if(seq and conf) then
			-- Start with operators. Invert if needed.
			if(bit.band(vars.Flags, Metadata.DISPLAY_INVMASK) > 0) then
				seq.Operators = ("!(%s)"):format(lSeq.Operators);
			else
				seq.Operators = lSeq.Operators;
			end

			-- Now parameters.
			wipe(seq.Parameters);
			for k, v in ipairs(lSeq.Parameters) do
				seq.Parameters[k] = v;
			end
		end
	end

	-- Run over the triggers on our action.
	for i = 1, math.max(#(aVars.Triggers), #(lAVars.Triggers)) do
		-- Get triggers.
		local tri = aVars.Triggers[i];
		local lTri = lAVars.Triggers[i];
		-- Does one exist without the other?
		local conf = false;
		if(not tri or not lTri) then
			if(not tri) then
				-- We don't have this trigger (!).
				PowerAuras:CreateAuraActionTrigger(aID, lTri["Type"], i);
				conf = true;
			elseif(not lTri) then
				-- They don't have this trigger.
				PowerAuras:DeleteAuraActionTrigger(aID, i);
			end
		elseif(tri.Type ~= lTri.Type) then
			-- We both have a trigger, but the types are wrong.
			PowerAuras:CreateAuraActionTrigger(aID, lTri["Type"], i);
			conf = true;
		else
			conf = true;
		end

		-- Right, do we need to configure the trigger now?
		local tri = aVars.Triggers[i];
		if(tri and conf) then
			wipe(tri.Parameters);
			for k, v in pairs(lTri.Parameters) do
				tri.Parameters[k] = v;
			end
		end
	end

	-- Now reconfigure our source.
	ConfigureSourceForDisplay(id);
end

--- Automatically configures a provider for a display.
-- @param id The ID of the display.
function ConfigureSourceForDisplay(id)
	-- Verify that the display exists.
	if(not PowerAuras:HasAuraDisplay(id)) then
		PowerAuras:PrintDebug(
			"ConfigureSourceForDisplay fail: %d not found.", id
		);
		return;
	end

	-- Get basic display information.
	local vars = PowerAuras:GetAuraDisplay(id);
	local class = PowerAuras:GetDisplayClass(vars["Type"]);
	local aID = vars.Actions["DisplayActivate"];
	local aVars = PowerAuras:GetAuraAction(aID);
	local sFlags = bit.band(vars.Flags, Metadata.DISPLAY_SOURCEMASK);

	-- Does this display even NEED a provider?
	if(not next(class:GetAllServices())) then
		-- Does it have one?
		if(vars["Provider"]) then
			vars["Provider"] = nil;
			Coroutines:Queue(PowerAuras:DeleteUnusedResources());
		end
		-- Done then.
		return;
	end

	-- Ensure the provider exists.
	local pID = vars["Provider"];
	if(not PowerAuras:HasAuraProvider(vars.Provider)) then
		-- Create or fail.
		local auraID = PowerAuras:SplitAuraDisplayID(id);
		pID = PowerAuras:CreateAuraProvider(auraID);
		if(not pID) then
			-- Failed to configure source.
			error(("Cannot create source for display: %d"):format(id));
		else
			vars["Provider"] = pID;
		end
	end
	-- Get the provider.
	local pVars = PowerAuras:GetAuraProvider(pID);

	-- HACK: Keep the texture parameter of TriggerData services around.
	local pRestore = (pVars.Texture and pVars.Texture.Type == "TriggerData"
		and pVars.Texture.Parameters["Texture"]);

	-- Now, reset the provider.
	local services = class:GetAllServices();
	local int, svc = next(pVars);
	while(int) do
		if(services[int] == nil) then
			pVars[int] = nil;
		else
			svc.Type = nil;
			wipe(svc.Parameters);
		end
		int, svc = next(pVars, int);
	end

	-- Create needed services.
	for int, req in pairs(services) do
		if(not pVars[int]) then
			pVars[int] = { Parameters = {} };
		end
	end

	-- Get our metadata flags.
	local optFlags = bit.band(vars["Flags"], Metadata.DISPLAY_OPTMASK);

	-- What type of configuration are we doing?
	local configured = false;
	-- Iterate over the triggers on the activate action.
	for i = 1, #(aVars["Triggers"]) do
		-- Right, can this trigger be configured into our
		-- required services?
		local tri = aVars["Triggers"][i];
		local tParams = tri["Parameters"];
		local tClass = PowerAuras:GetTriggerClass(tri["Type"]);
		local invalidTrigger = false;

		for int, req in pairs(services) do
			local sName = tClass:SupportsServiceConversion(int);
			if(not sName and req) then
				-- Can't make this service.
				invalidTrigger = true;
				break;
			end
		end

		-- Full match?
		if(not invalidTrigger) then
			-- Set up the interfaces.
			for int, req in pairs(services) do
				-- Is this required or optional? If optional, only include
				-- if configured to.
				local optFlag = Metadata["DISPLAY_OPT_" .. int:upper()];
				local sName = tClass:SupportsServiceConversion(int);
				if((req or bit.band(optFlags, optFlag) > 0) and sName) then
					-- Set up the service.
					pVars[int].Type = sName;
					-- Now tell the trigger class to configure it.
					local pParams = pVars[int]["Parameters"];
					wipe(pParams);
					tClass:ConvertToService(int, tParams, pParams, aID, i);
				end
				-- In addition, if required, update the flags.
				if(req) then
					vars["Flags"] = bit.bor(vars["Flags"], optFlag);
				end
			end
			-- Done.
			configured = true;
			-- Store the used trigger index.
			local flags = Metadata:SetFlagID(vars["Flags"], i, "Trigger");
			vars["Flags"] = flags;
			break;
		end
	end

	-- Kill uninitialised interfaces.
	local int, svc = next(pVars);
	while(int) do
		if(not svc.Type) then
			pVars[int] = nil;
		end
		int, svc = next(pVars, int);
	end

	-- HACK: Restore texture if applicable.
	if(pRestore and pVars.Texture and pVars.Texture.Type == "TriggerData") then
		pVars.Texture.Parameters["Texture"] = pRestore;
	end

	-- Did we succeed or fail?
	if(not configured) then
		-- Failed. Tell the user, but don't reset it.
		PowerAuras:PrintInfo(L("SourceAutoConfFail", id));
	end
end

--- Configures the source for a trigger automagically.
-- @param aID The action ID of the trigger.
-- @param tID The trigger index.
-- @param dID Optional display ID to use for configuring.
local function ConfigureSourceForTrigger(aID, tID, dID)
	-- Verify the action exists.
	if(not PowerAuras:HasAuraAction(aID)) then
		return;
	end

	-- Verify the trigger exists.
	local action = PowerAuras:GetAuraAction(aID);
	if(not action.Triggers[tID]) then
		return;
	end

	-- Get trigger data and flags.
	local tri = action.Triggers[tID];
	local tCls = PowerAuras:GetTriggerClass(tri.Type);
	local reqServices = tCls:GetRequiredServices();
	local flags = tri.Flags;
	local sFlags = bit.band(flags, Metadata.TRIGGER_SOURCEMASK);

	-- Ensure the provider exists.
	if(not PowerAuras:HasAuraProvider(tri.Provider)) then
		-- Right well hang on, does it even NEED one?
		if((sFlags == Metadata.TRIGGER_SOURCE_AUTODISP
			or sFlags == Metadata.TRIGGER_SOURCE_AUTO)
			and not next(reqServices)) then
			-- It doesn't!
			return;
		end

		-- Create one.
		local auraID = PowerAuras:SplitAuraActionID(aID);
		local id = PowerAuras:CreateAuraProvider(auraID);
		if(not id) then
			error("Failed to create source.");
		else
			tri.Provider = id;
		end
	end

	-- Reset the source.
	local prov = PowerAuras:GetAuraProvider(tri.Provider);
	local int, data = next(prov);
	while(int) do
		-- Outright delete, or just recycle?
		if(not reqServices[int]) then
			prov[int] = nil;
		else
			data.Type = nil;
			wipe(data.Parameters);
		end
		int, data = next(prov, int);
	end

	-- Ensure required services exist.
	for int in pairs(reqServices) do
		if(not prov[int]) then
			prov[int] = { Parameters = {} };
		end
	end

	-- So what configuration mode?
	local configured = false;
	-- Use the main trigger of the activate action of the owning display.
	if(PowerAuras:HasAuraDisplay(dID)) then
		-- Get the main trigger on this display.
		local disp = PowerAuras:GetAuraDisplay(dID);
		local mAID = disp.Actions["DisplayActivate"];
		local mAct = PowerAuras:GetAuraAction(mAID);
		for mTID, mTri in ipairs(mAct.Triggers) do
			-- Is this a main trigger?
			local mCls = PowerAuras:GetTriggerClass(mTri.Type);
			if(not mCls:IsSupportTrigger()) then
				-- Does it support converting to all our services?
				local supported = true;
				for int, _ in pairs(prov) do
					if(not mCls:SupportsServiceConversion(int)) then
						supported = false;
						break;
					end
				end

				-- So will it work?
				if(supported) then
					-- We're done then.
					for int, svc in pairs(prov) do
						-- Convert.
						mCls:ConvertToService(
							int, mTri.Parameters, svc.Parameters, mAID, mTID
						);

						-- Store type.
						svc.Type = mCls:SupportsServiceConversion(int);
					end
					configured = true;
					break;
				end
			end
		end
	end

	-- Did it get configured?
	if(not configured and next(reqServices)) then
		PowerAuras:PrintError(
			L("TSourceAutoConfFail", L["TSourceAutoConfFailNoMain"])
		);
	elseif(not configured and not next(reqServices)) then
		-- Just delete the provider.
		PowerAuras:DeleteAuraProvider(tri.Provider);
		tri.Provider = nil;
	end
end

--- Updates all displays that are linked to the passed one.
-- @param id The ID of the display to update.
local function ReconfigureLinkedDisplays(id)
	-- Bail early if the display no longer exists.
	if(not PowerAuras:HasAuraDisplay(id)) then
		PowerAuras:PrintDebug("UpdateLinkedDisplays fail: %d not found.", id);
		return;
	end

	-- Split the ID up and get the aura.
	local vars = PowerAuras:GetAuraDisplay(id);
	local aID, dID = PowerAuras:SplitAuraDisplayID(id);
	local aura = PowerAuras:GetAura(aID);

	-- Iterate over the displays and find ones which link to ours.
	for i = 1, #(aura.Displays) do
		local vars = aura.Displays[i];
		local lID = Metadata:GetFlagID(vars["Flags"], "Display");
		if(bit.band(vars["Flags"], Metadata.DISPLAY_LINK) > 0) then
			-- Reconfigure.
			ConfigureActivationForDisplay(PowerAuras:GetAuraDisplayID(aID, i));
		end
	end
end

--- Reconfigures the sources on displays from an event.
-- @param event The fired event.
-- @param aID   The action index from the event.
-- @param tID   The trigger index from the event.
local function ReconfigureDisplaySources(event, aID, tID)
	-- Iterate over all displays on the aura and reconfigure.
	local auraID = PowerAuras:SplitAuraActionID(aID);
	local aura = PowerAuras:GetAura(auraID);
	for i, disp in ipairs(aura.Displays) do
		-- Get the flags and links from this displays.
		local flags = disp.Flags;
		local sFlags = bit.band(flags, Metadata.DISPLAY_SOURCEMASK);
		local lTri = Metadata:GetFlagID(flags, "Trigger");
		local id = PowerAuras:GetAuraDisplayID(auraID, i);
		local activeID = disp.Actions["DisplayActivate"];

		-- Ignore the linked ID if manually configured.
		if(sFlags == Metadata.DISPLAY_SOURCE_MANUAL) then
			lTri = 0;
			disp.Flags = Metadata:SetFlagID(flags, 0, "Trigger");
		end

		-- Was this a deletion event on the action?
		if(event == "TRIGGER_DELETED" and aID == activeID) then
			-- Adjust the linked index.
			if(tID == lTri) then
				-- Deleted, handle based upon the type.
				if(sFlags == Metadata.DISPLAY_SOURCE_AUTO) then
					-- Safe to just reconfigure, it'll work fine.
					Coroutines:Deferred(ConfigureSourceForDisplay, id);
				elseif(sFlags == Metadata.DISPLAY_SOURCE_TRIGGER) then
					-- Linked trigger is gone, notify the user.
					-- TODO: Notify.
					disp.Flags = Metadata:SetFlagID(flags, 0, "Trigger");
					Coroutines:Deferred(ConfigureSourceForDisplay, id);
				end
			elseif(tID < lTri) then
				-- Adjust index.
				disp.Flags = Metadata:SetFlagID(flags, lTri - 1, "Trigger");
				Coroutines:Deferred(ConfigureSourceForDisplay, id);
			end
		elseif(aID == activeID and tID == lTri
			or aID == activeID and sFlags == Metadata.DISPLAY_SOURCE_AUTO) then
			-- Just reconfigure.
			Coroutines:Deferred(ConfigureSourceForDisplay, id);
		end

		-- Are we updating the linked displays system?
		if(aID == activeID) then
			Coroutines:Deferred(ReconfigureLinkedDisplays, id);
			break;
		end
	end
end

--- Reconfigures the sources on triggers from an event.
-- @param event The fired event.
-- @param aID   The action index from the event.
-- @param tID   The trigger index from the event.
local function ReconfigureTriggerSources(event, aID, tID)
	-- Iterate o'er the actions and triggARR!s.
	local auraID = PowerAuras:SplitAuraActionID(aID);
	local aura = PowerAuras:GetAura(auraID);
	local act = PowerAuras:GetAuraAction(aID);
	for i, tri in ipairs(act.Triggers) do
		-- Get the flags and links from this trigger.
		local flags = tri.Flags;
		local sFlags = bit.band(flags, Metadata.TRIGGER_SOURCEMASK);
		local lTri = Metadata:GetFlagID(flags, "Trigger");

		-- Ignore the linked ID if manually configured.
		if(sFlags == Metadata.TRIGGER_SOURCE_MANUAL) then
			lTri = 0;
			tri.Flags = Metadata:SetFlagID(flags, 0, "Trigger");
		end

		-- Are we processing a delete event?
		if(event == "TRIGGER_DELETED") then
			-- Adjust the linked index, as we're on the same action.
			if(tID == lTri) then
				-- Deleted, handle based upon the type.
				if(sFlags == Metadata.TRIGGER_SOURCE_AUTO) then
					-- Safe to just reconfigure, it'll work fine.
					Coroutines:Deferred(ConfigureSourceForTrigger, aID, i);
				elseif(sFlags == Metadata.TRIGGER_SOURCE_TRIGGER) then
					-- Linked trigger is gone, notify the user.
					-- TODO: Notify.
					tri.Flags = Metadata:SetFlagID(flags, 0, "Trigger");
					Coroutines:Deferred(ConfigureSourceForTrigger, aID, i);
				end
			elseif(tID < lTri) then
				-- Adjust index.
				tri.Flags = Metadata:SetFlagID(flags, lTri - 1, "Trigger");
				Coroutines:Deferred(ConfigureSourceForTrigger, aID, i);
			end
		elseif(tID == lTri or sFlags == Metadata.TRIGGER_SOURCE_AUTO) then
			-- Otherwise, just reconfigure.
			Coroutines:Deferred(ConfigureSourceForTrigger, aID, i);
		end
	end

	-- In addition, does the action target a display?
	local cls = PowerAuras:GetActionClass(act.Type);
	if(cls:GetTarget() == "Display" or cls:GetTarget() == "Animation") then
		-- Get the display that this action is linked to.
		local index;
		for i, disp in ipairs(aura.Displays) do
			-- Check actions.
			for act, id in pairs(disp.Actions) do
				if(id == aID) then
					-- Found it.
					index = i;
					break;
				end
			end

			-- Try animations.
			if(not index) then
				for _, ctype in PowerAuras:IterList("Single", "Repeat") do
					for _, chan in ipairs(disp.Animations.Triggered[ctype]) do
						if(chan.Action == aID) then
							index = i;
							break;
						end
					end

					if(index) then
						break;
					end
				end
			end

			-- How about now?
			if(index) then
				break;
			end
		end

		-- Are we processing updates then?
		if(index) then
			local disp = aura.Displays[index];
			local dID = PowerAuras:GetAuraDisplayID(auraID, index);
			-- Process the triggers on the main actions.
			for _, id in pairs(disp.Actions) do
				local act = PowerAuras:GetAuraAction(id);
				for i, tri in ipairs(act.Triggers) do
					-- How is this one linked?
					local fl = tri.Flags;
					local sF = bit.band(fl, Metadata.TRIGGER_SOURCEMASK);
					if(sF == Metadata.TRIGGER_SOURCE_AUTODISP) then
						-- Reconfigure it.
						Coroutines:Deferred(
							ConfigureSourceForTrigger, id, i, dID
						);
					end
				end
			end

			-- Repeat for animation actions.
			for _, ctype in PowerAuras:IterList("Single", "Repeat") do
				for _, chan in ipairs(disp.Animations.Triggered[ctype]) do
					local id = chan.Action;
					local act = PowerAuras:GetAuraAction(id);
					for i, tri in ipairs(act.Triggers) do
						-- How is this one linked?
						local fl = tri.Flags;
						local sF = bit.band(fl, Metadata.TRIGGER_SOURCEMASK);
						if(sF == Metadata.TRIGGER_SOURCE_AUTODISP) then
							-- Reconfigure it.
							Coroutines:Deferred(
								ConfigureSourceForTrigger, id, i, dID
							);
						end
					end
				end
			end
		end
	end
end

--- Extracts ID information from a set of flags.
-- @param flags  The flags to extract from.
-- @param idType The type of ID to extract.
function Metadata:GetFlagID(flags, idType)
	-- Get the mask/shift values.
	idType = tostring(idType);
	local mask = self["ID_" .. idType:upper() .. "MASK"];
	local shift = self["ID_" .. idType:upper() .. "SHIFT"];
	assert(mask and shift, "Invalid ID type specified.");
	assert(type(flags) == "number", "Invalid flags specified.");

	-- Extractimos!
	return bit.rshift(bit.band(flags, mask), shift);
end

do
	--- Sets flag data and returns the modified flags.
	-- @param flags The flags to operate on.
	-- @param type  The type of flags to set.
	-- @param value The values to set.
	-- @param ...   The mask types of the values.	
	local function WriteFlags(flags, type, value, ...)
		-- Reset types.
		type = type:upper();
		if(select("#", ...) == 0) then
			-- No types means reset the entire set of flags.
			flags = 0;
		else
			for i = 1, select("#", ...) do
				local key = (type .. "_" .. select(i, ...):upper() .. "MASK");
				flags = bit.band(flags, bit.bnot(Metadata[key]));
			end
		end
		return bit.bor(flags, value);
	end

	--- Sets the metadata flags for a specific display. Existing flags of the
	--  specified types are cleared.
	-- @param id    The ID of the display.
	-- @param value The flag to set.
	-- @param ...   The type of flags to set.
	function Metadata:SetDisplayFlags(id, value, ...)
		-- Verify display exists.
		if(not PowerAuras:HasAuraDisplay(id)) then
			return;
		end
		-- Get the flags.
		local vars = PowerAuras:GetAuraDisplay(id);
		-- Now set the flags.
		vars["Flags"] = WriteFlags(vars["Flags"], "Display", value, ...);
		PowerAuras.OnOptionsEvent(
			"DISPLAY_METADATA_CHANGED", id, vars["Flags"]
		);
		return vars["Flags"];
	end


	--- Sets the metadata flags for a specific trigger. Existing flags of the
	--  specified types are cleared.
	-- @param id    The ID of the action.
	-- @param index The index of the trigger.
	-- @param value The flag to set.
	-- @param ...   The type of flags to set.
	function Metadata:SetTriggerFlags(id, index, value, ...)
		-- Verify action/trigger exist.
		if(not PowerAuras:HasAuraAction(id)) then
			return;
		end
		local action = PowerAuras:GetAuraAction(id);
		if(not action.Triggers[index]) then
			return;
		end

		-- Update flags.
		local tri = action.Triggers[index];
		tri["Flags"] = WriteFlags(tri["Flags"], "Trigger", value, ...);
		PowerAuras.OnOptionsEvent(
			"TRIGGER_METADATA_CHANGED", id, index, tri["Flags"]
		);
		return tri["Flags"];
	end
end

--- Stores ID information in a set of flags.
-- @param flags  The flags to alter.
-- @param id     The ID to store.
-- @param idType The type of ID to store.
function Metadata:SetFlagID(flags, id, idType)
	-- Get the mask/shift values.
	idType = tostring(idType);
	local mask = self["ID_" .. idType:upper() .. "MASK"];
	local shift = self["ID_" .. idType:upper() .. "SHIFT"];
	assert(mask and shift, "Invalid ID type specified.");
	assert(type(flags) == "number", "Invalid flags specified.");

	-- Clear existing flags.
	flags = bit.band(flags, bit.bnot(mask));
	-- Set new ones.
	flags = bit.bor(flags, bit.band(bit.lshift(id, shift), mask));
	return flags;
end

--- Listen to OnOptionsEvent for all the juicy gossip.
PowerAuras.OnOptionsEvent:Connect(function(event, ...)
	-- Handle events.
	if(event == "TRIGGER_CREATED" or event == "TRIGGER_DELETED") then
		-- Unpack event arguments.
		local aID, tID = ...;
		if(event == "TRIGGER_CREATED") then
			tID = select(3, ...);
		end

		-- Reconfigure sources.
		ReconfigureDisplaySources(event, aID, tID);
		ReconfigureTriggerSources(event, aID, tID);
	elseif(event == "DISPLAY_METADATA_CHANGED") then
		-- Reconfigure source if needed.
		ReconfigureDisplaySources(event, ...);
	elseif(event == "TRIGGER_METADATA_CHANGED") then
		-- Reconfigure source if needed.
		ReconfigureTriggerSources(event, ...);
	elseif(event == "DISPLAY_ACTION_LINK_CREATED") then
		-- Filter by action type.
		local dID, aID, aType = ...;
		if(aType == "DisplayActivate") then
			-- Reconfigure.
			ReconfigureDisplaySources(event, aID);
		end
	end
end);

--- Listen to OnParameterChanged for the not-so-juicy gossip.
PowerAuras.OnParameterChanged:Connect(function(_, t, _, aID, tID)
	-- Filter by type.
	if(t ~= "Trigger" and t ~= "Sequence" and t ~= "SequenceOp") then
		return;
	end

	-- Iterate over the displays and reconfigure their sources.
	local auraID = PowerAuras:SplitAuraActionID(aID);
	local aura = PowerAuras:GetAura(auraID);
	for i, vars in ipairs(aura.Displays) do
		-- Reconfigure when we find the correct action.
		if(vars.Actions["DisplayActivate"] == aID) then
			ReconfigureDisplaySources("PARAMETER_CHANGED", aID, tID);
			break;
		end
	end

	-- Sequences don't affect trigger sources.
	if(t == "Trigger") then
		ReconfigureTriggerSources("PARAMETER_CHANGED", aID, tID);
	end
end);