-- Lock down local environment.
local PowerAuras = _G["PowerAuras"];
setfenv(1, PowerAuras);

-- Scoped functions.
local GetAllSubTriggers, IsTriggerInverted, RemoveSubTrigger;

--- Current editor category.
local CurrentCategory = 0;

-- Storage for the currently selected sub-trigger.
local CurrentSubTrigger = nil;

-- Wipe the currently stored trigger when told to.
PowerAuras.OnOptionsEvent:Connect(function(event)
	if(event == "SELECTED_DISPLAY_CHANGED") then
		CurrentSubTrigger = nil;
	end
end);

--- Returns the current display ID and, if applicable, the action ID of the
--  activate action.
local function GetCurrentData()
	local editor = PowerAuras.Editor.Displays;
	local _, id = PowerAuras:SplitNodeID(editor:GetCurrentNode());
	if(PowerAuras:HasAuraDisplay(id)) then
		local aID = PowerAuras:GetAuraDisplay(id).Actions["DisplayActivate"];
		return id, aID, PowerAuras:GetAuraAction(aID);
	else
		return nil, nil, nil;
	end
end

--- Adds/replaces a trigger reference within a sequence.
-- @param id      The ID of the display.
-- @param trigger The trigger index to add/replace.
-- @param invert  True if the trigger should be inverted.
local function AddTriggerToSequence(id, trigger, invert)
	-- Get display/action data.
	local _, actionID, action = GetCurrentData();
	-- Run over the sequence, see if the trigger exists.
	local ops = action["Sequences"][1]["Operators"];
	local _, exists = IsTriggerInverted(id, trigger);
	if(exists) then
		-- Straight-up replacement.
		ops = ops:gsub("(!?)([0-9]+)", function(inv, index)
			if(tonumber(index) == trigger) then
				return ("%s%d"):format(invert and "!" or "", index);
			else
				return ("%s%d"):format(inv, index);
			end
		end);
	else
		-- Doesn't exist, append.
		ops = ops .. ("&%s%d"):format(invert and "!" or "", trigger);
		-- Was this the only trigger?
		if(trigger == 1) then
			ops = ops:sub(2);
		end
	end
	-- Update sequence.
	PowerAuras:SetParameter("SequenceOp", "", ops, actionID, 1);
end

do
	--- Stateless iterator function for GetAllSubTriggers.
	-- @param action The action to search.
	-- @param index  The current trigger index.
	local function iterator(action, index)
		-- Get next trigger.
		index = index + 1;
		while(action["Triggers"][index]) do
			-- Check the trigger class.
			local tri = action["Triggers"][index];
			local class = PowerAuras:GetTriggerClass(tri["Type"]);
			if(class:IsSupportTrigger()) then
				return index, tri, class;
			end
			-- Next trigger.
			index = index + 1;
		end
	end

	--- Returns an iterator for accessing all subtriggers within a display.
	--  A subtrigger is one that is considered to be a 'support' trigger.
	-- @param id The ID of the display to search.
	function GetAllSubTriggers(id)
		-- Find the display action.
		local display = PowerAuras:GetAuraDisplay(id);
		local actionID = display["Actions"]["DisplayActivate"];
		-- Return the iterator.
		return iterator, PowerAuras:GetAuraAction(actionID), 0;
	end
end

--- OnValueUpdated handler for Invert checkboxes.
-- @param btn   The clicked button.
-- @param state The checkbox state.
local function InvertTrigger(btn, state)
	-- Handle this in AddTriggerToSequence.
	AddTriggerToSequence((GetCurrentData()), btn:GetID(), state);
	-- Refresh the editor.
	local editor = PowerAuras.Editor.Displays;
	editor:RefreshHost(editor:GetCurrentNode());
end

--- Checks if the specified trigger is inverted.
-- @param id    The ID of the display.
-- @param index The trigger index.
-- @return True/false if inverted. Second return is true/false if the trigger
--         exists in the sequence.
function IsTriggerInverted(id, index)
	local display = PowerAuras:GetAuraDisplay(id);
	local actionID = display["Actions"]["DisplayActivate"];
	local action = PowerAuras:GetAuraAction(actionID);
	-- Find the trigger within the sequence.
	local ops = action["Sequences"][1]["Operators"];
	for inv, id in ops:gmatch("(!?)([0-9]+)") do
		if(tonumber(id) == index) then
			return inv == "!", true;
		end
	end
	-- Trigger isn't even in here.
	return false, false;
end

