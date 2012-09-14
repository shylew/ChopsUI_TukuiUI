-- Lock down local environment.
local PowerAuras = _G["PowerAuras"];
setfenv(1, PowerAuras);

--- Tree view widget. Contains a navigatable tree of elements with
--  collapsing/expanding support.
local TreeView = PowerAuras:RegisterWidget("TreeView", "ScrollFrame");

--- Constructs a new instance of the class and returns the frame.
-- @param parent The parent frame.
function TreeView:New(parent)
	-- Create the frame, add some tables.
	local frame = base(self, parent);
	-- Reusable node descriptions.
	frame.UsableNodes = setmetatable({}, { __index = table, __mode = "kv" });
	-- Always have a root node.
	frame.RootNode = {
		["Key"] = "__ROOT__",
		["Value"] = "Root",
		["Disabled"] = true,
		["Expanded"] = true,
		["Children"] = 0,
		["HideExpand"] = false,
		["Orderable"] = false,
	};
	-- Default to the root node.
	frame.CurrentNode = frame.RootNode;
	-- Keep a table of all our frames for displaying nodes.
	frame.NodeFrames = {};
	-- Node key -> value storage.
	frame.NodesByKey = {};
	frame.NodeParentsByKey = {};
	frame.OnCurrentNodeChanged = PowerAuras:Callback();
	-- Node storage.
	return frame;
end

--- Adds a new node to the treeview.
-- @param key    The key of the node.
-- @param value  The value to display in this node.
-- @param parent The key of the parent node.
-- @param dis    Set to true if the node should be disabled.
-- @param col    Set to true if the node should be collapsed.
-- @param exp    Set to true if the expand button should be hidden.
-- @param order  Allows the children of this element to be reordered. This
--               only applies to the immediate children.
function TreeView:AddNode(key, value, parent, dis, col, exp, order)
	-- Validate key doesn't exist.
	if(self.NodesByKey[key]) then
		error(("Node with key %s already exists."):format(key));
	end
	-- Get the parent.
	local parentNode = (self.NodesByKey[(parent or "__ROOT__")]
		or self.RootNode);
	-- Create or recycle.
	local node = self.UsableNodes:remove() or {};
	node["Key"] = key;
	node["Value"] = value;
	node["Disabled"] = not not dis;
	node["Expanded"] = not col;
	node["Children"] = 0;
	node["HideExpand"] = not not exp;
	node["Orderable"] = not not order;
	-- Add node to register.
	self.NodesByKey[key] = node;
	self.NodeParentsByKey[key] = parentNode;
	tinsert(parentNode, node);
	-- Perform an update.
	self:UpdateVisibleNodes();
end

--- Removes all nodes from the tree.
function TreeView:ClearNodes()
	-- Pause the layout.
	self:PauseLayout();
	-- Remove all nodes.
	local key = next(self.NodesByKey);
	while(key) do
		self:RemoveNode(key);
		key = next(self.NodeParentsByKey, key);
	end
	-- Unpause.
	self:ResumeLayout();
end

--- Collapses a node.
-- @param key The key of the node to collapse.
function TreeView:CollapseNode(key)
	if(not self.NodesByKey[key]) then
		error(("Node with key %s doesn't exist."):format(key));
	end
	-- Collapse, update.
	self.NodesByKey[key]["Expanded"] = false;
	self:UpdateVisibleNodes();
end

--- Disables a node.
-- @param key The key of the node to disable.
function TreeView:DisableNode(key)
	if(not self.NodesByKey[key]) then
		error(("Node with key %s doesn't exist."):format(key));
	end
	-- Disable, update.
	self.NodesByKey[key]["Disabled"] = true;
	self:UpdateVisibleNodes();
end

--- Enables a node.
-- @param key The key of the node to enable.
function TreeView:EnableNode(key)
	if(not self.NodesByKey[key]) then
		error(("Node with key %s doesn't exist."):format(key));
	end
	-- Enable, update.
	self.NodesByKey[key]["Disabled"] = false;
	self:UpdateVisibleNodes();
end

--- Expands a node.
-- @param key The key of the node to expand.
function TreeView:ExpandNode(key)
	if(not self.NodesByKey[key]) then
		error(("Node with key %s doesn't exist."):format(key));
	end
	-- Expand, update.
	self.NodesByKey[key]["Expanded"] = true;
	self:UpdateVisibleNodes();
end

