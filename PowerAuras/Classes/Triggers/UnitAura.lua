-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

-- Load modules.
local SharedChecks = PowerAuras:GetModules("SharedChecks");

-- Upvalue the check functions.
local CheckUnit = SharedChecks.CheckUnitAura;

--- Trigger class definition.
local UnitAura = PowerAuras:RegisterTriggerClass("UnitAura", {
	--- Dictionary of default parameters this trigger uses.
	Parameters = {
		Unit = PowerAuras:EncodeUnits("player"),
		Type = 1, -- 1 = Buff, 2 = Debuff.
		Matches = PowerAuras:EncodeMatch({
			-- Default settings at index #0, inherited if not specified.
			[0] = {
				-- Effect information.
				Effect = "<Buff/Debuff Name>",
				CastBy = "player",
				Stealable = false,
				-- Additional matching flags.
				Exact = false,
				IgnoreCase = true,
				Pattern = false,
				Tooltip = "",
				UseTooltip = false,
				-- Stacks matching.
				Count = 0,
				CountSource = 0,
				Operator = ">=",
			},
			-- Actual settings from #1 onwards.
			[1] = {
			},
		}),
	},
	--- Dictionary of events this trigger responds to.
	Events = {
		ARENA_OPPONENT_UPDATE = { "ArenaAura", "UnitAura" },
		GROUP_ROSTER_UPDATE = function(buffer)
			buffer.Triggers["UnitAura"] = true;
			if(IsInRaid()) then
				buffer.Triggers["RaidAura"] = true;
				buffer.Triggers["RaidPetAura"] = true;
			else
				buffer.Triggers["PartyAura"] = true;
				buffer.Triggers["PartyPetAura"] = true;
			end
			buffer.Triggers["GroupAura"] = true;
		end,
		INSTANCE_ENCOUNTER_ENGAGE_UNIT = { "BossAura", "UnitAura" },
		PLAYER_FOCUS_CHANGED = { "FocusAura", "UnitAura" },
		PLAYER_TARGET_CHANGED = function(buffer)
			-- If not in a raid, flag party for checks.
			buffer.Triggers["UnitAura"] = true;
			if(not IsInRaid()) then
				buffer.Triggers["GroupAura"] = true;
			end
			buffer.Triggers["TargetAura"] = true;
		end,
		UNIT_AURA = function(buffer, unit)
			-- Flag triggers based on unit.
			buffer.Triggers["UnitAura"] = true;
			if(unit == "player") then
				buffer.Triggers["PartyAura"] = true;
				buffer.Triggers["GroupAura"] = true;
				buffer.Triggers["PlayerAura"] = true;
			elseif(unit == "pet") then
				buffer.Triggers["PetAura"] = true;
			elseif(unit == "vehicle") then
				buffer.Triggers["VehicleAura"] = true;
			elseif(unit == "target") then
				buffer.Triggers["TargetAura"] = true;
			elseif(unit == "focus") then
				buffer.Triggers["FocusAura"] = true;
			elseif(unit ~= nil) then
				-- Likely a group unit.
				local match = unit:match("%a+");
				if(match == "party") then
					buffer.Triggers["PartyAura"] = true;
				elseif(match == "partypet") then
					buffer.Triggers["PartyPetAura"] = true;
				elseif(match == "raid") then
					buffer.Triggers["RaidAura"] = true;
				elseif(match == "raidpet") then
					buffer.Triggers["RaidPetAura"] = true;
				elseif(match == "arena") then
					buffer.Triggers["ArenaAura"] = true;
				elseif(match == "boss") then
					buffer.Triggers["BossAura"] = true;
				elseif(match == "group") then
					buffer.Triggers["GroupAura"] = true;
				end
			end
		end,
		UNIT_ENTERED_VEHICLE = { "VehicleAura", "UnitAura" },
		UNIT_EXITED_VEHICLE = { "VehicleAura", "UnitAura" },
		UNIT_PET = { "PetAura", "UnitAura" },
	},
	--- Dictionary of provider services required by this trigger type.
	Services = {
	},
	--- Dictionary of supported trigger > service conversions.
	ServiceMirrors = {
		Stacks  = "TriggerData",
		Text    = "TriggerData",
		Texture = "TriggerData",
		Timer   = "TriggerData",
	},
});

