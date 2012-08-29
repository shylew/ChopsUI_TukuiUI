-- Lock down local environment.
local PowerAuras = _G["PowerAuras"];
setfenv(1, PowerAuras);

--- Slider widget, for controlling values with a slider and textbox.
local Slider = PowerAuras:RegisterWidget("Slider", "ReusableWidget");

--- Constructs a new instance of the slider widget.
-- @param parent The parent of the widget.
function Slider:New(parent)
	-- Try to recycle.
	local frame = base(self);
	if(not frame) then
		-- Construct a new frame then.
		frame = CreateFrame("Slider", nil, parent or UIParent);
		frame:EnableMouseWheel(true);
		frame:SetHitRectInsets(0, 0, -14, -15);
		frame:SetValue(50);
		frame:SetMinMaxValues(0, 100);
		frame:SetValueStep(1);
		frame:SetOrientation("HORIZONTAL");
		frame:SetBackdrop({
			bgFile = [[Interface\Buttons\UI-SliderBar-Background]],
			edgeFile = [[Interface\Buttons\UI-SliderBar-Border]],
			tile = true,
			edgeSize = 8,
			tileSize = 8,
			insets = { left = 3, right = 3, top = 6, bottom = 6 },
		});
		-- Add min/max labels to the frame.
		frame.MinLabel = frame:CreateFontString(nil, "OVERLAY");
		frame.MinLabel:SetFontObject(GameFontHighlightSmall);
		frame.MinLabel:SetSize(0, 14);
		frame.MinLabel:SetWordWrap(false);
		frame.MinLabel:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, -1);
		frame.MaxLabel = frame:CreateFontString(nil, "OVERLAY");
		frame.MaxLabel:SetFontObject(GameFontHighlightSmall);
		frame.MaxLabel:SetSize(0, 14);
		frame.MaxLabel:SetWordWrap(false);
		frame.MaxLabel:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", 0, -1);
		-- Title label.
		frame.Title = frame:CreateFontString(nil, "OVERLAY");
		frame.Title:SetFontObject(GameFontNormal);
		frame.Title:SetSize(0, 14);
		frame.Title:SetWordWrap(false);
		frame.Title:SetPoint("BOTTOM", frame, "TOP");
		-- Slider thumb texture.
		frame.Thumb = frame:CreateTexture(nil, "ARTWORK");
		frame.Thumb:SetSize(32, 32);
		frame.Thumb:SetTexture(
			[[Interface\Buttons\UI-SliderBar-Button-Horizontal]]
		);
		frame:SetThumbTexture(frame.Thumb);
		-- Editbox.
		frame.Edit = CreateFrame("EditBox", nil, frame);
		frame.Edit:SetAutoFocus(false);
		frame.Edit:SetNumeric(false);
		frame.Edit:SetJustifyH("CENTER");
		frame.Edit:SetFontObject(GameFontHighlightSmall);
		frame.Edit:SetSize(70, 14);
		frame.Edit:SetPoint("TOP", frame, "BOTTOM", 0, -1);
		frame.Edit:SetTextInsets(4, 4, 0, 0);
		frame.Edit:SetBackdrop({
			bgFile = [[Interface\ChatFrame\ChatFrameBackground]],
			edgeFile = [[Interface\ChatFrame\ChatFrameBackground]],
			tile = true,
			edgeSize = 1,
			tileSize = 5,
		});
		frame.Edit:SetBackdropColor(0, 0, 0, 1);
		frame.Edit:SetBackdropBorderColor(0.3, 0.3, 0.3, 1.0);
		-- Connect editbox events.
		frame.Edit:SetScript("OnEnterPressed", self.OnEditEnterPressed);
		frame.Edit:SetScript("OnEscapePressed", self.OnEditEscapePressed);
		frame.Edit:SetScript("OnEditFocusLost", self.OnEditFocusLost);
		frame.Edit:SetScript("OnEditFocusGained", self.OnEditFocusGained);
		-- Callback object.
		frame.OnValueUpdated = PowerAuras:Callback();
	end
	-- Reset our data storage.
	frame.CustomLabelMin = "%d";
	frame.CustomLabelMax = "%d";
	frame.LastValue = nil;
	-- Done.
	frame:SetParent(parent or UIParent);
	return frame;
