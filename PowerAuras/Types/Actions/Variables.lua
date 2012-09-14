-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

-- Modules.
local Coroutines = PowerAuras:GetModules("Coroutines");

--- Creates an action on the specified aura.
-- @param id   The ID of the aura.
-- @param name The name of the action class to construct.
-- @param link The display ID to link to.
function PowerAuras:CreateAuraAction(id, name, link)
	-- Get the aura and class.
	local aura = self:GetAura(id);
	local class = self:GetActionClass(name);
	-- Can we fit the action onto the aura?
	local actionID = self:GetAuraActionCount(id) + 1;
	if(actionID > self.MAX_ACTIONS_PER_AURA) then
		self:PrintError("Maximum number of actions per aura reached.");
		return nil;
	end
	-- Construct the action.
	local realID = self:GetAuraActionID(id, actionID);
	aura["Actions"][actionID] = {
		Type = name,
		Sequences = {},
		Triggers = {},
	};
	-- Fire callbacks.
	self.OnOptionsEvent("ACTION_CREATED", realID);
	-- Link to a display if necessary.
	if(link) then
		self:LinkAuraDisplayAction(link, realID);
	end
	-- Construct an initial sequence.
	self:CreateAuraActionSequence(realID);
	-- Return the created ID.
	return realID;
end

--- Deletes the action with the specified ID.
-- @param id The ID of the action to delete.
function PowerAuras:DeleteAuraAction(id)
	-- Make sure the action exists.
	if(not self:HasAuraAction(id)) then
		return false;
	end
	-- Begin removal.
	local auraID, actionID = self:SplitAuraActionID(id);
	local aura = self:GetAura(auraID);
	tremove(aura["Actions"], actionID);
	-- Update references.
	self:ReindexResourceID("Action", id, nil);
	-- Remove unused resources.
	Coroutines:Queue(self:DeleteUnusedResources());
	-- Fire callbacks.
	self.OnOptionsEvent("ACTION_DELETED", id);
	return true;
end

do
	--- Internal stateless iterator function for GetAllActions.
	local function iterator(_, i)
		-- Attempt to access the next action.
		i = i + 1;
		-- Valid?
		if(PowerAuras:HasAuraAction(i)) then
			return i, PowerAuras:GetAuraAction(i);
		else
			-- Go to the next aura.
			local aura = PowerAuras:SplitAuraActionID(i) + 1;
			while(PowerAuras:HasAura(aura)) do
				i = PowerAuras:GetAuraActionID(aura, 1);
				if(PowerAuras:HasAuraAction(i)) then
					-- Action here exists.
					return i, PowerAuras:GetAuraAction(i);
				else
					aura = aura + 1;
				end
			end
		end
	end

	--- Returns an iterator that can be used for accessing every action within
	--  the current profile.
	function PowerAuras:GetAllActions()
		return iterator, nil, 0;
	end
end

--- Retrieves the specified action if it exists.
-- @param id The ID to resolve.
-- @return The referenced action.
function PowerAuras:GetAuraAction(id)
	assert(self:HasAuraAction(id), L("ErrorAuraActionIDInvalid", id));
	local auraID, actionID = self:SplitAuraActionID(id);
	return self:GetAura(auraID)["Actions"][actionID];
end

--- Returns the total number of actions in the specified aura.
-- @param id The aura ID.
function PowerAuras:GetAuraActionCount(id)
	return (self:HasAura(id)
		and #(self:GetAura(id)["Actions"])
		or 0);
end

--- Calculates the ID of an action for the given aura and action ID's.
-- @param auraID   The ID of the aura.
-- @param actionID The ID of the action within the aura.
function PowerAuras:GetAuraActionID(auraID, actionID)
	return ((auraID - 1) * PowerAuras.MAX_ACTIONS_PER_AURA) + actionID;
end

--- Returns the actions table for the specified aura.
-- @param id The aura ID.
function PowerAuras:GetAuraActions(id)
	assert(self:HasAura(id), L("ErrorAuraIDInvalid", id));
	return self:GetAura(id)["Actions"];
end

--- Validates the passed action ID.
-- @param id The ID of the action.
-- @return True if an action with this ID exists. False if not.
function PowerAuras:HasAuraAction(id)
	-- Validate type, then split the ID.
	if(type(id) ~= "number") then
		return false;
	end
	local auraID, actionID = self:SplitAuraActionID(id);
	-- Validate aura ID, then the action ID.
	return (self:HasAura(auraID) 
		and self:GetAura(auraID)["Actions"][actionID] ~= nil);
end

--- Splits the passed action ID into the aura ID and the index of the action
--  within the aura.
-- @param id The ID to split.
function PowerAuras:SplitAuraActionID(id)
	if(type(id) ~= "number") then
		return 0, 0;
	else
		return math.ceil((id / PowerAuras.MAX_ACTIONS_PER_AURA)),
			((id - 1) % PowerAuras.MAX_ACTIONS_PER_AURA) + 1;
	end
end