--- Constructs a new instance of the trigger and returns it.
-- @param parameters The parameters to construct the trigger from.
function UnitAura:New(parameters)
	-- Decode our matches parameter.
	local matches = PowerAuras:DecodeMatch(parameters["Matches"], true);
	local units = PowerAuras:DecodeUnits(parameters["Unit"]);
	-- Further initialise our matches.
	for i = 1, #(matches) do
		-- If ignoring case, convert to lowercase.
		if(matches[i].IgnoreCase) then
			matches[i].Effect = matches[i].Effect:lower();
		end
	end
	-- Turn the type into a filter string.
	local filter = (parameters["Type"] == 2 and "HARMFUL" or "HELPFUL");
	local start = 1;
	-- Return the trigger.
	local UnitAura = _G.UnitAura;
	return function(self, buffer, action, store)
		-- Process units.
		local result, unit, slot, index = PowerAuras:CheckUnits(
			units, CheckUnit, filter, matches, start
		);
		-- Store the index for faster rechecks.
		start = slot;
		if(result) then
			-- Get data to share with our source.
			local name, _, icon, v0, type, dur, exp, caster, steal,
				_, id, _, _, v1, v2, v3 = UnitAura(unit, slot, filter);
			-- Get match parameters.
			local match = matches[index];
			-- Store data in sensible slots.
			store.Texture        = icon;
			store.TimerStart     = ((exp or 2^31 - 1) - (dur or 0));
			store.TimerEnd       = (exp or 2^31 - 1);
			store.Stacks         = (match.CountSource == 0 and v0
					or match.CountSource == 1 and tonumber(v1)
					or match.CountSource == 2 and tonumber(v2)
					or match.CountSource == 3 and tonumber(v3)
					or 0);
			store.Text["name"]   = name;
			store.Text["icon"]   = ("|T%s:0:0|t"):format(icon);
			store.Text["count"]  = v0;
			store.Text["type"]   = type;
			store.Text["caster"] = caster;
			store.Text["id"]     = id;
			store.Text["tt1"]    = tonumber(v1) or 0;
			store.Text["tt2"]    = tonumber(v2) or 0;
			store.Text["tt3"]    = tonumber(v3) or 0;
		else
			store.Texture        = nil;
			store.TimerStart     = nil;
			store.TimerEnd       = nil;
			store.Stacks         = nil;
			store.Text["name"]   = "";
			store.Text["icon"]   = "";
			store.Text["count"]  = "";
			store.Text["type"]   = "";
			store.Text["caster"] = "";
			store.Text["id"]     = "";
			store.Text["tt1"]    = "";
			store.Text["tt2"]    = "";
			store.Text["tt3"]    = "";
		end
		-- Return the result.
		return result;
	end
end

--- Creates the controls for the basic activation editor frame.
-- @param frame The frame to apply controls to.
-- @param ... ID's to use for Get/SetParameter calls.
function UnitAura:CreateTriggerEditor(frame, ...)
	-- Match creation dialog.
	local matchBox = PowerAuras:Create("UnitAuraMatchBox", frame,
		"Trigger", ...);
	matchBox:SetUserTooltip("UnitAura_MatchDlg");
	matchBox:SetTitle(L["UnitAura_MatchDlg"]);
	matchBox:SetRelativeWidth(0.7);
	matchBox:SetPadding(4, 0, 2, 0);
	matchBox:SetText(PowerAuras:GetParameter("Trigger", "Matches", ...));
	matchBox:ConnectParameter("Trigger", "Matches", matchBox.SetText, ...);
	matchBox.OnValueUpdated:Connect(PowerAuras:FormatString([[
		local self, value = ...;
		PowerAuras:SetParameter("Trigger", "Matches", value, ${...});
	]], ...));
	frame:AddWidget(matchBox);

	-- Effect type.
	local effectType = PowerAuras:Create("P_Dropdown", frame);
	effectType:SetUserTooltip("UnitAura_MatchType");
	effectType:SetTitle(L["UnitAura_MatchType"]);
	effectType:SetRelativeWidth(0.3);
	effectType:SetPadding(2, 0, 4, 0);
	effectType:AddCheckItem(1, L["Buff"]);
	effectType:AddCheckItem(2, L["Debuff"]);
	effectType:LinkParameter("Trigger", "Type", ...);
	frame:AddWidget(effectType);

	-- Unit selection dialog.
	local unitBox = PowerAuras:Create("DialogBox", frame, nil, "UnitDialog",
		"Trigger", "Unit", ...);
	unitBox:SetUserTooltip("UnitAura_Unit");
	unitBox:SetTitle(L["Unit"]);
	unitBox:SetRelativeWidth(0.7);
	unitBox:SetPadding(4, 0, 2, 0);
	unitBox:SetText(PowerAuras:GetParameter("Trigger", "Unit", ...));
	unitBox:ConnectParameter("Trigger", "Unit", unitBox.SetText, ...);
	unitBox.OnValueUpdated:Connect(PowerAuras:FormatString([[
		local self, value = ...;
		PowerAuras:SetParameter("Trigger", "Unit", value, ${...});
	]], ...));
	frame:AddWidget(unitBox);
