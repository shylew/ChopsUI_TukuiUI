-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

-- Load modules.
local Coroutines, Metadata = PowerAuras:GetModules("Coroutines", "Metadata");

--- Creates a display on the specified aura.
-- @param id    The ID of the aura to place the display on.
-- @param name  The class name of the display to create.
-- @return The ID of the created display if successful, nil on failure.
function PowerAuras:CreateAuraDisplay(id, name)
	-- Get the aura and the class.
	local aura = self:GetAura(id);
	local class = self:GetDisplayClass(name);
	-- Ensure that we can fit the display on the aura.
	local displayID = self:GetAuraDisplayCount(id) + 1;
	if(displayID > self.MAX_DISPLAYS_PER_AURA) then
		return nil;
	end
	-- Attempt to construct an activate action.
	local actionID = self:CreateAuraAction(id, "DisplayActivate");
	if(not actionID) then
		return nil;
	end
	-- Attach two triggers to it.
	self:CreateAuraActionTrigger(actionID, "UnitAura");
	self:CreateAuraActionTrigger(actionID, "PlayerState");
	if(self.SetParameter) then
		self:SetParameter("SequenceOp", "", "1&2", actionID, 1);
	else
		self:GetAuraActionSequence(actionID, 1)["Operators"] = "1&2";
	end
	-- Do we require a provider?
	local providerID;
	if(next(class:GetAllServices())) then
		-- Create one.
		providerID = self:CreateAuraProvider(id);
		if(not providerID) then
			return nil;
		end
		-- Apply services.
		local pID = providerID;
		for svc, _ in pairs(class:GetRequiredServices()) do
			if(not self:CreateAuraProviderService(pID, svc, "Static")) then
				return nil;
			end
		end
	end
	-- Get the fixed layout class.
	local layout = self:GetLayoutClass("Fixed");
	-- Construct the display.
	aura["Displays"][displayID] = {
		-- Class name.
		Type = name,
		-- Editor flags.
		Flags = Metadata.DISPLAY_SOURCE_AUTO,
		-- Actions table.
		Actions = {
		},
		-- Animations table, safe to leave empty.
		Animations = {
			Static = {},
			Triggered = {
				Single = {},
				Repeat = {},
			},
		},
		-- Layout data, layout #1 will always be a Fixed layout.
		Layout = {
			ID = 1,
			Parameters = self:CopyTable(layout:GetDefaultDisplayParameters()),
		},
		-- Data provider.
		Provider = providerID,
		-- Config parameters.
		Parameters = self:CopyTable(class:GetDefaultParameters()),
	};
	-- Link the activate action to the display.
	local id = self:GetAuraDisplayID(id, displayID);
	self:LinkAuraDisplayAction(id, actionID);
	-- Fire callbacks.
	self.OnOptionsEvent("DISPLAY_CREATED", id);
	return id;
end

--- Deletes a display from an aura.
-- @param id      The ID of the display to delete.
-- @param noIndex If passed as true, no reindexing is performed.
function PowerAuras:DeleteAuraDisplay(id, noIndex)
	-- Make sure the display exists.
	if(not self:HasAuraDisplay(id)) then
		return false;
	end

	-- Remove the display. All of it. Gone. Poof!
	local aID, dID = self:SplitAuraDisplayID(id);
	local aura = self:GetAura(aID);
	tremove(aura["Displays"], dID);

	-- Bail if not reindexing.
	if(noIndex) then
		self.OnOptionsEvent("DISPLAY_DELETED", id);
		return true;
	end

	-- Check for displays that linked to it.
	for i = #(aura.Displays), 1, -1 do
		local lVars = aura.Displays[i];
		if(lVars and Metadata:GetFlagID(lVars["Flags"], "Display") == dID) then
			-- It linked, so destroy it.
			self:DeleteAuraDisplay(PowerAuras:GetAuraDisplayID(aID, i), true);
		elseif(not lVars) then
			-- Something odd happened. This may occur if there's an
			-- illegal chain of linked displays.
			break;
		end
	end

	-- Remove references to the display.
	PowerAuras:ReindexResourceID("Display", id, nil);

	-- Remove unused resources.
	Coroutines:Queue(self:DeleteUnusedResources());

	-- Fire GUI events.
	self.OnOptionsEvent("DISPLAY_DELETED", id);
	return true;
end

