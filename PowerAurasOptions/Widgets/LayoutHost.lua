-- Lock down local environment.
local PowerAuras = _G["PowerAuras"];
setfenv(1, PowerAuras);

--- Host container for most of the editor windows. Provides a flowing container
--  layout.
local LayoutHost = PowerAuras:RegisterWidget("LayoutHost", "ScrollFrame");

--- Constructs a new instance of the class and returns the frame.
-- @param parent The parent frame.
function LayoutHost:New(parent)
	-- Construct as normal.
	local frame = base(self, parent);
	frame.Widgets = (frame.Widgets or {});
	return frame;
end

--- Initialises the layout host, resetting the layout type to Auto.
function LayoutHost:Initialise()
	self:SetLayoutType("Auto");
end

--- Adds a spacer to the container. Spacers provide either an absolute or
--  relative amount of horizontal spacing that can be used for creating
--  gaps in elements, or wrapping them to the next row.
-- @param width Amount of relative width to space by.
function LayoutHost:AddRelativeSpacer(width)
	-- Add spacer and reperform the layout.
	width = math.max(0, math.min(100, width * 100));
	tinsert(self.Widgets, bit.bor(bit.band(width, 0x00FFFFFF), 0x01000000));
	self:PerformLayout();
end

--- Adds a spacer to the container. Spacers provide either an absolute or
--  relative amount of horizontal spacing that can be used for creating
--  gaps in elements, or wrapping them to the next row.
-- @param width Amount of absolute width to space by.
function LayoutHost:AddSpacer(width)
	tinsert(self.Widgets, bit.band(width, 0x00FFFFFF));
	self:PerformLayout();
end

--- Adds a stretcher to the container. This will create a fluid space on the
--  current row of the container that causes all elements to the right of it
--  to be positioned against that side of the frame, as opposed to the left.
function LayoutHost:AddStretcher()
	tinsert(self.Widgets, 0x04FFFFFF);
	self:PerformLayout();
end

--- Adds a special marker that extends the height of the previous widget to
--  fill the remaining container height. Only works if this is the last
--  added widget. Only works for widgets, not spacers.
function LayoutHost:AddVerticalFill()
	tinsert(self.Widgets, 0x08FFFFFF);
	self:PerformLayout();
end

--- Adds an empty row to the host.
-- @param height The height of the row.
function LayoutHost:AddRow(height)
	tinsert(self.Widgets, bit.bor(bit.band(height, 0x00FFFFFF), 0x02000000));
	self:PerformLayout();
end

--- Adds a widget to the layout.
-- @param widget The widget to add to the container.
function LayoutHost:AddWidget(widget)
	-- Register, relayout.
	tinsert(self.Widgets, widget);
	widget:SetParent(self);
	self:PerformLayout();
end

--- Removes all widgets and spacers from the container.
function LayoutHost:ClearWidgets()
	-- Remove everything.
	self:PauseLayout();
	self:SetScrollRange(0, 0);
	for i = #(self.Widgets), 1, -1 do
		local item = self.Widgets[i];
		if(type(item) == "number") then
			self:RemoveSpacer(i);
		else
			self:RemoveWidget(item);
		end
	end
	self:ResumeLayout();
end

--- Returns the padding data for this element.
function LayoutHost:GetContentPadding()
	self.ContentPadding = (self.ContentPadding or { 0, 0, 0, 0 });
	return self.ContentPadding;
end

--- Removes a spacer from the container.
-- @param index The index to remove the spacer from. If no spacer is at this
--              index, nothing happens.
function LayoutHost:RemoveSpacer(index)
	-- Validate the index.
	if(type(self.Widgets[index]) == "number") then
		tremove(self.Widgets, index);
		self:PerformLayout();
	end
end

--- Removes a widget from the container.
-- @param widget The widget to remove.
function LayoutHost:RemoveWidget(widget)
	-- Remove and recycle.
	for i = #(self.Widgets), 1, -1 do
		if(self.Widgets[i] == widget) then
			tremove(self.Widgets, i);
		end
	end
	-- Recycle, done.
	if(widget.Recycle) then
		widget:Recycle();
	end
	self:PerformLayout();
end

