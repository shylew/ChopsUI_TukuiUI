-- Lock down local environment.
local PowerAuras = _G["PowerAuras"];
setfenv(1, PowerAuras);

--- Base widget class. All existing widgets should inherit this.
local Widget = PowerAuras:RegisterWidget("Widget", {
	--- Tooltip instance used by widgets.
	Tooltip = GameTooltip,
	--- Current widget that owns a tooltip.
	TooltipOwner = nil,
});

--- Abstract constructor for the Widget base class. Throws an error.
function Widget:New()
	-- The class parameter should not be our own class.
	if(self == Widget) then
		error(L("GUIErrorWidgetClassAbstract", "Widget"));
	end
end

--- Registers a function on the widget with a callback. Applies a wrapper
--  that allows the callback function to properly receive the self argument.
-- @param callback The callback object to register with.
-- @param func     The function to be called.
-- @param offset   Optional argument offset to start from.
function Widget:ConnectCallback(callback, func, offset)
	-- Register and return.
	self.CallbackHandlers = (self.CallbackHandlers or {});
	self.CallbackHandlers[callback] = (self.CallbackHandlers[callback] or {});
	local wrapper = function(...) func(self, select(offset or 1, ...)); end;
	callback:Connect(wrapper);
	tinsert(self.CallbackHandlers[callback], wrapper);
	return wrapper;
end

--- Registers the current widget with a parameter.
-- @param ... Argument composition changes based upon what type of function
--            to register. If the first argument is a function, then it is
--            registered as a direct callback handler, however if the first
--            type is a string then the format is type, key, callback and ID's.
--            The callback argument is the function to execute.
-- @remarks The type, key and ID parameters are the same as used by the
--          Get/SetParameter functions.
function Widget:ConnectParameter(...)
	-- Argument composition based on type of first arg.
	local handlerType = type(select(1, ...));
	self.ParameterHandlers = (self.ParameterHandlers or {});
	if(handlerType == "function") then
		local func = select(1, ...);
		local wrapper = function(...) func(self, ...); end;
		PowerAuras:ConnectParameterHandler(wrapper);
		tinsert(self.ParameterHandlers, wrapper);
		return wrapper;
	elseif(handlerType ~= "string") then
		-- Invalid type.
		return;
	end
	-- Generate wrapper function.
	local ptype, key, func, id1, id2, id3, id4, id5 = ...;
	if(type(ptype) == "string") then ptype = ("%q"):format(ptype); end
	if(type(key) == "string") then key = ("%q"):format(key); end
	if(type(id1) == "string") then id1 = ("%q"):format(id1); end
	if(type(id1) == "string") then id1 = ("%q"):format(id1); end
	if(type(id2) == "string") then id2 = ("%q"):format(id2); end
	if(type(id3) == "string") then id3 = ("%q"):format(id3); end
	if(type(id4) == "string") then id4 = ("%q"):format(id4); end
	if(type(id5) == "string") then id5 = ("%q"):format(id5); end
	local wrapper = PowerAuras:Loadstring(PowerAuras:FormatString([[
		local self, func = ...;
		return function(value, type, key, id1, id2, id3, id4, id5)
			-- Validate params.
			if(type == ${1} and key == ${2}
				and (${3} == nil or ${3} == id1)
				and (${4} == nil or ${4} == id2)
				and (${5} == nil or ${5} == id3)
				and (${6} == nil or ${6} == id4)
				and (${7} == nil or ${7} == id5)) then
				-- Call function.
				func(self, value, type, key, id1, id2, id3, id4, id5);
			end
		end;
	]], ptype, key, tostringall(id1, id2, id3, id4, id5)))(self, func);
	-- Register and return.
	PowerAuras:ConnectParameterHandler(wrapper);
	tinsert(self.ParameterHandlers, wrapper);
	return wrapper;
end

--- Disconnects all functions from a callback.
-- @param callback The callback to disconnect from.
function Widget:DisconnectCallback(callback)
	-- Skip if we don't even know about this callback.
	if(not self.CallbackHandlers or not self.CallbackHandlers[callback]) then
		return;
	end
	-- Otherwise, disconnect all the wrappers.
	local wrappers = self.CallbackHandlers[callback];
	for i = #(wrappers), 1, -1 do
		local wrapper = wrappers[i];
		callback:Disconnect(wrapper);
		tremove(wrappers, i);
	end
end

--- Returns the fixed (absolute) height for this element, or nil.
function Widget:GetFixedHeight()
	return self.FixedHeight;
end

--- Returns the fixed (absolute) width and height for this element, or nil.
function Widget:GetFixedSize()
	return self:GetFixedWidth(), self:GetFixedHeight();
end

--- Returns the fixed (absolute) width for this element, or nil.
function Widget:GetFixedWidth()
	return self.FixedWidth;
end

--- Returns the help plate definition stored on this frame if it exists.
function Widget:GetHelpPlate()
	return self.HelpPlate;
end

--- Returns the margin data for this element.
function Widget:GetMargins()
	self.Margins = (self.Margins or { 0, 0, 0, 0 });
	return self.Margins;
end

--- Returns the padding data for this element.
function Widget:GetPadding()
	self.Padding = (self.Padding or { 0, 0, 0, 0 });
	return self.Padding;
end

--- Returns the relative width for this element, or nil.
function Widget:GetRelativeWidth()
	return self.RelativeWidth;
end

--- Returns the relative width and height for this element, or nil.
function Widget:GetRelativeSize()
	return self:GetRelativeWidth(), self:GetRelativeHeight();
end

--- Returns the relative height for this element, or nil.
function Widget:GetRelativeHeight()
	return self.RelativeHeight;
end

--- Returns true if the widget has a help plate definition.
function Widget:HasHelpPlate()
	return not not self.HelpPlate;
end

--- Hides the help plate on this widget, if it exists and is showing.
function Widget:HideHelpPlate()
	if(self:HasHelpPlate() and self.HelpPlate.Frame
		and self.HelpPlate.Frame:IsShown()) then
		self.HelpPlate.Frame:BeginHide();
	end
end

--- Returns true if the widget inherits the specified widget class.
-- @param name The name of the widget class.
function Widget:InstanceOf(name)
	local current = (self.Class ~= nil and self.Class or self);
	while(current) do
		if(current == PowerAuras:GetWidget(name)) then
			return true;
		else
			current = current.Base;
		end
	end
	-- Failed.
	return false;
end

--- OnEnter handler. Sets up the tooltip for this widget.
function Widget:OnEnter()
	-- Clean up existing owner.
	if(self.Class.TooltipOwner ~= nil) then
		self.Class.TooltipOwner:OnLeave();
	end
	-- Set new owner and text.
	if(self.OnTooltipShow) then
		self.Class.TooltipOwner = self;
		self:OnTooltipShow(self.Class.Tooltip);
		if(self.Class.Tooltip:NumLines() > 0) then
			self.Class.Tooltip:Show();
		else
			self.Class.TooltipOwner = nil;
		end
	end
end

--- OnLeave handler. Cleans up the tooltip if the current widget owns one.
function Widget:OnLeave()
	if(self:OwnsTooltip()) then
		self.Class.TooltipOwner = nil;
		self.Class.Tooltip:Hide();
		self.Class.Tooltip:ClearLines();
	end
end

--- Default handler for tooltip show events.
-- @param tooltip The tooltip to show.
function Widget:OnUserTooltipShow(tooltip)
	tooltip:SetOwner(self, "ANCHOR_RIGHT");
	tooltip:SetText(self.UserTooltip[1]);
	tooltip:AddLine(self.UserTooltip[2], 1, 1, 1, true);
	tooltip:Show();
end

--- Returns true if the current widget owns a tooltip.
function Widget:OwnsTooltip()
	return self.Class.TooltipOwner == self;
end

--- Recycles the widget, resetting parameter and callback handlers as well
--  as removing widget parents, sizes and anchors. This implementation does
--  not automatically allow the widget to be reused, classes should inherit
--  ReusableWidget for that functionality.
function Widget:Recycle()
	-- Fire recycle callback.
	if(rawget(self, "OnRecycled")) then
		self:OnRecycled();
		self.OnRecycled:Reset();
	end
	-- Unregister all parameters.
	self.ParameterHandlers = (self.ParameterHandlers or {});
	for i = #(self.ParameterHandlers), 1, -1 do
		local func = tremove(self.ParameterHandlers, i);
		PowerAuras:DisconnectParameterHandler(func);
	end
	-- Unregister callbacks.
	self.CallbackHandlers = (self.CallbackHandlers or {});
	for callback, funcs in pairs(self.CallbackHandlers) do
		for i = #(funcs), 1, -1 do
			callback:Disconnect(tremove(funcs, i));
		end
	end
	-- Clear all points and parent, that's all we do.
	self:Hide();
	self:SetParent(UIParent);
	self:ClearAllPoints();
	-- Reset relative/fixed sizes.
	self:SetFixedSize(nil, nil);
	self:SetRelativeSize(nil, nil);
	self:SetPadding(0, 0, 0, 0);
	self:SetMargins(0, 0, 0, 0);
	self:SetHelpPlate(nil);
	self:SetUserTooltip(nil);
	self:SetID(-1);
	if(self.Enable) then
		self:Enable();
	end
end

--- Refreshes the tooltip if the current widget owns it.
function Widget:RefreshTooltip()
	-- Check for ownership.
	if(not self:OwnsTooltip()) then
		return;
	end
	-- Reset tooltip.
	self.Class.Tooltip:Hide();
	self.Class.Tooltip:ClearLines();
	-- Recreate.
	self:OnTooltipShow(self.Class.Tooltip);
	if(self.Class.Tooltip:NumLines() > 0) then
		self.Class.Tooltip:Show();
	else
		self.Class.TooltipOwner = nil;
	end
end

--- Sets a fixed (absolute) height used by the widget when inside of a
--  container.
-- @param height The height to set.
function Widget:SetFixedHeight(height)
	self.FixedHeight = (height and math.max(0, height) or nil);
	-- Update parent layout.
	if(self:GetParent().PerformLayout) then
		self:GetParent():PerformLayout();
	elseif(height ~= nil and height > 0) then
		self:SetHeight(self.FixedHeight);
	end
end

--- Sets a fixed (absolute) size used by the widget when inside of a
--  container.
-- @param width The width to set.
-- @param height The height to set.
function Widget:SetFixedSize(width, height)
	self:SetFixedWidth(width);
	self:SetFixedHeight(height);
end

--- Sets a fixed (absolute) width used by the widget when inside of a
--  container.
-- @param width The width to set.
function Widget:SetFixedWidth(width)
	self.FixedWidth = (width and math.max(0, width) or nil);
	-- Update parent layout.
	if(self:GetParent().PerformLayout) then
		self:GetParent():PerformLayout();
	elseif(width ~= nil and width > 0) then
		self:SetWidth(self.FixedWidth);
	end
end

--- Sets the help plate definition used by this widget. If an existing
--  definition exists, the help plate will be hidden.
-- @param def The definition to register.
function Widget:SetHelpPlate(def)
	if(self:HasHelpPlate()) then
		self:HideHelpPlate();
	end
	self.HelpPlate = def;
end

--- Sets the margins used by a widget inside of a container. Padding subtracts
--  from the widgets' width and height, whereas margins do not.
-- @param top    The top margin.
-- @param left   The left margin.
-- @param right  The right margin.
-- @param bottom The bottom margin.
function Widget:SetMargins(top, left, right, bottom)
	-- Params can't be nil.
	top, left, right, bottom = top or 0, left or 0, right or 0, bottom or 0;
	-- Store margins.
	self.Margins = (self.Margins or { top, left, right, bottom });
	self.Margins[1], self.Margins[2], self.Margins[3], self.Margins[4] = 
		top, left, right, bottom;
	-- Update parent layout.
	if(self:GetParent().PerformLayout) then
		self:GetParent():PerformLayout();
	end
end