do
	--- Internal stateless iterator function for GetAllDisplays.
	local function iterator(_, i)
		-- Attempt to access the next action.
		i = i + 1;
		-- Valid?
		if(PowerAuras:HasAuraDisplay(i)) then
			return i, PowerAuras:GetAuraDisplay(i);
		else
			-- Go to the next aura.
			local aura = PowerAuras:SplitAuraDisplayID(i) + 1;
			while(PowerAuras:HasAura(aura)) do
				i = PowerAuras:GetAuraDisplayID(aura, 1);
				if(PowerAuras:HasAuraDisplay(i)) then
					-- Action here exists.
					return i, PowerAuras:GetAuraDisplay(i);
				else
					aura = aura + 1;
				end
			end
		end
	end

	--- Returns an iterator that can be used for accessing every display within
	--  the current profile.
	function PowerAuras:GetAllDisplays()
		return iterator, nil, 0;
	end
end

--- Retrieves the specified display if it exists.
-- @param id The ID to resolve.
-- @return The referenced display.
function PowerAuras:GetAuraDisplay(id)
	assert(self:HasAuraDisplay(id), L("ErrorAuraDisplayIDInvalid", id));
	local auraID, displayID = self:SplitAuraDisplayID(id);
	return self:GetAura(auraID)["Displays"][displayID];
end

--- Returns the DisplayActivate action ID for the specified display.
-- @param id The ID of the display.
-- @return The ID of the action, or nil if it wasn't found.
function PowerAuras:GetAuraDisplayActivateAction(id)
	local display = PowerAuras:GetAuraDisplay(id);
	for class, id in pairs(display["Actions"]) do
		if(class == "DisplayActivate") then
			return id;
		end
	end
end

--- Returns the total number of displays in the specified aura.
-- @param id The aura ID.
function PowerAuras:GetAuraDisplayCount(id)
	return (self:HasAura(id)
		and #(self:GetAura(id)["Displays"])
		or 0);
end

--- Calculates the ID of an display for the given aura and display ID's.
-- @param auraID    The ID of the aura.
-- @param displayID The ID of the action within the aura.
function PowerAuras:GetAuraDisplayID(auraID, displayID)
	return ((auraID - 1) * PowerAuras.MAX_DISPLAYS_PER_AURA) + displayID;
end

--- Returns the layout used by the specified display.
-- @param id The ID of the display.
function PowerAuras:GetAuraDisplayLayout(id)
	return self:GetLayout(self:GetAuraDisplay(id)["Layout"]["ID"]);
end

--- Returns the displays table for the specified aura.
-- @param id The aura ID.
function PowerAuras:GetAuraDisplays(id)
	assert(self:HasAura(id), L("ErrorAuraIDInvalid", id));
	return self:GetAura(id)["Displays"];
end

--- Validates the passed display ID.
-- @param id The ID of the display.
-- @return True if a display with this ID exists. False if not.
function PowerAuras:HasAuraDisplay(id)
	-- Validate type, then split the ID.
	if(type(id) ~= "number") then
		return false;
	end
	local auraID, displayID = self:SplitAuraDisplayID(id);
	-- Validate aura ID, then the display ID.
	return (self:HasAura(auraID) 
		and self:GetAura(auraID)["Displays"][displayID] ~= nil);
end

--- Links a display to an action.
-- @param dID The ID of the display.
-- @param aID  The ID of the action.
-- @return True on success, false on failure.
function PowerAuras:LinkAuraDisplayAction(dID, aID)
	-- Get the display.
	local dVars = self:GetAuraDisplay(dID);
	local class = self:GetDisplayClass(dVars["Type"]);
	-- Verify the class supports this action.
	local aVars = self:GetAuraAction(aID);
	if(not class:IsActionSupported(aVars["Type"])) then
		return false;
	end
	dVars["Actions"][aVars["Type"]] = aID;
	self.OnOptionsEvent("DISPLAY_ACTION_LINK_CREATED", dID, aID, aVars["Type"]);
	return true;
end

--- Splits the passed display ID into the aura ID and the index of the display
--  within the aura.
-- @param id The ID to split.
function PowerAuras:SplitAuraDisplayID(id)
	if(type(id) ~= "number") then
		return 0, 0;
	else
		return math.ceil((id / PowerAuras.MAX_DISPLAYS_PER_AURA)),
			((id - 1) % PowerAuras.MAX_DISPLAYS_PER_AURA) + 1;
	end
end