--- Checks if the specified trigger is used within the display action.
-- @param id   The ID of the display.
-- @param name The name of the trigger.
local function IsTriggerUsed(id, name)
	local display = PowerAuras:GetAuraDisplay(id);
	local actionID = display["Actions"]["DisplayActivate"];
	local action = PowerAuras:GetAuraAction(actionID);
	-- Run over the triggers until we find a match.
	for i = 1, #(action["Triggers"]) do
		if(action["Triggers"][i]["Type"] == name) then
			return true;
		end
	end
	-- No match.
	return false;
end

--- Called when a subtrigger is toggled on/off.
-- @param button The clicked button.
-- @param state  The checkbox state.
local function OnSubTriggerToggled(button, state)
	-- Enabled or disabled?
	if(state) then
		-- Determine the trigger class being created.
		local match, offset = nil, 0;
		for i, id in PowerAuras:IterTriggerClasses() do
			local cls = PowerAuras:GetTriggerClass(id);
			if(cls:IsSupportTrigger()) then
				offset = offset + 1;
				if(offset == button:GetID()) then
					match = id;
					break;
				end
			end
		end

		-- Now create it.
		local displayID, actionID = GetCurrentData();
		local index = PowerAuras:CreateAuraActionTrigger(actionID, match);
		AddTriggerToSequence(displayID, index, false);
		CurrentSubTrigger = index;

		-- Refresh the host.
		local editor = PowerAuras.Editor.Displays;
		editor:RefreshHost(editor:GetCurrentNode());
	else
		-- Remove it.
		RemoveSubTrigger();
	end
end

--- Deletes the current subtrigger.
function RemoveSubTrigger()
	-- Get the action ID from the display.
	local _, actionID = GetCurrentData();
	-- Delete.
	PowerAuras:DeleteAuraActionTrigger(actionID, CurrentSubTrigger);
	-- Refresh the editor.
	local editor = PowerAuras.Editor.Displays;
	editor:RefreshHost(editor:GetCurrentNode());
end

--- Updates the main trigger for an action.
-- @param dropdown The dropdown button.
-- @param id       The selected key.
local function UpdateCurrentMainTrigger(dropdown, id)
	-- Get the display data and main trigger index.
	local displayID, actionID, action = GetCurrentData();
	-- Get main trigger index.
	local index = PowerAuras:GetMainTrigger(displayID);
	if(index) then
		-- Replace trigger at this index, but only if it's different.
		if(action["Triggers"][index]["Type"] ~= id) then
			PowerAuras:CreateAuraActionTrigger(actionID, id, index);
		end
	else
		-- No main trigger present, just create.
		local index = PowerAuras:CreateAuraActionTrigger(actionID, id);
		AddTriggerToSequence(displayID, index, false);
	end
	-- Close menu.
	dropdown:CloseMenu();
	-- Refresh the editor.
	local editor = PowerAuras.Editor.Displays;
	editor:RefreshHost(editor:GetCurrentNode());
end