--- Finds all drawable nodes within the tree and draws them.
-- @param node  The node to search from.
-- @param count Internal counter for number of nodes iterated over.
-- @param depth Internal counter for current node depth.
function TreeView:FindDrawableNodes(node, count, depth)
	-- Fill in internal vars.
	if(not count) then count = 0; end
	if(not depth) then depth = 0; end
	-- Get offset/max values.
	local offset, max = self:GetScrollOffset(), floor(self:GetHeight() / 24);
	-- Iterate over child nodes.
	for i = 1, #(node) do
		count = count + 1;
		-- Can we draw this node?
		if(count > offset and count <= (offset + max)) then
			-- Create the node frame.
			local frame = PowerAuras:Create("TreeNode", self, node[i],
				self.CurrentNode == node[i], depth, i, node["Orderable"]);
			-- Anchor it.
			frame:SetPoint(
				"TOPLEFT",
				4,
				-(((count - offset) - 1) * 24) - 4
			);
			frame:SetPoint(
				"TOPRIGHT",
				(self.ScrollBar:IsShown() and -20 or -4),
				-(((count - offset) - 1) * 24) - 4
			);
			frame:Show();
			-- Insert into list.
			tinsert(self.NodeFrames, frame);
		end
		-- Can we end it?
		if(count > (offset + max)) then
			break;
		end
		-- Should we draw the children of this node?
		if(node[i]["Expanded"]
			and (count + node[i]["Children"]) >= offset) then
			-- Go for it.
			count = self:FindDrawableNodes(node[i], count, depth + 1);
		else
			count = count + node[i]["Children"];
		end
	end
	-- Return counter.
	return count;
end

--- Finds the scroll offset of a node.
-- @param key  The node to find.
-- @param node The node to search from.
function TreeView:FindNodeOffset(key, node)
	node = node or self.RootNode;
	for i = 1, #(node) do
		-- Are these the nodes you're looking for?
		if(node[i] == self.NodesByKey[key]) then
			return i;
		else
			-- These are not the nodes you're looking for.
			if(node[i]["Expanded"]) then
				local j = self:FindNodeOffset(key, node[i]);
				if(j) then
					return i + j;
				end
			end
		end
	end
end

--- Returns the key of the currently selected node.
function TreeView:GetCurrentNode()
	return self.CurrentNode["Key"];
end

--- Checks to see if a node with the specified key exists.
-- @param key The key to find.
function TreeView:HasNode(key)
	return not not self.NodesByKey[key];
end

--- Called when the size of the frame is changed. Reperforms the layout.
function TreeView:OnSizeChanged()
	self:UpdateVisibleNodes();
	self:PerformLayout();
end

--- Updates the layout of all visible items.
function TreeView:PerformLayout()
	-- Test if layout is locked.
	if(not base(self)) then
		return;
	end
	-- Recycle existing widgets.
	for i = #(self.NodeFrames), 1, -1 do
		tremove(self.NodeFrames):Recycle();
	end
	-- Find all drawable nodes and draw 'em.
	self:FindDrawableNodes(self.RootNode);
end

--- Removes a node from the tree.
-- @param key The key of the node to remove.
function TreeView:RemoveNode(key)
	if(not self.NodesByKey[key]) then
		error(("Node with key %s doesn't exist."):format(key));
	end
	-- Get the node.
	local node = self.NodesByKey[key];
	-- Detach all children.
	for i = #(node), 1, -1 do
		self:RemoveNode(tremove(node, i)["Key"]);
	end
	-- Remove from tables.
	self.NodesByKey[key] = nil;
	for i = #(self.NodeParentsByKey[key]), 1, -1 do
		if(self.NodeParentsByKey[key][i] == node) then
			tremove(self.NodeParentsByKey[key], i);
			break;
		end
	end
	self.NodeParentsByKey[key] = nil;
	-- Did we remove the current node?
	if(self:GetCurrentNode() == key) then
		self:SetCurrentNode("__ROOT__");
	else
		self:UpdateVisibleNodes();
	end
	-- Recycle node table.
	wipe(node);
	self.UsableNodes:insert(node);
end

