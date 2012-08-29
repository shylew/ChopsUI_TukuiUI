-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Editor controls table upvalue.
local EditorControls = {};

--- Creates an RFC-4122 v4 compliant UUID.
-- @see http://stackoverflow.com/a/2117523
local function uuid()
   return ("xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"):gsub("[xy]", function(c)
         local r = math.floor(math.random() * 16);
         local v = (c == "x" and r or bit.bor(bit.band(r, 0x3), 0x8));
         return ("%X"):format(v);
   end);
end

--- Creates a new custom trigger. The trigger will be created with a unique
--  ID for a type name, and will be given a default generic name.
function PowerAuras:CreateCustomTrigger()
	-- Create the trigger.
	local c = #(self.GlobalSettings["Triggers"]) + 1;
	self.GlobalSettings["Triggers"][c] = {
		Type         = uuid(),
		Name         = ("Custom Trigger %d"):format(c),
		Tooltip      = L["NoDescription"],
		Timed        = false,
		ToggleTimed  = false,
		Lazy         = true,
		Dependencies = { Action = {}, Display = {} },
		Editor       = {},
		Events       = {},
		Parameters   = {},
		Services     = {},
		New          = [[
-- Trigger constructor arguments.
-- @param class  The trigger class.
local class = ...;

-- Any pre-trigger setup here. Locals 
-- defined here are upvalues to the
-- generated function.
local a = 5;

-- Generate trigger function.
return function(self, buffer, action, store)
	-- Activate if upvalue 'a' is 5.
	return (a == 5);
end
		]],
	};

	-- Fire necessary events.
	self:LoadCustomTriggers();
	self.OnOptionsEvent("CUSTOM_TRIGGER_CREATED", c);
	return c;
end

--- Deletes a custom trigger. The trigger will be deleted, and any triggers
--  which reference it will instead be reset to using the Static trigger type.
-- @param id The ID of the trigger.
function PowerAuras:DeleteCustomTrigger(id)
	-- Find users of this trigger and change their types.
	for _, tri in self:IterCustomTriggerUsers(id) do
		tri.Type = "Static";
		wipe(tri.Parameters);
	end

	-- Destroy it.
	local vars = tremove(self.GlobalSettings.Triggers, id);
	local classes = PowerAuras:GetTriggerClasses();
	classes[vars.Type] = nil;

	-- Fire necessary events.
	self.OnOptionsEvent("CUSTOM_TRIGGER_DELETED", c);
end

do
	--- Iterator function for IterCustomTriggerUsers.
	-- @param id   The ID of the custom trigger.
	-- @param node Internal node ID of the action/trigger.
	local function iterator(id, node)
		-- Sort out the node ID and trigger variables.
		local _, aID, _, tID = PowerAuras:SplitNodeID(node);
		local vars = PowerAuras.GlobalSettings.Triggers[id];

		-- Does the action exist or not?
		if(not PowerAuras:HasAuraAction(aID)) then
			-- Try bumping the aura up.
			local auraID, subID = PowerAuras:SplitAuraActionID(aID);
			if(PowerAuras:HasAura(auraID + 1)) then
				return iterator(
					id,
					PowerAuras:GetNodeID(
						"Actions",
						PowerAuras:GetAuraActionID(auraID + 1, 1),
						0, 0, 0, 0
					)
				);
			else
				-- No other auras to check.
				return;
			end
		end

		-- Iterate over the triggers on the action.
		local action = PowerAuras:GetAuraAction(aID);
		for i = tID + 1, #(action.Triggers) do
			local tri = action.Triggers[i];
			if(tri.Type == vars.Type) then
				-- Got one.
				return PowerAuras:GetNodeID("Actions", aID, 0, i, 0, 0), tri;
			end
		end
		-- Getting here means we ran out of triggers on the action, so bump
		-- it up and retry.
		return iterator(
			id,
			PowerAuras:GetNodeID("Actions", aID + 1, 0, 0, 0, 0)
		);
	end

	--- Iterates over all triggers that use a custom trigger.
	-- @param id The index of the custom trigger.
	function PowerAuras:IterCustomTriggerUsers(id)
		return iterator, id, self:GetNodeID("Actions", 1, 0, 0, 0, 0);
	end
end

