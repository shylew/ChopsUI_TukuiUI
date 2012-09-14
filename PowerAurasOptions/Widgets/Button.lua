-- Lock down local environment.
local PowerAuras = _G["PowerAuras"];
setfenv(1, PowerAuras);

--- Basic button widget.
local Button = PowerAuras:RegisterWidget("Button", "ReusableWidget");

--- Constructs/recycles an instance of the widget.
function Button:New()
	local frame = base(self);
	if(not frame) then
		frame = CreateFrame("Button", nil, UIParent, "UIPanelButtonTemplate");
		frame.OnClicked = PowerAuras.Callback();
	end
	return frame;
end

--- Initialises the widget.
-- @param parent The parent of the widget.
function Button:Initialise(parent)
	self:SetParent(parent);
	self:SetFixedSize(110, 24);
	self:RegisterForClicks("AnyUp");
end

--- OnClick script handler.
-- @param button The clicked button.
function Button:OnClick(button)
	PlaySound("UChatScrollButton");
	self:OnClicked(button);
end

--- Recycles the widget, allowing it to be reused.
function Button:Recycle()
	-- Reset callbacks.
	self.OnClicked:Reset();
	self:SetText("");
	base(self);
end

--- Larger, prettier button template. Fixed size though.
local BigButton = PowerAuras:RegisterWidget("BigButton", "ReusableWidget");

--- Constructs/recycles an instance of the widget.
function BigButton:New()
	local frame = base(self);
	if(not frame) then
		frame = CreateFrame("Button", nil, UIParent);
		-- Textures.
		frame:SetNormalTexture([[Interface\HelpFrame\HelpButtons]]);
		frame:GetNormalTexture():SetTexCoord(
			0.00390625, 0.78125000, 0.44140625, 0.65234375
		);
		frame:SetPushedTexture([[Interface\HelpFrame\HelpButtons]]);
		frame:GetPushedTexture():SetTexCoord(
			0.00390625, 0.78125000, 0.22265625, 0.43359375
		);
		frame:SetHighlightTexture([[Interface\HelpFrame\HelpButtons]]);
		frame:GetHighlightTexture():SetTexCoord(
			0.00390625, 0.78125000, 0.00390625, 0.21484375
		);
		-- Text.
		frame.Text = frame:CreateFontString(nil, "OVERLAY");
		frame.Text:SetFontObject(GameFontNormalLarge);
		frame.Text:SetAllPoints(frame);
		frame.Text:SetJustifyH("CENTER");
		frame.Text:SetJustifyV("MIDDLE");
		frame:SetFontString(frame.Text);
		-- Callbacks.
		frame.OnClicked = PowerAuras.Callback();
	end
	return frame;
end

--- Initialises the widget.
-- @param parent The parent of the widget.
function BigButton:Initialise(parent)
	self:SetParent(parent);
	self:SetFixedSize(199, 54);
	self:RegisterForClicks("AnyUp");
end

--- OnClick script handler.
-- @param button The clicked button.
function BigButton:OnClick(button)
	PlaySound("UChatScrollButton");
	self:OnClicked(button);
end

--- Recycles the widget, allowing it to be reused.
function BigButton:Recycle()
	-- Reset callbacks.
	self.OnClicked:Reset();
	self:SetText("");
	base(self);
end

--- Blue button template. It's blue.
local BlueButton = PowerAuras:RegisterWidget("BlueButton", "ReusableWidget");

--- Constructs/recycles an instance of the widget.
function BlueButton:New()
	-- Recycle if possible.
	local frame = base(self);
	if(not frame) then
		-- Create.
		frame = CreateFrame("CheckButton", nil, UIParent);
		frame.Bg = frame:CreateTexture(nil, "BACKGROUND");
		frame.Bg:SetAllPoints(true);
		frame.Bg:SetTexture([[Interface\Common\bluemenu-main]]);
		frame.Bg:SetTexCoord(0.00390625, 0.87890625, 0.75195313, 0.83007813);
		-- Checked texture.
		frame:SetCheckedTexture([[Interface\Common\bluemenu-main]]);
		local t = frame:GetCheckedTexture();
		t:SetTexCoord(0.00390625, 0.87890625, 0.59179688, 0.66992188);
		-- Button text.
		frame.Text = frame:CreateFontString(nil, "OVERLAY");
		frame.Text:SetFontObject(GameFontNormal);
		frame.Text:SetAllPoints(true);
		frame.Text:SetJustifyH("CENTER");
		frame.Text:SetJustifyV("MIDDLE");
		frame:SetFontString(frame.Text);
		-- Callbacks.
		frame.OnClicked = PowerAuras.Callback();
	end
	return frame;