--- Sets the padding used by a widget inside of a container. Padding subtracts
--  from the widgets' width and height, whereas margins do not.
-- @param top    The top padding.
-- @param left   The left padding.
-- @param right  The right padding.
-- @param bottom The bottom padding.
function Widget:SetPadding(top, left, right, bottom)
	-- Params can't be nil.
	top, left, right, bottom = top or 0, left or 0, right or 0, bottom or 0;
	-- Store padding.
	self.Padding = (self.Padding or { top, left, right, bottom });
	self.Padding[1], self.Padding[2], self.Padding[3], self.Padding[4] = 
		top, left, right, bottom;
	-- Update parent layout.
	if(self:GetParent().PerformLayout) then
		self:GetParent():PerformLayout();
	end
end

--- Sets the relative height used by a widget inside of a container. If
--  set to nil, then the absolute height will be used.
-- @param height The height to set.
function Widget:SetRelativeHeight(height)
	self.RelativeHeight = (height and math.max(0, math.min(1, height)) or nil);
	-- Update parent layout.
	if(self:GetParent().PerformLayout) then
		self:GetParent():PerformLayout();
	elseif(height ~= nil and height > 0) then
		self:SetHeight(self:GetParent():GetHeight() * self.RelativeHeight);
	end
end

--- Sets the relative size used by a widget inside of a container. If
--  set to nil, then the absolute size will be used.
-- @param width The width to set.
-- @param height The height to set.
function Widget:SetRelativeSize(width, height)
	self:SetRelativeWidth(width);
	self:SetRelativeHeight(height);
end

--- Sets the relative width used by a widget inside of a container. If
--  set to nil, then the absolute width will be used.
-- @param width The width to set.
function Widget:SetRelativeWidth(width)
	self.RelativeWidth = (width and math.max(0, math.min(1, width)) or nil);
	-- Update parent layout.
	if(self:GetParent().PerformLayout) then
		self:GetParent():PerformLayout();
	elseif(width ~= nil and width > 0) then
		self:SetHeight(self:GetParent():GetWidth() * self.RelativeWidth);
	end
end

