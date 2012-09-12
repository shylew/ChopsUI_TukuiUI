-- Lock down local environment.
local PowerAuras = _G["PowerAuras"];
setfenv(1, PowerAuras);

--- Workspace widget. This is where all the auras are displayed.
local Workspace = PowerAuras:RegisterWidget("Workspace", "Container");

--- Creates a new instance of the widget and returns the frame.
function Workspace:New()
	-- Create the frame, style it.
	local frame = CreateFrame("Frame", "PowerAurasGUIWS", UIParent);
	frame:SetAllPoints(UIParent);
	frame:Hide();
	-- Close on escape key. Hence the need for a name.
	tinsert(UISpecialFrames, frame:GetName());
	-- Hide when in combat.
	frame:RegisterEvent("PLAYER_REGEN_DISABLED");
	-- Create editor frame.
	PowerAuras["Editor"] = PowerAuras:Create("Editor", frame);
	PowerAuras["Browser"] = PowerAuras:Create("Browser", frame);
	-- Connect OnOptionsLoaded safely.
	PowerAuras["Browser"]:ConnectCallback(
		PowerAuras.OnOptionsLoaded,
		PowerAuras["Browser"].OnOptionsEvent
	);
	-- Return the frame.
	return frame;
end

--- Initialises the widget.
function Workspace:Initialise()
	-- Listen to OnOptionsEvent.
	self:ConnectCallback(PowerAuras.OnOptionsEvent, self.OnOptionsEvent);
	-- Display parenting stuff.
	self.ParentingDisplay = false;
	self.ParentingAnchor = nil;
	-- Collection of workspace previews.
	self.Displays = setmetatable({}, {
		__index = function(t, k)
			-- Create a preview for this display.
			if(not PowerAuras:HasAuraDisplay(k)) then
				return;
			end
			-- Safely create the display.
			local s, r = pcall(PowerAuras.Create, PowerAuras,
				"WorkspacePreview", self, k);
			if(not s) then
				PowerAuras:PrintError(r);
				return nil;
			else
				t[k] = r;
			end
			-- Return the display.
			return r;
		end,
	});
	-- Collection of workspace layouts.
	self.Layouts = setmetatable({}, {
		__index = function(t, k)
			-- Create a preview for this layout.
			if(not PowerAuras:HasLayout(k)) then
				return;
			end
			-- Safely create the layout.
			local s, r = pcall(PowerAuras.Create, PowerAuras,
				"WorkspaceLayout", self, k);
			if(not s) then
				PowerAuras:PrintError(r);
				return nil;
			else
				t[k] = r;
			end
			-- Return the layout.
			return r;
		end,
	});
end

--- Creates all preview frames.
function Workspace:CreatePreviews()
	local auraID = PowerAuras:GetCurrentAura();
	if(auraID and PowerAuras:HasAura(auraID)) then
		for i, vars in ipairs(PowerAuras:GetAura(auraID).Displays) do
			local id = PowerAuras:GetAuraDisplayID(auraID, i);
			local frame = self.Displays[id];
			if(frame) then
				-- Get the layout too.
				local layout = self.Layouts[vars["Layout"]["ID"]];
				if(layout) then
					layout:AttachDisplay(id);
				end
			end
		end
	end
end

--- Destroys all preview frames.
function Workspace:DestroyPreviews()
	local id, preview = next(self.Layouts);
	while(id) do
		preview:Recycle();
		self.Layouts[id] = nil;
		id, preview = next(self.Layouts, id);
	end
	local id, preview = next(self.Displays);
	while(id) do
		preview:Recycle();
		self.Displays[id] = nil;
		id, preview = next(self.Displays, id);
	end
end

--- Returns the current display used for parenting.
function Workspace:GetParentingDisplay()
	return self.ParentingDisplay, self.ParentingAnchor;
end

--- Script handler for the OnEvent event of the widget.
function Workspace:OnEvent(event)
	-- Do nothing if not editing.
	if(not PowerAuras:GetEditMode()) then
		return;
	elseif(event == "PLAYER_REGEN_DISABLED") then
		-- Hide upon entering combat.
		self:Hide();
		PowerAuras:PrintInfo(L["InfoHidingFromCombat"]);
	end
end

--- Script handler for the OnHide event of the widget.
function Workspace:OnHide()
	-- Remove edit mode.
	PowerAuras:SetEditMode(false);
	PowerAuras:SetCurrentAura(nil);
	PowerAuras:SetCurrentLayout(nil);
	-- Recycle previews.
	self:SetParentingDisplay(false);
	self:DestroyPreviews();
end

--- Callback handler for OnOptionsEvent.
-- @param event The fired event.
-- @param ...   The event arguments.
function Workspace:OnOptionsEvent(event, ...)
	-- Handle events.
	if(event == "AURAS_DELETED") then
		-- Recreate later.
		self:DestroyPreviews();
		self.CreatePending = true;
	elseif(event == "COROUTINE_QUEUE_END" and self.CreatePending) then
		self:CreatePreviews();
	elseif(event == "DISPLAY_DELETED") then
		-- Recreate later.
		self:DestroyPreviews();
		self.CreatePending = true;
	elseif(event == "DISPLAY_CREATED") then
		-- Show the display.
		local id = ...;
		local frame = self.Displays[id];
		if(frame) then
			-- Get the layout too.
			local vars = PowerAuras:GetAuraDisplay(id);
			local layout = self.Layouts[vars["Layout"]["ID"]];
			if(layout) then
				layout:AttachDisplay(id);
			end
		end
	elseif(event == "PROFILE_LOADED") then
		self:DestroyPreviews();
		self:CreatePreviews();
	elseif(event == "SELECTED_DISPLAY_CHANGED") then
		-- Update checked state on displays.
		for id, display in pairs(self.Displays) do
			display:SetChecked(id == (...));
			display:UpdateBackdrop();
		end
	elseif(event == "SELECTED_AURA_CHANGED") then
		self:DestroyPreviews();
		self:CreatePreviews();
	elseif(event == "WS_PARENTING_UPDATE") then
		-- Run over displays.
		local mode, source = ...;
		for id, display in pairs(self.Displays) do
			-- Show/hide all the points based upon the mode.
			for i = 1, #(display.Points) do
				display.Points[i]:SetShown(
					(mode == 1 and source == id
						or mode == 2 and source ~= id --[[ and PowerAuras:IsValidDisplayParent(source, id)]])
				);
				display.Points[i]:SetFrameStrata("DIALOG");
			end
			-- Same for mouse interactivity.
			display:SetEnabled(mode == 0);
			display:UpdateBackdrop();
		end
	end
