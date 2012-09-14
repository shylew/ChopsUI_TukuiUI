-- Lock down local environment.
local PowerAuras = _G["PowerAuras"];
setfenv(1, PowerAuras);

--- Child widget for the display editor, contains a live preview of the
--  edited display.
local Preview = PowerAuras:RegisterWidget("DisplayPreview", "ReusableWidget", {
	Backdrop = {
		bgFile   = [[Interface\Buttons\WHITE8X8]],
		edgeFile = [[Interface\Buttons\WHITE8X8]],
		edgeSize = 1,
		tile     = true,
	},	
});

--- Constructs/recycles an instance of the widget.
-- @param parent The parent frame.
function Preview:New(parent)
	-- Attempt to recycle.
	local frame = base(self);
	if(not frame) then
		-- Construct.
		frame = CreateFrame("CheckButton", nil, UIParent);
		frame:SetBackdrop(self.Backdrop);
		frame:SetBackdropColor(0.0, 0.0, 0.0, 0.5);
		frame:SetBackdropBorderColor(0.3, 0.3, 0.3, 1.0);
		frame:SetSize(100, 100);
		-- Storage table for subframes of each display type.
		frame.OnClicked = PowerAuras.Callback();
		frame.Storage = setmetatable({}, {
			__index = function(self, k)
				-- Construct frame for this type.
				self[k] = CreateFrame("Frame", nil, frame);
				self[k]:SetPoint("CENTER", 0, 0);
				self[k]:SetWidth(frame:GetFixedWidth() - 4);
				self[k]:SetHeight(frame:GetFixedHeight() - 4);
				self[k]:SetScript("OnSizeChanged", function(frame, w, h)
					-- Scale the frame down whilst keeping the aspect ratio.
					local oW, oH = frame:GetSize();
					local nW, nH = frame:GetParent():GetFixedSize();
					if(nW == 0 or nH == 0) then
						-- If there's no fixed size, update the parent's size.
						frame:GetParent():SetSize(oW + 20, oH + 20);
						return;
					end
					-- Adjust inner frame size.
					nW, nH = nW - 6, nH - 6;
					if(oW > nW and oW >= oH) then
						frame:SetSize(nW, (oH / oW * nW));
					elseif(oH > nH) then
						frame:SetSize((oW / oH * nH), nH);
					end
				end);
				return self[k];
			end,
		});
	end
	return frame;
end

--- Initialises an instance of the widget.
-- @param parent  The parent frame.
-- @param id      The ID of the display.
-- @param noClick Disables all mouse functionality.
function Preview:Initialise(parent, id, noClick)
	-- Set up sizing and padding.
	self:SetMargins(1, 1, 1, 1);
	self:SetFixedSize(98, 98);
	self:SetParent(parent);
	self:SetID(id);
	-- Contents of preview frame change based on the type of the display.
	self:Refresh();
	-- Disconnect certain script handlers if noClick is true.
	if(noClick) then
		self:SetScript("OnClick", nil);
		self:SetScript("OnEnter", nil);
		self:SetScript("OnLeave", nil);
		self:SetScript("OnMouseDown", nil);
		self:SetScript("OnMouseUp", nil);
	else
		self:SetScript("OnClick", self.OnClick);
		self:SetScript("OnEnter", self.OnEnter);
		self:SetScript("OnLeave", self.OnLeave);
		self:SetScript("OnMouseDown", self.OnMouseDown);
		self:SetScript("OnMouseUp", self.OnMouseUp);
	end
	-- Stay awhile and listen.
	self:ConnectCallback(
		PowerAuras.OnParameterChanged,
		self.OnParameterChanged
	);
	self:ConnectCallback(PowerAuras.OnOptionsEvent, self.OnOptionsEvent);
	-- Fix borders.
	if(not self:GetChecked() and not self:IsMouseOver()) then
		self:SetBackdropBorderColor(0.3, 0.3, 0.3, 1.0);
	else
		self:SetBackdropBorderColor(1.0, 0.8, 0.0, 1.0);
	end