--- ListInlay OnContentRefreshed callback.
-- @param frame The inlay frame.
-- @param pane  The frame to attach controls to.
-- @param key   The selected key.
-- @param tab   The current item tab.
local function OnContentRefreshed(frame, pane, key, tab)
	-- Store category.
	CurrentCategory = key;

	-- Change contents based upon the category.
	local id, aID, action = GetCurrentData();
	if(key == 0) then
		-- Main trigger.
		local index = PowerAuras:GetMainTrigger(id);
		local tri = action.Triggers[index];

		-- Dropdown for class picking.
		local cT = PowerAuras:Create("SimpleDropdown", pane);
		cT:SetUserTooltip("Editor_MainTrigger");
		cT:SetPadding(4, 0, 2, 0);
		cT:SetRelativeWidth(0.5);
		cT:SetTitle(L["MainTrigger"]);
		cT:SetRawText(NONE);

		-- Add classes to dropdown.
		for _, id, name in PowerAuras:IterTriggerClasses() do
			local cls = PowerAuras:GetTriggerClass(id);
			if(not cls:IsSupportTrigger()) then
				cT:AddCheckItem(id, name, (tri and id == tri.Type));
				cT:SetItemTooltip(id, L["TriggerClasses"][id]["Tooltip"]);
				if(tri and id == tri.Type) then
					cT:SetText(id);
				end
			end
		end

		-- Callbacks and add to pane.
		cT.OnValueUpdated:Connect(UpdateCurrentMainTrigger);
		pane:AddWidget(cT);

		-- Add editor for the trigger.
		if(tri and PowerAuras:HasTriggerClass(tri.Type)) then
			-- Invert checkbox.
			local invert = PowerAuras:Create("Checkbox", pane);
			invert:SetUserTooltip("Editor_Invert");
			invert:SetMargins(0, 20, 0, 0);
			invert:SetPadding(2, 0, 4, 0);
			invert:SetRelativeWidth(0.5);
			invert:SetText(L["Invert"]);
			invert:SetChecked(IsTriggerInverted(id, index));
			invert:SetID(index);
			invert.OnValueUpdated:Connect(InvertTrigger);
			pane:AddWidget(invert);

			-- Create editor.
			local cls = PowerAuras:GetTriggerClass(tri.Type);
			pane:AddRow(4);
			cls:CreateTriggerEditor(pane, aID, index);
		elseif(tri) then
			-- Can't edit this trigger.
			local l = PowerAuras:Create("Label", pane);
			l:SetText(L["TriggerNoConf"]);
			l:SetRelativeWidth(1.0);
			l:SetHeight(36);
			l:SetJustifyH("CENTER");
			l:SetJustifyV("MIDDLE");
			pane:AddRow(4);
			pane:AddWidget(l);
		else
			-- No trigger.
			local l = PowerAuras:Create("Label", pane);
			l:SetText(L["TriggerNone"]);
			l:SetRelativeWidth(1.0);
			l:SetHeight(36);
			l:SetJustifyH("CENTER");
			l:SetJustifyV("MIDDLE");
			pane:AddRow(4);
			pane:AddWidget(l);
		end
	elseif(key == 1) then
		-- Support triggers. Find the selected one.
		CurrentSubTrigger = nil;
		local match, offset, curName = nil, 0, "";
		for i, id, name in PowerAuras:IterTriggerClasses() do
			local cls = PowerAuras:GetTriggerClass(id);
			if(cls:IsSupportTrigger()) then
				offset = offset + 1;
				if(offset == tab) then
					curName = name;
					match = id;
					break;
				end
			end
		end

		-- Find it in our subtriggers.
		for i, tri, cls in GetAllSubTriggers(id) do
			if(tri.Type == match) then
				CurrentSubTrigger = i;
				break;
			end
		end

		-- Help text.
		local help1 = PowerAuras:Create("Label", pane);
		help1:SetUserTooltip(curName, L["TriggerClasses"][match]["Tooltip"]);
		help1:SetJustifyV("MIDDLE");
		help1:SetJustifyH("LEFT");
		help1:SetRelativeWidth(1.0);
		help1:SetFontObject(GameFontHighlight);
		help1:SetFixedHeight(16);
		help1:SetText(L("SupportTriggersHelp1", curName));
		pane:AddWidget(help1);

		local help2 = PowerAuras:Create("Label", pane);
		help2:SetJustifyV("MIDDLE");
		help2:SetJustifyH("LEFT");
		help2:SetRelativeWidth(1.0);
		help2:SetFontObject(GameFontHighlightSmall);
		help2:SetFixedHeight(32);
		help2:SetText(L["SupportTriggersHelp2"]);
		pane:AddWidget(help2);
		pane:AddRow(4);

		-- Enabled checkbox.
		local enabled = PowerAuras:Create("Checkbox", pane);
		enabled:SetUserTooltip("Editor_EnableSupport");
		enabled:SetPadding(4, 0, 2, 0);
		enabled:SetRelativeWidth(1 / 3);
		enabled:SetText(L["Enabled"]);
		enabled:SetChecked(CurrentSubTrigger ~= nil);
		enabled:SetID(offset);
		enabled.OnValueUpdated:Connect(OnSubTriggerToggled);
		pane:AddWidget(enabled);

		-- So can we edit the current trigger?
		if(CurrentSubTrigger) then
			-- Invert checkbox.
			local invert = PowerAuras:Create("Checkbox", pane);
			invert:SetUserTooltip("Editor_Invert");
			invert:SetPadding(2, 0, 4, 0);
			invert:SetRelativeWidth(1 / 3);
			invert:SetText(L["Invert"]);
			invert:SetChecked(IsTriggerInverted(id, CurrentSubTrigger));
			invert:SetID(CurrentSubTrigger);
			invert.OnValueUpdated:Connect(InvertTrigger);
			pane:AddWidget(invert);

			-- Add editor.
			local tri = action.Triggers[CurrentSubTrigger];
			if(PowerAuras:HasTriggerClass(tri.Type)) then
				-- Add the editor.
				local cls = PowerAuras:GetTriggerClass(tri.Type);
				pane:AddRow(4);
				cls:CreateTriggerEditor(pane, aID, CurrentSubTrigger);
			else
				-- Can't edit this trigger.
				local l = PowerAuras:Create("Label", pane);
				l:SetText(L["TriggerNoConf"]);
				l:SetRelativeWidth(1.0);
				l:SetHeight(36);
				l:SetJustifyH("CENTER");
				l:SetJustifyV("MIDDLE");
				pane:AddRow(4);
				pane:AddWidget(l);
			end
		end
	elseif(key == 2) then
		-- Config UI for the sequence on the action.
		local cls = PowerAuras:GetActionClass(action.Type);
		cls:CreateSequenceEditor(pane, aID, 1);
	end
