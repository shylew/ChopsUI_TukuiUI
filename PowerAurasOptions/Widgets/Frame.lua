-- Lock down local environment.
local PowerAuras = _G["PowerAuras"];
setfenv(1, PowerAuras);

--- Basic frame widget, does nothing special.
local Frame = PowerAuras:RegisterWidget("Frame", "Container");

--- Creates a new instance of the widget and returns the frame.
-- @param parent The parent frame.
function Frame:New(parent)
	-- Create and return.
	return CreateFrame("Frame", nil, parent or UIParent);
end

--- Basic frame with a title region and optional icon/description.
local TitledFrame = PowerAuras:RegisterWidget("TitledFrame", "Frame");

--- Creates a new instance of the widget and returns the frame.
-- @param parent The parent frame.
function TitledFrame:New(parent, title, desc, icon)
	-- Create the frame.
	local frame = base(self, parent);
	-- Add title text.
	frame.Title = frame:CreateFontString(nil, "OVERLAY");
	frame.Title:SetFontObject(GameFontNormalLarge);
	frame.Title:SetSize(1, 16);
	frame.Title:SetJustifyH("LEFT");
	frame.Title:SetJustifyV("MIDDLE");
	frame.Title:SetPoint("TOPLEFT", (not icon and 15 or 70), -15);
	frame.Title:SetPoint("TOPRIGHT", -15, -15);
	-- Description text.
	frame.Description = frame:CreateFontString(nil, "OVERLAY");
	frame.Description:SetFontObject(GameFontHighlightSmall);
	frame.Description:SetSize(1, 36);
	frame.Description:SetJustifyH("LEFT");
	frame.Description:SetJustifyV("TOP");
	frame.Description:SetPoint("TOPLEFT", (not icon and 15 or 70), -40);
	frame.Description:SetPoint("TOPRIGHT", -15, -40);
	-- Icon.
	frame.Icon = frame:CreateTexture(nil, "ARTWORK");
	frame.Icon:SetSize(48, 48);
	frame.Icon:SetPoint("TOPLEFT", 15, -15);
	-- Set data.
	self.SetTitle(frame, title);
	self.SetDescription(frame, desc);
	self.SetIcon(frame, icon);
	-- Return the frame.
	return frame;
end

--- Sets the description text on the frame.
-- @param desc The text to set, or a localization key.
-- @param ...  Arguments to pass to string.format.
function TitledFrame:SetDescription(desc, ...)
	self.Description:SetText(tostring(desc):format(tostringall(...)));
end

--- Sets the title text on the frame.
-- @param title The text to set, or a localization key.
-- @param ...   Arguments to pass to string.format.
function TitledFrame:SetTitle(title, ...)
	self.Title:SetText(tostring(title):format(tostringall(...)));
end

--- Sets or removes the icon on the frame.
-- @param icon The path to the icon, or nil to hide it.
function TitledFrame:SetIcon(icon)
	self.Icon:SetTexture(icon);
	-- Reposition text.
	if(icon) then
		self.Title:SetPoint("TOPLEFT", 70, -15);
		self.Description:SetPoint("TOPLEFT", 70, -40);
	else
		self.Title:SetPoint("TOPLEFT", 15, -15);
		self.Description:SetPoint("TOPLEFT", 15, -40);
	end
end

--- Frame template with a border. Simple.
local BorderedFrame = PowerAuras:RegisterWidget("BorderedFrame", "Frame", {
	Backdrop = {
		bgFile = [[Interface\Buttons\WHITE8X8]],
		edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
		tile = true,
		tileSize = 16,
		edgeSize = 14,
		insets = { left = 2, right = 2, top = 2, bottom = 2 },
	},
});

--- Creates a new instance of the widget and returns the frame.
-- @param parent The parent frame.
function BorderedFrame:New(parent)
	local frame = base(self, parent);
	frame:SetBackdrop(self.Backdrop);
	frame:SetBackdropColor(0.0, 0.0, 0.0, 0.5);
	frame:SetBackdropBorderColor(0.3, 0.3, 0.3, 1.0);
	return frame;
end

--- Scrollbar template for the ScrollFrame widget.
local ScrollBar = PowerAuras:RegisterWidget("ScrollBar", "ReusableWidget");

--- Constructs a new instance of the scrollbar and returns it.
function ScrollBar:New()
	-- Create the widget.
	local frame = base(self);
	if(frame) then
		return frame;
	end
	frame = CreateFrame("Slider");
	frame:SetSize(18, 1);
	frame:EnableMouseWheel(true);
	-- Create texture for the thumb.
	local thumb = frame:CreateTexture();
	thumb:SetSize(18, 16);
	thumb:SetTexCoord(0.2, 0.8, 0.25, 0.75);
	thumb:SetTexture([[Interface\Buttons\UI-ScrollBar-Knob]]);
	frame:SetThumbTexture(thumb);
	-- Create buttons.
	for _, t in ipairs({ "Up", "Down" }) do
		-- Texture path for buttons.
		local tex = [[Interface\Buttons\UI-ScrollBar-Scroll%sButton-%s]];
		-- Button widget.
		local button = CreateFrame("Button", nil, frame);
		frame[("Scroll%s"):format(t)] = button;
		button:SetSize(18, 16);
		if(t == "Up") then
			button:SetPoint("TOPRIGHT", 0, 16);
		else
			button:SetPoint("BOTTOMRIGHT", 0, -16);
		end
		-- Normal texture.
		local texture = button:CreateTexture();
		texture:SetTexture(tex:format(t, "Up"));
		texture:SetTexCoord(0.2, 0.8, 0.25, 0.75);
		texture:SetAllPoints(button);
		button:SetNormalTexture(texture);
		-- Pushed texture.
		local texture = button:CreateTexture();
		texture:SetTexture(tex:format(t, "Down"));
		texture:SetTexCoord(0.2, 0.8, 0.25, 0.75);
		texture:SetAllPoints(button);
		button:SetPushedTexture(texture);
		-- Disabled texture.
		local texture = button:CreateTexture();
		texture:SetTexture(tex:format(t, "Disabled"));
		texture:SetTexCoord(0.2, 0.8, 0.25, 0.75);
		texture:SetAllPoints(button);
		button:SetDisabledTexture(texture);
		-- Highlight texture.
		local texture = button:CreateTexture();
		texture:SetTexture(tex:format(t, "Highlight"));
		texture:SetBlendMode("ADD");
		texture:SetTexCoord(0.2, 0.8, 0.25, 0.75);
		texture:SetAllPoints(button);
		button:SetHighlightTexture(texture);
		-- OnClick script handler.
		button:SetScript("OnClick", function()
			-- Update value.
			if(t == "Up") then
				frame:SetValue(frame:GetValue() - frame:GetValueStep());
			else
				frame:SetValue(frame:GetValue() + frame:GetValueStep());
			end
			-- Play a sound.
			PlaySound("UChatScrollButton");
		end);
	end
	-- Callbacks.
	frame.OnRangeUpdated = PowerAuras:Callback();
	frame.OnValueUpdated = PowerAuras:Callback();
	-- Done.
	return frame;
