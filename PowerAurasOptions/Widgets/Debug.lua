-- Lock down local environment.
local PowerAuras = _G["PowerAuras"];
setfenv(1, PowerAuras);

--- Debugger window widget.
local DebugWindow = PowerAuras:RegisterWidget("DebugWindow", "Window");

--- Constructs a new instance of the widget.
function DebugWindow:New(parent)
	-- Construct the window.
	local frame = base(self, parent, "PowerAurasGUIProfiler");
	-- Add our tab frame.
	frame.Tabs = PowerAuras:Create("TabFrame", frame);
	frame.Tabs:SetPoint("TOPLEFT", 12, -55);
	frame.Tabs:SetPoint("BOTTOMRIGHT", -12, 12);
	-- Construct the tabs and their frames.
	local debug = not not PowerAuras.GetDebugLog;
	if(debug) then
		frame.Log = PowerAuras:Create("DebugLog", frame);
		frame.Log:SetAllPoints(frame.Tabs);
		frame.Log:SetBackdrop(nil);
	end
	frame.Profiler = PowerAuras:Create("DebugProfiler", frame);
	frame.Profiler:SetAllPoints(frame.Tabs);
	frame.Profiler:SetBackdrop(nil);
	-- Add tabs to list.
	if(debug) then
		frame.Tabs:AddTab(frame.Log, "Log",
			[[Interface\HelpFrame\HelpIcon-Bug]]);
	end
	frame.Tabs:AddTab(frame.Profiler, "Profiler",
		[[Interface\HelpFrame\HelpIcon-ReportLag]]);
	-- Also add a disabled checkbox giving the user our debug state.
	frame.Debug = PowerAuras:Create("Checkbox", frame);
	frame.Debug:SetPoint("BOTTOMRIGHT", frame.Tabs, "TOPRIGHT", -8, 0);
	frame.Debug:SetSize(92, 24);
	frame.Debug:SetText(L["DebuggerLogHeader"]);
	frame.Debug:SetChecked(debug);
	frame.Debug:Disable();
	-- Return the window.
	return frame;
end

--- Initialises the widget.
function DebugWindow:Initialise()
	-- Size, anchor and hide the frame.
	self:SetSize(720, 480);
	self:SetPoint("CENTER");
	self:SetTitle("Power Auras %s",
		GetAddOnMetadata("PowerAuras", "Version"):sub(1, 3));
	self:Hide();
	-- Close on escape key. Hence the need for a name.
	tinsert(UISpecialFrames, self:GetName());
end

--- OnHide script handler. Plays window sounds.
function DebugWindow:OnHide()
	PlaySound("igMainMenuClose");
end

--- OnShow script handler. Plays window sounds.
function DebugWindow:OnShow()
	PlaySound("igCharacterInfoTab");
end

--- Logging tool for the debugger.
local Log = PowerAuras:RegisterWidget("DebugLog", "ScrollFrame");

--- Initialises the log, registering callbacks and setting up child widgets.
function Log:Initialise()
	-- Verify that logging is enabled.
	if(not PowerAuras.GetDebugLog) then
		-- Add a simple font string notifying the user of this.
		self.Message = PowerAuras:Create("Label", self);
		self.Message:SetAllPoints(self);
		self.Message:SetFontObject(GameFontNormalLarge);
		self.Message:SetText(L["DebuggerLogNotEnabled"]);
	else
		-- Connect to the OnDebugLogUpdated callback.
		self:ConnectCallback(PowerAuras.OnDebugLogUpdated, self.PerformLayout);
		-- Storage for visible lines in the log.
		self.LineWidgets = {};
	end
end

