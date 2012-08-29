-- Lock down local environment.
local PowerAuras = _G["PowerAuras"];
setfenv(1, PowerAuras);

--- Current selected aura ID for the workspace.
local CurrentAuraID = nil;

--- Current selected display ID for the workspace.
local CurrentDisplayID = nil;

--- Current selected layout ID for the workspace.
local CurrentLayoutID = nil;

--- Registers a function for receiving notifications of changed saved
--  variable parameters.
-- @param ... Argument composition changes based upon what type of function
--            to register. If the first argument is a function, then it is
--            registered as a direct callback handler, however if the first
--            type is a string then the format is type, key, callback and ID's.
--            The callback argument is the function to execute.
-- @remarks The type, key and id parameters are the same as used by the
--          Get/SetParameter functions.
function PowerAuras:ConnectParameterHandler(...)
	-- Argument composition based on type of first arg.
	local handlerType = type(select(1, ...));
	if(handlerType == "function") then
		-- We're using a custom callback handler.
		local func = select(1, ...);
		self.OnParameterChanged:Connect(func);
		return func;
	elseif(handlerType == "string") then
		-- Use a generic wrapper function.
		local ptype, key, func, id1, id2, id3, id4, id5 = ...;
		if(type(ptype) == "string") then ptype = ("%q"):format(ptype); end
		if(type(key) == "string") then key = ("%q"):format(key); end
		if(type(id1) == "string") then id1 = ("%q"):format(id1); end
		if(type(id2) == "string") then id2 = ("%q"):format(id2); end
		if(type(id3) == "string") then id3 = ("%q"):format(id3); end
		if(type(id4) == "string") then id4 = ("%q"):format(id4); end
		if(type(id5) == "string") then id5 = ("%q"):format(id5); end
		local wrapper = PowerAuras:Loadstring(PowerAuras:FormatString([[
			local func = ...;
			return function(value, type, key, id1, id2, id3, id4, id5)
				-- Validate params.
				if(type == ${1} and key == ${2}
					and (${3} == nil or ${3} == id1)
					and (${4} == nil or ${4} == id2)
					and (${5} == nil or ${5} == id3)
					and (${6} == nil or ${6} == id4)
					and (${7} == nil or ${7} == id5)) then
					-- Call function.
					func(value, type, key, id1, id2, id3, id4, id5);
				end
			end;
		]], ptype, key, tostringall(id1, id2, id3, id4, id5)))(func);
		self.OnParameterChanged:Connect(wrapper);
		return wrapper;
	end
end

--- Disconnects a parameter handler function.
-- @param func The function to disconnect.
function PowerAuras:DisconnectParameterHandler(func)
	self.OnParameterChanged:Disconnect(func);
end

--- Returns the currently selected aura ID in the workspace.
function PowerAuras:GetCurrentAura()
	return CurrentAuraID;
end

--- Returns the currently selected display ID in the workspace.
function PowerAuras:GetCurrentDisplay()
	return CurrentDisplayID,
		self:GetAuraDisplayID(CurrentAuraID or 0, CurrentDisplayID or 0);
end

--- Returns the currently selected layout ID in the workspace.
function PowerAuras:GetCurrentLayout()
	return CurrentLayoutID;
end

