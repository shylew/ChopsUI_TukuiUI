-- Lock down local environment.
local PowerAuras = _G["PowerAuras"];
setfenv(1, PowerAuras);

--- Breadcrumb frame widget. Inherits LayoutHost, as the child elements are
--  completely user controlled.
local BCFrame = PowerAuras:RegisterWidget("BreadcrumbFrame", "LayoutHost");

--- Initialises a new instance of the widget.
function BCFrame:Initialise(...)
	-- Keep a couple of tables containing all of our nodes.
	self.NodesByKey = {};
	self.UsableNodes = setmetatable({}, { __mode = "v" });
	-- Callback for when the node is changed.
	self.CurrentNode = "__ROOT__";
	self.OnCurrentNodeChanged = PowerAuras:Callback();
	self.OnNodesChanged = PowerAuras:Callback();
	-- Create the breadcrumb bar.
	self.Bar = PowerAuras:Create("BreadcrumbBar", self);
	self.Bar:SetPoint("TOPLEFT", 4, -6);
	self.Bar:SetPoint("TOPRIGHT", -4, -6);
	self.Bar:SetHeight(34);
	-- Force a minimum padding on the top of the layout for our breadcrumbs.
	self:SetContentPadding(8, 44, 8, 8);
	-- Add a root node.
	self:AddNode("__ROOT__", _G["HOME"], "");
	self.RootNode = self.NodesByKey["__ROOT__"];
	-- Initialise as normal.
	base(self, ...);
	-- Reposition our scrollbar a slight bit.
	self.ScrollBar:SetPoint("TOPRIGHT", -4, -58);
	self.ScrollBar:SetPoint("BOTTOMRIGHT", -4, 20);
end

--- Adds a node to the frame.
-- @param key    The key of the node.
-- @param text   The text to display on the node.
-- @param parent The parent of the node, defaults to the root node.
-- @param icon   Optional icon for the node. Doesn't display in the bar.
function BCFrame:AddNode(key, text, parent, icon)
	if(self:HasNode(key)) then
		error(("Node with key '%s' already exists."):format(tostring(key)));
	end
	-- Determine parent node.
	parent = parent or "__ROOT__";
	if(not self:HasNode(parent) and key ~= "__ROOT__") then
		error(("Node with key '%s' does not exist."):format(tostring(parent)));
	end
	-- Get a node table.
	local node = tremove(self.UsableNodes)
		or { Key = nil, Value = nil, Parent = nil, Icon = nil };
	-- Populate node and store.
	node.Key, node.Value, node.Parent, node.Icon = key, text, parent, icon;
	self.NodesByKey[key] = node;
	if(key ~= "__ROOT__") then
		tinsert(self.NodesByKey[parent], node);
	else
		node.Parent = nil;
	end
	-- Fire callback.
	self:OnNodesChanged();
end

--- Removes all nodes from the frame.
function BCFrame:ClearNodes()
	self.OnCurrentNodeChanged:Pause();
	for i = #(self.RootNode), 1, -1 do
		self:RemoveNode(tremove(self.RootNode).Key);
	end
	self.OnCurrentNodeChanged:Resume();
	self:OnCurrentNodeChanged(self.CurrentNode);
end

--- Returns all child nodes of the specified node.
-- @param key The key of the node.
function BCFrame:GetChildNodes(key)
	if(not self:HasNode(key)) then
		error(("Node with key '%s' does not exist."):format(tostring(key)));
	end
	return unpack(self.NodesByKey[key]);
end

--- Returns the key of a parent node.
-- @param key The key of the node.
function BCFrame:GetParentNode(key)
	if(not self:HasNode(key)) then
		error(("Node with key '%s' does not exist."):format(tostring(key)));
	end
	return self.NodesByKey[key].Parent;
end

--- Returns the key of the currently selected node.
function BCFrame:GetCurrentNode()
	return self.CurrentNode;
end

--- Checks if a node exists on the frame.
-- @param key The key of the node.
function BCFrame:HasNode(key)
	return not not self.NodesByKey[key];
end

