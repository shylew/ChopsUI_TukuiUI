-- Lock down local environment.
local PowerAuras = _G["PowerAuras"];
setfenv(1, PowerAuras);

--- Creates the Trigger editor for the Custom Trigger editor.
-- @param frame The frame to populate.
-- @param node  The current node.
function PowerAuras:CreateCustomTriggerEditor(frame, node)
	-- Get the trigger data.
	local _, id = PowerAuras:SplitNodeID(node);
	local vars = self.GlobalSettings.Triggers[id];

	-- Add checkboxes for basic settings.
	local timed = PowerAuras:Create("Checkbox", frame);
	timed:SetUserTooltip("CT_Timed");
	timed:SetRelativeWidth(1 / 3);
	timed:SetPadding(4, 0, 2, 0);
	timed:SetText(L["CT_Timed"]);
	timed:SetChecked(vars.Timed);
	timed.OnValueUpdated:Connect(function(self, state)
		vars.Timed = state;
	end);
	frame:AddWidget(timed);

	local toggle = PowerAuras:Create("Checkbox", frame);
	toggle:SetUserTooltip("CT_ToggleTimed");
	toggle:SetRelativeWidth(1 / 3);
	toggle:SetPadding(2, 0, 2, 0);
	toggle:SetText(L["CT_ToggleTimed"]);
	toggle:SetChecked(vars.ToggleTimed);
	toggle.OnValueUpdated:Connect(function(self, state)
		vars.ToggleTimed = state;
	end);
	frame:AddWidget(toggle);

	local lazy = PowerAuras:Create("Checkbox", frame);
	lazy:SetUserTooltip("CT_Lazy");
	lazy:SetRelativeWidth(1 / 3);
	lazy:SetPadding(2, 0, 4, 0);
	lazy:SetText(L["CT_Lazy"]);
	lazy:SetChecked(vars.Lazy);
	lazy.OnValueUpdated:Connect(function(self, state)
		vars.Lazy = state;
	end);
	frame:AddWidget(lazy);
	frame:AddRow(4);

	-- And a codebox for the code.
	local code = PowerAuras:Create("CodeBox", frame);
	code:SetRelativeSize(1.0, 1.0);
	code:SetMargins(0, 0, 0, -56);
	code:SetPadding(4, 0, 4, 56);
	code:SetText(vars.New);
	frame:AddWidget(code);

	-- And a save button for the codebox.
	local apply = PowerAuras:Create("Button", frame);
	apply:SetPadding(2, 0, 4, 0);
	apply:SetText(L["Save"]);
	apply.OnClicked:Connect(function(self)
		vars.New = code.Edit:GetText();
	end);
	frame:AddRow(4);
	frame:AddStretcher();
	frame:AddWidget(apply);
end