end

--- OnClick script handler.
-- @param button The clicked button.
function Preview:OnClick(button)
	PlaySound("igMainMenuOptionCheckBoxOn");
	self:SetChecked(not self:GetChecked());
	self:OnClicked(button);
end

--- OnEnter script handler.
function Preview:OnEnter()
	base(self);
	self:SetBackdropBorderColor(1.0, 0.8, 0.0, 1.0);
end

--- OnLeave script handler.
function Preview:OnLeave()
	base(self);
	if(not self:GetChecked()) then
		self:SetBackdropBorderColor(0.3, 0.3, 0.3, 1.0);
	end
end

--- OnMouseDown script handler.
function Preview:OnMouseDown()
	self.ActiveChild:SetPoint("CENTER", 1, -1);
end

--- OnMouseUp script handler.
function Preview:OnMouseUp()
	self.ActiveChild:SetPoint("CENTER", 0, 0);
end

--- Sets the checked state of the preview.
-- @param state The state to set.
function Preview:SetChecked(state)
	self:__SetChecked(state);
	-- Update border colour.
	if(state or self:IsMouseOver()) then
		self:SetBackdropBorderColor(1.0, 0.8, 0.0, 1.0);
	else
		self:SetBackdropBorderColor(0.3, 0.3, 0.3, 1.0);
	end
end

--- OnOptionsEvent callback handler.
-- @param event  The fired event.
-- @param ...    The fired event arguments.
function Preview:OnOptionsEvent(event, ...)
	if(event == "DISPLAY_METADATA_CHANGED" and (...) == self:GetID()) then
		self:Refresh();
	elseif(event == "COROUTINE_QUEUE_END" or event == "DEFERRED_EXEC_END") then
		if(self:IsShown()) then
			self:Refresh();
		end
	end
end

--- OnParameterChanged callback handler.
-- @param value The new value.
-- @param type  The type of changed parameter.
-- @param key   The key of the parameter.
-- @param id    The ID of the changed parameter.
function Preview:OnParameterChanged(value, type, key, id)
	-- Refresh the frame if needed.
	if(type == "Display" and id == self:GetID()) then
		-- Refresh the frame.
		self:Refresh();
	end
end

--- Refreshes the display preview.
function Preview:Refresh()
	-- Quit if the display doesn't exist.
	if(not PowerAuras:HasAuraDisplay(self:GetID())) then
		return;
	end
	-- Get the display class and make it create a preview.
	local display = PowerAuras:GetAuraDisplay(self:GetID());
	self.ActiveChild = self.Storage[display["Type"]];
	local class = PowerAuras:GetDisplayClass(display["Type"]);
	class:CreatePreview(self.ActiveChild, self:GetID());
	self.ActiveChild:Show();
	-- Fix frame strata, force OnSizeChanged to run.
	if(not self.IgnoreStrata) then
		self.ActiveChild:SetFrameStrata(self:GetFrameStrata());
	else
		-- Set the stata on ourselves then.
		local strata = self.ActiveChild:GetFrameStrata();
		self:SetFrameStrata(strata);
	end
	self.ActiveChild:GetScript("OnSizeChanged")(
		self.ActiveChild, self.ActiveChild:GetSize()
	);
end

--- Recycles the widget, allowing it to be reused.
function Preview:Recycle()
	self.OnClicked:Reset();
	if(self.ActiveChild) then
		self.ActiveChild:Hide();
	end
	self.ActiveChild = nil;
	self:SetID(-1);
	self:SetChecked(false);
	base(self);
end

--- Display preview for the editor grid. Has a modified OnClick script.
local Grid = PowerAuras:RegisterWidget("GridDisplayPreview", "DisplayPreview");

--- OnClick script handler.
function Grid:OnClick()
	PlaySound("igMainMenuOptionCheckBoxOn");
	self:SetChecked(not self:GetChecked());
	self:GetParent():SetCurrentNode(bit.lshift(self:GetID(), 14));
end

