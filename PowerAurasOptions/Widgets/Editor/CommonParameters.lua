-- Lock down local environment.
local PowerAuras = _G["PowerAuras"];
setfenv(1, PowerAuras);

-- This file is for parameter-editing controls that are used in one or more
-- places, or use enough code to warrant a separate type.

--- Generic parameter slider. Just add sugar!
local Slider = PowerAuras:RegisterWidget("P_Slider", "Slider");

function Slider:Initialise(parent)
	base(self, parent);
	-- Parameter data storage.
	self.Parameter = {};
end

function Slider:OnValueUpdatedHandler(value)
	local type, key = unpack(self.Parameter);
	PowerAuras:SetParameter(type, key, value, unpack(self.Parameter, 3));
end

function Slider:LinkParameter(type, key, ...)
	-- Update our current value.
	self:SetValue(PowerAuras:GetParameter(type, key, ...));
	-- Connect callback and parameter handlers.
	self.OnValueUpdated:Connect(self.OnValueUpdatedHandler);
	self:ConnectParameter(type, key, self.SetValue, ...);
	-- Store parameter data.
	self.Parameter[1], self.Parameter[2] = type, key;
	for i = 3, 2 + select("#", ...) do
		self.Parameter[i] = select(i - 2, ...);
	end
end

--- Slider for controlling alpha values.
local AlphaSlider = PowerAuras:RegisterWidget("P_AlphaSlider", "Slider");

function AlphaSlider:Initialise(parent)
	base(self, parent);
	-- Set default value caps/stepping for controlling this param.
	self:SetMinMaxValues(0, 100);
	self:SetValueStep(1);
	self:SetMinMaxLabels("%d%%", "%d%%");
	self:SetTitle(L["Alpha"]);
	-- Parameter data storage.
	self.Parameter = {};
end

function AlphaSlider:OnParameterUpdated(value)
	self:SetValue(value * 100);
end

function AlphaSlider:OnValueUpdatedHandler(value)
	local type, key = unpack(self.Parameter);
	PowerAuras:SetParameter(type, key, value / 100, unpack(self.Parameter, 3));
end

function AlphaSlider:LinkParameter(type, key, ...)
	-- Update our current value.
	self:SetValue(PowerAuras:GetParameter(type, key, ...) * 100);
	-- Connect callback and parameter handlers.
	self.OnValueUpdated:Connect(self.OnValueUpdatedHandler);
	self:ConnectParameter(type, key, self.OnParameterUpdated, ...);
	-- Store parameter data.
	self.Parameter[1], self.Parameter[2] = type, key;
	for i = 3, 2 + select("#", ...) do
		self.Parameter[i] = select(i - 2, ...);
	end
end

--- Slider for controlling scale values.
local ScaleSlider = PowerAuras:RegisterWidget("P_ScaleSlider", "Slider");

function ScaleSlider:Initialise(parent)
	base(self, parent);
	-- Set default value caps/stepping for controlling this param.
	self:SetMinMaxValues(1, 250);
	self:SetValueStep(1);
	self:SetMinMaxLabels("%d%%", "%d%%");
	self:SetTitle(L["Scale"]);
	-- Parameter data storage.
	self.Parameter = {};
end

function ScaleSlider:OnParameterUpdated(value)
	self:SetValue(value * 100);
end

function ScaleSlider:OnValueUpdatedHandler(value)
	local type, key = unpack(self.Parameter);
	PowerAuras:SetParameter(type, key, value / 100, unpack(self.Parameter, 3));
end

function ScaleSlider:LinkParameter(type, key, ...)
	-- Update our current value.
	self:SetValue(PowerAuras:GetParameter(type, key, ...) * 100);
	-- Connect callback and parameter handlers.
	self.OnValueUpdated:Connect(self.OnValueUpdatedHandler);
	self:ConnectParameter(type, key, self.OnParameterUpdated, ...);
	-- Store parameter data.
	self.Parameter[1], self.Parameter[2] = type, key;
	for i = 3, 2 + select("#", ...) do
		self.Parameter[i] = select(i - 2, ...);
	end
end

--- Colour picker for controlling tint colour.
local Tint = PowerAuras:RegisterWidget("P_ColorPicker", "ColorPicker");

function Tint:Initialise(parent)
	base(self, parent);
	self:HasOpacity(false);
	-- Parameter data storage.
	self.Parameter = {};
end