--- Retrieves a parameter associated with the given key.
-- @param type  The type of the parameter.
-- @param key   The name of the parameter.
-- @param ...   The ID's to identify the resource.
function PowerAuras:GetParameter(type, key, ...)
	-- Handle type.
	if(type == "Animation") then
		-- Extract and validate ID's.
		local id, aType, cType, cID, aID = ...;
		if(not self:HasAuraDisplay(id)) then
			return nil;
		end
		-- Get display data.
		local display = self:GetAuraDisplay(id);
		-- Work our way to the animation.
		local anims = display["Animations"][aType];
		local anim = (aType == "Static" and anims[cType]
			or aType == "Triggered" and anims[cType][cID]["Animations"][aID]);
		-- Get the animation class.
		local class = self:GetAnimationClass(anim["Type"]);
		-- Set parameter.
		if(class:GetDefaultParameters()[key] ~= nil) then
			return anim["Parameters"][key];
		else
			return nil;
		end
	elseif(type == "Display") then
		-- Validate the ID.
		local displayID = ...;
		if(not self:HasAuraDisplay(displayID)) then
			return nil;
		end
		-- Get the data.
		local data = self:GetAuraDisplay(displayID);
		if(not self:HasDisplayClass(data["Type"])) then
			return nil;
		end
		-- Grab the class.
		local class = self:GetDisplayClass(data["Type"]);
		-- Get data.
		if(class:GetDefaultParameters()[key] ~= nil) then
			return data["Parameters"][key];
		else
			return nil;
		end
	elseif(type == "DisplayLayout") then
		-- Validate the IDs.
		local displayID = ...;
		if(not self:HasAuraDisplay(displayID)) then
			return nil;
		end
		-- Get the data.
		local data = self:GetAuraDisplay(displayID)["Layout"];
		if(not self:HasLayout(data["ID"])) then
			return nil;
		end
		-- Get the layout.
		local layout = self:GetAuraDisplayLayout(displayID);
		if(not self:HasLayoutClass(layout["Type"])) then
			return;
		end
		-- Get the class.
		local class = self:GetLayoutClass(layout["Type"]);
		-- Get parameter.
		if(key == "ID") then
			return data["ID"];
		elseif(class:GetDefaultDisplayParameters()[key] ~= nil) then
			return data["Parameters"][key];
		else
			return nil;
		end
	elseif(type == "Global") then
		return self.GlobalSettings[key];
	elseif(type == "Provider") then
		-- Validate ID's.
		local provID, int = ...;
		if(not self:HasAuraProvider(provID)) then
			return nil;
		end
		-- Get the provider.
		local prov = self:GetAuraProvider(provID);
		if(not prov[int]) then
			return nil;
		end
		-- Get parameter.
		return prov[int]["Parameters"][key];
	elseif(type == "Sequence") then
		-- Validate ID's.
		local actionID, sequenceID = ...;
		if(not self:HasAuraActionSequence(actionID, sequenceID)) then
			return nil;
		end
		-- Return the parameter by this key.
		local seq = self:GetAuraActionSequence(actionID, sequenceID);
		return seq["Parameters"][key];
	elseif(type == "SequenceOp") then
		-- Validate IDs.
		local actionID, sequenceID = ...;
		if(not self:HasAuraActionSequence(actionID, sequenceID)) then
			return nil;
		end
		-- Return the sequence operators.
		local seq = self:GetAuraActionSequence(actionID, sequenceID);
		return seq["Operators"];
	elseif(type == "Trigger") then
		-- Validate the IDs.
		local actionID, triggerID = ...;
		if(not self:HasAuraActionTrigger(actionID, triggerID)) then
			return nil;
		end
		-- Get the trigger.
		local trigger = self:GetAuraActionTrigger(actionID, triggerID);
		-- Verify class exists.
		if(not self:HasTriggerClass(trigger["Type"])) then
			return nil;
		end
		-- Get class, get parameter.
		local class = self:GetTriggerClass(trigger["Type"]);
		if(class:GetDefaultParameters()[key] ~= nil) then
			return trigger["Parameters"][key];
		else
			return nil;
		end
	else
		return nil;
	end
end

--- Checks if the passed aura ID is that of the current selected one.
-- @param id The aura ID.
function PowerAuras:IsCurrentAura(id)
	return (CurrentAuraID ~= nil and CurrentAuraID == id);
end

--- Checks if the passed display ID is that of the current selected one.
-- @param id The display ID.
function PowerAuras:IsCurrentDisplay(id)
	return (CurrentDisplayID ~= nil and CurrentDisplayID == id);
end

--- Sets the currently selected aura ID for the workspace.
-- @param id The ID of the aura to select.
function PowerAuras:SetCurrentAura(id)
	-- Validate ID, if not valid then set to nil.
	if(not self:HasAura(id)) then
		id = nil;
	end
	-- Store, fire callbacks.
	local old = CurrentAuraID;
	CurrentAuraID = id;
	-- Fire callback if necessary.
	if(id ~= old) then
		-- Remove selected display.
		self:SetCurrentDisplay(nil);
		self.OnOptionsEvent("SELECTED_AURA_CHANGED", id);
	end
end

--- Sets the currently selected display ID for the workspace.
-- @param id The ID of the display to select. This is not the global ID of the
--           display, but rather the ID of the display within the current aura.
function PowerAuras:SetCurrentDisplay(id)
	-- Validate ID, if not valid then set to nil.
	local displayID = self:GetAuraDisplayID(CurrentAuraID or 0, id or 0);
	if(not self:HasAuraDisplay(displayID)) then
		id = nil;
	end
	-- Store, fire callbacks.
	local old = CurrentDisplayID;
	CurrentDisplayID = id;
	-- Update dependents.
	if(id ~= old) then
		self.OnOptionsEvent("SELECTED_DISPLAY_CHANGED", displayID);
	end
end

--- Sets the current layout ID.
-- @param id The ID of the layout to select.
function PowerAuras:SetCurrentLayout(id)
	-- Validate ID.
	if(not self:HasLayout(id)) then
		id = nil;
	end
	-- Store old ID.
	local old = CurrentLayoutID;
	CurrentLayoutID = id;
	-- Fire callbacks.
	if(id ~= old) then
		self.OnOptionsEvent("SELECTED_LAYOUT_CHANGED", id);
	end
end

