-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Layout class definition.
local Fixed = PowerAuras:RegisterLayoutClass("Fixed", {
	--- Dictionary of valid anchor points.
	AnchorPoints = {
		TOPLEFT = true,
		TOP = true,
		TOPRIGHT = true,
		LEFT = true,
		CENTER = true,
		RIGHT = true,
		BOTTOMLEFT = true,
		BOTTOM = true,
		BOTTOMRIGHT = true,
	},
	--- Dictionary of default parameters for each display using this layout.
	DisplayParameters = {
		Anchor = { "CENTER", nil, "CENTER", 0, 0 },
	},
	--- Dictionary of default parameters this layout uses.
	LayoutParameters = {
	},
});

--- Constructs a new instance of the display and returns it.
-- @param id     The ID of the constructed layout.
-- @param params The parameters to construct the display from.
-- @return Returns a table, which is considered to be the instance of the
--         layout. This table will automatically have the class set as its
--         metatable.
function Fixed:New(id, params)
	return {};
end

--- Activates a registered display on the layout. Activated displays can be
--  positioned as needed by the layout, and are considered to be shown/active.
-- @param display The display to activate.
-- @remarks This is an instance method.
function Fixed:ActivateDisplay(display)
	-- This is a stub method on purpose. Fixed layout doesn't need advanced
	-- behaviours like sorting, or dynamic positioning.
end

--- Creates the controls necessary for editing the layout parameters
--  of a display.
-- @param frame The frame to assign controls to.
-- @param ...   The ID's to use for Get/SetParameter calls.
function Fixed:CreateDisplayEditor(frame, ...)
	-- Get anchor params.
	local anchor = PowerAuras:GetParameter("DisplayLayout", "Anchor", ...);

	-- Temporary dropdown illustrating how the hell you change layouts.
	local layout = PowerAuras:Create("P_Dropdown");
	layout:SetRelativeSize(0.6);
	layout:SetPadding(4, 0, 2, 0);
	layout:SetTitle(L["Layout"]);
	layout:SetRawText(DEFAULT);
	layout:Disable();

	-- Resource anchor.
	local parent = PowerAuras:Create("DisplayBox", frame, PowerAuras.Editor);
	parent:SetUserTooltip("LFixed_Parent");
	parent:SetRelativeSize(0.6);
	parent:SetPadding(4, 0, 2, 0);
	parent:SetTitle(L["DisplayParent"]);
	parent:SetText(anchor[2] or "");
	parent:ConnectParameter("DisplayLayout", "Anchor", PowerAuras:Loadstring([[
		local self, value = ...;
		self:SetNumber(value[2] or "");
	]]), ...);
	parent.OnValueUpdated:Connect(PowerAuras:FormatString([[
		local self, value = ...;
		-- Get existing value.
		local anchor = PowerAuras:GetParameter("DisplayLayout", "Anchor",
			${...});
		-- Validate display exists.
		value = (value:trim() ~= "" and tonumber(value) or nil);
		if(PowerAuras:HasAuraDisplay(value) and value ~= ${...}
			or not value) then
			-- Set value.
			anchor[2] = value;
		end
		-- Update the parameter.
		PowerAuras:SetParameter("DisplayLayout", "Anchor", anchor, ${...});
	]], ...));

	-- Offsets.
	local x = PowerAuras:Create("P_NumberBox", frame);
	x:SetUserTooltip("LFixed_X");
	x:SetMinMaxValues(-65535, 65535);
	x:LinkParameter("DisplayLayout", "Anchor", 4, ...);
	x:SetPadding(2, 0, 2, 0);
	x:SetRelativeWidth(0.2);
	x:SetTitle(L["X"]);

	local y = PowerAuras:Create("P_NumberBox", frame);
	y:SetUserTooltip("LFixed_Y");
	y:SetMinMaxValues(-65535, 65535);
	y:LinkParameter("DisplayLayout", "Anchor", 5, ...);
	y:SetPadding(2, 0, 4, 0);
	y:SetRelativeWidth(0.2);
	y:SetTitle(L["Y"]);

	-- Anchor points.
	local point = PowerAuras:Create("P_AnchorDropdown", frame);
	point:SetUserTooltip("LFixed_Anchor");
	point:LinkParameter("DisplayLayout", "Anchor", 1, ...);
	point:SetPadding(4, 0, 2, 0);
	point:SetRelativeWidth(0.4);
	point:SetTitle(L["Anchor"]);

	local rel = PowerAuras:Create("P_AnchorDropdown", frame);
	rel:SetUserTooltip("LFixed_Relative");
	rel:LinkParameter("DisplayLayout", "Anchor", 3, ...);
	rel:SetPadding(4, 0, 2, 0);
	rel:SetRelativeWidth(0.4);
	rel:SetTitle(L["RelativeAnchor"]);

	-- Add widgets to frame.
	frame:AddWidget(layout);
	frame:AddRow(4);
	frame:AddWidget(parent);
	frame:AddWidget(x);
	frame:AddWidget(y);
	frame:AddRow(4);
	frame:AddWidget(point);
	frame:AddWidget(rel);
