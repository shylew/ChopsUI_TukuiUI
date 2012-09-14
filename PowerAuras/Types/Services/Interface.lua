-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Dictionary containing all registered service classes.
local ServiceClasses = {};

--- Dictionary containing all provider service interfaces. These interfaces
--  implicitly inherit our standard service interface.
local ServiceInterfaces = {};

--- Converts an index to an interface type name.
-- @param index The numeric index to convert.
function PowerAuras:GetInterfaceFromIndex(index)
	local i = 1;
	for int, _ in self:ByKey(self:GetServiceInterfaces()) do
		if(i == index) then
			return int;
		end
		i = i + 1;
	end
end

--- Returns the requested service class if it exists. Throws an error
--  on failure.
-- @param name The name of the class.
function PowerAuras:GetServiceClass(name)
	return ServiceClasses[name]
		or error(L("ErrorServiceClassMissing", name));
end

--- Returns the table of registered classes for this type.
function PowerAuras:GetServiceClasses()
	return ServiceClasses;
end

--- Returns an interface implementation for the specified service class if
--  it exists. Throws an error if the class/interface do not exist.
-- @param name      The name of the class.
-- @param interface The name of the interface.
function PowerAuras:GetServiceClassImplementation(name, interface)
	if(not self:HasServiceClass(name)) then
		error(L("ErrorServiceClassMissing", name));
	elseif(not self:HasServiceClassImplemented(name, interface)) then
		error(L("ErrorServiceInterfaceMissing", interface));
	else
		return ServiceClasses[name][interface];
	end
end

--- Returns the requested service interface if it exists. Throws an error
--  on failure.
-- @param name The name of the interface.
function PowerAuras:GetServiceInterface(name)
	return ServiceInterfaces[name]
		or error(L("ErrorServiceInterfaceMissing", name));
end

--- Returns the table of registered service interface types.
function PowerAuras:GetServiceInterfaces()
	return ServiceInterfaces;
end

--- Checks if the specified service class implements all of the specified
--  interfaces.
-- @param name The name of the class.
-- @param ...  The interfaces to check for.
function PowerAuras:HasServiceClassImplemented(name, ...)
	-- If the service class doesn't exist, then obviously it can't implement
	-- anything.
	if(not self:HasServiceClass(name)) then
		return false;
	end
	-- Go over interfaces.
	for i = 1, select("#", ...) do
		local interface = select(i, ...);
		if(not self:HasServiceInterface(interface)
			or not ServiceClasses[name][interface]) then
			-- Either the interface doesn't exist or it isn't implemented.
			return false;
		end
	end
	-- Success if we get here.
	return true;
end

--- Checks if the specified service class is registered.
-- @param name The name of the class.
function PowerAuras:HasServiceClass(name)
	return not not ServiceClasses[name];
end

--- Checks if the specified service interface is registered.
-- @param name The name of the interface.
function PowerAuras:HasServiceInterface(name)
	return not not ServiceInterfaces[name];
end

do
	--- Sort comparison function.
	-- @param a First item to compare.
	-- @param b Second item to compare.
	local function sort(a, b)
		-- Compare the localised string names.
		return L["ServiceClasses"][a]["Name"] < L["ServiceClasses"][b]["Name"];
	end

	--- Iterator function.
	-- @param t The table to iterate over.
	-- @param i The current index.
	local function iter(t, i)
		i = (i or 0) + 1;
		if(t[i]) then
			return i, t[i], L["ServiceClasses"][t[i]]["Name"];
		end
	end

	--- Returns a sorted iterator for accessing all service classes in
	--  alphabetical order.
	function PowerAuras:IterServiceClasses()
		-- Create our storage table, fill with class names.
		local t = self:ListKeys(ServiceClasses);
		-- Sort them.
		table.sort(t, sort);
		-- Return the iterator.
		return iter, t, 0;
	end
end

do
	--- Sort comparison function.
	-- @param a First item to compare.
	-- @param b Second item to compare.
	local function sort(a, b)
		-- Compare the localised string names.
		return L["ServiceInterfaces"][a] < L["ServiceInterfaces"][b];
	end

	--- Iterator function.
	-- @param t The table to iterate over.
	-- @param i The current index.
	local function iter(t, i)
		i = (i or 0) + 1;
		if(t[i]) then
			return i, t[i], L["ServiceInterfaces"][t[i]];
		end
	end

	--- Returns a sorted iterator for accessing all service interfaces in
	--  alphabetical order.
	function PowerAuras:IterServiceInterfaces()
		-- Create our storage table, fill with class names.
		local t = self:ListKeys(ServiceInterfaces);
		-- Sort them.
		table.sort(t, sort);
		-- Return the iterator.
		return iter, t, 0;
	end
end

