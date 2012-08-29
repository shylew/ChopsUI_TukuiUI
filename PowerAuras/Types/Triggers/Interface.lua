-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Dictionary containing all registered trigger classes.
local TriggerClasses = {};

--- Returns the named trigger class, or throws an error if it doesn't exist.
-- @param name The name of the class.
function PowerAuras:GetTriggerClass(name)
	return TriggerClasses[name] or error(L("ErrorTriggerClassMissing", name));
end

--- Returns the table of registered classes for this type.
function PowerAuras:GetTriggerClasses()
	return TriggerClasses;
end

do
	--- Sort comparison function.
	-- @param a First item to compare.
	-- @param b Second item to compare.
	local function sort(a, b)
		-- Compare the localised string names.
		return L["TriggerClasses"][a]["Name"] < L["TriggerClasses"][b]["Name"];
	end

	--- Iterator function.
	-- @param t The table to iterate over.
	-- @param i The current index.
	local function iter(t, i)
		i = (i or 0) + 1;
		if(t[i]) then
			return i, t[i], L["TriggerClasses"][t[i]]["Name"];
		end
	end

	--- Returns a sorted iterator for accessing all trigger classes in
	--  alphabetical order.
	function PowerAuras:IterTriggerClasses()
		-- Create our storage table, fill with class names.
		local t = self:ListKeys(TriggerClasses);
		-- Sort them.
		table.sort(t, sort);
		-- Return the iterator.
		return iter, t, 0;
	end
end

--- Returns a boolean based on whether or not the named trigger class
--  exists.
-- @param name The name of the class.
function PowerAuras:HasTriggerClass(name)
	return not not TriggerClasses[name];
end