--- Reorders a node within its parent, shifting it up/down one spot.
-- @param key   The key of the node to move.
-- @param delta The direction to move. Negative if up, positive if down.
function TreeView:ReorderNode(key, delta)
	if(not self.NodesByKey[key]) then
		error(("Node with key %s doesn't exist."):format(key));
	end
	-- Get the parent of this node.
	local parent = self.NodeParentsByKey[key];
	-- Find and shift.
	for i = #(parent), 1, -1 do
		if(parent[i]["Key"] == key and (delta == -1 and i > 1
			or delta == 1 and i < #(parent))) then
			tinsert(parent, i + delta, tremove(parent, i));
			break;
		end
	end
	-- Update.
	self:PerformLayout();
end

--- Resumes the layout of the frame, updating all visible tree nodes.
function TreeView:ResumeLayout()
	base(self);
	self:UpdateVisibleNodes();
end

--- Sets the currently selected node.
-- @param key The key of the node to select.
function TreeView:SetCurrentNode(key)
	key = key or "__ROOT__";
	if(not self.NodesByKey[key] and key ~= "__ROOT__") then
		error(("Node with key %s doesn't exist."):format(key));
	end
	-- Set new key.
	self.CurrentNode = self.NodesByKey[key] or self.RootNode;
	-- Make the node visible, first we need to find it.
	self:PauseLayout();
	local node = self.NodeParentsByKey[key];
	while(node and self:HasNode(node["Key"])) do
		self:ExpandNode(node["Key"]);
		node = self.NodeParentsByKey[node["Key"]];
	end
	-- Reperform the layout.
	self:ResumeLayout();
end

--- Updates the min/max ranges of the treeview's scrollbar, which in turn will
--  cause the layout to be reperformed.
-- @param node The node to search from.
function TreeView:UpdateVisibleNodes(node)
	-- Update only if unpaused.
	if(self.LayoutPaused and self.LayoutPaused > 0) then
		return;
	end
	-- Start from the root node. This node never counts to our counter.
	if(not node) then
		node = self.RootNode;
	end
	-- Set counter to 1 if not root.
	local count = (node ~= self.RootNode and 1 or 0);
	-- Is the node expanded?
	if(node["Expanded"]) then
		-- Count children.
		for i = 1, #(node) do
			count = count + self:UpdateVisibleNodes(node[i]);
		end
	end
	-- Set visible child counter.
	node["Children"] = (node ~= self.RootNode and count - 1 or count);
	-- Is this the root node?
	if(node == self.RootNode) then
		-- We have a count of all visible nodes.
		local max = math.max(0, count - floor(self:GetHeight() / 24));
		if(max == select(2, self:GetScrollRange())) then
			-- If they're the same, OnMinMaxChanged won't fire.
			self:PerformLayout();
		else
			self:SetScrollRange(0, max);
		end
	else
		-- Return visible node count.
		return count;
	end
end

--- Constructs a new instance of a node for use with a TreeView.
local TreeNode = PowerAuras:RegisterWidget("TreeNode", "ReusableWidget");

--- Constructs a new instance of the class and returns the frame.
-- @param parent    The parent TreeView widget.
-- @param node      The node object.
-- @param checked   True if this is the current selected node.
-- @param depth     The depth of the node. Indent the text with this.
-- @param index     The index number of this node within its parent.
-- @param orderable True if the parent node has the Orderable flag set.
function TreeNode:New(parent, node, checked, depth, index, orderable)
	-- Expand node data.
	local key, value, disabled, expanded, children = node["Key"], 
		node["Value"], node["Disabled"], node["Expanded"], #(node);
	-- Recycle or create.
	local frame = base(self);
	if(not frame) then
		frame = CreateFrame("CheckButton");
		-- Add text.
		frame.Text = frame:CreateFontString(nil, "OVERLAY");
		frame.Text:SetJustifyH("LEFT");
		frame.Text:SetSize(0, 10);
		frame.Text:SetWordWrap(false);
		frame:SetFontString(frame.Text);
		-- Style the button as needed.
		frame:SetNormalFontObject(GameFontNormal);
		frame:SetHighlightFontObject(GameFontHighlight);
		frame:SetDisabledFontObject(GameFontHighlight);
		-- Highlight texture.
		local texture = frame:CreateTexture();
		texture:SetAllPoints(frame);
		texture:SetBlendMode("ADD");
		texture:SetTexture([[Interface\HelpFrame\KnowledgeBaseButtton]]);
		texture:SetTexCoord(0.13085938, 0.63085938, 0.0078125, 0.203125);
		frame:SetHighlightTexture(texture);
		-- Disabled texture.
		local texture = frame:CreateTexture();
		texture:SetAllPoints(frame);
		texture:SetBlendMode("ADD");
		texture:SetTexture(p);
		frame:SetDisabledTexture(texture);
		-- Expandomatic 3000.
		local expand = CreateFrame("Button", nil, frame);
		frame.Expand = expand;
		expand:SetSize(16, 16);
		expand:SetPoint("TOPRIGHT", -4, -4);
		-- Button textures.
		expand:SetNormalTexture([[Interface\Buttons\UI-MinusButton-Down]]);
		expand:GetNormalTexture():ClearAllPoints();
		expand:GetNormalTexture():SetPoint("TOPRIGHT");
		expand:GetNormalTexture():SetSize(16, 16);
		expand:SetPushedTexture([[Interface\Buttons\UI-MinusButton-Up]]);
		expand:GetPushedTexture():ClearAllPoints();
		expand:GetPushedTexture():SetPoint("TOPRIGHT");
		expand:GetPushedTexture():SetSize(16, 16);
		expand:SetHighlightTexture(
			[[Interface\Buttons\UI-PlusButton-Hilight]]
		);
		expand:GetHighlightTexture():SetBlendMode("ADD");
		expand:GetHighlightTexture():ClearAllPoints();
		expand:GetHighlightTexture():SetPoint("TOPRIGHT");
		expand:GetHighlightTexture():SetSize(16, 16);
		-- When clicked, expand/collapse this node.
		expand:SetScript("OnClick", function()
			PlaySound("UChatScrollButton");
			if(frame.Expanded) then
				frame:GetParent():CollapseNode(frame.Key);
			else
				frame:GetParent():ExpandNode(frame.Key);
			end
		end);
		-- Reordering buttons.
		frame.OrderUp = CreateFrame("Button", nil, frame);
		frame.OrderUp:SetSize(16, 8);
		frame.OrderUp:SetPoint("TOPRIGHT", -24, -4);
		frame.OrderUp:SetNormalTexture([[Interface\Buttons\Arrow-Up-Up]]);
		frame.OrderUp:GetNormalTexture():SetTexCoord(0, 1, 0.5, 1);
		frame.OrderUp:SetPushedTexture([[Interface\Buttons\Arrow-Up-Down]]);
		frame.OrderUp:GetPushedTexture():SetTexCoord(0, 1, 0.5, 1);
		frame.OrderUp:SetDisabledTexture(
			[[Interface\Buttons\Arrow-Up-Disabled]]
		);
		frame.OrderUp:GetDisabledTexture():SetTexCoord(0, 1, 0.5, 1);
		-- Order down.
		frame.OrderDown = CreateFrame("Button", nil, frame);
		frame.OrderDown:SetSize(16, 8);
		frame.OrderDown:SetPoint("TOPRIGHT", -24, -12);
		frame.OrderDown:SetNormalTexture([[Interface\Buttons\Arrow-Down-Up]]);
		frame.OrderDown:GetNormalTexture():SetTexCoord(0, 1, 0, 0.5);
		frame.OrderDown:SetPushedTexture([[Interface\Buttons\Arrow-Down-Down]]);
		frame.OrderDown:GetPushedTexture():SetTexCoord(0, 1, 0, 0.5);
		frame.OrderDown:SetDisabledTexture(
			[[Interface\Buttons\Arrow-Down-Disabled]]
		);
		frame.OrderDown:GetDisabledTexture():SetTexCoord(0, 1, 0, 0.5);
		-- Ordering buttons should default to low alpha while not mouseovered.
		frame.OrderUp:SetAlpha(0.50);
		frame.OrderDown:SetAlpha(0.50);
		-- Apply scripts.
		frame.OrderUp:SetScript("OnEnter", function(self)
			self:SetAlpha(1);
		end);
		frame.OrderUp:SetScript("OnLeave", function(self)
			self:SetAlpha(0.5);
		end);
		frame.OrderDown:SetScript("OnEnter", function(self)
			self:SetAlpha(1);
		end);
		frame.OrderDown:SetScript("OnLeave", function(self)
			self:SetAlpha(0.5);
		end);
		-- When clicked, reorder.
		frame.OrderUp:SetScript("OnClick", function()
			PlaySound("UChatScrollButton");
			frame:GetParent():ReorderNode(frame.Key, -1);
		end);
		frame.OrderDown:SetScript("OnClick", function()
			PlaySound("UChatScrollButton");
			frame:GetParent():ReorderNode(frame.Key, 1);
		end);
	end
	-- Update parent.
	frame:SetText(value);
	frame:SetSize(0, 24);
	frame:SetParent(parent);
	local rightOffset = -4;
	-- Hide/show the expand button.
	if(children == 0 or node["HideExpand"]) then
		frame.Expand:Hide();
	else
		frame.Expand:Show();
		rightOffset = rightOffset - 20;
	end
	-- Expand button textures.
	if(expanded) then
		frame.Expand:SetNormalTexture(
			[[Interface\Buttons\UI-MinusButton-Up]]
		);
		frame.Expand:SetPushedTexture(
			[[Interface\Buttons\UI-MinusButton-Down]]
		);
	else
		frame.Expand:SetNormalTexture(
			[[Interface\Buttons\UI-PlusButton-Up]]
		);
		frame.Expand:SetPushedTexture(
			[[Interface\Buttons\UI-PlusButton-Down]]
		);
	end
	-- Change font sizes if parent node is root.
	if(parent.NodeParentsByKey[key] == parent.RootNode) then
		frame:SetNormalFontObject(GameFontNormal);
		frame:SetHighlightFontObject(GameFontHighlight);
		frame:SetDisabledFontObject(GameFontHighlight);
	else
		frame:SetNormalFontObject(GameFontNormalSmall);
		frame:SetHighlightFontObject(GameFontHighlightSmall);
		frame:SetDisabledFontObject(GameFontHighlightSmall);
	end
	-- Disabled nodes look different.
	if(disabled) then
		frame:SetDisabledTexture("");
		if(parent.NodeParentsByKey[key] == parent.RootNode) then
			frame:SetDisabledFontObject(GameFontNormal);
		else
			frame:SetDisabledFontObject(GameFontNormalSmall);
		end
		frame:Disable();
		-- Expand the expand button to be clickable from the entire item.
		frame.Expand:ClearAllPoints();
		frame.Expand:SetPoint("TOPLEFT", 4, -4);
		frame.Expand:SetPoint("TOPRIGHT", -4, -4);
		-- Reordering buttons won't show if disabled.
		frame.OrderUp:Hide();
		frame.OrderDown:Hide();
	else
		frame:SetDisabledTexture([[Interface\HelpFrame\KnowledgeBaseButtton]]);
		frame:GetDisabledTexture():SetTexCoord(
			0.13085938, 0.63085938, 0.0078125, 0.203125
		);
		if(parent.NodeParentsByKey[key] == parent.RootNode) then
			frame:SetDisabledFontObject(GameFontHighlight);
		else
			frame:SetDisabledFontObject(GameFontHighlightSmall);
		end
		frame:Enable();
		-- Reset expand button positioning.
		frame.Expand:ClearAllPoints();
		frame.Expand:SetPoint("TOPRIGHT", -4, -4);
		-- Handle ordering buttons.
		if(orderable) then
			frame.OrderUp:Show();
			frame.OrderDown:Show();
			-- Enable/disable based on the index.
			if(index > 1) then
				frame.OrderUp:Enable();
			else
				frame.OrderUp:Disable();
			end
			if(index < #(parent.NodeParentsByKey[key])) then
				frame.OrderDown:Enable();
			else
				frame.OrderDown:Disable();
			end
			-- Reposition next to the close button.
			frame.OrderUp:SetPoint("TOPRIGHT", rightOffset, -4);
			frame.OrderDown:SetPoint("TOPRIGHT", rightOffset, -12);
			rightOffset = rightOffset - 20;
		else
			frame.OrderUp:Hide();
			frame.OrderDown:Hide();
		end
	end
	-- Check/uncheck.
	if(not disabled) then
		frame:SetChecked(checked);
		if(checked) then
			frame:Disable();
		else
			frame:Enable();
		end
	end
	-- Reposition the text.
	frame.Text:ClearAllPoints();
	frame.Text:SetPoint("LEFT", 4 + (depth * 10), 0); 
	frame.Text:SetPoint("RIGHT", rightOffset, 0);
	-- Store expansion status.
	frame.Key = key;
	frame.Expanded = expanded;
	frame.Orderable = orderable;
	frame:Show();
	-- Done.
	return frame;
end

--- OnClick script handler for the node.
function TreeNode:OnClick()
	self:SetChecked(false);
	self:GetParent():SetCurrentNode(self.Key);
	self:GetParent():OnCurrentNodeChanged(self.Key);
	PlaySound("UChatScrollButton");
end