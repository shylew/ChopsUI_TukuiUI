-- Lock down local environment.
local PowerAuras = _G["PowerAuras"];
setfenv(1, PowerAuras);

--- iWindow widget. Draggable, closable, pretty. Now only £499.99.
local Window = PowerAuras:RegisterWidget("Window", "Container");

--- Creates a new instance of the widget and returns the frame.
-- @param parent   The parent frame of the window. Defaults to UIParent.
-- @param name     The global name of the window. Optional.
function Window:New(parent, name)
	-- Create new.
	local template = "BasicFrameTemplate";
	local frame = CreateFrame("Frame", name, parent or UIParent, template);
	-- Update background.
	frame.Bg:SetTexture([[Interface\HelpFrame\DarkSandstone-Tile]], true);
	frame.TitleBg:SetTexture([[Interface\HelpFrame\DarkSandstone-Tile]], true);
	-- Rename some regions.
	frame.Close = frame.CloseButton;
	frame.Title = frame.TitleText;
	-- Configure the frame.
	frame:SetSize(550, 456);
	frame:SetFrameStrata("MEDIUM");
	frame:SetMovable(true);
	frame:EnableMouse(true);
	frame:SetClampRectInsets(0, 0, 0, 0);
	frame:SetClampedToScreen(true);
	frame:SetToplevel(true);
	-- Add a help button.
	frame.Help = PowerAuras:Create("WindowHelpButton", frame, frame);
	frame.Help:SetPoint("TOPLEFT", -20, 20);
	frame.Help:Hide();
	-- Add coroutine storage to the window.
	frame.Coroutines = { ["Next"] = 0 };
	frame.CoFrame = PowerAuras:Create("CoroutineHost", frame);
	-- Done, return the frame.
	return frame;
end

--- Script handler for OnHide.
function Window:OnHide()
	if(self.isMoving and self:IsMovable()) then
		self.isMoving = false;
		self:StopMovingOrSizing();
		self:SetUserPlaced(false);
	end
end

--- Script handler for OnMouseDown.
-- @param button The button that was pressed.
function Window:OnMouseDown(button)
	-- Close any existing dropdown menus.
	PowerAuras:GetWidget("Dropdown"):CloseAllMenus();
	if(button == "LeftButton" and not self.isMoving and self:IsMovable()) then
		self.isMoving = true;
		self:StartMoving();
	end
end

--- Script handler for OnMouseUp.
-- @param button The button that was released.
function Window:OnMouseUp(button)
	if(button == "LeftButton" and self.isMoving and self:IsMovable()) then
		self.isMoving = false;
		self:StopMovingOrSizing();
		self:SetUserPlaced(false);
	end
end

--- Controls whether or not the close button is shown/hidden.
-- @param state True if the window should be closable, false if not.
function Window:SetClosable(state)
	self.Close:SetEnabled(state);
end

--- Sets the help plate for this widget.
-- @param plate The plate definition to set.
function Window:SetHelpPlate(plate)
	base(self, plate);
	-- Did we set one?
	self.Help:SetShown(self:HasHelpPlate());
end

--- Sets the title of the window.
-- @param title The title text to set.
-- @param ...   Arguments to format into the title.
function Window:SetTitle(title, ...)
	-- Show the title region.
	self.Title:Show();
	if(not self.Title.Text and self.Title.SetText) then
		self.Title:SetText(tostring(title):format(tostringall(...)));
	else
		self.Title.Text:SetText(tostring(title):format(tostringall(...)));
	end
end

--- Subframe for windows that displays the progress of coroutines.
local CoroutineHost = PowerAuras:RegisterWidget("CoroutineHost", "Frame");

