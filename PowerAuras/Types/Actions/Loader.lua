-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Dictionary of action ID's and the data table associated with it. The table
--  contains information like the trigger classes and types that compose
--  the action, as well as any dependencies upon other resources.
local ActionDataMap = {};

--- Dictionary of action ID's to the actual compiled action function.
local ActionMap = {};

--- Dictionary mapping actions to their ID's. While most resources can
--  store their own ID in some way, an action is a function with no specialised
--  way of storing an ID.
local ActionReverseMap = {};

--- Upvalue for CreateStoreProxy function.
local CreateStoreProxy;

do
	--- Checks if the store was updated and, if so, flags any providers that
	--  depend on this action/trigger for rechecks.
	local function UpdateProxy(proxy, aID, tID)
		-- Updated?
		local mt = getmetatable(proxy);
		if(mt.__PROXY_UPDATE) then
			mt.__PROXY_UPDATE = nil;
			PowerAuras:MarkActionDependentProviders(aID, tID);
		end
	end

	--- __index metamethod handler.
	-- @param proxy The proxy to read from.
	-- @param key   The key of the item to read.
	local function ReadProxy(proxy, key)
		-- Handle special keys.
		if(key == "UpdateProxy") then
			return UpdateProxy;
		else
			-- Get the store.
			local mt = getmetatable(proxy);
			local value = mt[key];

			-- If not a simple value, flag for updates.
			local tv = type(value);
			if(tv == "table"
				or tv == "function"
				or tv == "userdata"
				or tv == "thread") then
				-- Failed.
				mt.__PROXY_UPDATE = true;
			end

			-- Return it.
			return value;
		end
	end

	--- __newindex metamethod handler.
	-- @param proxy The proxy store.
	-- @param key   The key of the value to write.
	-- @param value The value to be written.
	local function WriteProxy(proxy, key, value)
		-- Get the proxy metadata.
		local mt = getmetatable(proxy);
		-- Write to the store and flag for updates.
		if(mt[key] ~= value) then
			mt[key] = value;
			mt.__PROXY_UPDATE = true;
		end
		return value;
	end

	--- Creates a proxy object for accessing a store table.
	-- @param store The store to wrap.
	function CreateStoreProxy(store)
		-- Create the proxy and return it.
		local proxy = newproxy(true);

		-- Alter the metatable.
		local mt = getmetatable(proxy);
		mt.__index = ReadProxy;
		mt.__newindex = WriteProxy;

		-- Now for the beautiful hack, set the __metatable field to some
		-- data for our state.
		mt.__metatable = store;
		return proxy;
	end
end

--- Returns the loaded action function for the passed action ID.
-- @param id The ID of the loaded action.
function PowerAuras:GetLoadedAction(id)
	return ActionMap[id] or error(L("ErrorActionNotLoaded", id));
end

--- Returns the loaded action data table for the passed action ID.
-- @param id The ID of the loaded action.
function PowerAuras:GetLoadedActionData(id)
	return ActionDataMap[id] or error(L("ErrorActionNotLoaded", id));
end

--- Returns the loaded action ID for the passed action function.
-- @param func The function of the loaded action.
function PowerAuras:GetLoadedActionID(func)
	return ActionReverseMap[func] or error(L("ErrorActionNotLoaded", -1));
end

--- Returns the dictionary of loaded actions.
function PowerAuras:GetLoadedActions()
	return ActionMap;
end

--- Checks if the passed action ID has been loaded successfully.
-- @param id The action ID to check the state of.
function PowerAuras:IsActionLoaded(id)
	return not not ActionMap[id];
end