end

--- Returns the trigger type name.
-- @param params The parameters of the trigger.
function UnitAura:GetTriggerType(params)
	-- Decode the unit parameter.
	local unit = PowerAuras:DecodeUnits(params["Unit"]);
	if(PowerAuras:IsValidUnitID(unit)) then
		return ("%sAura"):format(
			params["Unit"]:match("^(%a-)%d*%-?[alny]*$")
			              :gsub("^%a", string.upper, 1)
		);
	else
		return "UnitAura";
	end
end

--- Initialises the per-trigger data store. This can be used to hold
--  values which can then be exposed to other parts of the system.
-- @param params The parameters of this trigger.
-- @return An item to store, or nil.
function UnitAura:InitialiseDataStore(params)
	-- We can communicate to sources, so set this up appropriately.
	return {
		Stacks = 0,
		Text = {
			name   = "",
			icon   = "",
			count  = 0,
			type   = "",
			caster = "",
			id     = 0,
			tt1    = 0,
			tt2    = 0,
			tt3    = 0,
		},
		Texture = PowerAuras.DefaultIcon,
		TimerStart = 0,
		TimerEnd = 2^31 - 1,
	};
end

--- Upgrades the trigger from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The trigger parameters to upgrade.
function UnitAura:Upgrade(version, params)
end

