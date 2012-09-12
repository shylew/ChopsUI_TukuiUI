-- Lock down local environment.
local PowerAuras = _G["PowerAuras"];
setfenv(1, PowerAuras);

--- Editor GUI for managing custom trigger classes.
local Triggers = PowerAuras:RegisterWidget("EditorTriggers", "BreadcrumbFrame",
{
	Tasks = {
		Root = {
			[1] = {
				Text = L["EditName"],
				Icon = [[Interface\Buttons\UI-GuildButton-PublicNote-Up]],
				OnClicked = function(item)
					-- Create edit dialog.
					local editor = PowerAuras.Editor;
					local dlg = PowerAuras:Create("BasicDialog", editor);

					-- Get the current node.
					local node = editor.Triggers:GetCurrentNode();
					local _, id = PowerAuras:SplitNodeID(node);
					local vars = PowerAuras.GlobalSettings.Triggers[id];

					-- Name box.
					local host = dlg.Host;
					local name = PowerAuras:Create("EditBox", host);
					name:SetPadding(4, 0, 4, 0);
					name:SetRelativeWidth(1.0);
					name:SetTitle(L["Name"]);
					name:SetText(vars.Name);
					host:AddWidget(name);

					-- Description box.
					local desc = PowerAuras:Create("CodeBox", host, true, 12);
					desc:SetPadding(4, 0, 4, 52);
					desc:SetMargins(0, 0, 0, -52);
					desc:SetRelativeSize(1.0, 1.0);
					desc:SetText(vars.Tooltip);
					host:AddWidget(desc);

					-- OnAccept callback.
					dlg.OnAccept:Connect(function()
						-- Eat the contents of the widgets.
						vars.Name = host.Widgets[1]:GetText();
						vars.Tooltip = host.Widgets[2].Edit:GetText();
						PowerAuras:LoadCustomTriggers();
						editor.Triggers:RefreshNodes();
					end);
				end,
			},
			[2] = {
				Text = L["DeleteTrigger"],
				Icon = [[Interface\PetBattles\DeadPetIcon]],
				OnClicked = function(item)
					-- Get the current trigger ID.
					local triggers = PowerAuras.Editor.Triggers;
					local node = triggers:GetCurrentNode();
					local _, id = PowerAuras:SplitNodeID(node);
					-- Display a dialog over the editor.
					local editor = PowerAuras.Editor;
					local dialog = PowerAuras:Create("PromptDialog", editor, 
						L["DialogDeleteTrigger"], YES, NO);
					-- Connect callbacks.
					dialog.OnAccept:Connect(function()
						-- Remove and update.
						PowerAuras:DeleteCustomTrigger(id);
						triggers:SetCurrentNode("__ROOT__");
					end);
					-- Is the control key down?
					if(IsControlKeyDown()) then
						dialog:Accept();
					end
				end,
			},
		},
	},
});

--- Initialises a new instance of the frame.
function Triggers:Initialise(parent)
	-- Initialise the frame as normal.
	base(self, parent);
	-- Remove the backdrop from the frame, change the root node text.
	self:SetBackdrop(nil);
	self:SetRootText(L["Triggers"]);
	-- Connect callbacks.
	self:ConnectCallback(PowerAuras.OnOptionsEvent, self.OnOptionsEvent);
	self.OnCurrentNodeChanged:Connect(self.RefreshHost);
	-- Refresh.
	self:RefreshNodes();
end

--- Callback handler for OnOptionsEvent.
-- @param event The event that fired.
-- @param ...   Event parameters.
function Triggers:OnOptionsEvent(event, ...)
	if(event == "CUSTOM_TRIGGER_CREATED"
		or event == "CUSTOM_TRIGGER_DELETED") then
		-- Simple refresh.
		self:RefreshNodes();
	end
end