--- Performs a layout pass, moving and positioning all child elements.
function LayoutHost:PerformLayout()
	-- Skip if paused.
	if(not base(self)) then return; end
	-- Get total frame size to fit things in.
	local width, height = self:GetSize();
	-- Remove edges from size for content padding.
	local cPL, cPT, cPR, cPB = unpack(self:GetContentPadding());
	width = math.floor(width - cPL - cPR);
	height = math.floor(height - cPT - cPB);
	-- If scrollbar is showing, it affects our width.
	if(self.ScrollBar:IsShown()) then
		width = math.floor(width - self.ScrollBar:GetWidth());
	end
	-- If in fluid mode, use a ridiculous height.
	if(self.LayoutType == "Fluid") then
		height = math.huge;
	end
	-- Keep track of offsets.
	local sO = self:GetScrollOffset() + 1;
	local oX, oY, cR, bIR, eIR, rH, wR, wVR = cPL, cPT, 1, 0, 0, 0, 0, 0;
	-- Iterate over all of the widgets.
	for i = 1, #(self.Widgets) do
		-- Get widget sizing data.
		local widget = self.Widgets[i];
		local wW, wH, wPL, wPT, wPR, wPB, wML, wMT, wMR, wMB, wFIW, wFIH =
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, false;
		-- If the widget is a frame...
		if(type(widget) == "table") then
			wW, wH = widget:GetSize();
			-- Can we replace the size with a relative/fixed one?
			local wTW, wTH = widget:GetRelativeSize();
			-- No special sizing?
			wFIW = (not wTW and not widget:GetFixedWidth());
			wFIH = (not wTH and not widget:GetFixedHeight());
			-- Set sizes.
			wTW = (wTW and math.floor(wTW * width)
				or widget:GetFixedWidth()
				or wW);
			wTH = (wTH and math.floor(wTH * height)
				or widget:GetFixedHeight()
				or wH);
			wW, wH = wTW, wTH;
			-- Extract padding/margins.
			wPL, wPT, wPR, wPB = unpack(widget:GetPadding());
			wML, wMT, wMR, wMB = unpack(widget:GetMargins());
		elseif(type(widget) == "number") then
			-- Special widget.
			local mode = bit.rshift(bit.band(widget, 0xFF000000), 24);
			local value = bit.band(widget, 0x00FFFFFF);
			if(mode == 0) then
				-- Fixed width spacer.
				wW = value;
			elseif(mode == 1) then
				-- Relative width spacer.
				wW = math.floor((value / 100) * width);
			elseif(mode == 2) then
				-- Empty row. Apply directly to offsets (workaround).
				oX = oX + width;
				oY = oY + value;
			elseif(mode == 4) then
				-- Stretcher.
				local uS = oX - cPL;
				for j = i + 1, #(self.Widgets) do
					-- Get next item.
					local widget = self.Widgets[j];
					local wTW = 0;
					if(type(widget) == "table") then
						-- Get item width.
						wTW = widget:GetWidth();
						local wRW = widget:GetRelativeWidth();
						local wFW = widget:GetFixedWidth();
						wTW = (wRW and math.floor(wRW * width) or wFW or wTW);
						-- Extract margins.
						local wML, wMT, wMR, wMB = unpack(widget:GetMargins());
						wTW = wTW + wML + wMR;
						wTW = math.min(wTW, width);
					elseif(type(widget) == "number") then
						local mode = bit.rshift(
							bit.band(widget, 0xFF000000),
							24
						);
						local value = bit.band(widget, 0x00FFFFFF);
						if(mode == 0) then
							wTW = value;
						elseif(mode == 1) then
							wTW = math.floor((value / 100) * width);
						end
					end
					-- Will item fit on row?
					if((uS - cPL) + wTW > width) then
						break;
					else
						-- Can fit, increment used space.
						uS = uS + wTW;
					end
				end
				-- Apply remaining space to the offset.
				oX = oX + (width - uS);
			elseif(mode == 8 and i == #(self.Widgets)) then
				-- Vertical fill. Get remaining space.
				local remH = height - (oY + rH);
				if(remH > 0 and type(self.Widgets[i - 1]) == "table") then
					-- Set new height.
					local widget = self.Widgets[i - 1];
					local wPL, wPT, wPR, wPB = unpack(widget:GetPadding());
					widget:SetHeight(math.min(height, remH) - wPT - wPB);
				end
			end
		end
		-- Can we fit the item onto this row? Calculate full width/height and
		-- include margins.
		local wFW, wFH = wW + wML + wMR, wH + wMT + wMB;
		wFW = math.min(wFW, width);
		wFH = math.min(wFH, height);
		if((oX - cPL) + wFW > width) then
			-- Did the combined offset and height of the last row cause any
			-- display issues?
			if((oY - cPT) + rH > height and wVR > 0) then
				local j, k = i - 1, 0;
				while(k < wVR and j > 0) do
					local widget = self.Widgets[j];
					if(type(widget) == "table") then
						self.Widgets[j]:ClearAllPoints();
						self.Widgets[j]:Hide();
						-- Increment removed counter.
						k = k + 1;
					end
					-- Move back one index.
					j = j - 1;
				end
			end
			-- Wrap to the next row.
			oX = cPL; -- Reset X offset.
			bIR = bIR + (cR < sO and wR > 0 and 1 or 0);
			eIR = eIR + ((oY - cPT) + rH > height and wR > 0 and 1 or 0);
			cR = cR + (rH > 0 and 1 or 0); -- Increment current (total) rows.
			oY = oY + (wVR > 0 and rH or 0); -- Increment Y offset if visible.
			rH = 0; -- Reset row height and widget counters.
			wR = 0;
			wVR = 0;
		end
		-- Display the item.
		if(type(widget) == "table") then
			if(wFW > 0 and wFH > 0 and cR >= sO and (oY - cPT) <= height) then
				widget:ClearAllPoints();
				widget:SetPoint("TOPLEFT", oX + wML + wPL, -(oY + wMT + wPT));
				widget:SetSize(
					(wFIW and wW or wW - wPL - wPR),
					(wFIH and wH or wH - wPT - wPB)
				);
				widget:Show();
				-- Increment visible widget counter.
				wVR = wVR + 1;
			else
				widget:ClearAllPoints();
				widget:Hide();
			end
			-- Increment widget counter on this row.
			wR = wR + 1;
		end
		-- Increment offsets.
		oX = oX + wFW;
		rH = math.max(rH, wFH);
	end
	-- Did the combined offset and height of the last row cause any
	-- display issues?
	if((oY - cPT) + rH > height and wVR > -1) then
		local j, k = #(self.Widgets), 0;
		while(k < wR and j > 0) do
			local widget = self.Widgets[j];
			if(type(widget) == "table") then
				self.Widgets[j]:ClearAllPoints();
				self.Widgets[j]:Hide();
				-- Increment removed counter.
				k = k + 1;
			end
			-- Move back one index.
			j = j - 1;
		end
		-- Increment invisible row count.
		eIR = eIR + 1;
	end
	-- Update scroll ranges.
	if(self.LayoutType == "Auto") then
		self:SetFixedHeight(0);
		self:SetScrollRange(0, bIR + eIR);
	elseif(self.LayoutType == "Fluid") then
		self:SetFixedHeight(oY + cPB + rH);
		self:SetScrollRange(0, 0);
	end
end

--- Sets the internal content region padding.
-- @param top    The top padding.
-- @param left   The left padding.
-- @param right  The right padding.
-- @param bottom The bottom padding.
function LayoutHost:SetContentPadding(top, left, right, bottom)
	-- Params can't be nil.
	top, left, right, bottom = top or 0, left or 0, right or 0, bottom or 0;
	-- Store padding.
	self.ContentPadding = (self.ContentPadding or { top, left, right, bottom });
	self.ContentPadding[1], self.ContentPadding[2],
		self.ContentPadding[3], self.ContentPadding[4] = 
		top, left, right, bottom;
	-- Update layout.
	self:PerformLayout();
end

--- Sets the layout type for the host.
-- @param type The type to set. Valid values are "Fluid" and "Auto". Auto will
--             cause the control to gain a scrollbar, Fluid will cause it to
--             automatically adjust the height.
function LayoutHost:SetLayoutType(type)
	self.LayoutType = (type == "Fluid" and type or "Auto");
	self:PerformLayout();
end

--- Normal frame, but with a blue tint.
local BlueFrame = PowerAuras:RegisterWidget("BlueFrame", "LayoutHost");

--- Constructs a new instance of the frame.
-- @param parent The parent of the frame.
-- @param side   What side to plade a separator bar on. Leave as nil for
--               no bar.
function BlueFrame:New(parent, side)
	-- Create the frame.
	local frame = base(self, parent);
	frame:SetBackdrop(nil);
	-- Background for the sidebar.
	frame.Bg = frame:CreateTexture(nil, "BACKGROUND");
	frame.Bg:SetTexture([[Interface\Common\bluemenu-main]]);
	frame.Bg:SetTexCoord(0.00390625, 0.82421875, 0.18554688, 0.58984375);
	frame.Bg:SetAllPoints(true);
	-- Shadow textures for sidebar.
	frame.SR = frame:CreateTexture(nil, "BACKGROUND");
	frame.SR:SetDrawLayer("BACKGROUND", 1);
	frame.SR:SetTexture([[Interface\Common\bluemenu-vert]], true);
	frame.SR:SetTexCoord(0.41406250, 0.742188, 0.0, 1.0);
	frame.SR:SetVertTile(true);
	frame.SR:SetWidth(43);
	frame.SR:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0);
	frame.SR:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0);
	frame.SL = frame:CreateTexture(nil, "BACKGROUND");
	frame.SL:SetDrawLayer("BACKGROUND", 1);
	frame.SL:SetTexture([[Interface\Common\bluemenu-vert]], true);
	frame.SL:SetTexCoord(0.125, 0.39843750, 0.0, 1.0);
	frame.SL:SetVertTile(true);
	frame.SL:SetWidth(43);
	frame.SL:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0);
	frame.SL:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0);
	frame.ST = frame:CreateTexture(nil, "BACKGROUND");
	frame.ST:SetDrawLayer("BACKGROUND", 1);
	frame.ST:SetTexture([[Interface\Common\bluemenu-goldborder-horiz]], true);
	frame.ST:SetTexCoord(0.0, 1.0, 0.015625, 0.34375000);
	frame.ST:SetHorizTile(true);
	frame.ST:SetHeight(43);
	frame.ST:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0);
	frame.ST:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0);
	frame.SB = frame:CreateTexture(nil, "BACKGROUND");
	frame.SB:SetDrawLayer("BACKGROUND", 1);
	frame.SB:SetTexture([[Interface\Common\bluemenu-goldborder-horiz]], true);
	frame.SB:SetTexCoord(0.0, 1.0, 0.35937500, 0.6875);
	frame.SB:SetHorizTile(true);
	frame.SB:SetHeight(43);
	frame.SB:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0);
	frame.SB:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0);
	-- Separator bar.
	if(side) then
		local bar = frame:CreateTexture(nil, "BORDER");
		frame.Bar = bar;
		-- Change texcoords/positioning/size based upon the side.
		if(side == "LEFT" or side == "RIGHT") then
			bar:SetTexture([[Interface\FrameGeneral\!UI-Frame]]);
			bar:SetVertexColor(0.6, 0.6, 0.6, 1.0);
			if(side == "RIGHT") then
				bar:SetTexCoord(0.203125, 0.296875, 0, 1);
				bar:SetPoint("TOPLEFT", frame, "TOPRIGHT", -3, 0);
				bar:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", -3, 0);
			else
				bar:SetTexCoord(0.296875, 0.203125, 0, 1);
				bar:SetPoint("TOPRIGHT", frame, "TOPLEFT", 3, 0);
				bar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", 3, 0);
			end
			bar:SetWidth(6);
		else
			bar:SetTexture([[Interface\FrameGeneral\_UI-Frame]]);
			bar:SetVertexColor(0.6, 0.6, 0.6, 1.0);
			if(side == "TOP") then
				bar:SetTexCoord(0, 1, 0.445312, 0.492188);
				bar:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, -3);
				bar:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 0, -3);
			else
				bar:SetTexCoord(0, 1, 0.492188, 0.445312);
				bar:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, 3);
				bar:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", 0, 3);
			end
			bar:SetHeight(6);
		end
	end
	-- Done!
	return frame;