-- Listen to UI options creation.
PowerAuras.OnOptionsLoaded:Connect(function()

	--- Dialogbox widget for UnitAura matches.
	local Box = PowerAuras:RegisterWidget("UnitAuraMatchBox", "DialogBox");

	--- Initialises the widget.
	-- @param parent The parent of the editbox.
	-- @param ...    The ID's to use for Get/SetParameter calls.
	function Box:Initialise(parent, ...)
		-- Initialise as normal, connect to OnDialogOpened.
		base(self, parent, PowerAuras.Editor, "ModalDialog");
		self:SetEditable(false);
		self.OnDialogOpened:Connect(self.OnDialogCreated);
		-- Store parameter ID's.
		self.ParamType, self.ParamID1, self.ParamID2 = ...;
	end

	--- Called when the dialog frame is created.
	-- @param dialog The dialog frame.
	-- @param keep   Keeps the stored setting data.
	function Box:OnDialogCreated(dialog, keep)
		-- Update settings?
		if(not keep) then
			local pt, id1, id2 = self.ParamType, self.ParamID1, self.ParamID2;
			self.Vars = PowerAuras:DecodeMatch(
				PowerAuras:GetParameter(pt, "Matches", id1, id2)
					or UnitAura.Parameters.Matches
			);
		end

		-- Get the layout host frame and position it.
		local host = dialog.Host;
		host:SetPoint("TOPLEFT", 32, -32);
		host:SetPoint("BOTTOMRIGHT", -32, 32);
		host:SetContentPadding(6, 6, 6, 6);
		host:ClearWidgets();

		-- Add the match navigation tree.
		local tree = PowerAuras:Create("TreeView", host);
		tree:SetFixedWidth(170);
		tree:SetRelativeHeight(1.0);
		tree:SetMargins(0, 0, 0, -32);
		tree:SetPadding(0, 0, 0, 32);
		self:ConnectCallback(tree.OnCurrentNodeChanged, self.OnNodeChanged, 2);
		host:AddWidget(tree);
		host:AddRow(4);

		-- Cancel/Save buttons.
		local cancel = PowerAuras:Create("Button", host);
		cancel:SetText(L["Cancel"]);
		dialog:ConnectCallback(cancel.OnClicked, dialog.Cancel);
		host:AddStretcher();
		host:AddWidget(cancel);

		local apply = PowerAuras:Create("Button", host);
		apply:SetText(L["Apply"]);
		apply.OnClicked:Connect(function()
			-- Accept the dialog.
			dialog:SetAcceptData(
				PowerAuras:EncodeMatch(PowerAuras:CopyTable(self.Vars))
			);
			dialog:Accept();
		end);
		host:AddWidget(apply);

		-- Create our spare layout host if needed.
		if(not self.ControlHost) then
			self.ControlHost = PowerAuras:Create("LayoutHost", self);
			self.ControlHost:SetContentPadding(8, 8, 8, 8);
		end
		-- Position control host.
		local controls = self.ControlHost;
		controls:ClearAllPoints();
		controls:SetParent(host);
		controls:SetPoint("TOPLEFT", host, 178, -6);
		controls:SetPoint("BOTTOMRIGHT", host, -6, 38);
		controls:SetFrameStrata(host:GetFrameStrata());
		controls:Show();

		-- Tool host.
		if(not self.ToolHost) then
			self.ToolHost = PowerAuras:Create("LayoutHost", self);
			self.ToolHost:SetContentPadding(4, 4, 4, 4);
		end
		-- Position control host.
		local tools = self.ToolHost;
		tools:ClearAllPoints();
		tools:SetParent(host);
		tools:SetPoint("BOTTOMLEFT", host, 6, 6);
		tools:SetSize(170, 32);
		tools:SetFrameStrata(host:GetFrameStrata());
		tools:Show();

		-- Populate the tree.
		tree:PauseLayout();
		tree:AddNode(0, L["Defaults"]);
		tree:AddNode(-1, L["Matches"], nil, true, false, true);
		for i = 1, #(self.Vars) do
			tree:AddNode(i, L("MatchID", i), -1);
		end
		-- Select node #1 if it exists.
		if(tree:HasNode(1)) then
			tree:SetCurrentNode(1);
		elseif(tree:HasNode(0)) then
			-- Defaults are just as good as any.
			tree:SetCurrentNode(0);
		end
		tree:OnCurrentNodeChanged(tree:GetCurrentNode());
		tree:ResumeLayout();

		-- Remove our controls when the dialog is recycled.
		dialog.OnRecycled:Connect(function()
			self.ControlHost:ClearAllPoints();
			self.ControlHost:Hide();
			self.ControlHost:ClearWidgets();
			self.ToolHost:ClearAllPoints();
			self.ToolHost:Hide();
			self.ToolHost:ClearWidgets();
		end);
	end

	--- Called when the treeview node changes.
	-- @param node The selected node ID.
	function Box:OnNodeChanged(node)
		-- Discard if root. Should be impossible to get to it, but be safe.
		if(node == "__ROOT__") then
			return;
		end
		-- Reset the controls in our frame.
		local host = self.ControlHost;
		host:PauseLayout();
		host:ClearWidgets();

		-- Repopulate the container. Start with effect name.
		local effect = PowerAuras:Create("EditBox", host);
		effect:SetUserTooltip("UnitAura_Match");
		effect:SetPadding(4, 0, 4, 0);
		effect:SetRelativeWidth(1.0);
		effect:SetTitle(L["UnitAura_Match"]);
		effect:SetText(self.Vars[node].Effect or "");
		effect:SetSaveOnChange(true);
		effect.OnValueUpdated:Connect(function(ctrl, value)
			self.Vars[node].Effect = tostring(value or "");
			ctrl:SetText(self.Vars[node].Effect);
		end);
		host:AddWidget(effect);
		host:AddRow(4);

		-- Match options. Exact match first.
		local exact = PowerAuras:Create("Checkbox", host);
		exact:SetUserTooltip("UnitAura_Exact");
		exact:SetPadding(4, 0, 2, 0);
		exact:SetRelativeWidth(0.5);
		exact:SetText(L["Exact"]);
		exact:SetChecked(self.Vars[node].Exact);
		exact.OnValueUpdated:Connect(function(ctrl, state)
			self.Vars[node].Exact = state;
			ctrl:SetChecked(self.Vars[node].Exact);
		end);
		host:AddWidget(exact);

		-- Ignore case.
		local case = PowerAuras:Create("Checkbox", host);
		case:SetUserTooltip("UnitAura_Ignore");
		case:SetPadding(2, 0, 4, 0);
		case:SetRelativeWidth(0.5);
		case:SetText(L["IgnoreCase"]);
		case:SetChecked(self.Vars[node].IgnoreCase);
		case.OnValueUpdated:Connect(function(ctrl, state)
			self.Vars[node].IgnoreCase = state;
			ctrl:SetChecked(self.Vars[node].IgnoreCase);
		end);
		host:AddWidget(case);
		host:AddRow(4);

		-- Pattern matching.
		local pattern = PowerAuras:Create("Checkbox", host);
		pattern:SetUserTooltip("UnitAura_Pattern");
		pattern:SetPadding(4, 0, 2, 0);
		pattern:SetRelativeWidth(0.5);
		pattern:SetText(L["PatternMatch"]);
		pattern:SetChecked(self.Vars[node].Pattern);
		pattern.OnValueUpdated:Connect(function(ctrl, state)
			self.Vars[node].Pattern = state;
			ctrl:SetChecked(self.Vars[node].Pattern);
		end);
		host:AddWidget(pattern);

		-- Tooltip matching.
		local tooltip = PowerAuras:Create("Checkbox", host);
		tooltip:SetUserTooltip("UnitAura_MatchTooltip");
		tooltip:SetPadding(2, 0, 4, 0);
		tooltip:SetRelativeWidth(0.5);
		tooltip:SetText(L["TooltipMatch"]);
		tooltip:SetChecked(self.Vars[node].UseTooltip);
		tooltip.OnValueUpdated:Connect(function(ctrl, state)
			self.Vars[node].UseTooltip = state;
			self:OnNodeChanged(node);
		end);
		host:AddWidget(tooltip);
		host:AddRow(4);

		-- Tooltip match editbox (show only if needed).
		if(self.Vars[node].UseTooltip) then
			local tooltip = PowerAuras:Create("EditBox", host);
			tooltip:SetUserTooltip("UnitAura_Tooltip");
			tooltip:SetPadding(4, 0, 4, 0);
			tooltip:SetRelativeWidth(1.0);
			tooltip:SetTitle(L["TooltipMatch"]);
			tooltip:SetText(self.Vars[node].Tooltip);
			tooltip:SetSaveOnChange(true);
			tooltip.OnValueUpdated:Connect(function(ctrl, value)
				self.Vars[node].Tooltip = tostring(value or "");
				ctrl:SetText(self.Vars[node].Tooltip);
			end);
			host:AddWidget(tooltip);
		end

		-- Additional options.
		local h2 = PowerAuras:Create("Header", host);
		h2:SetText(L["Options"]);
		host:AddWidget(h2);

		-- Cast By option.
		local castBy = PowerAuras:Create("Checkbox", host);
		castBy:SetUserTooltip("UnitAura_IsMine");
		castBy:SetPadding(4, 0, 2, 0);
		castBy:SetRelativeWidth(0.5);
		castBy:SetText(L["IsMine"]);
		castBy:SetChecked((self.Vars[node].CastBy == "player"));
		castBy.OnValueUpdated:Connect(function(ctrl, state)
			self.Vars[node].CastBy = (state and "player" or false);
			ctrl:SetChecked((self.Vars[node].CastBy == "player"));
		end);
		host:AddWidget(castBy);

		-- Stealable spell?
		local stealable = PowerAuras:Create("Checkbox", host);
		stealable:SetUserTooltip("UnitAura_StealPurge");
		stealable:SetPadding(2, 0, 4, 0);
		stealable:SetRelativeWidth(0.5);
		stealable:SetText(L["Stealable"]);
		stealable:SetChecked(self.Vars[node].Stealable);
		stealable.OnValueUpdated:Connect(function(ctrl, state)
			self.Vars[node].Stealable = state;
			ctrl:SetChecked(self.Vars[node].Stealable);
		end);
		host:AddWidget(stealable);

		-- Stacks matching.
		local h3 = PowerAuras:Create("Header", host);
		h3:SetText(L["Stacks"]);
		host:AddWidget(h3);

		-- Stacks operator.
		local op = PowerAuras:Create("SimpleDropdown", host);
		op:SetUserTooltip("Operator");
		op:SetPadding(4, 0, 2, 0);
		op:SetRelativeWidth(1 / 3);
		op:SetTitle(L["Operator"]);
		for i = 1, #(PowerAuras.Operators) do
			op:AddCheckItem(PowerAuras.Operators[i], PowerAuras.Operators[i]);
		end
		op:SetItemChecked(self.Vars[node].Operator, true);
		op:SetText(self.Vars[node].Operator);
		op.OnValueUpdated:Connect(function(ctrl, value)
			ctrl:CloseMenu();
			ctrl:SetItemChecked(self.Vars[node].Operator, false);
			self.Vars[node].Operator = value;
			ctrl:SetItemChecked(self.Vars[node].Operator, true);
			ctrl:SetText(self.Vars[node].Operator);
		end);
		host:AddWidget(op);

		-- Stacks count.
		local count = PowerAuras:Create("NumberBox", host);
		count:SetUserTooltip("UnitAura_Count");
		count:SetPadding(2, 0, 2, 0);
		count:SetRelativeWidth(1 / 3);
		count:SetTitle(L["Count"]);
		count:SetMinMaxValues(0, 2^31 - 1);
		count:SetValueStep(1);
		count:SetValue(self.Vars[node].Count);
		count.OnValueUpdated:Connect(function(ctrl, value)
			self.Vars[node].Count = (tonumber(value) or 0);
			ctrl:SetValue(self.Vars[node].Count);
		end);
		host:AddWidget(count);

		-- Stacks source.
		local src = PowerAuras:Create("SimpleDropdown", host);
		src:SetUserTooltip("UnitAura_Source");
		src:SetPadding(4, 0, 2, 0);
		src:SetRelativeWidth(1 / 3);
		src:SetTitle(L["StacksSource"]);
		src:AddCheckItem(0, L["StacksSource0"]);
		src:AddCheckItem(1, L["StacksSource1"]);
		src:AddCheckItem(2, L["StacksSource2"]);
		src:AddCheckItem(3, L["StacksSource3"]);
		src.OnValueUpdated:Connect(function(ctrl, value)
			ctrl:CloseMenu();
			ctrl:SetItemChecked(self.Vars[node].CountSource, false);
			self.Vars[node].CountSource = value;
			ctrl:SetItemChecked(self.Vars[node].CountSource, true);
			ctrl:SetText(self.Vars[node].CountSource);
		end);
		src:SetItemChecked(self.Vars[node].CountSource, true);
		src:SetText(self.Vars[node].CountSource);
		host:AddWidget(src);

		-- Resume the layout.
		host:ResumeLayout();

		-- Now redo the tools!
		local tools = self.ToolHost;
		tools:PauseLayout();
		tools:ClearWidgets();

		-- Add Match button.
		local add = PowerAuras:Create("IconButton", tools);
		add:SetIcon([[Interface\PaperDollInfoFrame\Character-Plus]]);
		add.OnClicked:Connect(function()
			tinsert(self.Vars, PowerAuras:CopyTable(self.Vars[0]));
			-- Hackish reset.
			self:OnDialogCreated(self.Dialog, true);
			-- Even more hackish selection.
			self.Dialog.Host.Widgets[1]:SetCurrentNode(#(self.Vars));
			self.Dialog.Host.Widgets[1]:OnCurrentNodeChanged(#(self.Vars));
		end);
		tools:AddWidget(add);

		-- Delete Match button.
		if(node > 0) then
			local delete = PowerAuras:Create("IconButton", tools);
			delete:SetIcon([[Interface\PetBattles\DeadPetIcon]]);
			delete.OnClicked:Connect(function()
				tremove(self.Vars, node);
				-- Hackish reset.
				self:OnDialogCreated(self.Dialog, true);
			end);
			tools:AddStretcher();
			tools:AddWidget(delete);
		end

		tools:ResumeLayout();
	end

	--- Recycles the frame, allowing it to be reused.
	function Box:Recycle()
		-- Recycle as normal, after hiding our control/tools host.
		if(self.ControlHost) then
			self.ControlHost:ClearAllPoints();
			self.ControlHost:Hide();
		end
		if(self.ToolHost) then
			self.ToolHost:ClearAllPoints();
			self.ToolHost:Hide();
		end
		base(self);
	end

end);