--- Layout preview. Also manages the positioning of workspace display previews.
local WSLayout = PowerAuras:RegisterWidget("WorkspaceLayout", "ReusableWidget");

--- Constructs/recycles an instance of the widget.
-- @param parent The parent frame.
function WSLayout:New(parent)
	-- Attempt to recycle.
	local frame = base(self);
	if(not frame) then
		-- Construct.
		frame = CreateFrame("CheckButton", nil, UIParent);
		frame:SetBackdrop(self.Backdrop);
		frame:SetBackdropColor(0.0, 0.0, 0.0, 0.5);
		frame:SetBackdropBorderColor(0.3, 0.3, 0.3, 1.0);
		frame.OnClicked = PowerAuras.Callback();
		-- Display storage.
		frame.Displays = {};
	end
	return frame;
end

--- Initialises an instance of the widget.
-- @param parent  The parent frame.
-- @param id      The ID of the layout.
-- @param noClick Disables all mouse functionality.
function WSLayout:Initialise(parent, id, noClick)
	-- Set frame data.
	self:SetParent(parent);
	self:SetID(id);
	-- Contents of preview frame change based on the type of the layout.
	self:Refresh();
	-- Disconnect certain script handlers if noClick is true.
	if(noClick) then
		self:SetScript("OnClick", nil);
		self:SetScript("OnEnter", nil);
		self:SetScript("OnLeave", nil);
		self:SetScript("OnMouseDown", nil);
		self:SetScript("OnMouseUp", nil);
	else
		self:SetScript("OnClick", self.OnClick);
		self:SetScript("OnEnter", self.OnEnter);
		self:SetScript("OnLeave", self.OnLeave);
		self:SetScript("OnMouseDown", self.OnMouseDown);
		self:SetScript("OnMouseUp", self.OnMouseUp);
	end
	-- Stay awhile and listen.
	self:ConnectCallback(
		PowerAuras.OnParameterChanged,
		self.OnParameterChanged
	);
	-- Fix borders.
	if(not self:GetChecked() and not self:IsMouseOver()) then
		self:SetBackdropBorderColor(0.3, 0.3, 0.3, 1.0);
	else
		self:SetBackdropBorderColor(1.0, 0.8, 0.0, 1.0);
	end
end

--- Attaches a display to the layout.
-- @param id The ID of the display.
function WSLayout:AttachDisplay(id)
	self.Displays[id] = true;
	self:RefreshDisplay(id);
end

--- OnClick script handler.
-- @param button The clicked button.
function WSLayout:OnClick(button)
	PlaySound("igMainMenuOptionCheckBoxOn");
	self:SetChecked(not self:GetChecked());
	self:OnClicked(button);
end

--- OnEnter script handler.
function WSLayout:OnEnter()
	base(self);
	self:SetBackdropBorderColor(1.0, 0.8, 0.0, 1.0);
end

--- OnLeave script handler.
function WSLayout:OnLeave()
	base(self);
	if(not self:GetChecked()) then
		self:SetBackdropBorderColor(0.3, 0.3, 0.3, 1.0);
	end
end

--- Sets the checked state of the preview.
-- @param state The state to set.
function WSLayout:SetChecked(state)
	self:__SetChecked(state);
	-- Update border colour.
	if(state or self:IsMouseOver()) then
		self:SetBackdropBorderColor(1.0, 0.8, 0.0, 1.0);
	else
		self:SetBackdropBorderColor(0.3, 0.3, 0.3, 1.0);
	end
end

--- OnParameterChanged callback handler.
-- @param value The new value.
-- @param type  The type of changed parameter.
-- @param key   The key of the parameter.
-- @param id    The ID of the changed parameter.
function WSLayout:OnParameterChanged(value, type, key, id)
	-- Refresh the frame if needed.
	if(type == "Layout" and id == self:GetID()) then
		-- Refresh the frame.
		self:Refresh();
	elseif(type == "DisplayLayout" and self.Displays[id]) then
		self:RefreshDisplay(id);
	end
end