do
	--- Storage table for the return value.
	local varStore = {};

	--- Cache for metatables to reduce table creation.
	local mtCache = {};

	--- Registers a service class with the specified interfaces.
	-- @param name  The name of the service to register.
	-- @param types Comma separated list of interfaces to implement.
	-- @param class The class to register. If nil, the table is created.
	-- @return A class table for each interface in order.
	function PowerAuras:RegisterServiceImplementation(name, types, class)
		wipe(varStore);
		-- Add service class to list if needed.
		ServiceClasses[name] = ServiceClasses[name] or {};
		local serviceHost = ServiceClasses[name];
		-- Iterate over each type in order.
		for match in types:gmatch("%s*([^,]+)%s*") do
			-- Is this interface already implemented?
			if(self:HasServiceClassImplemented(match)) then
				error(L("ErrorServiceImplemented", name, match));
			end
			-- Get the interface metatable.
			local interface = mtCache[match];
			if(not interface) then
				interface = { __index = self:GetServiceInterface(match) };
				mtCache[match] = interface;
			end
			-- Add to service class.
			serviceHost[match] = setmetatable(class or {}, interface);
			tinsert(varStore, serviceHost[match]);
		end
		return unpack(varStore);
	end
end

do
	--- Base class definition for data services. Doesn't implement all methods
	--  of the interface, only the boilerplate/tedious ones.
	local baseClass = {};
	local baseMetatable = { __index = baseClass };

	--- Returns true if this service can be created from a trigger. This is
	--  an override that takes precedence over trigger -> source conversions.
	-- @param id     The ID of the action for the trigger.
	-- @param index  The index of the trigger.
	-- @return True if supported, false if not.
	function baseClass:CanCreateFromTrigger(id, index)
		return false;
	end

	--- Performs a trigger to source conversion.
	-- @param tp    The trigger parameters to convert/copy.
	-- @param out   The output parameter table to modify.
	-- @param id    The ID of the action for this trigger.
	-- @param index The index of the trigger.
	-- @return True on success, false if an unsupported conversion is done.
	function baseClass:CreateFromTrigger(tp, out, id, index)
		return false;
	end

	--- Creates the parameter editor frame for this implemenation.
	-- @param frame The frame to add widgets to.
	-- @param ...   ID's to use for Get/SetParameter calls.
	function baseClass:CreateEditor(frame, ...)
		-- Add a NYI label.
		local label = PowerAuras:Create("Label", frame);
		label:SetRelativeWidth(1.0);
		label:SetFontObject(GameFontNormalLarge);
		label:SetText("Service editor for this class is not yet implemented.");
		frame:AddWidget(label);
		frame:AddVerticalFill();
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
	end

	--- Describes whether or not this service is 'static'. Static services
	--  respond to no events and don't require updating, as their returned
	--  value doesn't change. If all services in a provider are static, then
	--  processing load can be reduced.
	-- @return True if the service is static. False if not.
	function baseClass:IsStaticService()
		return false;
	end


	--- Returns a dictionary of events to register if the service class is
	--  instantiated. The keys should be event names like "UNIT_AURA", and 
	--  the value should just be boolean true.
	function baseClass:GetEventFilters()
		return self.Events;
	end

	--- Registers a service class interface. Service classes are split into
	--  interfaces that define certain characteristics about how the service
	--  operates, for processing.
	-- @param name  The name of the interface.
	-- @param class The class to register. If nil, the table is created.
	function PowerAuras:RegisterServiceInterface(name, class)
		-- Name collision check.
		if(self:HasServiceInterface(name)) then
			error(L("ErrorServiceInterfaceExists", name));
		end
		-- Register and return.
		ServiceInterfaces[name] = setmetatable(class or {}, baseMetatable);
		return ServiceInterfaces[name];
	end
end

--- Validates the named service class, checking to see if all required
--  methods have been implemented.
-- @param name The name of the class to validate.
function PowerAuras:ValidateServiceClass(name)
	-- Validate the services the class provides.
	local class = self:GetServiceClass(name);
	for interface, service in pairs(class) do
		if(type(service.IsStaticService) ~= "function"
			or type(service.CanCreateFromTrigger) ~= "function"
			or type(service.CreateEditor) ~= "function"
			or type(service.CreateFromTrigger) ~= "function"
			or type(service.GetActionDependencies) ~= "function"
			or type(service.GetDefaultParameters) ~= "function"
			or type(service.GetDefaultValues) ~= "function"
			or type(service.GetEventFilters) ~= "function"
			or type(service.GetIDParameters) ~= "function"
			or type(service.GetReturnCount) ~= "function"
			or type(service.New) ~= "function"
			or type(service.Upgrade) ~= "function") then
			-- Invalid class. Deregister.
			ServiceClasses[name] = nil;
			return false, L("ErrorServiceClassInvalid", name, interface);
		end
	end
	-- All is fine.
	return true;
end