--- Performs a layout pass on the log, showing the necessary items in the
--  scroll frame.
function Log:PerformLayout()
	-- Skip if paused, or if logging isn't enabled.
	if(not base(self) or self.Message) then
		return;
	end
	-- Get the debug log.
	local log = PowerAuras:GetDebugLog();
	-- Determine visible lines.
	local lines = math.floor(math.max(0, ((self:GetHeight() - 8) / 27)));
	local linesMax = math.max(0, #(log) - lines);
	-- Fix scroll ranges if necessary.
	local _, max = self:GetScrollRange();
	if(max ~= linesMax) then
		self:SetScrollRange(0, linesMax);
		if(self:GetScrollOffset() == max) then
			-- Autoscroll to bottom.
			self:SetScrollOffset(select(2, self:GetScrollRange()));
		else
			return;
		end
	end
	-- Recycle existing widgets.
	for i = #(self.LineWidgets), 1, -1 do
		tremove(self.LineWidgets):Recycle();
	end
	-- Construct widgets for all visible lines.
	local offset = self:GetScrollOffset();
	local rOfs = (self.ScrollBar:IsShown() and -24 or -20);
	for i = offset + 1, math.min(#(log), offset + lines) do
		-- Create widget.
		local widget = PowerAuras:Create("DebugLogItem", self, i, log[i]);
		widget:SetPoint("TOPLEFT", 4, -4 - ((i - offset - 1) * 27));
		widget:SetPoint("TOPRIGHT", rOfs, -4 - ((i - offset - 1) * 27));
		widget:SetHeight(27);
		tinsert(self.LineWidgets, widget);
	end
end

--- Item widget for the debug log.
local LogItem = PowerAuras:RegisterWidget("DebugLogItem", "Label");

--- Initialises the item, setting the displayed text and data.
-- @param parent The parent frame of the item.
-- @param id     The index of the item in the log.
-- @param data   The line data to display. Includes the stack trace for
--               our tooltip.
function LogItem:Initialise(parent, id, data)
	-- First, make sure we have our background texture.
	if(not self.Background) then
		self.Background = self:CreateTexture(nil, "BACKGROUND");
		self.Background:SetAllPoints(self);
		self.Background:SetTexture(0.9, 0.9, 1);
		self.Background:SetAlpha(0.1);
		self.Background:Hide();
	end
	-- Even rows have the background visible.
	if((id % 2) == 0) then
		self.Background:Show();
	else
		self.Background:Hide();
	end
	-- Add our filter button.
	if(not self.Filter) then
		self.Filter = CreateFrame("Button", nil, self);
		self.Filter:SetSize(16, 16);
		self.Filter:SetPoint("RIGHT", -24, 0);
		self.Filter:SetAlpha(0.5);
		self.Filter:SetNormalTexture(
			[[Interface\Buttons\UI-GroupLoot-Pass-Up]]
		);
		self.Filter:GetNormalTexture():ClearAllPoints();
		self.Filter:GetNormalTexture():SetPoint("CENTER", 0, 0);
		self.Filter:GetNormalTexture():SetSize(16, 16);
		self.Filter:SetScript("OnClick", self.OnButtonClick);
		self.Filter:SetScript("OnEnter", self.OnButtonEnter);
		self.Filter:SetScript("OnLeave", self.OnButtonLeave);
		self.Filter:SetScript("OnMouseDown", self.OnButtonMouseDown);
		self.Filter:SetScript("OnMouseUp", self.OnButtonMouseUp);
	end
	-- And a copy button.
	if(not self.Copy) then
		self.Copy = CreateFrame("Button", nil, self);
		self.Copy:SetSize(16, 16);
		self.Copy:SetPoint("RIGHT", -4, 0);
		self.Copy:SetAlpha(0.5);
		self.Copy:SetNormalTexture(
			[[Interface\Buttons\UI-GuildButton-PublicNote-Up]]
		);
		self.Copy:GetNormalTexture():ClearAllPoints();
		self.Copy:GetNormalTexture():SetPoint("CENTER", 0, 0);
		self.Copy:GetNormalTexture():SetSize(16, 16);
		self.Copy:SetScript("OnClick", self.OnButtonClick);
		self.Copy:SetScript("OnEnter", self.OnButtonEnter);
		self.Copy:SetScript("OnLeave", self.OnButtonLeave);
		self.Copy:SetScript("OnMouseDown", self.OnButtonMouseDown);
		self.Copy:SetScript("OnMouseUp", self.OnButtonMouseUp);
	end
	-- Set the line text.
	self:SetJustifyH("LEFT");
	self:SetID(id);
	self.Line = data;
	self:SetText(
		("|cFF666666[%s]: |r|cFFFFFFFF%s|r"):format(
			date("%X", data["Time"]),
			tostring(data[1]):format(tostringall(unpack(data, 2)))
		)
	);
end

--- Script handler for the OnClick event.
function LogItem:OnButtonClick()
	if(self == self:GetParent().Filter) then
		PowerAuras:RegisterDebugFilter(self:GetParent().Line[1]);
	else
		PowerAuras:CopyDebugMessage(self:GetParent():GetID());
	end
end

--- Script handler for the OnEnter event. Changes the texture alpha.
-- @remarks self points to a button, not to the log item.
function LogItem:OnButtonEnter()
	self:SetAlpha(1.0);
	-- Also show a tooltip based on the button.
	GameTooltip:ClearLines();
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	if(self == self:GetParent().Filter) then
		-- Filter button.
		GameTooltip:AddLine(L["DebuggerLogFilterTitle"]);
		GameTooltip:AddLine(
			L("DebuggerLogFilterText", self:GetParent().Line[1]), 1, 1, 1, true
		);
	else
		-- Copy button.
		GameTooltip:AddLine(L["DebuggerLogCopyTitle"]);
		GameTooltip:AddLine(L["DebuggerLogCopyText"], 1, 1, 1, true);
	end
	GameTooltip:Show();
end


--- Script handler for the OnLeave event. Changes the texture alpha.
-- @remarks self points to a button, not to the log item.
function LogItem:OnButtonLeave()
	self:SetAlpha(0.5);
	GameTooltip:ClearLines();
	GameTooltip:Hide();
end


--- Script handler for the OnMouseDown event. Changes the texture position.
-- @remarks self points to a button, not to the log item.
function LogItem:OnButtonMouseDown()
	self:GetNormalTexture():SetPoint("CENTER", 1, -1);
end


--- Script handler for the OnMouseUp event. Changes the texture position.
-- @remarks self points to a button, not to the log item.
function LogItem:OnButtonMouseUp()
	self:GetNormalTexture():SetPoint("CENTER", 0, 0);
end

--- Called when the tooltip is shown for this item. Adds text to it.
-- @param tooltip The tooltip instance to modify.
function LogItem:OnTooltipShow(tooltip)
	-- Add lines to tooltip.
	local line = self.Line;
	tooltip:SetOwner(self, "ANCHOR_RIGHT");
	tooltip:AddDoubleLine(
		date("%X", line["Time"]), line["TimeMs"], 0.4, 0.4, 0.4, 0.4, 0.4, 0.4
	);
	tooltip:AddLine(L["DebuggerLogTH1"]);
	tooltip:AddLine(tostring(line[1]):format(tostringall(unpack(line, 2))),
		1, 1, 1, true);
	tooltip:AddLine(L["DebuggerLogTH2"]);
	tooltip:AddLine(line["Stack"] or _G["NONE"], 1, 1, 1);
	tooltip:AddLine(L["DebuggerLogTH3"]);
	tooltip:AddLine(line["Locals"] or _G["NONE"], 1, 1, 1);
end

--- Profiling tool for the debugger.
local Profiler = PowerAuras:RegisterWidget("DebugProfiler", "BorderedFrame");

--- Initialises the profiler, creating the child widgets for the frame.
function Profiler:Initialise()
	-- Construct child widgets, start with labels.
	self.LabelCPU = PowerAuras:Create("Label", self);
	self.LabelCPU:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 8, 31);
	self.LabelCPU:SetPoint("BOTTOMRIGHT", self, "BOTTOM", -2, 8);
	self.LabelCPU:SetText(L("DebuggerProfilerCPU", 0, 0));
	self.LabelMem = PowerAuras:Create("Label", self);
	self.LabelMem:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -8, 31);
	self.LabelMem:SetPoint("BOTTOMLEFT", self, "BOTTOM", 2, 8);
	self.LabelMem:SetText(L("DebuggerProfilerMem", 0, "kb"));
	-- Add option checkboxes.
	self.CheckCVar = PowerAuras:Create("Checkbox", self);
	self.CheckCVar:SetPoint("TOPLEFT", 8, -10);
	self.CheckCVar:SetSize(150, 24);
	self.CheckCVar:SetText(L["DebuggerProfilerCVar"]);
	self.CheckCVar:SetChecked(GetCVarBool("scriptProfile"));
	self.CheckCVar.OnValueUpdated:Connect(function(self)
		SetCVar("scriptProfile", self:GetChecked() and 1 or 0);
		ReloadUI();
	end);
	self.CheckSubs = PowerAuras:Create("Checkbox", self);
	self.CheckSubs:SetPoint("TOPLEFT", 162, -10);
	self.CheckSubs:SetSize(150, 24);
	self.CheckSubs:SetText(L["DebuggerProfilerSubs"]);
	self.CheckSubs.OnValueUpdated:Connect(function()
		self.NextUpdate = 0;
	end);
	-- Filter dropdown.
	self.ProfilerFilter = PowerAuras:Create("DropdownButton", self);
	self.ProfilerFilter:SetPoint("TOPRIGHT", -8, -9);
	self.ProfilerFilter:SetText(L["DebuggerProfilerFilters"]);
	self.ProfilerFilter:SetSize(150, 26);
	self.ProfilerFilter.OnMenuRefreshed:Connect(self.OnFilterMenuRefreshed);
	-- Now add the table widget.
	self.Table = PowerAuras:Create("Table", self);
	self.Table:SetPoint("TOPLEFT", self, 8, -40);
	self.Table:SetPoint("BOTTOMRIGHT", self, -8, 35);
	self.Table:PauseLayout();
	self.Table:AddColumn(L["DebuggerProfilerTH1"], 0.3);
	self.Table:AddColumn(L["DebuggerProfilerTH2"], 0.125);
	self.Table:AddColumn(L["DebuggerProfilerTH3"], 0.15, "%.2f");
	self.Table:AddColumn(L["DebuggerProfilerTH4"], 0.15, "%.2fms");
	self.Table:AddColumn(L["DebuggerProfilerTH5"], 0.15, "%.2fms");
	self.Table:AddColumn(L["DebuggerProfilerTH6"], 0.125, "%.2f%%");
	self.Table:SetSortedColumn(5, true);
	self.Table:ResumeLayout();
	-- Function filter states.
	self.FilterAutoFuncs = false;
	self.FilterScriptFuncs = true;
	self.FilterActionFuncs = true;
	self.FilterProviderFuncs = true;
	self.FilterDisplayFuncs = true;
	-- Throttle table updates.
	self.NextUpdate = 0;