--- Refreshes the layout preview.
function WSLayout:Refresh()
	-- Get the layout class and make it create a preview.
	local layout = PowerAuras:GetLayout(self:GetID());
	local class = PowerAuras:GetLayoutClass(layout["Type"]);
	class:CreatePreview(self, self:GetID());
	-- If the frame has a size, show it.
	if(self:GetWidth() > 0 or self:GetHeight() > 0) then
		self:Show();
	else
		self:Hide();
	end
end

--- Refreshes the positioning of a display within the preview.
-- @param id The ID of the display.
function WSLayout:RefreshDisplay(id)
	-- Get the layout class and demand a refresh.
	local layout = PowerAuras:GetLayout(self:GetID());
	local class = PowerAuras:GetLayoutClass(layout["Type"]);
	class:PositionDisplayPreview(self, id);
	-- Get the display.
	local display = PowerAuras.Workspace.Displays[id];
	if(not display) then
		return;
	end
	-- Do we support moving?
	if(class:IsDisplayMoveable()) then
		display:SetMovable(true);
	else
		if(display.IsMoving) then
			display:OnMouseUp();
		end
		display:SetMovable(false);
	end
end

--- Recycles the widget, allowing it to be reused.
function WSLayout:Recycle()
	self.OnClicked:Reset();
	wipe(self.Displays);
	self:SetID(-1);
	self:SetChecked(false);
	base(self);
end

--- Display preview for the workspace, complete with pain and misery.
local WS = PowerAuras:RegisterWidget("WorkspacePreview", "DisplayPreview", {
	--- Mouse-over backdrop.
	MouseOverBackdrop = {
		bgFile = [[Interface\BUTTONS\WHITE8X8]],
		insets = { left = 6, right = 6, top = 6, bottom = 6 },
		tile = false,
	},
	--- Checked backdrop.
	SelectedBackdrop = {
		bgFile = [[Interface\BUTTONS\WHITE8X8]],
		edgeFile = [[Interface\LFGFrame\LFGBorder]],
		edgeSize = 16,
		insets = { left = 6, right = 6, top = 6, bottom = 6 },
		tile = false,
	},
});

--- OnClick handler for the preview point buttons.
-- @param button  The button.
-- @param clicked The clicked button.
local function WSPoint_OnClick(button, clicked)
	-- Do a little sound.
	PlaySound("igMainMenuOptionCheckBoxOn");
	-- Make a little parent.
	if(clicked == "LeftButton") then
		PowerAuras.Workspace:SetParentingDisplay(
			true,
			button:GetParent():GetID(),
			button.Point
		);
	else
		PowerAuras.Workspace:SetParentingDisplay(false);
	end
	-- Return tonight.
end

--- OnEnter script handler for the preview point buttons.
-- @param button The button.
local function WSPoint_OnEnter(button)
	-- Update the cursor.
	SetCursor([[Interface\Cursor\Crosshairs]]);
	-- Grab a tooltip.
	local tooltip = GameTooltip;
	tooltip:ClearLines();
	tooltip:Hide();
	-- Anchor to ourselves.
	tooltip:SetOwner(button, "ANCHOR_RIGHT");
	-- Show useful text.
	tooltip:AddDoubleLine(
		L[button.Point], button.Point,
		1, 0.8, 0, 0.5, 0.5, 0.5
	);
	tooltip:AddLine(" ");
	-- Controls vary based upon where we are.
	local display, point = PowerAuras.Workspace:GetParentingDisplay();
	if(display and not point) then
		tooltip:AddDoubleLine(
			L("TColon", L["Buttons"]["Left"]),
			L["PreviewAnchorLeftClick1"],
			1.0, 0.8, 0, 1, 1, 1
		);
	else
		tooltip:AddDoubleLine(
			L("TColon", L["Buttons"]["Left"]),
			L["PreviewAnchorLeftClick2"],
			1, 0.8, 0, 1, 1, 1
		);
	end
	-- Always show the right click option.
	tooltip:AddDoubleLine(
		L("TColon", L["Buttons"]["Right"]), L["PreviewAnchorRightClick"],
		1, 0.8, 0, 1, 1, 1
	);
	tooltip:Show();
