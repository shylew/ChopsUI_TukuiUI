-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Dictionary containing all action classes.
local ActionClasses = {};

--- Populates the reflector debug frame with the necessary widgets.
-- @param frame The frame to populate. This is a LayoutHost type widget.
-- @param id    The ID of the selected action.
function PowerAuras:CreateActionReflectorHost(frame, id)
	-- Verify the action exists.
	if(not self:HasAuraAction(id)) then
		return;
	end
	-- Get data tables.
	local actionVars = self:GetAuraAction(id);
	local isLoaded = self:IsActionLoaded(id);
	local actionData;
	if(isLoaded) then
		actionData = self:GetLoadedActionData(id);
	end
	-- Add status label.
	local status = PowerAuras:Create("Label", frame);
	if(isLoaded) then
		status:SetText(("|cFFFFFFFF%s: |r|cFF00FF00%s|r"):format(
			L["Status"], L["Loaded"]
		));
	else
		status:SetText(("|cFFFFFFFF%s: |r|cFFFF0000%s|r"):format(
			L["Status"], L["NotLoaded"]
		));
	end
	-- status:SetJustifyH("LEFT");
	status:SetRelativeWidth(1.0);
	status:SetFixedHeight(26);
	frame:AddWidget(status);
	-- Add an editbox for the generated func string.
	local funcEdit = PowerAuras:Create("CodeBox", frame);
	funcEdit:SetRelativeSize(1.0, 0.9);
	funcEdit:SetFontHeight(13);
	if(isLoaded) then
		funcEdit:SetText(actionData["Function"]);
	elseif(self:GetResourceLog()["Action"][id]) then
		funcEdit:SetText(self:ExportTable(self:GetResourceLog()["Action"][id]));
	else
		funcEdit:SetText("");
	end
	-- funcEdit:Disable();
	frame:AddWidget(funcEdit);
end

--- Returns the named action class, or throws an error if it doesn't exist.
-- @param name The name of the class.
function PowerAuras:GetActionClass(name)
	return ActionClasses[name] or error(L("ErrorActionClassMissing", name));
end

--- Returns the table of registered classes for this type.
function PowerAuras:GetActionClasses()
	return ActionClasses;
end

do
	--- Sort comparison function.
	-- @param a First item to compare.
	-- @param b Second item to compare.
	local function sort(a, b)
		-- Compare the localised string names.
		return L["ActionClasses"][a]["Name"] < L["ActionClasses"][b]["Name"];
	end

	--- Iterator function.
	-- @param t The table to iterate over.
	-- @param i The current index.
	local function iter(t, i)
		i = (i or 0) + 1;
		if(t[i]) then
			return i, t[i], L["ActionClasses"][t[i]]["Name"];
		end
	end

	--- Returns a sorted iterator for accessing all action classes in
	--  alphabetical order.
	function PowerAuras:IterActionClasses()
		-- Create our storage table, fill with class names.
		local t = self:ListKeys(ActionClasses);
		-- Sort them.
		table.sort(t, sort);
		-- Return the iterator.
		return iter, t, 0;
	end
end

--- Returns a boolean based on whether or not the named action class
--  exists.
-- @param name The name of the class.
function PowerAuras:HasActionClass(name)
	return not not ActionClasses[name];
end

do
	--- Base class definition for actions. Doesn't implement all methods
	--  of the interface, only the boilerplate/tedious ones.
	local baseClass = {};
	local baseMetatable = { __index = baseClass };

	--- Constructs the sequence editor for an action.
	-- @param frame The frame to apply widgets to.
	-- @param ...   The ID's to pass to Get/SetParameter calls.
	function baseClass:CreateSequenceEditor(frame, ...)
		-- Temp widgets for NYI editors.
		local label = PowerAuras:Create("Label", frame);
		label:SetRelativeWidth(1.0);
		label:SetJustifyH("CENTER");
		label:SetJustifyV("MIDDLE");
		label:SetText("Sequence editor for this class is not yet implemented.");
		frame:AddWidget(label);
	end

	--- Returns a list of default parameters for use by a newly created trigger
	--  sequence within an existing action.
	function baseClass:GetDefaultParameters()
		return self.Parameters;
	end

	--- Returns a dictionary of parameter names that are ID numbers to other
	--  resources.
	-- @param params The parameters of the resource.
	-- @param out    The table to fill.
	function baseClass:GetIDParameters(params, out)
	end

	--- Returns the number of parameters in the action.
	function baseClass:GetNumParameters()
		return #(self.Parameters);
	end

	--- Returns the target of this action as a string. A target is what the
	--  action is designed to be used with. Valid return values are "Display",
	--  "Animation" and "Standalone".
	function baseClass:GetTarget()
		return "Standalone";
	end

	--- Registers a new action class.
	-- @param name  The name of the class.
	-- @param class The class to register. If nil, the table is created.
	function PowerAuras:RegisterActionClass(name, class)
		-- Name collision check.
		if(self:HasActionClass(name)) then
			error(L("ErrorActionClassExists", name));
		end
		-- Register and return class table.
		ActionClasses[name] = setmetatable(class or {}, baseMetatable);
		return ActionClasses[name];
	end
end

--- Validates the specified action class, making sure it has all required
--  fields.
-- @param name The class to be validated.
function PowerAuras:ValidateActionClass(name)
	-- Get and validate.
	local class = self:GetActionClass(name);
	if(type(class.CreateSequenceEditor) ~= "function"
		or type(class.GetDefaultParameters) ~= "function"
		or type(class.GetIDParameters) ~= "function"
		or type(class.GetNumParameters) ~= "function"
		or type(class.GetTarget) ~= "function"
		or type(class.New) ~= "function"
		or type(class.Upgrade) ~= "function") then
		-- Invalid class. Deregister.
		ActionClasses[name] = nil;
		return false, L("ErrorActionClassInvalid", name);
	end
	-- All is fine.
	return true;
end