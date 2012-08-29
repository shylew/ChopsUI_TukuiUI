-- Lock down local environment.
local PowerAuras = _G["PowerAuras"];
setfenv(1, PowerAuras);

--- Table widget. Contains a set of data that may be sorted via columns.
local Table = PowerAuras:RegisterWidget("Table", "ScrollFrame");

--- Constructs a new instance of the widget.
-- @param parent The parent of the frame.
function Table:New(parent)
	-- Construct the frame.
	local frame = base(self, parent);
	-- Add column/row storage tables.
	frame.Columns = {};
	frame.Rows = {};
	frame.SortedRows = {};
	-- Table widget storage.
	frame.ColumnWidgets = {};
	frame.RowWidgets = {};
	-- Sorting data.
	frame.SortedColumn = 1;
	frame.SortedDescending = false;
	frame.SortPending = false;
	-- Row click callback.
	frame.OnRowClicked = PowerAuras.Callback();
	frame.OnRowTooltip = PowerAuras.Callback();
	-- Default sort function. Sorts by the specified column, and then
	-- in ascending order by the first column.
	function frame.Sorter(a, b)
		local col, desc = frame.SortedColumn + 1, frame.SortedDescending;
		return (desc and a[col] > b[col]) or (not desc and a[col] < b[col])
			or (a[col] == b[col] and a[2] < b[2]);
	end
	-- Return the frame.
	return frame;
end