end

--- OnLeave script handler for the preview point buttons.
-- @param button The button.
local function WSPoint_OnLeave(button)
	-- Reset tooltip and cursor.
	SetCursor(nil);
	GameTooltip:ClearLines();
	GameTooltip:Hide();
end

function WS:Initialise(parent, id)
	-- Initialise as normal.
	base(self, parent, id, false);
	-- Adjust the awesomeness that is the backdrop.
	self:UpdateBackdrop();
	-- Remove fixed sizes and strata adjustments.
	self:SetFixedSize(0, 0);
	self.IgnoreStrata = true;
	-- Allow clicking of many mouse buttons.
	self:RegisterForClicks("AnyUp");
	self:RegisterEvent("MODIFIER_STATE_CHANGED");
	-- Add subregions for points.
	if(not self.Points) then
		self.Points = {};
		for i, point in ipairs(PowerAuras.Points) do
			-- Get the point type.
			local ptype = ((i % 2) == 0 and "EDGE"
				or i == 5 and "CENTER"
				or "CORNER");
			-- Create the frame.
			local frame = CreateFrame("Button", nil, self);
			frame:RegisterForClicks("AnyUp");
			frame.Point = point;
			frame:SetNormalTexture([[Interface\Buttons\WHITE8X8]]);
			local t = frame:GetNormalTexture();
			t:SetDrawLayer("OVERLAY", 7);
			-- Colour varies based upon type.
			if(ptype == "EDGE") then
				t:SetVertexColor(0.75, 0.25, 0.0, 0.5);
			elseif(ptype == "CENTER") then
				t:SetVertexColor(0.0, 0.25, 0.75, 0.5);
			elseif(ptype == "CORNER") then
				t:SetVertexColor(0.25, 0.0, 0.75, 0.5);
			end
			-- Show/Hide display based upon parenting mode.
			frame:SetShown(not not PowerAuras.Workspace:GetParentingDisplay());
			-- Connect scripts.
			frame:SetScript("OnClick", WSPoint_OnClick);
			frame:SetScript("OnEnter", WSPoint_OnEnter);
			frame:SetScript("OnLeave", WSPoint_OnLeave);
			-- Add to points table.
			tinsert(self.Points, frame);
		end
	end
	-- Refresh the display again.
	self:Refresh();
end

--- OnClick script handler.
-- @param button The clicked button.
function WS:OnClick(button)
	-- Sound is important.
	PlaySound("igMainMenuOptionCheckBoxOn");
	self:SetChecked(not self:GetChecked());
	-- Split our ID.
	local auraID, displayID = PowerAuras:SplitAuraDisplayID(self:GetID());
	-- Handle buttons.
	if(button == "LeftButton") then
		-- Handle modifiers/options.
		if(PowerAuras.Workspace:GetParentingDisplay()) then
			-- Select parent.
			PowerAuras.Workspace:SetParentingDisplay(false);
			self:UpdateCursor();
			self:RefreshTooltip();
		elseif(IsAltKeyDown()) then
			-- Parent.
			PowerAuras.Workspace:SetParentingDisplay(true, self:GetID());
			self:UpdateCursor();
			self:RefreshTooltip();
		elseif(not IsControlKeyDown()) then
			-- Update selection.
			PowerAuras:SetCurrentAura(auraID);
			PowerAuras:SetCurrentDisplay(displayID);
		end
	else
		-- Menu.
	end
end

--- OnEnter script handler.
function WS:OnEnter()
	base(self);
	self:UpdateBackdrop();
	-- Update the mouse cursor.
	self:UpdateCursor(false);
end

--- OnEvent script handler.
-- @param event The fired event.
-- @param ...   The fired event arguments.
function WS:OnEvent(event, ...)
	--- Update the mouse cursor if a modifier is pressed.
	if(event == "MODIFIER_STATE_CHANGED") then
		self:UpdateCursor(false);
		-- Did we release the modifier key while dragging?
		if(not IsControlKeyDown() and self.IsMoving) then
			self:OnMouseUp();
		end
	end