do
	--- Base class definition for triggers. Doesn't implement all methods
	--  of the interface, only the boilerplate/tedious ones.
	local baseClass = {};
	local baseMetatable = { __index = baseClass };

	--- Converts trigger parameters to those used by a service.
	-- @param int    The service interface to convert to.
	-- @param tp     The trigger parameters to convert/copy.
	-- @param out    The output parameter table to modify.
	-- @param action The ID of the action for this trigger.
	-- @param index  The index of the trigger.
	-- @return True on success, false if an unsupported conversion is done.
	function baseClass:ConvertToService(int, tp, out, action, index)
		-- Default implementation is available for this. Just define
		-- a table in the class: ServiceMirrors.
		if(not self.ServiceMirrors or not self.ServiceMirrors[int]) then
			-- Undefined.
			return false;
		end

		-- Is there an override converter for this class?
		local name = self.ServiceMirrors[int];
		local class = PowerAuras:GetServiceClassImplementation(name, int);
		if(class:CanCreateFromTrigger(action, index)) then
			return class:CreateFromTrigger(tp, out, action, index);
		end

		-- Copy service defaults into output.
		local defaults = class:GetDefaultParameters();
		for k, v in pairs(defaults) do
			out[k] = (type(v) == "table" and PowerAuras:CopyTable(v) or v);
		end

		-- Now copy trigger params over.
		for k, v in pairs(tp) do
			if(defaults[k] ~= nil) then
				out[k] = (type(v) == "table" and PowerAuras:CopyTable(v) or v);
			end
		end

		-- Done.
		return true;
	end

	--- Creates the controls for the basic trigger editor frame.
	-- @param frame The frame to apply controls to.
	function baseClass:CreateTriggerEditor(frame)
		-- Default to a giant label.
		local label = PowerAuras:Create("Label", frame);
		label:SetText("Editor for this trigger is not yet implemented.");
		label:SetRelativeSize(1.0, 0.75);
		label:SetJustifyH("CENTER");
		label:SetJustifyV("MIDDLE");
		frame:AddWidget(label);
	end

	--- Returns a dictionary of the dependencies upon other actions that this
	--  trigger will have if constructed. The dictionary should use action ID
	--  numbers as the key and boolean true as the value.
	-- @param params The parameters of the trigger.
	function baseClass:GetActionDependencies(params)
		return nil;
	end

	--- Returns the default parameter dictionary for use with new instances
	--  of the class.
	function baseClass:GetDefaultParameters()
		return self.Parameters;
	end

	--- Returns a dictionary of the dependencies upon other displays that this
	--  trigger will have if constructed. The dictionary should use action ID
	--  numbers as the key and boolean true as the value.
	-- @param params The parameters of the trigger.
	function baseClass:GetDisplayDependencies(params)
		return nil;
	end

	--- Returns a dictionary of parameter names that are ID numbers to other
	--  resources.
	-- @param params The parameters of the resource.
	-- @param out    The table to fill.
	function baseClass:GetIDParameters(params, out)
		-- Automatically handle this if at all possible.
		local actions = self:GetActionDependencies(params);
		if(actions) then
			for param, _ in pairs(actions) do
				out[param] = "Action";
			end
		end
		-- Same for displays.
		local displays = self:GetDisplayDependencies(params);
		if(displays) then
			for param, _ in pairs(displays) do
				out[param] = "Display";
			end
		end
	end

	--- Returns a dictionary of events to register if the service class is
	--  instantiated. The keys should be event names like "UNIT_AURA", and the
	--  value should be a function that returns a trigger type name to be
	--  rechecked.
	function baseClass:GetEventFilters()
		return self.Events;
	end

	--- Returns a dictionary of the required data provider services that must
	--  be instantiated before the trigger is created. May return an empty
	--  dictionary if no services are required. The key should be the service
	--  type required, like "Timer".
	function baseClass:GetRequiredServices()
		return self.Services;
	end

	--- Returns a trigger type name that is used for identifying what needs
	--  rechecking in response to events. This is normally the same as the
	--  class name, but may be more specific for performance reasons.
	-- @param params The parameters of the trigger.
	function baseClass:GetTriggerType(params)
		return self.ClassName;
	end

	--- Initialises the per-trigger data store. This can be used to hold
	--  values which can then be exposed to other parts of the system.
	-- @param params The parameters of this trigger.
	-- @return An item to store, or nil.
	function baseClass:InitialiseDataStore(params)
		return nil;
	end

	--- Returns true if the trigger is considered a 'support' trigger and can
	--  be shown as an additional trigger option within the simple activation
	--  editor.
	function baseClass:IsSupportTrigger()
		return false;
	end

	--- Returns true if the trigger requires a recheck every frame. Only true
	--  if the trigger is time-related.
	-- @param params The parameters of the trigger.
	-- @return The first value is the default timed state on creation. The 
	--         second boolean is whether or not the timed status is capable of
	--         being toggled by the trigger.
	function baseClass:IsTimed(params)
		return false, false;
	end

	--- Return true if the trigger supports lazy checks. Lazy triggers
	--  require that their individual trigger type be flagged for a recheck
	--  before being re-processed within an already-flagged action.
	--  Returns false by default if this trigger has dependencies, or is timed.
	function baseClass:SupportsLazyChecks(params)
		-- Do we have dependencies?
		local deps = self:GetActionDependencies(params);
		if(deps and next(deps)) then
			return false;
		end
		deps = self:GetDisplayDependencies(params);
		if(deps and next(deps)) then
			return false;
		end
		-- Requires a provider?
		deps = self:GetRequiredServices();
		if(deps and next(deps)) then
			return false;
		end
		-- Finally, is timed?
		local timed, toggle = self:IsTimed(params);
		return not timed and not toggle;
	end

	--- Checks if this trigger supports any service conversions.
	-- @param int The interface to try to convert to.
	-- @return The name of the mirrored class to convert to on success.
	--         Nil on failure.
	function baseClass:SupportsServiceConversion(int)
		return self.ServiceMirrors and self.ServiceMirrors[int];
	end

	--- Registers a new trigger class.
	-- @param name  The name of the class.
	-- @param class The class to register. If nil, the table is created.
	function PowerAuras:RegisterTriggerClass(name, class)
		-- Name collision check.
		if(self:HasTriggerClass(name)) then
			error(L("ErrorTriggerClassExists", name));
		end
		-- Register and return class table.
		TriggerClasses[name] = setmetatable(class or {}, baseMetatable);
		TriggerClasses[name].ClassName = name;
		return TriggerClasses[name];
	end
end

--- Validates the specified trigger class, making sure it has all required
--  fields.
-- @param name The class to be validated.
function PowerAuras:ValidateTriggerClass(name)
	-- Get and validate.
	local class = self:GetTriggerClass(name);
	if(type(class.ConvertToService) ~= "function"
		or type(class.CreateTriggerEditor) ~= "function"
		or type(class.GetActionDependencies) ~= "function"
		or type(class.GetDefaultParameters) ~= "function"
		or type(class.GetDisplayDependencies) ~= "function"
		or type(class.GetEventFilters) ~= "function"
		or type(class.GetIDParameters) ~= "function"
		or type(class.GetRequiredServices) ~= "function"
		or type(class.GetTriggerType) ~= "function"
		or type(class.InitialiseDataStore) ~= "function"
		or type(class.IsSupportTrigger) ~= "function"
		or type(class.IsTimed) ~= "function"
		or type(class.New) ~= "function"
		or type(class.SupportsLazyChecks) ~= "function"
		or type(class.SupportsServiceConversion) ~= "function"
		or type(class.Upgrade) ~= "function") then
		-- Invalid class. Deregister.
		TriggerClasses[name] = nil;
		return false, L("ErrorTriggerClassInvalid", name);
	end
	-- All is fine.
	return true;
end