function Tint:OnValueUpdatedHandler(r, g, b)
	-- Reuse existing table.
	local color = PowerAuras:GetParameter(unpack(self.Parameter));
	color[1], color[2], color[3] = r, g, b;
	-- Update parameter.
	local type, key = unpack(self.Parameter);
	PowerAuras:SetParameter(type, key, color, unpack(self.Parameter, 3));
end

function Tint:LinkParameter(type, key, ...)
	-- Update our current value.
	self:SetColor(PowerAuras:GetParameter(type, key, ...));
	-- Connect callback and parameter handlers.
	self.OnValueUpdated:Connect(self.OnValueUpdatedHandler);
	self:ConnectParameter(type, key, self.SetColor, ...);
	-- Store parameter data.
	self.Parameter[1], self.Parameter[2] = type, key;
	for i = 3, 2 + select("#", ...) do
		self.Parameter[i] = select(i - 2, ...);
	end
end

--- Generic on/off checkbox.
local Checkbox = PowerAuras:RegisterWidget("P_Checkbox", "Checkbox");

function Checkbox:Initialise(parent)
	base(self, parent);
	-- Parameter data storage.
	self.Parameter = {};
end

function Checkbox:OnValueUpdatedHandler(state)
	-- Update parameter.
	local type, key = unpack(self.Parameter);
	PowerAuras:SetParameter(type, key, state, unpack(self.Parameter, 3));
end

function Checkbox:LinkParameter(type, key, ...)
	-- Update our current value.
	self:SetChecked(PowerAuras:GetParameter(type, key, ...));
	-- Connect callback and parameter handlers.
	self.OnValueUpdated:Connect(self.OnValueUpdatedHandler);
	self:ConnectParameter(type, key, self.SetChecked, ...);
	-- Store parameter data.
	self.Parameter[1], self.Parameter[2] = type, key;
	for i = 3, 2 + select("#", ...) do
		self.Parameter[i] = select(i - 2, ...);
	end
end

--- Numeric editbox for controlling size/offset values.
local NumberBox = PowerAuras:RegisterWidget("P_NumberBox", "NumberBox");

function NumberBox:Initialise(parent)
	base(self, parent);
	-- Parameter data storage.
	self.Parameter = {};
end

function NumberBox:OnParameterUpdated(value)
	value = (self.Parameter[3] == 0 and value or value[self.Parameter[3]]);
	self:SetValue(value);
end

function NumberBox:OnValueUpdatedHandler(value)
	local type, key = unpack(self.Parameter);
	-- Reuse table if it exists.
	if(self.Parameter[3] > 0) then
		local c = PowerAuras:GetParameter(type, key, unpack(self.Parameter, 4));
		c[self.Parameter[3]] = value;
		value = c;
	end
	PowerAuras:SetParameter(type, key, value, unpack(self.Parameter, 4));
end

function NumberBox:LinkParameter(type, key, index, ...)
	-- Update our current value.
	local value = PowerAuras:GetParameter(type, key, ...);
	self:SetValue((index == 0 and value or value[index]));
	-- Connect callback and parameter handlers.
	self.OnValueUpdated:Connect(self.OnValueUpdatedHandler);
	self:ConnectParameter(type, key, self.OnParameterUpdated, ...);
	-- Store parameter data.
	self.Parameter[1], self.Parameter[2], self.Parameter[3] = type, key, index;
	for i = 4, 3 + select("#", ...) do
		self.Parameter[i] = select(i - 3, ...);
	end
end

local SpeedBox = PowerAuras:RegisterWidget("P_SpeedBox", "P_NumberBox");

function SpeedBox:Initialise(parent, seconds)
	base(self, parent);
	-- Initialise caps.
	self.BaseSpeed = (seconds or 1);
	self:SetMinMaxValues(0.05, 60);
	self:SetValueStep(0.05);
	self:SetTitle(L["AnimSpeed"]);
	self:SetUserTooltip("AnimSpeed");
end

function SpeedBox:OnParameterUpdated(value)
	base(self, self.BaseSpeed * (1 / value));
end

function SpeedBox:OnValueUpdatedHandler(value)
	base(self, (self.BaseSpeed / value));
end

function SpeedBox:LinkParameter(type, key, index, ...)
	-- Update our current value.
	local value = PowerAuras:GetParameter(type, key, ...);
	value = (index == 0 and value or value[index]);
	self:SetValue(self.BaseSpeed * (1 / value));
	-- Connect callback and parameter handlers.
	self.OnValueUpdated:Connect(self.OnValueUpdatedHandler);
	self:ConnectParameter(type, key, self.OnParameterUpdated, ...);
	-- Store parameter data.
	self.Parameter[1], self.Parameter[2], self.Parameter[3] = type, key, index;
	for i = 4, 3 + select("#", ...) do
		self.Parameter[i] = select(i - 3, ...);
	end