--- Adds a column to the table.
-- @param text   The text of the column.
-- @param width  Relative width of the column.
-- @param format The format of any values displayed in this column. If
--               a string, then string.format will be called. If this is a
--               function, it will receive and must return the value to be
--               shown. If omitted, the value will be shown as normal.
-- @param sort   Optional custom sorting function for values in this
--               column.
-- @return The ID number of the column.
-- @remarks This function will throw an error if adding a column to a table
--          that already has rows.
function Table:AddColumn(text, width, format, sort)
	assert(#(self.Rows) == 0, "Cannot add columns to a table with rows.");
	tinsert(self.Columns, { text, format, sort or self.Sorter, width });
	self:PerformLayout();
	return #(self.Columns);
end

--- Adds a row to the table.
-- @param ... The values for each column in the table.
-- @return The ID number of the row. This is not affected by sorting.
-- @remarks If the number of passed arguments does not match the number of
--          columns, an error will be thrown.
function Table:AddRow(...)
	-- Verify arg count.
	assert(select("#", ...) == #(self.Columns),
		"Number of values does not match number of columns.");
	-- Add row table.
	tinsert(self.Rows, { #(self.Rows) + 1, ... });
	tinsert(self.SortedRows, self.Rows[#(self.Rows)]);
	self:Sort();
	return #(self.Rows);
end

--- Clears all of the columns in the table.
function Table:ClearColumns()
	self:PauseLayout();
	for i = #(self.Columns), 1, -1 do
		self:RemoveColumn(i);
	end
	self:ResumeLayout();
end

--- Clears all of the rows in the table.
function Table:ClearRows()
	self:PauseLayout();
	for i = #(self.Rows), 1, -1 do
		self:RemoveRow(i);
	end
	self:ResumeLayout();
end

--- Returns the index of the sorted column, and its direction.
-- @return An index for the column, and true if sorted in descending order.
function Table:GetSortedColumn()
	return self.SortedColumn, self.SortedDescending;
end

--- Removes a column from the table.
-- @param id The ID of the column to remove.
-- @remarks Throws an error if you attempt to remove a column from a table with
--          rows present.
function Table:RemoveColumn(id)
	-- Check if row count == 0.
	assert(#(self.Rows) == 0, "Cannot remove columns from a table with rows.");
	-- Remove row.
	tremove(self.Columns, id);
	-- If we were sorting by this column, fix it.
	if(id == self.SortedColumn) then
		self:SetSortedColumn(
			math.max(1, #(self.Columns)),
			self.SortedDescending
		);
	else
		self:PerformLayout();
	end
end

--- Removes a row from the table.
-- @param id The ID of the row to remove.
-- @remarks Throws an error if you attempt to remove a non-existant row.
function Table:RemoveRow(id)
	-- Ensure row exists.
	assert(self.Rows[id], "Cannot remove rows that don't exist.");
	-- Remove from lists.
	local row = tremove(self.Rows, id);
	for i = 1, #(self.SortedRows) do
		if(self.SortedRows[i] == row) then
			tremove(self.SortedRows, i);
			break;
		end
	end
	-- Resort the table.
	self:Sort();
end

--- Performs the layout of the frame, showing/hiding and styling rows as
--  needed.
function Table:PerformLayout()
	-- Skip if paused.
	if(not base(self)) then
		return;
	end
	-- Sort if needed.
	if(self.SortPending) then
		self.SortPending = false;
		return self:Sort();
	end
	-- Calculate number of visible lines.
	local lines = math.floor(math.max(0, ((self:GetHeight() - 26) / 24)));
	local linesMax = math.max(0, #(self.Rows) - lines);
	-- Fix scroll ranges if necessary.
	local _, max = self:GetScrollRange();
	if(max ~= linesMax) then
		return self:SetScrollRange(0, linesMax);
	end
	-- Recycle existing widgets.
	for i = #(self.RowWidgets), 1, -1 do
		tremove(self.RowWidgets):Recycle();
	end
	for i = #(self.ColumnWidgets), 1, -1 do
		tremove(self.ColumnWidgets):Recycle();
	end
	-- Create and position column widgets.
	local sorted, dir = self:GetSortedColumn();
	local fWidth = (self:GetWidth() - 3 + ((#(self.Columns) - 1) * 2));
	fWidth = fWidth - (self.ScrollBar:IsShown() and 20 or 0);
	for i = 1, #(self.Columns) do
		-- Extract column data.
		local data = self.Columns[i];
		local text, width = data[1], (fWidth * data[4]);
		local sort = (i == sorted);
		-- Construct and size widget.
		local col = PowerAuras:Create("TableHeader", self, i, text, sort, dir);
		tinsert(self.ColumnWidgets, col);
		col:SetWidth(width);
		-- Anchor to previous column if possible.
		local prev = self.ColumnWidgets[i - 1];
		if(prev) then
			col:SetPoint("TOPLEFT", prev, "TOPRIGHT", -2, 0);
		else
			col:SetPoint("TOPLEFT", self, "TOPLEFT", 1, -2);
		end
	end
	-- Create and position rows.
	local offset = self:GetScrollOffset();
	for i = offset + 1, math.min(#(self.Rows), offset + lines) do
		-- Extract row data.
		local data = self.SortedRows[i];
		local cols = self.ColumnWidgets;
		local colData = self.Columns;
		-- Construct and position widget.
		local row = PowerAuras:Create("TableRow", self, i, cols, colData, 
			unpack(data));
		tinsert(self.RowWidgets, row);
		local rOfs = -4 - (self.ScrollBar:IsShown() and 20 or 0);
		row:SetPoint("TOPLEFT", self, 4, -22 - ((i - offset - 1) * 24));
		row:SetPoint("TOPRIGHT", self, rOfs, -22 - ((i - offset - 1) * 24));
	end
end

--- Recycles the table, clearing all rows and columns.
function Table:Recycle()
	self:PauseLayout();
	self:ClearRows();
	self:ClearColumns();
	self:ResumeLayout();
	base(self);
end

--- Sorts the table, and updates the layout.
function Table:Sort()
	if(not self.LayoutPaused or self.LayoutPaused == 0) then
		table.sort(self.SortedRows, self.Columns[self.SortedColumn][3]);
		self:PerformLayout();
	else
		self.SortPending = true;
	end
end

--- Sorts the table by the specified column.
-- @param id   The ID of the column to sort by.
-- @param desc True if to sort in descending order.
function Table:SetSortedColumn(id, desc)
	self.SortedColumn = math.max(1, math.min(#(self.Columns), id));
	self.SortedDescending = not not desc;
	self:Sort();
end

--- Reusable table header widget. Provides a clickable column for sorting.
local TableHeader = PowerAuras:RegisterWidget("TableHeader", "ReusableWidget");

--- Recycles or constructs an instance of the widget class.
function TableHeader:New()
	-- Recycle or create.
	local frame = base(self);
	if(not frame) then
		-- Construct a button.
		frame = CreateFrame("Button", nil, UIParent);
		frame:SetSize(0, 24);
		-- Add the text and highlight textures first.
		local text = frame:CreateFontString(nil, "OVERLAY");
		text:SetPoint("TOPLEFT", 8, 0);
		text:SetPoint("BOTTOMRIGHT", -32, 0);
		text:SetJustifyH("LEFT");
		text:SetWordWrap(false);
		frame:SetFontString(text);
		frame:SetNormalFontObject(GameFontHighlightSmall);
		frame:SetHighlightTexture([[Interface\HelpFrame\KnowledgeBaseButtton]]);
		frame:GetHighlightTexture():SetTexCoord(
			0.13085938, 0.63085938, 0.0078125, 0.203125
		);
		frame:GetHighlightTexture():ClearAllPoints();
		frame:GetHighlightTexture():SetPoint("TOPLEFT", 2, -4);
		frame:GetHighlightTexture():SetPoint("BOTTOMRIGHT", -2, 4);
		-- The background textures are bit different.
		frame.BgL = frame:CreateTexture(nil, "BACKGROUND");
		frame.BgL:SetTexture([[Interface\FriendsFrame\WhoFrame-ColumnTabs]]);
		frame.BgL:SetTexCoord(0, 0.078125, 0, 0.59375);
		frame.BgL:SetVertexColor(0.65, 0.65, 0.65, 1);
		frame.BgL:SetPoint("TOPLEFT");
		frame.BgL:SetSize(5, 19);
		frame.BgR = frame:CreateTexture(nil, "BACKGROUND");
		frame.BgR:SetTexture([[Interface\FriendsFrame\WhoFrame-ColumnTabs]]);
		frame.BgR:SetTexCoord(0.90625, 0.96875, 0, 0.59375);
		frame.BgR:SetVertexColor(0.65, 0.65, 0.65, 1);
		frame.BgR:SetPoint("TOPRIGHT");
		frame.BgR:SetSize(4, 19);
		frame.BgM = frame:CreateTexture(nil, "BACKGROUND");
		frame.BgM:SetTexture([[Interface\FriendsFrame\WhoFrame-ColumnTabs]]);
		frame.BgM:SetTexCoord(0.078125, 0.90625, 0, 0.59375);
		frame.BgM:SetVertexColor(0.65, 0.65, 0.65, 1);
		frame.BgM:SetPoint("LEFT", frame.BgL, "RIGHT");
		frame.BgM:SetPoint("RIGHT", frame.BgR, "LEFT");
		frame.BgM:SetSize(10, 19);
		-- Finally, set the arrow texture.
		local arrow = frame:CreateTexture(nil, "OVERLAY");
		arrow:SetTexture([[Interface\Minimap\MiniMap-PositionArrows]]);
		arrow:SetTexCoord(0, 1, 0, 0.5);
		arrow:SetSize(16, 16);
		arrow:SetPoint("TOPRIGHT", -6, -4);
		frame:SetNormalTexture(arrow);
	end
	-- Return the frame.
	return frame;
end

--- Initialises the widget, setting the parent, ID and text values.
-- @param parent The parent of the widget.
-- @param id     The ID of the column.
-- @param text   The text to display on the column.
-- @param sorted True if this column is sorted.
-- @param desc   True if this column is sorted in descending order.
function TableHeader:Initialise(parent, id, text, sorted, desc)
	-- Fix ID and parent.
	self:SetParent(parent);
	self:SetID(id);
	-- Update label.
	self:SetText(tostring(text));
	-- Hide or show the arrow based on our sorted args.
	if(not sorted) then
		self:GetNormalTexture():Hide();
		self:SetNormalFontObject(GameFontHighlightSmall);
	else
		self:GetNormalTexture():Show();
		self:SetNormalFontObject(GameFontNormalSmall);
		if(desc) then
			self:GetNormalTexture():SetTexCoord(0, 1, 0, 0.5);
		else
			self:GetNormalTexture():SetTexCoord(0, 1, 0.5, 1);
		end
	end
end

--- Called when the header is clicked. Updates the sorted column in the parent.
function TableHeader:OnClick()
	PlaySound("UChatScrollButton");
	local parent = self:GetParent();
	local old, dir = parent:GetSortedColumn();
	parent:SetSortedColumn(self:GetID(), (old == self:GetID() and not dir));
end

--- Recycles the widget, allowing it to be added to the reusable pool.
function TableHeader:Recycle()
	self:SetText(nil);
	self:SetID(0);
	base(self);
end

--- Reusable table row widget. Displays the data of a table.
local TableRow = PowerAuras:RegisterWidget("TableRow", "ReusableWidget");

--- Recycles or constructs an instance of the widget class.
function TableRow:New()
	-- Recycle or create.
	local frame = base(self);
	if(not frame) then
		-- Construct a frame.
		frame = CreateFrame("Button", nil, UIParent);
		frame:SetSize(0, 24);
		frame.FontStrings = {};
		-- Alternate rows have a background colour.
		frame.Bg = frame:CreateTexture(nil, "BACKGROUND");
		frame.Bg:SetAllPoints(frame);
		frame.Bg:SetTexture(0.9, 0.9, 1);
		frame.Bg:SetAlpha(0.1);
		frame.Bg:Hide();
		-- Highlight texture for the row.
		frame:SetHighlightTexture([[Interface\HelpFrame\KnowledgeBaseButtton]]);
		frame:GetHighlightTexture():SetTexCoord(
			0.13085938, 0.63085938, 0.0078125, 0.203125
		);
	end
	-- Return the frame.
	return frame;
end

--- Initialises the widget, setting the parent, ID and text values.
-- @param parent  The parent of the widget.
-- @param index   The sorted index of the row.
-- @param cols    The column widgets. Use these for anchoring.
-- @param colData Table of column data entries.
-- @param id      The index of thw row.
-- @param ...     The values to display in the columns.
function TableRow:Initialise(parent, index, cols, colData, id, ...)
	-- Fix ID and parent.
	self:SetID(id);
	self:SetParent(parent);
	if((index % 2) == 0) then
		self.Bg:Show();
	else
		self.Bg:Hide();
	end
	-- Add in the font strings.
	for i = 1, math.max(#(cols), #(self.FontStrings)) do
		-- Does this column exist?
		if(#(cols) >= i) then
			-- Font string need creating?
			if(not self.FontStrings[i]) then
				self.FontStrings[i] = self:CreateFontString(nil, "OVERLAY");
				self.FontStrings[i]:SetFontObject(GameFontHighlightSmall);
				self.FontStrings[i]:SetJustifyH("LEFT");
				self.FontStrings[i]:SetHeight(24);
				self.FontStrings[i]:SetWordWrap(false);
			end
			-- Position string.
			self.FontStrings[i]:ClearAllPoints();
			local colWidth = cols[i]:GetWidth();
			if(i > 1) then
				local fs = self.FontStrings[i - 1];
				self.FontStrings[i]:SetPoint("TOPLEFT", fs, "TOPRIGHT", 6, 0);
				self.FontStrings[i]:SetWidth(colWidth - 8);
			else
				self.FontStrings[i]:SetPoint("TOPLEFT", self, 2, 0);
				self.FontStrings[i]:SetWidth(colWidth - 8);
			end
			-- Set text and show.
			local format = colData[i][2];
			local text = select(i, ...);
			if(type(format) == "string") then
				self.FontStrings[i]:SetText(format:format(text));
			elseif(type(format) == "function") then
				self.FontStrings[i]:SetText(tostring(format(text)));
			else
				self.FontStrings[i]:SetText(tostring(text));
			end
			self.FontStrings[i]:Show();
		elseif(#(cols) < i) then
			-- Fontstring needs hiding, as this column isn't visible.
			self.FontStrings[i]:ClearAllPoints();
			self.FontStrings[i]:Hide();
		end
	end
	-- Disable the button if the number of connected OnRowClicked callbacks
	-- is 0.
	if(#(parent.OnRowClicked) == 0) then
		self:Disable();
	else
		self:Enable();
	end
end

--- OnClick script handler.
function TableRow:OnClick(button)
	PlaySound("UChatScrollButton");
	self:GetParent():OnRowClicked(self:GetID(), button);
end

--- Called when the tooltip for this widget should be shown.
-- @param tooltip The tooltip frame to use.
function TableRow:OnTooltipShow(tooltip)
	-- Position the tooltip.
	if(#(self:GetParent().OnRowTooltip) > 0) then
		tooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
		self:GetParent():OnRowTooltip(self:GetID(), tooltip);
	end
end