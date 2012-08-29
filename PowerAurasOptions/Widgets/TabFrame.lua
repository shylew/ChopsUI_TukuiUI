-- Lock down local environment.
local PowerAuras = _G["PowerAuras"];
setfenv(1, PowerAuras);

--- Tab frame widget, extends the BorderedFrame to provide tab support.
local TabFrame = PowerAuras:RegisterWidget("TabFrame", "BorderedFrame");

--- Constructs a new instance of the class and returns the frame.
-- @param parent The parent frame.
function TabFrame:New(parent)
	-- Create the frame, add some tables.
	local frame = base(self, parent);
	frame.OnCurrentTabChanged = PowerAuras.Callback();
	frame.Tabs = {};
	frame.CurrentTab = 0;
	frame.LayoutType = "TOP";
	return frame;
end

--- Adds a new tab to the frame.
-- @param frame The frame to link to the tab.
-- @param text  The text to set on the tab.
-- @param icon  The icon to set on the tab.
-- @param ...   Icon sizing/positioning data.
function TabFrame:AddTab(frame, text, icon, ...)
	-- Create and insert.
	tinsert(
		self.Tabs, 
		PowerAuras:Create("TabButton", self, frame, text, icon, ...)
	);
	if(self.CurrentTab == 0) then
		self:SetCurrentTab(#(self.Tabs));
	end
	self:PerformLayout();
end

--- Removes all tabs from the frame.
function TabFrame:ClearTabs()
	-- Remove all tabs,
	for i = #(self.Tabs), 1, -1 do
		self:RemoveTab(i);
	end
end

--- Edits an existing tab, updating the text and icon.
-- @param tab  The tab index or frame to find.
-- @param text The text to set on the tab.
-- @param icon The icon to set on the tab.
-- @param ...  Icon sizing/positioning data.
function TabFrame:EditTab(tab, text, icon, ...)
	-- Find the tab.
	tab = self:GetTabIndex(tab);
	if(tab) then
		-- Update the tab.
		local tbl = self.Tabs[tab];
		tbl:Edit(text, icon, ...);
		self:PerformLayout();
	end
end

--- Returns the currently selected tab index.
-- @return 0 if no tab is selected, otherwise 1 or more.
function TabFrame:GetCurrentTab()
	return self.CurrentTab;
end

--- Searches all owned tabs for a matching tab and returns the index.
-- @param tab The tab to find. Either a numeric index or the frame of a tab.
-- @return A number representing a tab index, or nil.
function TabFrame:GetTabIndex(tab)
	if(type(tab) == "number") then
		return tab;
	else
		for i = 1, #(self.Tabs) do
			if(self.Tabs[i]:GetOwnedFrame() == tab) then
				return i;
			end
		end
	end
end

--- Sets a tab as hidden, removing it from the layout.
-- @param tab The tab to select. Either a numeric index or the frame of a tab.
function TabFrame:HideTab(tab)
	tab = self:GetTabIndex(tab);
	if(tab) then
		self.Tabs[tab]:Hide();
		-- If you just hid the current tab, select another.
		if(self:GetCurrentTab() == tab) then
			self:SetCurrentTab(self:GetCurrentTab() - 1);
		end
		self:PerformLayout();
	end
end

--- Updates the layout of all visible tabs.
function TabFrame:PerformLayout()
	local lastTab = nil;
	for i = 1, #(self.Tabs) do
		local tab = self.Tabs[i];
		if(tab:IsShown()) then
			tab:Position(lastTab, (self:GetCurrentTab() == i), self.LayoutType);
			lastTab = tab;
		else
			tab:GetOwnedFrame():Hide();
		end
	end
end

--- Removes a tab from the frame.
-- @param tab The tab to remove. Either a numeric index or the frame of a tab.
function TabFrame:RemoveTab(tab)
	-- Get the real index.
	tab = self:GetTabIndex(tab);
	if(tab) then
		tremove(self.Tabs, tab):Recycle();
		if(self:GetCurrentTab() == tab) then
			self:SetCurrentTab(self:GetCurrentTab() - 1);
		end
		self:PerformLayout();
	end
end

--- Sets the current tab index.
-- @param tab The tab to select. Either a numeric index or the frame of a tab.
function TabFrame:SetCurrentTab(tab)
	-- Validate and update.
	tab = self:GetTabIndex(tab);
	self.CurrentTab = math.max(0, math.min(#(self.Tabs), tab or 0));
	self:OnCurrentTabChanged(self.CurrentTab);
	self:PerformLayout();
end

--- Sets the layout type used by the frame.
-- @param position Position of tabs on the frame. Either TOP or BOTTOM.
function TabFrame:SetLayoutType(position)
	self.LayoutType = (position == "TOP" or position == "BOTTOM" and position
		or self.LayoutType);
	self:PerformLayout();
end

--- Sets a tab as shown, adding it to the layout.
-- @param tab The tab to select. Either a numeric index or the frame of a tab.
function TabFrame:ShowTab(tab)
	tab = self:GetTabIndex(tab);
	if(tab) then
		self.Tabs[tab]:Show();
		self:PerformLayout();
	end
end

--- Basic tab button widget with icon and text support.
local TabButton = PowerAuras:RegisterWidget("TabButton", "ReusableWidget");

--- Constructs a new instance of the class and returns the frame.
-- @param parent The parent TabFrame widget.
-- @param owned  The frame to show/hide based on the state of this tab.
-- @param text   The text to set on the tab.
-- @param icon   The icon to set on the tab.
-- @param ...    Icon sizing/positioning data.
function TabButton:New(parent, owned, text, icon, ...)
	-- Recycle or create.
	local frame = base(self);
	if(not frame) then
		frame = CreateFrame("CheckButton");
		-- Add text.
		frame.Text = frame:CreateFontString(nil, "OVERLAY");
		frame.Text:SetSize(0, 10);
		frame.Text:SetWordWrap(false);
		frame:SetFontString(frame.Text);
		-- Icon.
		frame.Icon = frame:CreateTexture(nil, "ARTWORK");
		frame.Icon:SetSize(24, 24);
		-- Style the button as needed.
		frame:SetSize(136, 35);
		frame:SetNormalFontObject(GameFontNormal);
		frame:SetHighlightFontObject(GameFontHighlight);
		frame:SetDisabledFontObject(GameFontHighlight);
		-- Add textures.
		frame.TabBgL = frame:CreateTexture(nil, "BACKGROUND");
		frame.TabBgL:SetSize(15, 36);
		frame.TabBgL:SetTexture(
			[[Interface\PaperDollInfoFrame\PaperDollSidebarTabs]]
		);
		-- Background middle.
		frame.TabBgM = frame:CreateTexture(nil, "BACKGROUND");
		frame.TabBgM:SetSize(50, 36);
		frame.TabBgM:SetTexture(
			[[Interface\PaperDollInfoFrame\PaperDollSidebarTabs]]
		);
		-- Background right.
		frame.TabBgR = frame:CreateTexture(nil, "BACKGROUND");
		frame.TabBgR:SetSize(11, 36);
		frame.TabBgR:SetTexture(
			[[Interface\PaperDollInfoFrame\PaperDollSidebarTabs]]
		);
		-- Highlight left.
		frame.HighlightL = frame:CreateTexture(nil, "HIGHLIGHT");
		frame.HighlightL:SetSize(4, 26);
		frame.HighlightL:SetTexture(
			[[Interface\PaperDollInfoFrame\PaperDollSidebarTabs]]
		);
		-- Highlight middle.
		frame.HighlightM = frame:CreateTexture(nil, "HIGHLIGHT");
		frame.HighlightM:SetSize(31, 26);
		frame.HighlightM:SetTexture(
			[[Interface\PaperDollInfoFrame\PaperDollSidebarTabs]]
		);
		-- Highlight right.
		frame.HighlightR = frame:CreateTexture(nil, "HIGHLIGHT");
		frame.HighlightR:SetSize(4, 26);
		frame.HighlightR:SetTexture(
			[[Interface\PaperDollInfoFrame\PaperDollSidebarTabs]]
		);
	end
	-- Update parent.
	frame:SetParent(parent);
	frame:Show();
	-- Store the owned frame.
	frame.OwnedFrame = owned;
	self.Edit(frame, text, icon, ...);
	-- Done.
	return frame;
end

--- Sets the displayed text and icon on the button.
-- @param text   The text to set on the tab.
-- @param icon   The icon to set on the tab.
-- @param w      The width of the icon. Defaults to 24px.
-- @param h      The height of the icon. Defaults to 24px.
-- @param left   The left texcoord for the icon.
-- @param right  The right texcoord for the icon.
-- @param top    The top texcoord for the icon.
-- @param bottom The bottom texcoord for the icon.
function TabButton:Edit(text, icon, w, h, left, right, top, bottom)
	-- Set the text.
	self:SetText(tostring(text));
	-- Icon is optional.
	if(icon and icon ~= "") then
		-- Reposition the text.
		self.Text:SetJustifyH("LEFT");
		self.Icon:SetTexture(icon);
		self.Icon:SetSize(w or 24, h or 24);
		self.Icon:SetTexCoord(left or 0, right or 1, top or 0, bottom or 1);
		self.Icon:Show();
	else
		self.Text:SetJustifyH("CENTER");
		self.Icon:Hide();
	end
end

--- Returns the frame owned by the tab button.
function TabButton:GetOwnedFrame()
	return self.OwnedFrame;
end

--- OnClick script handler for the tab button.
function TabButton:OnClick()
	self:SetChecked(false);
	self:GetParent():SetCurrentTab(self.OwnedFrame);
	PlaySound("igCharacterInfoTab");
end

--- Positions the button.
-- @param previous The previous button in the layout.
-- @param state    The checked state of this tab.
-- @param anchor   The anchoring/layout type of the owning frame.
function TabButton:Position(previous, state, anchor)
	-- Check/uncheck the button.
	self:SetChecked(not not state);
	-- Resize the button if needed.
	if(not self:GetText() or self:GetText():trim() == "") then
		self:SetSize(48, 35);
	else
		local border = (self.Icon:IsShown() and 59 or 36);
		self:SetSize(math.min(148, border + self.Text:GetStringWidth()), 35);
	end
	-- Position the button.
	self:ClearAllPoints();
	if(previous) then
		self:SetPoint("TOPLEFT", previous, "TOPRIGHT", -12, 0);
	else
		if(anchor == "TOP") then
			self:SetPoint("BOTTOMLEFT", self:GetParent(), "TOPLEFT", 0, -2);
		else
			self:SetPoint("TOPLEFT", self:GetParent(), "BOTTOMLEFT", 0, 2);
		end
	end
	-- Style the button based on the state and anchor pos.
	if(state) then
		self:Disable();
		self:GetOwnedFrame():Show();
		if(anchor == "TOP") then
			self.TabBgL:SetPoint("BOTTOMLEFT", 0, 0);
			self.TabBgL:SetTexCoord(0.015625, 0.25, 0.7890625, 0.93359375);
			self.TabBgM:SetPoint("BOTTOMLEFT", 15, 0);
			self.TabBgM:SetPoint("BOTTOMRIGHT", -11, 0);
			self.TabBgM:SetTexCoord(0.25, 0.25, 0.7890625, 0.93359375);
			self.TabBgR:SetPoint("BOTTOMRIGHT", 0, 0);
			self.TabBgR:SetTexCoord(0.625, 0.796875, 0.7890625, 0.93359375);
		else
			self.TabBgL:SetPoint("TOPLEFT", 0, 0);
			self.TabBgL:SetTexCoord(0.015625, 0.25, 0.93359375, 0.7890625);
			self.TabBgM:SetPoint("TOPLEFT", 15, 0);
			self.TabBgM:SetPoint("TOPRIGHT", -11, 0);
			self.TabBgM:SetTexCoord(0.25, 0.25, 0.93359375, 0.7890625);
			self.TabBgR:SetPoint("TOPRIGHT", 0, 0);
			self.TabBgR:SetTexCoord(0.625, 0.796875, 0.93359375, 0.7890625);
		end
	else
		self:Enable();
		self:GetOwnedFrame():Hide();
		if(anchor == "TOP") then
			self.TabBgL:SetPoint("BOTTOMLEFT", 0, 0);
			self.TabBgL:SetTexCoord(0.015625, 0.25, 0.61328125, 0.75390625);
			self.TabBgM:SetPoint("BOTTOMLEFT", 15, 0);
			self.TabBgM:SetPoint("BOTTOMRIGHT", -11, 0);
			self.TabBgM:SetTexCoord(0.25, 0.25, 0.61328125, 0.75390625);
			self.TabBgR:SetPoint("BOTTOMRIGHT", 0, 0);
			self.TabBgR:SetTexCoord(0.625, 0.796875, 0.61328125, 0.75390625);
		else
			self.TabBgL:SetPoint("TOPLEFT", 0, 0);
			self.TabBgL:SetTexCoord(0.015625, 0.25, 0.75390625, 0.61328125);
			self.TabBgM:SetPoint("TOPLEFT", 15, 0);
			self.TabBgM:SetPoint("TOPRIGHT", -11, 0);
			self.TabBgM:SetTexCoord(0.25, 0.25, 0.75390625, 0.61328125);
			self.TabBgR:SetPoint("TOPRIGHT", 0, 0);
			self.TabBgR:SetTexCoord(0.625, 0.796875, 0.75390625, 0.61328125);
		end
	end
	-- Anchoring updates for non-state dependent things.
	if(self.Icon:IsShown()) then
		self.Text:SetPoint("LEFT", 41, (anchor == "TOP" and -4 or 4));
		self.Text:SetPoint("RIGHT", -11, (anchor == "TOP" and -4 or 4));
		self.Icon:SetPoint("LEFT", 13 - ((self.Icon:GetWidth() - 24) / 2), 
			(anchor == "TOP" and -5.5 or 4.5));
	else
		self.Text:SetPoint("LEFT", 15, (anchor == "TOP" and -4 or 4));
		self.Text:SetPoint("RIGHT", -11, (anchor == "TOP" and -4 or 4));
	end
	-- Reposition the highlight overlay.
	if(anchor == "TOP") then
		self.HighlightL:SetPoint("TOPLEFT", 11, -8);
		self.HighlightL:SetTexCoord(0.015625, 0.078125, 0.1953125, 0.296875);
		self.HighlightM:SetPoint("TOPLEFT", 15, -8);
		self.HighlightM:SetPoint("TOPRIGHT", -12, -8);
		self.HighlightM:SetTexCoord(0.078125, 0.4375, 0.1953125, 0.296875);
		self.HighlightR:SetPoint("TOPRIGHT", -8, -8);
		self.HighlightR:SetTexCoord(0.4375, 0.5, 0.1953125, 0.296875);
	else
		self.HighlightL:SetPoint("TOPLEFT", 11, 0);
		self.HighlightL:SetTexCoord(0.015625, 0.078125, 0.296875, 0.1953125);
		self.HighlightM:SetPoint("TOPLEFT", 15, 0);
		self.HighlightM:SetPoint("TOPRIGHT", -12, 0);
		self.HighlightM:SetTexCoord(0.078125, 0.4375, 0.296875, 0.1953125);
		self.HighlightR:SetPoint("TOPRIGHT", -8, 0);
		self.HighlightR:SetTexCoord(0.4375, 0.5, 0.296875, 0.1953125);
	end
end

--- Recycles the tab button for reuse later.
function TabButton:Recycle()
	-- Hide the owned frame too.
	self.OwnedFrame:Hide();
	self.OwnedFrame = nil;
	-- Forward call to superclass.
	base(self);
end