end

--- Creates the display activation editor pane.
-- @param frame The frame to attach widgets to.
-- @param node  The currently selected node.
function PowerAuras:CreateActivationEditor(frame, node)
	-- Split node data up.
	local _, id = self:SplitNodeID(node);
	if(not self:HasAuraDisplay(id)) then
		return;
	end

	-- Get the display/action data.
	local display = self:GetAuraDisplay(id);
	local actionID = display["Actions"]["DisplayActivate"];
	local action = self:GetAuraAction(actionID);

	-- Determine if advanced mode is required.
	local state, reason = PowerAuras:IsAdvancedActivationRequired(id);
	if(state) then
		-- Redirect the user.
		frame:SetCurrentNode(self:GetNodeID("Actions", actionID, 1, 0, 0, 0));
		frame:RefreshHost(frame:GetCurrentNode());
		PowerAuras:PrintError(L(
			"EditorActivateRedirect",
			L["EditorActivateRedirectReasons"][reason]
		));
		return;
	end

	-- Get main trigger data.
	local index = PowerAuras:GetMainTrigger(id);
	local tri = index and action["Triggers"][index] or nil;

	-- Add list inlay for each category (main/subtriggers).
	local inlay = PowerAuras:Create("ListInlay", frame);
	inlay:SetRelativeSize(1.0, 1.0);
	inlay:SetPadding(-3, -6, -6, -8);
	inlay:PauseLayout();

	-- Add subcategories.
	if(tri) then
		inlay:AddItem(0, L["TriggerClasses"][tri["Type"]]["Name"]);
	else
		inlay:AddItem(0, L["MainTrigger"]);
	end

	-- Tabs for support classes.
	local support = {};
	for _, id, name in PowerAuras:IterTriggerClasses() do
		local cls = PowerAuras:GetTriggerClass(id);
		if(cls:IsSupportTrigger()) then
			support[#(support) + 1] = name;
		end
	end
	-- Add support/options.
	inlay:AddItem(1, L["SupportTriggers"], nil, unpack(support));
	inlay:AddItem(2, L["DurationDelay"]);

	-- Default to the style section unless told otherwise.
	inlay:SetCurrentItem(CurrentCategory or 0);

	-- Connect to callbacks.
	inlay.OnContentRefreshed:Connect(OnContentRefreshed);
	inlay.OnTasksRefreshed:Connect(OnTasksRefreshed);
	inlay:ResumeLayout();
	frame:AddWidget(inlay);
end

do
	local supportCache = {};

	--- Returns true if the advanced editor is required for the passed display.
	-- @param id The ID of the display to search.
	-- @return True if required, false if not. Also returns a string code
	--         if the first return is True.
	function PowerAuras:IsAdvancedActivationRequired(id)
		-- This check returns true if the display has > 1 main trigger, or if
		-- the support triggers are duplicated.
		local mains, unique = 0, true;
		local display = self:GetAuraDisplay(id);
		local actionID = display["Actions"]["DisplayActivate"];
		local action = self:GetAuraAction(actionID);
		-- Run over the triggers until we find the 'main' one.
		for i = 1, #(action["Triggers"]) do
			local tri = action["Triggers"][i];
			local class = self:GetTriggerClass(tri["Type"]);
			-- Main trigger is the one that isn't a support trigger.
			if(not class:IsSupportTrigger()) then
				mains = mains + 1;
			else
				-- Support trigger, does it exist?
				if(supportCache[tri["Type"]]) then
					unique = false;
					break;
				else
					supportCache[tri["Type"]] = true;
				end
			end
		end
		-- Check number of main triggers.
		wipe(supportCache);
		if(mains > 1) then
			return true, "MULTIPLE_MAIN_TRIGGERS";
		elseif(not unique) then
			return true, "DUPLICATE_SUPPORT_TRIGGERS";
		end
		-- Next, check the sequences. Can't have complex logic (or > 1).
		if(#(action["Sequences"]) ~= 1) then
			return true, "MULTIPLE_SEQUENCES";
		end
		local seq = action["Sequences"][1];
		local ops = seq["Operators"];
		-- Only allow AND (&) and NOT (!) logic.
		if(ops:find("[^%s0-9&!]")) then
			return true, "SEQUENCE_COMPLEX";
		end
		-- Make sure all the triggers exist.
		for id in ops:gmatch("[0-9]+") do
			if(not action["Triggers"][tonumber(id)]) then
				return true, "BROKEN_SEQUENCE";
			end
		end
		-- Nothing bad.
		return false;
	end
end