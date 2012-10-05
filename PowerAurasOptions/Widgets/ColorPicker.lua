-- Lock down local environment.
local PowerAuras = _G["PowerAuras"];
setfenv(1, PowerAuras);

--- Color picker widget, displays a box with a color.
local ColorPicker = PowerAuras:RegisterWidget("ColorPicker", "ReusableWidget");

--- Constructs or recycles an instance of the class.
-- @param parent The parent frame.
function ColorPicker:New(parent)
	-- Recycle frame.
	local frame = base(self);
	if(not frame) then
		-- Construct frame.
		frame = CreateFrame("Button", nil, UIParent);
		-- Add a color swatch.
		frame.Swatch = CreateFrame("Frame", nil, frame);
		frame.Swatch:SetSize(16, 16);
		frame.Swatch:SetPoint("LEFT", 0, 0);
		frame.Swatch:SetBackdrop({
			bgFile   = [[Interface\Buttons\WHITE8X8]],
			edgeFile = [[Interface\Buttons\WHITE8X8]],
			edgeSize = 1,
			tile     = true,
		});
		frame.Swatch:SetBackdropColor(1.0, 1.0, 1.0, 0.5);
		frame.Swatch:SetBackdropBorderColor(0.3, 0.3, 0.3, 1.0);
		-- Fonts.
		frame:SetNormalFontObject(GameFontNormal);
		frame:SetHighlightFontObject(GameFontHighlight);
		-- Text label.
		frame.Text = frame:CreateFontString(nil, "OVERLAY");
		frame.Text:SetPoint("LEFT", 20, 0);
		frame.Text:SetPoint("RIGHT", 0, 0);
		frame.Text:SetJustifyH("LEFT");
		frame.Text:SetJustifyV("MIDDLE");
		frame.Text:SetHeight(16);
		frame.Text:SetFontObject(GameFontNormal);
		frame:SetFontString(frame.Text);
		-- Callbacks.
		frame.OnValueUpdated = PowerAuras.Callback();
	end
	return frame;
end

--- Initialises the color picker widget.
-- @param parent The parent frame.
function ColorPicker:Initialise(parent)
	-- Widget has a fixed height and an expandable width.
	self:SetParent(parent);
	self:SetFixedHeight(22);
	self:SetRelativeWidth(0.3);
	self:SetText(COLOR);
	self:RegisterForClicks("AnyUp");
	-- Color storage.
	self.R, self.G, self.B, self.A = 1, 1, 1, 1;
	self.PickerOpacity = false;
	self.Restore = {};
	-- Connect to our own callback (seriously).
	self.OnValueUpdated:Connect(self.SetColor);
	self:SetColor(self.R, self.G, self.B, self.A);
	-- Generate a callback function for the color picker frame.
	self.ColorCallback = self.ColorCallback or function(restore)
		-- Fire our own callback for this.
		local r, g, b = ColorPickerFrame:GetColorRGB();
		self:OnValueUpdated(r, g, b, OpacitySliderFrame:GetValue() or 0);
	end;
	-- Workaround for broken cancelFunc.
	self.CancelCallback = self.CancelCallback or function()
		self:OnValueUpdated(unpack(self.Restore));
	end;
end

--- Returns the color and alpha stored on the widget.
function ColorPicker:GetColor()
	return self.R, self.G, self.B, self.A;
end

--- Returns true if opacity editing is enabled. If a value is passed, this
--  will instead set the flag to true/false based on the value.
-- @param value True to enable opacity editing, false to disable it.
function ColorPicker:HasOpacity(value)
	if(value == nil) then
		return self.PickerOpacity;
	else
		self.PickerOpacity = not not value;
	end
end

--- OnClick script handler.
function ColorPicker:OnClick(button)
	if(button == "LeftButton") then
		-- Store color.
		self.Restore[1] = self.R;
		self.Restore[2] = self.G;
		self.Restore[3] = self.B;
		self.Restore[4] = self.A;
		-- Get the color picker frame set up and shown.
		ColorPickerFrame:SetColorRGB(self.R, self.G, self.B);
		ColorPickerFrame.hasOpacity = self.PickerOpacity;
		ColorPickerFrame.opacity = self.A;
		-- Connect functions.
		ColorPickerFrame.func        = self.ColorCallback;
		ColorPickerFrame.opacityFunc = self.ColorCallback;
		ColorPickerFrame.cancelFunc  = self.CancelCallback;
		-- Force the OnShow script to fire.
		ColorPickerFrame:Hide();
		ColorPickerFrame:Show();
	elseif(button == "RightButton") then
		-- Restore to white.
		self.R, self.G, self.B, self.A = 1, 1, 1, 1;
		self:OnValueUpdated(1, 1, 1, 1);
	end
end

--- Recycles the widget, allowing it to be reused.
function ColorPicker:Recycle()
	-- Disconnect callbacks.
	self.OnValueUpdated:Reset();
	base(self);
end

--- Sets the color displayed on the widget.
-- @param r The red component.
-- @param g The green component.
-- @param b The blue component.
-- @param a The alpha component.
function ColorPicker:SetColor(r, g, b, a)
	-- Unpack colour if table.
	if(type(r) == "table" and #(r) >= 3) then
		r, g, b, a = unpack(r);
	end
	-- Store color.
	self.R = math.max(math.min(r or 1, 1), 0);
	self.G = math.max(math.min(g or 1, 1), 0);
	self.B = math.max(math.min(b or 1, 1), 0);
	self.A = math.max(math.min(a or 1, 1), 0);
	-- Update the swatch.
	self.Swatch:SetBackdropColor(self.R, self.G, self.B, self.A);
end