--- Removes a node from the frame.
-- @param key The key of the node.
function BCFrame:RemoveNode(key)
	if(not self:HasNode(key)) then
		error(("Node with key '%s' does not exist."):format(tostring(key)));
	elseif(key == "__ROOT__") then
		error("Root node cannot be removed.");
	end
	-- Remove all child nodes.
	local node = self.NodesByKey[key];
	for i = #(node), 1, -1 do
		self:RemoveNode(tremove(node).Key);
	end
	-- Wipe the node clean and store it.
	wipe(node);
	tinsert(self.UsableNodes, node);
	self.NodesByKey[key] = nil;
	-- If this was the selected node, select the root node.
	if(self.CurrentNode == key) then
		self:SetCurrentNode("__ROOT__");
	end
	-- Fire callback.
	self:OnNodesChanged();
end

--- Populates the layout host with a list of all child nodes of the currently
--  selected node.
-- @param start  Starting index, optional.
-- @param finish Finishing index, optional.
function BCFrame:PopulateChildNodes(start, finish)
	self:PauseLayout();
	-- Fix ranges.
	start = math.max(start or 1, 1);
	local current = self:GetCurrentNode();
	finish = math.min(
		finish or math.huge,
		select("#", self:GetChildNodes(current))
	);
	-- Run over all of the child nodes.
	for i = start, finish do
		local node = self.NodesByKey[current][i];
		-- Construct a list item for the frame.
		self:AddWidget(PowerAuras:Create("BreadcrumbListItem", self, node));
	end
	self:ResumeLayout();
end

--- Sets the current selected node.
-- @param key The key of the node.
function BCFrame:SetCurrentNode(key)
	-- Set node.
	local old = self.CurrentNode;
	self.CurrentNode = (self:HasNode(key) and key or "__ROOT__");
	-- Fire callbacks.
	if(old ~= self.CurrentNode) then
		self:OnCurrentNodeChanged(self.CurrentNode);
	end
end

--- Sets the text of the root node.
-- @param text The text to display.
function BCFrame:SetRootText(text)
	self.RootNode.Value = text;
	self:OnNodesChanged();
end

--- Reusable list item class for PopulateChildNodes.
local BCLI = PowerAuras:RegisterWidget("BreadcrumbListItem", "ReusableWidget");

--- Constructs/recycles an instance of the class.
function BCLI:New(parent)
	-- Recycle frame.
	local frame = base(self);
	if(not frame) then
		-- Construct frame.
		frame = CreateFrame("Button", nil, UIParent);
		-- Apply textures.
		frame:SetNormalTexture([[Interface\HelpFrame\KnowledgeBaseButtton]]);
		local t = frame:GetNormalTexture();
		t:SetTexCoord(0.13085938, 0.63085938, 0.21875, 0.4140625);
		frame:SetPushedTexture([[Interface\HelpFrame\KnowledgeBaseButtton]]);
		local t = frame:GetPushedTexture();
		t:SetTexCoord(0.13085938, 0.63085938, 0.4296875, 0.625);
		frame:SetHighlightTexture([[Interface\HelpFrame\KnowledgeBaseButtton]]);
		local t = frame:GetHighlightTexture();
		t:SetTexCoord(0.13085938, 0.63085938, 0.0078125, 0.203125);
		-- End textures.
		frame.REnd = frame:CreateTexture(nil, "OVERLAY");
		frame.REnd:SetTexture([[Interface\HelpFrame\KnowledgeBaseButtton]]);
		frame.REnd:SetTexCoord(0.00195313, 0.12695313, 0.4296875, 0.625);
		frame.REnd:SetPoint("RIGHT", 5, 0);
		frame.REnd:SetSize(64, 25);
		frame.LEnd = frame:CreateTexture(nil, "OVERLAY");
		frame.LEnd:SetTexture([[Interface\HelpFrame\KnowledgeBaseButtton]]);
		frame.LEnd:SetTexCoord(0.00195313, 0.12695313, 0.0078125, 0.203125);
		frame.LEnd:SetPoint("LEFT", -5, 0);
		frame.LEnd:SetSize(64, 25);
		-- Main text.
		frame.Text = frame:CreateFontString(nil, "OVERLAY");
		frame.Text:SetFontObject(GameFontNormal);
		frame.Text:SetVertexColor(0.8, 0.8, 0.8);
		frame.Text:SetPoint("TOPLEFT", 8, 0);
		frame.Text:SetPoint("BOTTOMRIGHT", -8, 0);
		frame.Text:SetJustifyH("LEFT");
		frame.Text:SetJustifyV("MIDDLE");
		frame.Text:SetWordWrap(false);
		frame:SetFontString(frame.Text);
		-- Icon (optional).
		frame.Icon = frame:CreateTexture(nil, "OVERLAY");
		frame.Icon:SetPoint("TOPLEFT", 8, -5);
		frame.Icon:SetSize(16, 16);
		frame.Icon:Hide();
	end
	return frame;