end

--- Dropdown template. Based off of SimpleDropdown.
local Dropdown = PowerAuras:RegisterWidget("P_Dropdown", "SimpleDropdown");

function Dropdown:Initialise(parent)
	base(self, parent);
	-- Parameter data storage.
	self.Parameter = {};
end

function Dropdown:OnValueUpdatedHandler(value)
	-- Update parameter.
	local type, key = unpack(self.Parameter);
	-- Close menu, update checked items.
	self:CloseMenu();
	for _, item in pairs(self.ItemsByKey) do
		if(item.Type == "Check") then
			self:SetItemChecked(item.Key, item.Key == value);
		end
	end
	-- Set the parameter.
	PowerAuras:SetParameter(type, key, value, unpack(self.Parameter, 3));
end

function Dropdown:LinkParameter(type, key, ...)
	-- Update our current value.
	local current = PowerAuras:GetParameter(type, key, ...);
	self:SetText(current);
	if(self.ItemsByKey[current].Type == "Check") then
		self:SetItemChecked(current, true);
	end
	-- Connect callback and parameter handlers.
	self.OnValueUpdated:Connect(self.OnValueUpdatedHandler);
	self:ConnectParameter(type, key, self.SetText, ...);
	-- Store parameter data.
	self.Parameter[1], self.Parameter[2] = type, key;
	for i = 3, 2 + select("#", ...) do
		self.Parameter[i] = select(i - 2, ...);
	end
end

--- Dropdown for controlling the strata of a display. Inherits P_Dropdown,
--  just adds items to it for you!
local Strata = PowerAuras:RegisterWidget("P_StrataDropdown", "P_Dropdown");

function Strata:Initialise(parent)
	base(self, parent);
	self:SetTitle(L["Strata"]);
	self:AddCheckItem("BACKGROUND", L["Background"]);
	self:AddCheckItem("LOW", L["Low"]);
	self:AddCheckItem("MEDIUM", L["Medium"]);
	self:AddCheckItem("HIGH", L["High"]);
end

--- Dropdown for controlling the blend mode of a display. Inherits P_Dropdown,
--  just adds items to it for you!
local Blend = PowerAuras:RegisterWidget("P_BlendDropdown", "P_Dropdown");

function Blend:Initialise(parent)
	base(self, parent);
	self:SetTitle(L["Blend"]);
	self:AddCheckItem("BLEND", DEFAULT);
	self:AddCheckItem("ADD", L["Glow"]);
	self:AddCheckItem("MOD", L["Mod"]);
end

--- Dropdown for selecting an operator. Inherits P_Dropdown.
local Operator = PowerAuras:RegisterWidget("P_OperatorDropdown", "P_Dropdown");

function Operator:Initialise(parent)
	base(self, parent);
	self:SetTitle(L["Operator"]);
	for i = 1, #(PowerAuras.Operators) do
		self:AddCheckItem(PowerAuras.Operators[i], PowerAuras.Operators[i]);
	end
end

--- Dropdown for selecting a unit.
local Unit = PowerAuras:RegisterWidget("P_UnitDropdown", "P_Dropdown");

--- Checks if the passed arguments contain a certain value.
-- @param match The value to find.
-- @param ...   The values to iterate over.
local function varContains(match, ...)
	for i = 1, select("#", ...) do
		if(select(i, ...) == match) then
			return true;
		end
	end
	return false;
end