--- Loads the custom trigger types stored in our saved variables.
-- @param noLoad If set to true, classes are created but not initialised.
function PowerAuras:LoadCustomTriggers(noLoad)
	-- Iterate over the triggers.
	for i = 1, #(self.GlobalSettings["Triggers"]) do
		-- Operate on a copy of the data.
		local data = self.GlobalSettings["Triggers"][i];

		-- If the trigger already exists, don't load.
		if(not self:HasTriggerClass(data["Type"])) then
			-- Generate the class.
			local class = self:RegisterTriggerClass(data["Type"]);
			class.IsCustom = true;

			-- Call ReloadCustomTrigger to handle the loading.
			if(not noLoad) then
				self:ReloadCustomTrigger(i);
			end

			-- Update localisation tables.
			L["TriggerClasses"][data["Type"]]["Name"] = data["Name"];
			L["TriggerClasses"][data["Type"]]["Tooltip"] = data["Tooltip"];
		else
			-- Is it registered as a custom class?
			local class = self:GetTriggerClass(data["Type"]);
			if(class.IsCustom) then
				-- Regenerate the function if not told otherwise.
				if(not noLoad) then
					self:ReloadCustomTrigger(i);
				end

				-- Update localisation tables.
				L["TriggerClasses"][data["Type"]]["Name"] = data["Name"];
				L["TriggerClasses"][data["Type"]]["Tooltip"] = data["Tooltip"];
			else
				self:PrintInfo("Custom trigger '%s' skipped: Already exists.",
					data["Type"]);
			end
		end
	end
end

--- Loads a custom trigger, refreshing any existing custom trigger class.
-- @param i The trigger index.
function PowerAuras:ReloadCustomTrigger(i)
	-- Get the class.
	local data = self:CopyTable(self.GlobalSettings["Triggers"][i]);
	local class = self:GetTriggerClass(data["Type"]);

	-- Copy over events/parameter/services tables.
	class.Events = data["Events"];
	class.Parameters = data["Parameters"];
	class.Services = data["Services"];
	class.ServiceMirrors = {};

	-- Service mirrors can't be configured, they'll always point to
	-- TriggerData.
	for _, int in self:IterServiceInterfaces() do
		class.ServiceMirrors[int] = "TriggerData";
	end

	-- Properly load the event filter functions.
	for event, filter in pairs(class.Events) do
		local state, func = pcall(self.Loadstring, self, filter);
		if(state) then
			-- Function is valid.
			class.Events[event] = func;
		elseif(type(filter) == "string" and filter:find("%s")) then
			-- If we find a space in the filter, then assume it was
			-- a lua function and print the error.
			self:PrintError(
				"Failed to load event filter '%s': %s", event, func
			);
		else
			-- Otherwise it was a type name/set.
			class.Events[event] = (filter == true
				and data["Type"]
				or filter);
		end
	end

	-- Generate the dependency functions.
	for depType, deps in pairs(data["Dependencies"]) do
		-- Is the dependency count == 0?
		if(self:CountPairs(deps, 1) == 0) then
			break;
		end

		-- Are the dependencies just static ID's, or param refs?
		local static = true;
		for dep, _ in pairs(deps) do
			if(type(dep) == "string") then
				static = false;
				break;
			end
		end

		-- Static?
		local funcName = ("Get%sDependencies"):format(depType);
		if(static) then
			-- Simple function wrapper.
			class[funcName] = function(self)
				return deps;
			end
		else
			-- Not so simple function wrapper.
			class[funcName] = function(self, params)
				-- Create new table.
				local t = {};
				for dep, _ in pairs(deps) do
					-- Add parameter/ID deps to the table.
					if(type(dep) == "string") then
						t[params[dep] or -1] = true;
					else
						t[dep] = true;
					end
				end
				-- Return table.
				return t;
			end
		end
	end

	-- Generate the flag functions.
	if(data["Timed"] or data["ToggleTimed"]) then
		local timed, toggle = data["Timed"], data["ToggleTimed"];
		function class:IsTimed() return timed, toggle; end
	end
	if(not data["Lazy"]) then
		function class:SupportsLazyChecks() return false; end
	end

	-- Generate the trigger editor.
	function class:CreateTriggerEditor(frame, ...)
		-- Iterate over editor controls and create them.
		for i = 1, #(data["Editor"]) do
			local ctrl = data["Editor"][i];
			if(EditorControls[ctrl["Type"]]) then
				EditorControls[ctrl["Type"]](ctrl, frame, ...);
			end
		end
	end

	-- Class will always have a store.
	function class:InitialiseDataStore()
		return {};
	end

	-- Add the trigger constructor.
	local state, func = pcall(self.Loadstring, self, data["New"]);
	if(not state) then
		self:PrintError("Failed to load constructor: %s", func);
	else
		class["New"] = func;
	end
end