end

--- Initialises a new instance of the class.
function BCLI:Initialise(parent, node)
	-- Initialise as normal, set parent and size.
	self:SetParent(parent);
	self:SetRelativeWidth(1.0);
	self:SetFixedHeight(25);
	self:SetMargins(0, 4, 0, 4);
	self:SetPadding(5, 0, 5, 0);
	self:GetFontString():SetDrawLayer("OVERLAY", 7);
	self.Icon:SetDrawLayer("OVERLAY", 7);
	-- Set displayed values.
	self:SetText(node.Value);
	self.Key = node.Key;
	-- Show icon if necessary.
	if(node.Icon and node.Icon:trim() ~= "") then
		self.Icon:Show();
		self.Icon:SetTexture(node.Icon);
		self.Text:SetPoint("TOPLEFT", 32, 0);
	else
		self.Icon:Hide();
		self.Text:SetPoint("TOPLEFT", 8, 0);
	end
end

--- Called when the list item is clicked.
function BCLI:OnClick()
	PlaySound("igMainMenuOptionCheckBoxOn");
	self:GetParent():SetCurrentNode(self.Key);
end

--- Breadcrumb bar navigation widget.
local BCBar = PowerAuras:RegisterWidget("BreadcrumbBar", "Frame");

--- Constructs/recycles an instance of the widget class.
function BCBar:New(parent)
	-- Get the frame.
	local frame = base(self, parent);
	-- Style the frame.
	local bg = frame:CreateTexture(nil, "BACKGROUND");
	bg:SetTexture([[Interface\HelpFrame\CS_HelpTextures_Tile]]);
	bg:SetAllPoints(true);
	bg:SetTexCoord(0, 1, 0.1875, 0.25390625);
	-- Add an overflow button.
	frame.Overflow = CreateFrame("CheckButton", nil, frame);
	frame.Overflow:SetPoint("LEFT", 0, 0);
	frame.Overflow:SetSize(44, 30);
	frame.Overflow:SetNormalTexture([[Interface\HelpFrame\CS_HelpTextures]]);
	local t = frame.Overflow:GetNormalTexture();
	t:SetTexCoord(0.54296875, 0.62890625, 0.7578125, 0.9921875);
	frame.Overflow:SetPushedTexture([[Interface\HelpFrame\CS_HelpTextures]]);
	local t = frame.Overflow:GetPushedTexture();
	t:SetTexCoord(0.453125, 0.5390625, 0.7578125, 0.9921875);
	frame.Overflow:SetHighlightTexture([[Interface\HelpFrame\CS_HelpTextures]]);
	local t = frame.Overflow:GetHighlightTexture();
	t:SetTexCoord(0.54296875, 0.62890625, 0.7578125, 0.9921875);
	t:SetAlpha(0.4);
	frame.Overflow:Hide();
	-- List for the overflow button.
	frame.OverflowList = {};
	-- Add an overlay frame.
	local overlay = CreateFrame("Frame", nil, frame);
	overlay:SetAllPoints(true);
	overlay.bg = overlay:CreateTexture(nil, "OVERLAY", 5);
	overlay.bg:SetTexture([[Interface\HelpFrame\CS_HelpTextures_Tile]]);
	overlay.bg:SetAllPoints(true);
	overlay.bg:SetTexCoord(0, 1, 0.2578125, 0.32421875);
	self.Overlay = overlay;
	-- Connect resize handling script.
	frame:SetScript("OnSizeChanged", self.OnNodesChanged);
	return frame;
end

--- Initialises a new instance of the widget.
-- @param parent The parent frame of the widget.
function BCBar:Initialise(parent)
	-- Connect to the callbacks on the parent.
	base(self, parent);
	self:ConnectCallback(parent.OnNodesChanged, self.OnNodesChanged);
	self:ConnectCallback(parent.OnCurrentNodeChanged, self.OnNodesChanged);
	-- Callback for the overflow button.
	self.Overflow:SetScript("OnClick", self.OnOverflowClick);
	-- Collection containing our item widgets.
	self.Widgets = {};
end