end

--- Initialises the widget.
-- @param parent The parent of the widget.
function BlueButton:Initialise(parent)
	-- Sizing/margin details.
	self:SetParent(parent);
	self:SetFixedSize(168, 60);
end

--- OnClick script handler.
-- @param button The clicked button.
function BlueButton:OnClick(button)
	self:SetChecked(not self:GetChecked());
	PlaySound("UChatScrollButton");
	self:OnClicked(button);
end

--- OnEnter script handler.
function BlueButton:OnEnter()
	self.Bg:SetTexCoord(0.00390625, 0.87890625, 0.59179688, 0.66992188);
	base(self);
end

--- OnLeave script handler.
function BlueButton:OnLeave()
	self.Bg:SetTexCoord(0.00390625, 0.87890625, 0.75195313, 0.83007813);
	base(self);
end

--- Recycles the widget, allowing it to be reused.
function BlueButton:Recycle()
	self.OnClicked:Reset();
	self:SetText("");
	base(self);
end

--- Tool button template for the browser.
local IconButton = PowerAuras:RegisterWidget("IconButton", "ReusableWidget");

--- Constructs or recycles an instance of the widget.
-- @param parent The parent of the widget.
function IconButton:New(parent)
	-- Recycle or create button.
	local frame = base(self);
	if(not frame) then
		frame = CreateFrame("CheckButton", nil, parent);
		frame:SetNormalTexture(DefaultIcon);
		frame:GetNormalTexture():ClearAllPoints();
		frame:GetNormalTexture():SetPoint("CENTER", 0, 0);
		frame:GetNormalTexture():SetSize(16, 16);
		frame:SetHighlightTexture([[Interface\PlayerActionBarAlt\Stone]]);
		frame:GetHighlightTexture():SetTexCoord(
			0.69921875, 0.765625, 0.359375, 0.42578125
		);
		frame:SetCheckedTexture([[Interface\PlayerActionBarAlt\Stone]]);
		frame:GetCheckedTexture():SetTexCoord(
			0.69921875, 0.765625, 0.359375, 0.42578125
		);
		frame.OnClicked = PowerAuras.Callback();
	end
	-- Fix parent and return.
	frame:SetParent(parent);
	return frame;
end

--- Updates the displayed icon on the button.
function IconButton:Initialise()
	self:SetFixedSize(24, 24);
	self:SetSize(self:GetFixedSize());
	self:RegisterForClicks("AnyUp");
end

--- Handler for the OnClick script.
function IconButton:OnClick(button)
	PlaySound("UChatScrollButton");
	self:SetChecked(not self:GetChecked());
	self:OnClicked(button);
end

--- Handler for the OnDisable script.
function IconButton:OnDisable()
	self:GetNormalTexture():SetDesaturated(true);
	self:GetNormalTexture():SetPoint("CENTER", 0, 0);
end

--- Handler for the OnDisable script.
function IconButton:OnEnable()
	self:GetNormalTexture():SetDesaturated(false);
	self:GetNormalTexture():SetPoint("CENTER", 0, 0);
end

--- Handler for the OnMouseDown script.
function IconButton:OnMouseDown()
	if(self:IsEnabled()) then
		self:GetNormalTexture():SetPoint("CENTER", 1, -1);
	end
end

--- Handler for the OnMouseUp script.
function IconButton:OnMouseUp()
	self:GetNormalTexture():SetPoint("CENTER", 0, 0);
end

--- Recycles the widget, resetting the icon and callback.
function IconButton:Recycle()
	self.OnClicked:Reset();
	self:SetIcon(nil);
	self:SetIconTexCoord(0, 1, 0, 1);
	self:GetNormalTexture():ClearAllPoints();
	self:GetNormalTexture():SetPoint("CENTER", 0, 0);
	self:GetNormalTexture():SetSize(16, 16);
	self:SetChecked(false);
	self:Enable();
	base(self);
end

--- Updates the displayed icon on the button.
function IconButton:SetIcon(icon)
	self:SetNormalTexture(icon or PowerAuras.DefaultIcon);
end

--- Sets the texture coordinates of the icon.
-- @param ... Coordinates to set.
function IconButton:SetIconTexCoord(...)
	self:GetNormalTexture():SetTexCoord(...);
end

--- Help button template that can be used for toggling the help plates of
--  a frame.
local HelpButton = PowerAuras:RegisterWidget("HelpButton", "ReusableWidget");

