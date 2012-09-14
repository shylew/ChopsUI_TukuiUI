-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Loads the passed trigger.
-- @param data       The trigger definition to load.
-- @param id         The ID of the action that owns this trigger.
-- @param actionData Reference to the data table the action is using. Inserts
--                   things like dependencies and types into this table.
function PowerAuras:LoadTrigger(data, id, actionData)
	-- Attempt to load the trigger.
	if(not self:HasTriggerClass(data["Type"])) then
		self:LogResourceMessage(1, "Trigger", id, "MissingClass", data["Type"]);
		return false;
	end

	-- Get class data.
	local class = self:GetTriggerClass(data["Type"]);
	local params = data["Parameters"];

	-- Modify the action data table.
	actionData["Classes"][data["Type"]] = true;
	actionData["Types"][class:GetTriggerType(params)] = true;
	actionData["Timed"] = (actionData["Timed"] or class:IsTimed(params));
	tinsert(actionData["PerTimed"], (class:IsTimed(params)) or false);
	tinsert(actionData["Stores"], class:InitialiseDataStore(params) or false);

	-- Lazy rechecks, yay or nay?
	if(class:SupportsLazyChecks(params)) then
		tinsert(actionData["Lazy"], class:GetTriggerType(params));
	else
		tinsert(actionData["Lazy"], false);
	end

	-- Action dependencies.
	local deps = class:GetActionDependencies(params);
	if(deps) then
		for action, _ in pairs(deps) do
			actionData["Actions"][action] = true;
		end
	end

	-- Display dependencies.
	local deps = class:GetDisplayDependencies(params);
	if(deps) then
		for display, _ in pairs(deps) do
			actionData["Displays"][display] = true;
		end
	end

	-- Does the class need a provider?
	local state, provider;
	local services = class:GetRequiredServices();
	if(services and next(services)) then
		-- Validate the provider has been loaded.
		local pid = data["Provider"];
		if(not self:HasAuraProvider(pid)) then
			self:LogResourceMessage(1, "Trigger", id, "MissingProvider", pid);
			return false;
		elseif(not self:IsProviderLoaded(pid)) then
			-- Try to load the provider.
			if(not self:LoadProvider(pid)) then
				self:LogResourceMessage(1, "Trigger", id, "DependencyFailed",
					"Provider", pid);
				return false;
			end
		end
		-- Store the provider ID in the action data table.
		actionData["Providers"][pid] = true;
		provider = self:GetLoadedProvider(pid);
	end

	-- Generate function.
	local state, func = pcall(class.New, class, params, id, provider);
	if(not state) then
		self:LogResourceMessage(1, "Trigger", id, "Error", func);
	else
		self:LogResourceMessage(3, "Trigger", id, "Loaded");
	end

	-- Strip trailing whitespace/newlines if a string was returned.
	if(state and type(func) == "string") then
		func = func:gsub("^[%s\n\r]*", ""):gsub("[%s\n\r]*$", "");
	end

	return state, func;
end