--- Called when the current node or any nodes are changed in the parent
--  frame. Updates the displayed items.
function BCBar:OnNodesChanged()
	-- Close existing dropdowns.
	PowerAuras:GetWidget("Dropdown"):CloseAllMenus();
	-- Recycle existing widgets.
	for i = #(self.Widgets), 1, -1 do
		tremove(self.Widgets):Recycle();
	end
	-- Get the owning frame.
	local frame = self:GetParent();
	-- Initial widget, the currently selected node.
	local key = frame:GetCurrentNode();
	while(key) do
		-- Construct a widget for the node with this key.
		local node = frame.NodesByKey[key];
		local widget = PowerAuras:Create("BreadcrumbItem", self, node);
		-- Toggle enable/disabled state.
		widget:SetChecked(key == frame:GetCurrentNode());
		if(key == frame:GetCurrentNode()) then
			widget:Disable();
		else
			widget:Enable();
		end
		widget:SetSize(widget:GetFixedSize());
		tinsert(self.Widgets, widget);
		-- Position the previous node to the end of this one.
		local prev = self.Widgets[#(self.Widgets) - 1];
		if(prev) then
			prev:SetPoint("LEFT", widget, "RIGHT", 0, 0);
		end
		-- Get the parent node.
		key = frame:GetParentNode(key);
	end
	-- Position the final widget to the start of the frame.
	local widget = self.Widgets[#(self.Widgets)];
	if(widget) then
		widget:SetWidth(widget:GetFixedWidth());
		widget:SetPoint("LEFT", self, "LEFT", 0, 0);
	end
	-- Get the total width of our displayed nodes and see if we need to get
	-- out our axe.
	local w = 0;
	for i = 1, #(self.Widgets) do
		w = w + self.Widgets[i]:GetWidth();
	end
	-- Chopping?
	if(w > self:GetWidth() and #(self.Widgets) > 0) then
		-- Increment size by the size of our overflow button.
		w = w + self.Overflow:GetWidth();
		self.Overflow:Show();
		wipe(self.OverflowList);
		repeat
			-- Remove the last widget (the leftmost one).
			local w1 = tremove(self.Widgets);
			w = w - w1:GetWidth();
			-- Add the item key to our overflow list before recycling.
			tinsert(self.OverflowList, w1.Key);
			w1:Recycle();
			-- Reposition new last widget.
			if(#(self.Widgets) > 0) then
				local w2 = self.Widgets[#(self.Widgets)];
				w2:SetPoint("LEFT", self.Overflow, "RIGHT", -18, 0);
				self.Overflow:SetFrameLevel(w2:GetFrameLevel() + 1);
				w2:SetWidth(w2:GetFixedWidth());
			end
		until(w <= self:GetWidth() or #(self.Widgets) == 0);
		self.Overlay:SetFrameLevel(self.Overflow:GetFrameLevel() + 1);
	else
		self.Overflow:Hide();
	end
end

--- Called when the overflow button is clicked.
-- @remarks self points to the button.
function BCBar:OnOverflowClick()
	-- Process sound/checked state fixing.
	PlaySound("igMainMenuOptionCheckBoxOn");
	self:SetChecked(not self:GetChecked());
	-- Are we currently checked?
	if(self:GetChecked()) then
		-- We're checked, so close existing menus.
		PowerAuras:GetWidget("Dropdown"):CloseAllMenus();
		self:SetChecked(false);
		return;
	end
	-- Not checked, create the menu.
	local menu = PowerAuras:Create("Dropdown", self, 1, nil);
	menu:SetParent(self);
	menu:SetAnchor(self, "TOPLEFT", "BOTTOMLEFT", 0, 4);
	menu:SetWidth(180);
	menu:Show();
	-- Connect menu callbacks.
	menu.OnMenuClosed:Connect([[
		-- Deselect the button.
		local menu = ...;
		menu:GetTopLevelParent():SetChecked(false);
	]]);
	menu.OnMenuRefreshed:Connect([[
		-- Add keys to the menu.
		local menu = ...;
		local bar = menu:GetTopLevelParent():GetParent();
		local frame = bar:GetParent();
		menu:ClearItems();
		for i = 1, #(bar.OverflowList) do
			local key = bar.OverflowList[i];
			menu:AddItem(key, "", frame.NodesByKey[key].Value);
		end
	]]);
	menu.OnValueUpdated:Connect([[
		-- Update selected key.
		local menu, key = ...;
		menu:GetTopLevelParent():GetParent():GetParent():SetCurrentNode(key);
	]]);
	-- Refresh menu.
	menu:RefreshMenu();
	self:SetChecked(true);
end

--- Reusable breadcrumb bar item widget.
local BCItem = PowerAuras:RegisterWidget("BreadcrumbItem", "ReusableWidget");

--- Constructs/recycles an instance of the widget class.
function BCItem:New()
	-- Recycle if possible.
	local frame = base(self);
	if(not frame) then
		-- Construct the frame from fresh.
		frame = CreateFrame("CheckButton", nil, UIParent);
		frame:SetNormalFontObject(GameFontNormal);
		frame:SetHighlightFontObject(GameFontHighlight);
		frame:SetDisabledFontObject(GameFontHighlight);
		-- Add textures.
		frame:SetNormalTexture([[Interface\HelpFrame\CS_HelpTextures_Tile]]);
		local t = frame:GetNormalTexture();
		t:SetTexCoord(0, 1, 0.0625, 0.12109375);
		frame:SetPushedTexture([[Interface\HelpFrame\CS_HelpTextures_Tile]]);
		local t = frame:GetPushedTexture();
		t:SetTexCoord(0, 1, 0.125, 0.18359375);
		frame:SetHighlightTexture([[Interface\HelpFrame\CS_HelpTextures]]);
		local t = frame:GetHighlightTexture();
		t:SetTexCoord(0.00195313, 0.25195313, 0.65625, 0.921875);
		frame:SetCheckedTexture([[Interface\HelpFrame\CS_HelpTextures]]);
		local t = frame:GetCheckedTexture();
		t:SetBlendMode("BLEND");
		t:SetTexCoord(0.00195313, 0.25195313, 0.375, 0.620625);
		-- Arrow textures.
		frame.ArrowUp = frame:CreateTexture(nil, "OVERLAY");
		frame.ArrowUp:SetTexture([[Interface\HelpFrame\CS_HelpTextures]]);
		frame.ArrowUp:SetSize(21, 30);
		frame.ArrowUp:SetPoint("LEFT", frame, "RIGHT");
		frame.ArrowUp:SetTexCoord(0.88867188, 0.9296875, 0.296875, 0.52125);
		frame.ArrowDo = frame:CreateTexture(nil, "OVERLAY");
		frame.ArrowDo:SetTexture([[Interface\HelpFrame\CS_HelpTextures]]);
		frame.ArrowDo:SetSize(21, 30);
		frame.ArrowDo:SetPoint("LEFT", frame, "RIGHT");
		frame.ArrowDo:SetTexCoord(0.6328125, 0.67382813, 0.7578155, 0.9921875);
		frame.ArrowDo:Hide();
		-- Add text label.
		frame.Text = frame:CreateFontString(nil, "OVERLAY");
		frame.Text:SetJustifyH("CENTER");
		frame.Text:SetJustifyV("MIDDLE");
		frame.Text:SetWordWrap(false);
		frame.Text:SetPoint("TOPLEFT", frame, "TOPLEFT", 21, -4);
		frame.Text:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 4);
		frame:SetFontString(frame.Text);
	end
	return frame;
end

--- Initialises a new instance of the widget class.
-- @param parent The parent bar frame.
-- @param node   The node data to display.
function BCItem:Initialise(parent, node)
	-- Initialise as normal, set a fixed size for the item.
	self:SetWidth(1024);
	self:SetParent(parent);
	self:Show();
	-- Set the data on the item.
	self:SetText(node.Value);
	self.Key = node.Key;
	-- Update size.
	self:SetFixedSize(math.max(self.Text:GetStringWidth(), 64) + 32, 30);
end

--- Called when the item is clicked. Updates the selection.
function BCItem:OnClick()
	PlaySound("igMainMenuOptionCheckBoxOn");
	self:GetParent():GetParent():SetCurrentNode(self.Key);
end

--- Called when the widget is disabled.
function BCItem:OnDisable()
	self.ArrowDo:Hide();
	self.ArrowUp:Show();
end

--- Called when the widget is disabled.
function BCItem:OnEnable()
	self.ArrowDo:Hide();
	self.ArrowUp:Show();
end

--- Called when the widget is pressed.
function BCItem:OnMouseDown()
	if(self:IsEnabled()) then
		self.ArrowUp:Hide();
		self.ArrowDo:Show();
	end
end

--- Called when the widget is released.
function BCItem:OnMouseUp()
	self.ArrowDo:Hide();
	self.ArrowUp:Show();
end