end

--- Script handler for the OnShow event of the widget.
function Workspace:OnShow()
	-- Enable edit mode.
	PowerAuras:SetEditMode(true);
	PowerAuras:SetCurrentAura(nil);
	PowerAuras:SetCurrentLayout(nil);
	-- Show all previews.
	self:CreatePreviews();
	self:SetParentingDisplay(false);
end

--- Sets the source display used for parenting.
-- @param state  The state to set.
-- @param source The display ID that set this state.
-- @param point  Optional anchor point parameter.
function Workspace:SetParentingDisplay(state, source, point)
	-- Change based upon state.
	if(not state) then
		-- Reset display.
		self.ParentingDisplay = false;
		self.ParentingAnchor = nil;
		-- Fire callbacks.
		PowerAuras.OnOptionsEvent("WS_PARENTING_UPDATE", 0);
	elseif(not self.ParentingDisplay or not self.ParentingAnchor) then
		-- Set the current display.
		self.ParentingDisplay = source;
		self.ParentingAnchor = point;
		-- Fire callbacks.
		PowerAuras.OnOptionsEvent("WS_PARENTING_UPDATE",
			point and 2 or 1, source);
	elseif(self.ParentingDisplay and self.ParentingAnchor) then
		-- Source ID and anchor point.
		local sourceID = self.ParentingDisplay;
		local anchor = self.ParentingAnchor;
		local rel = point;
		-- Get the layout used by the source.
		local vars = PowerAuras:GetAuraDisplay(sourceID);
		local layout = PowerAuras:GetLayout(vars["Layout"]["ID"]);
		local class = PowerAuras:GetLayoutClass(layout["Type"]);
		-- Update the anchor.
		local p1, p2, p3, p4, p5 = class:GetDisplayAnchor(sourceID);
		class:SetDisplayAnchor(
			sourceID,
			anchor or p1,
			source or p2,
			rel or p3,
			p4,
			p5
		);
		-- Reset.
		self.ParentingDisplay = false;
		self.ParentingAnchor = nil;
		PowerAuras.OnOptionsEvent("WS_PARENTING_UPDATE", 0);
	end
end

--- Toggles the state of the Workspace display.
function Workspace:Toggle()
	-- Bail if we're supposed to show and we're in combat.
	if(not self:IsShown() and UnitAffectingCombat("player")) then
		-- Forcibly hide the frame.
		self:Hide();
		PowerAuras:PrintInfo(L["InfoHideInCombat"]);
	elseif(not self:IsShown()) then
		self:Show();
	else
		self:Hide();
	end
end

--- Browser window. This is a child of the Workspace.
local Browser = PowerAuras:RegisterWidget("Browser", "Window", {
	-- Browser categories.
	Categories = { "Auras", --[["Layouts",]] "Profiles", "Options", --[["Help"]] },
	-- Icons for each category.
	CategoryIcons = {
		[[Interface\AddOns\PowerAuras\Textures\Aura13]],
		--[=[[[Interface\Cursor\UI-Cursor-Move]],]=]
		[[Interface\FriendsFrame\UI-Toast-ChatInviteIcon]],
		[[Interface\HelpFrame\HelpIcon-CharacterStuck]],
		--[=[[[Interface\HelpFrame\HelpIcon-KnowledgeBase]]]=]
	},
	-- Buttons to display on categories.
	CategoryButtons = {
		["Auras"] = function(self)
			-- Create Aura button.
			local count = PowerAuras:GetAuraCount();
			-- Create the button.
			local button = PowerAuras:Create("IconButton", self);
			button:SetUserTooltip("Browser_NewAura");
			button:SetPoint("TOPRIGHT", -4, -4);
			button:SetSize(24, 24);
			button:SetIcon([[Interface\PaperDollInfoFrame\Character-Plus]]);
			button:SetEnabled(count < PowerAuras.MAX_AURAS_PER_PROFILE);
			-- Callback.
			button.OnClicked:Connect(function()
				-- Create aura.
				local id = PowerAuras:CreateAura();
				PowerAuras:SetCurrentAura(id);
				-- Scroll the list down to it.
				self:GetParent().Main:SetScrollOffset(2^31 - 1);
			end);
			-- In addition, listen to aura creation/deletion events.
			PowerAuras.OnOptionsEvent:Connect(function(e)
				-- Only care about aura events.
				if(e ~= "AURAS_CREATED" and e ~= "AURAS_DELETED") then
					return;
				end
				-- Disable button if we've got too many auras.
				local count = PowerAuras:GetAuraCount();
				button:SetEnabled(count < PowerAuras.MAX_AURAS_PER_PROFILE);
			end);
			-- Return the button.
			return button;
		end,
		["Profiles"] = function(self)
			-- Create the button.
			local button = PowerAuras:Create("IconButton", self);
			button:SetUserTooltip("Browser_NewProfile");
			button:SetPoint("TOPRIGHT", -4, -4);
			button:SetSize(24, 24);
			button:SetIcon([[Interface\PaperDollInfoFrame\Character-Plus]]);
			-- Callback.
			button.OnClicked:Connect(function()
				StaticPopup_Show("POWERAURAS_CREATE_PROFILE");
			end);
			-- Return the button.
			return button;
		end,
	},
});

