-- Lock down local environment.
local PowerAuras = _G["PowerAuras"];
setfenv(1, PowerAuras);

--- Currently selected trigger 'node'.
local CurrentTrigger = nil;

--- Listen to OnOptionsEvent for some things.
PowerAuras.OnOptionsEvent:Connect(function(event, ...)
	-- Disregard most events.
	if(event ~= "TRIGGER_CREATED" and event ~= "TRIGGER_DELETED") then
		return;
	end
	-- Created?
	if(event == "TRIGGER_CREATED") then
		-- Update CurrentTrigger var if it is currently set, and if the action
		-- ID's match.
		local id, _, i = ...;
		local _, cID = PowerAuras:SplitNodeID(CurrentTrigger or 0);
		if(cID == id) then
			CurrentTrigger = PowerAuras:GetNodeID("Actions", id, 1, 0, 0, i);
		end
	elseif(event == "TRIGGER_DELETED") then
		-- Similar to CREATED, except select the one before it.
		local id, i = ...;
		local _, cID = PowerAuras:SplitNodeID(CurrentTrigger or 0);
		if(cID == id) then
			-- Does one before it exist? If not, keep the ID.
			if(PowerAuras:HasAuraActionTrigger(id, i - 1)) then
				i = i - 1;
			end
			CurrentTrigger = PowerAuras:GetNodeID("Actions", id, 1, 0, 0, i);
		end
	end
end);

--- Callback function for when the Change Trigger Type button is clicked.
-- @param button The button frame.
-- @param key    The key of the selected item.
local function OnChangeTriggerClicked(button, key)
	-- Extract ID's and morph this thing!
	local safeID = button:GetID();
	local id, index = bit.rshift(safeID, 8), bit.band(safeID, 0x3F);
	PowerAuras:CreateAuraActionTrigger(id, key, index);
end

