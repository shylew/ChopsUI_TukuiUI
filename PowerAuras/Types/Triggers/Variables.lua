-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

-- Modules.
local Coroutines, Metadata = PowerAuras:GetModules("Coroutines", "Metadata");

--- Creates a trigger and attaches it to the specified action.
-- @param id    The ID of the action.
-- @param name  The class name of the trigger.
-- @param index The index to store the trigger at. If a trigger exists here,
--              it will be replaced. Optional.
function PowerAuras:CreateAuraActionTrigger(id, name, index)
	-- Get the action and trigger class.
	local action = self:GetAuraAction(id);
	local aClass = self:GetActionClass(action.Type);
	local class = self:GetTriggerClass(name);

	-- Cap the index.
	index = math.min(
		index or math.huge,
		self:GetAuraActionTriggerCount(id) + 1,
		self.MAX_TRIGGERS_PER_ACTION
	);

	-- Create trigger.
	local tri = action.Triggers[index];
	action.Triggers[index] = {
		Type = name,
		Parameters = self:CopyTable(class:GetDefaultParameters()),
		Provider = (tri and tri.Provider),
		Flags = (aClass:GetTarget() == "Standalone"
			and Metadata.TRIGGER_SOURCE_AUTO
			or Metadata.TRIGGER_SOURCE_AUTODISP),
	};

	-- Does the trigger need a provider?
	tri = action.Triggers[index];
	if(next(class:GetRequiredServices())) then
		-- Create one from scratch.
		if(not tri.Provider) then
			local auraID = self:SplitAuraActionID(id);
			tri.Provider = self:CreateAuraProvider(auraID);
		end

		-- Construct required services.
		for int, _ in pairs(class:GetRequiredServices()) do
			self:CreateAuraProviderService(tri.Provider, int, "Static");
		end
	elseif(tri.Provider) then
		-- Nil out the provider.
		tri.Provider = nil;

		-- Remove unused resources.
		Coroutines:Queue(self:DeleteUnusedResources());
	end

	-- Return the trigger ID.
	self.OnOptionsEvent("TRIGGER_CREATED", id, name, index);
	return index;
end

--- Deletes a trigger from an action, and re-indexes the sequences if
--  necessary.
-- @param id    The ID of the action.
-- @param index The index of the trigger.
function PowerAuras:DeleteAuraActionTrigger(id, index)
	-- Get the action.
	local action = self:GetAuraAction(id);
	tremove(action["Triggers"], index);
	-- Re-index sequences.
	self:RemoveTriggerFromSequences(id, index);
	-- Remove unused resources.
	Coroutines:Queue(self:DeleteUnusedResources());
	-- Fire callbacks.
	self.OnOptionsEvent("TRIGGER_DELETED", id, index);
	return true;
end

do
	--- Internal iterator function.
	local function iterator(id, index)
		-- Validate action ID.
		if(not PowerAuras:HasAuraAction(id)) then
			return nil, nil;
		end
		-- Validate next trigger ID.
		index = index + 1;
		if(PowerAuras:HasAuraActionTrigger(id, index)) then
			return index, PowerAuras:GetAuraActionTrigger(id, index);
		else
			return nil, nil;
		end
	end

	--- Returns an iterator for accessing all triggers within an action.
	-- @param id The ID of the action.
	function PowerAuras:GetAllAuraActionTriggers(id)
		-- Return iterator.
		return iterator, id, 0;
	end
end

--- Retrieves a trigger from the action with the specified index.
-- @param id  The ID of the action.
-- @param tri The trigger index.
function PowerAuras:GetAuraActionTrigger(id, tri)
	-- Validate existance.
	assert(self:HasAuraActionTrigger(id, tri),
		L("ErrorTriggerIDInvalid", id, tri));
	return self:GetAuraAction(id)["Triggers"][tri];
end

--- Returns the total number of triggers within an action.
-- @param id  The ID of the action.
function PowerAuras:GetAuraActionTriggerCount(id)
	return (self:HasAuraAction(id)
		and #(self:GetAuraAction(id)["Triggers"])
		or 0);
end

--- Returns the index of the 'main' trigger within the display. If none is
--  found, nil will be returned.
-- @param id    The ID of the display to search.
-- @param check If set to true, this will return nil if there's more than
--              one main trigger set.
function PowerAuras:GetMainTrigger(id, check)
	-- Find the display action.
	local display = self:GetAuraDisplay(id);
	local actionID = display["Actions"]["DisplayActivate"];
	local action = self:GetAuraAction(actionID);
	-- Run over the triggers until we find the 'main' one.
	local result = nil;
	for i = 1, #(action["Triggers"]) do
		local tri = action["Triggers"][i];
		local class = self:GetTriggerClass(tri["Type"]);
		-- Main trigger is the one that isn't a support trigger.
		if(not class:IsSupportTrigger()) then
			-- If not checking for multiples, just return.
			if(not check) then
				return i, actionID;
			else
				-- Otherwise, if we found a result then quit, if not then
				-- store it and continue.
				if(result) then
					return nil, nil;
				else
					result = i;
				end
			end
		end
	end
	-- Return our result.
	return result, (result and actionID or nil);
end

--- Checks if an action has a trigger with the specified index.
-- @param id  The ID of the action.
-- @param tri The trigger index.
function PowerAuras:HasAuraActionTrigger(id, tri)
	-- Validate types.
	if(not self:HasAuraAction(id) or type(tri) ~= "number") then
		return false;
	else
		return not not self:GetAuraAction(id)["Triggers"][tri];
	end
end