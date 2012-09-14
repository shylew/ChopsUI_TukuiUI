-- Lock down local environment.
local PowerAuras = _G["PowerAuras"];
setfenv(1, PowerAuras);

--- Dropdown widget, for controlling values with a menu.
local Dropdown = PowerAuras:RegisterWidget("Dropdown", "ScrollFrame");

--- Constructs a new instance of the Dropdown widget.
-- @param parent The parent of the widget.
-- @param level  The level of the menu. Should default to 1.
-- @param key    The key of the item that spawned this menu. Will usually
--               be nil if level is 1.
function Dropdown:New(parent, level, key)
	-- Create the instance list.
	self.DropdownMenus = (self.DropdownMenus or {});
	-- Cap the level.
	level = math.min(level, #(self.DropdownMenus) + 1);
	-- Try to recycle.
	local frame = (self.DropdownMenus[level] or base(self));
	frame:SetBackdropColor(0.0, 0.0, 0.0, 1.0);
	-- If requesting a menu that is at a level which is already opened,
	-- then we close the existing one.
	if(self.DropdownMenus[level] and self.DropdownMenus[level]:IsShown()) then
		self.DropdownMenus[level]:CloseMenu();
	end
	-- Store the frame.
	self.DropdownMenus[level] = frame;
	-- Add a close button if necessary.
	if(not frame.Close) then
		frame.Close = CreateFrame("Button", nil, frame);
		frame.Close:RegisterForClicks("AnyUp");
		frame.Close:SetSize(16, 16);
		frame.Close:SetPoint("TOPRIGHT", -3, -3);
		frame.Close:SetScript("OnClick", self.OnCloseClick);
		frame.Close:SetNormalTexture(
			[[Interface\FriendsFrame\UI-Toast-CloseButton-Up]]
		);
		frame.Close:SetPushedTexture(
			[[Interface\FriendsFrame\UI-Toast-CloseButton-Down]]
		);
		frame.Close:SetHighlightTexture(
			[[Interface\FriendsFrame\UI-Toast-CloseButton-Highlight]]
		);
	end
	-- Item storage.
	frame.ItemStore = (frame.ItemStore or setmetatable({}, { __mode = "kv" }));
	frame.Items = (frame.Items or {});
	frame.Widgets = (frame.Widgets or {});
	-- Callback object.
	frame.OnValueUpdated = (frame.OnValueUpdated or PowerAuras:Callback());
	frame.OnMenuRefreshed = (frame.OnMenuRefreshed or PowerAuras:Callback());
	frame.OnMenuClosed = (frame.OnMenuClosed or PowerAuras:Callback());
	-- Anchoring and levels.
	frame.Anchor = (frame.Anchor or {});
	frame.Level = level;
	-- Done.
	frame:SetParent(parent or UIParent);
	return frame;
end

--- Called when the frame has been constructed.
function Dropdown:Initialise(parent, level, key)
	self.LayoutType = "Auto";
	self:SetFixedHeight(10);
	self:SetToplevel(true);
	self:SetFrameStrata("DIALOG");
	self:SetClosable(false);
	self:SetParentKey(key);
end

--- Adds a checkable menu item to the list.
-- @param key     The key of the item. Must be unique.
-- @param state   The state of the check item as a boolean. True if checked.
-- @param value   Text to display on the item.
-- @param style   True if the item should be a checkbox, and not a radiobutton.
-- @Param tooltip Optional tooltip text/callback.
function Dropdown:AddCheckItem(key, state, value, style, tooltip)
	-- Validate key doesn't exist.
	if(self:FindItem(key)) then
		error(("Dropdown item with key '%s' already exists."):format(
			tostring(key)
		));
	end
	-- Register.
	local item = tremove(self.ItemStore) or {};
	item["Type"], item["Key"], item["State"], item["Value"], item["Style"] = 
		"Check", key, not not state, value, not not style;
	item["Tooltip"] = tooltip;
	-- Insert into item list.
	tinsert(self.Items, item);
	-- Update layout.
	self:PerformLayout();
end

--- Adds a normal button item to the dropdown.
-- @param key     The key of the item. Must be unique.
-- @param icon    Optional path to an icon to display.
-- @param value   Text to display on the item.
-- @Param tooltip Optional tooltip text/callback.
function Dropdown:AddItem(key, icon, value, tooltip)
	-- Validate key doesn't exist.
	if(self:FindItem(key)) then
		error(("Dropdown item with key '%s' already exists."):format(
			tostring(key)
		));
	end
	-- Register.
	local item = tremove(self.ItemStore) or {};
	item["Type"], item["Key"], item["Icon"], item["Value"] =
		"Item", key, icon or "", value;
	item["Tooltip"] = tooltip;
	-- Insert into item list.
	tinsert(self.Items, item);
	-- Update layout.
	self:PerformLayout();
end

--- Adds a non-clickable label item to the dropdown.
-- @param key     The key of the item. Must be unique.
-- @param value   Text to display on the item.
-- @Param tooltip Optional tooltip text/callback.
function Dropdown:AddLabel(key, value, tooltip)
	-- Validate key doesn't exist.
	if(self:FindItem(key)) then
		error(("Dropdown item with key '%s' already exists."):format(
			tostring(key)
		));
	end
	-- Register.
	local item = tremove(self.ItemStore) or {};
	item["Type"], item["Key"], item["Value"] = "Label", key,
		value;
	item["Tooltip"] = tooltip;
	-- Insert into item list.
	tinsert(self.Items, item);
	-- Update layout.
	self:PerformLayout();
end

--- Adds a submenu to the dropdown, which will open when this item is
--  activated via mouse movement.
-- @param key      The key of the item. Must be unique.
-- @param callback Function to execute in order to populate the dropdown.
-- @param value    Text to display on the item.
-- @Param tooltip  Optional tooltip text/callback.
function Dropdown:AddMenu(key, callback, value, tooltip)
	-- Validate key doesn't exist.
	if(self:FindItem(key)) then
		error(("Dropdown item with key '%s' already exists."):format(
			tostring(key)
		));
	end
	-- Register.
	local item = tremove(self.ItemStore) or {};
	item["Type"], item["Key"], item["Callback"], item["Value"] =
		"Menu", key, callback, value;
	item["Tooltip"] = tooltip;
	-- Insert into item list.
	tinsert(self.Items, item);
	-- Update layout.
	self:PerformLayout();
end

--- Adds a raw item to the dropdown. A raw item won't be wiped or tampered
--  with in any way, and can be used for more efficient memory usage.
-- @param item The item table to add.
-- @remarks Adds a boolean key (Raw) to the item table temporarily/
function Dropdown:AddRawItem(item)
	item.Raw = true;
	tinsert(self.Items, item);
	self:PerformLayout();
end

--- Removes all items from the dropdown list.
function Dropdown:ClearItems()
	self:PauseLayout();
	while(#(self.Items) > 0) do
		self:RemoveItem(self.Items[#(self.Items)].Key);
	end
	self:ResumeLayout();
end

--- Closes all menus.
-- @remarks self can either be the class or an instance of the class.
function Dropdown:CloseAllMenus()
	local class = (self == Dropdown and self or self.Class);
	-- Ensure validity of class.
	if(not class or not class.DropdownMenus) then
		return;
	end
	-- Close the root menu, this will chain to lower level menus automatically.
	if(class.DropdownMenus[1]) then
		class.DropdownMenus[1]:CloseMenu();
	end
end

--- Closes all menus that have a level that is higher than this one.
function Dropdown:CloseChildMenus()
	local menus = self.Class.DropdownMenus;
	for i = #(menus), self:GetLevel() + 1, -1 do
		if(menus[i]:IsShown()) then
			menus[i]:CloseMenu();
		end
	end
end

--- Closes the menu, recycling it, firing a callback and closing any other
--  menus with a higher level.
function Dropdown:CloseMenu()
	-- Close child menus first.
	self:CloseChildMenus();
	-- Fire callback.
	self:OnMenuClosed();
	self:Recycle();
end

--- Finds a dropdown item with the specified key. If the item is not found,
--  nil is returned.
-- @param key The item key.
function Dropdown:FindItem(key)
	for i = #(self.Items), 1, -1 do
		if(self.Items[i].Key == key) then
			return i, self.Items[i];
		end
	end
end

--- Returns the level of the dropdown menu.
function Dropdown:GetLevel()
	return self.Level;
end

--- Returns the screen pixel distances from each edge of the visible UI.
--  If value is < 0, then the edge is offscreen. Edges are returned in 
--  order of Left, Right, Top and Bottom.
function Dropdown:GetScreenEdgeDistance()
	-- GetLeft/Get* methods can sometimes return nil.
	if(not self:GetLeft()) then
		PrintDebug("[GetScreenEdgeDistance] Invalid edges, defaulting to 0.");
		return 0, 0, 0, 0;
	else
		local scale = self:GetEffectiveScale();
		return self:GetLeft() / scale,
			(GetScreenWidth() - self:GetRight()) / scale,
			(GetScreenHeight() - self:GetTop()) / scale,
			self:GetBottom() / scale;
	end
end

--- Returns the key of the item that owns this menu, if an item owns it.
function Dropdown:GetParentKey()
	return self.ParentKey;
end

--- Returns the widget that owns the toplevel menu (the menu at level 1). If
--  no parent could be found, this will return nil.
-- @remarks This function may be called on an instance or from the class
--          directly.
function Dropdown:GetTopLevelParent()
	local class = (self == Dropdown and self or self.Class);
	-- Ensure validity of class.
	if(not class or not class.DropdownMenus) then
		return;
	end
	-- The toplevel parent is the owner of the menu at level #1.
	local menu = class.DropdownMenus[1];
	if(menu and menu:IsShown()) then
		return menu:GetParent();
	end
end

--- Returns true if the dropdown menu is using the automated anchor system.
function Dropdown:HasAnchor()
	return not not self.Anchor[1];
end

--- Checks whether or not the dropdown has a close button displayed.
function Dropdown:IsClosable()
	return self.Close:IsShown();
end

--- Checks whether or not the dropdown menu is fully onscreen.
-- @param x True to check the horizontal axis.
-- @param y True to check the vertical axis.
function Dropdown:IsFullyVisible(x, y)
	local left, right, top, bottom = self:GetScreenEdgeDistance();
	return x and not (left < 0 or right < 0)
		or y and not (top < 0 or bottom < 0);
end

--- Called when the close button is clicked. Closes the menu, of course.
function Dropdown:OnCloseClick()
	PlaySound("UChatScrollButton");
	self:GetParent():CloseMenu();
end

--- Called when the dropdown menu size (width/height) is changed.
function Dropdown:OnSizeChanged()
	self:UpdateAnchor();
end

--- Recycles the widget, allowing it to be reused in the future.
function Dropdown:Recycle()
	self.OnValueUpdated:Reset();
	self.OnMenuRefreshed:Reset();
	self.OnMenuClosed:Reset();
	self:SetAnchor(nil);
	self:ClearItems();
	base(self);
	self:SetParent(nil);
end

--- Refreshes the menu, clearing all items and calling the OnMenuRefreshed
--  callback.
function Dropdown:RefreshMenu()
	-- Lock layout, clear, refresh, unlock.
	self:PauseLayout();
	self:ClearItems();
	self:OnMenuRefreshed();
	self:ResumeLayout();
end

--- Removes an item from the dropdown with the specified key.
-- @param key The item key.
function Dropdown:RemoveItem(key)
	-- Find the item.
	local index, item = self:FindItem(key);
	if(not item) then
		error(("No dropdown menu item with key '%s' was found."):format(
			tostring(key)
		));
	end
	-- Destroy submenu items properly.
	if(item.Type == "Menu") then
		self:CloseChildMenus();
	end
	-- Remove items.
	tremove(self.Items, index);
	if(not item.Raw) then
		wipe(item);
		tinsert(self.ItemStore, item);
	else
		item.Raw = nil;
	end
	-- Reperform a layout.
	self:PerformLayout();
end

--- Performs the layout of all items within the dropdown.
function Dropdown:PerformLayout()
	-- Check if layout is locked. If so, bail.
	if(not base(self)) then
		return;
	end
	-- Adjust the sizing/scrolling of the frame.
	if(self.LayoutType == "Auto") then
		-- Adjust height.
		self:SetHeight((#(self.Items) * 24) + 8);
		-- No scrolling.
		local _, max = self:GetScrollRange();
		if(max ~= 0) then
			return self:SetScrollRange(0, 0);
		end
	elseif(self.LayoutType == "Scroll") then
		-- Respect minimum fixed size.
		local minHeight = self:GetFixedHeight() or 0;
		if(minHeight > 0 and #(self.Items) <= minHeight) then
			-- Just adjust height.
			self:SetHeight((#(self.Items) * 24) + 8);
			-- No scrolling.
			local _, max = self:GetScrollRange();
			if(max ~= 0) then
				return self:SetScrollRange(0, 0);
			end
		else
			-- Fix the scroll range of the dropdown.
			self:SetHeight((minHeight * 24) + 8);
			local visible = #(self.Items) - floor(self:GetHeight() / 24);
			local max = math.max(0, visible);
			if(select(2, self:GetScrollRange()) ~= max) then
				return self:SetScrollRange(0, max);
			end
		end
	end
	-- Recycle existing widgets.
	for i = #(self.Widgets), 1, -1 do
		tremove(self.Widgets):Recycle();
	end
	-- Construct new widgets for each item.
	local offset = self:GetScrollOffset();
	for i = offset + 1, #(self.Items) do
		local item = self.Items[i];
		local widget;
		-- Constructed item varies based on type.
		if(item.Type == "Check") then
			widget = PowerAuras:Create("DropdownCheckItem",
				self, item.Key, item.Value, item.State, item.Style);
		elseif(item.Type == "Label") then
			widget = PowerAuras:Create("DropdownLabelItem",
				self, item.Key, item.Value);
		elseif(item.Type == "Menu") then
			widget = PowerAuras:Create("DropdownMenuItem",
				self, item.Key, item.Value, item.Callback);
		else
			-- Default item is the basic one.
			widget = PowerAuras:Create("DropdownBasicItem",
				self, item.Key, item.Value, item.Icon);
		end
		-- Apply tooltip text.
		widget:SetTooltipText(item.Tooltip);
		-- Position the widget accordingly.
		widget:SetPoint("TOPLEFT", 4, -((i - offset - 1) * 24) - 4);
		if(self.ScrollBar:IsShown()) then
			widget:SetPoint("TOPRIGHT", -24, -((i - offset - 1) * 24) - 4);
		else
			widget:SetPoint("TOPRIGHT", -4, -((i - offset - 1) * 24) - 4);
		end
		widget:SetSize(0, 24);
		widget:Show();
		tinsert(self.Widgets, widget);
		-- Was this the last widget?
		if((i - offset) == floor(self:GetHeight() / 24)) then
			break;
		end
	end
	-- Update the custom anchors.
	self:UpdateAnchor();
end

--- Anchors the dropdown menu to an existing frame. This will automatically
--  alter the anchored point and offsets if the menu cannot fit onto the
--  screen. This should not be used in conjunction with manual SetPoint calls,
--  either use this or SetPoint. Only one anchor may be set.
-- @param frame The frame to anchor to. If nil, the anchor is cleared.
-- @param point The point of the menu to be anchored.
-- @param rel   The point to anchor to on the frame.
-- @param x     Optional initial X co-ordinate offset. Defaults to 0.
-- @param y     Optional initial Y co-ordinate offset. Defaults to 0.
function Dropdown:SetAnchor(frame, point, rel, x, y)
	if(not frame) then
		-- Clear anchor.
		wipe(self.Anchor);
	else
		-- Fix missing parameters,
		point, rel = (point or "TOPLEFT"), (rel or "BOTTOMLEFT");
		x, y = (x or 0), (y or 0);
		-- Set anchor.
		local a = self.Anchor;
		a[1], a[2], a[3], a[4], a[5] = frame, point, rel, x, y;
	end
	-- Update.
	self:UpdateAnchor();
end

--- Sets whether or not the dropdown has a close button displayed.
-- @param state True if a button should be displayed, false if not. Defaults
--              to false.
function Dropdown:SetClosable(state)
	if(state) then
		self.Close:Show();
	else
		self.Close:Hide();
	end
end

--- Sets the layout type for the dropdown.
-- @param type Either "Auto" or "Scroll". Auto will automatically resize
--             the height of the dropdown to accomodate all items, Scroll will
--             apply a scrollbar. A minimum size can be specified via
--             SetFixedHeight, which will resize the frame when in Scroll
--             mode until it hits the height, at which point scrolling will
--             be enabled.
function Dropdown:SetLayoutType(type)
	self.LayoutType = (type == "Scroll" and type or "Auto");
	self:PerformLayout();
end

--- Returns the key of the item that owns this menu, if an item owns it.
function Dropdown:SetParentKey(key)
	self.ParentKey = key;
end

do
	--- Flips an anchor point on the specified axes.
	-- @param point The point to flip.
	-- @param x     True if the point should be flipped horizontally.
	-- @param y     True if the point should be flipped vertically.
	local function FlipPoint(point, x, y)
		if(x) then
			point = point:find("LEFT$") and point:gsub("(.*)LEFT$", "%1RIGHT")
				or point:find("RIGHT$") and point:gsub("(.*)RIGHT$", "%1LEFT")
				or point;
		end
		if(y) then
			point = point:find("^TOP") and point:gsub("^TOP(.*)", "BOTTOM%1")
				or point:find("^BOTTOM") and point:gsub("^BOTTOM(.*)", "TOP%1")
				or point;
		end
		return point;
	end

	--- Updates the automated anchor to ensure that the full menu is on-screen.
	function Dropdown:UpdateAnchor()
		-- Only update if using the anchor system.
		if(not self:HasAnchor()) then
			return;
		end
		-- Clear all custom set points.
		self:ClearAllPoints();
		-- Set point, test if menu is fully onscreen.
		local frame, point, rel, x, y = unpack(self.Anchor);
		self:SetPoint(point, frame, rel, x, y);
		-- Get screen edge distances.
		local left, right, top, bottom = self:GetScreenEdgeDistance();
		-- Code based on Blizzard's implementation in UIDropdownMenu.
		if(not self:IsFullyVisible(true, false)) then
			-- Flip and update point.
			point = FlipPoint(point, true, false);
			rel = FlipPoint(rel, true, false);
			x = -x;
			self:ClearAllPoints();
			self:SetPoint(point, frame, rel, x, y);
			if(not self:IsFullyVisible(true, false)) then
				-- Flipping did nothing, revert.
				point, rel = select(2, unpack(self.Anchor));
				-- The edge distances are in screen coordinates, so scale them.
				local adj = (left < 0 and -left or right < 0 and right or 0);
				x = -x + (adj * self:GetEffectiveScale());
				self:ClearAllPoints();
				self:SetPoint(point, frame, rel, x, y);
			end
		end
		-- Now test the same vertically!
		if(not self:IsFullyVisible(false, true)) then
			-- Flip and update point.
			point = FlipPoint(point, false, true);
			rel = FlipPoint(rel, false, true);
			y = -y;
			self:ClearAllPoints();
			self:SetPoint(point, frame, rel, x, y);
			if(not self:IsFullyVisible(false, true)) then
				-- Flipping did nothing, revert.
				point, rel = select(2, unpack(self.Anchor));
				-- The edge distances are in screen coordinates, so scale them.
				local adj = (top < 0 and -top or bottom < 0 and bottom or 0);
				y = -y + (adj * self:GetEffectiveScale());
				self:ClearAllPoints();
				self:SetPoint(point, frame, rel, x, y);
			end
		end
	end
end

--- Generic dropdown item template. Abstract, cannot be instantiated.
local Item = PowerAuras:RegisterWidget("DropdownItem", "ReusableWidget");

--- Constructs a new instance of a dropdown item widget. Prevents instantiation
--  of the item class itself.
-- @param parent The parent dropdown of the item.
-- @param type   The type of frame to construct by default. Must be either
--               Button or CheckButton.
function Item:New(parent, type)
	-- Ensure that this class isn't being instantiated directly.
	if(self == Item) then
		error(L("GUIErrorWidgetClassAbstract", "DropdownItem"));
	else
		-- Validate the type arg.
		type = (type == "CheckButton" and type or "Button");
		local frame = base(self) or CreateFrame(type);
		frame:SetParent(parent or UIParent);
		return frame;
	end
end

--- Initialises the item, storing the key and level as well as updating the
--  label text.
-- @param parent  The parent dropdown of the item.
-- @param key     The key of the item.
-- @param value   The text to display on the item.
function Item:Initialise(parent, key, value)
	self.ItemKey = key;
	self.TooltipText = nil;
	self:SetText(value);
end

--- OnClick handler for the item. Fires the OnValueUpdated callback in the
--  parent dropdown with the passed arguments and the key.
-- @param ... Additional arguments to pass to the callback.
function Item:OnClick(...)
	PlaySound("UChatScrollButton");
	local parent = self:GetParent();
	parent:OnValueUpdated(self.ItemKey, ...);
end

--- OnEnter script handler for the item. Closes any dropdown menus that
--  are at a higher level than the owners level.
function Item:OnEnter()
	-- Forcibly close any menus that are on higher levels.
	self:GetParent():CloseChildMenus();
	base(self);
end

--- OnTooltipShow handler. Called when the item is mouseovered.
-- @param tooltip The tooltip frame to use.
function Item:OnTooltipShow(tooltip)
	-- Skip if we have no tooltip.
	if(not self.TooltipText) then
		return;
	end
	-- Custom or automatic?
	if(type(self.TooltipText) == "function") then
		self.TooltipText(self, tooltip, self.ItemKey);
	elseif(type(self.TooltipText) == "string") then
		-- Set main text and description labels.
		tooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
		tooltip:AddLine(self:GetText());
		tooltip:AddLine(self.TooltipText, 1, 1, 1, true);
	end
end

--- Recycles the item, allowing it to be reused in the future.
function Item:Recycle()
	self:SetText("");
	self.ItemKey = nil;
	base(self);
end

--- Sets the displayed tooltip text.
-- @param text The text to show. Can be either a string, or a callback
--             function.
function Item:SetTooltipText(text)
	self.TooltipText = ((type(text) == "function"
			or type(text) == "string")
		and text
		or nil);
end

--- Basic clickable dropdown item. Does not have a checkbox or any
--  brilliant, innovative behaviours.
local Basic = PowerAuras:RegisterWidget("DropdownBasicItem", "DropdownItem");

--- Constructs a new instance of the dropdown item.
-- @param parent The parent dropdown of the item.
-- @param key    The key of the item.
-- @param value  The text to display on the item.
-- @param icon   Path to an icon to display on the item.
function Basic:New(parent, key, value, icon)
	-- Construct a frame, apply extras to it.
	local frame = base(self, parent, "Button");
	-- Add fontstring.
	if(not frame.Text) then
		frame.Text = frame:CreateFontString(nil, "OVERLAY");
		frame.Text:SetPoint("BOTTOMRIGHT", -4, 0);
		frame.Text:SetJustifyV("MIDDLE");
		frame.Text:SetJustifyH("LEFT");
		frame.Text:SetWordWrap(false);
		frame.Text:SetFontObject(GameFontHighlightSmall);
		frame:SetFontString(frame.Text);
	end
	-- Apply textures.
	if(not frame:GetHighlightTexture()) then
		frame:SetHighlightTexture([[Interface\HelpFrame\KnowledgeBaseButtton]]);
		frame:GetHighlightTexture():SetTexCoord(
			0.13085938, 0.63085938, 0.0078125, 0.203125
		);
	end
	-- Icon texture.
	frame.Text:SetPoint("TOPLEFT", (icon and icon ~= "" and 28 or 4), 0);
	if(icon) then
		if(not frame:GetNormalTexture()) then
			frame:SetNormalTexture(icon);
		else
			frame:GetNormalTexture():SetTexture(icon);
		end
		frame:GetNormalTexture():ClearAllPoints();
		frame:GetNormalTexture():SetPoint("TOPLEFT", 5, -4);
		frame:GetNormalTexture():SetSize(16, 16);
	elseif(frame:GetNormalTexture()) then
		frame:GetNormalTexture():SetTexture(nil);
	end
	return frame;
end

--- Checkable dropdown item. Has a simple boolean state and a checkbox
--  display.
local Check = PowerAuras:RegisterWidget("DropdownCheckItem", "DropdownItem");

--- Constructs a new instance of the dropdown item.
-- @param parent The parent dropdown of the item.
-- @param key    The key of the item.
-- @param value  The text to display on the item.
-- @param state  The checked state of the button.
-- @param style  True to style as a checkbutton, false for a radiobutton.
function Check:New(parent, key, value, state, style)
	-- Construct a frame, apply extras to it.
	local frame = base(self, parent, "CheckButton");
	-- Add fontstring.
	if(not frame.Text) then
		frame.Text = frame:CreateFontString(nil, "OVERLAY");
		frame.Text:SetPoint("TOPLEFT", 28, 0);
		frame.Text:SetPoint("BOTTOMRIGHT", -4, 0);
		frame.Text:SetJustifyV("MIDDLE");
		frame.Text:SetJustifyH("LEFT");
		frame.Text:SetWordWrap(false);
		frame.Text:SetFontObject(GameFontHighlightSmall);
		frame:SetFontString(frame.Text);
	end
	-- Apply textures.
	if(not frame:GetNormalTexture()) then
		frame:SetNormalTexture([[Interface\Buttons\UI-RADIOBUTTON]]);
		frame:GetNormalTexture():SetTexCoord(0.0, 0.25, 0, 1);
		frame:GetNormalTexture():ClearAllPoints();
		frame:GetNormalTexture():SetPoint("TOPLEFT", 3, -4);
		frame:GetNormalTexture():SetSize(16, 16);
	end
	if(not frame:GetCheckedTexture()) then
		frame:SetCheckedTexture([[Interface\Buttons\UI-RADIOBUTTON]]);
		frame:GetCheckedTexture():SetTexCoord(0.25, 0.50, 0, 1);
		frame:GetCheckedTexture():ClearAllPoints();
		frame:GetCheckedTexture():SetPoint("TOPLEFT", 3, -4);
		frame:GetCheckedTexture():SetSize(16, 16);
	end
	if(not frame:GetHighlightTexture()) then
		-- There's two highlight textures for this.
		frame:SetHighlightTexture([[Interface\HelpFrame\KnowledgeBaseButtton]]);
		frame:GetHighlightTexture():SetTexCoord(
			0.13085938, 0.63085938, 0.0078125, 0.203125
		);
		frame.H2 = frame:CreateTexture(nil, "HIGHLIGHT");
		frame.H2:SetTexture([[Interface\Buttons\UI-RADIOBUTTON]]);
		frame.H2:SetTexCoord(0.50, 0.75, 0, 1);
		frame.H2:SetBlendMode("ADD");
		frame.H2:SetPoint("TOPLEFT", 3, -4);
		frame.H2:SetSize(16, 16);
	end
	-- Update textures based on selection style.
	local ct, nt = frame:GetCheckedTexture(), frame:GetNormalTexture();
	if(style) then
		nt:SetTexture([[Interface\Common\UI-DropDownRadioChecks]]);
		nt:SetTexCoord(0.5, 1.0, 0.0, 0.5);
		ct:SetTexture([[Interface\Common\UI-DropDownRadioChecks]]);
		ct:SetTexCoord(0.0, 0.5, 0.0, 0.5);
		frame.H2:Hide();
	else
		ct:SetTexture([[Interface\Buttons\UI-RADIOBUTTON]]);
		ct:SetTexCoord(0.25, 0.50, 0.0, 1.0);
		nt:SetTexture([[Interface\Buttons\UI-RADIOBUTTON]]);
		nt:SetTexCoord(0.00, 0.25, 0.0, 1.0);
		frame.H2:Show();
	end
	-- Set checked state and return.
	frame:SetChecked(state);
	return frame;
end

--- OnClick script handler for a check item.
function Check:OnClick(...)
	self:SetChecked(not self:GetChecked());
	base(self, not self:GetChecked(), ...);
end

--- Unclickable label item. Even more boring than DropdownBasicItem.
--  Favourite ice-cream flavour is clearly vanilla.
local Label = PowerAuras:RegisterWidget("DropdownLabelItem", "DropdownItem");

--- Constructs a new instance of the dropdown item.
-- @param parent The parent dropdown of the item.
-- @param key    The key of the item.
-- @param value  The text to display on the item.
function Label:New(parent, key, value)
	-- Construct a frame, apply extras to it.
	local frame = base(self, parent, "Button");
	frame:Disable();
	-- Add fontstring.
	if(not frame.Text) then
		frame.Text = frame:CreateFontString(nil, "OVERLAY");
		frame.Text:SetPoint("TOPLEFT", 4, 0);
		frame.Text:SetPoint("BOTTOMRIGHT", -4, 0);
		frame.Text:SetJustifyV("MIDDLE");
		frame.Text:SetJustifyH("CENTER");
		frame.Text:SetWordWrap(false);
		frame.Text:SetFontObject(GameFontNormal);
		frame:SetFontString(frame.Text);
	end
	return frame;
end

--- Dropdown item that will open a submenu when mouseovered.
local Menu = PowerAuras:RegisterWidget("DropdownMenuItem", "DropdownItem");

--- Constructs a new instance of the class.
-- @param parent   The parent dropdown of the item.
-- @param key      The key of the item.
-- @param value    The text to display on the item.
-- @param callback The function to execute when the menu is refreshed.
function Menu:New(parent, key, value, callback)
	-- Construct a frame, apply extras to it.
	local frame = base(self, parent, "Button");
	frame:RegisterForClicks("");
	-- Add fontstring.
	if(not frame.Text) then
		frame.Text = frame:CreateFontString(nil, "OVERLAY");
		frame.Text:SetPoint("TOPLEFT", 4, 0);
		frame.Text:SetPoint("BOTTOMRIGHT", -24, 0);
		frame.Text:SetJustifyV("MIDDLE");
		frame.Text:SetJustifyH("LEFT");
		frame.Text:SetWordWrap(false);
		frame.Text:SetFontObject(GameFontHighlightSmall);
		frame:SetFontString(frame.Text);
		frame:SetPushedTextOffset(0, 0);
	end
	-- Apply textures.
	if(not frame:GetHighlightTexture()) then
		frame:SetHighlightTexture([[Interface\HelpFrame\KnowledgeBaseButtton]]);
		frame:GetHighlightTexture():SetTexCoord(
			0.13085938, 0.63085938, 0.0078125, 0.203125
		);
	end
	if(not frame:GetNormalTexture()) then
		frame:SetNormalTexture([[Interface\ChatFrame\UI-InChatFriendsArrow]]);
		frame:GetNormalTexture():ClearAllPoints();
		frame:GetNormalTexture():SetPoint("TOPRIGHT", -4, -5);
		frame:GetNormalTexture():SetSize(16, 16);
	end
	-- Store callback for future use.
	frame.Callback = callback;
	return frame;
end

--- OnEnter script handler. Hides submenus and creates our own one for this
--  item.
function Menu:OnEnter()
	-- Close existing menus first off.
	base(self);
	-- Next up, create a menu just for us.
	local level = self:GetParent():GetLevel() + 1;
	local menu = PowerAuras:Create("Dropdown", self, level, self.ItemKey);
	menu:SetWidth(self:GetParent():GetWidth());
	menu:Show();
	menu:SetAnchor(self, "TOPLEFT", "TOPRIGHT", 1, 4);
	self.Menu = menu;
	-- Apply callbacks to the menu.
	self.Menu.OnMenuRefreshed:Connect(self.Callback);
	if(not self.OnMenuClosedWrapper) then
		-- Cache wrapper function.
		self.OnMenuClosedWrapper = self:ConnectCallback(
			self.Menu.OnMenuClosed, self.OnMenuClosed);
	else
		-- Reuse cached function.
		self.Menu.OnMenuClosed:Connect(self.OnMenuClosedWrapper);
	end
	-- Refresh the child menu.
	self.Menu:RefreshMenu();
end

--- Called when the owned child menu is closed.
function Menu:OnMenuClosed()
	self.Menu = nil;
end

--- Recycles the widget, allowing it to be reused in the future.
function Menu:Recycle()
	self.Callback = nil;
	if(self.Menu) then
		self.Menu:CloseMenu();
	end
	base(self);
end

--- Host widget that will open a dropdown menu when clicked.
local Button = PowerAuras:RegisterWidget("DropdownButton", "ReusableWidget");

--- Constructs a new instance of the DropdownButton widget.
-- @param parent The parent frame of the widget.
function Button:New(parent)
	local frame = base(self);
	if(not frame) then
		-- Create a new frame.
		frame = CreateFrame("Button", nil, parent or UIParent);
		frame:SetBackdrop({
			bgFile = [[Interface\Buttons\WHITE8X8]],
			edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
			tile = true,
			tileSize = 16,
			edgeSize = 14,
			insets = { left = 2, right = 2, top = 2, bottom = 2 },
		});
		frame:SetBackdropColor(0, 0, 0, 1);
		frame:SetBackdropBorderColor(0.3, 0.3, 0.3, 1.0);
		frame:SetHitRectInsets(0, 0, -20, 0);
		-- Title text.
		frame.Title = frame:CreateFontString(nil, "OVERLAY");
		frame.Title:SetFontObject(GameFontNormal);
		frame.Title:SetJustifyV("MIDDLE");
		frame.Title:SetJustifyH("LEFT");
		frame.Title:SetWordWrap(false);
		frame.Title:SetSize(0, 20);
		frame.Title:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 3, 0);
		frame.Title:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", -3, 0);
		-- Value text. Not automatically updated.
		frame.Text = frame:CreateFontString(nil, "OVERLAY");
		frame.Text:SetFontObject(GameFontHighlightSmall);
		frame.Text:SetJustifyH("LEFT");
		frame.Text:SetJustifyV("MIDDLE");
		frame.Text:SetWordWrap(false);
		frame.Text:SetPoint("TOPLEFT", 8, -2);
		frame.Text:SetPoint("BOTTOMRIGHT", -28, 2);
		frame:SetFontString(frame.Text);
		-- Normal button texture.
		local t = frame:CreateTexture(nil, "ARTWORK");
		t:SetTexture([[Interface\ChatFrame\UI-ChatIcon-ScrollDown-Up]]);
		t:SetPoint("TOPRIGHT");
		t:SetPoint("BOTTOMRIGHT");
		t:SetSize(26, 26);
		frame:SetNormalTexture(t);
		-- Disabled button texture.
		local t = frame:CreateTexture(nil, "ARTWORK");
		t:SetTexture([[Interface\ChatFrame\UI-ChatIcon-ScrollDown-Disabled]]);
		t:SetPoint("TOPRIGHT");
		t:SetPoint("BOTTOMRIGHT");
		t:SetSize(26, 26);
		frame:SetDisabledTexture(t);
		-- Pushed button texture.
		local t = frame:CreateTexture(nil, "ARTWORK");
		t:SetTexture([[Interface\ChatFrame\UI-ChatIcon-ScrollDown-Down]]);
		t:SetPoint("TOPRIGHT");
		t:SetPoint("BOTTOMRIGHT");
		t:SetSize(26, 26);
		frame:SetPushedTexture(t);
		-- Highlight button texture.
		local t = frame:CreateTexture(nil, "ARTWORK");
		t:SetTexture([[Interface\ChatFrame\UI-ChatIcon-BlinkHilight]]);
		t:SetBlendMode("ADD");
		t:SetPoint("TOPRIGHT");
		t:SetPoint("BOTTOMRIGHT");
		t:SetSize(26, 26);
		frame:SetHighlightTexture(t);
		-- Callbacks.
		frame.OnMenuRefreshed = PowerAuras:Callback();
	end
	-- Update frame parent.
	frame:SetParent(parent or UIParent);
	return frame;
end

--- Initialises the widget.
function Button:Initialise()
	self:SetFixedSize(175, 26);
	self:SetMargins(0, 20, 0, 0);
end

--- OnClick script handler for the button. Toggles the state of the
--  menu.
function Button:OnClick()
	PlaySound("UChatScrollButton");
	if(self.Menu) then
		self.Menu:CloseMenu();
	else
		-- Construct.
		self.Menu = PowerAuras:Create("Dropdown", self, 1);
		self.Menu:SetWidth(self:GetWidth());
		self.Menu:SetAnchor(self, "TOPLEFT", "BOTTOMLEFT", 0, 2);
		self.Menu:Show();
		-- Connect callbacks.
		if(not self.OnMenuRefreshedWrapper) then
			-- Cache wrapper function.
			self.OnMenuRefreshedWrapper = self:ConnectCallback(
				self.Menu.OnMenuRefreshed, self.OnMenuRefreshed);
		else
			-- Connect cached function.
			self.Menu.OnMenuRefreshed:Connect(self.OnMenuRefreshedWrapper);
		end
		if(not self.OnMenuClosedWrapper) then
			-- Cache wrapper function.
			self.OnMenuClosedWrapper = self:ConnectCallback(
				self.Menu.OnMenuClosed, self.OnMenuClosed);
		else
			-- Connect cached function.
			self.Menu.OnMenuClosed:Connect(self.OnMenuClosedWrapper);
		end
		-- Refresh the menu.
		self.Menu:RefreshMenu();
	end
end

--- Closes the menu if this button currently owns one.
function Button:CloseMenu()
	if(self.Menu) then
		self.Menu:CloseMenu();
	end
end

--- Returns true if this button currently owns a menu.
function Button:HasMenu()
	return not not self.Menu;
end

--- Called when the button is hidden. Closes the dropdown menu if owned.
function Button:OnHide()
	self:CloseMenu();
end

--- Called when the menu owned by the dropdown is closed.
function Button:OnMenuClosed(dropdown)
	self.Menu = nil;
end

--- Called when the button size has been changed.
function Button:OnSizeChanged()
	if(self.Menu) then
		self.Menu:SetWidth(self:GetWidth());
	end
end

--- Recycles the widget, allowing it to be reused later.
function Button:Recycle()
	self:SetText("");
	self:SetTitle("");
	self:CloseMenu();
	self.OnMenuRefreshed:Reset();
	base(self);
end

--- Refreshes the menu if this button currently owns one.
function Button:RefreshMenu()
	if(self.Menu) then
		self.Menu:RefreshMenu();
	end
end

--- Sets the title label of the widget.
-- @param text The text to set.
-- @param ...  Substitutions to perform.
function Button:SetTitle(text, ...)
	self.Title:SetText(tostring(text):format(tostringall(...)));
end

--- Altenative host widget that will open a dropdown menu when clicked.
local Simple = PowerAuras:RegisterWidget("SimpleDropdown", "ReusableWidget");

--- Constructs a new instance of the SimpleDropdown widget.
-- @param parent The parent frame of the widget.
function Simple:New(parent)
	local frame = base(self);
	if(not frame) then
		-- Create a new frame.
		frame = CreateFrame("Button", nil, parent or UIParent);
		frame:SetBackdrop({
			bgFile = [[Interface\Buttons\WHITE8X8]],
			edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
			tile = true,
			tileSize = 16,
			edgeSize = 14,
			insets = { left = 2, right = 2, top = 2, bottom = 2 },
		});
		frame:SetBackdropColor(0, 0, 0, 1);
		frame:SetBackdropBorderColor(0.3, 0.3, 0.3, 1.0);
		frame:SetHitRectInsets(0, 0, -20, 0);
		-- Title text.
		frame.Title = frame:CreateFontString(nil, "OVERLAY");
		frame.Title:SetFontObject(GameFontNormal);
		frame.Title:SetJustifyV("MIDDLE");
		frame.Title:SetJustifyH("LEFT");
		frame.Title:SetWordWrap(false);
		frame.Title:SetSize(0, 20);
		frame.Title:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 3, 0);
		frame.Title:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", -3, 0);
		-- Value text. Not automatically updated.
		frame.Text = frame:CreateFontString(nil, "OVERLAY");
		frame.Text:SetFontObject(GameFontHighlightSmall);
		frame.Text:SetJustifyH("LEFT");
		frame.Text:SetJustifyV("MIDDLE");
		frame.Text:SetWordWrap(false);
		frame.Text:SetPoint("TOPLEFT", 8, -2);
		frame.Text:SetPoint("BOTTOMRIGHT", -28, 2);
		frame:SetFontString(frame.Text);
		-- Normal button texture.
		local t = frame:CreateTexture(nil, "ARTWORK");
		t:SetTexture([[Interface\ChatFrame\UI-ChatIcon-ScrollDown-Up]]);
		t:SetPoint("TOPRIGHT");
		t:SetPoint("BOTTOMRIGHT");
		t:SetSize(26, 26);
		frame:SetNormalTexture(t);
		-- Disabled button texture.
		local t = frame:CreateTexture(nil, "ARTWORK");
		t:SetTexture([[Interface\ChatFrame\UI-ChatIcon-ScrollDown-Disabled]]);
		t:SetPoint("TOPRIGHT");
		t:SetPoint("BOTTOMRIGHT");
		t:SetSize(26, 26);
		frame:SetDisabledTexture(t);
		-- Pushed button texture.
		local t = frame:CreateTexture(nil, "ARTWORK");
		t:SetTexture([[Interface\ChatFrame\UI-ChatIcon-ScrollDown-Down]]);
		t:SetPoint("TOPRIGHT");
		t:SetPoint("BOTTOMRIGHT");
		t:SetSize(26, 26);
		frame:SetPushedTexture(t);
		-- Highlight button texture.
		local t = frame:CreateTexture(nil, "ARTWORK");
		t:SetTexture([[Interface\ChatFrame\UI-ChatIcon-BlinkHilight]]);
		t:SetBlendMode("ADD");
		t:SetPoint("TOPRIGHT");
		t:SetPoint("BOTTOMRIGHT");
		t:SetSize(26, 26);
		frame:SetHighlightTexture(t);
		-- Callbacks.
		frame.OnValueUpdated = PowerAuras.Callback();
		-- Item storage.
		frame.ItemTables = setmetatable({}, { __mode = "v" });
		frame.ItemsByKey = { ["__ROOT__"] = {} };
		frame.ParentsByKey = {};
	end
	-- Update frame parent.
	frame:SetParent(parent or UIParent);
	return frame;
end

--- Initialises the widget.
function Simple:Initialise()
	self:SetFixedSize(175, 26);
	self:SetTitle("");
end

--- Adds a checkbox item to the dropdown.
-- @param key     The key of the item.
-- @param text    The text to display on the item.
-- @param checked Set to true to have the item checked.
-- @param multi   If set to true, the item will be styled as a checkbox
--                rather than as a radio button.
-- @param parent  If specified, this item will be owned by another item.
--                Valid parents are Menu type items.
function Simple:AddCheckItem(key, text, checked, multi, parent)
	-- Ensure key uniqueness.
	if(self:HasItem(key)) then
		error(("Item with key '%s' already exists."):format(tostring(key)));
	end
	-- Add item to list.
	local item = tremove(self.ItemTables) or {};
	item.Type, item.Key, item.Value, item.State, item.Style = 
		"Check", key, text, checked, multi;
	-- Add item to parent, if specified.
	parent = self:HasItem(parent) and parent or "__ROOT__";
	tinsert(self.ItemsByKey[parent], item);
	-- Store item in by-key tables.
	self.ItemsByKey[key] = item;
	self.ParentsByKey[key] = self.ItemsByKey[parent];
	self:RefreshMenu();
end

--- Adds a simple clickable item to the dropdown.
-- @param key    The key of the item.
-- @param text   The text to display on the item.
-- @param icon   The icon to display on the item, optional.
-- @param parent If specified, this item will be owned by another item.
--               Valid parents are Menu type items.
function Simple:AddItem(key, text, icon, parent)
	-- Ensure key uniqueness.
	if(self:HasItem(key)) then
		error(("Item with key '%s' already exists."):format(tostring(key)));
	end
	-- Add item to list.
	local item = tremove(self.ItemTables) or {};
	item.Type, item.Key, item.Value, item.Icon = "Item", key, text, icon;
	-- Add item to parent, if specified.
	parent = self:HasItem(parent) and parent or "__ROOT__";
	tinsert(self.ItemsByKey[parent], item);
	-- Store item in by-key tables.
	self.ItemsByKey[key] = item;
	self.ParentsByKey[key] = self.ItemsByKey[parent];
	self:RefreshMenu();
end

--- Adds a non-interactive label to the dropdown.
-- @param key    The key of the item.
-- @param text   The text to display on the item.
-- @param parent If specified, this item will be owned by another item.
--               Valid parents are Menu type items.
function Simple:AddLabel(key, text, parent)
	-- Ensure key uniqueness.
	if(self:HasItem(key)) then
		error(("Item with key '%s' already exists."):format(tostring(key)));
	end
	-- Add item to list.
	local item = tremove(self.ItemTables) or {};
	item.Type, item.Key, item.Value = "Label", key, text;
	-- Add item to parent, if specified.
	parent = self:HasItem(parent) and parent or "__ROOT__";
	tinsert(self.ItemsByKey[parent], item);
	-- Store item in by-key tables.
	self.ItemsByKey[key] = item;
	self.ParentsByKey[key] = self.ItemsByKey[parent];
	self:RefreshMenu();
end

--- Adds a submenu to the dropdown.
-- @param key    The key of the item.
-- @param text   The text to display on the item.
-- @param parent If specified, this item will be owned by another item.
--               Valid parents are Menu type items.
function Simple:AddMenu(key, text, parent)
	-- Ensure key uniqueness.
	if(self:HasItem(key)) then
		error(("Item with key '%s' already exists."):format(tostring(key)));
	end
	-- Add item to list.
	local item = tremove(self.ItemTables) or {};
	item.Type, item.Key, item.Value, item.Callback =
		"Menu", key, text, self.OnMenuRefreshed;
	-- Add item to parent, if specified.
	parent = self:HasItem(parent) and parent or "__ROOT__";
	tinsert(self.ItemsByKey[parent], item);
	-- Store item in by-key tables.
	self.ItemsByKey[key] = item;
	self.ParentsByKey[key] = self.ItemsByKey[parent];
	self:RefreshMenu();
end

--- Removes all items from the dropdown.
function Simple:ClearItems()
	-- Remove all items from the list.
	for i = #(self.ItemsByKey["__ROOT__"]), 1, -1 do
		self:RemoveItem(self.ItemsByKey["__ROOT__"][i].Key);
	end
end

--- Closes the menu if the dropdown has it open.
function Simple:CloseMenu()
	-- Close menu only if we own it.
	if(not self:HasMenu()) then
		return;
	end
	self.Menu:CloseAllMenus();
end

--- Returns the checked status of an item.
-- @param key The key of the item.
function Simple:GetItemChecked(key)
	-- Quit if the item doesn't exist.
	if(not self:HasItem(key)) then
		error(("Item with key '%s' doesn't exist."):format(tostring(key)));
	elseif(self.ItemsByKey[key].Type ~= "Check") then
		error(("Item with key '%s' cannot have a checkbox."):format(
			tostring(key)
		));
	end
	-- Return state.
	return self.ItemsByKey[key].State;
end

--- Returns the number of items with the specified parent key.
-- @param key The parent key. Optional.
function Simple:GetItemCount(key)
	return #(self.ItemsByKey[key or "__ROOT__"]);
end

--- Returns true if an item with the specified key exists.
-- @param key The key of the item.
function Simple:HasItem(key)
	return not not (key and self.ItemsByKey[key]);
end

--- Returns true if the dropdown contains items, false if not.
function Simple:HasItems()
	return #(self.ItemsByKey["__ROOT__"]) > 0;
end

--- Returns true if the dropdown currently has the menu opened.
function Simple:HasMenu()
	return not not self.Menu;
end

--- OnClick script handler, toggles the display of the menu.
function Simple:OnClick()
	-- Toggle menu display.
	PlaySound("UChatScrollButton");
	if(self:HasMenu()) then
		self:CloseMenu();
	else
		-- Construct menu.
		self.Menu = PowerAuras:Create("Dropdown", self, 1, "__ROOT__");
		self.Menu:SetParent(self);
		self.Menu:SetAnchor(self, "TOPLEFT", "BOTTOMLEFT", 0, 2);
		self.Menu:SetWidth(math.max(160, self:GetWidth()));
		self.Menu:SetFrameStrata("FULLSCREEN_DIALOG");
		self.Menu:Show();
		-- Connect callbacks.
		self.Menu.OnMenuClosed:Connect(self.OnMenuClosed);
		self.Menu.OnMenuRefreshed:Connect(self.OnMenuRefreshed);
		self.Menu:RefreshMenu();
	end
end

--- Called when the button is hidden. Closes the dropdown menu if owned.
function Simple:OnHide()
	self:CloseMenu();
end

--- OnSizeChanged script handler, updates the menu width.
-- @param width  The new frame width.
-- @param height The new frame height.
function Simple:OnSizeChanged(width, height)
	if(self:HasMenu()) then
		self.Menu:SetWidth(width);
	end
end

--- OnMenuClosed callback handler for the menu.
-- @remarks self points to the menu instance, not the frame.
function Simple:OnMenuClosed()
	-- Get the button frame.
	local frame = self:GetTopLevelParent();
	frame.Menu = nil;
end

--- OnMenuRefreshed callback handler for the menu.
-- @remarks self points to the menu instance, not the frame.
function Simple:OnMenuRefreshed()
	-- Get the button frame.
	local frame = self:GetTopLevelParent();
	-- Clear the menu.
	self:ClearItems();
	-- Allow 10 items before scrolling.
	self:SetLayoutType("Scroll");
	self:SetFixedHeight(10);
	-- Place all of our items onto the menu.
	local level = self:GetLevel();
	for i = 1, #(frame.ItemsByKey[self:GetParentKey()]) do
		local item = frame.ItemsByKey[self:GetParentKey()][i];
		-- Add item to the menu based upon the type.
		self:AddRawItem(item);
	end
	-- Connect callbacks.
	self.OnValueUpdated:Reset();
	self.OnValueUpdated:Connect(frame.OnMenuValueUpdated);
end

--- OnValueUpdated callback handler for the menu.
-- @param key The key of the item.
-- @remarks self points to the menu instance, not the frame.
function Simple:OnMenuValueUpdated(key)
	-- Get the button frame.
	local frame = self:GetTopLevelParent();
	frame:OnValueUpdated(key, self);
end

--- Recycles the widget, allowing it to be reused later.
function Simple:Recycle()
	-- Remove items, eliminate callbacks, etc.
	self:ClearItems();
	self:__SetText("");
	self:SetTitle("");
	self:CloseMenu();
	self.OnValueUpdated:Reset();
	base(self);
end

--- Refreshes the dropdown menu, if it is opened.
function Simple:RefreshMenu()
	if(self:HasMenu()) then
		self.Menu:RefreshMenu();
	end
end

--- Removes an item from the dropdown.
-- @param key The key of the item.
function Simple:RemoveItem(key)
	-- Quit if the item doesn't exist.
	if(not self:HasItem(key) or key == "__ROOT__") then
		error(("Item with key '%s' doesn't exist."):format(tostring(key)));
	end
	-- Remove the item from its parent.
	local parent = self.ParentsByKey[key];
	for i = #(parent), 1, -1 do
		if(parent[i].Key == key) then
			local item = parent[i];
			-- Remove child items.
			for j = #(item), 1, -1 do
				self:RemoveItem(item[j].Key);
			end
			-- Remove item from parent.
			local item = tremove(parent, i);
			wipe(item);
			tinsert(self.ItemTables, item);
			-- Remove item from other lists.
			self.ItemsByKey[key] = nil;
			self.ParentsByKey[key] = nil;
			break;
		end
	end
	-- Refresh the menu.
	self:RefreshMenu();
end

--- Updates the icon of an item.
-- @param key  The key of the item.
-- @param icon The icon to set.
function Simple:SetItemIcon(key, icon)
	-- Quit if the item doesn't exist.
	if(not self:HasItem(key)) then
		error(("Item with key '%s' doesn't exist."):format(tostring(key)));
	elseif(self.ItemsByKey[key].Type ~= "Item") then
		error(("Item with key '%s' cannot have an icon."):format(
			tostring(key)
		));
	end
	-- Update parameter.
	self.ItemsByKey[key].Icon = icon;
	-- Refresh the menu.
	self:RefreshMenu();
end

--- Updates the text of an item.
-- @param key  The key of the item.
-- @param text The text to set.
function Simple:SetItemText(key, text)
	-- Quit if the item doesn't exist.
	if(not self:HasItem(key)) then
		error(("Item with key '%s' doesn't exist."):format(tostring(key)));
	end
	-- Update parameter.
	self.ItemsByKey[key].Value = text;
	-- Refresh the menu.
	self:RefreshMenu();
end

--- Updates the checked status of a check item.
-- @param key   The key of the item.
-- @param state The state to set.
function Simple:SetItemChecked(key, state)
	-- Quit if the item doesn't exist.
	if(not self:HasItem(key)) then
		error(("Item with key '%s' doesn't exist."):format(tostring(key)));
	elseif(self.ItemsByKey[key].Type ~= "Check") then
		error(("Item with key '%s' cannot have a checkbox."):format(
			tostring(key)
		));
	end
	-- Update parameter.
	self.ItemsByKey[key].State = state;
	-- Refresh the menu.
	self:RefreshMenu();
end

--- Updates the checked style of a check item.
-- @param key   The key of the item.
-- @param state The state to set.
function Simple:SetItemCheckedStyle(key, state)
	-- Quit if the item doesn't exist.
	if(not self:HasItem(key)) then
		error(("Item with key '%s' doesn't exist."):format(tostring(key)));
	elseif(self.ItemsByKey[key].Type ~= "Check") then
		error(("Item with key '%s' cannot have a checkbox."):format(
			tostring(key)
		));
	end
	-- Update parameter.
	self.ItemsByKey[key].Style = state;
	-- Refresh the menu.
	self:RefreshMenu();
end

--- Sets the tooltip for an item.
-- @param key  The key of the item.
-- @param text The text to set. Function callbacks are allowed.
function Simple:SetItemTooltip(key, text)
	-- Store tooltip.
	self.ItemsByKey[key].Tooltip = text;
	self:RefreshMenu();
end

--- Sets the text of the widget.
function Simple:SetRawText(text)
	self:__SetText(text);
end

--- Sets the displayed text to match that of an item in the list.
-- @param key The key of the item.
function Simple:SetText(key)
	assert(self:HasItem(key), ("Key '%s' doesn't exist."):format(
		tostring(key)
	));
	-- Set the text.
	self:__SetText(self.ItemsByKey[key].Value);
end

--- Sets the title of the widget.
-- @param text The text to set.
function Simple:SetTitle(text)
	-- Set the title text.
	self.Title:SetText(text);
	-- Do we have a title?
	if(not self.Title:GetText() or self.Title:GetText() == "") then
		-- Remove margins/hit rect insets.
		self:SetMargins(0, 0, 0, 0);
		self:SetHitRectInsets(0, 0, 0, 0);
	else
		self:SetMargins(0, 20, 0, 0);
		self:SetHitRectInsets(0, 0, -20, 0);
	end
end

--- Smaller version of the SimpleDropdown that simply displays an icon.
local Icon = PowerAuras:RegisterWidget("SimpleDropdownIcon", "SimpleDropdown");

--- Constructs a new instance of the SimpleDropdownIcon widget.
-- @param parent The parent frame of the widget.
function Icon:New(parent)
	-- Recycle a frame if possible.
	rawset(self, "WidgetFrames", rawget(self, "WidgetFrames") or {});
	local frame = tremove(rawget(self, "WidgetFrames"));
	if(not frame) then
		-- Create a new frame.
		frame = CreateFrame("CheckButton", nil, parent or UIParent);
		-- Add textures.
		frame:SetNormalTexture(PowerAuras.DefaultIcon);
		frame:GetNormalTexture():ClearAllPoints();
		frame:GetNormalTexture():SetPoint("TOPLEFT", 4, -4);
		frame:GetNormalTexture():SetSize(16, 16);
		frame:SetHighlightTexture([[Interface\HelpFrame\KnowledgeBaseButtton]]);
		frame:GetHighlightTexture():SetTexCoord(
			0.13085938, 0.63085938, 0.0078125, 0.203125
		);
		frame:SetCheckedTexture([[Interface\HelpFrame\KnowledgeBaseButtton]]);
		frame:GetCheckedTexture():SetTexCoord(
			0.13085938, 0.63085938, 0.0078125, 0.203125
		);
		-- Callbacks.
		frame.OnValueUpdated = PowerAuras.Callback();
		-- Item storage.
		frame.ItemTables = setmetatable({}, { __mode = "v" });
		frame.ItemsByKey = { ["__ROOT__"] = {} };
		frame.ParentsByKey = {};
	end
	-- Update frame parent.
	frame:SetParent(parent or UIParent);
	frame:Show();
	return frame;
end

--- Initialises the widget.
-- @param parent The parent frame of the widget.
-- @param width  Optional menu width. Defaults to 160.
function Icon:Initialise(parent, width)
	-- Set fixed size, default icon and default menu width.
	self:SetFixedSize(24, 24);
	self:SetIcon(PowerAuras.DefaultIcon);
	self.MenuWidth = width or 160;
end

--- OnClick script handler, toggles the display of the menu.
function Icon:OnClick()
	-- Proceed as normal.
	base(self);
	-- Fix menu width.
	self:SetChecked(self:HasMenu());
	if(self:HasMenu()) then
		self.Menu:SetWidth(self.MenuWidth);
	end
end

--- OnDisable script handler.
function Icon:OnDisable()
	self:GetNormalTexture():SetDesaturated(true);
end

--- OnEnable script handler.
function Icon:OnEnable()
	self:GetNormalTexture():SetDesaturated(false);
end

--- OnMenuClosed callback handler for the menu.
-- @remarks self points to the menu instance, not the frame.
function Icon:OnMenuClosed()
	-- Get the button frame.
	local frame = self:GetTopLevelParent();
	frame.Menu = nil;
	frame:SetChecked(false);
end

--- OnSizeChanged script handler.
function Icon:OnSizeChanged()
	-- No-op. No automatic width.
end

--- Recycles the widget, allowing it to be reused in the future.
function Icon:Recycle()
	-- Reset icon.
	self:SetIconTexCoord(0, 1, 0, 1);
	self:SetIcon(PowerAuras.DefaultIcon);
	self:Enable();
	base(self);
end

--- Sets the icon of the button.
-- @param icon The icon to set.
function Icon:SetIcon(icon)
	self:SetNormalTexture(icon);
end

--- Sets the texture coordinates of the icon.
-- @param ... The coordinate to set.
function Icon:SetIconTexCoord(...)
	self:GetNormalTexture():SetTexCoord(...)
end

--- Sets the displayed menu width.
-- @param width The menu width.
function Icon:SetMenuWidth(width)
	self.MenuWidth = width;
	self:RefreshMenu();
end

--- Sets the text of the widget.
function Icon:SetRawText()
	-- No-op. No text.
end

--- Sets the text of the widget.
function Icon:SetText()
	-- No-op. No text.
end

--- Sets the title of the widget.
function Icon:SetTitle()
	-- No-op. No title.
end