--- Sets a custom tooltip for the widget. Use this only if the widget does
--  not internally have a tooltip.
-- @param ... Tooltip data. Either the title and text, or a callback function.
function Widget:SetUserTooltip(...)
	-- Can we just end early?
	if(not ... and not self.UserTooltip) then
		return;
	end

	-- Need the table perchance?
	if(not self.UserTooltip) then
		self.UserTooltip = { ... };
	else
		-- Update the table.
		for i = 1, math.max(select("#", ...), #(self.UserTooltip)) do
			self.UserTooltip[i] = select(i, ...);
		end
	end

	-- Was there only one string value?
	if(select("#", ...) == 1 and type(...) == "string"
		and rawget(PowerAuras.L, ...)) then
		-- Autolocalise it.
		self.UserTooltip[1] = L[...];
		self.UserTooltip[2] = L[... .. "Text"];
	end

	-- Are we setting or unsetting?
	if(not ... and rawget(self, "OnTooltipShow")) then
		-- Unsetting.
		rawset(self, "OnTooltipShow", nil);
		if(self.UserTooltip.HasOnEnter) then
			self:SetScript("OnEnter", nil);
			self.UserTooltip.HasOnEnter = false;
		end
		if(self.UserTooltip.HasOnLeave) then
			self:SetScript("OnLeave", nil);
			self.UserTooltip.HasOnLeave = false;
		end
	elseif(...) then
		-- Set the appropriate OnTooltipShow handler.
		if(type(...) == "string") then
			rawset(self, "OnTooltipShow", self.OnUserTooltipShow);
		else
			rawset(self, "OnTooltipShow", ...);
		end

		-- Need script handlers?
		self.UserTooltip.HasOnEnter = not self:GetScript("OnEnter");
		if(self.UserTooltip.HasOnEnter) then
			self:SetScript("OnEnter", PowerAuras:GetWidget("Widget").OnEnter);
		end

		self.UserTooltip.HasOnLeave = not self:GetScript("OnLeave");
		if(self.UserTooltip.HasOnLeave) then
			self:SetScript("OnLeave", PowerAuras:GetWidget("Widget").OnLeave);
		end
	end
end

do
	--- Begins the fade in animation for the passed frame.
	local function BeginShow(frame)
		local alpha = frame:GetAlpha();
		frame.Fade:Stop();
		frame:SetAlpha(alpha);
		frame.FadeAnim:SetChange(1);
		frame.Fade:Play();
	end

	--- Begins the fade out animation for the passed frame.
	local function BeginHide(frame)
		local alpha = frame:GetAlpha();
		frame.Fade:Stop();
		frame:SetAlpha(alpha);
		frame.FadeAnim:SetChange(-1);
		frame.Fade:Play();
	end

	--- Shows and, if necessary, creates the frames for this help plate to be
	--  visible.
	function Widget:ShowHelpPlate()
		-- Skip if there is no help plate.
		if(not self:HasHelpPlate()) then
			return;
		end
		-- If the frame exists, we can just show it.
		if(not self.HelpPlate.Frame) then
			-- Construct main frame.
			self.HelpPlate.Frame = CreateFrame("Frame", nil, UIParent);
			local frame = self.HelpPlate.Frame;
			frame:SetAlpha(0);
			frame:EnableMouse();
			-- Apply fade animation.
			frame.Fade = frame:CreateAnimationGroup();
			frame.FadeAnim = frame.Fade:CreateAnimation("Alpha");
			frame.FadeAnim:SetDuration(0.1);
			frame.Fade:SetScript("OnPlay", function()
				if(frame:GetAlpha() == 0) then
					frame:Show();
				end
			end);
			frame.Fade:SetScript("OnFinished", function()
				if(frame:GetAlpha() > 0) then
					frame:SetAlpha(0);
					frame:Hide();
				else
					frame:SetAlpha(1);
				end
			end);
			frame.BeginShow = BeginShow;
			frame.BeginHide = BeginHide;
			-- Construct boxes.
			for i = 1, #(self.HelpPlate) do
				-- Construct the box.
				local box = CreateFrame("Frame", nil, frame, 
					"PowerAurasGUIHelpPlateBox");
				local point, rel, x, y = unpack(self.HelpPlate[i].Anchor);
				box:SetPoint(point, frame, rel, x, y);
				box:SetSize(unpack(self.HelpPlate[i].Size));
				-- Add the button to it.
				box.Button = PowerAuras:Create("SubHelpButton", box);
				local point, rel, x, y = unpack(self.HelpPlate[i].ButtonAnchor);
				box.Button:SetPoint(point, box, rel, x, y);
				-- Set button tooltip.
				box.Button.TooltipTitle = self.HelpPlate[i].TooltipTitle;
				box.Button.TooltipText = self.HelpPlate[i].TooltipText;
				box.Button.TooltipAnchor = self.HelpPlate[i].TooltipAnchor;
			end
		end
		-- Fix parenting, positioning and sizing, then show.
		self.HelpPlate.Frame:SetParent(self);
		if(type(self.HelpPlate.Anchor) == "table") then
			local point, rel, x, y = unpack(self.HelpPlate.Anchor);
			self.HelpPlate.Frame:SetPoint(point, self, rel, x, y);
			self.HelpPlate.Frame:SetSize(unpack(self.HelpPlate.Size));
		else
			self.HelpPlate.Frame:SetAllPoints(self);
		end
		self.HelpPlate.Frame:BeginShow();
		self.HelpPlate.Frame:SetFrameStrata("DIALOG");
	end
end

--- Toggles the displayed state of the widget, showing it if hidden and vice
--  versa.
function Widget:Toggle()
	if(self:IsShown()) then
		self:Hide();
	else
		self:Show();
	end
end

--- Toggles the visibility of the help plate on this frame if it exists.
function Widget:ToggleHelpPlate()
	if(self:HasHelpPlate() and self.HelpPlate.Frame) then
		if(self.HelpPlate.Frame:IsShown()) then
			self:HideHelpPlate();
		else
			self:ShowHelpPlate();
		end
	elseif(self:HasHelpPlate()) then
		self:ShowHelpPlate();
	end
end

--- Base class for a reusable widget. Provides methods for creating/reusing
--  existing widgets.
local ReusableWidget = PowerAuras:RegisterWidget("ReusableWidget", "Widget");

--- Returns an existing widget of the passed class type, or nil if a new
--  one must be created.
function ReusableWidget:New()
	-- The class parameter should not be our own class.
	if(self == ReusableWidget) then
		error(L("GUIErrorWidgetClassAbstract", "ReusableWidget"));
	end
	-- Make sure the class has a reusable widget table.
	rawset(self, "WidgetFrames", rawget(self, "WidgetFrames") or {});
	-- Remove or return nil.
	local frame = tremove(rawget(self, "WidgetFrames"));
	if(frame) then
		frame:Show();
	end
	return frame;
end

--- Recycles an existing widget, adding it to the pool of reusable widgets.
function ReusableWidget:Recycle()
	-- Recycle.
	base(self);
	tinsert(rawget(self.Class, "WidgetFrames"), self);
end

--- Base class for a container widget. Containers provide layouts and can
--  contain child widgets.
local Container = PowerAuras:RegisterWidget("Container", "Widget");

--- Applies container-specific things to a host frame.
function Container:Initialise()
	-- Layout is initially not paused.
	self.LayoutPaused = 0;
end

--- Called when the size of the frame is changed. Reperforms the layout.
function Container:OnSizeChanged()
	self:PerformLayout();
end

--- Pauses the layout, preventing PerformLayout from doing anything.
function Container:PauseLayout()
	self.LayoutPaused = (self.LayoutPaused and self.LayoutPaused + 1 or 1);
end

--- Performs the layout of any child widgets. Stub function.
function Container:PerformLayout()
	return (not self.LayoutPaused or self.LayoutPaused == 0);
end

--- Resumes and re-performs the layout.
function Container:ResumeLayout()
	self.LayoutPaused = (self.LayoutPaused and self.LayoutPaused - 1 or 0);
	self:PerformLayout();
end

--- Sets the layout type used by the container. Stub function.
function Container:SetLayoutType()
	self:PerformLayout();
end

--- Sets the margins used by a container for its child widgets.
-- @param top    The top margins.
-- @param left   The left margins.
-- @param right  The right margins.
-- @param bottom The bottom margins.
function Container:SetMargins(top, left, right, bottom)
	base(self, top, left, right, bottom);
	self:PerformLayout();
end

--- Sets the padding used by a container for its child widgets.
-- @param top    The top padding.
-- @param left   The left padding.
-- @param right  The right padding.
-- @param bottom The bottom padding.
function Container:SetPadding(top, left, right, bottom)
	base(self, top, left, right, bottom);
	self:PerformLayout();
end

--- Reusable label widget, displays a string of text.
local Label = PowerAuras:RegisterWidget("Label", "ReusableWidget");

--- Creates a new instance of the widget and returns the frame.
-- @param parent The parent frame to create the label for.
function Label:New(parent)
	-- Create a frame.
	local frame = base(self);
	if(not frame) then
		frame = CreateFrame("Frame", nil, parent or UIParent);
		frame.Label = frame:CreateFontString(nil, "OVERLAY");
		frame.Label:SetAllPoints(frame);
		frame.Label:SetFontObject(GameFontNormal);
	end
	-- Set parent.
	frame:SetParent(parent or UIParent);
	frame:Show();
	-- Return the frame.
	return frame;
end

--- Custom lookup function. Automagically generates wrapper functions to allow
--  you to call methods on the label object directly.
-- @param key The key to look up.
-- @param mt  The metatable of the frame object.
function Label:__index(key, mt)
	-- See if class can handle it.
	if(mt.__index[key]) then
		return mt.__index[key];
	elseif(Label[key]) then
		return Label[key];
	elseif(type(self.Label[key]) == "function") then
		-- Create class-wide wrapper.
		Label[key] = function(self, ...)
			return self.Label[key](self.Label, ...);
		end;
		-- Return wrapper.
		return Label[key];
	end
end

--- Recycles the widget.
function Label:Recycle()
	-- Reset font related stuff.
	self:SetFontObject(GameFontNormal);
	self:SetJustifyH("CENTER");
	self:SetJustifyV("MIDDLE");
	self:SetWordWrap(true);
	self:SetText("");
	base(self);
end

--- Reusable texture widget definition.
local Texture = PowerAuras:RegisterWidget("Texture", "ReusableWidget");

--- Custom lookup function. Automagically generates wrapper functions to allow
--  you to call methods on the texture object directly.
-- @param key The key to look up.
-- @param mt  The metatable of the frame object.
function Texture:__index(key, mt)
	-- See if class can handle it.
	if(mt.__index[key]) then
		return mt.__index[key];
	elseif(Texture[key]) then
		return Texture[key];
	elseif(type(self.Texture[key]) == "function") then
		-- Create class-wide wrapper.
		Texture[key] = function(self, ...)
			return self.Texture[key](self.Texture, ...);
		end;
		-- Return wrapper.
		return Texture[key];
	end
end

--- Creates a new instance of the widget and returns the frame.
-- @param parent The parent frame to anchor to.
function Texture:New(parent)
	-- Create a frame.
	local frame = base(self);
	if(not frame) then
		frame = CreateFrame("Frame", nil, parent or UIParent);
		frame.Texture = frame:CreateTexture(nil, "ARTWORK");
		frame.Texture:SetAllPoints(frame);
		frame.Texture:SetTexture(
			[[Interface\AddOns\PowerAuras\Textures\Aura182.tga]]
		);
	end
	-- Set parent.
	frame:SetParent(parent or UIParent);
	frame:Show();
	-- Return the frame.
	return frame;
end

--- Recycles the widget.
function Texture:Recycle()
	-- Reset texture related stuff.
	self:SetTexture(nil);
	self:SetVertexColor(1, 1, 1, 1);
	self:SetTexCoord(0, 1, 0, 1);
	base(self);
end

--- Header widget. Displays a horizontal line and an optional piece of text.
local Header = PowerAuras:RegisterWidget("Header", "ReusableWidget");

--- Constructs a new instance of the widget and returns the frame.
-- @param parent The parent frame to anchor to.
function Header:New(parent)
	-- Recycle or create.
	local frame = base(self);
	if(not frame) then
		frame = CreateFrame("Frame", nil, parent or UIParent);
		-- Title text.
		frame.Title = frame:CreateFontString(nil, "OVERLAY");
		frame.Title:SetFontObject(GameFontNormal);
		frame.Title:SetSize(0, 24);
		frame.Title:SetPoint("CENTER");
		frame.Title:SetJustifyH("CENTER");
		frame.Title:SetJustifyV("MIDDLE");
		frame.Title:SetWordWrap(false);
		-- Bar texture(s).
		frame.BarL = frame:CreateTexture(nil, "ARTWORK");
		frame.BarL:SetTexture([[Interface\ChatFrame\ChatFrameBackground]]);
		frame.BarL:SetVertexColor(0.3, 0.3, 0.3, 1.0);
		frame.BarL:SetSize(0, 1);
		frame.BarL:SetPoint("LEFT", 5, -2);
		frame.BarL:SetPoint("RIGHT", frame.Title, "LEFT", -5, -2);
		frame.BarR = frame:CreateTexture(nil, "ARTWORK");
		frame.BarR:SetTexture([[Interface\ChatFrame\ChatFrameBackground]]);
		frame.BarR:SetVertexColor(0.3, 0.3, 0.3, 1.0);
		frame.BarR:SetSize(0, 1);
		frame.BarR:SetPoint("RIGHT", -5, -2);
		frame.BarR:SetPoint("LEFT", frame.Title, "RIGHT", 5, -2);
	end
	-- Set parent.
	frame:SetParent(parent or UIParent);
	frame:Show();
	-- Return the frame.
	return frame;
end

--- Called after the widget has been fully constructed. Can be used to further
--  initialise the widget as needed.
function Header:Initialise()
	self:SetMargins(0, 5, 0, 5);
	self:SetRelativeWidth(1.0);
	self:SetFixedSize(0, 24);
	self:SetText("");
end

--- Recycles the widget, allowing it to be reused later.
function Header:Recycle()
	-- Clear text, continue.
	self:SetText("");
	base(self);
end

--- Sets the text displayed on the header.
-- @param text The text to display.
function Header:SetText(text)
	-- Set text as normal.
	self.Title:SetText(text);
	-- Do we have text?
	if(not self.Title:GetText() or self.Title:GetText() == "") then
		-- Adjust points on bars.
		self.BarL:SetPoint("RIGHT", self.BarR, "LEFT", 0, 0);
	else
		self.BarL:SetPoint("RIGHT", self.Title, "LEFT", -5, -2);
	end
end

--- Modal dialog widget, provides an overlay for displaying a dialog.
local ModalDialog = PowerAuras:RegisterWidget("ModalDialog", "ReusableWidget");

--- Constructs/recycles an instance of the widget.
function ModalDialog:New()
	local frame = base(self);
	if(not frame) then
		-- Create the dialog.
		frame = CreateFrame("Frame", nil, UIParent);
		frame:EnableMouse(true);
		frame:SetBackdrop({
			bgFile = [[Interface\Buttons\WHITE8X8]],
			tile = true,
		});
		frame:SetBackdropColor(0.0, 0.0, 0.0, 0.75);
		-- Add the child container frame.
		frame.Host = PowerAuras:Create("LayoutHost", frame);
		-- Button data storage.
		frame.AcceptData = nil;
		frame.CancelData = nil;
		-- Callbacks.
		frame.OnAccept = PowerAuras.Callback();
		frame.OnCancel = PowerAuras.Callback();
	end
	return frame;
end

--- Initialises the widget.
-- @param parent The parent of the widget.
function ModalDialog:Initialise(parent)
	-- Update parent and anchors.
	self:SetParent(parent);
	self:SetPoint("TOPLEFT", 2, -22);
	self:SetPoint("BOTTOMRIGHT", -3, 2);
	self:SetFrameStrata("DIALOG");
end

--- Accepts the dialog, firing the OnAccept callback and closing it.
function ModalDialog:Accept()
	self:OnAccept(self.AcceptData);
	self:Hide();
	self:Recycle();
end

--- Cancels the dialog, firing the OnCancel callback and closing it.
function ModalDialog:Cancel()
	self:OnCancel(self.CancelData);
	self:Hide();
	self:Recycle();
end

--- OnHide script handler. Provides special handling of Window parents.
function ModalDialog:OnHide()
	local parent = self:GetParent();
	if(parent and parent.InstanceOf and parent:InstanceOf("Window")) then
		parent.Help:SetFrameStrata("MEDIUM");
		parent.Close:Enable();
	end
end

--- OnShow script handler. Provides special handling of Window parents.
function ModalDialog:OnShow()
	local parent = self:GetParent();
	if(parent and parent.InstanceOf and parent:InstanceOf("Window")) then
		parent.Help:SetFrameStrata("FULLSCREEN_DIALOG");
		parent.Close:Disable();
	end
end

--- Resets the dialog, allowing it to be reused in the future.
function ModalDialog:Recycle()
	-- Clear the host container.
	self.Host:ClearWidgets();
	-- Reset buttons and button data.
	self:SetAcceptData(nil);
	self:SetCancelData(nil);
	-- Reset callbacks.
	self.OnAccept:Reset();
	self.OnCancel:Reset();
	base(self);
end

--- Sets the data passed in the OnAccept callback.
-- @param data Data to pass in the callback.
function ModalDialog:SetAcceptData(data)
	self.AcceptData = data;
end

--- Sets the data passed in the OnCancel callback.
-- @param data Data to pass in the callback.
function ModalDialog:SetCancelData(data)
	self.CancelData = data;
end

--- Basic dialog with a single close button.
local BasicDialog = PowerAuras:RegisterWidget("BasicDialog", "ModalDialog");

--- Initialises the widget.
-- @param parent The parent of the dialog.
function BasicDialog:Initialise(parent)
	-- Initialise the frame.
	base(self, parent);

	-- Add buttons if needed.
	if(not self.AcceptButton) then
		self.AcceptButton = PowerAuras:Create("Button", self.Host);
		self.AcceptButton:SetPoint("BOTTOMRIGHT", -8, 8);
		self.AcceptButton:SetSize(self.AcceptButton:GetFixedSize());
		self.AcceptButton:SetText(L["Close"]);
	end

	-- Connect accept callback.
	self:ConnectCallback(self.AcceptButton.OnClicked, self.Accept);

	-- Configure the host.
	self.Host:SetPoint("TOPLEFT", 32, -32);
	self.Host:SetPoint("BOTTOMRIGHT", -32, 32);
	self.Host:SetContentPadding(8, 8, 8, 32);
end

--- Two button prompt dialog.
local PromptDialog = PowerAuras:RegisterWidget("PromptDialog", "ModalDialog");

--- Initialises the widget, adding child frames automatically.
-- @param parent The parent frame.
-- @param text   The text to show.
-- @param accept The accept button text.
-- @param cancel The cancel button text.
function PromptDialog:Initialise(parent, text, accept, cancel)
	-- Initialise as normal.
	base(self, parent);
	-- Position the host.
	self.Host:SetPoint("LEFT", self:GetWidth() / 6, 0);
	self.Host:SetPoint("RIGHT", -(self:GetWidth() / 6), 0);
	self.Host:SetHeight(self:GetHeight() / 4);
	-- Add main label.
	self.Text = PowerAuras:Create("Label", self.Host);
	self.Text:SetRelativeSize(1.0, 1.0);
	self.Text:SetPadding(0, 0, 0, 24);
	self.Text:SetMargins(0, 0, 0, -24);
	self.Text:SetText(text or "");
	self.Text:SetJustifyH("CENTER");
	self.Text:SetJustifyV("MIDDLE");
	-- Add buttons.
	self.CancelButton = PowerAuras:Create("Button", self.Host);
	self.CancelButton:SetText(cancel or CANCEL);
	self:ConnectCallback(self.CancelButton.OnClicked, self.Cancel);
	self.AcceptButton = PowerAuras:Create("Button", self.Host);
	self.AcceptButton:SetText(accept or ACCEPT);
	self:ConnectCallback(self.AcceptButton.OnClicked, self.Accept);
	-- Offset the cancel button so both of them appear at the right side
	-- of the frame.
	self.CancelButton:SetMargins(
		(self.Host:GetWidth() - 17) - (self.CancelButton:GetFixedWidth() * 2),
		0,
		0,
		0
	);
	-- Add widgets to frame.
	self.Host:SetContentPadding(8, 8, 8, 8);
	self.Host:AddWidget(self.Text);
	self.Host:AddWidget(self.CancelButton);
	self.Host:AddWidget(self.AcceptButton);
end

--- Unit selection dialog.
local UnitDialog = PowerAuras:RegisterWidget("UnitDialog", "ModalDialog");

--- Initialises the widget, adding child frames automatically.
-- @param parent The parent frame.
-- @param ...    Arguments for Get/SetParameter calls.
function UnitDialog:Initialise(parent, ...)
	-- Initialise as normal.
	base(self, parent);
	-- Position the host.
	self.Host:SetPoint("LEFT", 32, 0);
	self.Host:SetPoint("RIGHT", -32, 0);
	self.Host:SetHeight(386)
	self.Host:SetContentPadding(8, 8, 8, 8);
	-- Load the variables.
	self.Vars = PowerAuras:DecodeUnits(
		PowerAuras:GetParameter(...) or "player",
		true
	);
	-- Refresh the pane.
	self:RefreshHost(0);
end

--- Refreshes the host pane.
-- @param key The selected unit type key.
function UnitDialog:RefreshHost(key)
	-- Reset the host.
	self.Host:PauseLayout();
	self.Host:ClearWidgets();
	-- Get iterable units table foe this type.
	local units = (key == 0 and PowerAuras.SingleUnitIDs or nil);
	local groupName = "";

	-- Add two dropdowns, first is for selecting current units.
	local current = PowerAuras:Create("SimpleDropdown", self.Host);
	current:SetPadding(4, 0, 2, 0);
	current:SetRelativeWidth(0.45);
	current:SetTitle(L["Showing"]);
	self:ConnectCallback(current.OnValueUpdated, self.RefreshHost, 2);
	self.Host:AddWidget(current);

	-- Populate unit types list. Start with single units, then groups.
	current:AddCheckItem(0, L["Units"]["single"], key == 0);
	local i = 1;
	for group, _ in PowerAuras:ByKey(PowerAuras.GroupUnitIDs) do
		-- Add item.
		current:AddCheckItem(i, L["Units"][group], i == key);
		-- Also, was this the selected item?
		if(not units and i == key) then
			groupName = group;
			units = PowerAuras.GroupUnitIDs[group];
		end
		-- Increment index.
		i = i + 1;
	end
	current:SetText(key);

	-- Second is for selecting the match mode (any/all).
	local mode = PowerAuras:Create("SimpleDropdown", self.Host);
	mode:SetPadding(2, 0, 4, 0);
	mode:SetRelativeWidth(0.45);
	mode:SetTitle(L["Match"]);
	mode:AddCheckItem(2, L["MatchAll"], not self.Vars["IsAny"]);
	mode:SetItemTooltip(2, L["MatchAllTooltip"]);
	mode:AddCheckItem(1, L["MatchAny"], self.Vars["IsAny"]);
	mode:SetItemTooltip(1, L["MatchAnyTooltip"]);
	mode:SetText(self.Vars["IsAny"] and 1 or 2);
	mode.OnValueUpdated:Connect(function(ctrl, value)
		ctrl:CloseMenu();
		self.Vars["IsAny"] = (value == 1 and true or false);
		ctrl:SetItemChecked(value, true);
		ctrl:SetItemChecked(value == 1 and 2 or 1, false);
		ctrl:SetText(value);
	end);
	self.Host:AddStretcher();
	self.Host:AddWidget(mode);
	self.Host:AddRow(4);

	-- Add quick all/any boxes if doing group units.
	if(key > 0) then
		-- Quick check all.
		local checkAll = PowerAuras:Create("Checkbox", self.Host);
		checkAll:SetPadding(4, 0, 2, 0);
		checkAll:SetRelativeWidth(0.25);
		checkAll:SetText(L["MatchAll"]);
		checkAll:SetChecked(tContains(self.Vars, groupName .. "-all"));
		checkAll.OnValueUpdated:Connect(function(ctrl, value)
			-- Reset the state of any of these group units.
			for i = #(self.Vars), 1, -1 do
				if(tContains(units, self.Vars[i])
					or self.Vars[i] == groupName .. "-all"
					or self.Vars[i] == groupName .. "-any") then
					-- Remove.
					tremove(self.Vars, i);
				end
			end
			-- Add our own.
			if(value) then
				tinsert(self.Vars, groupName .. "-all");
			end
			-- Refresh.
			self:RefreshHost(key);
		end);
		self.Host:AddWidget(checkAll);

		-- Quick check any.
		local checkAny = PowerAuras:Create("Checkbox", self.Host);
		checkAny:SetPadding(4, 0, 2, 0);
		checkAny:SetRelativeWidth(0.25);
		checkAny:SetText(L["MatchAny"]);
		checkAny:SetChecked(tContains(self.Vars, groupName .. "-any"));
		checkAny.OnValueUpdated:Connect(function(ctrl, value)
			-- Reset the state of any of these group units.
			for i = #(self.Vars), 1, -1 do
				if(tContains(units, self.Vars[i])
					or self.Vars[i] == groupName .. "-all"
					or self.Vars[i] == groupName .. "-any") then
					-- Remove.
					tremove(self.Vars, i);
				end
			end
			-- Add our own.
			if(value) then
				tinsert(self.Vars, groupName .. "-any");
			end
			-- Refresh.
			self:RefreshHost(key);
		end);
		self.Host:AddWidget(checkAny);
		self.Host:AddRow(2);
	end

	-- Now add a boatload of checkboxes.
	local isQuick = tContains(self.Vars, groupName .. "-any")
		or tContains(self.Vars, groupName .. "-all");
	for i = 1, #(units) do
		-- Add checkbox, quickly configure, add!
		local check = PowerAuras:Create("Checkbox", self.Host);
		check:SetPadding(4, 0, 4, 0);
		check:SetRelativeWidth(0.25);
		check:SetText(L["Units"][units[i]]);
		check:SetEnabled(not isQuick);
		check:SetChecked(isQuick or tContains(self.Vars, units[i]));
		check.OnValueUpdated:Connect(function(ctrl, value)
			-- Remove this unit.
			for j = #(self.Vars), 1, -1 do
				if(self.Vars[j] == units[i]) then
					tremove(self.Vars, j);
				end
			end
			-- Re-add it.
			ctrl:SetChecked(value);
			if(value) then
				tinsert(self.Vars, units[i]);
			end
		end);
		self.Host:AddWidget(check);
		if(i % 4 == 0) then
			self.Host:AddRow(2);
		end
	end
	-- Add a bit more padding.
	self.Host:AddRow(4);

	-- Add the accept/cancel buttons.
	local cancel = PowerAuras:Create("Button", self.Host);
	cancel:SetPadding(4, 0, 2, 0);
	cancel:SetMargins(
		self.Host:GetWidth() - (cancel:GetFixedWidth() * 2) - 17,
		260 - (math.ceil(#(units) / 4) * 24)
			- (math.floor(#(units) / 4) * 2)
			+ (key == 0 and 26 or 0),
		0,
		0
	);
	cancel:SetText(L["Cancel"]);
	self:ConnectCallback(cancel.OnClicked, self.Cancel, 2);
	self.Host:AddWidget(cancel);

	local accept = PowerAuras:Create("Button", self.Host);
	accept:SetPadding(4, 0, 2, 0);
	accept:SetMargins(
		0,
		260 - (math.ceil(#(units) / 4) * 24)
			- (math.floor(#(units) / 4) * 2)
			+ (key == 0 and 26 or 0),
		0,
		0
	);
	accept:SetText(L["Apply"]);
	accept.OnClicked:Connect(function()
		-- Serialize and accept.
		self:SetAcceptData(PowerAuras:EncodeUnits(self.Vars));
		self:Accept();
	end);
	self.Host:AddWidget(accept);

	-- Resume.
	self.Host:ResumeLayout();
end

--- Dialog for picking a texture.
local TextureDialog = PowerAuras:RegisterWidget("TextureDialog", "ModalDialog");

--- Initialises the dialog, adding all of the child widgets.
function TextureDialog:Initialise(parent)
	-- Initialise as normal.
	base(self, parent);
	-- Anchor the host frame.
	self.Host:SetPoint("TOPLEFT", 64, -56);
	self.Host:SetPoint("BOTTOMRIGHT", -64, 56);
	-- Add our preview panel.
	if(not self.Preview) then
		self.Preview = self.Host:CreateTexture(nil, "ARTWORK");
		self.Preview:SetPoint("CENTER", self.Host, "TOPLEFT", 92, -108);
		self.Preview:SetSize(128, 128);
		-- Use cancel data texture if present.
		if(self.CancelData) then
			self.Preview:SetTexture(self.CancelData);
		end
	end

	-- Resizing controls.
	if(not self.SizeX and not self.SizeY) then
		self.SizeX = PowerAuras:Create("NumberBox", self.Host);
		self.SizeX:SetPoint("TOPLEFT", self.Host, "TOPLEFT", 28, -176);
		self.SizeX:SetPoint("TOPRIGHT", self.Host, "TOPLEFT", 84, -176);
		self.SizeX:SetHeight(self.SizeX:GetFixedHeight());
		self.SizeX:SetMinMaxValues(1, 128);
		self.SizeX:SetValue(128);
		self.SizeX.OnValueUpdated:Connect(function(box, value)
			self.Preview:SetWidth(value);
		end);

		self.SizeM = PowerAuras:Create("Label", self.Host);
		self.SizeM:SetPoint("TOPLEFT", self.SizeX, "TOPRIGHT", 2, 0);
		self.SizeM:SetWidth(12);
		self.SizeM:SetHeight(self.SizeX:GetFixedHeight());
		self.SizeM:SetJustifyH("CENTER");
		self.SizeM:SetJustifyV("MIDDLE");
		self.SizeM:SetFontObject(GameFontNormalSmall);
		self.SizeM:SetText("x");

		self.SizeY = PowerAuras:Create("NumberBox", self.Host);
		self.SizeY:SetPoint("TOPLEFT", self.Host, "TOPLEFT", 100, -176);
		self.SizeY:SetPoint("TOPRIGHT", self.Host, "TOPLEFT", 156, -176);
		self.SizeY:SetHeight(self.SizeY:GetFixedHeight());
		self.SizeY:SetMinMaxValues(1, 128);
		self.SizeY:SetValue(128);
		self.SizeY.OnValueUpdated:Connect(function(box, value)
			self.Preview:SetHeight(value);
		end);

		self.Color = PowerAuras:Create("ColorPicker", self.Host);
		self.Color:SetPoint("TOPLEFT", self.SizeX, "BOTTOMLEFT", 0, -4);
		self.Color:SetPoint("TOPRIGHT", self.SizeY, "BOTTOMRIGHT", 0, -4);
		self.Color:SetHeight(self.Color:GetFixedHeight());
		self.Color:HasOpacity(false);
		self.Color.OnValueUpdated:Connect(function(w, r, g, b)
			self.Preview:SetVertexColor(r, g, b);
			self.Selection:PerformLayout();
		end);

		self.Auto = PowerAuras:Create("Checkbox", self.Host);
		self.Auto:SetPoint("TOPLEFT", self.Color, "BOTTOMLEFT", 0, -4);
		self.Auto:SetPoint("TOPRIGHT", self.Color, "BOTTOMRIGHT", 0, -4);
		self.Auto:SetHeight(self.Auto:GetFixedHeight());
		self.Auto:SetChecked(true);
		self.Auto:SetText(L["Autosize"]);
	end

	-- And our selection panel.
	if(not self.Selection) then
		self.Selection = PowerAuras:Create("ScrollFrame", self.Host);
		self.Selection:SetPoint("BOTTOMRIGHT", -8, 34);
		self.Selection:SetPoint("TOPLEFT", self.Host, "TOP", -64, -40);
		self.Selection.Count = {};
		self.Selection.Total = 0;
		self.Selection.Widgets = {};

		function self.Selection:PerformLayout()
			-- Hide all textures.
			for i = 1, #(self.Widgets) do
				self.Widgets[i]:Hide();
			end
			-- Are we dirty?
			local pop = self:GetParent():GetParent();
			local textureSets = PowerAuras:GetTextureSets();
			if(self.Total == 0) then
				-- Damn right we are! Count all the textures. All. Go!
				local newOffset = self:GetScrollOffset();
				for name, set in pairs(textureSets) do
					for i, tex in set() do
						self.Count[name] = (self.Count[name] or 0) + 1;
						if(pop.Filter:GetItemChecked(name)) then
							self.Total = (self.Total or 0) + 1;
						end
						-- Also, do we need to scroll to our current one?
						if(not pop.AcceptData and pop.CancelData) then
							if(tex == pop.CancelData) then
								newOffset = math.ceil(self.Total / 4) - 1;
							end
						end
					end
				end
				-- Update scroll range.
				local max = math.max(0, math.ceil((self.Total - 16) / 4));
				if(select(2, self:GetScrollRange()) ~= max) then
					self:SetScrollRange(0, max);
					self:SetScrollOffset(newOffset);
					return;
				elseif(newOffset ~= self:GetScrollOffset()) then
					self:SetScrollOffset(newOffset);
					return;
				end
			end
			-- Get scroll offset.
			local offset = (self:GetScrollOffset() * 4);
			local index = 0;
			-- Get the first set.
			local name, set;
			local bykey = PowerAuras:ByKey(textureSets);
			repeat
				name, set = bykey(textureSets, name);
			until(not name or pop.Filter:GetItemChecked(name));
			-- Iterate over the set.
			while(name) do
				-- Can we skip this set outright?
				if(offset - self.Count[name] > 0) then
					offset = offset - self.Count[name];
				else
					-- Run over the textures in the set.
					for i, tex in set() do
						-- Can we show this image?
						if(offset == 0 and index < 16) then
							-- Increment index.
							index = index + 1;
							-- Does the texture at this point exist?
							if(not self.Widgets[index]) then
								local w = CreateFrame("CheckButton", nil, self);
								w:SetSize(64, 64);
								w:SetPoint(
									"TOPLEFT",
									6 + ((index - 1) * 66)
										- (math.floor((index - 1) / 4) * 264),
									-((math.floor((index - 1) / 4) * 66) + 6)
								);
								w:SetBackdrop({
									edgeFile = [[Interface\Buttons\WHITE8X8]],
									edgeSize = 1,
								});
								w:SetBackdropBorderColor(0.3, 0.3, 0.3, 1.0);
								w.Texture = w:CreateTexture(nil, "ARTWORK");
								w.Texture:SetPoint("CENTER");
								w.Texture:SetSize(62, 62);
								self.Widgets[index] = w;
								-- Script handlers.
								w:SetScript("OnEnter", function(w)
									w:SetBackdropBorderColor(1.0, 0.8, 0.0);
								end);
								w:SetScript("OnLeave", function(w)
									if(w:GetChecked()) then
										return;
									end
									w:SetBackdropBorderColor(0.3, 0.3, 0.3);
								end);
								w:SetScript("OnClick", function(w)
									pop:SetAcceptData(w.Tex);
									pop.Selection:PerformLayout();
								end);
							end
							-- Set the texture.
							local w = self.Widgets[index];
							-- Attempt the automatic texture sizing trick.
							w.Texture:SetSize(0, 0);
							w.Texture:SetTexture(tex);
							w.Texture:SetVertexColor(pop.Color:GetColor());
							local current = pop.AcceptData or pop.CancelData;
							w:SetChecked(current == tex);
							if(current == tex or w:IsMouseOver()) then
								w:SetBackdropBorderColor(1.0, 0.8, 0.0);
							else
								w:SetBackdropBorderColor(0.3, 0.3, 0.3);
							end
							w.Tex = tex;
							w:Show();
							-- Was a size set?
							if(w.Texture:GetWidth() == 0) then
								w.Texture:SetSize(62, 62);
							else
								-- Maintain aspect ratio and scale it down.
								local tw, th = w.Texture:GetSize();
								w.Texture:SetSize(62, (th / tw) * 62);
								if(w.Texture:GetHeight() > 62) then
									w.Texture:SetSize((tw / th) * 62, 62);
								end
							end
						elseif(offset == 0 and index == 16) then
							-- Time to quit.
							break;
						else
							-- Decrement offset.
							offset = offset - 1;
						end
					end
				end
				-- Can we skip the rest?
				if(offset == 0 and index == 16) then
					break;
				end
				-- We hit the end of the set, next one.
				repeat
					name, set = bykey(textureSets, name);
				until(not name or pop.Filter:GetItemChecked(name));
			end
		end
	end

	-- Filtering dropdowns.
	if(not self.Filter) then
		self.Filter = PowerAuras:Create("SimpleDropdown", self.Host);
		self.Filter:SetPoint("BOTTOMRIGHT", self.Selection, "TOPRIGHT", 0, 4);
		self.Filter:SetPoint("BOTTOMLEFT", self.Selection, "TOP", 4, 4);
		self.Filter:SetHeight(self.Filter:GetFixedHeight());
		self.Filter:SetRawText(L["FilterBy"]);
		-- Add options for each set.
		for set, _ in PowerAuras:ByKey(PowerAuras:GetTextureSets()) do
			self.Filter:AddCheckItem(set, set, true);
		end
		self.Filter.OnValueUpdated:Connect(function(filter, set)
			-- Toggle state.
			filter:SetItemChecked(set, not filter:GetItemChecked(set));
			-- Flag the frame as being dirty.
			wipe(self.Selection.Count);
			self.Selection.Total = 0;
			self.Selection:PerformLayout();
		end);
	end

	-- And finally, accept/close buttons!
	if(not self.AcceptButton) then
		self.AcceptButton = PowerAuras:Create("Button", self.Host);
		self.AcceptButton:SetText(ACCEPT);
		self.AcceptButton:SetSize(self.AcceptButton:GetFixedSize());
		self.AcceptButton:SetPoint("BOTTOMRIGHT", -8, 8);
		self.AcceptButton:Disable();
		self.AcceptButton.OnClicked:Connect(function()
			self:Accept();
		end);
	end

	if(not self.CancelButton) then
		self.CancelButton = PowerAuras:Create("Button", self.Host);
		self.CancelButton:SetText(CANCEL);
		self.CancelButton:SetSize(self.CancelButton:GetFixedSize());
		self.CancelButton:SetPoint("RIGHT", self.AcceptButton, "LEFT", -8, 0);
		self.CancelButton.OnClicked:Connect(function()
			self:Cancel();
		end);
	end
end

--- Sets the accept data for the dialog.
-- @param data The data to set.
function TextureDialog:SetAcceptData(data)
	-- Pass call to base func.
	base(self, data);
	-- Update accept button state.
	if(not data) then
		self.AcceptButton:Disable();
	else
		self.AcceptButton:Enable();
	end
	-- Update our preview.
	if(self.Auto:GetChecked()) then
		self.Preview:SetSize(0, 0);
	end
	self.Preview:SetTexture(data);
	-- Was a size set?
	if(self.Preview:GetWidth() == 0) then
		self.Preview:SetSize(128, 128);
	else
		-- Maintain aspect ratio and scale it down.
		local tw, th = self.Preview:GetSize();
		self.Preview:SetSize(128, math.ceil((th / tw) * 128));
		if(self.Preview:GetHeight() > 128) then
			self.Preview:SetSize(math.floor((tw / th) * 128), 128);
		end
	end
	-- Update editbox sizes.
	self.SizeX:SetValue(self.Preview:GetWidth());
	self.SizeY:SetValue(self.Preview:GetHeight());
end

--- Sets the cancel data for the dialog.
-- @param data The data to set.
function TextureDialog:SetCancelData(data)
	-- Do we not yet have data?
	if(not self.CancelData and data) then
		-- Update preview.
		self.Preview:SetTexture(data);
	end
	-- Set the data as normal.
	base(self, data);
	-- Reperform the layout.
	self.Selection.Total = 0;
	self.Selection:PerformLayout();
end

--- Dialog for picking a sound file.
local SoundDialog = PowerAuras:RegisterWidget("SoundDialog", "ModalDialog");

--- Initialises the dialog, adding all of the child widgets.
function SoundDialog:Initialise(parent)
	-- Initialise as normal.
	base(self, parent);
	-- Anchor the host frame.
	self.Host:SetPoint("TOPLEFT", 64, -56);
	self.Host:SetPoint("BOTTOMRIGHT", -64, 56);

	-- And our selection panel.
	if(not self.Selection) then
		self.Selection = PowerAuras:Create("ScrollFrame", self.Host);
		self.Selection:SetPoint("BOTTOMRIGHT", -8, 34);
		self.Selection:SetPoint("TOPLEFT", self.Host, "TOP", -64, -40);
		self.Selection:SetPoint("TOPLEFT", 8, -40);
		self.Selection.Count = {};
		self.Selection.Total = 0;
		self.Selection.Widgets = setmetatable({}, {
			__index = function(t, i)
				-- Create button.
				t[i] = CreateFrame("CheckButton", nil, self.Selection);
				t[i]:SetSize(0, 24);
				t[i]:SetPoint("TOPLEFT", 8, -(4 + (i - 1) * 24));
				t[i]:SetPoint("TOPRIGHT", -24, -(4 + (i - 1) * 24));
				-- Add textures.
				t[i]:SetHighlightTexture(
					[[Interface\HelpFrame\KnowledgeBaseButtton]]
				);
				t[i]:GetHighlightTexture():SetTexCoord(
					0.13085938, 0.63085938, 0.0078125, 0.203125
				);
				t[i]:SetCheckedTexture(
					[[Interface\HelpFrame\KnowledgeBaseButtton]]
				);
				t[i]:GetCheckedTexture():SetTexCoord(
					0.13085938, 0.63085938, 0.0078125, 0.203125
				);
				t[i]:SetDisabledTexture(
					[[Interface\HelpFrame\KnowledgeBaseButtton]]
				);
				t[i]:GetDisabledTexture():SetDesaturated(true);
				t[i]:GetDisabledTexture():SetTexCoord(
					0.13085938, 0.63085938, 0.0078125, 0.203125
				);
				-- Add text.
				t[i].Text = t[i]:CreateFontString(nil, "OVERLAY");
				t[i].Text:SetFontObject(GameFontNormal);
				t[i].Text:SetPoint("TOPLEFT", 24, 0);
				t[i].Text:SetPoint("BOTTOMRIGHT", -4, 0);
				t[i].Text:SetJustifyH("LEFT");
				t[i].Text:SetJustifyV("MIDDLE");
				t[i]:SetFontString(t[i].Text);
				-- Set fonts.
				t[i]:SetNormalFontObject(GameFontNormalSmall);
				t[i]:SetHighlightFontObject(GameFontHighlightSmall);
				t[i]:SetDisabledFontObject(GameFontNormal);
				-- Play button.
				t[i].Play = CreateFrame("Button", nil, t[i]);
				t[i].Play:SetSize(16, 16);
				t[i].Play:SetAlpha(0.5);
				t[i].Play:SetPoint("TOPLEFT", 4, -4);
				t[i].Play:SetNormalTexture(
					[[Interface\Buttons\UI-GuildButton-MOTD-Up]]
				);
				t[i].Play:SetHighlightTexture(
					[[Interface\Buttons\UI-GuildButton-MOTD-Up]]
				);
				-- Scripts.
				t[i]:SetScript("OnEnable", function(w)
					w.Text:SetJustifyH("LEFT");
					w.Play:Show();
				end);
				t[i]:SetScript("OnDisable", function(w)
					w.Text:SetJustifyH("MIDDLE");
					w.Play:Hide();
				end);
				t[i]:SetScript("OnClick", function(w)
					self:SetAcceptData({ w.Path, w.IsWoW });
					self.Selection:PerformLayout();
				end);
				t[i].Play:SetScript("OnEnter", function(b)
					b:SetAlpha(1.0);
				end);
				t[i].Play:SetScript("OnLeave", function(b)
					b:SetAlpha(0.5);
				end);
				t[i].Play:SetScript("OnClick", function(b)
					if(t[i].IsWoW) then
						PlaySound(t[i].Path, "MASTER");
					else
						PlaySoundFile(t[i].Path, "MASTER");
					end
				end);
				return t[i];
			end,
		});

		function self.Selection:PerformLayout()
			-- Hide all sounds.
			for i = 1, #(self.Widgets) do
				self.Widgets[i]:Hide();
			end
			-- Are we dirty?
			local pop = self:GetParent():GetParent();
			local soundSets = PowerAuras:GetSoundSets();
			local max = math.floor((self:GetHeight() - 8) / 24);
			local current = pop.AcceptData or pop.CancelData;
			if(self.Total == 0) then
				-- Damn right we are! Count all the sounds. All. Go!
				local newOffset = self:GetScrollOffset();
				for name, set in pairs(soundSets) do
					for i, path in set() do
						self.Count[name] = (self.Count[name] or 0) + 1;
						if(pop.Filter:GetItemChecked(name)) then
							self.Total = (self.Total or 0) + 1;
						end
						-- Also, do we need to scroll to our current one?
						if(not pop.AcceptData and pop.CancelData) then
							if(path == pop.CancelData[1]) then
								newOffset = self.Total - 1;
							end
						end
					end
				end
				-- Update scroll range.
				local max = math.max(0, (self.Total - max));
				if(select(2, self:GetScrollRange()) ~= max) then
					self:SetScrollRange(0, max);
					self:SetScrollOffset(newOffset);
					return;
				elseif(newOffset ~= self:GetScrollOffset()) then
					self:SetScrollOffset(newOffset);
					return;
				end
			end
			-- Get scroll offset.
			local offset = self:GetScrollOffset();
			local index = 0;
			-- Get the first set.
			local name, set;
			local bykey = PowerAuras:ByKey(soundSets);
			repeat
				name, set = bykey(soundSets, name);
			until(not name or pop.Filter:GetItemChecked(name));
			-- Iterate over the set.
			while(name) do
				-- Can we skip this set outright?
				if(offset - self.Count[name] > 0) then
					offset = offset - self.Count[name];
				else
					-- Run over the sounds in the set.
					for i, path, name, isWoW in set() do
						-- Can we show this sound?
						if(offset == 0 and index < max) then
							-- Increment index.
							index = index + 1;
							local w = self.Widgets[index];
							w.Path = path;
							w.IsWoW = isWoW;
							w:SetChecked(current and path == current[1]);
							w:SetText(name);
							w:Enable();
							w:Show();
						elseif(offset == 0 and index == max) then
							-- Time to quit.
							break;
						else
							-- Decrement offset.
							offset = offset - 1;
						end
					end
				end
				-- Can we skip the rest?
				if(offset == 0 and index == max) then
					break;
				end
				-- We hit the end of the set, next one.
				repeat
					name, set = bykey(soundSets, name);
				until(not name or pop.Filter:GetItemChecked(name));
			end
		end
	end

	-- Filtering dropdowns.
	if(not self.Filter) then
		self.Filter = PowerAuras:Create("SimpleDropdown", self.Host);
		self.Filter:SetPoint("BOTTOMRIGHT", self.Selection, "TOPRIGHT", 0, 4);
		self.Filter:SetPoint("BOTTOMLEFT", self.Selection, "TOP", 4, 4);
		self.Filter:SetHeight(self.Filter:GetFixedHeight());
		self.Filter:SetRawText(L["FilterBy"]);
		-- Add options for each set.
		for set, _ in PowerAuras:ByKey(PowerAuras:GetSoundSets()) do
			self.Filter:AddCheckItem(set, set, true);
		end
		self.Filter.OnValueUpdated:Connect(function(filter, set)
			-- Toggle state.
			filter:SetItemChecked(set, not filter:GetItemChecked(set));
			-- Flag the frame as being dirty.
			wipe(self.Selection.Count);
			self.Selection.Total = 0;
			self.Selection:PerformLayout();
		end);
	end

	-- And finally, accept/close buttons!
	if(not self.AcceptButton) then
		self.AcceptButton = PowerAuras:Create("Button", self.Host);
		self.AcceptButton:SetText(ACCEPT);
		self.AcceptButton:SetSize(self.AcceptButton:GetFixedSize());
		self.AcceptButton:SetPoint("BOTTOMRIGHT", -8, 8);
		self.AcceptButton:Disable();
		self.AcceptButton.OnClicked:Connect(function()
			self:Accept();
		end);
	end

	if(not self.CancelButton) then
		self.CancelButton = PowerAuras:Create("Button", self.Host);
		self.CancelButton:SetText(CANCEL);
		self.CancelButton:SetSize(self.CancelButton:GetFixedSize());
		self.CancelButton:SetPoint("RIGHT", self.AcceptButton, "LEFT", -8, 0);
		self.CancelButton.OnClicked:Connect(function()
			self:Cancel();
		end);
	end
end

--- Sets the accept data for the dialog.
-- @param data The data to set.
function SoundDialog:SetAcceptData(data)
	-- Pass call to base func.
	base(self, data);
	-- Update accept button state.
	if(not data) then
		self.AcceptButton:Disable();
	else
		self.AcceptButton:Enable();
	end
end

--- Sets the cancel data for the dialog.
-- @param data The data to set.
function SoundDialog:SetCancelData(data)
	-- Set the data as normal.
	base(self, data);
	-- Reperform the layout.
	self.Selection.Total = 0;
	self.Selection:PerformLayout();
end

--- Dialog for picking a bar template.
local Template = PowerAuras:RegisterWidget("TemplateDialog", "ModalDialog");

--- Initialises the dialog, adding all of the child widgets.
function Template:Initialise(parent)
	-- Initialise as normal.
	base(self, parent);
	-- Anchor the host frame.
	self.Host:SetPoint("TOPLEFT", 64, -56);
	self.Host:SetPoint("BOTTOMRIGHT", -64, 56);

	-- Preview panel.
	self.Preview = PowerAuras:Create("Frame", self.Host);
	self.Preview:SetPoint("TOPLEFT", 16, -48);
	self.Preview:SetSize(256, 256);

	--- Updates the preview panel with a bar template.
	function self.Preview:Update(template)
		-- Get the requested template.
		template = PowerAuras:GetBarTemplate(template);
		if(not template) then
			self:Hide();
			return;
		else
			self:Show();
		end
		-- Update frame size.
		self:SetSize(unpack(template["Size"]));
		-- Create textures if needed.
		self.Frame = (self.Frame or self:CreateTexture(nil, "ARTWORK"));
		self.Bg = (self.Bg or self:CreateTexture(nil, "BACKGROUND"));
		self.Fill = (self.Fill or self:CreateTexture(nil, "BORDER"));
		self.Spark = (self.Spark or self:CreateTexture(nil, "OVERLAY"));
		self.Flash = (self.Flash or self:CreateTexture(nil, "OVERLAY"));
		-- Style individual textures.
		self.Frame:SetAllPoints(self);
		self.Frame:SetTexture(template["Frame"]);
		self.Bg:SetAllPoints(self);
		self.Bg:SetTexture(template["Background"]);
		self.Fill:SetTexture(template["Fill"]);
		self.Spark:SetTexture(template["Spark"]);
		self.Spark:SetBlendMode(template["SparkBlendMode"] or "ADD");
		self.Spark:SetWidth(self:GetHeight() / 8);
		self.Flash:SetAllPoints(self);
		self.Flash:SetTexture(template["Flash"]);
		self.Flash:SetBlendMode(template["FlashBlendMode"] or "ADD");
		if(self:GetParent():GetParent().ShowFlash:GetChecked()) then
			self.Flash:Show();
		else
			self.Flash:Hide();
		end
		-- Use sensible fill values and update the fill width/height/whatever.
		self.Spark:ClearAllPoints();
		self.Fill:ClearAllPoints();
		local w, h = self:GetSize();
		if(template["Type"] == "Horizontal") then
			self.Fill:SetPoint("TOPLEFT");
			self.Fill:SetPoint("BOTTOMLEFT");
			self.Fill:SetWidth(0.5 * w);
			self.Fill:SetTexCoord(0, 0.5, 0, 1);
			self.Spark:SetPoint("TOPLEFT", self.Fill, "TOPRIGHT", -3, 0);
			self.Spark:SetPoint("BOTTOMLEFT", self.Fill, "BOTTOMRIGHT", -3, 0);
		else
			-- TODO
		end
	end

	-- Checkbox for showing the flash texture.
	self.ShowFlash = PowerAuras:Create("Checkbox", self.Host);
	self.ShowFlash:SetText(L["ShowBarGlow"]);
	self.ShowFlash:SetPoint("TOPLEFT", 16, -12);
	self.ShowFlash:SetPoint("TOPRIGHT", self.Host, "TOP", -16);
	self.ShowFlash:SetHeight(self.ShowFlash:GetFixedHeight());
	self.ShowFlash.OnValueUpdated:Connect(function()
		self.Preview:Update(self.AcceptData or self.CancelData);
	end);

	-- And our selection panel.
	if(not self.Selection) then
		self.Selection = PowerAuras:Create("ScrollFrame", self.Host);
		self.Selection:SetPoint("BOTTOMRIGHT", -8, 34);
		self.Selection:SetPoint("TOPLEFT", self.Host, "TOP", 32, -40);
		self.Selection.Count = {};
		self.Selection.Total = 0;
		self.Selection.Widgets = setmetatable({}, {
			__index = function(t, i)
				-- Create button.
				t[i] = CreateFrame("CheckButton", nil, self.Selection);
				t[i]:SetSize(0, 24);
				t[i]:SetPoint("TOPLEFT", 8, -(4 + (i - 1) * 24));
				t[i]:SetPoint("TOPRIGHT", -24, -(4 + (i - 1) * 24));
				-- Add textures.
				t[i]:SetHighlightTexture(
					[[Interface\HelpFrame\KnowledgeBaseButtton]]
				);
				t[i]:GetHighlightTexture():SetTexCoord(
					0.13085938, 0.63085938, 0.0078125, 0.203125
				);
				t[i]:SetCheckedTexture(
					[[Interface\HelpFrame\KnowledgeBaseButtton]]
				);
				t[i]:GetCheckedTexture():SetTexCoord(
					0.13085938, 0.63085938, 0.0078125, 0.203125
				);
				t[i]:SetDisabledTexture(
					[[Interface\HelpFrame\KnowledgeBaseButtton]]
				);
				t[i]:GetDisabledTexture():SetDesaturated(true);
				t[i]:GetDisabledTexture():SetTexCoord(
					0.13085938, 0.63085938, 0.0078125, 0.203125
				);
				-- Add text.
				t[i].Text = t[i]:CreateFontString(nil, "OVERLAY");
				t[i].Text:SetFontObject(GameFontNormal);
				t[i].Text:SetPoint("TOPLEFT", 4, 0);
				t[i].Text:SetPoint("BOTTOMRIGHT", -4, 0);
				t[i].Text:SetJustifyH("LEFT");
				t[i].Text:SetJustifyV("MIDDLE");
				t[i]:SetFontString(t[i].Text);
				-- Set fonts.
				t[i]:SetNormalFontObject(GameFontNormalSmall);
				t[i]:SetHighlightFontObject(GameFontHighlightSmall);
				t[i]:SetDisabledFontObject(GameFontNormal);
				-- Scripts.
				t[i]:SetScript("OnEnable", function(w)
					w.Text:SetJustifyH("LEFT");
				end);
				t[i]:SetScript("OnDisable", function(w)
					w.Text:SetJustifyH("MIDDLE");
				end);
				t[i]:SetScript("OnClick", function(w)
					self:SetAcceptData(w:GetText());
					self.Selection:PerformLayout();
				end);
				return t[i];
			end,
		});

		function self.Selection:PerformLayout()
			-- Hide all templates.
			for i = 1, #(self.Widgets) do
				self.Widgets[i]:Hide();
			end
			-- Are we dirty?
			local pop = self:GetParent():GetParent();
			local barSets = PowerAuras:GetBarTemplateSets();
			local max = math.floor((self:GetHeight() - 8) / 24);
			local current = pop.AcceptData or pop.CancelData;
			if(self.Total == 0) then
				-- Damn right we are! Count all the templates. All. Go!
				local newOffset = self:GetScrollOffset();
				for name, set in pairs(barSets) do
					for i, tempName in set() do
						self.Count[name] = (self.Count[name] or 0) + 1;
						if(pop.Filter:GetItemChecked(name)) then
							self.Total = (self.Total or 0) + 1;
						end
						-- Also, do we need to scroll to our current one?
						if(not pop.AcceptData and pop.CancelData) then
							if(tempName == pop.CancelData) then
								newOffset = self.Total - 1;
							end
						end
					end
				end
				-- Update scroll range.
				local max = math.max(0, (self.Total - max));
				if(select(2, self:GetScrollRange()) ~= max) then
					self:SetScrollRange(0, max);
					self:SetScrollOffset(newOffset);
					return;
				elseif(newOffset ~= self:GetScrollOffset()) then
					self:SetScrollOffset(newOffset);
					return;
				end
			end
			-- Get scroll offset.
			local offset = self:GetScrollOffset();
			local index = 0;
			-- Get the first set.
			local name, set;
			local bykey = PowerAuras:ByKey(barSets);
			repeat
				name, set = bykey(barSets, name);
			until(not name or pop.Filter:GetItemChecked(name));
			-- Iterate over the set.
			while(name) do
				-- Can we skip this set outright?
				if(offset - self.Count[name] > 0) then
					offset = offset - self.Count[name];
				else
					-- Run over the templates in the set.
					for i, tempName, data in set() do
						-- Can we show this template?
						if(offset == 0 and index < max) then
							-- Increment index.
							index = index + 1;
							local w = self.Widgets[index];
							w.Data = data;
							w:SetChecked(tempName == current);
							w:SetText(tempName);
							w:Enable();
							w:Show();
						elseif(offset == 0 and index == max) then
							-- Time to quit.
							break;
						else
							-- Decrement offset.
							offset = offset - 1;
						end
					end
				end
				-- Can we skip the rest?
				if(offset == 0 and index == max) then
					break;
				end
				-- We hit the end of the set, next one.
				repeat
					name, set = bykey(barSets, name);
				until(not name or pop.Filter:GetItemChecked(name));
			end
		end
	end

	-- Filtering dropdowns.
	if(not self.Filter) then
		self.Filter = PowerAuras:Create("SimpleDropdown", self.Host);
		self.Filter:SetPoint("BOTTOMRIGHT", self.Selection, "TOPRIGHT", 0, 4);
		self.Filter:SetPoint("BOTTOMLEFT", self.Selection, "TOPLEFT", 0, 4);
		self.Filter:SetHeight(self.Filter:GetFixedHeight());
		self.Filter:SetRawText(L["FilterBy"]);
		-- Add options for each set.
		for set, _ in PowerAuras:ByKey(PowerAuras:GetBarTemplateSets()) do
			self.Filter:AddCheckItem(set, set, true);
		end
		self.Filter.OnValueUpdated:Connect(function(filter, set)
			-- Toggle state.
			filter:SetItemChecked(set, not filter:GetItemChecked(set));
			-- Flag the frame as being dirty.
			wipe(self.Selection.Count);
			self.Selection.Total = 0;
			self.Selection:PerformLayout();
		end);
	end

	-- And finally, accept/close buttons!
	if(not self.AcceptButton) then
		self.AcceptButton = PowerAuras:Create("Button", self.Host);
		self.AcceptButton:SetText(ACCEPT);
		self.AcceptButton:SetSize(self.AcceptButton:GetFixedSize());
		self.AcceptButton:SetPoint("BOTTOMRIGHT", -8, 8);
		self.AcceptButton:Disable();
		self.AcceptButton.OnClicked:Connect(function()
			self:Accept();
		end);
	end

	if(not self.CancelButton) then
		self.CancelButton = PowerAuras:Create("Button", self.Host);
		self.CancelButton:SetText(CANCEL);
		self.CancelButton:SetSize(self.CancelButton:GetFixedSize());
		self.CancelButton:SetPoint("RIGHT", self.AcceptButton, "LEFT", -8, 0);
		self.CancelButton.OnClicked:Connect(function()
			self:Cancel();
		end);
	end
end

--- Sets the accept data for the dialog.
-- @param data The data to set.
function Template:SetAcceptData(data)
	-- Pass call to base func.
	base(self, data);
	-- Update accept button state.
	if(not data) then
		self.AcceptButton:Disable();
	else
		self.AcceptButton:Enable();
	end
	-- Update the preview.
	self.Preview:Update(data);
end

--- Sets the cancel data for the dialog.
-- @param data The data to set.
function Template:SetCancelData(data)
	-- Set the data as normal.
	base(self, data);
	-- Reperform the layout.
	self.Selection.Total = 0;
	self.Selection:PerformLayout();
	-- Update the preview.
	self.Preview:Update(data);
end

--- Dialog for picking a counter texture.
local Counter = PowerAuras:RegisterWidget("CounterDialog", "ModalDialog");

--- Initialises the dialog, adding all of the child widgets.
function Counter:Initialise(parent)
	-- Initialise as normal.
	base(self, parent);
	-- Anchor the host frame.
	self.Host:SetPoint("TOPLEFT", 64, -56);
	self.Host:SetPoint("BOTTOMRIGHT", -64, 56);

	-- Preview panel.
	self.Preview = PowerAuras:Create("Frame", self.Host);
	self.Preview:SetPoint("TOPLEFT", 16, -48);
	self.Preview:SetSize(256, 256);

	--- Updates the preview panel with a counter texture.
	function self.Preview:Update(counter)
		-- Get the requested texture.
		counter = PowerAuras:GetCounterPath(counter);
		if(not counter) then
			self:Hide();
			return;
		else
			self.Texture = self.Texture or self:CreateTexture(nil, "OVERLAY");
			self.Texture:SetAllPoints(self);
			self.Texture:SetTexture(counter);
			self:Show();
		end
	end

	-- And our selection panel.
	if(not self.Selection) then
		self.Selection = PowerAuras:Create("ScrollFrame", self.Host);
		self.Selection:SetPoint("BOTTOMRIGHT", -8, 34);
		self.Selection:SetPoint("TOPLEFT", self.Host, "TOP", 32, -40);
		self.Selection.Count = {};
		self.Selection.Total = 0;
		self.Selection.Widgets = setmetatable({}, {
			__index = function(t, i)
				-- Create button.
				t[i] = CreateFrame("CheckButton", nil, self.Selection);
				t[i]:SetSize(0, 24);
				t[i]:SetPoint("TOPLEFT", 8, -(4 + (i - 1) * 24));
				t[i]:SetPoint("TOPRIGHT", -24, -(4 + (i - 1) * 24));
				-- Add textures.
				t[i]:SetHighlightTexture(
					[[Interface\HelpFrame\KnowledgeBaseButtton]]
				);
				t[i]:GetHighlightTexture():SetTexCoord(
					0.13085938, 0.63085938, 0.0078125, 0.203125
				);
				t[i]:SetCheckedTexture(
					[[Interface\HelpFrame\KnowledgeBaseButtton]]
				);
				t[i]:GetCheckedTexture():SetTexCoord(
					0.13085938, 0.63085938, 0.0078125, 0.203125
				);
				t[i]:SetDisabledTexture(
					[[Interface\HelpFrame\KnowledgeBaseButtton]]
				);
				t[i]:GetDisabledTexture():SetDesaturated(true);
				t[i]:GetDisabledTexture():SetTexCoord(
					0.13085938, 0.63085938, 0.0078125, 0.203125
				);
				-- Add text.
				t[i].Text = t[i]:CreateFontString(nil, "OVERLAY");
				t[i].Text:SetFontObject(GameFontNormal);
				t[i].Text:SetPoint("TOPLEFT", 4, 0);
				t[i].Text:SetPoint("BOTTOMRIGHT", -4, 0);
				t[i].Text:SetJustifyH("LEFT");
				t[i].Text:SetJustifyV("MIDDLE");
				t[i]:SetFontString(t[i].Text);
				-- Set fonts.
				t[i]:SetNormalFontObject(GameFontNormalSmall);
				t[i]:SetHighlightFontObject(GameFontHighlightSmall);
				t[i]:SetDisabledFontObject(GameFontNormal);
				-- Scripts.
				t[i]:SetScript("OnEnable", function(w)
					w.Text:SetJustifyH("LEFT");
				end);
				t[i]:SetScript("OnDisable", function(w)
					w.Text:SetJustifyH("MIDDLE");
				end);
				t[i]:SetScript("OnClick", function(w)
					self:SetAcceptData(w:GetText());
					self.Selection:PerformLayout();
				end);
				return t[i];
			end,
		});

		function self.Selection:PerformLayout()
			-- Hide all templates.
			for i = 1, #(self.Widgets) do
				self.Widgets[i]:Hide();
			end
			-- Are we dirty?
			local pop = self:GetParent():GetParent();
			local counters = PowerAuras:GetCounterSets();
			local max = math.floor((self:GetHeight() - 8) / 24);
			local current = pop.AcceptData or pop.CancelData;
			if(self.Total == 0) then
				-- Damn right we are! Count all the templates. All. Go!
				local newOffset = self:GetScrollOffset();
				for name, set in pairs(counters) do
					for i, tempName in set() do
						self.Count[name] = (self.Count[name] or 0) + 1;
						if(pop.Filter:GetItemChecked(name)) then
							self.Total = (self.Total or 0) + 1;
						end
						-- Also, do we need to scroll to our current one?
						if(not pop.AcceptData and pop.CancelData) then
							if(tempName == pop.CancelData) then
								newOffset = self.Total - 1;
							end
						end
					end
				end
				-- Update scroll range.
				local max = math.max(0, (self.Total - max));
				if(select(2, self:GetScrollRange()) ~= max) then
					self:SetScrollRange(0, max);
					self:SetScrollOffset(newOffset);
					return;
				elseif(newOffset ~= self:GetScrollOffset()) then
					self:SetScrollOffset(newOffset);
					return;
				end
			end
			-- Get scroll offset.
			local offset = self:GetScrollOffset();
			local index = 0;
			-- Get the first set.
			local name, set;
			local bykey = PowerAuras:ByKey(counters);
			repeat
				name, set = bykey(counters, name);
			until(not name or pop.Filter:GetItemChecked(name));
			-- Iterate over the set.
			while(name) do
				-- Can we skip this set outright?
				if(offset - self.Count[name] > 0) then
					offset = offset - self.Count[name];
				else
					-- Run over the templates in the set.
					for i, tempName, path in set() do
						-- Can we show this template?
						if(offset == 0 and index < max) then
							-- Increment index.
							index = index + 1;
							local w = self.Widgets[index];
							w.Path = path;
							w:SetChecked(tempName == current);
							w:SetText(tempName);
							w:Enable();
							w:Show();
						elseif(offset == 0 and index == max) then
							-- Time to quit.
							break;
						else
							-- Decrement offset.
							offset = offset - 1;
						end
					end
				end
				-- Can we skip the rest?
				if(offset == 0 and index == max) then
					break;
				end
				-- We hit the end of the set, next one.
				repeat
					name, set = bykey(counters, name);
				until(not name or pop.Filter:GetItemChecked(name));
			end
		end
	end

	-- Filtering dropdowns.
	if(not self.Filter) then
		self.Filter = PowerAuras:Create("SimpleDropdown", self.Host);
		self.Filter:SetPoint("BOTTOMRIGHT", self.Selection, "TOPRIGHT", 0, 4);
		self.Filter:SetPoint("BOTTOMLEFT", self.Selection, "TOPLEFT", 0, 4);
		self.Filter:SetHeight(self.Filter:GetFixedHeight());
		self.Filter:SetRawText(L["FilterBy"]);
		-- Add options for each set.
		for set, _ in PowerAuras:ByKey(PowerAuras:GetCounterSets()) do
			self.Filter:AddCheckItem(set, set, true);
		end
		self.Filter.OnValueUpdated:Connect(function(filter, set)
			-- Toggle state.
			filter:SetItemChecked(set, not filter:GetItemChecked(set));
			-- Flag the frame as being dirty.
			wipe(self.Selection.Count);
			self.Selection.Total = 0;
			self.Selection:PerformLayout();
		end);
	end

	-- And finally, accept/close buttons!
	if(not self.AcceptButton) then
		self.AcceptButton = PowerAuras:Create("Button", self.Host);
		self.AcceptButton:SetText(ACCEPT);
		self.AcceptButton:SetSize(self.AcceptButton:GetFixedSize());
		self.AcceptButton:SetPoint("BOTTOMRIGHT", -8, 8);
		self.AcceptButton:Disable();
		self.AcceptButton.OnClicked:Connect(function()
			self:Accept();
		end);
	end

	if(not self.CancelButton) then
		self.CancelButton = PowerAuras:Create("Button", self.Host);
		self.CancelButton:SetText(CANCEL);
		self.CancelButton:SetSize(self.CancelButton:GetFixedSize());
		self.CancelButton:SetPoint("RIGHT", self.AcceptButton, "LEFT", -8, 0);
		self.CancelButton.OnClicked:Connect(function()
			self:Cancel();
		end);
	end
end

--- Sets the accept data for the dialog.
-- @param data The data to set.
function Counter:SetAcceptData(data)
	-- Pass call to base func.
	base(self, data);
	-- Update accept button state.
	if(not data) then
		self.AcceptButton:Disable();
	else
		self.AcceptButton:Enable();
	end
	-- Update the preview.
	self.Preview:Update(data);
end

--- Sets the cancel data for the dialog.
-- @param data The data to set.
function Counter:SetCancelData(data)
	-- Set the data as normal.
	base(self, data);
	-- Reperform the layout.
	self.Selection.Total = 0;
	self.Selection:PerformLayout();
	-- Update the preview.
	self.Preview:Update(data);
end

--- Dialog for picking a font file.
local FontDialog = PowerAuras:RegisterWidget("FontDialog", "ModalDialog");

--- Initialises the dialog, adding all of the child widgets.
function FontDialog:Initialise(parent)
	-- Initialise as normal.
	base(self, parent);
	-- Anchor the host frame.
	self.Host:SetPoint("TOPLEFT", 64, -56);
	self.Host:SetPoint("BOTTOMRIGHT", -64, 56);

	-- And our selection panel.
	if(not self.Selection) then
		self.Selection = PowerAuras:Create("ScrollFrame", self.Host);
		self.Selection:SetPoint("BOTTOMRIGHT", -8, 34);
		self.Selection:SetPoint("TOPLEFT", self.Host, "TOP", -64, -40);
		self.Selection:SetPoint("TOPLEFT", 8, -40);
		self.Selection.Count = {};
		self.Selection.Total = 0;
		self.Selection.Widgets = setmetatable({}, {
			__index = function(t, i)
				-- Create button.
				t[i] = CreateFrame("CheckButton", nil, self.Selection);
				t[i]:SetSize(0, 24);
				t[i]:SetPoint("TOPLEFT", 8, -(4 + (i - 1) * 24));
				t[i]:SetPoint("TOPRIGHT", -24, -(4 + (i - 1) * 24));
				-- Add textures.
				t[i]:SetHighlightTexture(
					[[Interface\HelpFrame\KnowledgeBaseButtton]]
				);
				t[i]:GetHighlightTexture():SetTexCoord(
					0.13085938, 0.63085938, 0.0078125, 0.203125
				);
				t[i]:SetCheckedTexture(
					[[Interface\HelpFrame\KnowledgeBaseButtton]]
				);
				t[i]:GetCheckedTexture():SetTexCoord(
					0.13085938, 0.63085938, 0.0078125, 0.203125
				);
				t[i]:SetDisabledTexture(
					[[Interface\HelpFrame\KnowledgeBaseButtton]]
				);
				t[i]:GetDisabledTexture():SetDesaturated(true);
				t[i]:GetDisabledTexture():SetTexCoord(
					0.13085938, 0.63085938, 0.0078125, 0.203125
				);
				-- Add text.
				t[i].Text = t[i]:CreateFontString(nil, "OVERLAY");
				t[i].Text:SetFontObject(GameFontNormal);
				t[i].Text:SetPoint("TOPLEFT", 24, 0);
				t[i].Text:SetPoint("BOTTOMRIGHT", -4, 0);
				t[i].Text:SetJustifyH("LEFT");
				t[i].Text:SetJustifyV("MIDDLE");
				t[i].Text:SetTextColor(1, 1, 1);
				t[i]:SetFontString(t[i].Text);
				-- Set fonts.
				t[i]:SetNormalFontObject(GameFontNormalSmall);
				t[i]:SetHighlightFontObject(GameFontHighlightSmall);
				t[i]:SetDisabledFontObject(GameFontNormal);
				-- Scripts.
				t[i]:SetScript("OnEnable", function(w)
					w.Text:SetJustifyH("LEFT");
				end);
				t[i]:SetScript("OnDisable", function(w)
					w.Text:SetJustifyH("MIDDLE");
				end);
				t[i]:SetScript("OnClick", function(w)
					self:SetAcceptData(w:GetText());
					self.Selection:PerformLayout();
				end);
				return t[i];
			end,
		});

		function self.Selection:PerformLayout()
			-- Hide all fonts.
			for i = 1, #(self.Widgets) do
				self.Widgets[i]:Hide();
			end
			-- Are we dirty?
			local pop = self:GetParent():GetParent();
			local fontSets = PowerAuras:GetFontSets();
			local max = math.floor((self:GetHeight() - 8) / 24);
			local current = pop.AcceptData or pop.CancelData;
			if(self.Total == 0) then
				-- Damn right we are! Count all the fonts. All. Go!
				local newOffset = self:GetScrollOffset();
				for name, set in pairs(fontSets) do
					for i, fontName in set() do
						self.Count[name] = (self.Count[name] or 0) + 1;
						if(pop.Filter:GetItemChecked(name)) then
							self.Total = (self.Total or 0) + 1;
						end
						-- Also, do we need to scroll to our current one?
						if(not pop.AcceptData and pop.CancelData) then
							if(fontName == pop.CancelData) then
								newOffset = self.Total - 1;
							end
						end
					end
				end
				-- Update scroll range.
				local max = math.max(0, (self.Total - max));
				if(select(2, self:GetScrollRange()) ~= max) then
					self:SetScrollRange(0, max);
					self:SetScrollOffset(newOffset);
					return;
				elseif(newOffset ~= self:GetScrollOffset()) then
					self:SetScrollOffset(newOffset);
					return;
				end
			end
			-- Get scroll offset.
			local offset = self:GetScrollOffset();
			local index = 0;
			-- Get the first set.
			local name, set;
			local bykey = PowerAuras:ByKey(fontSets);
			repeat
				name, set = bykey(fontSets, name);
			until(not name or pop.Filter:GetItemChecked(name));
			-- Iterate over the set.
			while(name) do
				-- Can we skip this set outright?
				if(offset - self.Count[name] > 0) then
					offset = offset - self.Count[name];
				else
					-- Run over the fonts in the set.
					for i, fontName, path in set() do
						-- Can we show this font?
						if(offset == 0 and index < max) then
							-- Increment index.
							index = index + 1;
							local w = self.Widgets[index];
							w.Path = path;
							w:SetChecked(current == fontName);
							w.Text:SetFont(path, 16, "OUTLINE");
							w:SetText(fontName);
							w:Enable();
							w:Show();
						elseif(offset == 0 and index == max) then
							-- Time to quit.
							break;
						else
							-- Decrement offset.
							offset = offset - 1;
						end
					end
				end
				-- Can we skip the rest?
				if(offset == 0 and index == max) then
					break;
				end
				-- We hit the end of the set, next one.
				repeat
					name, set = bykey(fontSets, name);
				until(not name or pop.Filter:GetItemChecked(name));
			end
		end
	end

	-- Filtering dropdowns.
	if(not self.Filter) then
		self.Filter = PowerAuras:Create("SimpleDropdown", self.Host);
		self.Filter:SetPoint("BOTTOMRIGHT", self.Selection, "TOPRIGHT", 0, 4);
		self.Filter:SetPoint("BOTTOMLEFT", self.Selection, "TOP", 4, 4);
		self.Filter:SetHeight(self.Filter:GetFixedHeight());
		self.Filter:SetRawText(L["FilterBy"]);
		-- Add options for each set.
		for set, _ in PowerAuras:ByKey(PowerAuras:GetFontSets()) do
			self.Filter:AddCheckItem(set, set, true);
		end
		self.Filter.OnValueUpdated:Connect(function(filter, set)
			-- Toggle state.
			filter:SetItemChecked(set, not filter:GetItemChecked(set));
			-- Flag the frame as being dirty.
			wipe(self.Selection.Count);
			self.Selection.Total = 0;
			self.Selection:PerformLayout();
		end);
	end

	-- And finally, accept/close buttons!
	if(not self.AcceptButton) then
		self.AcceptButton = PowerAuras:Create("Button", self.Host);
		self.AcceptButton:SetText(ACCEPT);
		self.AcceptButton:SetSize(self.AcceptButton:GetFixedSize());
		self.AcceptButton:SetPoint("BOTTOMRIGHT", -8, 8);
		self.AcceptButton:Disable();
		self.AcceptButton.OnClicked:Connect(function()
			self:Accept();
		end);
	end

	if(not self.CancelButton) then
		self.CancelButton = PowerAuras:Create("Button", self.Host);
		self.CancelButton:SetText(CANCEL);
		self.CancelButton:SetSize(self.CancelButton:GetFixedSize());
		self.CancelButton:SetPoint("RIGHT", self.AcceptButton, "LEFT", -8, 0);
		self.CancelButton.OnClicked:Connect(function()
			self:Cancel();
		end);
	end
end

--- Sets the accept data for the dialog.
-- @param data The data to set.
function FontDialog:SetAcceptData(data)
	-- Pass call to base func.
	base(self, data);
	-- Update accept button state.
	if(not data) then
		self.AcceptButton:Disable();
	else
		self.AcceptButton:Enable();
	end
end

--- Sets the cancel data for the dialog.
-- @param data The data to set.
function FontDialog:SetCancelData(data)
	-- Set the data as normal.
	base(self, data);
	-- Reperform the layout.
	self.Selection.Total = 0;
	self.Selection:PerformLayout();
end

--- Dialog for picking a display.
local DisplayDialog = PowerAuras:RegisterWidget("DisplayDialog", "ModalDialog");

--- Initialises the dialog, adding all of the child widgets.
function DisplayDialog:Initialise(parent)
	-- Initialise as normal.
	base(self, parent);
	-- Anchor the host frame.
	self.Host:SetPoint("TOPLEFT", 64, -56);
	self.Host:SetPoint("BOTTOMRIGHT", -64, 56);

	-- And our selection panel.
	if(not self.Selection) then
		self.Selection = PowerAuras:Create("ScrollFrame", self.Host);
		self.Selection:SetPoint("BOTTOMRIGHT", -8, 34);
		self.Selection:SetPoint("TOPLEFT", 8, -8);
		self.Selection.Total = 0;
		self.Selection.Widgets = {};

		function self.Selection:PerformLayout()
			-- Handle paused layouts.
			if(self.LayoutPaused and self.LayoutPaused > 0) then
				return;
			end
			-- Recycle previews.
			self:PauseLayout();
			for i = #(self.Widgets), 1, -1 do
				tremove(self.Widgets):Recycle();
			end
			-- Count the total number of displays.
			local pop = self:GetParent():GetParent();
			local current = (pop.AcceptData or pop.CancelData);
			if(self.Total == 0) then
				for id, _ in PowerAuras:GetAllDisplays() do
					self.Total = self.Total + 1;
				end
				-- Update scroll range.
				local max = math.max(0, math.ceil((self.Total - 24) / 6));
				if(select(2, self:GetScrollRange()) ~= max) then
					self:SetScrollRange(0, max);
					if(self.LayoutPaused) then
						self.LayoutPaused = self.LayoutPaused - 1;
					end
					return;
				end
			end
			-- Show displays.
			local rowOffset, colOffset = self:GetScrollOffset(), 0;
			local rowShown = 0;
			for id, _ in PowerAuras:GetAllDisplays() do
				-- Can we draw this display?
				if(rowOffset == 0 and rowShown < 4) then
					-- Add a preview in.
					local w = PowerAuras:Create("DisplayPreview", self, id);
					w:SetPoint(
						"TOPLEFT", 8 + (colOffset * 74), -(6 + (rowShown * 74))
					);
					w:SetFixedSize(72, 72);
					w:SetSize(72, 72);
					w:Refresh();
					w:SetChecked(id == current);
					tinsert(self.Widgets, w);
					-- OnClicked callback.
					w.OnClicked:Connect([[
						local self = ...;
						local popop = self:GetParent():GetParent():GetParent();
						popop:SetAcceptData(self:GetID());
					]]);
					-- Increment offsets.
					colOffset = colOffset + 1;
					if(colOffset == 6) then
						rowShown = rowShown + 1;
						colOffset = 0;
					end
				elseif(rowOffset == 0 and rowShown >= 4) then
					break;
				else
					-- Increment offsets.
					colOffset = colOffset + 1;
					if(colOffset == 4) then
						rowOffset = rowOffset - 1;
						colOffset = 0;
					end
				end
			end
			if(self.LayoutPaused) then
				self.LayoutPaused = self.LayoutPaused - 1;
			end
		end;
	end

	-- And finally, accept/close buttons!
	if(not self.AcceptButton) then
		self.AcceptButton = PowerAuras:Create("Button", self.Host);
		self.AcceptButton:SetText(ACCEPT);
		self.AcceptButton:SetSize(self.AcceptButton:GetFixedSize());
		self.AcceptButton:SetPoint("BOTTOMRIGHT", -8, 8);
		self.AcceptButton:Disable();
		self.AcceptButton.OnClicked:Connect(function()
			self:Accept();
		end);
	end

	if(not self.CancelButton) then
		self.CancelButton = PowerAuras:Create("Button", self.Host);
		self.CancelButton:SetText(CANCEL);
		self.CancelButton:SetSize(self.CancelButton:GetFixedSize());
		self.CancelButton:SetPoint("RIGHT", self.AcceptButton, "LEFT", -8, 0);
		self.CancelButton.OnClicked:Connect(function()
			self:Cancel();
		end);
	end
end

--- Sets the accept data for the dialog.
-- @param data The data to set.
function DisplayDialog:SetAcceptData(data)
	-- Pass call to base func.
	base(self, data);
	-- Update accept button state.
	self.Selection:PerformLayout();
	if(not data) then
		self.AcceptButton:Disable();
	else
		self.AcceptButton:Enable();
	end
end

--- Sets the cancel data for the dialog.
-- @param data The data to set.
function DisplayDialog:SetCancelData(data)
	-- Set the data as normal.
	base(self, data);
	-- Reperform the layout.
	self.Selection.Total = 0;
	self.Selection:PerformLayout();
end