end

--- Called when Filters dropdown menu is refreshed. Populates the menu.
-- @param menu  The menu instance.
-- @remarks self points to the dropdown button instance, not the profiler.
function Profiler:OnFilterMenuRefreshed(menu)
	-- Add items.
	local parent = self:GetParent();
	menu:AddCheckItem("FilterScriptFuncs", parent.FilterScriptFuncs,
		L["DebuggerProfilerFilterScriptFuncs"]);
	menu:AddCheckItem("FilterActionFuncs", parent.FilterActionFuncs,
		L["DebuggerProfilerFilterActionFuncs"]);
	menu:AddCheckItem("FilterDisplayFuncs", parent.FilterDisplayFuncs,
		L["DebuggerProfilerFilterDisplayFuncs"]);
	menu:AddCheckItem("FilterProviderFuncs", parent.FilterProviderFuncs,
		L["DebuggerProfilerFilterProviderFuncs"]);
	menu:AddCheckItem("FilterAutoFuncs", parent.FilterAutoFuncs,
		L["DebuggerProfilerFilterAutoFuncs"]);
	-- Connect ValueUpdated handler.
	menu.OnValueUpdated:Disconnect(parent.OnFilterValueUpdated);
	menu.OnValueUpdated:Connect(parent.OnFilterValueUpdated);
