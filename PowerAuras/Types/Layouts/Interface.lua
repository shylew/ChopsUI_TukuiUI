-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Dictionary containing all registered layout classes.
local LayoutClasses = {};

--- Returns the named layout class, or throws an error if it doesn't exist.
-- @param name The name of the class.
function PowerAuras:GetLayoutClass(name)
	return LayoutClasses[name] or error(L("ErrorLayoutClassMissing", name));
end

--- Returns the table of registered classes for this type.
function PowerAuras:GetLayoutClasses()
	return LayoutClasses;
end

--- Returns a boolean based on whether or not the named layout class
--  exists.
-- @param name The name of the class.
function PowerAuras:HasLayoutClass(name)
	return not not LayoutClasses[name];
end

do
	--- Base class definition for actions. Doesn't implement all methods
	--  of the interface, only the boilerplate/tedious ones.
	local baseClass = {};
	local baseMetatable = { __index = baseClass };

	--- Creates the controls necessary for editing the layout parameters
	--  of a display.
	-- @param frame The frame to assign controls to.
	-- @param ...   The ID's to use for Get/SetParameter calls.
	function baseClass:CreateDisplayEditor(frame, ...)
		-- Default (NYI) implementation is...Well, a NYI message.
		local label = PowerAuras:Create("Label", frame);
		label:SetRelativeWidth(1.0);
		label:SetJustifyH("CENTER");
		label:SetJustifyV("MIDDLE");
		label:SetText("Layout editor for this display is not yet implemented.");
		frame:AddWidget(label);
	end

	--- Creates the controls necessary for editing layout parameters.
	-- @param frame The frame to assign controls to.
	-- @param ...   The ID's to use for Get/SetParameter calls.
	function baseClass:CreateLayoutEditor(frame, ...)
	end

	--- Creates a preview of the layout for the workspace.
	-- @param frame The frame to play around with.
	-- @param id    The ID of the layout.
	function baseClass:CreatePreview(frame, id)
	end

	--- Returns the default parameter dictionary for use with new instances
	--  of a display class.
	function baseClass:GetDefaultDisplayParameters()
		return self.DisplayParameters;
	end

	--- Returns the default parameter dictionary for use with new instances
	--  of the layout class.
	function baseClass:GetDefaultLayoutParameters()
		return self.LayoutParameters;
	end

	--- Returns the anchoring data for a moveable/parentable display.
	-- @param id The ID of the display.
	-- @return The parent, anchor/relative points and x/y offsets.
	function baseClass:GetDisplayAnchor(id)
	end

	--- Returns a dictionary of parameter names that are ID numbers to other
	--  resources.
	-- @param params The parameters of the resource.
	-- @param out    The table to fill.
	function baseClass:GetIDParameters(params, out)
	end

	--- Returns the ID of any parent aura display used by the passed display.
	--  If the display does not depend upon another display for anchoring,
	--  this should return nil. The ID should be a valid display, so validation
	--  must take place within the implementation.
	-- @param display The display widget to get the parent of.
	function baseClass:GetParentDisplay(display)
		return nil;
	end

	--- Returns true if displays attached to this layout can have positioning
	--  or anchoring data.
	function baseClass:IsDisplayMoveable()
		return false;
	end

	--- Returns true if displays attached to this layout can be attached to
	--  parent displays.
	function baseClass:IsDisplayParentable()
		return false;
	end

	--- Called when a provider on a display owned by this layout is updated.
	--  Not called if SupportsProvider returns false for all providers on
	--  the display.
	function baseClass:OnProviderUpdate()
	end

	--- Positions a display within the preview frame of the layout.
	-- @param frame The frame to play around with.
	-- @param id    The ID of the display.
	function baseClass:PositionDisplayPreview(frame, id)
	end

	--- Sets the anchor of a display. This is intended to be used by the
	--  editor for the workspace drag/drop movement of displays.
	-- @param id     The ID of the display.
	-- @param point  The anchor point of the display.
	-- @param parent The parent display ID, or nil if no parent.
	-- @param rel    The relative point of the display.
	-- @param x      The X offset of a display.
	-- @param y      The Y offset of a display.
	function baseClass:SetDisplayAnchor(id, point, parent, rel, x, y)
	end

	--- Returns true if the display instance supports updates in response to
	--  providers being updated. Defaults to false.
	-- @param display  The ID of the display.
	-- @param provider The provider instance on the display.
	function baseClass:SupportsProvider(display, provider)
		return false;
	end

	--- Registers a new layout class.
	-- @param name  The name of the class.
	-- @param class The class to register. If nil, the table is created.
	function PowerAuras:RegisterLayoutClass(name, class)
		-- Name collision check.
		if(self:HasLayoutClass(name)) then
			error(L("ErrorLayoutClassExists", name));
		end
		-- Register and return class table.
		LayoutClasses[name] = setmetatable(class or {}, baseMetatable);
		return LayoutClasses[name];
	end
end

--- Validates the specified layout class, making sure it has all required
--  fields.
-- @param name The class to be validated.
function PowerAuras:ValidateLayoutClass(name)
	-- Get and validate.
	local class = self:GetLayoutClass(name);
	if(type(class.ActivateDisplay) ~= "function"
		or type(class.CreateDisplayEditor) ~= "function"
		or type(class.CreateLayoutEditor) ~= "function"
		or type(class.CreatePreview) ~= "function"
		or type(class.DeactivateDisplay) ~= "function"
		or type(class.GetDefaultDisplayParameters) ~= "function"
		or type(class.GetDefaultLayoutParameters) ~= "function"
		or type(class.GetDisplayAnchor) ~= "function"
		or type(class.GetIDParameters) ~= "function"
		or type(class.GetParentDisplay) ~= "function"
		or type(class.IsDisplayMoveable) ~= "function"
		or type(class.IsDisplayParentable) ~= "function"
		or type(class.New) ~= "function"
		or type(class.OnProviderUpdate) ~= "function"
		or type(class.PositionDisplayPreview) ~= "function"
		or type(class.RegisterDisplay) ~= "function"
		or type(class.SetDisplayAnchor) ~= "function"
		or type(class.SupportsProvider) ~= "function"
		or type(class.UnregisterDisplay) ~= "function"
		or type(class.UpgradeDisplay) ~= "function"
		or type(class.UpgradeLayout) ~= "function"
		or type(class:GetDefaultDisplayParameters()["ID"]) ~= "nil") then
		-- Invalid class. Deregister.
		LayoutClasses[name] = nil;
		return false, L("ErrorLayoutClassInvalid", name);
	end
	-- All is fine.
	return true;
end