end

--- Basic reusable list-inlay widget. Supports pagination if there's too many
--  damn items.
local ListInlay = PowerAuras:RegisterWidget("ListInlay", "ReusableWidget");

--- Creates/recycles an instance of the widget.
function ListInlay:New()
	-- Does exactly what it says on the tin.
	local frame = base(self);
	if(not frame) then
		frame = CreateFrame("Frame", nil, UIParent);
		-- Add fixed child frames.
		frame.Pane = PowerAuras:Create("LayoutHost", frame);
		frame.Pane:SetBackdrop(nil);
		frame.Pane:SetPoint("TOPLEFT", 0, -32);
		frame.Pane:SetPoint("BOTTOMRIGHT", 0, 0);
		frame.Pane:SetContentPadding(8, 8, 8, 8);
		-- Shadows for the visible area.
		frame.ST = frame.Pane:CreateTexture(nil, "BACKGROUND");
		frame.ST:SetDrawLayer("BACKGROUND", 1);
		frame.ST:SetTexture([[Interface\Common\bluemenu-goldborder-horiz]],
			true);
		frame.ST:SetTexCoord(0.0, 1.0, 0.015625, 0.34375000);
		frame.ST:SetHorizTile(true);
		frame.ST:SetHeight(43);
		frame.ST:SetPoint("TOPLEFT", 0, 0);
		frame.ST:SetPoint("TOPRIGHT", 0, 0);
		frame.SB = frame.Pane:CreateTexture(nil, "BACKGROUND");
		frame.SB:SetDrawLayer("BACKGROUND", 1);
		frame.SB:SetTexture([[Interface\Common\bluemenu-goldborder-horiz]],
			true);
		frame.SB:SetTexCoord(0.0, 1.0, 0.35937500, 0.6875);
		frame.SB:SetHorizTile(true);
		frame.SB:SetHeight(43);
		frame.SB:SetPoint("BOTTOMLEFT", 0, 0);
		frame.SB:SetPoint("BOTTOMRIGHT", 0, 0);
		-- Page selection.
		frame.PageBar = PowerAuras:Create("BlueFrame", frame, "BOTTOM");
		frame.PageBar.Bg:SetTexture(
			[[Interface\PlayerActionBarAlt\GENERICWOW]]
		);
		frame.PageBar.Bg:SetTexCoord(0, 1, 0.173828, 0.357422);
		frame.PageBar:SetHeight(29);
		frame.PageBar:SetPoint("TOPLEFT", 0, 0);
		frame.PageBar:SetPoint("TOPRIGHT", 0, 0);
		-- Next/Previous buttons.
		frame.PageBar.Prev = CreateFrame("Button", nil, frame.PageBar);
		frame.PageBar.Prev:SetSize(32, 32);
		frame.PageBar.Prev:SetPoint("TOPLEFT", 0, 0);
		frame.PageBar.Prev:SetNormalTexture(
			[[Interface\Buttons\UI-SpellbookIcon-PrevPage-Up]]
		);
		frame.PageBar.Prev:SetPushedTexture(
			[[Interface\Buttons\UI-SpellbookIcon-PrevPage-Down]]
		);
		frame.PageBar.Prev:SetDisabledTexture(
			[[Interface\Buttons\UI-SpellbookIcon-PrevPage-Disabled]]
		);
		frame.PageBar.Prev:SetHighlightTexture(
			[[Interface\Buttons\UI-Common-MouseHilight]]
		);
		frame.PageBar.Prev:SetScript("OnClick", function()
			PlaySound("UChatScrollButton");
			frame.PageBar.Box:OnMouseWheel(-1);
		end);
		frame.PageBar.Next = CreateFrame("Button", nil, frame.PageBar);
		frame.PageBar.Next:SetSize(32, 32);
		frame.PageBar.Next:SetPoint("TOPRIGHT", 0, 0);
		frame.PageBar.Next:SetNormalTexture(
			[[Interface\Buttons\UI-SpellbookIcon-NextPage-Up]]
		);
		frame.PageBar.Next:SetPushedTexture(
			[[Interface\Buttons\UI-SpellbookIcon-NextPage-Down]]
		);
		frame.PageBar.Next:SetDisabledTexture(
			[[Interface\Buttons\UI-SpellbookIcon-NextPage-Disabled]]
		);
		frame.PageBar.Next:SetHighlightTexture(
			[[Interface\Buttons\UI-Common-MouseHilight]]
		);
		frame.PageBar.Next:SetScript("OnClick", function()
			PlaySound("UChatScrollButton");
			frame.PageBar.Box:OnMouseWheel(1);
		end);
		-- Numberbox for page selection.
		frame.PageBar.Box = PowerAuras:Create("NumberBox", frame.PageBar);
		frame.PageBar.Box:SetPoint("TOPLEFT", frame.PageBar, "TOP", 2, -3);
		frame.PageBar.Box:SetSize(frame.PageBar.Box:GetFixedSize());
		frame.PageBar.Box:SetHitRectInsets(0, 0, 0, 0);
		frame.PageBar.Box.OnValueUpdated:Connect(function(_, value)
			frame:SetCurrentPage(value);
		end);
		-- Page label.
		frame.PageBar.Lab = frame.PageBar:CreateFontString(nil, "OVERLAY");
		frame.PageBar.Lab:SetPoint("TOPRIGHT", frame.PageBar, "TOP", -2, -3);
		frame.PageBar.Lab:SetHeight(23);
		frame.PageBar.Lab:SetJustifyH("RIGHT");
		frame.PageBar.Lab:SetJustifyV("MIDDLE");
		frame.PageBar.Lab:SetFontObject(GameFontNormal);
		frame.PageBar.Lab:SetText(L("TColon", L["Page"]));
		-- Item storage.
		frame.Tables = setmetatable({}, { __mode = "v" });
		frame.Items = {};
		frame.ItemsByKey = {};
		frame.Widgets = {};
		-- Page data.
		frame.PageSize = 3;
		frame.CurrentPage = 1;
		frame.CurrentItem = nil;
		-- Callbacks.
		frame.OnContentRefreshed = PowerAuras.Callback();
		frame.OnTasksRefreshed = PowerAuras.Callback();
	end
	return frame;