--- Constructs a new instance of the widget.
-- @param parent The parent frame.
function CoroutineHost:New(parent)
	-- Create the frame.
	local frame = base(self, parent);
	frame:SetAlpha(0);
	frame:SetPoint("TOPLEFT", 2, -22);
	frame:SetPoint("BOTTOMRIGHT", -3, 2);
	frame:EnableMouse(true);
	frame:SetBackdrop({ bgFile = [[Interface\Buttons\WHITE8X8]] });
	frame:SetBackdropColor(0.0, 0.0, 0.0, 0.9);
	frame:SetFrameStrata("DIALOG");

	-- Add show/hide animations.
	frame.HideAnim = frame:CreateAnimationGroup();
	frame.HideAnim.Alpha = frame.HideAnim:CreateAnimation("Alpha");
	frame.HideAnim.Alpha:SetChange(-1);
	frame.HideAnim.Alpha:SetDuration(0.1);
	frame.HideAnim:SetScript("OnFinished", function()
		frame:SetAlpha(0);
		frame:__Hide();
	end);
	frame.ShowAnim = frame:CreateAnimationGroup();
	frame.ShowAnim.Alpha = frame.ShowAnim:CreateAnimation("Alpha");
	frame.ShowAnim.Alpha:SetChange(1);
	frame.ShowAnim.Alpha:SetDuration(0.1);
	frame.ShowAnim:SetScript("OnPlay", function()
		frame:__Show();
	end);
	frame.ShowAnim:SetScript("OnFinished", function()
		frame:SetAlpha(1);
	end);

	-- Add child widgets to coroutine frame. Start with title.
	frame.Title = frame:CreateFontString(nil, "OVERLAY");
	frame.Title:SetPoint("LEFT", 12, 12);
	frame.Title:SetPoint("RIGHT", -12, 12);
	frame.Title:SetHeight(24);
	frame.Title:SetFontObject(GameFontNormal);
	frame.Title:SetJustifyH("CENTER");
	frame.Title:SetJustifyV("MIDDLE");
	-- Border frame for progress bar.
	frame.Wrap = CreateFrame("Frame", nil, frame);
	frame.Wrap:SetPoint("LEFT", 12, -12);
	frame.Wrap:SetPoint("RIGHT", -12, -12);
	frame.Wrap:SetHeight(24);
	frame.Wrap:SetBackdrop({
		edgeFile = [[Interface\LFGFrame\LFGBorder]],
		edgeSize = 16
	});
	-- Progress bar.
	frame.Bar = CreateFrame("StatusBar", nil, frame.Wrap);
	frame.Bar:SetPoint("TOPLEFT", 7, -8);
	frame.Bar:SetPoint("BOTTOMRIGHT", -7, 7);
	frame.Bar:SetMinMaxValues(0, 1);
	frame.Bar:SetValue(0);
	frame.Bar:SetStatusBarTexture(
		[[Interface\RaidFrame\Raid-Bar-Resource-Fill]]
	);
	frame.Bar:SetStatusBarColor(0.0, 0.7, 0.0, 1.0);
	-- Overall progress bar.
	frame.OverallWrap = CreateFrame("Frame", nil, frame);
	frame.OverallWrap:SetPoint("TOPLEFT", frame.Wrap, "BOTTOMLEFT", 0, -8);
	frame.OverallWrap:SetPoint("TOPRIGHT", frame.Wrap, "BOTTOMRIGHT", 0, -8);
	frame.OverallWrap:SetHeight(24);
	frame.OverallWrap:SetBackdrop({
		edgeFile = [[Interface\LFGFrame\LFGBorder]],
		edgeSize = 16
	});
	frame.Overall = CreateFrame("StatusBar", nil, frame.OverallWrap);
	frame.Overall:SetPoint("TOPLEFT", 7, -8);
	frame.Overall:SetPoint("BOTTOMRIGHT", -7, 7);
	frame.Overall:SetMinMaxValues(0, 1);
	frame.Overall:SetValue(0);
	frame.Overall:SetStatusBarTexture(
		[[Interface\RaidFrame\Raid-Bar-Resource-Fill]]
	);
	frame.Overall:SetStatusBarColor(0.0, 0.7, 0.0, 1.0);
	frame.Processed = 0;
	-- Hide coroutine processing frame.
	frame:Hide();
	return frame;
end