--- Creates a new instance of the widget and returns the frame.
function Browser:New(parent)
	-- Set up the main frame.
	local frame = base(self, parent, "PowerAurasGUIBrowser");
	frame:SetParent(parent);
	frame:SetPoint("LEFT", 4, 0);
	frame:SetSize(220, 496);
	frame:SetClampRectInsets(180, -180, -487, 487);
	frame:SetClampedToScreen(true);
	-- Main content frame.
	frame.Main = PowerAuras:Create("ScrollFrame", frame);
	frame.Main:SetBackdrop(nil);
	frame.Main.Widgets = {};
	-- Options/Help panes use a layout host for simplicity.
	-- Parent to the frame (not the content pane) on purpose.
	frame.Main.Host = PowerAuras:Create("LayoutHost", frame);
	frame.Main.Host:SetBackdrop(nil);
	frame.Main.Host:SetContentPadding(4, 4, 4, 4);
	frame.Main.Host:SetAllPoints(frame.Main);
	frame.Main.Host:Hide();
	-- Replace the PerformLayout function on the content frame with
	-- our own.
	local hook = frame.Main.PerformLayout;
	function frame.Main:PerformLayout()
		if(hook(frame.Main)) then
			frame:UpdateContent(frame.Main);
		end
	end;
	-- Top/bottom shadows for the visible area.
	frame.ST = frame.Main:CreateTexture(nil, "BACKGROUND");
	frame.ST:SetDrawLayer("BACKGROUND", 1);
	frame.ST:SetTexture([[Interface\Common\bluemenu-goldborder-horiz]], true);
	frame.ST:SetTexCoord(0.0, 1.0, 0.015625, 0.34375000);
	frame.ST:SetHorizTile(true);
	frame.ST:SetHeight(43);
	frame.ST:SetPoint("TOPLEFT", 0, 0);
	frame.ST:SetPoint("TOPRIGHT", 0, 0);
	frame.SB = frame.Main:CreateTexture(nil, "BACKGROUND");
	frame.SB:SetDrawLayer("BACKGROUND", 1);
	frame.SB:SetTexture([[Interface\Common\bluemenu-goldborder-horiz]], true);
	frame.SB:SetTexCoord(0.0, 1.0, 0.35937500, 0.6875);
	frame.SB:SetHorizTile(true);
	frame.SB:SetHeight(43);
	frame.SB:SetPoint("BOTTOMLEFT", 0, 0);
	frame.SB:SetPoint("BOTTOMRIGHT", 0, 0);
	-- Add categories.
	for i = 1, #(self.Categories) do
		-- Category button.
		local cat = CreateFrame("CheckButton", nil, frame);
		cat:SetPoint("TOPLEFT", 2, -(22 + ((i - 1) * 32)));
		cat:SetPoint("TOPRIGHT", -4, -(22 + ((i - 1) * 32)));
		cat:SetHeight(32);
		-- Background.
		cat.Bg = cat:CreateTexture(nil, "BACKGROUND");
		cat.Bg:SetAllPoints(true);
		cat.Bg:SetTexture([[Interface\FrameGeneral\UI-Background-Marble]], true);
		cat.Bg:SetHorizTile(true);
		cat.Bg:SetVertTile(true);
		-- Borders.
		cat.Border = cat:CreateTexture(nil, "BORDER");
		cat.Border:SetTexture([[Interface\LevelUp\LevelUpTex]]);
		cat.Border:SetTexCoord(0.00195313, 0.81835938, 0.00195313, 0.01562500);
		cat.Border:SetHeight(7);
		-- Icon.
		cat.Icon = cat:CreateTexture(nil, "ARTWORK");
		cat.Icon:SetSize(24, 24);
		cat.Icon:SetPoint("TOPLEFT", 4, -4);
		cat.Icon:SetTexture(self.CategoryIcons[i]);
		-- Text.
		cat.Text = cat:CreateFontString(nil, "OVERLAY");
		cat.Text:SetFontObject(GameFontNormal);
		cat.Text:SetPoint("TOPLEFT", 36, -4);
		cat.Text:SetPoint("BOTTOMRIGHT", -4, 4);
		cat.Text:SetJustifyV("MIDDLE");
		cat.Text:SetJustifyH("LEFT");
		cat.Text:SetText(L[self.Categories[i]]);
		cat:SetFontString(cat.Text);
		cat:SetNormalFontObject(GameFontHighlight);
		cat:SetHighlightFontObject(GameFontNormal);
		cat:SetDisabledFontObject(GameFontNormal);
		-- Button.
		local func = self.CategoryButtons[self.Categories[i]];
		if(func) then
			cat.Button = func(cat);
			if(cat.Button) then
				cat.Button:SetShown(false);
			end
		end
		-- Script handlers.
		cat:SetScript("OnClick", function()
			PlaySound("UChatScrollButton");
			frame:SetActiveCategory(i);
		end);
		-- Add category to frame.
		self[self.Categories[i] .. "Category"] = cat;
	end
	return frame;
end

--- Called when the browser frame has been constructed. Initialises the
--  callback handlers.
function Browser:Initialise()
	-- Set window title and category.
	self:SetTitle(L["Browser"]);
	self:SetActiveCategory(1);
	-- Connect callbacks.
	self:ConnectCallback(PowerAuras.OnOptionsEvent, self.OnOptionsEvent);
end

