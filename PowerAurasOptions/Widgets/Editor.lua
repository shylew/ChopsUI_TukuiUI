-- Lock down local environment.
local PowerAuras = _G["PowerAuras"];
setfenv(1, PowerAuras);

--- Compresses the passed data and returns a node ID for use with a
--  breadcrumb frame. Each node is supposed to be unique.
-- @param rType The resource/editor type.
-- @param id    The main ID of the resource. Capped between 0-65535.
-- @param flag1 Bit flag #1. Must be 0 or 1.
-- @param sub1  Sub-resource ID #1. Capped between 0-63.
-- @param flag2 Bit flag #2. Must be 0 or 1.
-- @param sub2  Sub-resource ID #2. Capped between 0-63.
function PowerAuras:GetNodeID(rType, id, flag1, sub1, flag2, sub2)
	-- Convert string types to numeric types.
	rType = (type(rType) == "string"
		and (rType == "Display" and 0x0
			or rType == "Style" and 0x1
			or rType == "Animations" and 0x2
			or rType == "Actions" and 0x3)
		or tonumber(rType));
	-- Set flags to 0 if needed.
	rType, id, flag1, sub1, flag2, sub2 =
		rType or 0, id or 0, flag1 or 0, sub1 or 0, flag2 or 0, sub2 or 0;
	-- Return generated ID.
	local node = bit.bor(
		-- 0xC0000000: Editor type.
		bit.lshift(bit.band(rType or 0, 0x3), 30),
		-- 0x3FFFC000: Resource ID.
		bit.lshift(bit.band(id or 0, 0xFFFF), 14),
		-- 0x00002000: Flag #1
		bit.lshift(bit.band(flag1 or 0, 0x1), 13),
		-- 0x00001F80: Resource sub-ID #1
		bit.lshift(bit.band(sub1 or 0, 0x3F), 7),
		-- 0x00000040: Flag #2
		bit.lshift(bit.band(flag2 or 0, 0x1), 6),
		-- 0x0000003F: Resource sub-ID #2
		bit.band(sub2 or 0, 0x3F)
	);
	-- Debug assertions.
	if(self.Debug) then
		local r1, r2, r3, r4, r5, r6 = self:SplitNodeID(node);
		assert(rType == r1, ("%s == %s (Resource Type)"):format(rType, r1));
		assert(id == r2, ("%s == %s (Resource ID)"):format(id, r2));
		assert(flag1 == r3, ("%s == %s (Flag #1)"):format(flag1, r3));
		assert(sub1 == r4, ("%s == %s (Subresource ID #1)"):format(sub1, r4));
		assert(flag2 == r5, ("%s == %s (Flag #2)"):format(flag2, r5));
		assert(sub2 == r6, ("%s == %s (Subresource ID #2)"):format(sub2, r6));
	end
	-- Done, return ID.
	return node;
end

--- Splits the passed node ID into all of its components.
function PowerAuras:SplitNodeID(node)
	local rtype = bit.rshift(node, 30);
	return rtype,
		bit.band(bit.rshift(node, 14), 0xFFFF),
		bit.band(bit.rshift(node, 13), 0x1),
		bit.band(bit.rshift(node, 7), 0x3F),
		bit.band(bit.rshift(node, 6), 0x1),
		bit.band(node, 0x3F),
		rtype == 0 and "Display"
			or rtype == 1 and "Style"
			or rtype == 2 and "Animations"
			or rtype == 3 and "Actions"
			or rtype;
end