--- Sets a parameter and fires the necessary callbacks.
-- @param type  The type of the parameter.
-- @param key   The name of the parameter.
-- @param value The value to set.
-- @param ...   ID of the object to apply the parameter to. Based on the type.
-- @return True on success, false on failure.
function PowerAuras:SetParameter(type, key, value, ...)
	-- Handle type.
	if(type == "Animation") then
		-- Extract and validate ID's.
		local id, aType, cType, cID, aID = ...;
		if(not self:HasAuraDisplay(id)) then
			return false;
		end
		-- Get display data.
		local display = self:GetAuraDisplay(id);
		-- Work our way to the animation.
		local anims = display["Animations"][aType];
		local anim = (aType == "Static" and anims[cType]
			or aType == "Triggered" and anims[cType][cID]["Animations"][aID]);
		-- Get the animation class.
		local class = self:GetAnimationClass(anim["Type"]);
		-- Set parameter.
		if(class:GetDefaultParameters()[key] ~= nil) then
			anim["Parameters"][key] = value;
		else
			return false;
		end
		-- Fire callbacks.
		self.OnParameterChanged(value, type, key, ...);
	elseif(type == "Display") then
		-- Validate the ID.
		local displayID = ...;
		if(not self:HasAuraDisplay(displayID)) then
			return false;
		end
		-- Get the data.
		local data = self:GetAuraDisplay(displayID);
		if(not self:HasDisplayClass(data["Type"])) then
			return false;
		end
		local class = self:GetDisplayClass(data["Type"]);
		-- Set data.
		if(class:GetDefaultParameters()[key] ~= nil) then
			data["Parameters"][key] = value;
		else
			return false;
		end
		-- Fire callbacks.
		self.OnParameterChanged(value, type, key, displayID);
	elseif(type == "DisplayLayout") then
		-- Validate the ID.
		local displayID = ...;
		if(not self:HasAuraDisplay(displayID)) then
			return false;
		end
		-- Get the data.
		local data = self:GetAuraDisplay(displayID)["Layout"];
		if(not self:HasLayout(data["ID"])) then
			return false;
		end
		-- Get the layout.
		local layout = self:GetAuraDisplayLayout(displayID);
		if(not self:HasLayoutClass(layout["Type"])) then
			return;
		end
		-- Get the class.
		local class = self:GetLayoutClass(layout["Type"]);
		-- Set parameter.
		if(key == "ID" and self:HasLayout(value)) then
			data["ID"] = tonumber(value);
		elseif(class:GetDefaultDisplayParameters()[key] ~= nil) then
			data["Parameters"][key] = value;
		else
			return false;
		end
		-- Fire callbacks.
		self.OnParameterChanged(value, type, key, displayID);
	elseif(type == "Global") then
		-- Set setting if a default exists for it.
		if(self.DefaultGlobalSettings[key] ~= nil) then
			self.GlobalSettings[key] = value;
		else
			return false;
		end
		-- Fire callbacks.
		self.OnParameterChanged(value, type, key);
	elseif(type == "Provider") then
		-- Validate ID's.
		local provID, int = ...;
		if(not self:HasAuraProvider(provID)) then
			return false;
		end
		-- Get the provider.
		local prov = self:GetAuraProvider(provID);
		if(not prov[int]) then
			return false;
		end
		-- Get class.
		local t = prov[int]["Type"];
		if(not self:HasServiceClassImplemented(t, int)) then
			return false;
		end
		local class = self:GetServiceClassImplementation(t, int);
		-- Set parameter.
		if(class:GetDefaultParameters()[key] ~= nil) then
			prov[int]["Parameters"][key] = value;
		else
			return false;
		end
		-- Fire callbacks.
		self.OnParameterChanged(value, type, key, provID, int);
	elseif(type == "Sequence") then
		-- Validate ID's.
		local actionID, sequenceID = ...;
		if(not self:HasAuraActionSequence(actionID, sequenceID)) then
			return false;
		end
		-- Set the parameter.
		local action = self:GetAuraAction(actionID);
		local actionClass = self:GetActionClass(action["Type"]);
		local seq = self:GetAuraActionSequence(actionID, sequenceID);
		if(actionClass:GetDefaultParameters()[key] ~= nil) then
			seq["Parameters"][key] = value;
		else
			return false;
		end
		-- Fire callbacks.
		self.OnParameterChanged(value, type, key, actionID, sequenceID);
	elseif(type == "SequenceOp") then
		-- Validate IDs.
		local actionID, sequenceID = ...;
		if(not self:HasAuraActionSequence(actionID, sequenceID)) then
			return false;
		end
		-- Update the sequence operators.
		local sequence = self:GetAuraActionSequence(actionID, sequenceID);
		sequence["Operators"] = value;
		-- Fire callbacks.
		self.OnParameterChanged(value, type, "", actionID, sequenceID);
	elseif(type == "Trigger") then
		-- Validate the IDs.
		local actionID, triggerID = ...;
		if(not self:HasAuraActionTrigger(actionID, triggerID)) then
			return false;
		end
		-- Get the trigger.
		local trigger = self:GetAuraActionTrigger(actionID, triggerID);
		-- Verify class exists.
		if(not self:HasTriggerClass(trigger["Type"])) then
			return false;
		end
		-- Get class, set parameter.
		local class = self:GetTriggerClass(trigger["Type"]);
		if(class:GetDefaultParameters()[key] ~= nil) then
			trigger["Parameters"][key] = value;
		else
			return false;
		end
		-- Fire callbacks.
		self.OnParameterChanged(value, type, key, actionID, triggerID);
	else
		return false;
	end
	-- Success!
	return true;
end