end

--- OnLeave script handler.
function WS:OnLeave()
	base(self);
	-- Update the backdrop and reset the mouse cursor.
	self:UpdateBackdrop();
	self:UpdateCursor(true);
end

--- OnMouseDown script handler.
function WS:OnMouseDown()
	-- Bail if the modifier key isn't down.
	if(not IsControlKeyDown() or not self:IsMovable()) then
		return;
	end
	-- Begin moving.
	self:StartMoving();
	self.IsMoving = true;
	-- Close dropdown menus.
	PowerAuras:GetWidget("Dropdown"):CloseAllMenus();
	-- Calling StartMoving will set the parent to nil (so it anchors to
	-- the screen) and will dock it to the nearest quadrant. Store the
	-- modified position.
	self.DragStore = self.DragStore or {};
	self.DragStore[1], self.DragStore[2] = select(4, self:GetPoint(1));
end

--- OnMouseUp script handler.
function WS:OnMouseUp()
	-- Do nothing if not moving.
	if(not self.IsMoving) then
		return;
	end
	-- Get our display and layout information.
	local vars = PowerAuras:GetAuraDisplay(self:GetID());
	local layout = PowerAuras:GetLayout(vars["Layout"]["ID"]);
	local class = PowerAuras:GetLayoutClass(layout["Type"]);
	-- Get our new position and calculate the delta from the start.
	local x, y = select(4, self:GetPoint(1));
	local dX, dY = (x - self.DragStore[1]), (y - self.DragStore[2]);
	-- Get original display position.
	local point, parent, rel, fX, fY = class:GetDisplayAnchor(self:GetID());
	-- Stop moving the frame.
	self:StopMovingOrSizing();
	self:SetUserPlaced(false);
	self.IsMoving = false;
	-- Update the position.
	class:SetDisplayAnchor(self:GetID(), point, parent, rel, fX + dX, fY + dY);
end

--- OnSizeChanged script handler.
-- @param w The new frame width.
-- @param h The new frame height.
function WS:OnSizeChanged(w, h)
	-- Apply padding to size.
	w, h = w - 12, h - 12;
	-- Adjust our point sizes.
	for i, point in ipairs(PowerAuras.Points) do
		-- Sizing is a bit manual here.
		local frame = self.Points[i];
		if(point == "TOPLEFT") then
			frame:SetPoint(point, 6, -6);
			frame:SetSize(w / 3, h / 3);
		elseif(point == "TOP") then
			frame:SetPoint(point, 0, -6);
			frame:SetSize(w / 3, h / 3);
		elseif(point == "TOPRIGHT") then
			frame:SetPoint(point, -6, -6);
			frame:SetSize(w / 3, h / 3);
		elseif(point == "LEFT") then
			frame:SetPoint(point, 6, 0);
			frame:SetSize(w / 3, h / 3);
		elseif(point == "CENTER") then
			frame:SetPoint(point, 0, 0);
			frame:SetSize(w / 3, h / 3);
		elseif(point == "RIGHT") then
			frame:SetPoint(point, -6, 0);
			frame:SetSize(w / 3, h / 3);
		elseif(point == "BOTTOMLEFT") then
			frame:SetPoint(point, 6, 6);
			frame:SetSize(w / 3, h / 3);
		elseif(point == "BOTTOM") then
			frame:SetPoint(point, 0, 6);
			frame:SetSize(w / 3, h / 3);
		elseif(point == "BOTTOMRIGHT") then
			frame:SetPoint(point, -6, 6);
			frame:SetSize(w / 3, h / 3);
		end
	end
end

