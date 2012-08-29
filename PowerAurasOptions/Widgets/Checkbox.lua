-- Lock down local environment.
local PowerAuras = _G["PowerAuras"];
setfenv(1, PowerAuras);

--- Checkbox widget, for controlling values with a simple on/off control.
local Checkbox = PowerAuras:RegisterWidget("Checkbox", "ReusableWidget");

--- Constructs a new instance of the Checkbox widget.
-- @param parent The parent of the widget.
function Checkbox:New(parent)
	-- Try to recycle.
	local frame = base(self);
	if(not frame) then
		-- Construct a new frame then.
		frame = CreateFrame("CheckButton", nil, parent or UIParent);
		frame:SetNormalFontObject(GameFontNormal);
		frame:SetDisabledFontObject(GameFontNormal);
		frame:SetHighlightFontObject(GameFontHighlight);
		frame:SetNormalTexture([[Interface\Buttons\UI-CheckBox-Up]]);
		frame:GetNormalTexture():SetSize(24, 24);
		frame:GetNormalTexture():ClearAllPoints();
		frame:GetNormalTexture():SetPoint("TOPLEFT", 0, 0);
		frame:SetCheckedTexture([[Interface\Buttons\UI-CheckBox-Check]]);
		frame:GetCheckedTexture():SetSize(24, 24);
		frame:GetCheckedTexture():ClearAllPoints();
		frame:GetCheckedTexture():SetPoint("TOPLEFT", 0, 0);
		-- Add text label.
		frame.Text = frame:CreateFontString(nil, "OVERLAY");
		frame.Text:SetJustifyH("LEFT");
		frame.Text:SetJustifyV("MIDDLE");
		frame.Text:SetWordWrap(false);
		frame.Text:SetPoint("TOPLEFT", frame, "TOPLEFT", 26, 0);
		frame.Text:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -4, 0);
		frame:SetFontString(frame.Text);
		-- Callback object.
		frame.OnValueUpdated = PowerAuras:Callback();
	end
	-- Done.
	frame.LastValue = nil;
	frame:SetParent(parent or UIParent);
	return frame;
end

--- Called when the frame has been constructed. Updates the size of the widget.
function Checkbox:Initialise()
	self:SetFixedSize(150, 24);
end

--- Called when the checkbox is clicked. Fires the callback.
function Checkbox:OnClick()
	PlaySound("UChatScrollButton");
	self:OnValueUpdated(not not self:GetChecked());
end

--- Called when the checkbox is disabled. Updates the checked texture.
function Checkbox:OnDisable()
	self:GetCheckedTexture():SetTexture(
		[[Interface\Buttons\UI-CheckBox-Check-Disabled]]
	);
end

--- Called when the checkbox is enabled. Updates the checked texture.
function Checkbox:OnEnable()
	self:GetCheckedTexture():SetTexture(
		[[Interface\Buttons\UI-CheckBox-Check]]
	);
end

--- Recycles the widget, allowing it to be reused in the future.
function Checkbox:Recycle()
	-- Clear all functions on our callback.
	self.OnValueUpdated:Reset();
	self:SetChecked(false);
	-- Reset labels.
	self:SetText(nil);
	base(self);
end

--- Sets the text label of the widget.
-- @param text The text to set.
-- @param ...  Substitutions to perform.
function Checkbox:SetText(text, ...)
	self:__SetText(tostring(text):format(tostringall(...)));
end

--- Tristate checkbox implementation.
local TriCheckbox = PowerAuras:RegisterWidget("TriCheckbox", "Checkbox");

--- Initialises the checkbox.
function TriCheckbox:Initialise()
	base(self);
	self.State = -1;
end

--- Returns the checkbox state.
function TriCheckbox:GetState()
	return self.State;
end

--- Called when the checkbox is clicked. Fires the callback.
function TriCheckbox:OnClick()
	PlaySound("UChatScrollButton");
	-- Toggle state.
	if(self.State == -1) then
		self:SetState(1);
	else
		self:SetState(self.State - 1);
	end
	-- Fire callbacks.
	self:OnValueUpdated(self.State);
end

--- Sets the state of the checkbox.
-- @param state The state integer. -1 is indeterminate, 0 is false, 1 is true.
function TriCheckbox:SetState(state)
	self.State = tonumber(state)
		or state == true and 1
		or state == false and 0
		or -1;
	-- Update the checked state.
	self:SetChecked(self.State > -1);
	if(self.State > -1) then
		-- Update the image if checked.
		if(self.State == 1) then
			self:GetCheckedTexture():SetTexture(
				[[Interface\RaidFrame\ReadyCheck-Ready]]
			);
		else
			self:GetCheckedTexture():SetTexture(
				[[Interface\RaidFrame\ReadyCheck-NotReady]]
			);
		end
	end
end