end

--- Called when the selected values are updated in the Filters dropdown menu.
-- @param key   The key of the updated item.
-- @param state The checked state of the item.
-- @remarks self points to the menu instance, not the dropdown or profiler.
function Profiler:OnFilterValueUpdated(key, state)
	-- Update the state on the parent (the profiler).
	local profiler = self:GetTopLevelParent():GetParent();
	profiler[key] = state;
	profiler.NextUpdate = 0;
	-- Refresh the menu.
	self:RefreshMenu();
end

--- Adds a row to the profiler table for the given function.
-- @param key  The name of the function to display.
-- @param func The function to be profiled.
function Profiler:AddFunction(key, func)
	-- Get profiling data for this function.
	local subs = not not self.CheckSubs:GetChecked();
	local usage, calls = GetFunctionCPUUsage(func, subs);
	usage, calls = math.max(0, usage), calls;
	self.Table:AddRow(
		key,
		calls,
		(calls / math.floor(GetTime() - PowerAuras.StartTime)),
		(usage / math.max(1, calls)),
		usage,
		(usage / math.max(1, GetAddOnCPUUsage("PowerAuras"))) * 100
	);
end

--- OnUpdate script handler. Updates the table with function stats.
function Profiler:OnUpdate()
	-- Skip if not showing.
	if(not self:IsShown()) then
		return;
	end
	-- Time to update the profiler?
	if(self.NextUpdate <= GetTime()) then
		-- Next update is a 1 sec later.
		self.NextUpdate = GetTime() + 1;
		-- Update addon statistics and clear the table.
		UpdateAddOnCPUUsage("PowerAuras");
		UpdateAddOnMemoryUsage("PowerAuras");
		self.Table:PauseLayout();
		self.Table:ClearRows();
		-- Collect information on all functions.
		if(self.FilterAutoFuncs) then
			for key, func in pairs(PowerAuras) do
				if(type(func) == "function") then
					self:AddFunction(key, func);
				end
			end
		end
		-- Script handlers.
		if(self.FilterScriptFuncs) then
			local script = PowerAuras.Frame:GetScript("OnEvent");
			if(script) then
				self:AddFunction("OnEvent", script);
			end
			local script = PowerAuras.Frame:GetScript("OnUpdate");
			if(script) then
				self:AddFunction("OnUpdate", script);
			end
		end
		-- Actions.
		if(self.FilterActionFuncs) then
			for id, func in pairs(PowerAuras:GetLoadedActions()) do
				self:AddFunction(L("ActionID", id), func);
			end
		end
		-- Providers.
		if(self.FilterProviderFuncs) then
			for id, provider in pairs(PowerAuras:GetLoadedProviders()) do
				for svc, func in pairs(provider) do
					if(type(func) == "function") then
						self:AddFunction(L("ProviderIDSvc", id, svc), func);
					end
				end
			end
		end
		-- Displays.
		if(self.FilterDisplayFuncs) then
			for id, display in pairs(PowerAuras:GetLoadedDisplays()) do
				for key, func in pairs(display) do
					if(type(func) == "function") then
						self:AddFunction(L("DisplayIDFunc", id, key), func);
					end
				end
			end
		end
		-- Update CPU usage label.
		local totalCPU = GetScriptCPUUsage();
		local addonCPU = GetAddOnCPUUsage("PowerAuras");
		self.LabelCPU:SetText(L(
			"DebuggerProfilerCPU",
			addonCPU,
			(addonCPU / math.max(1, totalCPU)) * 100
		));
		-- Memory usage label.
		local mem = GetAddOnMemoryUsage("PowerAuras");
		self.LabelMem:SetText(L(
			"DebuggerProfilerMem",
			mem > 1024 and mem / 1024 or mem,
			mem > 1024 and "mb" or "kb"
		));
		-- Resume the layout, this will restore the rows for us.
		self.Table:ResumeLayout();
	end
end