--- Called when a content pane item is clicked.
-- @param id     The ID of the item.
-- @param button The clicked button.
-- @remarks self points to the item, not the browser.
function Browser:OnContentItemClicked(id, button)
	-- Close dropdowns.
	PowerAuras:GetWidget("Dropdown"):CloseAllMenus();
	-- Determine item type.
	local browser = PowerAuras.Browser;
	local _, id, _, _, _, category = PowerAuras:SplitNodeID(id);
	category = browser.Categories[category];
	if(category == "Auras") then
		-- Aura.
		if(PowerAuras:GetCurrentAura() == id) then
			PowerAuras:SetCurrentAura(nil);
		else
			PowerAuras:SetCurrentAura(id);
		end
	elseif(category == "Layouts") then
		-- Layout.
		if(PowerAuras:GetCurrentLayout() == id) then
			PowerAuras:SetCurrentLayout(nil);
		else
			PowerAuras:SetCurrentLayout(id);
		end
	elseif(category == "Profiles") then
		-- Profile.
		if(button == "LeftButton") then
			if(PowerAuras:GetCurrentProfileID() ~= self:GetText()) then
				PowerAuras:LoadProfile(self:GetText());
			end
		elseif(button == "RightButton") then
			-- Context menu.
			local dd = PowerAuras:Create("Dropdown", self, 1);
			dd:SetParent(self);
			dd:SetAnchor(self, "TOPLEFT", "TOPRIGHT", 0, 0);
			dd:SetWidth(200);
			dd:Show();
			-- Callbacks.
			dd.OnMenuRefreshed:Connect(function(menu)
				menu:AddItem(1, "", L["DeleteProfile"]);
				menu:AddItem(2, "", L["RenameProfile"]);

				menu.OnValueUpdated:Connect(function(menu, key)
					menu:CloseAllMenus();
					if(key == 1) then
						local d = StaticPopup_Show(
							"POWERAURAS_DELETE_PROFILE", self:GetText()
						);
						d.data = self:GetText();
					elseif(key == 2) then
						local d = StaticPopup_Show(
							"POWERAURAS_RENAME_PROFILE"
						);
						d.data = self:GetText();
					end
				end);
			end);
			dd:RefreshMenu();
		end
	end
end

--- Script handler for when the browser is hidden. Closes the workspace.
function Browser:OnHide()
	PowerAuras.Workspace:Hide();
	self:Show();
end

--- Callback handler for OnOptionsEvent. Processes profile events and
--  updates the contents of our dropdown as needed.
function Browser:OnOptionsEvent(event, ...)
	-- Check if profile dropdown needs updating.
	if(event == "OPTIONS_LOADED" or event:sub(1, 7) == "PROFILE") then
		self:RefreshContent();
	elseif(event:sub(1, 5) == "AURAS") then
		self:RefreshContent(1);
	elseif(event:sub(1, 6) == "LAYOUT") then
		self:RefreshContent(2);
	elseif(event:sub(1, 8) == "SELECTED") then
		self:RefreshContent();
	end
end

--- Refreshes the content pane.
-- @param current If not nil, the refresh will only be performed if this
--                parameter is the index of the active category.
function Browser:RefreshContent(current)
	-- Skip if not current.
	if(current and current ~= self.ActiveCategory) then
		return;
	end
	-- Get visible range and the scrollrange of our shown content.
	local pane = self.Main;
	local v = math.floor((pane:GetHeight() - 10) / 38);
	local cat = self.ActiveCategory;
	local catToken = self.Categories[self.ActiveCategory];
	if(catToken == "Auras") then
		pane:SetScrollRange(0, math.max(0, PowerAuras:GetAuraCount() - v));
	elseif(catToken == "Layouts") then
		pane:SetScrollRange(0, math.max(0, PowerAuras:GetLayoutCount() - v));
	elseif(catToken == "Profiles") then
		pane:SetScrollRange(0, math.max(0, PowerAuras:GetProfileCount() - v));
	elseif(catToken == "Options" or catToken == "Help") then
		-- These use the layout host.
		pane.Host:Show();
		pane:SetScrollRange(0, 0);
	end
	-- Force an update.
	pane:PerformLayout();
end

--- Sets the active browser category.
-- @param cat The category to activate. Either a string token or
--            numeric index. If it is not found, it will instead activate
--            the first one.
function Browser:SetActiveCategory(cat)
	-- Find the category.
	if(not self.Categories[cat]) then
		for i = 1, #(self.Categories) do
			if(self.Categories[i] == cat) then
				cat = i;
				break;
			end
		end
		-- Did we find it?
		if(not self.Categories[cat]) then
			cat = 1;
		end
	end
	-- Set category.
	self.ActiveCategory = cat;
	-- Reset content frame position.
	self.Main:SetPoint("TOPLEFT", 2, -22);
	self.Main:SetPoint("BOTTOMRIGHT", -3, 2);
	-- Reposition category buttons.
	local offset = 0;
	for i = 1, #(self.Categories) do
		-- Position frame.
		local frame = self[self.Categories[i] .. "Category"];
		frame:SetPoint("TOPLEFT", 2, -(22 + offset + ((i - 1) * 32)));
		frame:SetPoint("TOPRIGHT", -4, -(22 + offset + ((i - 1) * 32)));
		-- Update border positions.
		frame.Border:ClearAllPoints();
		if(i <= cat) then
			frame.Border:SetPoint("BOTTOMLEFT", 0, 0);
			frame.Border:SetPoint("BOTTOMRIGHT", 0, 0);
		else
			frame.Border:SetPoint("TOPLEFT", 0, 6);
			frame.Border:SetPoint("TOPRIGHT", 0, 6);
		end
		-- Is this the current category?
		frame:SetChecked(i == cat);
		frame:SetEnabled(i ~= cat);
		if(i == cat) then
			-- Checked.
			frame.Border:SetVertexColor(1.0, 0.8, 0.0);
			if(frame.Button) then
				frame.Button:SetShown(true);
			end
			offset = self:GetHeight() - 25 - (32 * #(self.Categories));
			-- Position the top of the content frame to the bottom of
			-- this element.
			self.Main:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, 0);
		else
			-- Normal.
			frame.Border:SetVertexColor(0.3, 0.3, 0.3);
			if(frame.Button) then
				frame.Button:SetShown(false);
			end
			-- Was this the one after the checked one? If so, attach the
			-- bottom of the content pane to it.
			if(i == cat + 1) then
				self.Main:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 0, 0);
			end
		end
	end
	-- Refresh the content frame.
	self:RefreshContent();
