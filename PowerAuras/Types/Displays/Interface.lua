-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Dictionary containing all registered display classes.
local DisplayClasses = {};

--- Declarations for things defined later on.
local BaseClass, BaseMetatable;

--- Returns the named display class, or throws an error if it doesn't exist.
-- @param name The name of the class.
function PowerAuras:GetDisplayClass(name)
	return DisplayClasses[name] or error(L("ErrorDisplayClassMissing", name));
end

--- Returns the table of registered classes for this type.
function PowerAuras:GetDisplayClasses()
	return DisplayClasses;
end

--- Returns a boolean based on whether or not the named display class
--  exists.
-- @param name The name of the class.
function PowerAuras:HasDisplayClass(name)
	return not not DisplayClasses[name];
end

do
	--- Sort comparison function.
	-- @param a First item to compare.
	-- @param b Second item to compare.
	local function sort(a, b)
		-- Compare the localised string names.
		return L["DisplayClasses"][a]["Name"] < L["DisplayClasses"][b]["Name"];
	end

	--- Iterator function.
	-- @param t The table to iterate over.
	-- @param i The current index.
	local function iter(t, i)
		i = (i or 0) + 1;
		if(t[i]) then
			return i, t[i], L["DisplayClasses"][t[i]]["Name"];
		end
	end

	--- Returns a sorted iterator for accessing all display classes in
	--  alphabetical order.
	function PowerAuras:IterDisplayClasses()
		-- Create our storage table, fill with class names.
		local t = self:ListKeys(DisplayClasses);
		-- Sort them.
		table.sort(t, sort);
		-- Return the iterator.
		return iter, t, 0;
	end
end

--- Registers a new display class.
-- @param name  The name of the class.
-- @param class The class to register. If nil, the table is created.
function PowerAuras:RegisterDisplayClass(name, class)
	-- Name collision check.
	if(self:HasDisplayClass(name)) then
		error(L("ErrorDisplayClassExists", name));
	end
	-- Register and return class table.
	DisplayClasses[name] = setmetatable(class or {}, BaseMetatable);
	return DisplayClasses[name];
end

--- Validates the specified display class, making sure it has all required
--  fields.
-- @param name The class to be validated.
function PowerAuras:ValidateDisplayClass(name)
	-- Get and validate.
	local class = self:GetDisplayClass(name);
	for field, fieldType in pairs(BaseClass) do
		-- If the expected type isn't a string, make it one.
		if(type(fieldType) ~= "string") then
			fieldType = type(fieldType);
		end
		-- Check for field.
		if(type(class[field]) ~= fieldType) then
			-- Invalid class. Deregister.
			DisplayClasses[name] = nil;
			return false, L(
				"ErrorDisplayClassInvalid",
				name, field, type(class[field]), fieldType
			);
		end
	end
	-- All is fine.
	return true;
end

--------------------------------------------------------------------------------
-- Base Class Table
--------------------------------------------------------------------------------

--- Base display class definition.
BaseClass = {
	-- Define required fields/methods here.
	ApplyAction          = "function",
	CreatePreview        = "function",
	CreateStyleEditor    = "function",
	GetActionDefaults    = "function",
	GetAllServices       = "function",
	GetDefaultParameters = "function",
	GetOptionalServices  = "function",
	GetRequiredServices  = "function",
	IsActionSupported    = "function",
	New                  = "function",
	SupportsAnimation    = "function",
	Upgrade              = "function",
};

-- Reusable metatable for the class.
BaseMetatable = { __index = BaseClass };

--- Applies an action to an instance of the display class.
-- @param display The display instance itself.
-- @param action  The action class name, such as "DisplayColor".
-- @param ...     Sequence parameters of the action.
function BaseClass:ApplyAction(action, display, ...)
end

--- Creates a static preview of a display for use with the editor.
-- @param frame The frame to attach the preview to.
-- @param id    The ID of the display to preview.
function BaseClass:CreatePreview(frame, id)
	-- Default display consists of a temp icon and an NYI label.
	if(not frame.Icon) then
		frame.Icon = frame:CreateTexture(nil, "ARTWORK");
		frame.Icon:SetAllPoints(true);
		frame.Icon:SetTexture(PowerAuras.DefaultIcon);
		frame.Icon:SetAlpha(0.4);
		frame.Icon:SetDesaturated(true);
	end
	if(not frame.Text) then
		frame.Text = frame:CreateFontString(nil, "OVERLAY");
		frame.Text:SetAllPoints(true);
		frame.Text:SetFontObject(GameFontNormalHuge);
		frame.Text:SetJustifyH("CENTER");
		frame.Text:SetJustifyV("MIDDLE");
		frame.Text:SetText("NYI");
	end
end

--- Returns a table of default sequence parameters to pass to ApplyAction
--  in the event that no sequence is activated. May return nil.
-- @param action  The action class name, such as "DisplayColor".
-- @param display The display instance itself.
function BaseClass:GetActionDefaults(action, display)
end

--- Returns a table of all the required and optional service interfaces.
function BaseClass:GetAllServices()
	-- This table is generated on demand.
	if(not self.AllServices) then
		self.AllServices = {};
		for int, _ in pairs(self:GetOptionalServices()) do
			self.AllServices[int] = false;
		end
		for int, _ in pairs(self:GetRequiredServices()) do
			self.AllServices[int] = true;
		end
	end
	return self.AllServices;
end

--- Returns the default parameter dictionary for use with new instances
--  of the class.
function BaseClass:GetDefaultParameters()
	return self.Parameters;
end

--- Returns a dictionary of optional data provider services that the
--  display class also supports. May return an empty dictionary. The key
--  should be the service type supported, like "Timer".
function BaseClass:GetOptionalServices()
	return self.OptServices;
end

--- Returns a dictionary of the required data provider services that must
--  be instantiated before the display is created. May return an empty
--  dictionary if no services are required. The key should be the service
--  type required, like "Timer".
function BaseClass:GetRequiredServices()
	return self.Services;
end

--- Returns a boolean based on whether or not the passed action type is
--  supported by this class.
-- @param type The type of action to check support for.
function BaseClass:IsActionSupported(type)
	return not not self.Actions[type];
end

--- Returns true if the display class supports animations.
function BaseClass:SupportsAnimation()
	return false;
end