--- Aura editor window. This is a child of the Workspace.
local Editor = PowerAuras:RegisterWidget("Editor", "Window", {
	--- Editor sections.
	Sections = { "Displays", "Triggers", --[["Tutorials"]] },
	--- Tasks by category.
	Tasks = {
		["Displays"] = {
			[1] = {
				Text = L["NewDisplay"],
				Icon = [[Interface\PaperDollInfoFrame\Character-Plus]],
				ShouldShow = function()
					-- Show if we can fit more displays on this aura.
					local auraID = PowerAuras:GetCurrentAura();
					if(not auraID) then
						return false;
					end
					local vars = PowerAuras:GetAura(auraID);
					local displays = vars["Displays"];
					return #(displays) < PowerAuras.MAX_DISPLAYS_PER_AURA;
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
						-- Populate menu with display classes.
						for _, id, name in PowerAuras:IterDisplayClasses() do
							local l = L["DisplayClasses"][id];
							menu:AddItem(id, nil, name, l["Tooltip"]);
						end
						-- Add value changed handler.
						menu.OnValueUpdated:Reset();
						menu.OnValueUpdated:Connect(function(menu, key)
							-- Close the menu.
							menu:CloseMenu();
							-- Construct class.
							local aID = PowerAuras:GetCurrentAura();
							local dID = PowerAuras:CreateAuraDisplay(aID, key);
							local _, dID = PowerAuras:SplitAuraDisplayID(dID);
							PowerAuras:SetCurrentDisplay(dID);
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
		["Triggers"] = {
			[1] = {
				Text = L["NewTrigger"],
				Icon = [[Interface\PaperDollInfoFrame\Character-Plus]],
				ShouldShow = function()
					return #(PowerAuras.GlobalSettings.Triggers) < 65535;
				end,
				OnClicked = function()
					PowerAuras:CreateCustomTrigger();
				end,
			},
		},
		["Root"] = {
			[1] = {
				Text = L["EditName"],
				Icon = [[Interface\Buttons\UI-GuildButton-PublicNote-Up]],
				OnClicked = function(item)
					-- Create edit dialog.
					local editor = PowerAuras.Editor;
					local dlg = PowerAuras:Create("BasicDialog", editor);

					-- Get the current node.
					local node = editor.Triggers:GetCurrentNode();
					local id = PowerAuras:GetCurrentAura();
					local vars = PowerAuras:GetAura(id);

					-- Name box.
					local host = dlg.Host;
					local name = PowerAuras:Create("EditBox", host);
					name:SetPadding(4, 0, 4, 0);
					name:SetRelativeWidth(0.5);
					name:SetTitle(L["Name"]);
					name:SetText(vars.Name);
					host:AddWidget(name);

					-- Icon box.
					local icon = PowerAuras:Create("EditBox", host);
					icon:SetPadding(4, 0, 4, 0);
					icon:SetRelativeWidth(0.5);
					icon:SetTitle(L["SpellIcon"]);
					icon:SetText(vars.Icon);
					host:AddWidget(icon);

					-- Description box.
					local desc = PowerAuras:Create("CodeBox", host, true, 12);
					desc:SetPadding(4, 0, 4, 52);
					desc:SetMargins(0, 0, 0, -52);
					desc:SetRelativeSize(1.0, 1.0);
					desc:SetText(vars.Description);
					host:AddWidget(desc);

					-- OnAccept callback.
					dlg.OnAccept:Connect(function()
						-- Eat the contents of the widgets.
						vars.Name = host.Widgets[1]:GetText();
						vars.Description = host.Widgets[3].Edit:GetText();
						vars.Icon = host.Widgets[2]:GetText();
						vars.Icon = tonumber(vars.Icon) or vars.Icon;
						PowerAuras.Browser:RefreshContent();
					end);
				end,
			},
			[2] = {
				Text = L["DeleteAura"],
				Icon = [[Interface\PetBattles\DeadPetIcon]],
				OnClicked = function(item)
					-- Get the current aura ID.
					local id = PowerAuras:GetCurrentAura(id);
					-- Display a dialog over the editor.
					local editor = PowerAuras.Editor;
					local dialog = PowerAuras:Create("PromptDialog", editor, 
						L["DialogDeleteAura"], YES, NO);
					-- Connect callbacks.
					dialog.OnAccept:Connect(function()
						-- Delete aura.
						PowerAuras:DeleteAura(id);
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

-- Copy root items into other task lists.
for k, v in ipairs(Editor.Tasks.Root) do
	for category, tasks in pairs(Editor.Tasks) do
		if(category ~= "Root") then
			tinsert(tasks, v);
		end
	end
end

--- Constructs the editor window.
-- @param parent The parent of the window.
function Editor:New(parent)
	-- Construct as normal.
	local frame = base(self, parent, "PowerAurasEditor");
	-- Update background.
	frame.Bg:SetTexture([[Interface\HelpFrame\DarkSandstone-Tile]], true);
	frame.TitleBg:SetTexture([[Interface\HelpFrame\DarkSandstone-Tile]], true);
	-- Rename some regions.
	frame.Close = frame.CloseButton;
	frame.Title = frame.TitleText;
	-- Add our subframes.
	frame.Side = PowerAuras:Create("BlueFrame", frame, "RIGHT");
	frame.Side:SetPoint("TOPLEFT", 2, -22);
	frame.Side:SetPoint("BOTTOMLEFT", 2, 2);
	frame.Side:SetWidth(180);
	-- Top bar.
	frame.Top = PowerAuras:Create("BlueFrame", frame, "BOTTOM");
	frame.Top.Bg:SetTexture([[Interface\HelpFrame\DarkSandstone-Tile]], true);
	frame.Top.Bg:SetTexCoord(0, 1, 0, 1);
	frame.Top.Bg:SetVertexColor(0.4, 0.4, 0.4);
	frame.Top.Bg:SetHorizTile(true);
	frame.Top.Bg:SetVertTile(true);
	frame.Top.ST:ClearAllPoints();
	frame.Top.ST:SetPoint("TOPLEFT", frame.Top, "BOTTOMLEFT");
	frame.Top.ST:SetPoint("TOPRIGHT", frame.Top, "BOTTOMRIGHT");
	frame.Top.SL:Hide();
	frame.Top.SR:Hide();
	frame.Top.SB:Hide();
	frame.Top.Bar:SetTexCoord(0, 1, 0.445312, 0.492188);
	frame.Top.Bar:SetPoint("TOPLEFT", frame.Top, "BOTTOMLEFT", 0, 0);
	frame.Top.Bar:SetPoint("TOPRIGHT", frame.Top, "BOTTOMRIGHT", 0, 0);
	frame.Top:SetPoint("TOPLEFT", 185, -56);
	frame.Top:SetPoint("TOPRIGHT", -3, -56);
	frame.Top:SetLayoutType("Fluid");
	frame.Top:SetContentPadding(4, 4, 4, 4);
	frame.Top:Hide();
	-- Bottom bar.
	frame.Bottom = PowerAuras:Create("BlueFrame", frame, "TOP");
	frame.Bottom.Bg:SetTexture([[Interface\HelpFrame\DarkSandstone-Tile]],
		true);
	frame.Bottom.Bg:SetTexCoord(0, 1, 0, 1);
	frame.Bottom.Bg:SetVertexColor(0.4, 0.4, 0.4);
	frame.Bottom.Bg:SetHorizTile(true);
	frame.Bottom.Bg:SetVertTile(true);
	frame.Bottom.SB:ClearAllPoints();
	frame.Bottom.SB:SetPoint("BOTTOMLEFT", frame.Bottom, "TOPLEFT");
	frame.Bottom.SB:SetPoint("BOTTOMRIGHT", frame.Bottom, "TOPRIGHT");
	frame.Bottom.SL:Hide();
	frame.Bottom.SR:Hide();
	frame.Bottom.ST:Hide();
	frame.Bottom.Bar:SetTexCoord(0, 1, 0.492188, 0.445312);
	frame.Bottom.Bar:SetPoint("BOTTOMLEFT", frame.Bottom, "TOPLEFT", 0, 0);
	frame.Bottom.Bar:SetPoint("BOTTOMRIGHT", frame.Bottom, "TOPRIGHT", 0, 0);
	frame.Bottom:SetPoint("BOTTOMLEFT", 185, 2);
	frame.Bottom:SetPoint("BOTTOMRIGHT", -3, 2);
	frame.Bottom:SetLayoutType("Fluid");
	frame.Bottom:SetContentPadding(4, 4, 4, 4);
	frame.Bottom:Hide();
	-- Sidebar navigation and task frames.
	frame.Side.List = PowerAuras:Create("EditorNavList", frame.Side);
	frame.Side.List:SetPoint("TOPLEFT");
	frame.Side.List:SetPoint("BOTTOMRIGHT");
	-- Keep track of the active subframe.
	frame.ActiveSection = 1;
	-- Done!
	return frame;
end

--- Initialises a new instance of the editor frame.
function Editor:Initialise(parent)
	-- Set up the main frame.
	base(self, parent);
	self:SetParent(parent);
	self:SetPoint("RIGHT", 0, 0);
	self:SetSize(640, 480);
	self:SetUserPlaced(true);
	self:SetClampRectInsets(600, -600, -440, 440);
	self:SetClampedToScreen(true);
	self:SetTitle(L["Editor"]);
	self:RegisterEvent("MODIFIER_STATE_CHANGED");
	self:Hide();
	-- Editor frames.
	for i, sub in ipairs(self.Sections) do
		-- Create the frame.
		self[sub] = PowerAuras:Create("Editor" .. sub, self);
		self[sub]:SetBackdrop(nil);
		self[sub]:SetPoint("TOPLEFT", 181, -16);
		self[sub]:SetPoint("BOTTOMRIGHT", -2, 2);
		self[sub]:SetRootText(L[sub]);
		-- Hide all but the first.
		self[sub]:SetShown(i == 1);
	end
	-- Connect callbacks.
	self:ConnectCallback(PowerAuras.OnOptionsEvent, self.OnOptionsEvent);
end

--- OnEvent script handler.
-- @param event The fired event.
function Editor:OnEvent(event)
	-- Check modifier keys.
	if(IsShiftKeyDown() and IsControlKeyDown() and IsAltKeyDown()
		and self:IsMouseOver()) then
		self:SetAlpha(0.25);
	else
		self:SetAlpha(1.0);
	end
end

--- OnEnter script handler.
function Editor:OnEnter()
	base(self);
	if(IsShiftKeyDown() and IsControlKeyDown() and IsAltKeyDown()
		and self:IsMouseOver()) then
		self:SetAlpha(0.25);
	else
		self:SetAlpha(1.0);
	end
end

--- OnLeave script handler.
function Editor:OnLeave()
	base(self);
	if(IsShiftKeyDown() and IsControlKeyDown() and IsAltKeyDown()
		and self:IsMouseOver()) then
		self:SetAlpha(0.25);
	else
		self:SetAlpha(1.0);
	end
end

--- OnHide script handler.
function Editor:OnHide()
	PlaySound("igMainMenuClose");
	-- Stop moving the window.
	if(self.isMoving and self:IsMovable()) then
		self.isMoving = false;
		self:StopMovingOrSizing();
	end
	-- Deselect any auras.
	PowerAuras:SetCurrentAura(nil);
end

--- Callback handler for OnOptionsEvent.
-- @param event The event that fired.
-- @param ...   Event parameters.
function Editor:OnOptionsEvent(event, ...)
	-- Handle selection events.
	if(event == "SELECTED_AURA_CHANGED") then
		self:SetShown(PowerAuras:HasAura((...)));
	elseif(event == "WS_PARENTING_UPDATE") then
		-- Hide if we're parenting something.
		if((...) > 0) then
			self:Hide();
		elseif(PowerAuras:HasAura(PowerAuras:GetCurrentAura())) then
			self:Show();
		end
	end
end

--- OnShow script handler.
function Editor:OnShow()
	PlaySound("igCharacterInfoTab");
end

--- Refreshes the current editor pane.
function Editor:Refresh()
	local frame = self[self.Sections[self.ActiveSection]];
	if(not frame) then
		return;
	end
	frame:RefreshHost(frame:GetCurrentNode());
end

--- Resets the bottom bar.
function Editor:ResetBottombar()
	self.Bottom:ClearWidgets();
	self.Bottom:Hide();
end

--- Resets the sidebar.
-- @param root If true, the default items are shown for switching sections.
function Editor:ResetSidebar(root)
	-- Root node or not?
	self.Side.List:PauseLayout();
	self.Side.List:ClearAllPoints();
	self.Side.List:SetPoint("TOPLEFT");
	self.Side.List:SetPoint("BOTTOMRIGHT");
	self.Side.List:SetMaxTasks(4);
	self.Side.List.OnLinkClicked:Reset();
	self.Side.List.OnHomeClicked:Reset();
	self.Side.List:SetHome(nil, nil);
	self.Side.List:SetCurrentItem(nil);
	self.Side.List:Clear();
	-- If root node, sneak in some tasks and navigation items.
	if(root) then
		local list = self.Side.List;
		-- Add a home item.
		list:SetHome("__ROOT__", L["Resources"]);
		-- Add links to each section.
		for i = 1, #(self.Sections) do
			list:AddLink(i, L[self.Sections[i]]);
		end
		-- Set the current link too.
		list:SetCurrentItem(self.ActiveSection);
		-- Add task items based upon the section.
		local tasks = self.Tasks[self.Sections[self.ActiveSection]];
		if(tasks) then
			list:SetMaxTasks(#(tasks));
			for i = 1, #(tasks) do
				-- Extract task data.
				local task = tasks[i];
				local text, icon, func = task.Text, task.Icon, task.OnClicked;
				-- Check if the task should be shown.
				local show = task.ShouldShow;
				if(show and show() or not show) then
					list:AddTask(text, icon, func);
				end
			end
		end
		-- Connect callback.
		self:ConnectCallback(list.OnLinkClicked, self.SetCurrentSection, 2);
	end
	-- Resume the layout of the sidebar list.
	self.Side.List:ResumeLayout();
end

--- Resets the top bar.
function Editor:ResetTopbar()
	self.Top:ClearWidgets();
	self.Top:Hide();
end

--- Sets the active section.
-- @param index The index or name of the section.
function Editor:SetCurrentSection(index)
	-- Determine the index.
	index = tonumber(index);
	if(not self.Sections[index]) then
		-- Try to find it.
		index = nil;
		for i = 1, #(self.Sections) do
			if(self.Sections[i] == index) then
				index = i;
				break;
			end
		end
		-- Got it?
		assert(index, "Invalid section passed.");
	end
	-- Update.
	self.ActiveSection = index;
	self:ResetSidebar(true);
	self:ResetBottombar();
	self:ResetTopbar();
	for i = 1, #(self.Sections) do
		local sub = self.Sections[i];
		self[sub]:SetShown(index == i);
	end
end

--- Sidebar navigation and tasks list for the editor.
local NavList = PowerAuras:RegisterWidget("EditorNavList", "Frame");

--- Initialises the widget.
-- @param parent The parent frame of the widget.
function NavList:Initialise(parent)
	-- Update parent.
	self:SetParent(parent);
	-- Item storage.
	self.Store = setmetatable({}, { __mode = "v" });
	self.Home  = {};
	self.Tasks = {};
	self.Links = {};
	-- Widget storage.
	self.Items = {};
	-- Generic scroll items.
	self.Up = { Icon = [[Interface\Minimap\MiniMap-PositionArrows]] };
	self.Down = { Icon = [[Interface\Minimap\MiniMap-PositionArrows]] };
	-- Scroll offsets.
	self.TasksOffset = 0;
	self.LinksOffset = 0;
	-- Maximum visible tasks.
	self.MaxTasks = 4;
	-- Callbacks.
	self.OnLinkClicked = PowerAuras.Callback();
	self.OnHomeClicked = PowerAuras.Callback();
end

--- Adds a navigation link to the list.
-- @param key  A key to pass to the callback.
-- @param text The text to display.
function NavList:AddLink(key, text)
	-- Get an item table and fill it.
	local item = tremove(self.Store) or {};
	item.Key, item.Text = key, text;
	tinsert(self.Links, item);
	-- Update.
	self:PerformLayout();
end

--- Adds a task item to the list.
-- @param text  The text to display.
-- @param icon  An icon to display.
-- @param func  Callback function to execute when the item is clicked.
-- @param tc    Optional table of texture co-ordinates for the icon.
function NavList:AddTask(text, icon, func, tc)
	-- Get an item table and fill it.
	local item = tremove(self.Store) or {};
	item.Icon, item.Text, item.Callback, item.TexCoords = icon, text, func, tc;
	tinsert(self.Tasks, item);
	-- Update.
	self:PerformLayout();
end

--- Removes all items from the navigation list.
function NavList:Clear()
	-- Remove it all.
	for i = #(self.Tasks), 1, -1 do
		tinsert(self.Store, wipe(tremove(self.Tasks, i)));
	end
	for i = #(self.Links), 1, -1 do
		tinsert(self.Store, wipe(tremove(self.Links, i)));
	end
	-- Update.
	self:PerformLayout();
end

--- Displays the items within the list.
function NavList:PerformLayout()
	-- Skip if paused.
	if(not base(self)) then
		return;
	else
		self.LayoutPaused = (self.LayoutPaused or 0) + 1;
	end
	-- Recycle widgets.
	for i = #(self.Items), 1, -1 do
		tremove(self.Items, i):Recycle();
	end
	-- Get frame size.
	local height = self:GetHeight() - 32 - (self.Home.Text and 34 or 0);

	-- Get link/task limits.
	local maxTasks = math.min(#(self.Tasks), self.MaxTasks);
	local tasksUp = (self.TasksOffset > 0);
	local realTasks = maxTasks - (tasksUp and 1 or 0);
	local tasksDown = (self.TasksOffset + realTasks < #(self.Tasks));
	realTasks = realTasks - (tasksDown and 1 or 0);

	-- Same for links.
	local maxLinks = math.floor(height / 24) - maxTasks;
	local linksUp = (self.LinksOffset > 0);
	local realLinks = maxLinks - (linksUp and 1 or 0);
	local linksDown = (self.LinksOffset + realLinks < #(self.Links));
	realLinks = realLinks - (linksDown and 1 or 0);

	-- Home item first, this one goes right at the top.
	local off = (self.Home.Key ~= nil and 38 or 4);
	if(self.Home.Key ~= nil) then
		local item = self.Home;
		local bar = PowerAuras:Create("EditorNavItem", self, "Home", item);
		bar:SetPoint("TOPLEFT", 4, 0);
		bar:SetPoint("TOPRIGHT", -4, 0);
		bar:SetHeight(34);
		tinsert(self.Items, bar);
	end

	-- Links next.
	if(linksUp) then
		-- Scroll up for links.
		local item = self.Up;
		local d = (self.LinksOffset == 2 and -2 or -1);
		local bar = PowerAuras:Create("EditorNavItem", self, "Link", item, d);
		bar:SetPoint("TOPLEFT", 4, -off);
		bar:SetPoint("TOPRIGHT", -4, -off);
		tinsert(self.Items, bar);
	end

	local o = (linksUp and 1 or 0);
	for i = 1, math.min(realLinks, #(self.Links) - self.LinksOffset) do
		-- Add the item.
		local item = self.Links[self.LinksOffset + i];
		local bar = PowerAuras:Create("EditorNavItem", self, "Link", item);
		bar:SetPoint("TOPLEFT", 4, -(off + ((i + o - 1) * 24)));
		bar:SetPoint("TOPRIGHT", -4, -(off + ((i + o - 1) * 24)));
		tinsert(self.Items, bar);
	end
	
	if(linksDown) then
		-- Scroll down for links.
		local item = self.Down;
		local d = (self.LinksOffset == 0 and 2 or 1);
		local bar = PowerAuras:Create("EditorNavItem", self, "Link", item, d);
		bar:SetPoint("TOPLEFT", 4, -(off + ((realLinks + o) * 24)));
		bar:SetPoint("TOPRIGHT", -4, -(off + ((realLinks + o) * 24)));
		tinsert(self.Items, bar);
	end

	-- Then tasks at the bottom.
	height = 8 + ((maxTasks - 1) * 24);
	if(tasksUp) then
		-- Scroll up for tasks.
		local item = self.Up;
		local d = (self.TasksOffset == 2 and -2 or -1);
		local bar = PowerAuras:Create("EditorNavItem", self, "Task", item, d);
		bar:SetPoint("BOTTOMLEFT", 4, height);
		bar:SetPoint("BOTTOMRIGHT", -4, height);
		tinsert(self.Items, bar);
		height = height - 24;
	end

	for i = 1, math.min(realTasks, #(self.Tasks) - self.TasksOffset) do
		local item = self.Tasks[self.TasksOffset + i];
		local bar = PowerAuras:Create("EditorNavItem", self, "Task", item);
		bar:SetPoint("BOTTOMLEFT", 4, (height - ((i - 1) * 24)));
		bar:SetPoint("BOTTOMRIGHT", -4, (height - ((i - 1) * 24)));
		tinsert(self.Items, bar);
	end

	if(tasksDown) then
		-- Scroll down for tasks.
		local item = self.Down;
		local d = (self.TasksOffset == 0 and 2 or 1);
		local bar = PowerAuras:Create("EditorNavItem", self, "Task", item, d);
		bar:SetPoint("BOTTOMLEFT", 4, (height - (realTasks * 24)));
		bar:SetPoint("BOTTOMRIGHT", -4, (height - (realTasks * 24)));
		tinsert(self.Items, bar);
		height = height - 24;
	end
	-- Unlock the layout again.
	self.LayoutPaused = (self.LayoutPaused or 1) - 1;
end

--- Scrolls the navigation list.
-- @param delta The amount to scroll by. Negative values go up.
function NavList:ScrollLinks(delta)
	-- Update the offset.
	self.LinksOffset = math.max(0,
		math.min(self.LinksOffset + delta, #(self.Links)));
	-- Update.
	self:PerformLayout();
end

--- Scrolls the task list.
-- @param delta The amount to scroll by. Negative values go up.
function NavList:ScrollTasks(delta)
	-- Update the offset.
	self.TasksOffset = math.max(0,
		math.min(self.TasksOffset + delta, #(self.Tasks)));
	-- Update.
	self:PerformLayout();
end

--- Sets the current navigation item.
-- @param key The key of the item.
function NavList:SetCurrentItem(key)
	-- Find it.
	for i = 1, #(self.Links) do
		self.Links[i].IsCurrent = (self.Links[i].Key == key);
	end
	-- Update.
	self:PerformLayout();
end

--- Sets the home item text.
-- @param key  The key of the home item.
-- @param text The text to display.
function NavList:SetHome(key, text)
	-- Update the home item.
	self.Home.Key = key;
	self.Home.Text = text;
	-- Update.
	self:PerformLayout();
end

--- Sets the maximum number of visible tasks.
-- @param count The value to set.
function NavList:SetMaxTasks(count)
	-- Update.
	self.MaxTasks = count;
	self:PerformLayout();
end

--- Item widget for the editor nav list.
local NavItem = PowerAuras:RegisterWidget("EditorNavItem", "ReusableWidget");

--- Constructs/recycles an instance of the widget.
function NavItem:New()
	-- Recycle if possible.
	local frame = base(self);
	if(not frame) then
		-- Create.
		frame = CreateFrame("CheckButton", nil, UIParent);
		-- Text.
		frame.Text = frame:CreateFontString(nil, "OVERLAY");
		frame.Text:SetPoint("TOPLEFT", 28, 0);
		frame.Text:SetPoint("BOTTOMRIGHT", -8, 0);
		frame.Text:SetFontObject(GameFontNormal);
		frame.Text:SetJustifyH("RIGHT");
		frame.Text:SetJustifyV("MIDDLE");
		frame.Text:SetWordWrap(false);
		frame:SetFontString(frame.Text);
		-- Icon.
		frame.Icon = frame:CreateTexture(nil, "ARTWORK");
		frame.Icon:SetSize(16, 16);
		frame.Icon:SetPoint("TOPLEFT", 4, -2);
		-- Glows are so 2012.
		frame.GlowT = frame:CreateTexture(nil, "BORDER");
		frame.GlowT:SetAlpha(0.5);
		frame.GlowT:SetTexture([[Interface\Common\talent-blue-glow]], true);
		frame.GlowT:SetBlendMode("ADD");
		frame.GlowT:SetTexCoord(0, 1, 1, 0);
		frame.GlowT:SetHorizTile(true);
		frame.GlowT:SetPoint("TOPLEFT", -4, 0);
		frame.GlowT:SetPoint("TOPRIGHT", 4, 0);
		frame.GlowT:SetHeight(8);
		frame.GlowB = frame:CreateTexture(nil, "BORDER");
		frame.GlowB:SetAlpha(0.5);
		frame.GlowB:SetTexture([[Interface\Common\talent-blue-glow]], true);
		frame.GlowB:SetBlendMode("ADD");
		frame.GlowB:SetHorizTile(true);
		frame.GlowB:SetPoint("BOTTOMLEFT", -4, 0);
		frame.GlowB:SetPoint("BOTTOMRIGHT", 4, 0);
		frame.GlowB:SetHeight(8);
	end
	return frame;
end

--- Initialises the widget.
-- @param parent The parent frame.
-- @param type   The item type.
-- @param item   The item table.
-- @param dir    If not nil, this is the scrolling direction.
function NavItem:Initialise(parent, type, item, dir)
	-- Store the item, update the parent.
	self:SetParent(parent);
	self:SetHeight(20);
	self.Item = item;
	self.Type = type;
	self.Dir = dir;

	-- Update our display.
	if(not dir) then
		self:SetText(item.Text);
		if(item.Icon) then
			self.Text:SetPoint("TOPLEFT", 28, 0);
			self.Icon:SetTexture(item.Icon);
			if(item.TexCoords) then
				self.Icon:SetTexCoord(unpack(item.TexCoords));
			else
				self.Icon:SetTexCoord(0, 1, 0, 1);
			end
			self.Icon:SetPoint("TOPLEFT", 4, -2);
			self.Icon:Show();
		else
			self.Text:SetPoint("TOPLEFT", 8, 0);
			self.Icon:Hide();
		end
		-- Checked item?
		self:SetChecked(item.IsCurrent);
		if(item.IsCurrent) then
			self.Text:SetFontObject(GameFontHighlight);
			self.GlowT:SetShown(true);
			self.GlowB:SetShown(true);
		else
			self.Text:SetFontObject(GameFontNormal);
			self.GlowT:SetShown(self:IsMouseOver());
			self.GlowB:SetShown(self:IsMouseOver());
		end
	else
		-- Direction buttons are a bit different.
		self:SetText("");
		self:SetChecked(false);
		self.GlowT:SetShown(self:IsMouseOver());
		self.GlowB:SetShown(self:IsMouseOver());
		-- Move the icon to the center.
		self.Icon:SetPoint("TOPLEFT", self, "CENTER", -8, 8);
		self.Icon:SetTexture(item.Icon);
		if(dir > 0) then
			self.Icon:SetTexCoord(0.0, 1.0, 0.5, 1.0);
		else
			self.Icon:SetTexCoord(0.0, 1.0, 0.0, 0.5);
		end
		self.Icon:Show();
	end

	-- Disable if home item.
	self:SetEnabled(type ~= "Home");
	self.Text:SetFontObject(
		type == "Home" and GameFontNormalLarge
		or item.IsCurrent
			and GameFontHighlight
			or GameFontNormal
	);
end

--- OnClick script handler for the widget.
function NavItem:OnClick()
	-- Play a little sound.)
	PlaySound("UChatScrollButton");
	-- Reset a little state.
	self:SetChecked(not self:GetChecked());
	-- Callback tonight.
	local parent = self:GetParent();
	if(self.Type == "Home") then
		parent:OnHomeClicked(self.Item.Key);
	elseif(self.Type == "Link") then
		if(not self.Dir) then
			parent:OnLinkClicked(self.Item.Key);
		else
			parent:ScrollLinks(self.Dir);
		end
	elseif(self.Type == "Task") then
		if(not self.Dir) then
			self.Item.Callback(self);
		else
			parent:ScrollTasks(self.Dir);
		end
	end
end

--- OnEnter script handler.
function NavItem:OnEnter()
	base(self);
	self.GlowT:SetShown(true);
	self.GlowB:SetShown(true);
end

--- OnLeave script handler.
function NavItem:OnLeave()
	base(self);
	self.GlowT:SetShown(self:GetChecked());
	self.GlowB:SetShown(self:GetChecked());
end

--- Hooked SetChecked function.
-- @param state The state to set.
function NavItem:SetChecked(state)
	-- Process as normal.
	self:__SetChecked(state);
	-- Update textures/fonts.
	self.Text:SetFontObject(state and GameFontHighlight or GameFontNormal);
	self.GlowT:SetShown(GetMouseFocus() == self);
	self.GlowB:SetShown(GetMouseFocus() == self);
end