end

--- Updates the content pane. Called when PerformLayout is called.
-- @param pane The content pane.
function Browser:UpdateContent(pane)
	-- Pause further layouts.
	pane:PauseLayout();
	-- Remove all widgets from the pane.
	for i = #(pane.Widgets), 1, -1 do
		tremove(pane.Widgets):Recycle();
	end
	-- Reset the layouthost pane too.
	pane.Host:ClearWidgets();
	pane.Host:Hide();
	-- Add new ones based upon the type.
	local cat = self.ActiveCategory;
	local catToken = self.Categories[self.ActiveCategory];
	local offset = pane:GetScrollOffset();
	if(catToken == "Auras" or catToken == "Layouts") then
		-- Auras/layouts.
		local i, s = 0, 0;
		local sw = (pane.ScrollBar:IsShown() and 22 or 0);
		-- Functions vary based upon the category type.
		local iterFunc = (cat == 1 and "GetAllAuras" or "GetAllLayouts");
		local current = (cat == 1 and "GetCurrentAura" or "GetCurrentLayout");
		local nameKey = (cat == 1 and "AuraID" or "LayoutID");
		current = PowerAuras[current](PowerAuras);
		-- Iterate over items.
		for id, vars in PowerAuras[iterFunc](PowerAuras) do
			-- Show this one?
			if(i >= offset) then
				-- Create the item and position it.
				local item = PowerAuras:Create("BrowserItem", pane);
				item:SetPoint("TOPLEFT", 4, -(4 + (s * 38)));
				item:SetPoint("TOPRIGHT", -(4 + sw), -(4 + (s * 38)));
				-- Update text/icons.
				item:SetIcon(select(3, GetSpellInfo(vars["Icon"]))
					or PowerAuras.DefaultIcon);
				item:SetText(vars["Name"] or L(nameKey, id));
				item:SetSubText(vars["Description"] or L["NoDescription"]);
				-- Update checked state and stored ID.
				item:SetID(PowerAuras:GetNodeID(0, id, 0, 0, 0, cat));
				item:SetChecked(id == current);
				-- Connect callbacks.
				item.OnClicked:Connect(self.OnContentItemClicked);
				-- Add widget to table and increment shown counter.
				tinsert(pane.Widgets, item);
				s = s + 1;
			end
			-- Bail?
			i = i + 1;
			if(s == math.floor((pane:GetHeight() - 10) / 38)) then
				break;
			end
		end
	elseif(catToken == "Profiles") then
		-- Profiles. Similar to auras/layouts.
		local i, s = 0, 0;
		local sw = (pane.ScrollBar:IsShown() and 22 or 0);
		local current = PowerAuras:GetCurrentProfileID();
		-- Iterate over items.
		for id, _ in PowerAuras:ByKey(PowerAuras:GetAllProfiles()) do
			-- Show this one?
			if(i >= offset) then
				-- Create the item and position it.
				local item = PowerAuras:Create("BrowserItem", pane);
				item:SetPoint("TOPLEFT", 4, -(4 + (s * 38)));
				item:SetPoint("TOPRIGHT", -(4 + sw), -(4 + (s * 38)));
				-- Update text/icons.
				item:SetIcon(nil);
				item:SetText(id);
				item:SetSubText(L[id == current and "Active" or "Inactive"]);
				-- Update checked state and stored ID.
				item:SetID(PowerAuras:GetNodeID(0, 0, 0, 0, 0, cat));
				item:SetChecked(id == current);
				-- Connect callbacks.
				item.OnClicked:Connect(self.OnContentItemClicked);
				-- Add widget to table and increment shown counter.
				tinsert(pane.Widgets, item);
				s = s + 1;
			end
			-- Bail?
			i = i + 1;
			if(s == math.floor((pane:GetHeight() - 10) / 38)) then
				break;
			end
		end
	elseif(catToken == "Options") then
		-- Hardcoded list of option widgets. Add more as you see fit.
		pane.Host:PauseLayout();
		-- Create widgets.
		-- Performance options.
		local h1 = PowerAuras:Create("Header", pane.Host);
		h1:SetText(L["Performance"]);

		local actions = PowerAuras:Create("P_NumberBox", pane.Host);
		actions:SetUserTooltip("GActionUpdate");
		actions:SetPadding(4, 0, 4, 0);
		actions:SetRelativeWidth(1.0);
		actions:SetMinMaxValues(1, PowerAuras.MAX_ACTIONS_PER_PROFILE);
		actions:SetValueStep(1);
		actions:SetTitle(L["ActionsPerFrame"]);
		actions:LinkParameter("Global", "ActionsPerFrame", 0);

		local providers = PowerAuras:Create("P_NumberBox", pane.Host);
		providers:SetUserTooltip("GSourceUpdate");
		providers:SetPadding(4, 0, 4, 0);
		providers:SetRelativeWidth(1.0);
		providers:SetMinMaxValues(1, PowerAuras.MAX_PROVIDERS_PER_PROFILE);
		providers:SetValueStep(1);
		providers:SetTitle(L["ProvidersPerFrame"]);
		providers:LinkParameter("Global", "ProvidersPerFrame", 0);

		local update = PowerAuras:Create("P_NumberBox", pane.Host);
		update:SetUserTooltip("GUpdate");
		update:SetPadding(4, 0, 4, 0);
		update:SetRelativeWidth(1.0);
		update:SetMinMaxValues(0, 120);
		update:SetValueStep(1);
		update:SetTitle(L["OnUpdateThrottle"]);
		update:LinkParameter("Global", "OnUpdateThrottle", 0);

		-- Add widgets.
		pane.Host:AddWidget(h1);
		pane.Host:AddWidget(actions);
		pane.Host:AddWidget(providers);
		pane.Host:AddWidget(update);
		-- Resume layout.
		pane.Host:ResumeLayout();
		pane.Host:Show();
	elseif(catToken == "Help") then
		-- Hardcoded list of help widgets. Add more as you see fit.
	end
	-- Resume layout on the pane.
	pane.LayoutPaused = (pane.LayoutPaused or 1) - 1;