end

--- Creates the controls necessary for editing layout parameters.
-- @param frame The frame to assign controls to.
-- @param ...   The ID's to use for Get/SetParameter calls.
function Fixed:CreateLayoutEditor(frame, ...)
	-- This is a no-op as we have no parameters.
end

--- Deactivates a registered display on the layout. Deactivated displays
--  are hidden and should not be positioned as if inside of the layout.
-- @remarks This is an instance method.
function Fixed:DeactivateDisplay(display)
	-- This is a stub method on purpose. Fixed layout doesn't need advanced
	-- behaviours like sorting, or dynamic positioning.
end

--- Returns the anchoring data for a moveable/parentable display.
-- @param id The ID of the display.
-- @return The parent, anchor/relative points and x/y offsets.
function Fixed:GetDisplayAnchor(id)
	-- Get the display data and unpack the parameters.
	local vars = PowerAuras:GetAuraDisplay(id);
	return unpack(vars["Layout"]["Parameters"]["Anchor"]);
end

--- Returns a dictionary of parameter names that are ID numbers to other
--  resources.
-- @param params The parameters of the resource.
-- @param out    The table to fill.
function Fixed:GetIDParameters(params, out)
	out["Anchor"] = { [2] = "Display" };
end

--- Returns the ID of any parent aura display used by the passed display.
--  If the display does not depend upon another display for anchoring,
--  this should return nil. The ID should be a valid display, so validation
--  must take place within the implementation.
-- @param display The display to get the parent of. Can either be the display
--                directly, or the ID number.
-- @return The ID number of the parent display if valid.
function Fixed:GetParentDisplay(display)
	local id = (tonumber(display) or display:GetID());
	if(PowerAuras:HasAuraDisplay(id)) then
		-- Get the saved var data for this display.
		local data = PowerAuras:GetAuraDisplay(id);
		local parent = data["Layout"]["Parameters"]["Anchor"][2];
		return PowerAuras:HasAuraDisplay(parent) and parent or nil;
	else
		return nil;
	end
end

--- Returns true if displays attached to this layout can have positioning
--  or anchoring data.
function Fixed:IsDisplayMoveable()
	return true;
end

--- Returns true if displays attached to this layout can be attached to
--  parent displays.
function Fixed:IsDisplayParentable()
	return true;
end

--- Positions a display within the preview frame of the layout.
-- @param frame The frame to play around with.
-- @param id    The ID of the display.
function Fixed:PositionDisplayPreview(frame, id)
	-- Position the display.
	local frame = PowerAuras.Workspace.Displays[id];
	frame:ClearAllPoints();
	local params = PowerAuras:GetAuraDisplay(id)["Layout"]["Parameters"];
	local point, parent, rel, x, y = unpack(params["Anchor"]);
	-- Fix the parent.
	parent = type(parent) == "number"
		and PowerAuras.Workspace.Displays[parent]
		or UIParent;
	frame:SetPoint(point, parent, rel, x, y);
end

--- Registers a display with the layout instance. Registered displays should
--  be considered positionable by the layout instance when activated.
-- @param display The display to register.
-- @param params  The layout parameters of the display.
-- @remarks This is an instance method.
function Fixed:RegisterDisplay(display, params)
	-- Due to the nature of this layout, set the position now.
	self[display] = true;
	display:ClearAllPoints();
	local point, parent, rel, x, y = unpack(params["Anchor"]);
	parent = PowerAuras:IsDisplayLoaded(parent)
		and PowerAuras:GetLoadedDisplay(parent)
		or UIParent;
	display:SetPoint(point, parent, rel, x, y);
end

--- Sets the anchor of a display. This is intended to be used by the
--  editor for the workspace drag/drop movement of displays.
-- @param id     The ID of the display.
-- @param point  The anchor point of the display.
-- @param parent The parent display ID, or nil if no parent.
-- @param rel    The relative point of the display.
-- @param x      The X offset of a display.
-- @param y      The Y offset of a display.
function Fixed:SetDisplayAnchor(id, point, parent, rel, x, y)
	-- Get our display data.
	local vars = PowerAuras:GetAuraDisplay(id);
	-- Update the table parameters.
	local a = vars["Layout"]["Parameters"]["Anchor"];
	a[1], a[2], a[3], a[4], a[5] = point, parent, rel, x, y;
	-- Set parameter.
	PowerAuras:SetParameter("DisplayLayout", "Anchor", a, id);
end

--- Unregisters a display from the layout instance. Should not throw any
--  errors if the display was not initially registered.
-- @param display The display to unregister.
-- @remarks This is an instance method.
function Fixed:UnregisterDisplay(display)
	-- Remove display from the layout.
	if(self[display]) then
		display:ClearAllPoints();
		self[display] = nil;
	end
end

--- Upgrades a display from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The display layout parameters to upgrade.
function Fixed:UpgradeDisplay(version, params)
	
end

--- Upgrades a layout from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The layout parameters to upgrade.
function Fixed:UpgradeLayout(version, params)
	
end