-- Lock down local environment.
local PowerAuras = _G["PowerAuras"];
setfenv(1, PowerAuras);

-- Modules.
local Metadata = PowerAuras:GetModules("Metadata");

local GetEligibleDisplayActions;

--- Dictionary of actions to not show in the Display Actions list.
local BannedDisplayActions = {
	["DisplaySound"] = true,
	["DisplayActivate"] = { L["Advanced"], "Display", false, 0, 0x20, 0, 0 },
};

--- Editor lookup tables for the tools/tasks part of the navbar.
local EditorTasks = {
	["Actions.Root"] = {
		[1] = {
			Text = L["NewAction"],
			Icon = [[Interface\PaperDollInfoFrame\Character-Plus]],
			ShouldShow = function(node, id)
				-- Show only if we have room for more actions.
				local auraID = PowerAuras:SplitAuraDisplayID(id);
				local vars = PowerAuras:GetAura(auraID);
				if(#(vars["Actions"]) > PowerAuras.MAX_ACTIONS_PER_AURA) then
					return false;
				end
				-- Also, only show if we have display actions to add.
				for _ in GetEligibleDisplayActions(id) do
					return true;
				end
				return false;
			end,
			OnClicked = function(item)
				-- Is the item checked?
				if(item:GetChecked()) then
					-- Close menu.
					item:SetChecked(false);
					item.Menu:CloseAllMenus();
					item.Menu = nil;
					return;
				end
				-- Get current node and display ID.
				local node = PowerAuras.Editor.Displays:GetCurrentNode();
				local _, id = PowerAuras:SplitNodeID(node);
				-- Show a dropdown menu when clicking here.
				local menu = PowerAuras:Create("Dropdown", item, 1);
				menu:SetParent(item);
				menu:SetAnchor(item, "TOPLEFT", "TOPRIGHT", 2, 2);
				menu:SetWidth(160);
				menu:SetFrameStrata("FULLSCREEN_DIALOG");
				menu:Show();
				-- Connect callbacks.
				menu.OnMenuClosed:Connect(function(menu)
					item:SetChecked(false);
					item.Menu = nil;
				end);
				menu.OnMenuRefreshed:Connect(function(menu)
					-- Populate menu with display actions.
					for name in GetEligibleDisplayActions(id) do
						menu:AddItem(
							name,
							nil,
							L["ActionClasses"][name]["Name"]
						);
					end
					-- Add value changed handler.
					menu.OnValueUpdated:Reset();
					menu.OnValueUpdated:Connect(function(menu, key)
						-- Close the menu.
						menu:CloseMenu();
						-- Construct class.
						local auraID = PowerAuras:SplitAuraDisplayID(id);
						local aID = PowerAuras:CreateAuraAction(auraID, key);
						PowerAuras:LinkAuraDisplayAction(id, aID);
					end);
				end);
				-- Store the menu on the item.
				item.Menu = menu;
				item:SetChecked(true);
				menu:RefreshMenu();
				-- Dispose of the menu when the item is recycled.
				item.OnRecycled:Connect(function(item)
					item:SetChecked(false);
					item.Menu = nil;
				end);
			end,
		},
	},
	["Actions.Sequences"] = {
		[1] = {
			Text = L["NewSequence"],
			Icon = [[Interface\PaperDollInfoFrame\Character-Plus]],
			ShouldShow = function(node, id)
				-- Does this action have sequence parameters?
				local vars = PowerAuras:GetAuraAction(id);
				local class = PowerAuras:GetActionClass(vars["Type"]);
				local seqs = vars["Sequences"];
				-- Show if there's params, and if we have room for more
				-- sequences.
				return class:GetNumParameters() > 0
					and #(seqs) < PowerAuras.MAX_SEQUENCES_PER_ACTION;
			end,
			OnClicked = function(item)
				-- Get the current node and action ID.
				local node = PowerAuras.Editor.Displays:GetCurrentNode();
				local _, id = PowerAuras:SplitNodeID(node);
				-- Create the sequence.
				local index = PowerAuras:CreateAuraActionSequence(id);
				-- Refresh the bottombar.
				PowerAuras.Editor.Displays:RefreshBottombar(index);
			end,
		},
		[2] = {
			Text = L["NewTrigger"],
			Icon = [[Interface\PaperDollInfoFrame\Character-Plus]],
			ShouldShow = function(node, id)
				-- Only show if there's room for more.
				local vars = PowerAuras:GetAuraAction(id);
				local triggers = vars["Triggers"];
				return #(triggers) < PowerAuras.MAX_TRIGGERS_PER_ACTION;
			end,
			OnClicked = function(item)
				-- Get the current node and action ID.
				local node = PowerAuras.Editor.Displays:GetCurrentNode();
				local _, id = PowerAuras:SplitNodeID(node);
				-- Create the trigger.
				PowerAuras:CreateAuraActionTrigger(id, "UnitAura");
			end,
		},
		[3] = {
			Text = L["DeleteAction"],
			Icon = [[Interface\PetBattles\DeadPetIcon]],
			ShouldShow = function(node, id)
				-- Get the action class type.
				local vars = PowerAuras:GetAuraAction(id);
				-- Rule is: You can't delete banned actions.
				return not BannedDisplayActions[vars["Type"]];
			end,
			OnClicked = function(item)
				-- Get the current node and action ID.
				local displays = PowerAuras.Editor.Displays;
				local node = displays:GetCurrentNode();
				local parent = displays:GetParentNode(node);
				local _, id = PowerAuras:SplitNodeID(node);
				-- Display a dialog over the editor.
				local editor = PowerAuras.Editor;
				local dialog = PowerAuras:Create("PromptDialog", editor, 
					L["DialogDeleteAction"], YES, NO);
				-- Connect callbacks.
				dialog.OnAccept:Connect(function()
					-- Delete action.
					PowerAuras:DeleteAuraAction(id);
					-- Navigate to parent node.
					if(displays:HasNode(parent)) then
						displays:SetCurrentNode(parent);
					end
				end);
				-- Auto-cancel the dialog if we change nodes.
				dialog:ConnectCallback(
					displays.OnCurrentNodeChanged,
					dialog.Cancel
				);
				-- Is the control key down?
				if(IsControlKeyDown()) then
					dialog:Accept();
				end
			end,
		},
	},
	["Actions.Trigger"] = {
		[1] = {
			Text = L["DeleteTrigger"],
			Icon = [[Interface\PetBattles\DeadPetIcon]],
			OnClicked = function()
				-- Get the current node and action ID.
				local displays = PowerAuras.Editor.Displays;
				local node = displays:GetCurrentNode();
				local parent = displays:GetParentNode(node);
				local _, id, _, _, _, index = PowerAuras:SplitNodeID(node);
				-- Display a dialog over the editor.
				local editor = PowerAuras.Editor;
				local dialog = PowerAuras:Create("PromptDialog", editor, 
					L["DialogDeleteTrigger"], YES, NO);
				-- Connect callbacks.
				dialog.OnAccept:Connect(function()
					-- Delete action.
					PowerAuras:DeleteAuraActionTrigger(id, index);
					-- Navigate to parent node.
					if(displays:HasNode(parent)) then
						displays:SetCurrentNode(parent);
					end
				end);
				-- Auto-cancel the dialog if we change nodes.
				dialog:ConnectCallback(
					displays.OnCurrentNodeChanged,
					dialog.Cancel
				);
				-- Is the control key down?
				if(IsControlKeyDown()) then
					dialog:Accept();
				end
			end,
		},
	},
	["Activation.Advanced"] = {
		[1] = {
			Text = L["BasicEditor"],
			Icon = [[Interface\WorldMap\Gear_64Grey]],
			TexCoords = { 0.2, 0.8, 0.2, 0.8 },
			ShouldShow = function(node, id)
				local _, id = PowerAuras:GetCurrentDisplay();
				return not PowerAuras:IsAdvancedActivationRequired(id);
			end,
			OnClicked = function(item)
				-- Return to the basic editor.
				local _, id = PowerAuras:GetCurrentDisplay();
				PowerAuras.Editor.Displays:SetCurrentNode(
					PowerAuras:GetNodeID("Display", id, 0, 0x20, 0, 0)
				);
			end,
		},
	},
	["Activation.Basic"] = {
		[1] = {
			Text = L["AdvancedEditor"],
			Icon = [[Interface\WorldMap\Gear_64Grey]],
			TexCoords = { 0.2, 0.8, 0.2, 0.8 },
			OnClicked = function(item)
				-- Get current node and swap to advanced.
				local node = PowerAuras.Editor.Displays:GetCurrentNode();
				local _, id = PowerAuras:SplitNodeID(node);
				-- We're in a display, so get the ID of the Activate action.
				local vars = PowerAuras:GetAuraDisplay(id);
				local aID = vars["Actions"]["DisplayActivate"];
				local new = PowerAuras:GetNodeID("Actions", aID, 1, 0, 0, 0);
				PowerAuras.Editor.Displays:SetCurrentNode(new);
			end,
		},
	},
	["Display"] = {
		[1] = {
			Text = L["ExportDisplay"],
			Icon = [[Interface\Cursor\Directions]],
			ShouldShow = function(node, id)
				return false; -- TODO
			end,
			OnClicked = function(item)
			end,
		},
		[2] = {
			Text = L["CopyMove"],
			Icon = [[Interface\Cursor\Pickup]],
			ShouldShow = function(node, id)
				return false; -- TODO
			end,
			OnClicked = function(item)
			end,
		},
		[3] = {
			Text = L["DeleteDisplay"],
			Icon = [[Interface\PetBattles\DeadPetIcon]],
			OnClicked = function(item)
				-- Get the current node and display ID.
				local displays = PowerAuras.Editor.Displays;
				local node = displays:GetCurrentNode();
				local parent = displays:GetParentNode(node);
				local _, id = PowerAuras:SplitNodeID(node);

				-- Display a dialog over the editor.
				local editor = PowerAuras.Editor;
				local dialog = PowerAuras:Create("PromptDialog", editor, 
					L["DialogDeleteDisplay"], YES, NO);

				-- Connect callbacks.
				dialog.OnAccept:Connect(function()
					-- Is this display linked to another one?
					local vars = PowerAuras:GetAuraDisplay(id);
					local lID = Metadata:GetFlagID(vars.Flags, "Display");
					local navParent = parent;
					if(lID > 0) then
						-- Change the navigated parent node to the parent.
						local aID = PowerAuras:SplitAuraDisplayID(id);
						local navID = PowerAuras:GetAuraDisplayID(aID, lID);
						navParent = PowerAuras:GetNodeID("Display", navID);
					end

					-- Delete display.
					PowerAuras:DeleteAuraDisplay(id);

					-- Navigate to parent node.
					if(displays:HasNode(navParent)) then
						displays:SetCurrentNode(navParent);
					elseif(displays:HasNode(parent)) then
						displays:SetCurrentNode(parent);
					end
				end);

				-- Auto-cancel the dialog if we change nodes.
				dialog:ConnectCallback(
					displays.OnCurrentNodeChanged,
					dialog.Cancel
				);

				-- Is the control key down?
				if(IsControlKeyDown()) then
					dialog:Accept();
				end
			end,
		},
	},
};

-- Advanced activation editor also needs to copy the other items from
-- the actions tasks.
local t = EditorTasks["Activation.Advanced"][1];
EditorTasks["Activation.Advanced"] = PowerAuras:CopyTable(
	EditorTasks["Actions.Sequences"]
);
tinsert(EditorTasks["Activation.Advanced"], 1, t);

-- And also add the individual "Add <x>" nodes for child displays.
for i, key in PowerAuras:IterDisplayClasses() do
	tinsert(EditorTasks["Display"], i, {
		Text = L["DisplayClasses"][key]["Add"],
		Icon = [[Interface\PaperDollInfoFrame\Character-Plus]],
		ShouldShow = function(node, id)
			-- Show if there's actually room left for more displays.
			local aID, dID = PowerAuras:SplitAuraDisplayID(id);
			local aura = PowerAuras:GetAura(aID);
			if(#(aura.Displays) >= PowerAuras.MAX_DISPLAYS_PER_AURA) then
				return false;
			end

			-- If this display is linked, replace the ID.
			local vars = PowerAuras:GetAuraDisplay(id);
			local lID = Metadata:GetFlagID(vars.Flags, "Display");
			if(lID > 0) then
				dID = lID;
				id = PowerAuras:GetAuraDisplayID(aID, dID);
				vars = PowerAuras:GetAuraDisplay(id);
			end

			-- Skip if this type is the type of the display.
			if(vars.Type == key) then
				return false;
			end

			-- Show only if the parent/current display has no ones of this
			-- type present.
			for i = 1, #(aura.Displays) do
				local lV = aura.Displays[i];
				if(Metadata:GetFlagID(lV.Flags, "Display") == dID
					and lV.Type == key) then
					-- Can't show.
					return false;
				end
			end

			-- Success otherwise.
			return true;
		end,
		OnClicked = function()
			-- Get current node data.
			local node = PowerAuras.Editor.Displays:GetCurrentNode();
			local _, id = PowerAuras:SplitNodeID(node);
			local aID, dID = PowerAuras:SplitAuraDisplayID(id);
			local vars = PowerAuras:GetAuraDisplay(id);

			-- Is this display linked to another one?
			local lID = Metadata:GetFlagID(vars.Flags, "Display");
			if(lID > 0) then
				dID = lID;
			end

			-- Add the display.
			local newID = PowerAuras:CreateAuraDisplay(aID, key);
			local vars = PowerAuras:GetAuraDisplay(newID);

			-- Link to parent.
			vars.Flags = Metadata:SetFlagID(vars.Flags, dID, "Display");
			Metadata:SetDisplayFlags(newID, Metadata.DISPLAY_LINK, "Link");

			-- Select the new display.
			local node = PowerAuras:GetNodeID("Display", newID, 0, 0, 0, 0);
			if(PowerAuras.Editor.Displays:HasNode(node)) then
				PowerAuras.Editor.Displays:SetCurrentNode(node);
			end
		end,
	});
end

do
	--- Stateless iterator function for GetEligibleDisplayActions.
	-- @param id   The display ID.
	-- @param name The last returned action class name.
	local function iterator(id, name)
		-- Get action classes and display actions.
		local vars = PowerAuras:GetAuraDisplay(id);
		local dClass = PowerAuras:GetDisplayClass(vars["Type"]);
		local classes = PowerAuras:GetActionClasses();
		-- Find next eligible one.
		local iter = PowerAuras:ByKey(classes);
		local name, class = iter(classes, name);
		while(name) do
			-- Eligible?
			if(class:GetTarget() == "Display"
				and dClass:IsActionSupported(name)
				and not vars["Actions"][name]
				and not BannedDisplayActions[name]) then
				-- Yep.
				return name;
			end
			-- Next.
			name, class = iter(classes, name);
		end
	end

	--- Returns an iterator for accessing actions that can be added to the
	--  specified display.
	-- @param id The display ID.
	function GetEligibleDisplayActions(id)
		return iterator, id, nil;
	end
end

--- Frame containing controls for editing the style of displays.
local Displays = PowerAuras:RegisterWidget("EditorDisplays", "BreadcrumbFrame");

--- Initialises a new instance of the frame.
function Displays:Initialise()
	-- Initialise the frame as normal.
	base(self, parent);
	-- Remove the backdrop from the frame, change the root node text.
	self:SetBackdrop(nil);
	self:SetRootText(L["Displays"]);
	-- Preview storage.
	self.Preview = nil;
	-- Connect callbacks.
	self:ConnectCallback(PowerAuras.OnOptionsEvent, self.OnOptionsEvent);
	self:ConnectParameter("SequenceOp", "", self.RefreshSidebar);
	self.OnCurrentNodeChanged:Connect(self.RefreshHost);
end

--- Updates the content paddings and fixes the frame sizes automatically.
function Displays:FixContentPadding()
	-- Get total padding.
	local parent = self:GetParent();
	local top, bottom = parent.Top, parent.Bottom;

	-- Refresh the frames.
	top:PerformLayout();
	bottom:PerformLayout();

	-- Update padding/sizes.
	self:PauseLayout();
	if(top:IsShown()) then
		-- Update frame size, padding and positioning.
		top:SetHeight(math.max(32, top:GetFixedHeight()));
		self:SetContentPadding(8, 44 + top:GetHeight(), 8, 8);
		self.ScrollBar:SetPoint("TOPRIGHT", top, "BOTTOMRIGHT", -4, -20);
	else
		top:SetHeight(0);
		self:SetContentPadding(8, 44, 8, 8);
		self.ScrollBar:SetPoint("TOPRIGHT", -4, -58);
	end

	-- Same for bottom bar.
	local _, pT = unpack(self:GetContentPadding());
	if(bottom:IsShown()) then
		bottom:SetHeight(math.max(32, bottom:GetFixedHeight()));
		self:SetContentPadding(8, pT, 8, 8 + bottom:GetHeight());
		self.ScrollBar:SetPoint("BOTTOMRIGHT", bottom, "TOPRIGHT", -4, 20);
	else
		bottom:SetHeight(0);
		self:SetContentPadding(8, pT, 8, 8);
		self.ScrollBar:SetPoint("BOTTOMRIGHT", -4, 20);
	end
	self:ResumeLayout();
end

--- Callback handler for OnOptionsEvent.
-- @param event The event that fired.
-- @param ...   Event parameters.
function Displays:OnOptionsEvent(event, ...)
	-- Refresh nodes if anything is created/deleted.
	if(event == "SELECTED_AURA_CHANGED" or event == "SELECTED_DISPLAY_CHANGED"
		or event:find("CREATED") or event:find("DELETED")) then
		-- If the display is changed, go to it.
		local node = self:GetCurrentNode();
		if(event == "SELECTED_DISPLAY_CHANGED" and node ~= "__ROOT__") then
			local rType, nodeID, f1 = PowerAuras:SplitNodeID(node);
			if(nodeID ~= (...) and (rType < 3 or f1 == 0)) then
				-- Update selected node.
				self:SetCurrentNode(bit.lshift((...), 14));
			end
		elseif(event == "SELECTED_DISPLAY_CHANGED" and ...) then
			self:SetCurrentNode(bit.lshift((...), 14));
		elseif(event == "SELECTED_AURA_CHANGED") then
			-- Otherwise, reset to root.
			self:SetCurrentNode("__ROOT__");
		end
		-- Refresh the nodes.
		self:RefreshNodes();
	end
end

--- Refreshes the bottombar with content based upon the current active
--  node.
-- @param ... Optional data based upon the type of content shown.
function Displays:RefreshBottombar(...)
	-- Get node data.
	local node = self:GetCurrentNode();
	if(type(node) ~= "number") then
		return;
	end
	local _, id, f1, s1, f2, s2, rtype = PowerAuras:SplitNodeID(node);

	-- Get the bottombar.
	local bottom = self:GetParent().Bottom;
	bottom:PauseLayout();
	bottom:ClearWidgets();
	bottom:Hide();

	-- Very few editors make use of the bottom bar, thankfully.
	if(rtype == "Actions" and f1 == 1 and s2 == 0) then
		-- Editing sequences.
		local vars = PowerAuras:GetAuraAction(id);
		local class = PowerAuras:GetActionClass(vars["Type"]);

		-- Allow picking a sequence. Cap between 1 and the last.
		local cur = math.max(
			1,
			math.min(#(vars["Sequences"]), tonumber((...)) or 1)
		);

		-- Booleans for displayed controls.
		local hasMult = (class:GetNumParameters() > 0);
		local hasDelete = (hasMult and #(vars["Sequences"]) > 1);

		-- Allow multiple sequences?
		if(hasMult) then
			-- Put in a dropdown for picking them.
			local sequences = PowerAuras:Create("SimpleDropdown", bottom);
			sequences:SetPadding(4, 0, 2, 0);
			sequences:SetRelativeWidth(0.4);
			sequences:SetTitle(L["CurrentSequence"]);
			for i = 1, #(vars["Sequences"]) do
				sequences:AddCheckItem(i, L("SequenceID", i));
			end
			-- Select the current one if possible.
			if(sequences:HasItem(cur)) then
				sequences:SetText(cur);
				sequences:SetItemChecked(cur, true);
			else
				sequences:SetRawText(NONE);
			end
			-- Add callbacks.
			self:DisconnectCallback(sequences.OnValueUpdated);
			self:ConnectCallback(
				sequences.OnValueUpdated,
				self.RefreshBottombar,
				2
			);
			-- Add to frame.
			bottom:AddWidget(sequences);
		end

		-- Add sequence editing editbox.
		if(vars["Sequences"][cur]) then
			-- Add editbox to frame.
			local edit = PowerAuras:Create("SequenceEditBox", bottom, id, cur);
			edit:SetRelativeWidth(hasMult and 0.6 or 1.0);
			edit:SetPadding(hasMult and 2 or 4, 0, hasDelete and 34 or 0, 0);
			edit:SetMargins(0, 20, hasDelete and -30 or 0, 0);
			bottom:AddWidget(edit);
		end

		-- Put in sequence deletion if allowed.
		if(hasDelete) then
			-- Add delete button.
			local delete = PowerAuras:Create("IconButton", bottom);
			delete:SetIcon([[Interface\PetBattles\DeadPetIcon]]);
			delete:SetMargins(2, 20, 4, 0);
			delete.OnClicked:Connect(function()
				-- Prompt.
				local editor = PowerAuras.Editor;
				local dialog = PowerAuras:Create("PromptDialog", editor, 
					L["DialogDeleteSequence"], YES, NO);
				-- Connect callbacks.
				dialog.OnAccept:Connect(function()
					PowerAuras:DeleteAuraActionSequence(id, cur);
					self:RefreshBottombar(math.max(1, cur - 1));
				end);
				-- Auto-cancel the dialog if we change nodes.
				dialog:ConnectCallback(
					editor.Displays.OnCurrentNodeChanged,
					dialog.Cancel
				);
				-- Is the control key down?
				if(IsControlKeyDown()) then
					dialog:Accept();
				end
			end);
			bottom:AddWidget(delete);
		end

		-- Put in sequence editor.
		if(vars["Sequences"][cur]) then
			bottom:AddRow(4);
			class:CreateSequenceEditor(bottom, id, cur);
		end

		-- Show the bar.
		bottom:Show();
	end

	-- Resume the layout of the bar.
	self:FixContentPadding();
	bottom:ResumeLayout();
end

--- Refreshes the host frame.
-- @param node The currently selected node.
function Displays:RefreshHost(node)
	-- Ensure the node is selected.
	if(self:GetCurrentNode() ~= node) then
		self:SetCurrentNode(node);
	end

	-- Reset the parent sidebar/bottombar.
	local parent = self:GetParent();
	parent:ResetSidebar(not node or node == "__ROOT__");
	parent:ResetBottombar();
	parent:ResetTopbar();

	-- Remove the existing preview.
	if(self.Preview) then
		self.Preview:Recycle();
		self.Preview = nil;
	end

	-- Determine what we're displaying.
	self:PauseLayout();
	self:ClearWidgets();

	if(not node or node == "__ROOT__") then
		-- Deselect any display.
		PowerAuras:SetCurrentDisplay(nil);

		-- List our displays.
		for i = 1, select("#", self:GetChildNodes("__ROOT__")) do
			-- Get the data about this display. Check the flags.
			local node = select(i, self:GetChildNodes("__ROOT__"));
			local _, id = PowerAuras:SplitNodeID(node["Key"]);
			local vars = PowerAuras:GetAuraDisplay(id);

			-- Don't show if this display is parented.
			if(Metadata:GetFlagID(vars["Flags"], "Display") == 0) then
				-- Create the preview for it.
				local prev = PowerAuras:Create("GridDisplayPreview", self, id);
				prev:SetFixedSize(96, 96);
				prev:Refresh();

				-- Add widget to frame, get next one.
				self:AddWidget(prev);
			end
		end
	elseif(type(node) == "number") then
		-- Split the node ID.
		local _, id, f1, s1, f2, s2, rtype = PowerAuras:SplitNodeID(node);

		-- Update the selected display ID if possible. To do so, work upwards
		-- until we find a node that is representative of a display.
		local displayNode, drtype, df1 = node, rtype, f1;
		while((drtype == "Actions" or drtype == "Display") and df1 == 1) do
			-- Get parent node.
			displayNode = self:GetParentNode(displayNode);
			-- If root/invalid, break.
			if(not displayNode or displayNode == "__ROOT__") then
				displayNode = nil;
				break;
			end
			-- Update compared types/flags.
			drtype = select(7, PowerAuras:SplitNodeID(displayNode));
			df1 = select(3, PowerAuras:SplitNodeID(displayNode));
		end

		-- If there's still a node, it probably worked.
		if(displayNode) then
			-- Get the display ID and set it as the current display.
			local _, id = PowerAuras:SplitNodeID(displayNode);
			local aID, dID = PowerAuras:SplitAuraDisplayID(id);
			PowerAuras:SetCurrentAura(aID);
			PowerAuras:SetCurrentDisplay(dID);
			-- Add a preview for the display.
			local side = parent.Side.List;
			self.Preview = PowerAuras:Create("DisplayPreview", self, id, true);
			self.Preview:SetFixedSize(96, 96);
			self.Preview:Refresh();
			-- Adjust the sidebar a bit and attach the preview to it.
			side:SetPoint("TOPLEFT", 0, -112);
			self.Preview:SetPoint("BOTTOM", side, "TOP", 0, 4);
		end

		-- Node handlers.
		if(rtype == "Display" and (f1 > 0 or s1 > 0 or f2 > 0 or s2 > 0)) then
			-- Some editors use the Display type and have flags set for
			-- navigational purposes.
			if(f1 == 1 and s1 == 0x20) then
				-- Sound.
				PowerAuras:CreateSoundEditor(self, node);
			elseif(s1 == 0x20) then
				-- Activation.
				PowerAuras:CreateActivationEditor(self, node);
			end
		elseif(rtype == "Style") then
			-- Style editor.
			PowerAuras:CreateStyleEditor(self, node);
		elseif(rtype == "Animations") then
			-- Animation editor.
			PowerAuras:CreateAnimationEditor(self, node);
		elseif(rtype == "Actions") then
			-- Action editor.
			PowerAuras:CreateActionEditor(self, node);
		else
			-- Populate nodes.
			self:PopulateChildNodes();
		end

		-- Populate the sidebar!
		self:RefreshSidebar();
		self:RefreshBottombar();
	end

	-- Resume layout processing.
	self:FixContentPadding();
	self:ResumeLayout();
end

do
	--- Creates editor nodes for an action.
	-- @param self   The editor frame.
	-- @param id     The ID of the action to add.
	-- @param parent The parent node.
	-- @param text   Optional text to show. Defaults to the action name.
	local function createActionNode(self, id, parent, text)
		-- Get the node.
		local key = PowerAuras:GetNodeID("Actions", id, 1, 0, 0, 0);
		if(self:HasNode(key)) then
			return;
		end
		-- Add it.
		local vars = PowerAuras:GetAuraAction(id);
		text = text or L["ActionClasses"][vars["Type"]]["Name"];
		self:AddNode(key, text, parent);
	end

	--- Refreshes the nodes of the frame.
	function Displays:RefreshNodes()
		-- Destroy existing nodes.
		self:PauseLayout();
		local current = self:GetCurrentNode();
		self.OnCurrentNodeChanged:Pause();
		self.OnNodesChanged:Pause();
		self:ClearNodes();
		self.OnCurrentNodeChanged:Resume();
		-- Populate nodes.
		local auraID = PowerAuras:GetCurrentAura();
		for displayID = 1, PowerAuras:GetAuraDisplayCount(auraID) do
			-- Get the display.
			local id = PowerAuras:GetAuraDisplayID(auraID, displayID);
			local vars = PowerAuras:GetAuraDisplay(id);
			local class = PowerAuras:GetDisplayClass(vars["Type"]);

			-- Create root node.
			local root = PowerAuras:GetNodeID("Display", id, 0, 0, 0, 0);
			self:AddNode(root, ("#%d: %s"):format(
				displayID,
				L["DisplayClasses"][vars["Type"]]["Name"]
			));

			-- Activation editor. Skip if this display is linked to another.
			local pID = Metadata:GetFlagID(vars["Flags"], "Display");
			if(pID == 0) then
				local nID = PowerAuras:GetNodeID("Display", id, 0, 0x20, 0, 0);
				self:AddNode(nID, L["Activation"], root);
			end

			-- Style editor.
			local nID = PowerAuras:GetNodeID("Style", id, 0, 0, 0, 0);
			self:AddNode(nID, L["Style"], root);

			-- Animations editor.
			if(class:SupportsAnimation()) then
				local nID = PowerAuras:GetNodeID("Animations", id, 0, 0, 0, 0);
				self:AddNode(nID, L["Animations"], root);
				self:AddNode(
					PowerAuras:GetNodeID("Animations", id, 1, 0, 0, 0),
					L["Advanced"],
					nID
				);
			end

			-- Sound editor.
			local nID = PowerAuras:GetNodeID("Display", id, 1, 0x20, 0, 0);
			self:AddNode(nID, L["Sounds"], root);

			-- Actions editor. Only add if we have eligible actions.
			local canAdd = false;
			for _ in GetEligibleDisplayActions(id) do
				canAdd = true;
				break;
			end
			-- Did we fail that? If so, see if we have non-banned actions.
			if(not canAdd) then
				for actionType, _ in pairs(vars["Actions"]) do
					if(not BannedDisplayActions[actionType]) then
						canAdd = true;
						break;
					end
				end
			end

			-- Can we add it?
			local nID = nil;
			if(canAdd) then
				nID = PowerAuras:GetNodeID("Actions", id, 0, 0, 0, 0);
				self:AddNode(nID, L["Actions"], root);
			end

			-- Add nodes for all actions.
			for actionType, aID in PowerAuras:ByKey(vars["Actions"]) do
				-- Get display action.
				local bannedData = BannedDisplayActions[actionType];
				if(not bannedData) then
					-- Add action as normal.
					if(self:HasNode(nID)) then
						createActionNode(self, aID, nID);
					end
				elseif(type(bannedData) == "table") then
					-- Parent action elsewhere.
					local prt = (bannedData[2] or "Display");
					local pid = (bannedData[3] or id);
					local pf1 = (bannedData[4] or 0);
					local ps1 = (bannedData[5] or 0);
					local pf2 = (bannedData[6] or 0);
					local ps2 = (bannedData[7] or 0);
					local nID = PowerAuras:GetNodeID(
						prt, pid, pf1, ps1, pf2, ps2
					);
					-- Add action.
					if(self:HasNode(nID)) then
						createActionNode(self, aID, nID, bannedData[1]);
					end
				end
			end
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
end

--- Refreshes the sidebar with content based upon the current active
--  node.
function Displays:RefreshSidebar()
	-- Get node data.
	local node = self:GetCurrentNode();
	if(type(node) ~= "number") then
		return;
	end
	local _, id, f1, s1, f2, s2, rtype = PowerAuras:SplitNodeID(node);

	-- Get the listframe for the sidebar.
	local side = self:GetParent().Side.List;
	side:PauseLayout();
	side:Clear();

	-- By default, we connect OnLinkClicked to our node changer.
	self:ConnectCallback(side.OnLinkClicked, self.SetCurrentNode, 2);

	-- Determine how deep in the system we are.
	local displayRoot, previousRoot = node, nil;
	repeat
		previousRoot = displayRoot;
		displayRoot = self:GetParentNode(displayRoot);
	until(self:GetParentNode(displayRoot) == "__ROOT__"
		or displayRoot == "__ROOT__"
		or not displayRoot);

	-- So where are we, exactly?
	local editorType;
	if(displayRoot ~= "__ROOT__") then
		-- We didn't hit the root level, so we're deeper down. Provide
		-- quicklinks to all children of the found node.
		for i = 1, select("#", self:GetChildNodes(displayRoot)) do
			local node = select(i, self:GetChildNodes(displayRoot));
			side:AddLink(node.Key, node.Value);
		end
		-- Set the current link to that of the previous root.
		side:SetCurrentItem(previousRoot);
		-- Determine the tasks to display.
		if(rtype == "Display" and (f1 > 0 or s1 > 0 or f2 > 0 or s2 > 0)) then
			-- Some editors use the Display type and have flags set for
			-- navigational purposes.
			if(f1 == 1 and s1 == 0x20) then
				editorType = "Sound";
			elseif(f1 == 1) then
				editorType = "Sources.Root";
			elseif(s1 == 0x20) then
				editorType = "Activation.Basic";
			end
		elseif(rtype == "Style") then
			editorType = "Style";
		elseif(rtype == "Animations") then
			editorType = "Animations.Root";
		elseif(rtype == "Actions") then
			-- Handle special actions.
			if(f1 == 0) then
				editorType = "Actions.Root";
			else
				local vars = PowerAuras:GetAuraAction(id);
				if(vars["Type"] == "DisplayActivate" and s2 == 0) then
					editorType = "Activation.Advanced";
				elseif(s2 == 0) then
					editorType = "Actions.Sequences";
				elseif(s2 > 0) then
					editorType = "Actions.Trigger";
				end
			end
		end
	else
		-- Probably at the root level, I hope. Add links to 'linked' displays.
		local aID, dID = PowerAuras:SplitAuraDisplayID(id);
		local vars = PowerAuras:GetAuraDisplay(id);
		local gID = id;

		-- Do we have a parent display?
		local vars = PowerAuras:GetAuraDisplay(gID);
		local pID = Metadata:GetFlagID(vars["Flags"], "Display");
		if(pID > 0) then
			-- Generate the list from the parent.
			gID = PowerAuras:GetAuraDisplayID(aID, pID);
			vars = PowerAuras:GetAuraDisplay(gID);
			dID = pID;
		end

		-- Add link to the 'main' display.
		side:AddLink(
			PowerAuras:GetNodeID("Display", gID, 0, 0, 0, 0),
			L["DisplayClasses"][vars["Type"]]["Name"]
		);

		-- Run over the aura to find linked displays.
		local aVars = PowerAuras:GetAura(aID);
		for i = 1, #(aVars.Displays) do
			-- Linked?
			local lVars = aVars.Displays[i];
			local lID = Metadata:GetFlagID(lVars["Flags"], "Display");
			if(lID == dID) then
				-- Yes it is.
				side:AddLink(
					PowerAuras:GetNodeID(
						"Display",
						PowerAuras:GetAuraDisplayID(aID, i),
						0,
						0,
						0,
						0
					),
					L["DisplayClasses"][lVars["Type"]]["Name"]
				);
			end
		end

		-- Set the current item.
		side:SetCurrentItem(PowerAuras:GetNodeID("Display", id, 0, 0, 0, 0));

		-- Set editor type to Display.
		editorType = "Display";
	end

	-- Add tasks.
	local tasks = EditorTasks[editorType or ""];
	if(tasks) then
		-- All tasks should be visible.
		side:SetMaxTasks(#(tasks));
		for i = 1, #(tasks) do
			-- Extract task data.
			local task = tasks[i];
			-- Check if the task should be shown.
			local show = task.ShouldShow;
			if(show and show(node, id) or not show) then
				side:AddTask(
					task.Text, task.Icon, task.OnClicked, task.TexCoords
				);
			end
		end
	end

	-- Resume the layout.
	side:ResumeLayout();
end