end

--- Generic item widget for the browser. Used to display auras/layouts.
local BrowserItem = PowerAuras:RegisterWidget("BrowserItem", "ReusableWidget");

--- Constructs/recycles an instance of the widget.
function BrowserItem:New()
	-- Recycle if possible.
	local frame = base(self);
	if(not frame) then
		-- Create.
		frame = CreateFrame("CheckButton", nil, UIParent);
		frame:SetHeight(36);
		frame:SetPushedTextOffset(0, 0);
		frame:RegisterForClicks("AnyUp");
		-- Add text labels.
		frame.Text = frame:CreateFontString(nil, "OVERLAY");
		frame.Text:SetPoint("TOPRIGHT", -4, -2);
		frame.Text:SetFontObject(GameFontNormal);
		frame.Text:SetJustifyH("LEFT");
		frame.Text:SetJustifyV("TOP");
		frame.Text:SetHeight(16);
		frame:SetFontString(frame.Text);
		-- Subtext.
		frame.Subtext = frame:CreateFontString(nil, "OVERLAY");
		frame.Subtext:SetPoint("TOPLEFT", frame.Text, "BOTTOMLEFT", 0, 0);
		frame.Subtext:SetPoint("BOTTOMRIGHT", -4, 2);
		frame.Subtext:SetFontObject(GameFontDisable);
		frame.Subtext:SetJustifyH("LEFT");
		frame.Subtext:SetJustifyV("TOP");
		frame.Subtext:SetHeight(16);
		-- Icon.
		frame.Icon = frame:CreateTexture(nil, "ARTWORK");
		frame.Icon:SetPoint("TOPLEFT", 2, -2);
		frame.Icon:SetSize(32, 32);
		frame.Icon:Hide();
		-- Glow textures.
		frame.GlowT = frame:CreateTexture(nil, "BACKGROUND");
		frame.GlowT:SetTexture([[Interface\LevelUp\LevelUpTex]]);
		frame.GlowT:SetTexCoord(0.00195313, 0.63867188, 0.03710938, 0.23828125);
		frame.GlowT:SetPoint("TOPLEFT", 0, 0);
		frame.GlowT:SetPoint("BOTTOMRIGHT", 0, 0);
		frame.GlowT:SetHeight(7);
		frame.GlowB = frame:CreateTexture(nil, "BORDER");
		frame.GlowB:SetTexture([[Interface\LevelUp\LevelUpTex]]);
		frame.GlowB:SetTexCoord(0.00195313, 0.81835938, 0.00195313, 0.015625);
		frame.GlowB:SetVertexColor(0.3, 0.3, 0.3);
		frame.GlowB:SetPoint("BOTTOMLEFT", 0, 0);
		frame.GlowB:SetPoint("BOTTOMRIGHT", 0, 0);
		frame.GlowB:SetHeight(7);
		-- Callbacks.
		frame.OnClicked = PowerAuras.Callback();
	end
	return frame;
end

--- Initialises an instance of the widget.
-- @param parent The parent of the item.
function BrowserItem:Initialise(parent)
	-- Update frame parent and icon/text.
	self:SetParent(parent);
	self:SetText("");
	self:SetSubText("");
	self:SetIcon(nil);
	-- Update glows.
	self.GlowT:SetShown(self:GetChecked() or self:IsMouseOver());
	self.GlowB:SetShown(self:GetChecked() or self:IsMouseOver());
end

--- OnClick script handler for the item.
function BrowserItem:OnClick(button)
	PlaySound("UChatScrollButton");
	self:SetChecked(not self:GetChecked());
	self:OnClicked(self:GetID(), button);
end

--- OnEnter script handler.
function BrowserItem:OnEnter()
	base(self);
	self.GlowT:SetShown(true);
	self.GlowB:SetShown(true);
end

--- OnLeave script handler.
function BrowserItem:OnLeave()
	self.GlowT:SetShown(self:GetChecked());
	self.GlowB:SetShown(self:GetChecked());
end

--- Recycles an instance of the widget.
function BrowserItem:Recycle()
	-- Clear callback, recycle as normal.
	self.OnClicked:Reset();
	self:SetText("");
	self:SetSubText("");
	self:SetIcon(nil);
	self:SetChecked(false);
	base(self);
end

--- Sets the checked state of the item.
function BrowserItem:SetChecked(state)
	-- Update state.
	self:__SetChecked(state);
	-- Update textures.
	self.GlowT:SetShown(state or self:IsMouseOver());
	self.GlowB:SetShown(state or self:IsMouseOver());
end

--- Sets the icon on the item.
-- @param texture The texture to display.
function BrowserItem:SetIcon(texture)
	-- Update the texture.
	self.Icon:SetTexture(texture);
	if(not texture or texture == "") then
		-- Reposition text and hide the icon.
		self.Text:SetPoint("TOPLEFT", 4, -2);
		self.Icon:Hide();
	else
		self.Text:SetPoint("TOPLEFT", 38, -2);
		self.Icon:Show();
	end
end

