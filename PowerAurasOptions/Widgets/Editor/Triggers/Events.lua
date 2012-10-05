-- Lock down local environment.
local PowerAuras = _G["PowerAuras"];
setfenv(1, PowerAuras);

--- Current event shown in the edtiro.
local CurrentEvent;

--- Called when the current dropdown value is updated.
-- @param frame The dropdown frame.
-- @param key   The selected key.
local function OnDropdownValueUpdated(frame, key)
	-- Adding an event, or just selecting?
	local vars = PowerAuras.GlobalSettings.Triggers[frame:GetID()];
	if(key == -1) then
		-- Generate a unique name.
		local template, i = ("New_Event_%d"), 1;
		while(vars.Events[template:format(i)]) do
			i = i + 1;
		end
		-- Add the event and select it.
		local name = template:format(i);
		vars.Events[name] = true;
		CurrentEvent = name;
	else
		-- Just selecting an event.
		CurrentEvent = key;
	end
	-- Refresh the frame.
	PowerAuras.Editor.Triggers:RefreshHost(
		PowerAuras.Editor.Triggers:GetCurrentNode()
	);
end

--- Creates the Events editor for the Custom Trigger editor.
-- @param frame The frame to populate.
-- @param node  The current node.
function PowerAuras:CreateCustomTriggerEventsEditor(frame, node)
	-- Get the trigger data.
	local _, id = PowerAuras:SplitNodeID(node);
	local vars = self.GlobalSettings.Triggers[id];

	-- Update the selected event.
	CurrentEvent = (vars.Events[CurrentEvent] and CurrentEvent
		or next(vars.Events));

	-- Add a dropdown for event selection.
	local events = PowerAuras:Create("SimpleDropdown", frame);
	events:SetUserTooltip("CT_Events");
	events:SetRelativeWidth(0.5);
	events:SetPadding(4, 0, 2, 0);
	events:SetTitle(L["CT_Events"]);
	events:SetID(id);
	events.OnValueUpdated:Connect(OnDropdownValueUpdated);
	-- Add events to the widget.
	for event, _ in PowerAuras:ByKey(vars.Events) do
		events:AddCheckItem(event, event, CurrentEvent == event);
	end
	-- Update the text.
	if(CurrentEvent) then
		events:SetText(CurrentEvent);
	else
		events:SetRawText(L["None"]);
	end
	-- Add a New Event button.
	events:AddItem(-1, L["NewEvent"],
		[[Interface\PaperDollInfoFrame\Character-Plus]]);
	-- Add widget to frame.
	frame:AddWidget(events);

	-- Only continue if an event is selected.
	if(CurrentEvent) then
		-- Add a delete event button.
		local delete = PowerAuras:Create("IconButton", frame);
		delete:SetUserTooltip("CT_DeleteEvent");
		delete:SetPadding(2, 0, 2, 0);
		delete:SetMargins(0, 20, 0, 0);
		delete:SetIcon([[Interface\PetBattles\DeadPetIcon]]);
		delete.OnClicked:Connect(function()
			-- Delete the event and refresh the frame.
			if(CurrentEvent and vars.Events[CurrentEvent]) then
				vars.Events[CurrentEvent] = nil;
			end
			frame:RefreshHost(node);
		end);
		frame:AddWidget(delete);

		-- Add an automatic handler checkbox.
		local auto = PowerAuras:Create("Checkbox", frame);
		auto:SetUserTooltip("CT_AutoEvent");
		auto:SetPadding(2, 0, 28, 0);
		auto:SetRelativeWidth(0.5);
		auto:SetMargins(0, 20, -24, 0);
		auto:SetText(L["Automatic"]);
		auto:SetChecked(vars.Events[CurrentEvent] == true);
		auto.OnValueUpdated:Connect(function(_, state)
			-- If enabling auto mode, just replace the event.
			if(state) then
				vars.Events[CurrentEvent] = true;
			else
				-- Template handler.
				vars.Events[CurrentEvent] = ([[
-- Event handler arguments.
-- Additional event arguments are located
-- in indexes 2 .. n
local buffer = ...;

-- Internal trigger type name.
local name = %q;

-- Flag this trigger when this event fires.
buffer:FlagTrigger(name);
				]]):format(vars.Type);
			end
			-- Refresh the frame.
			frame:RefreshHost(node);
		end);
		frame:AddWidget(auto);

		-- Event name.
		local name = PowerAuras:Create("EditBox", frame);
		name:SetUserTooltip("CT_EventName");
		name:SetRelativeWidth(1.0);
		name:SetPadding(4, 0, 4, 0);
		name:SetTitle(L["CT_EventName"]);
		name:SetText(CurrentEvent);
		name.OnValueUpdated:Connect(function(_, value)
			-- Trim the value up.
			value = value:trim();
			-- Make sure no event with this name exists.
			if(vars.Events[value]) then
				PowerAuras:PrintError(L("EventExists", value));
				return;
			end
			-- Just change the keys around and refresh.
			vars.Events[value] = vars.Events[CurrentEvent];
			vars.Events[CurrentEvent] = nil;
			CurrentEvent = value;
			frame:RefreshHost(node);
		end);
		frame:AddWidget(name);

		-- And if not in automatic mode, put in a codebox.
		if(vars.Events[CurrentEvent] ~= true) then
			-- Codebox.
			local code = PowerAuras:Create("CodeBox", frame);
			code:SetRelativeSize(1.0, 1.0);
			code:SetPadding(4, 0, 4, 120);
			code:SetMargins(0, 0, 0, -120);
			code:SetText(vars.Events[CurrentEvent]);
			frame:AddWidget(code);

			-- Save button.
			local apply = PowerAuras:Create("Button", frame);
			apply:SetPadding(2, 0, 4, 0);
			apply:SetText(L["Save"]);
			apply.OnClicked:Connect(function(self)
				vars.Events[CurrentEvent] = code.Edit:GetText();
			end);
			frame:AddRow(4);
			frame:AddStretcher();
			frame:AddWidget(apply);
		end
	end
end