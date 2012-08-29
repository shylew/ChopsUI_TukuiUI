-- Lock down local environment.
local PowerAuras = _G["PowerAuras"];
setfenv(1, PowerAuras);

--- Creates the sound editor pane for a display.
-- @param frame The frame to place controls on.
-- @param node  The current selected node.
function PowerAuras:CreateSoundEditor(frame, node)
	-- Split the node data up.
	local _, id, _, _, _, page = self:SplitNodeID(node);
	for page = 1, 2 do
		-- Find the appropriate action and triggers.
		local display = self:GetAuraDisplay(id);
		local actionID = display["Actions"]["DisplaySound"];
		local aID, tID, sID = self:GetDisplaySoundAction(id, page);
		-- Add header.
		local h1 = PowerAuras:Create("Header", frame);
		h1:SetText(page == 1 and L["OnShow"] or L["OnHide"]);
		-- Now put in a checkbox for enabling/disabling the sound.
		local check = PowerAuras:Create("Checkbox", frame);
		check:SetUserTooltip("Sound_Enable");
		check:SetRelativeWidth(1.0);
		check:SetPadding(4, 0, 4, 0);
		check:SetText(ENABLE_SOUND);
		check:SetChecked(tID ~= nil and sID ~= nil);
		check:SetID(bit.bor(bit.lshift(id, 2), page));
		check.OnValueUpdated:Connect([[
			local self, state = ...;
			-- Get the necessary ID's.
			local node = self:GetID();
			local id, t = bit.rshift(node, 2), bit.band(node, 0x3);
			local aID, tID, sID = PowerAuras:GetDisplaySoundAction(id, t);
			-- Operate based on the state.
			if(state) then
				-- We're enabling.
				local created;
				if(not aID) then
					-- Create the action.
					local aura = PowerAuras:SplitAuraDisplayID(id);
					aID = PowerAuras:CreateAuraAction(aura, "DisplaySound", id);
					created = true;
				end
				-- Add the necessary trigger/sequence to the action.
				if(aID) then
					-- Add triggers to action.
					tID = PowerAuras:CreateAuraActionTrigger(
						aID,
						"DisplayState"
					);
					-- Sequence time.
					if(not created) then
						sID = PowerAuras:CreateAuraActionSequence(aID);
					else
						sID = 1;
					end
					-- Configure the trigger/sequence.
					PowerAuras:SetParameter(
						"Trigger", "State",
						t == 1 and "BeginShow/Show" or "BeginHide/Hide",
						aID, tID
					);
					-- Ensure the trigger is looking at this display.
					PowerAuras:SetParameter("Trigger", "ID", id, aID, tID);
					-- Update sequence to point to that trigger.
					PowerAuras:SetParameter(
						"SequenceOp", "", tostring(tID), aID, sID
					);
					-- Refresh host.
					local parent = self:GetParent();
					parent:RefreshHost(parent:GetCurrentNode());
				end
			elseif(not state and aID) then
				-- We're removing.
				if(PowerAuras:GetAuraActionTriggerCount(aID) == 1) then
					PowerAuras:DeleteAuraAction(aID);
				else
					PowerAuras:DeleteAuraActionTrigger(aID, tID);
					PowerAuras:DeleteAuraActionSequence(aID, sID);
				end
			end
		]]);
		frame:AddWidget(h1);
		frame:AddWidget(check);
		frame:AddRow(8);
		-- Did the action/trigger exist?
		if(aID and tID and sID) then
			local action = self:GetAuraAction(aID);
			-- Add the editor for the action.
			local class = self:GetActionClass(action["Type"]);
			class:CreateSequenceEditor(frame, aID, sID);
		end
	end
end

--- Returns the action, trigger and sequence ID's of a DisplaySound action
--  for the sound of the given type. If the action does not exist, all
--  results are nil.
-- @param id The ID of the display.
-- @param t  1 for an OnShow type sound, 2 for an OnHide one.
function PowerAuras:GetDisplaySoundAction(id, t)
	-- Run over the action if it exists.
	local actionID = self:GetAuraDisplay(id)["Actions"]["DisplaySound"];
	local triggerID, sequenceID;
	if(actionID and self:HasAuraAction(actionID)) then
		-- Run over the triggers to find the appropriate one.
		local action = self:GetAuraAction(actionID);
		for i = 1, #(action["Triggers"]) do
			local tri = action["Triggers"][i];
			local params = tri["Parameters"];
			-- Must be a DisplayState trigger.
			if(tri["Type"] == "DisplayState" and params["ID"] == id) then
				-- Verify the state option.
				local state = params["State"];
				if(t == 1 and state:find("Show", 1, true)
				or t == 2 and state:find("Hide", 1, true)) then
					-- Matches!
					triggerID = i;
					break;
				end
			end
		end
		-- Now check the sequences for the one with this trigger ID.
		for i = 1, #(action["Sequences"]) do
			local seq = action["Sequences"][i];
			if(seq["Operators"] == tostring(triggerID)) then
				sequenceID = i;
				break;
			end
		end
	end
	-- Return our findings.
	return actionID, triggerID, sequenceID;
end