end

--- Script handler for the OnMinMaxChanged event.
-- @param min The new minimum value.
-- @param max The new maximum value.
function ScrollBar:OnMinMaxChanged(min, max)
	if(self:GetValue() <= min) then
		self.ScrollUp:Disable();
	else
		self.ScrollUp:Enable();
	end
	if(self:GetValue() >= max) then
		self.ScrollDown:Disable();
	else
		self.ScrollDown:Enable();
	end
	self:OnRangeUpdated(min, max);
end

--- Script handler for the OnMouseWheel event.
-- @param The mousewheel value delta.
function ScrollBar:OnMouseWheel(delta)
	if(delta > 0) then
		self:SetValue(self:GetValue() - self:GetValueStep());
	else
		self:SetValue(self:GetValue() + self:GetValueStep());
	end
end

--- Script handler for the OnValueChanged event.
-- @param value The new value of the slider.
function ScrollBar:OnValueChanged(value)
	-- Value changed?
	local min, max = self:GetMinMaxValues();
	if(value <= min) then
		self.ScrollUp:Disable();
	else
		self.ScrollUp:Enable();
	end
	if(value >= max) then
		self.ScrollDown:Disable();
	else
		self.ScrollDown:Enable();
	end
	self:OnValueUpdated(value);
end

--- Recycles the widget, allowing it to be reused in the future.
function ScrollBar:Recycle()
	self.OnRangeUpdated:Reset();
	self.OnValueUpdated:Reset();
	base(self);
end

--- Frame template with a scrollbar.
local ScrollFrame = PowerAuras:RegisterWidget("ScrollFrame", "BorderedFrame");

--- Creates a new instance of the widget and returns the frame.
-- @param parent The parent frame.
function ScrollFrame:New(parent)
	-- Create the frame.
	local frame = base(self, parent);
	-- Enable the mousewheel.
	frame:EnableMouseWheel(true);
	-- Add the scrollbar to the frame.
	frame.ScrollBar = PowerAuras:Create("ScrollBar");
	frame.ScrollBar:SetParent(frame);
	frame.ScrollBar:SetPoint("TOPRIGHT", -3, -20);
	frame.ScrollBar:SetPoint("BOTTOMRIGHT", -3, 20);
	frame.ScrollBar:SetValueStep(1);
	frame.ScrollBar:SetMinMaxValues(0, 0);
	frame.ScrollBar:SetValue(0);
	frame.ScrollBar:Hide();
	-- Hook the OnValueChanged/OnMinMaxChanged scripts of the scrollbar.
	local lastValue = nil;
	frame.ScrollBar.OnValueUpdated:Connect(function(_, value)
		-- Only update if the value really changed.
		if(value ~= lastValue) then
			frame:PerformLayout();
			lastValue = value;
		end
	end);
	-- Always do an update on min/max.
	frame.ScrollBar.OnRangeUpdated:Connect(function(_, min, max)
		-- If <= 0, hide the bar.
		if((max - min) <= 0) then
			frame.ScrollBar:Hide();
		else
			frame.ScrollBar:Show();
		end
		frame:PerformLayout();
	end);
	-- Done.
	return frame;
end

--- OnMouseWheel script handler for the frame.
-- @param delta The delta of the scroll wheel.
function ScrollFrame:OnMouseWheel(delta)
	if(delta > 0) then
		self.ScrollBar:SetValue(
			self.ScrollBar:GetValue() - self.ScrollBar:GetValueStep()
		);
	else
		self.ScrollBar:SetValue(
			self.ScrollBar:GetValue() + self.ScrollBar:GetValueStep()
		);
	end
end

--- Returns the offset of the scroll region.
function ScrollFrame:GetScrollOffset()
	return self.ScrollBar:GetValue();
end

--- Returns the min and max range of the scroll region.
function ScrollFrame:GetScrollRange()
	return self.ScrollBar:GetMinMaxValues();
end

--- Sets the offset of the scroll region.
-- @param offset The offset to set.
function ScrollFrame:SetScrollOffset(offset)
	self.ScrollBar:SetValue(offset);
end

--- Sets the min/max range of the scroll region.
-- @param min The minimum range of the scroll region.
-- @param max The maximum range of the scroll region.
function ScrollFrame:SetScrollRange(min, max)
	self.ScrollBar:SetMinMaxValues(min, max);
end