--- Called when the tooltip for the widget should be shown.
-- @param tooltip The tooltip frame.
function WS:OnTooltipShow(tooltip)
	-- Do nothing if in parenting mode.
	if(PowerAuras.Workspace:GetParentingDisplay()) then
		return;
	end
	-- Anchor the tooltip.
	tooltip:SetOwner(self, "ANCHOR_RIGHT");
	-- Add informative text.
	local vars = PowerAuras:GetAuraDisplay(self:GetID());
	local layout = PowerAuras:GetLayout(vars["Layout"]["ID"]);
	local class = PowerAuras:GetLayoutClass(layout["Type"]);
	local auraID, displayID = PowerAuras:SplitAuraDisplayID(self:GetID());
	tooltip:AddDoubleLine(
		L("DisplayID", displayID), L("AuraID", auraID), 
		1, 0.8, 0, 0.5, 0.5, 0.5
	);
	-- Add basic display related information.
	tooltip:AddDoubleLine(
		L("TColon", L["Type"]), L["DisplayClasses"][vars["Type"]]["Name"],
		1, 0.8, 0, 1, 1, 1
	);
	-- Determine the main trigger if possible.
	local main = PowerAuras:GetMainTrigger(self:GetID(), true);
	local mainName = L["Multiple"];
	if(main) then
		-- Get the trigger.
		local actions = vars["Actions"];
		local action = PowerAuras:GetAuraAction(actions["DisplayActivate"]);
		local tri = action["Triggers"][main];
		mainName = L["TriggerClasses"][tri["Type"]]["Name"];
	end
	-- Add activation line.
	tooltip:AddDoubleLine(
		L("TColon", L["Activation"]), mainName,
		1, 0.8, 0, 1, 1, 1
	);
	-- Controls.
	tooltip:AddLine(" ");
	-- Normal controls.
	tooltip:AddDoubleLine(
		L("TColon", L["Buttons"]["Left"]), L["PreviewLeftClick"],
		1, 0.8, 0, 1, 1, 1
	);
	-- Requires moveable displays.
	if(class:IsDisplayMoveable(self:GetID())) then
		tooltip:AddDoubleLine(
			L("TColon",
				L("ModButtons1",
					L["Modifiers"]["Ctrl"],
					L["Buttons"]["Left"]
				)
			),
			L["PreviewCtrlLeftClick"],
			1, 0.8, 0, 1, 1, 1
		);
	end
	-- Requires parentable displays.
	if(class:IsDisplayParentable(self:GetID())) then
		tooltip:AddDoubleLine(
			L("TColon",
				L("ModButtons1",
					L["Modifiers"]["Alt"],
					L["Buttons"]["Left"]
				)
			),
			L["PreviewAltLeftClick"],
			1, 0.8, 0, 1, 1, 1
		);
	end
end

--- Sets the checked state of the preview.
-- @param state The state to set.
function WS:SetChecked(state)
	self:__SetChecked(state);
end

--- Updates the backdrop used by the preview.
function WS:UpdateBackdrop()
	-- Checked?
	if(self:GetChecked() and self:IsEnabled()) then
		self:SetBackdrop(self.SelectedBackdrop);
	elseif(GetMouseFocus() == self and self:IsEnabled()) then
		-- Hover.
		self:SetBackdrop(self.MouseOverBackdrop);
	else
		self:SetBackdrop(nil);
	end
	-- Fix colours.
	self:SetBackdropColor(0.0, 1.0, 0.0, 0.25);
	self:SetBackdropBorderColor(1.0, 1.0, 1.0, 1.0);
end

--- Updates the mouse cursor.
-- @param reset If true, resetting the mouse cursor is allowed.
function WS:UpdateCursor(reset)
	-- Is our mouse over the thing?
	if(GetMouseFocus() ~= self and reset) then
		-- It isn't, and we have reset permission.
		SetCursor(nil);
	elseif(GetMouseFocus() == self) then
		-- It is, so handle modifiers.
		if(IsControlKeyDown()) then
			SetCursor([[Interface\CURSOR\UI-Cursor-Move]]);
		else
			-- Reset cursor.
			SetCursor([[Interface\CURSOR\EngineerSkin]]);
		end
	end
end