function Unit:Initialise(parent, mode, ...)
	base(self, parent);
	self:SetTitle(L["Unit"]);
	-- Default mode to 1.
	mode = mode or 1;
	-- All units.
	local allowSection = (mode ~= 3 or varContains("Single", ...));
	for i = 1, #(PowerAuras.SingleUnitIDs) do
		local unit = PowerAuras.SingleUnitIDs[i];
		if(allowSection or varContains(unit, ...)) then
			self:AddCheckItem(unit, L["Units"][unit]);
		end
	end
	-- Move on to group ones.
	local allowSection = (mode ~= 3 or varContains("Group", ...));
	for group, units in PowerAuras:ByKey(PowerAuras.GroupUnitIDs) do
		-- Add the group.
		self:AddMenu(group, L["Units"][group]);
		-- Allowing group specifiers?
		if(allowSection and mode ~= 1
			or varContains(("%s-spec"):format(group), ...)) then
			-- Split the menu up.
			self:AddLabel(
				("_%s_H1"):format(group), L["Group"], group
			);
			-- Add all unit.
			local unit = ("%s-all"):format(group);
			if(allowSection or varContains(unit, ...)) then
				self:AddCheckItem(
					unit, L["Units"][unit], false, nil, group
				);
			end
			-- Any unit.
			local unit = ("%s-any"):format(group);
			if(allowSection or varContains(unit, ...)) then
				self:AddCheckItem(
					unit, L["Units"][unit], false, nil, group
				);
			end
			-- Add label for individuals.
			self:AddLabel(
				("_%s_H2"):format(group), L["Individuals"], group
			);
		end
		-- Allow units?
		local allowSection = (allowSection
			or varContains(("%s-units"):format(group), ...));
		-- Iterate over units.
		for i = 1, #(units) do
			local unit = units[i];
			if(allowSection or varContains(unit, ...)) then
				self:AddCheckItem(
					unit, L["Units"][unit], false, nil, group
				);
			end
		end
		-- Did we actually add anything?
		if(self:GetItemCount(group) == 0) then
			self:RemoveItem(group);
		end
	end
end

--- Dropdown for controlling anchoring points.
local Anchor = PowerAuras:RegisterWidget("P_AnchorDropdown", "P_Dropdown");

function Anchor:Initialise(parent)
	base(self, parent);
	self:AddCheckItem("TOPLEFT", L["TOPLEFT"]);
	self:AddCheckItem("TOP", L["TOP"]);
	self:AddCheckItem("TOPRIGHT", L["TOPRIGHT"]);
	self:AddCheckItem("LEFT", L["LEFT"]);
	self:AddCheckItem("CENTER", L["CENTER"]);
	self:AddCheckItem("RIGHT", L["RIGHT"]);
	self:AddCheckItem("BOTTOMLEFT", L["BOTTOMLEFT"]);
	self:AddCheckItem("BOTTOM", L["BOTTOM"]);
	self:AddCheckItem("BOTTOMRIGHT", L["BOTTOMRIGHT"]);
end

function Anchor:OnParameterUpdated(value)
	local type, key, index = unpack(self.Parameter);
	self:SetText(value[index]);
end

function Anchor:OnValueUpdatedHandler(value)
	-- Update parameter.
	local type, key, index = unpack(self.Parameter);
	-- Close menu, update checked items.
	self:CloseMenu();
	for _, item in pairs(self.ItemsByKey["__ROOT__"]) do
		if(item.Type == "Check") then
			self:SetItemChecked(item.Key, item.Key == value);
		end
	end
	-- Get existing parameter.
	local data = PowerAuras:GetParameter(type, key, unpack(self.Parameter, 4));
	data[index] = value;
	-- Set the parameter.
	PowerAuras:SetParameter(type, key, data, unpack(self.Parameter, 4));
end

function Anchor:LinkParameter(type, key, index, ...)
	-- Update our current value.
	local current = PowerAuras:GetParameter(type, key, ...);
	self:SetText(current[index]);
	if(self.ItemsByKey[current[index]].Type == "Check") then
		self:SetItemChecked(current[index], true);
	end
	-- Connect callback and parameter handlers.
	self.OnValueUpdated:Connect(self.OnValueUpdatedHandler);
	self:ConnectParameter(type, key, self.OnParameterUpdated, ...);
	-- Store parameter data.
	self.Parameter[1], self.Parameter[2], self.Parameter[3] = type, key, index;
	for i = 4, 3 + select("#", ...) do
		self.Parameter[i] = select(i - 3, ...);
	end
end

--- Generic editbox. Somewhat boring.
local EditBox = PowerAuras:RegisterWidget("P_EditBox", "EditBox");

function EditBox:Initialise(parent)
	base(self, parent);
	-- Parameter data storage.
	self.Parameter = {};
end

function EditBox:OnValueUpdatedHandler(value)
	-- Update parameter.
	local type, key = unpack(self.Parameter);
	PowerAuras:SetParameter(type, key, value, unpack(self.Parameter, 3));
end

function EditBox:LinkParameter(type, key, ...)
	-- Update our current value.
	self:SetText(PowerAuras:GetParameter(type, key, ...));
	-- Connect callback and parameter handlers.
	self.OnValueUpdated:Connect(self.OnValueUpdatedHandler);
	self:ConnectParameter(type, key, self.SetText, ...);
	-- Store parameter data.
	self.Parameter[1], self.Parameter[2] = type, key;
	for i = 3, 2 + select("#", ...) do
		self.Parameter[i] = select(i - 2, ...);
	end
end