--- Initialises the widget.
function CoroutineHost:Initialise()
	-- Listen to events.
	self:ConnectCallback(PowerAuras.OnOptionsEvent, self.OnOptionsEvent);
end

--- Hides the coroutine host frame.
function CoroutineHost:Hide()
	-- If playing show animation, stop it.
	local alpha = self:GetAlpha();
	if(self.ShowAnim:IsPlaying()) then
		self.ShowAnim:Stop();
		self:SetAlpha(alpha);
	end
	-- Play hide animation.
	self.HideAnim:Play();
end

--- OnHide script handler for the widget.
function CoroutineHost:OnHide()
	-- Restore help button strata and close button.
	local parent = self:GetParent();
	parent.Help:SetFrameStrata("MEDIUM");
	parent.Close:Enable();
	self.Processed = 0;
end

--- OnOptionsEvent callback handler.
-- @param event The event that fired.
-- @param arg1  The first event argument. All we're interested in.
function CoroutineHost:OnOptionsEvent(event, arg1)
	-- Queue events first.
	if(event == "COROUTINE_QUEUE_START") then
		self.Overall:SetValue(0);
		self:Show();
	elseif(event == "COROUTINE_QUEUE_END") then
		self:Hide();
	end

	-- Specific coroutine events.
	if(event == "COROUTINE_START") then
		self.Title:SetText(tostring(arg1));
		self.Bar:SetValue(0);
	elseif(event == "COROUTINE_END") then
		self.Bar:SetValue(1);
		self.Processed = self.Processed + 1;
		self.Overall:SetValue(self.Processed);
	elseif(event == "COROUTINE_UPDATE") then
		self.Wrap:SetShown(arg1 ~= -1);
		self.Bar:SetValue(arg1);
	elseif(event == "COROUTINE_QUEUED") then
		self.Overall:SetMinMaxValues(0, arg1);
	end
end

--- OnShow script handler for the widget.
function CoroutineHost:OnShow()
	-- Ensure help button is on top of the frame, and disable close button.
	local parent = self:GetParent();
	parent.Help:SetFrameStrata("FULLSCREEN_DIALOG");
	parent.Close:Disable();
end

--- Shows the coroutine host frame.
function CoroutineHost:Show()
	-- If playing hide animation, stop it.
	local alpha = self:GetAlpha();
	if(self.HideAnim:IsPlaying()) then
		self.HideAnim:Stop();
		self:SetAlpha(alpha);
	end
	-- Play show animation.
	self.ShowAnim:Play();
end

--- Help button template for windows.
local WindowHelp = PowerAuras:RegisterWidget("WindowHelpButton", "HelpButton");

--- Constructs or recycles an instance of the button, and links it to a
--  widget.
-- @param parent The parent of the button.
-- @param link   The widget to link to for toggling.
function WindowHelp:New(parent, link)
	-- Recycle or construct.
	local frame = PowerAuras:GetWidget("ReusableWidget").New(self);
	if(not frame) then
		frame = CreateFrame("Button");
		frame:SetSize(64, 64);
		-- "i" texture.
		frame:SetNormalTexture([[Interface\Common\help-i]]);
		frame:GetNormalTexture():ClearAllPoints();
		frame:GetNormalTexture():SetPoint("CENTER", 0, 0);
		frame:GetNormalTexture():SetSize(46, 46);
		frame:SetHighlightTexture(
			[[Interface\Minimap\UI-Minimap-ZoomButton-Highlight]]
		);
		-- Glow texture.
		frame:GetHighlightTexture():ClearAllPoints();
		frame:GetHighlightTexture():SetPoint("CENTER", 0, 0);
		frame:GetHighlightTexture():SetSize(46, 46);
		-- Border texture.
		frame.Border = frame:CreateTexture(nil, "BORDER");
		frame.Border:SetTexture([[Interface\Minimap\MiniMap-TrackingBorder]]);
		frame.Border:SetPoint("CENTER", 12, -13);
		frame.Border:SetSize(64, 64);
	end
	-- Fix frame parent and return.
	frame.Target = link;
	frame:SetParent(parent);
	return frame;
end