--- Sets the subtext on an item.
-- @param text The text to display.
function BrowserItem:SetSubText(text)
	self.Subtext:SetText(text);
end

--- Changelog window, shown once a profile is upgraded/on first run.
--  Displays $IMPORTANT_INFORMATION.
local Changelog = PowerAuras:RegisterWidget("Changelog", "Window");

--- Initialises a new instance of the editor frame.
function Changelog:Initialise()
	-- Set up the main frame.
	base(self, UIParent);
	self:SetParent(UIParent);
	self:SetPoint("CENTER", 0, 0);
	self:SetSize(640, 400);
	self:SetClampRectInsets(600, -600, -440, 440);
	self:SetClampedToScreen(true);
	self:SetFrameStrata("DIALOG");
	self:SetClosable(false);
	self:SetMovable(false);
	-- Add pretty textures.
	self.Bg = self:CreateTexture(nil, "BACKGROUND");
	self.Bg:SetTexture([[Interface\Common\bluemenu-main]]);
	self.Bg:SetTexCoord(0.00390625, 0.82421875, 0.18554688, 0.58984375);
	self.Bg:SetPoint("TOPLEFT", 2, -22);
	self.Bg:SetPoint("BOTTOMRIGHT", -3, 2);
	-- Corner textures.
	self.TLCorner = self:CreateTexture(nil, "BORDER");
	self.TLCorner:SetTexture([[Interface\TalentFrame\talent-main]]);
	self.TLCorner:SetTexCoord(0.00390625, 0.25390625, 0.70117188, 0.80859375);
	self.TLCorner:SetPoint("TOPLEFT", 2, -22);
	self.TLCorner:SetSize(64, 55);
	self.TRCorner = self:CreateTexture(nil, "BORDER");
	self.TRCorner:SetTexture([[Interface\TalentFrame\talent-main]]);
	self.TRCorner:SetTexCoord(0.00390625, 0.25390625, 0.58984375, 0.69726563);
	self.TRCorner:SetPoint("TOPRIGHT", -3, -22);
	self.TRCorner:SetSize(64, 55);
	self.BLCorner = self:CreateTexture(nil, "BORDER");
	self.BLCorner:SetTexture([[Interface\TalentFrame\talent-main]]);
	self.BLCorner:SetTexCoord(0.27734375, 0.52734375, 0.47656250, 0.58398438);
	self.BLCorner:SetPoint("BOTTOMLEFT", 2, 2);
	self.BLCorner:SetSize(64, 55);
	self.BRCorner = self:CreateTexture(nil, "BORDER");
	self.BRCorner:SetTexture([[Interface\TalentFrame\talent-main]]);
	self.BRCorner:SetTexCoord(0.53515625, 0.78515625, 0.47656250, 0.58398438);
	self.BRCorner:SetPoint("BOTTOMRIGHT", -3, 2);
	self.BRCorner:SetSize(64, 55);
	-- Tiling textures.
	self.TEdge = self:CreateTexture(nil, "BORDER");
	self.TEdge:SetTexture([[Interface\TalentFrame\talent-horiz]], true);
	self.TEdge:SetHorizTile(true);
	self.TEdge:SetTexCoord(0, 7.59375, 0.05468750, 0.14062500);
	self.TEdge:SetPoint("TOPLEFT", self.TLCorner, "TOPRIGHT", 0, 0);
	self.TEdge:SetPoint("TOPRIGHT", self.TRCorner, "TOPLEFT", 0, 0);
	self.TEdge:SetSize(0, 11);
	self.BEdge = self:CreateTexture(nil, "BORDER");
	self.BEdge:SetTexture([[Interface\TalentFrame\talent-horiz]], true);
	self.BEdge:SetHorizTile(true);
	self.BEdge:SetTexCoord(0, 7.59375, 0.00781250, 0.03906250);
	self.BEdge:SetPoint("BOTTOMLEFT", self.BLCorner, "BOTTOMRIGHT", 0, 0);
	self.BEdge:SetPoint("BOTTOMRIGHT", self.BRCorner, "BOTTOMLEFT", 0, 0);
	self.BEdge:SetSize(0, 4);
	-- Add title text.
	self.Title:SetText(
		("Power Auras %s"):format(
			GetAddOnMetadata("PowerAuras", "Version"):sub(1, 3)
		)
	);
	-- Release notes frame.
	self.Notes = PowerAuras:Create("LayoutHost", self);
	self.Notes:SetPoint("TOPLEFT", 32, -67);
	self.Notes:SetPoint("BOTTOMRIGHT", -32, 76);
	self.Notes:SetBackdropColor(0, 0, 0, 0);
	self.Notes:SetBackdropBorderColor(1.0, 0.8, 0.0, 1);
	self.Notes:SetContentPadding(8, 8, 8, 8);
	self.Notes:Hide();
	-- Populate notes with items.
	self.Notes:PauseLayout();
	-- Add header item.
	local header = PowerAuras:Create("Label", self.Notes);
	header:SetMargins(4, 0, 0, 8);
	header:SetFontObject(GameFontNormalLarge);
	header:SetJustifyH("LEFT");
	header:SetJustifyV("MIDDLE");
	header:SetText(L["ChangelogReleaseNotesTitle"]);
	header:SetRelativeWidth(1.0);
	header:SetFixedHeight(30);
	self.Notes:AddWidget(header);
	-- Autopopulate the release notes from the localization files.
	local key, i = "ChangelogReleaseNotes1", 1;
	while(rawget(L, key)) do
		-- Bulletpoint-esque texture.
		local tex = PowerAuras:Create("Texture", self.Notes);
		tex:SetTexture([[Interface\Buttons\UI-RADIOBUTTON]]);
		tex:SetTexCoord(0.25, 0.5, 0.0, 1.0);
		tex:SetMargins(4, 0, 8, 4);
		tex:SetFixedSize(16, 16);
		-- Label.
		local label = PowerAuras:Create("Label", self.Notes);
		label:SetFontObject(GameFontHighlight);
		label:SetJustifyH("LEFT");
		label:SetJustifyV("TOP");
		label:SetText(L[key]);
		label:SetRelativeWidth(0.8);
		label:SetFixedHeight(46);
		label:SetMargins(0, 2, 0, 0);
		-- Add to frame.
		self.Notes:AddWidget(tex);
		self.Notes:AddWidget(label);
		self.Notes:AddRelativeSpacer(1.0);
		-- Next note.
		i = i + 1;
		key = "ChangelogReleaseNotes" .. i;
	end
	-- Perform a layout pass.
	self.Notes:ResumeLayout();
	-- Add help regions on the left.
	for i = 1, 3 do
		local iconKey = "LeftIcon" .. i;
		self[iconKey] = self:CreateTexture(nil, "ARTWORK");
		self[iconKey]:SetSize(64, 64);
		self[iconKey]:SetPoint("TOPLEFT", 32, -(67 + (i - 1) * 100));
		self[iconKey]:SetTexture(L["ChangelogHelpIcon" .. i]);
		local titleKey = "LeftTitle" .. i;
		self[titleKey] = self:CreateFontString(nil, "OVERLAY");
		self[titleKey]:SetFontObject(GameFontNormalLarge);
		self[titleKey]:SetJustifyH("LEFT");
		self[titleKey]:SetJustifyV("TOP");
		self[titleKey]:SetPoint("TOPLEFT", self[iconKey], "TOPRIGHT", 16, 0);
		self[titleKey]:SetSize(320, 24);
		self[titleKey]:SetText(L["ChangelogHelpTitle" .. i]);
		local textKey = "LeftText" .. i;
		self[textKey] = self:CreateFontString(nil, "OVERLAY");
		self[textKey]:SetFontObject(GameFontHighlightSmall);
		self[textKey]:SetJustifyH("LEFT");
		self[textKey]:SetJustifyV("TOP");
		self[textKey]:SetPoint("TOPLEFT", self[iconKey], "TOPRIGHT", 16, -24);
		self[textKey]:SetPoint("RIGHT", self, "RIGHT", -64, 0);
		self[textKey]:SetSize(320, 48);
		self[textKey]:SetText(L["ChangelogHelpText" .. i]);
	end
	-- Add nav buttons.
	for _, key in ipairs({ "Next", "Prev" }) do
		self[key] = CreateFrame("Button", nil, self);
		self[key]:SetSize(168, 60);
		self[key]:SetPoint("BOTTOMLEFT", self, "BOTTOM", 32, 16);
		self[key].Bg = self[key]:CreateTexture(nil, "BACKGROUND");
		self[key].Bg:SetTexture([[Interface\Common\bluemenu-main]]);
		self[key].Bg:SetTexCoord(0.00390625, 0.87890625, 0.75195313,
			0.83007813);
		self[key].Bg:SetAllPoints(true);
		self[key]:SetScript("OnEnter", function()
			self[key].Bg:SetTexCoord(0.00390625, 0.87890625, 0.59179688,
				0.66992188);
		end);
		self[key]:SetScript("OnLeave", function()
			self[key].Bg:SetTexCoord(0.00390625, 0.87890625, 0.75195313,
				0.83007813);
		end);
		self[key].Text = self[key]:CreateFontString(nil, "OVERLAY");
		self[key].Text:SetFontObject(GameFontNormalLarge);
		self[key].Text:SetAllPoints(true);
		self[key].Text:SetJustifyH("CENTER");
		self[key].Text:SetJustifyV("MIDDLE");
		self[key].Text:SetText(key == "Next" and NEXT or BACK);
		self[key]:SetFontString(self[key].Text);
	end
	-- Connect scripts to buttons.
	self.Next:SetScript("OnClick", function()
		-- Update button visiblity/text.
		PlaySound("UChatScrollButton");
		-- Are we done?
		if(self.Prev:IsShown()) then
			return self:Hide();
		end
		self.Next:SetText(DONE);
		self.Prev:Show();
		-- Hide some icons and labels.
		self.LeftIcon1:Hide();
		self.LeftTitle1:Hide();
		self.LeftText1:Hide();
		self.LeftIcon2:Hide();
		self.LeftTitle2:Hide();
		self.LeftText2:Hide();
		self.LeftIcon3:Hide();
		self.LeftTitle3:Hide();
		self.LeftText3:Hide();
		self.Notes:Show();
		self.Notes:PerformLayout();
	end);
	self.Prev:SetScript("OnClick", function()
		-- Update button visiblity/text.
		PlaySound("UChatScrollButton");
		self.Next:SetText(NEXT);
		self.Prev:Hide();
		-- Show some icons and labels.
		self.LeftIcon1:Show();
		self.LeftTitle1:Show();
		self.LeftText1:Show();
		self.LeftIcon2:Show();
		self.LeftTitle2:Show();
		self.LeftText2:Show();
		self.LeftIcon3:Show();
		self.LeftTitle3:Show();
		self.LeftText3:Show();
		self.Notes:Hide();
	end);
	-- Hide previous button.
	self.Prev:ClearAllPoints();
	self.Prev:SetPoint("BOTTOMRIGHT", self, "BOTTOM", -32, 16);
	self.Prev:Hide();
end

--- OnHide script handler.
function Changelog:OnHide()
	PlaySound("igMainMenuClose");
	self.Notes:ClearWidgets();
	-- And spawn in the workspace.
	PowerAuras["Workspace"] = PowerAuras:Create("Workspace");
	PowerAuras["Workspace"]:Toggle();
end

--- OnShow script handler.
function Changelog:OnShow()
	PlaySound("igCharacterInfoTab");
end