--- Callback function for when the Delete Trigger button is clicked.
-- @param button The button frame.
local function OnDeleteTriggerClicked(button)
	-- Extract ID's and assimilate into the void.
	local safeID = button:GetID();
	local id, index = bit.rshift(safeID, 8), bit.band(safeID, 0x3F);
	-- Prompt user.
	local editor = PowerAuras.Editor;
	local dialog = PowerAuras:Create("PromptDialog", editor, 
		L["DialogDeleteTrigger"], YES, NO);
	-- Connect callbacks.
	dialog.OnAccept:Connect(function()
		PowerAuras:DeleteAuraActionTrigger(id, index);
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
end

--- Callback function for the editor content pane update.
-- @param frame The editor list frame.
-- @param pane  The editor content pane.
-- @param key   The selected list key.
local function OnEditorContentRefreshed(frame, pane, key)
	-- Update current trigger.
	CurrentTrigger = key;
	-- So was anything selected?
	if(not key) then
		return;
	end
	-- Create editor.
	local _, id, _, _, _, index = PowerAuras:SplitNodeID(key);
	local trigger = PowerAuras:GetAuraActionTrigger(id, index);
	local class = PowerAuras:GetTriggerClass(trigger["Type"]);
	-- Get the trigger editor and add it to the frame.
	class:CreateTriggerEditor(pane, id, index);
end

--- Called when the tasks list for an item is refreshed.
-- @param frame The editor list frame.
-- @param pane  The item tasks pane.
-- @param key   The selected list key.
local function OnEditorTasksRefreshed(frame, pane, key)
	-- Get the 'safe' ID for use with SetID. Client crashes if this is
	-- too high (2^31 - 1 probably being safest).
	local _, id, _, _, _, index = PowerAuras:SplitNodeID(key);
	local safeID = bit.bor(bit.lshift(id, 8), index);
	-- Get trigger data.
	local vars = PowerAuras:GetAuraActionTrigger(id, index);
	-- Change trigger button.
	local trigger = PowerAuras:Create("SimpleDropdownIcon", pane, 200);
	trigger:SetIcon([[Interface\WorldMap\Gear_64Grey]]);
	trigger:SetIconTexCoord(0.2, 0.8, 0.2, 0.8);
	trigger:SetMargins(2, 0, 0, 0);
	trigger:SetID(safeID);
	trigger.OnValueUpdated:Connect(OnChangeTriggerClicked);
	for _, key, name in PowerAuras:IterTriggerClasses() do
		trigger:AddCheckItem(key, name);
		trigger:SetItemTooltip(key, L["TriggerClasses"][key]["Tooltip"]);
	end
	-- Hopefully a node for this trigger exists...
	if(trigger:HasItem(vars["Type"])) then
		trigger:SetItemChecked(vars["Type"], true);
	end

	-- Trigger deletion button.
	local delete = PowerAuras:Create("IconButton", pane);
	delete:SetIcon([[Interface\PetBattles\DeadPetIcon]]);
	delete:SetMargins(0, 0, 2, 0);
	delete:SetID(safeID);
	delete.OnClicked:Connect(OnDeleteTriggerClicked);

	-- Add buttons to pane, and manually size it (required).
	pane:AddWidget(trigger);
	pane:AddWidget(delete);
	-- (Button width * Number of buttons) + Sum of horizontal margins + 1.
	pane:SetWidth((delete:GetFixedWidth() * 2) + 5);
end

--- Creates the animation editing GUI for a display.
-- @param frame The frame to attach controls to.
-- @param node  The key of the node.
function PowerAuras:CreateActionEditor(frame, node)
	-- Extract ID's from node param.
	local source = bit.rshift(bit.band(node, 0xC0000000), 30);
	local actionID, actionFlag, objType, objID =
		bit.band(bit.rshift(node, 14), 0x0000FFFF),
		bit.rshift(bit.band(node, 0x00002000), 13),
		bit.rshift(bit.band(node, 0x00000040), 6),
		bit.band(node, 0x0000003F);
	-- Use default node population where needed.
	if(objID == 0 and actionFlag == 0) then
		-- Populate with list items.
		frame:PopulateChildNodes();
		-- DId we add anything?
		if(#(frame.Widgets) == 0) then
			-- Add a label pointing out the New Action button.
			local label = PowerAuras:Create("Label", frame);
			label:SetRelativeWidth(1.0);
			label:SetFixedHeight(36);
			label:SetJustifyH("CENTER");
			label:SetJustifyV("MIDDLE");
			label:SetFontObject(GameFontNormal);
			label:SetText(L["NoActions"]);
			frame:AddWidget(label);
		end
	elseif(objID == 0 and actionFlag == 1) then
		-- Reset the current trigger ID if this isn't the same action.
		local _, aID = self:SplitNodeID(CurrentTrigger or 0);
		if(aID ~= actionID) then
			CurrentTrigger = nil;
		end
		-- Add the triggers list.
		local list = PowerAuras:Create("ListInlay", frame);
		list:SetRelativeSize(1.0, 1.0);
		list:SetPadding(-3, -6, -6, -5);
		list:PauseLayout();
		-- Add all the triggers.
		local vars = self:GetAuraAction(actionID);
		for i = 1, #(vars["Triggers"]) do
			-- Get the trigger.
			local tri = vars["Triggers"][i];
			-- Add the item.
			list:AddItem(
				self:GetNodeID("Actions", actionID, 1, 0, 0, i),
				("%d: %s"):format(i, L["TriggerClasses"][tri["Type"]]["Name"])
			);
		end
		-- Select the first trigger.
		CurrentTrigger = CurrentTrigger
			or self:GetNodeID("Actions", actionID, 1, 0, 0, 1);
		if(list:HasItem(CurrentTrigger)) then
			list:SetCurrentItem(CurrentTrigger);
			list:SetCurrentPage(list:GetItemPageNumber(CurrentTrigger));
		else
			CurrentTrigger = nil;
		end
		-- Connect callbacks.
		list.OnContentRefreshed:Connect(OnEditorContentRefreshed);
		list.OnTasksRefreshed:Connect(OnEditorTasksRefreshed);
		list:ResumeLayout();
		-- Add list to frame.
		frame:AddWidget(list);
	end
end