--- Loads an action with the specified ID.
-- @param id  The action to load.
-- @param ... Additional arguments to pass to the action constructor.
--            If the arguments are not valid for the trigger class' specified
--            target, loading will fail.
-- @return True/false on success.
function PowerAuras:LoadAction(id, ...)
	-- Make sure this action has not yet been loaded.
	if(self:IsActionLoaded(id)) then
		return true;
	end

	-- Get the data to create this action.
	local data = self:GetAuraAction(id);

	-- Validate the class.
	if(not self:HasActionClass(data["Type"])) then
		self:LogResourceMessage(1, "Action", id, "MissingClass", "Action",
			data["Type"]);
		return false;
	end

	-- Now get the class.
	local class = self:GetActionClass(data["Type"]);

	-- Validate the target type.
	if(class:GetTarget() == "Display" or class:GetTarget() == "Animation") then
		local display, targetID, targetClass = ...;
		-- Typecheck the display and ID.
		if(type(display) ~= "table" or type(display[0]) ~= "userdata"
			or type(targetID) ~= "number"
			or (class:GetTarget() == "Display"
				and type(targetClass) ~= "table")) then
			-- Passed arguments aren't valid.
			return false;
		end
	end

	-- Create the activator function.
	local activator;
	local state, result = pcall(class.New, class, id, data["Parameters"], ...);
	if(not state) then
		-- Error creating the activator.
		self:LogResourceMessage(1, "Action", id, "Error", result);
		return false;
	else
		activator = result;
	end

	-- Data for our action. This table is modified by the LoadTrigger function.
	local actionData = {
		Actions   = {},        -- Action dependencies.
		Activator = activator, -- Activator function.
		Classes   = {},        -- Trigger class type names.
		Displays  = {},        -- Display dependencies.
		Function  = nil,       -- Generated function string.
		Providers = {},        -- Provider dependencies.
		Target    = nil,       -- Target resource ID/Type.
		Timed     = false,     -- True if a trigger needs timed updates.
		Types     = {},        -- Trigger instance type names.
		Lazy      = {},        -- Lazy rechecks list.
		Stores    = {},        -- Per-trigger storage.
		PerTimed  = {},        -- Per-trigger timed check state.
	};

	-- Was our class target a display/animation?
	if(class:GetTarget() == "Display" or class:GetTarget() == "Animation") then
		-- Then by default, we depend upon our linked display.
		actionData["Target"] = bit.bor(
			bit.band((select(2, ...)), 0xFFFF),
			0x10000
		);
	end

	-- Function "environment" for the action. This is unpacked to the loaded
	-- function which then uses the varargs to set locals.
	local actionEnv = { _G, PowerAuras, activator, id };

	-- Triggers can either be functions or inline string expressions.
	local triggerFunctions = {};

	-- Compile our triggers and create variable names for them.
	local triggerVariableNames = { "_G", "PowerAuras", "Activator", "ID" };

	for i = 1, #(data.Triggers) do
		-- Create variable name in format T<id>.
		local tid = ("T%d"):format(i);
		tinsert(triggerVariableNames, ("TR%d"):format(i));
		tinsert(actionEnv, false);

		-- Load trigger function.
		local data = data.Triggers[i];
		local state, result = self:LoadTrigger(data, id, actionData);
		if(not state) then
			self:LogResourceMessage(1, "Action", id, "ErrorTrigger", i);
			return false;
		end

		-- Is the result a string block with locals?
		if(type(result) == "string") then
			-- Include the string.
			triggerFunctions[tid] = result;
		elseif(type(result) == "function") then
			-- Functions can go straight in the environment.
			tinsert(triggerVariableNames, tid);
			tinsert(actionEnv, result);
			triggerFunctions[tid] = result;
		end

		-- Include the store.
		if(actionData.Stores[i] ~= nil) then
			tinsert(triggerVariableNames, ("TS%d"):format(i));
			tinsert(actionEnv, CreateStoreProxy(actionData.Stores[i]));
		end
	end

	-- Concatenate names.
	triggerVariableNames = table.concat(triggerVariableNames, ", ");

	-- Begin constructing the action function.
	local funcString, triggerChecks, sequenceChecks = {}, {}, {};
	tinsert(funcString, ([[
		-- Upvalues from the loader.
		local %s = ...;
		-- Return new function.
		return function(buffer, old)
	]]):format(triggerVariableNames));

	-- Insert all of our sequences.
	for i = 1, #(data.Sequences) do
		-- Insert the if condition.
		tinsert(sequenceChecks, [[if(]]);

		-- Get the sequence, split the operator string up.
		local seq = data.Sequences[i];
		local seqOps = seq["Operators"];
		for pre, id, post in seqOps:gmatch("([()&|! ]*)(%d+)([()&|! ]*)") do
			-- Get the trigger name and result variable name.
			id = tonumber(id);
			local triName = ("T%d"):format(id);
			local varName = ("TR%d"):format(id);

			-- Ensure the trigger ID was compiled.
			if(not triggerFunctions[triName]) then
				self:LogResourceMessage(1, "Action", id, "MissingTrigger", i);
				return false;
			end

			-- Have we inserted the check for this trigger yet?
			if(not triggerChecks[id]) then
				local trigger;
				-- If the trigger is a function, insert a call. Otherwise,
				-- inline it as an expr.
				if(type(triggerFunctions[triName]) == "function") then
					result = ("%s(%d, buffer, ID, %s)"):format(
						triName,
						id,
						(actionData.Stores[id] and ("TS%d"):format(id) or "nil") 
					);
				elseif(type(triggerFunctions[triName]) == "string") then
					result = triggerFunctions[triName];
				else
					result = "false";
				end

				-- Insert the check.
				local supportsLazy = actionData.Lazy[id];
				if(supportsLazy) then
					tinsert(funcString, ([[
						if(buffer.Triggers[%q]) then
							%s = (%s);
					]]):format(supportsLazy, varName, result));
				else
					tinsert(funcString, ([[
						%s = (%s);
					]]):format(varName, result));
				end

				-- Ensure that we call the UpdateProxy method on stores.
				if(actionData.Stores[id]) then
					tinsert(funcString, ([[
						TS%d:UpdateProxy(ID, %d);
					]]):format(id, id));
				end

				-- Close the lazy check block.
				if(supportsLazy) then
					tinsert(funcString, "end\n");
				end

				-- We only perform the check/assignment once.
				triggerChecks[id] = true;
			end

			-- Insert pre-operators.
			for j = 1, #(pre) do
				local c = pre:sub(j, j);
				tinsert(sequenceChecks, (c == "&" and " and "
					or c == "|" and " or "
					or c == "!" and " not "
					or c));
			end

			-- Insert the variable name.
			tinsert(sequenceChecks, varName);

			-- Post-operators.
			for j = 1, #(post) do
				local c = post:sub(j, j);
				tinsert(sequenceChecks, (c == "&" and " and "
					or c == "|" and " or "
					or c == "!" and " not "
					or c));
			end
		end

		-- Append the sequence check to the function string.
		tinsert(funcString, table.concat(sequenceChecks));
		wipe(sequenceChecks);

		-- And now compile the arguments to pass to the activator.
		local args = {};
		for j = 1, #(data.Sequences[i].Parameters) do
			-- Deal with the parameter based on its type. Complex types
			-- aren't supported.
			local param = data.Sequences[i].Parameters[j];
			local t = type(param);
			if(t == "string") then
				tinsert(args, ("%q"):format(param));
			elseif(t == "number") then
				tinsert(args, ("%g"):format(param));
			elseif(t == "boolean") then
				tinsert(args, (param and "true" or "false"));
			else
				-- Complex, use nil.
				tinsert(args, "nil");
			end
		end

		-- One parameter is required as a minimum.
		if(#(args) == 0) then
			tinsert(args, "nil");
		end

		-- Statement body.
		tinsert(funcString, ([[) then
			local i = %d;
			-- Update if sequence has changed.
			if(i ~= old) then
				PowerAuras:SetActionActivationData(ID, i);
				Activator(i, old, %s);
			end
			return;
		end
		]]):format(i, table.concat(args, ", ")));
	end

	-- Insert fallback sequence.
	tinsert(funcString, ([[
		-- No active sequences.
		if(old ~= nil) then
			PowerAuras:SetActionActivationData(ID, nil);
			return Activator(nil, old);
		end
	end;
	]]):format(#(data.Sequences) == 0 and "do" or "else"));

	-- Concatenate the function string.
	funcString = table.concat(funcString):gsub("\t", "");
	actionData["Function"] = funcString;

	-- Attempt to load it.
	local action, result = loadstring(funcString, "=");
	if(not action) then
		self:LogResourceMessage(1, "Action", id, "Error", result);
		return false;
	end

	-- Call the wrapper function to set the locals and generate the REAL
	-- action.
	local state, action = pcall(action, unpack(actionEnv));
	if(not state) then
		self:LogResourceMessage(1, "Action", id, "Error", action);
		return false;
	end

	-- It worked, set ourselves as loaded.
	ActionMap[id] = action;
	ActionDataMap[id] = actionData;
	ActionReverseMap[action] = id;
	self:LogResourceMessage(3, "Action", id, "Loaded");
	return true;
end

--- Unloads the specified action.
-- @param id     The ID of the action to unload.
function PowerAuras:UnloadAction(id)
	-- If not loaded, don't even bother.
	if(not self:IsActionLoaded(id)) then
		return;
	end
	-- If the dispatcher is currently loaded, unload it and reload later.
	local reload = self:IsDispatcherLoaded();
	if(reload) then
		self:PrintWarning("Unloading resource with dispatcher active.");
		self:UnloadDispatcher();
	end
	-- Unloading is as simple as removing from the map and changing the state.
	ActionReverseMap[ActionMap[id]] = nil;
	ActionMap[id] = nil;
	ActionDataMap[id] = nil;
	self:LogResourceMessage(3, "Action", id, "Unloaded");
	-- Reload the dispatcher if needed.
	if(reload) then
		self:LoadDispatcher();
	end
end