end

--- Initialises the widget.
-- @param parent The parent widget.
function ListInlay:Initialise(parent)
	-- Reparent frame.
	self:SetParent(parent);
	self.LayoutPaused = 0;
	self:UpdatePage();
end

--- Adds an item to the widget.
-- @param key  The key of the item. Must be unique.
-- @param text The item text.
-- @param icon The icon to show. Optional.
-- @param ...  Optional tabs to add to the item.
function ListInlay:AddItem(key, text, icon, ...)
	-- Ensure key uniqueness.
	assert(not self.ItemsByKey[key], ("Item with key exists: %s"):format(key));
	-- Recycle a table.
	local item = tremove(self.Tables) or {};
	item.Key, item.Text, item.Icon = key, text, icon;
	item.Tabs = (tremove(self.Tables) or {});
	for i = 1, select("#", ...) do
		item.Tabs[i] = select(i, ...);
	end
	-- Add to tables.
	tinsert(self.Items, item);
	self.ItemsByKey[key] = item;
	-- Update UI.
	self:UpdatePage(self:GetItemPageNumber(key));
end

--- Removes all items from the widget.
function ListInlay:ClearItems()
	for i = #(self.Items), 1, -1 do
		self:RemoveItem(self.Items[i].Key);
	end
end

--- Returns the current selected item key.
function ListInlay:GetCurrentItem()
	return self.CurrentItem;