--- Refreshes the host frame.
-- @param node The currently selected node.
function Triggers:RefreshHost(node)
	-- Ensure the node is selected.
	if(self:GetCurrentNode() ~= node) then
		self:SetCurrentNode(node);
	end

	-- Reset the parent sidebar/bottombar.
	local parent = self:GetParent();
	parent:ResetSidebar(not node or node == "__ROOT__");
	parent:ResetBottombar();
	parent:ResetTopbar();

	-- Populate each of the bars.
	if(type(node) == "number") then
		self:RefreshSidebar();
	end

	-- Determine what we're displaying.
	self:PauseLayout();
	self:ClearWidgets();
	if(type(node) ~= "number") then
		-- Trigger class list.
		self:PopulateChildNodes();
	else
		local _, id, f1, s1, f2, s2 = PowerAuras:SplitNodeID(node);
		if(s1 == 0) then
			-- Listing of categories.
			self:PopulateChildNodes();
		elseif(s1 == 1) then
			-- Trigger editor.
			PowerAuras:CreateCustomTriggerEditor(self, node);
		elseif(s1 == 2) then
			-- Events.
			PowerAuras:CreateCustomTriggerEventsEditor(self, node)
		-- elseif(s1 == 3) then
		-- 	-- Sources editor.
		-- elseif(s1 == 4) then
		-- 	-- Parameters editor.
		-- elseif(s1 == 5) then
		-- 	-- Dependencies.
		-- elseif(s1 == 6) then
		-- 	-- UI editor.
		end
	end

	-- Resume layout processing.
	self:ResumeLayout();
end

--- Refreshes the nodes of the frame.
function Triggers:RefreshNodes()
	-- Destroy existing nodes.
	self:PauseLayout();
	local current = self:GetCurrentNode();
	self.OnCurrentNodeChanged:Pause();
	self.OnNodesChanged:Pause();
	self:ClearNodes();
	self.OnCurrentNodeChanged:Resume();

	-- Add nodes for all the triggers.
	for i = 1, #(GlobalSettings.Triggers) do
		local data = GlobalSettings.Triggers[i];
		-- Add root node.
		local root = PowerAuras:GetNodeID(nil, i, 0, 0, 0, 0);
		self:AddNode(root, data["Name"]);

		-- Add subnodes for each editor section.
		local sub = PowerAuras:GetNodeID(nil, i, 0, 1, 0, 0);
		self:AddNode(sub, L["Trigger"], root);

		local sub = PowerAuras:GetNodeID(nil, i, 0, 2, 0, 0);
		self:AddNode(sub, L["Events"], root);

		-- local sub = PowerAuras:GetNodeID(nil, i, 0, 3, 0, 0);
		-- self:AddNode(sub, L["Sources"], root);

		-- local sub = PowerAuras:GetNodeID(nil, i, 0, 4, 0, 0);
		-- self:AddNode(sub, L["Parameters"], root);

		-- local sub = PowerAuras:GetNodeID(nil, i, 0, 5, 0, 0);
		-- self:AddNode(sub, L["Dependencies"], root);

		-- local sub = PowerAuras:GetNodeID(nil, i, 0, 6, 0, 0);
		-- self:AddNode(sub, L["Configuration"], root);
	end

	-- Reset the current node to the one previously selected if possible.
	self.OnNodesChanged:Resume();
	self:ResumeLayout();
	if(self:HasNode(current) and self:GetCurrentNode() ~= current) then
		self:SetCurrentNode(current);
	else
		self:OnCurrentNodeChanged(self:GetCurrentNode());
	end
end

--- Refreshes the sidebar with content based upon the current active
--  node.
function Triggers:RefreshSidebar()
	-- Get node data.
	local node = self:GetCurrentNode();
	local taskType = "Root";
	if(type(node) ~= "number") then
		-- It's the root node.
		taskType = "Root";
	else
		-- Determine the types of tasks.
		local _, id, f1, s1, f2, s2, rtype = PowerAuras:SplitNodeID(node);
		if(s1 == 0) then
			taskType = "Root";
		else
			taskType = nil;
		end
	end

	-- Get the listframe for the sidebar.
	local side = self:GetParent().Side.List;
	side:PauseLayout();
	side:Clear();

	-- By default, we connect OnLinkClicked to our node changer.
	self:ConnectCallback(side.OnLinkClicked, self.SetCurrentNode, 2);

	-- Add links to the subkeys.
	if(type(node) == "number") then
		local _, id = PowerAuras:SplitNodeID(node);
		local baseNode = PowerAuras:GetNodeID(nil, id, 0, 0, 0, 0);
		side:SetHome("__ROOT__", self.NodesByKey[baseNode].Value);
		for i = 1, #(self.NodesByKey[baseNode]) do
			local child = self.NodesByKey[baseNode][i];
			side:AddLink(child.Key, child.Value);
		end
		side:SetCurrentItem(node);
	end

	-- Add all tasks.
	local tasks = self.Tasks[(taskType or "")];
	if(tasks) then
		for i = 1, #(tasks) do
			local task = tasks[i];
			local show = task.ShouldShow;
			if(show and show(node) or not show) then
				side:AddTask(
					task.Text, task.Icon, task.OnClicked, task.TexCoords
				);
			end
		end
	end

	-- Resume the layout.
	side:ResumeLayout();
end