--- Constructs or recycles an instance of the button, and links it to a
--  widget.
-- @param parent The parent of the button.
-- @param link   The widget to link to for toggling.
function HelpButton:New(parent, link)
	-- Recycle or construct.
	local frame = base(self);
	if(not frame) then
		frame = CreateFrame("Button");
		frame:SetSize(28, 28);
		frame:SetNormalTexture([[Interface\Common\help-i]]);
		frame:GetNormalTexture():ClearAllPoints();
		frame:GetNormalTexture():SetPoint("CENTER", 0, 0);
		frame:GetNormalTexture():SetSize(frame:GetSize());
		frame:GetNormalTexture():SetTexCoord(
			0.111111111, 0.888888889, 0.111111111, 0.888888889
		);
		frame:SetHighlightTexture(
			[[Interface\Minimap\UI-Minimap-ZoomButton-Highlight]]
		);
	end
	-- Fix frame parent and return.
	frame.Target = link;
	frame:SetParent(parent);
	return frame;
end

--- OnClick script handler. Toggles the help plate on the target frame.
function HelpButton:OnClick()
	PlaySound("UChatScrollButton");
	self.Target:ToggleHelpPlate();
end

--- OnMouseDown script handler. Modifies the image position.
function HelpButton:OnMouseDown()
	self:GetNormalTexture():SetPoint("CENTER", 1, -1);
end

--- OnMouseUp script handler. Resets the image position.
function HelpButton:OnMouseUp()
	self:GetNormalTexture():SetPoint("CENTER", 0, 0);
end

--- Called when the tooltip for this widget should be shown.
-- @param tooltip The tooltip frame to use.
function HelpButton:OnTooltipShow(tooltip)
	-- Position the tooltip.
	tooltip:SetOwner(self, "ANCHOR_RIGHT");
	tooltip:AddLine(_G["HELP_LABEL"]);
	tooltip:AddLine(L["HelpButtonTooltipText"], 1, 1, 1);
end

--- Recycles the widget, allowing it to be reused again in the future.
function HelpButton:Recycle()
	self.Target = nil;
	base(self);
end

--- Freeform help button template used for the boxes within a help plate.
local SubHelpButton = PowerAuras:RegisterWidget("SubHelpButton", "HelpButton");

--- Initialises the help button widget, disabling it to prevent clicking.
function SubHelpButton:Initialise()
	-- Disable the button, modify the alpha and enable the OnEnter/OnLeave
	-- to work while disabled.
	self:Disable();
	self:SetAlpha(0.75);
	self:SetMotionScriptsWhileDisabled(true);
	-- Remove click scripts.
	self:SetScript("OnMouseDown", nil);
	self:SetScript("OnMouseUp", nil);
	-- Ensure the highlight texture works while disabled.
	if(not self.HighlightTexture) then
		self.HighlightTexture = self:CreateTexture(nil, "OVERLAY");
		self.HighlightTexture:SetAllPoints(self);
		self.HighlightTexture:SetBlendMode("ADD");
		self.HighlightTexture:Hide();
		self.HighlightTexture:SetTexture(
			[[Interface\Minimap\UI-Minimap-ZoomButton-Highlight]]
		);
	end
end

--- OnEnter script handler. Shows the tooltip and adjusts the button alpha.
function SubHelpButton:OnEnter()
	self:SetAlpha(1);
	self.HighlightTexture:Show();
	if(self:GetParent().Background) then
		self:GetParent().Background:SetVertexColor(0, 0, 0, 0);
		self:GetParent().Normal:Hide();
		self:GetParent().Highlight:Show();
	end
	base(self);
end

--- OnLeave script handler. Hides the tooltip and adjusts the button alpha.
function SubHelpButton:OnLeave()
	self:SetAlpha(0.75);
	self.HighlightTexture:Hide();
	if(self:GetParent().Background) then
		self:GetParent().Background:SetVertexColor(0, 0, 0, 0.75);
		self:GetParent().Normal:Show();
		self:GetParent().Highlight:Hide();
	end
	base(self);
end

--- Called when the tooltip for this widget should be shown.
-- @param tooltip The tooltip frame to use.
function SubHelpButton:OnTooltipShow(tooltip)
	-- Position the tooltip.
	tooltip:SetOwner(self, self.TooltipAnchor or "ANCHOR_BOTTOMRIGHT");
	tooltip:AddLine(self.TooltipTitle or "");
	tooltip:AddLine(self.TooltipText or "", 1, 1, 1, true);
end

--- Recycles the widget, allowing it to be reused again in the future.
function SubHelpButton:Recycle()
	self.TooltipTitle = nil;
	self.TooltipText = nil;
	base(self);
end