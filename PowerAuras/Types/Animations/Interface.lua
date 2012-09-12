-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Collection of possible animation types.
AnimationTypes = {
	Show    = 0,
	Hide    = 1,
	Single  = 2,
	Repeat  = 3,
};

--- Dictionary containing all animation classes.
local AnimationClasses = {};

--- Returns the named animation class, or throws an error if it doesn't exist.
-- @param name The name of the class.
function PowerAuras:GetAnimationClass(name)
	return AnimationClasses[name] or error(L("ErrorAnimClassMissing", name));
end

--- Returns the table of registered classes for this type.
function PowerAuras:GetAnimationClasses()
	return AnimationClasses;
end

do
	--- Sort comparison function.
	-- @param a First item to compare.
	-- @param b Second item to compare.
	local function sort(a, b)
		-- Compare the localised string names.
		return L["AnimationClasses"][a]["Name"] < L["AnimationClasses"][b]["Name"];
	end

	--- Iterator function.
	-- @param t The table to iterate over.
	-- @param i The current index.
	local function iter(t, i)
		i = (i or 0) + 1;
		if(t[i]) then
			return i, t[i], L["AnimationClasses"][t[i]]["Name"];
		end
	end

	--- Returns a sorted iterator for accessing all animation classes in
	--  alphabetical order.
	function PowerAuras:IterAnimationClasses()
		-- Create our storage table, fill with class names.
		local t = self:ListKeys(AnimationClasses);
		-- Sort them.
		table.sort(t, sort);
		-- Return the iterator.
		return iter, t, 0;
	end
end

--- Returns a boolean based on whether or not the named animation class
--  exists.
-- @param name The name of the class.
function PowerAuras:HasAnimationClass(name)
	return not not AnimationClasses[name];
end

do
	--- Base class definition for animations. Doesn't implement all methods
	--  of the interface, only the boilerplate/tedious ones.
	local baseClass = {};
	local baseMetatable = { __index = baseClass };

	--- Creates the controls for the basic animation editor frame.
	-- @param frame The frame to apply controls to.
	function baseClass:CreateAnimationEditor(frame)
		-- Default to a giant label.
		local label = PowerAuras:Create("Label", frame);
		label:SetText("Editor for this animation is not yet implemented.");
		label:SetRelativeSize(1.0, 0.75);
		label:SetJustifyH("CENTER");
		label:SetJustifyV("MIDDLE");
		frame:AddWidget(label);
	end

	--- Returns the default parameter dictionary for use with new instances
	--  of the class.
	function baseClass:GetDefaultParameters()
		return self.Parameters;
	end

	--- Returns a boolean based on whether or not the passed animation type is
	--  supported by this class.
	-- @param type The type of animation to check support for.
	function baseClass:IsTypeSupported(type)
		return not not self.Types[type];
	end

	--- Registers a new animation class.
	-- @param name  The name of the class.
	-- @param class The class to register. If nil, the table is created.
	function PowerAuras:RegisterAnimationClass(name, class)
		-- Name collision check.
		if(self:HasAnimationClass(name)) then
			error(L("ErrorAnimClassExists", name));
		end
		-- Register and return class table.
		AnimationClasses[name] = setmetatable(class or {}, baseMetatable);
		return AnimationClasses[name];
	end
end

--- Validates the specified animation class, making sure it has all required
--  fields.
-- @param name The class to be validated.
function PowerAuras:ValidateAnimationClass(name)
	-- Get and validate.
	local class = self:GetAnimationClass(name);
	if(type(class.CreateAnimationEditor) ~= "function"
		or type(class.GetDefaultParameters) ~= "function"
		or type(class.IsTypeSupported) ~= "function"
		or type(class.New) ~= "function"
		or type(class.Upgrade) ~= "function") then
		-- Invalid class. Deregister.
		AnimationClasses[name] = nil;
		return false, L("ErrorAnimClassInvalid", name);
	end
	-- All is fine.
	return true;
end