end

--- Called when the frame has been constructed. Updates the size of the slider.
function Slider:Initialise()
	self:SetMargins(0, 17, 0, 22);
	self:SetFixedSize(150, 15);
end

--- Called when the enter key is pressed inside of the editbox.
-- @remarks self points to the editbox, not the slider instance.
function Slider:OnEditEnterPressed()
	local slider = self:GetParent();
	slider:SetValue(tonumber(self:GetText()) or slider:GetValue());
	self:ClearFocus();
end

--- Called when the escape key is pressed inside of the editbox.
-- @remarks self points to the editbox, not the slider instance.
function Slider:OnEditEscapePressed()
	local slider = self:GetParent();
	self:SetText(tostring(slider:GetValue()));
	self:ClearFocus();
end

--- Called when the slider editbox gains focus.
-- @remarks self points to the editbox, not the slider instance.
function Slider:OnEditFocusGained()
	self:HighlightText(0, -1);
end

--- Called when the slider editbox loses focus.
-- @remarks self points to the editbox, not the slider instance.
function Slider:OnEditFocusLost()
	local slider = self:GetParent();
	self:HighlightText(0, 0);
	self:SetText(tostring(slider:GetValue()));
end

--- Script handler for min/max value range changes.
-- @param min The new minimum range.
-- @param min The new maximum range.
function Slider:OnMinMaxChanged(min, max)
	-- Update the labels.
	self.MinLabel:SetText(self.CustomLabelMin:format(min));
	self.MaxLabel:SetText(self.CustomLabelMax:format(max));
end

--- Script handler for mousewheel events.
-- @param delta The mousewheel delta.
function Slider:OnMouseWheel(delta)
	if(delta > 0) then
		self:SetValue(self:GetValue() + self:GetValueStep());
	else
		self:SetValue(self:GetValue() - self:GetValueStep());
	end
end

--- Script handler for when the value of the slider changes.
-- @param value The new slider value.
function Slider:OnValueChanged(value)
	if(value ~= self.LastValue) then
		-- Update editbox.
		if(value ~= math.floor(value)) then
			self.Edit:SetText(("%.2f"):format(tostring(value)));
		else
			self.Edit:SetText(tostring(value));
		end
		self.LastValue = value;
		self:OnValueUpdated(value);
	end
end

--- Recycles the widget, allowing it to be reused in the future.
function Slider:Recycle()
	-- Clear all functions on our callback.
	self.OnValueUpdated:Reset();
	-- Reset labels.
	self:SetMinMaxLabels(nil, nil);
	self:SetTitle(nil);
	base(self);
end

--- Sets the maximum label string to use. If nil, this will default to "%d".
--  The maximum range can be substituted in via %d.
-- @param max The maximum label.
function Slider:SetMaxLabel(max)
	self.CustomLabelMax = (max or "%g");
	local _, max = self:GetMinMaxValues();
	self.MaxLabel:SetText(self.CustomLabelMax:format(max));
end

--- Sets the minimum label string to use. If nil, this will default to "%d".
--  The minimum range can be substituted in via %d.
-- @param min The minimum label.
function Slider:SetMinLabel(min)
	self.CustomLabelMin = (min or "%g");
	local min = self:GetMinMaxValues();
	self.MinLabel:SetText(self.CustomLabelMin:format(min));
end

--- Sets both the minimum and maximum labels of the slider bar.
-- @param min The minimum label.
-- @param max The maximum label.
function Slider:SetMinMaxLabels(min, max)
	self:SetMinLabel(min);
	self:SetMaxLabel(max);
end

--- Sets the title label of the slider.
-- @param title The title text.
-- @param ...   Substitutions to perform.
function Slider:SetTitle(title, ...)
	self.Title:SetText(tostring(title):format(tostringall(...)));
end