end

--- Returns the current page number.
function ListInlay:GetCurrentPage()
	return self.CurrentPage;
end

--- Returns the page number that contains an item.
-- @param key The key of the item.
function ListInlay:GetItemPageNumber(key)
	-- Ensure key exists.
	assert(self.ItemsByKey[key], ("No item with key: %s"):format(key));
	-- Find it.
	for i = 1, #(self.Items) do
		if(self.Items[i].Key == key) then
			return math.ceil(i / self.PageSize);
		end
	end
	-- Failed, somehow.
	return 1;
end

--- Returns the total number of pages.
function ListInlay:GetPageCount()
	return math.ceil(#(self.Items) / self.PageSize);
end

--- Returns the maximum number of shown items per page.
function ListInlay:GetPageSize()
	return self.PageSize;
end

--- Returns true/false if the specified item exists.
-- @param key The key of the item.
function ListInlay:HasItem(key)
	return not not self.ItemsByKey[key];
end

--- Pauses the layout, preventing UpdatePage from doing anything.
function ListInlay:PauseLayout()
	self.LayoutPaused = (self.LayoutPaused and self.LayoutPaused + 1 or 1);
end

--- Recycles the widget, allowing it to be reused.
function ListInlay:Recycle()
	-- Recycle child widgets.
	self.Pane:PauseLayout();
	self.Pane:ClearWidgets();
	self.Pane:ResumeLayout();
	-- Reset callbacks.
	self.OnContentRefreshed:Reset();
	self.OnTasksRefreshed:Reset();
	-- Clear all our items.
	self:PauseLayout();
	self:ClearItems();
	self:ResumeLayout();
	-- Reset page size.
	self:SetPageSize(3);
	base(self);
end

--- Removes an item from the widget.
-- @param key The key of the item.
function ListInlay:RemoveItem(key)
	-- Ensure key exists.
	assert(self.ItemsByKey[key], ("No item with key: %s"):format(key));

	-- Reclaim this item for Aiur!
	local item = self.ItemsByKey[key];
	self.ItemsByKey[key] = nil;
	tinsert(self.Tables, wipe(item.Tabs));
	tinsert(self.Tables, wipe(item));
	for i = #(self.Items), 1, -1 do
		if(self.Items[i] == item) then
			tremove(self.Items, i);
			break;
		end
	end

	-- Was this selected?
	if(self.CurrentItem == key) then
		self:SetCurrentItem(nil);
	else
		self:UpdatePage();
	end
end

--- Resumes and re-performs the layout.
function ListInlay:ResumeLayout()
	self.LayoutPaused = (self.LayoutPaused and self.LayoutPaused - 1 or 0);
	self:UpdatePage();
end

--- Sets the currently expanded item.
-- @param key The key of the item.
function ListInlay:SetCurrentItem(key)
	-- Ensure key exists.
	if(key) then
		assert(self.ItemsByKey[key], ("No item with key: %s"):format(key));
	end
	-- Update.
	self.CurrentItem = key;
	self:UpdatePage(key and self:GetItemPageNumber(key) or nil);
end

--- Sets the currently displayed page.
-- @param index The page number.
function ListInlay:SetCurrentPage(index)
	-- Update.
	self.CurrentPage = math.max(1, math.min(index, self:GetPageCount()));
	self:UpdatePage();
end

--- Sets the maximum number of items per page.
-- @param size The number of items per page.
function ListInlay:SetPageSize(size)
	-- Update.
	self.PageSize = math.max(1, size);
	self:SetCurrentPage(self.CurrentPage);
end

--- Updates the page display.
-- @param page If specified, the update is only performed if this is the
--             current page number.
function ListInlay:UpdatePage(page)
	-- Update button states.
	self.PageBar.Prev:SetEnabled(self.CurrentPage > 1);
	self.PageBar.Next:SetEnabled(self.CurrentPage < self:GetPageCount());
	-- Pause editbox updates.
	self.PageBar.Box.OnValueUpdated:Pause();
	-- Update.
	self.PageBar.Box:SetMinMaxValues(1, self:GetPageCount());
	self.PageBar.Box:SetValue(self.CurrentPage);
	-- Resume.
	self.PageBar.Box.OnValueUpdated:Resume();
	-- Show/hide the page bar.
	self.PageBar:SetShown(self:GetPageCount() > 1);
	-- Verify page match.
	if(page and page ~= self.CurrentPage) then
		return;
	end
	-- Recycle widgets.
	self.Pane:PauseLayout();
	self.Pane:ClearWidgets();
	for i = #(self.Widgets), 1, -1 do
		tremove(self.Widgets):Recycle();
	end
	-- Reposition the content pane.
	local barOffset = (self.PageBar:IsShown() and 32 or 0);
	self.Pane:SetPoint("TOPLEFT", 0, -barOffset);
	self.Pane:SetPoint("BOTTOMRIGHT", 0, 0);
	self.SB:Hide();
	self.Pane:Hide();
	-- Bail early if there's no items.
	if(#(self.Items) == 0) then
		self.Pane:ResumeLayout();
		self.Pane:Show();
		return;
	end
	-- Calculate number of visible items.
	local shownItems = (self.CurrentPage >= self:GetPageCount()
		and ((#(self.Items) % self.PageSize) > 0
				and (#(self.Items) % self.PageSize)
				or self.PageSize)
		or self.PageSize);
	-- Add buttons for this page.
	local currentWidget;
	for i = 1, shownItems do
		-- Get item index.
		local index = (self.CurrentPage - 1) * self.PageSize + i;
		local item = self.Items[index];
		if(not item) then
			break;
		end
		-- Create widget.
		local w = PowerAuras:Create("ListInlayItem", self, item);
		tinsert(self.Widgets, w);
		-- Have we shown the content frame?
		if(self.Pane:IsShown()) then
			-- Bottom to top.
			w:SetPoint("BOTTOMLEFT", 0, ((shownItems - i) * 32));
			w:SetPoint("BOTTOMRIGHT", 0, ((shownItems - i) * 32));
		else
			-- Top to bottom.
			w:SetPoint("TOPLEFT", 0, -(((i - 1) * 32) + barOffset));
			w:SetPoint("TOPRIGHT", 0, -(((i - 1) * 32) + barOffset));
		end
		-- Get previous item.
		local prev = self.Items[(self.CurrentPage - 1) * self.PageSize + i - 1];
		-- Is this the selected item?
		if(item.Key == self.CurrentItem) then
			-- Attach top of content pane to it.
			currentWidget = w;
			self.Pane:SetPoint("TOPLEFT", w, "BOTTOMLEFT", 0, 0);
			self.Pane:Show();
		elseif(prev and prev.Key == self.CurrentItem) then
			-- Attach bottom of pane to it.
			self.Pane:SetPoint("BOTTOMRIGHT", w, "TOPRIGHT", 0, 0);
			self.SB:Show();
		end
	end
	-- Resume layout of content pane.
	self:OnContentRefreshed(self.Pane, self.CurrentItem,
		(currentWidget and currentWidget:GetCurrentTab() or nil));
	self.Pane:ResumeLayout();
end

--- Reusable item widget for the ListInlay.
local InlayItem = PowerAuras:RegisterWidget("ListInlayItem", "ReusableWidget");

--- Constructs/recycles an instance of the widget.
function InlayItem:New()
	local f = base(self);
	if(not f) then
		-- Create the button.
		f = CreateFrame("CheckButton", nil, UIParent);
		f:SetHeight(32);

		-- Background.
		f.Bg = f:CreateTexture(nil, "BACKGROUND");
		f.Bg:SetAllPoints(true);
		f.Bg:SetTexture([[Interface\FrameGeneral\UI-Background-Marble]], true);
		f.Bg:SetHorizTile(true);
		f.Bg:SetVertTile(true);

		-- Borders.
		f.Border = f:CreateTexture(nil, "BORDER");
		f.Border:SetTexture([[Interface\LevelUp\LevelUpTex]]);
		f.Border:SetTexCoord(0.00195313, 0.81835938, 0.00195313, 0.01562500);
		f.Border:SetHeight(7);

		-- Icon.
		f.Icon = f:CreateTexture(nil, "ARTWORK");
		f.Icon:SetSize(24, 24);
		f.Icon:SetPoint("TOPLEFT", 4, -4);

		-- Subframe for buttons. Shown only if this is the currently selected
		-- item.
		f.Tasks = PowerAuras:Create("LayoutHost", f);
		f.Tasks:SetPoint("TOPRIGHT", -12, 0);
		f.Tasks:SetPoint("BOTTOMRIGHT", -12, 0);
		f.Tasks:SetBackdrop(nil);
		f.Tasks:SetWidth(1);
		f.Tasks:SetLayoutType("Fluid");

		-- Tab offset buttons.
		f.TabL = PowerAuras:Create("IconButton", f);
		f.TabL:SetIcon([[Interface\Minimap\MiniMap-PositionArrows]]);
		f.TabL:SetIconTexCoord(0.0, 1.0, 0.0, 0.5);
		f.TabL:SetSize(16, 28);
		SetClampedTextureRotation(f.TabL:GetNormalTexture(), 270);
		f.TabL.OnClicked:Connect(function()
			local tab = f.Tabs[f.CurrentTab + 1];
			if(tab) then
				tab:OnClick();
			end
		end);

		f.TabR = PowerAuras:Create("IconButton", f);
		f.TabR:SetIcon([[Interface\Minimap\MiniMap-PositionArrows]]);
		f.TabR:SetIconTexCoord(0.0, 1.0, 0.5, 1.0);
		f.TabR:SetSize(16, 28);
		SetClampedTextureRotation(f.TabR:GetNormalTexture(), 270);
		f.TabR:SetPoint("BOTTOMRIGHT", -4, 2);
		f.TabR.OnClicked:Connect(function()
			local tab = f.Tabs[f.CurrentTab - 1];
			if(tab) then
				tab:OnClick();
			end
		end);

		-- Text.
		f.Text = f:CreateFontString(nil, "OVERLAY");
		f.Text:SetFontObject(GameFontNormal);
		f.Text:SetPoint("TOPLEFT", 36, -4);
		f.Text:SetPoint("BOTTOM", 0, 4);
		f.Text:SetPoint("RIGHT", f.Tasks, "LEFT", -4, 0);
		f.Text:SetJustifyV("MIDDLE");
		f.Text:SetJustifyH("LEFT");
		f.Text:SetWordWrap(false);
		f:SetFontString(f.Text);
		f:SetNormalFontObject(GameFontHighlight);
		f:SetHighlightFontObject(GameFontNormal);
		f:SetDisabledFontObject(GameFontNormal);

		-- Shadows.
		f.SL = f:CreateTexture(nil, "BORDER");
		f.SL:SetDrawLayer("BORDER", 7);
		f.SL:SetTexture([[Interface\Common\bluemenu-vert]], true);
		f.SL:SetTexCoord(0.125, 0.39843750, 0.0, 1.0);
		f.SL:SetVertTile(true);
		f.SL:SetWidth(43);
		f.SL:SetPoint("TOPLEFT", 0, 0);
		f.SL:SetPoint("BOTTOMLEFT", 0, 0);
		f.SR = f:CreateTexture(nil, "BORDER");
		f.SR:SetDrawLayer("BORDER", 7);
		f.SR:SetTexture([[Interface\Common\bluemenu-vert]], true);
		f.SR:SetTexCoord(0.41406250, 0.742188, 0.0, 1.0);
		f.SR:SetVertTile(true);
		f.SR:SetWidth(43);
		f.SR:SetPoint("TOPRIGHT", 0, 0);
		f.SR:SetPoint("BOTTOMRIGHT", 0, 0);
		f.Tabs = {};
	end
	return f;
end

--- Initialises the widget.
-- @param parent The parent of the widget.
-- @param item   The item table.
function InlayItem:Initialise(parent, item)
	-- Set up the widget.
	self:SetParent(parent);
	self:SetText(item.Text);
	self.CurrentTab = (self.Key ~= item.Key and 1 or self.CurrentTab or 1);
	self.Key = item.Key;
	-- Show an icon?
	if(item.Icon and item.Icon ~= "") then
		self.Text:SetPoint("TOPLEFT", 36, -4);
		self.Icon:SetTexture(item.Icon);
		self.Icon:Show();
	else
		self.Text:SetPoint("TOPLEFT", 12, -4);
		self.Icon:Hide();
	end

	-- Is the item checked?
	self:SetEnabled(item.Key ~= parent:GetCurrentItem());
	if(item.Key == parent:GetCurrentItem()) then
		self.Border:SetVertexColor(1.0, 0.8, 0.0);
		-- Also show tasks.
		self.Tasks:PauseLayout();
		self.Tasks:SetContentPadding(0, 4, 0, 4);
		self.Tasks:ClearWidgets();
		self.Tasks:Show();
		parent:OnTasksRefreshed(self.Tasks, item.Key, self.CurrentTab);
		if(#(self.Tasks.Widgets) == 0) then
			self.Tasks:SetWidth(1);
		else
			self.Tasks:SetWidth(self.Tasks:GetWidth() + 1);
		end
		self.Tasks:ResumeLayout();

		-- Get tab offset.
		local offset = math.max(1, math.min(#(item.Tabs), self.CurrentTab));
		self.TabR:SetShown(offset > 1);

		-- And show tabs.
		for i = 1, math.max(#(self.Tabs), #(item.Tabs)) do
			-- Do we need a tab here or not?
			if(i > #(item.Tabs)) then
				self.Tabs[i]:Hide();
			else
				-- Need a tab?
				if(not self.Tabs[i]) then
					-- Need a tab.
					local tab = PowerAuras:Create("ListInlayTab", self, i, 0);
					self.Tabs[i] = tab;
				end

				-- Showing this one?
				if(offset == i) then
					-- Position.
					if(offset == i) then
						self.Tabs[i]:SetPoint("BOTTOMRIGHT", -22, 1);
					else
						self.Tabs[i]:SetPoint(
							"BOTTOMRIGHT", self.Tabs[i - 1], "BOTTOMLEFT", 1, 0
						);
					end

					-- We'll need to attach the left scroll button.
					self.TabL:SetShown(i < #(item.Tabs));
					self.TabL:SetPoint(
						"BOTTOMRIGHT", self.Tabs[i], "BOTTOMLEFT", -2, 1
					);

					-- Initialise and show.
					self.Tabs[i]:Initialise(self, i);
					self.Tabs[i]:SetText(item.Tabs[i]);
					self.Tabs[i]:Show();
				else
					self.Tabs[i]:Hide();
				end
			end
		end
	else
		self.Border:SetVertexColor(0.3, 0.3, 0.3);
		-- Kill tasks.
		self.Tasks:PauseLayout();
		self.Tasks:ClearWidgets();
		self.Tasks:Hide();
		self.Tasks:ResumeLayout();

		-- Kill tabs.
		self.TabL:Hide();
		self.TabR:Hide();
		for i = 1, #(self.Tabs) do
			self.Tabs[i]:Hide();
		end
	end

	-- Reposition the border if needed.
	self.Border:ClearAllPoints();
	if(parent.Pane:IsShown()) then
		self.Border:SetPoint("TOPLEFT", 0, 7);
		self.Border:SetPoint("TOPRIGHT", 0, 7);
	else
		self.Border:SetPoint("BOTTOMLEFT", 0, 0);
		self.Border:SetPoint("BOTTOMRIGHT", 0, 0);
	end
end

--- Returns the current tab index.
function InlayItem:GetCurrentTab()
	return self.CurrentTab;
end

--- OnClick script handler.
function InlayItem:OnClick()
	PlaySound("UChatScrollButton");
	self:SetChecked(not self:GetChecked());
	self:GetParent():SetCurrentItem(self.Key);
end

--- Recycles the item.
function InlayItem:Recycle()
	-- Recycle the tasks/tools.
	self.Tasks:PauseLayout();
	self.Tasks:ClearWidgets();
	self.Tasks:Hide();
	self.Tasks:ResumeLayout();
	-- Hide the tabs.
	for i = 1, #(self.Tabs) do
		self.Tabs[i]:Hide();
	end
	-- Continue as normal.
	base(self);
end

--- Reusable tab widget for the ListInlay.
local InlayTab = PowerAuras:RegisterWidget("ListInlayTab", "ReusableWidget");

--- Constructs/recycles an instance of the class.
function InlayTab:New()
	local frame = base(self);
	if(not frame) then
		-- Create new instance.
		frame = CreateFrame("CheckButton", nil, UIParent);

		frame.Text = frame:CreateFontString(nil, "OVERLAY");
		frame.Text:SetSize(0, 23);
		frame.Text:SetPoint("LEFT", 4, -1);
		frame.Text:SetPoint("RIGHT", -4, -1);
		frame.Text:SetWordWrap(false);
		frame:SetFontString(frame.Text);

		-- Style the button as needed.
		frame:SetSize(136, 31);
		frame:SetNormalFontObject(GameFontNormal);
		frame:SetHighlightFontObject(GameFontHighlight);
		frame:SetDisabledFontObject(GameFontHighlight);

		-- Background left.
		frame.TabBgL = frame:CreateTexture(nil, "BACKGROUND");
		frame.TabBgL:SetSize(1, 31);
		frame.TabBgL:SetTexture([[Interface\Buttons\WHITE8x8]]);
		frame.TabBgL:SetPoint("BOTTOMLEFT", 0, 0);
		frame.TabBgL:SetGradientAlpha(
			"VERTICAL", 0.3, 0.3, 0.3, 0.75, 0.3, 0.3, 0.3, 0
		);

		-- Background middle.
		frame.TabBgM = frame:CreateTexture(nil, "BACKGROUND");
		frame.TabBgM:SetSize(134, 31);
		frame.TabBgM:SetTexture([[Interface\Buttons\WHITE8x8]]);
		frame.TabBgM:SetPoint("BOTTOMLEFT", 1, 0);
		frame.TabBgM:SetPoint("BOTTOMRIGHT", -1, 0);
		frame.TabBgM:SetGradientAlpha("VERTICAL", 0, 0, 0, 0.75, 0, 0, 0, 0);

		-- Background right.
		frame.TabBgR = frame:CreateTexture(nil, "BACKGROUND");
		frame.TabBgR:SetSize(1, 31);
		frame.TabBgR:SetTexture([[Interface\Buttons\WHITE8x8]]);
		frame.TabBgR:SetPoint("BOTTOMRIGHT", 0, 0);
		frame.TabBgR:SetGradientAlpha(
			"VERTICAL", 0.3, 0.3, 0.3, 0.75, 0.3, 0.3, 0.3, 0
		);
	end
	return frame;
end

--- Initialises an instance of the widget.
-- @param parent    The parent of the tab.
-- @param index     The index of the tab.
function InlayTab:Initialise(parent, index)
	-- Initialise the frame.
	self:SetParent(parent);
	self:SetChecked(parent.CurrentTab == index);
	self:SetEnabled(parent.CurrentTab ~= index);
	self.TabIndex = index;
	self.TabKey = (parent.Key);
	self.TabBgL:SetShown(parent.CurrentTab ~= index + 1);
	self.TabBgR:SetShown(index == 0 or self:GetChecked());
end

--- OnClick script handler for the tab.
function InlayTab:OnClick()
	PlaySound("UChatScrollButton");
	self:GetParent().CurrentTab = self.TabIndex;
	self:GetParent():GetParent():SetCurrentItem(self.TabKey);
end

--- Recycles the tab widget.
function InlayTab:Recycle()
	self.TabIndex = nil;
	self.TabKey = nil;
	self:SetText("");
	base(self);
end

--- Updates the checked state of the button.
-- @param state The state to set.
function InlayTab:SetChecked(state)
	self:__SetChecked(state);
	if(state) then
		self.TabBgL:SetGradientAlpha(
			"VERTICAL", 1.0, 0.8, 0.0, 0.75, 1.0, 0.8, 0.0, 0
		);
		self.TabBgR:SetGradientAlpha(
			"VERTICAL", 1.0, 0.8, 0.0, 0.10, 1.0, 0.8, 0.0, 0
		);
	else
		self.TabBgL:SetGradientAlpha(
			"VERTICAL", 0.3, 0.3, 0.3, 0.75, 0.3, 0.3, 0.3, 0
		);
		self.TabBgR:SetGradientAlpha(
			"VERTICAL", 0.3, 0.3, 0.3, 0.10, 0.3, 0.3, 0.3, 0
		);
	end
end

--- Updates the text on the tab.
-- @param text The text to display.
function InlayTab:SetText(text)
	self:__SetText(tostring(text));
	-- Fix the tab width.
	self:SetWidth(136);
end