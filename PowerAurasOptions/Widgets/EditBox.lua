-- Lock down local environment.
local PowerAuras = _G["PowerAuras"];
setfenv(1, PowerAuras);

--- EditBox widget, for controlling values with a simple text box.
local EditBox = PowerAuras:RegisterWidget("EditBox", "ReusableWidget");

--- Constructs a new instance of the editbox widget.
-- @param parent The parent of the widget.
function EditBox:New(parent)
	-- Try to recycle.
	local frame = base(self);
	if(not frame) then
		-- Construct a new frame then.
		frame = CreateFrame("EditBox", nil, parent or UIParent);
		frame:SetJustifyH("LEFT");
		frame:SetAutoFocus(false);
		frame:SetFontObject(GameFontHighlight);
		frame:SetTextInsets(4, 4, 2, 2);
		frame:SetHitRectInsets(0, 0, -20, 0);
		frame:SetBackdrop({
			edgeFile = [[Interface\Buttons\WHITE8X8]],
			edgeSize = 1,	
		});
		frame:SetBackdrop(PowerAuras:GetWidget("BorderedFrame").Backdrop);
		frame:SetBackdropColor(0.0, 0.0, 0.0, 0.75);
		frame:SetBackdropBorderColor(0.3, 0.3, 0.3, 1.0);
		-- Add title label.
		frame.Title = frame:CreateFontString(nil, "OVERLAY");
		frame.Title:SetFontObject(GameFontNormal);
		frame.Title:SetJustifyH("LEFT");
		frame.Title:SetJustifyV("MIDDLE");
		frame.Title:SetWordWrap(false);
		frame.Title:SetSize(1, 20);
		frame.Title:SetPoint("BOTTOMLEFT", frame, "TOPLEFT");
		frame.Title:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT");
		-- Callback object.
		frame.OnValueUpdated = PowerAuras:Callback();
	end
	-- Done.
	frame.LastValue = nil;
	frame:SetParent(parent or UIParent);
	return frame;
end

--- Called when the frame has been constructed. Updates the size of the widget.
function EditBox:Initialise()
	self:SetMargins(0, 20, 0, 0);
	self:SetFixedSize(70, 26);
end

--- Called when the enter key is pressed inside of the editbox.
function EditBox:OnEnterPressed()
	self:ClearFocus();
end

--- Called when the escape key is pressed inside of the editbox.
function EditBox:OnEscapePressed()
	self:SetText(self.LastValue);
	self:ClearFocus();
end

--- Called when the editbox gains focus.
function EditBox:OnEditFocusGained()
	self:HighlightText(0, -1);
	self.LastValue = self:GetText();
end

--- Called when the editbox loses focus.
function EditBox:OnEditFocusLost()
	self:HighlightText(0, 0);
	if(self:GetText() ~= self.LastValue) then
		self:OnValueUpdated(self:GetText());
	end
end

--- OnTextChanged script handler.
-- @param user If true, the text changed because of user input.
function EditBox:OnTextChanged(user)
	if(self.SaveOnTextChanged) then
		self:OnValueUpdated(self:GetText(), true, user);
	end
end

--- Recycles the widget, allowing it to be reused in the future.
function EditBox:Recycle()
	-- Clear all functions on our callback.
	self.OnValueUpdated:Reset();
	self:SetJustifyH("LEFT");
	self:SetAutoFocus(false);
	self:SetFontObject(GameFontHighlight);
	self:SetTextInsets(4, 4, 2, 2);
	self:SetSaveOnChange(false);
	-- Reset labels.
	self:SetTitle(nil);
	base(self);
end

--- Changes how the editbox behaves when the input text is changed. If this
--  mode is set to true, then the editbox will update whenever the text is
--  altered irrespective of whether or not enter is pressed.
function EditBox:SetSaveOnChange(mode)
	self.SaveOnTextChanged = mode;
end

--- Sets the title label of the widget.
-- @param title The title text.
-- @param ...   Substitutions to perform.
function EditBox:SetTitle(title, ...)
	self.Title:SetText(tostring(title):format(tostringall(...)));
end

--- Sets the displayed text and fires the update callback.
function EditBox:UpdateText(text)
	self:SetText(text);
	self:OnValueUpdated(self:GetText());
end

--- Editbox designed for number input.
local NumberBox = PowerAuras:RegisterWidget("NumberBox", "EditBox");

--- Constructs/recycles an instance of the widget.
function NumberBox:New(parent)
	-- Get the editbox.
	local frame = base(self, parent);
	-- Add side buttons for incrementing/decrementing.
	if(not frame.Up) then
		frame.Up = CreateFrame("Button", nil, frame);
		frame.Up:SetSize(16, 16);
		frame.Up:SetPoint("TOPRIGHT", -4, 0);
		frame.Up:SetNormalTexture([[Interface\Minimap\MiniMap-PositionArrows]]);
		frame.Up:GetNormalTexture():SetTexCoord(0, 1, 0, 0.5);
		frame.Up:SetAlpha(0.5);
		frame.Up:SetScript("OnEnter", function(self)
			self:SetAlpha(1.0);
		end);
		frame.Up:SetScript("OnLeave", function(self)
			self:SetAlpha(0.5);
		end);
		frame.Up:SetScript("OnClick", function(self)
			local parent = self:GetParent();
			parent:SetValue(parent:GetValue() + parent.ValueStep);
		end);
	end
	if(not frame.Do) then
		frame.Do = CreateFrame("Button", nil, frame);
		frame.Do:SetSize(16, 16);
		frame.Do:SetPoint("BOTTOMRIGHT", -4, 0);
		frame.Do:SetNormalTexture([[Interface\Minimap\MiniMap-PositionArrows]]);
		frame.Do:GetNormalTexture():SetTexCoord(0, 1, 0.5, 1.0);
		frame.Do:SetAlpha(0.5);
		frame.Do:SetScript("OnEnter", function(self)
			self:SetAlpha(1.0);
		end);
		frame.Do:SetScript("OnLeave", function(self)
			self:SetAlpha(0.5);
		end);
		frame.Do:SetScript("OnClick", function(self)
			local parent = self:GetParent();
			parent:SetValue(parent:GetValue() - parent.ValueStep);
		end);
	end
	-- Default fields.
	frame.MinValue, frame.MaxValue = 0, 0;
	frame.ValueStep = 1;
	return frame;
end

--- Initialises the widget.
function NumberBox:Initialise(parent)
	-- Reset values.
	-- SetNumeric prevents negative inputs.
	self:SetNumeric(false);
	self:SetMinMaxValues(0, 0);
	self:SetValueStep(1);
	base(self, parent);
end

--- Returns the min/max values.
function NumberBox:GetMinMaxValues()
	return self.MinValue, self.MaxValue;
end

--- Returns the value.
function NumberBox:GetValue()
	return self:GetNumber();
end

--- Returns the value step.
function NumberBox:GetValueStep()
	return self.ValueStep;
end

--- Called when the editbox loses focus.
function NumberBox:OnEditFocusLost()
	self:HighlightText(0, 0);
	-- Cap the value.
	self:SetValue(tonumber(self:GetText()) or self.LastValue);
	if(self:GetValue() ~= self.LastValue) then
		self:OnValueUpdated(self:GetValue());
	end
end

--- OnMouseWheel script handler.
-- @param delta Mousewheel direction.
function NumberBox:OnMouseWheel(delta)
	if(delta == 1) then
		self:SetValue(self:GetValue() + self:GetValueStep());
	else
		self:SetValue(self:GetValue() - self:GetValueStep());
	end
end

--- Sets the min/max values.
-- @param min The lower bound.
-- @param max The upper bound.
function NumberBox:SetMinMaxValues(min, max)
	self.MinValue = min;
	self.MaxValue = math.max(min, max);
	self:SetValue(self:GetValue());
end

--- Sets the value.
-- @param value The value to set.
function NumberBox:SetValue(value)
	-- Round the base value to one DP's.
	value = tonumber(value or self:GetValue());
	value = math.floor((value / self.ValueStep) * 10 + 0.5)
		/ 10 * self.ValueStep;
	self:SetNumber(math.max(self.MinValue, math.min(value, self.MaxValue)));
	-- Update buttons.
	if(self:GetValue() == self.MinValue) then
		self.Do:Hide();
	else
		self.Do:Show();
	end
	if(self:GetValue() == self.MaxValue) then
		self.Up:Hide();
	else
		self.Up:Show();
	end
	-- Fire callback.
	self:OnValueUpdated(self:GetValue());
end

--- Sets the value step.
-- @param step The step to set.
function NumberBox:SetValueStep(step)
	self.ValueStep = step;
	self:SetValue(self:GetValue());
end

--- EditBox template designed for editing action sequences.
local SequenceEditBox = PowerAuras:RegisterWidget("SequenceEditBox", "EditBox");

--- Called when the frame has been constructed.
-- @param parent     The parent frame.
-- @param actionID   The ID of the action.
-- @param sequenceID The ID of the sequence.
function SequenceEditBox:Initialise(parent, actionID, sequenceID)
	-- Automatically set the title text and connect handlers.
	self:SetTitle(L["TriggerOperators"]);
	self.OnValueUpdated:Connect(self.OnValueUpdatedHandler);
	self:ConnectParameter("SequenceOp", "", self.OnParameterUpdatedHandler,
		actionID, sequenceID);
	-- Update displayed text.
	self:SetText(
		PowerAuras:GetParameter("SequenceOp", "", actionID, sequenceID)
	);
	-- Store ID's.
	self.Action = actionID;
	self.Sequence = sequenceID;
	-- Continue initialisation.
	self:SetRelativeWidth(1.0);
	base(self, parent);
end

--- Called when the sequence parameter is updated.
-- @param _     Unused.
-- @param _     Unused.
-- @param value The new value of the sequence.
function SequenceEditBox:OnParameterUpdatedHandler(value)
	self:SetText(value:gsub("|+", "|"));
end

--- Called when the value is updated.
-- @param value The new editbox value.
function SequenceEditBox:OnValueUpdatedHandler(value)
	-- Fix pipes.
	value = value:gsub("|+", "|");
	PowerAuras:SetParameter("SequenceOp", "", value, self.Action,
		self.Sequence);
end

--- Special editbox template which integrates with the FAIAP lib.
local CodeBox = PowerAuras:RegisterWidget("CodeBox", "ReusableWidget");

--- Constructs/recycles an instance of the widget class.
function CodeBox:New()
	-- Recycle the widget if possible.
	local frame = base(self);
	if(not frame) then
		-- Construct widget.
		frame = CreateFrame("Frame", nil, UIParent);
		frame:SetBackdrop(PowerAuras:GetWidget("BorderedFrame").Backdrop);
		frame:SetBackdropColor(0.0, 0.0, 0.0, 0.5);
		frame:SetBackdropBorderColor(0.3, 0.3, 0.3, 1.0);
		-- Enable the mousewheel, create a subframe for our contents.
		frame:EnableMouseWheel(true);
		frame.Sub = CreateFrame("ScrollFrame", nil, frame);
		frame.Sub:SetPoint("TOPLEFT", 4, -4);
		frame.Sub:SetPoint("BOTTOMRIGHT", -24, 4);
		-- Scrollbar for scrolling.
		frame.ScrollBar = PowerAuras:Create("ScrollBar");
		frame.ScrollBar:SetParent(frame);
		frame.ScrollBar:SetPoint("TOPRIGHT", -3, -20);
		frame.ScrollBar:SetPoint("BOTTOMRIGHT", -3, 20);
		frame.ScrollBar.OnValueUpdated:Connect(function(self, value)
			frame.Sub:SetVerticalScroll(value);
		end);
		frame.ScrollBar:Show();
		-- Add our child editbox.
		frame.Edit = CreateFrame("EditBox", nil, frame.Sub);
		frame.Edit:SetMultiLine(true);
		frame.Edit:SetJustifyH("LEFT");
		frame.Edit:SetAutoFocus(false);
		frame.Edit:SetTextInsets(0, 32, 0, 0);
		frame.Sub:SetScrollChild(frame.Edit);
		-- Connect scripts.
		frame.Edit:SetScript("OnEscapePressed", frame.Edit.ClearFocus);
		frame.Edit:SetScript("OnSizeChanged", function(self, w, h)
			local st = frame.ScrollBar:GetValueStep();
			frame.ScrollBar:SetMinMaxValues(
				0,
				math.max(0, math.ceil((h - frame.Sub:GetHeight()) / st) * st)
			);
		end);
		frame.Edit:SetScript("OnCursorChanged", function(self, x, y, w, h)
			local posY = (-y + h);
			local vs = frame.Sub:GetVerticalScroll();
			local visY = (vs + frame.Sub:GetHeight());
			local st = frame.ScrollBar:GetValueStep();
			if(posY > visY) then
				-- Scroll downwards.
				frame.ScrollBar:SetValue(
					math.ceil((posY - frame.Sub:GetHeight()) / st) * st
				);
			elseif(-y < frame.Sub:GetVerticalScroll()) then
				-- Scroll upwards.
				frame.ScrollBar:SetValue(
					math.ceil((-y) / st) * st
				);
			end
		end);
	end
	return frame;
end

--- Initialises an instance of the widget class.
-- @param parent The parent of the frame.
-- @param noLib  Set to true if you don't want syntax highlighting.
-- @param size   Custom font height. Defaults to 14.
function CodeBox:Initialise(parent, noLib, size)
	-- Reparent the frame and reset the scrollbar.
	self:SetParent(parent);
	self.ScrollBar:SetValueStep(14);
	self.ScrollBar:SetMinMaxValues(0, 0);
	self.ScrollBar:SetValue(0);
	-- Enable FAIAP integration.
	self.IsLibEnabled = not noLib;
	self:SetFontHeight(size or 14);
	if(not noLib) then
		IndentationLib.enable(self.Edit, nil, 4);
	end
end

--- OnMouseDown script handler.
function CodeBox:OnMouseDown()
	self.Edit:SetFocus();
end

--- OnMouseWheel script handler.
-- @param delta The mousewheel direction.
function CodeBox:OnMouseWheel(delta)
	self.ScrollBar:OnMouseWheel(delta);
end

--- OnSizeChanged script handler.
-- @param width  The new frame width.
-- @param height The new frame height.
function CodeBox:OnSizeChanged(width, height)
	self.Edit:SetSize(width, height);
end

--- Recycles the widget, allowing it to be reused.
function CodeBox:Recycle()
	-- Disable code colouring.
	if(self.IsLibEnabled) then
		IndentationLib.disable(self.Edit);
	end
	base(self);
end

--- Sets the font size of the editor.
-- @param size The size in pixels.
function CodeBox:SetFontHeight(size)
	self.FontHeight = math.min(24, math.max(1, size or 14));
	self.ScrollBar:SetValueStep(self.FontHeight);
	-- Update the font.
	local font = self.Edit:SetFont(
		(self.IsLibEnabled
			and [[Interface\AddOns\PowerAuras\Fonts\DejaVu\DejaVuSansMono.ttf]]
			or [[Fonts\FRIZQT__.ttf]]),
		self.FontHeight,
		""
	);
	if(not font) then
		self.Edit:SetFontObject(GameFontHighlight);
	end
end

--- Sets the text displayed in the editor.
-- @param text The text to set.
function CodeBox:SetText(text)
	self.Edit:SetText(tostring(text));
end

--- Editbox for opening dialogs.
local DialogBox = PowerAuras:RegisterWidget("DialogBox", "EditBox");

--- Constructs/recycles an instance of the widget.
-- @param parent The parent of the widget.
function DialogBox:New(parent)
	-- Get the frame sorted.
	local frame = base(self, parent);
	-- Add button for opening the dialog.
	if(not frame.DialogButton) then
		frame.DialogButton = CreateFrame("Button", nil, frame);
		frame.DialogButton:SetPoint("TOPRIGHT", 0, 0);
		frame.DialogButton:SetSize(26, 26);
		frame.DialogButton:SetNormalTexture(
			[[Interface\ChatFrame\UI-ChatIcon-Maximize-Up]]
		);
		frame.DialogButton:SetHighlightTexture(
			[[Interface\ChatFrame\UI-ChatIcon-BlinkHilight]]
		);
		frame.DialogButton:SetPushedTexture(
			[[Interface\ChatFrame\UI-ChatIcon-Maximize-Down]]
		);
		frame.DialogButton:SetScript("OnClick", function(btn)
			-- Create the dialog.
			PlaySound("UChatScrollButton");
			frame:ClearFocus();
			frame.Dialog = PowerAuras:Create(frame.DialogClass, frame.Window,
				unpack(frame.DialogArgs));
			frame.Dialog:SetCancelData(frame:GetText());
			-- Connect callbacks.
			frame:ConnectCallback(frame.Dialog.OnCancel, frame.UpdateText, 2);
			frame:ConnectCallback(frame.Dialog.OnAccept, frame.UpdateText, 2);
			-- Fire callbacks.
			frame:OnDialogOpened(frame.Dialog);
		end);
		frame.DialogButton:SetScript("OnEnter", function()
			if(frame:GetScript("OnEnter")) then
				frame:GetScript("OnEnter")(frame);
			end
		end);
		frame.DialogButton:SetScript("OnLeave", function()
			if(frame:GetScript("OnLeave")) then
				frame:GetScript("OnLeave")(frame);
			end
		end);
		-- Add callbacks.
		frame.OnDialogOpened = PowerAuras.Callback();
	end
	return frame;
end

--- Initialises the widget.
-- @param parent The parent of the widget.
-- @param window The window to attach the dialog to. If not specified, then
--               the editor window is used.
-- @param class  The dialog class to instantiate. Defaults to ModalDialog.
-- @param ...    Additional arguments to pass to the dialog on instantiation.
function DialogBox:Initialise(parent, window, class, ...)
	-- Initialise as normal, but adjust our text insets.
	base(self, parent);
	self:SetTextInsets(4, 30, 2, 2);
	self:SetEditable(true);
	-- Store the window and dialog class.
	self.Window = window or PowerAuras.Editor;
	self.DialogClass = class or "ModalDialog";
	self.DialogArgs = { ... };
end

--- Called when the editbox gains focus.
function DialogBox:OnEditFocusGained()
	-- Editable or not?
	if(not self.Editable) then
		self:ClearFocus();
		self.DialogButton:GetScript("OnClick")(self.DialogButton);
	else
		base(self);
	end
end

--- Called when the editbox loses focus.
function DialogBox:OnEditFocusLost()
	-- Editable or not?
	if(not self.Editable) then
		self:HighlightText(0, 0);
	else
		base(self);
	end
end

--- OnSizeChanged script handler.
function DialogBox:OnSizeChanged()
	if(not self.Editable) then
		self.DialogButton:SetHitRectInsets(-(self:GetWidth() - 26), 0, 0, 0);
	else
		self.DialogButton:SetHitRectInsets(0, 0, 0, 0);
	end
end

--- Recycles the widget, allowing it to be reused.
function DialogBox:Recycle()
	-- Recycle the dialog if needed.
	if(self.Dialog) then
		self.Dialog:Recycle();
		self.Dialog = nil;
	end
	-- Recycle as normal.
	self.OnDialogOpened:Reset();
	self.Window = nil;
	self:SetEditable(true);
	base(self);
end

--- Sets the editable state of the dialog box.
-- @param state The state to set.
function DialogBox:SetEditable(state)
	-- Store the state.
	self.Editable = state;
	-- Expand the hit rect of our button.
	if(not state) then
		self.DialogButton:SetHitRectInsets(-(self:GetWidth() - 26), 0, 0, 0);
	else
		self.DialogButton:SetHitRectInsets(0, 0, 0, 0);
	end
end

--- Sound editbox, comes with support for the sound dialog.
local SoundBox = PowerAuras:RegisterWidget("SoundBox", "EditBox");

--- Constructs/recycles an instance of the widget.
-- @param parent The parent of the widget.
function SoundBox:New(parent)
	-- Get the frame sorted.
	local frame = base(self, parent);
	-- Add button for opening the dialog.
	if(not frame.DialogButton) then
		frame.OnCancel = PowerAuras.Callback();
		frame.OnAccept = PowerAuras.Callback();
		frame.DialogButton = CreateFrame("Button", nil, frame);
		frame.DialogButton:SetPoint("TOPRIGHT", 0, 0);
		frame.DialogButton:SetSize(26, 26);
		frame.DialogButton:SetNormalTexture(
			[[Interface\ChatFrame\UI-ChatIcon-Maximize-Up]]
		);
		frame.DialogButton:SetHighlightTexture(
			[[Interface\ChatFrame\UI-ChatIcon-BlinkHilight]]
		);
		frame.DialogButton:SetPushedTexture(
			[[Interface\ChatFrame\UI-ChatIcon-Maximize-Down]]
		);
		frame.DialogButton:SetScript("OnClick", function(btn)
			-- Create the dialog.
			PlaySound("UChatScrollButton");
			frame:ClearFocus();
			frame.Dialog = PowerAuras:Create("SoundDialog", frame.Window);
			frame.Dialog:SetCancelData({ frame:GetText(), frame.IsWoW });
			-- Connect callbacks.
			frame:ConnectCallback(frame.Dialog.OnCancel, function(_, _, value)
				frame:UpdateText(value[1]);
				frame:OnCancel(unpack(value));
			end);
			frame:ConnectCallback(frame.Dialog.OnAccept, function(_, _, value)
				frame:UpdateText(value[1]);
				frame:OnAccept(unpack(value));
			end);
		end);
	end
	return frame;
end

--- Initialises the widget.
-- @param parent The parent of the widget.
-- @param window The window to attach the dialog to.
function SoundBox:Initialise(parent, window)
	-- Initialise as normal, but adjust our text insets.
	base(self, parent);
	self:SetTextInsets(4, 30, 2, 2);
	-- Store the window.
	self.Window = window;
end

--- Recycles the widget, allowing it to be reused.
function SoundBox:Recycle()
	-- Recycle the dialog if needed.
	if(self.Dialog) then
		self.Dialog:Recycle();
		self.Dialog = nil;
	end
	-- Recycle as normal.
	self.OnAccept:Reset();
	self.OnCancel:Reset();
	self.Window = nil;
	base(self);
end

--- Template editbox, comes with support for the template dialog.
local TemplateBox = PowerAuras:RegisterWidget("TemplateBox", "EditBox");

--- Constructs/recycles an instance of the widget.
-- @param parent The parent of the widget.
function TemplateBox:New(parent)
	-- Get the frame sorted.
	local frame = base(self, parent);
	-- Add button for opening the dialog.
	if(not frame.DialogButton) then
		frame.DialogButton = CreateFrame("Button", nil, frame);
		frame.DialogButton:SetPoint("TOPRIGHT", 0, 0);
		frame.DialogButton:SetSize(26, 26);
		frame.DialogButton:SetNormalTexture(
			[[Interface\ChatFrame\UI-ChatIcon-Maximize-Up]]
		);
		frame.DialogButton:SetHighlightTexture(
			[[Interface\ChatFrame\UI-ChatIcon-BlinkHilight]]
		);
		frame.DialogButton:SetPushedTexture(
			[[Interface\ChatFrame\UI-ChatIcon-Maximize-Down]]
		);
		frame.DialogButton:SetScript("OnClick", function(btn)
			-- Create the dialog.
			PlaySound("UChatScrollButton");
			frame:ClearFocus();
			frame.Dialog = PowerAuras:Create("TemplateDialog", frame.Window);
			frame.Dialog:SetCancelData(frame:GetText());
			-- Connect callbacks.
			frame:ConnectCallback(frame.Dialog.OnCancel, frame.UpdateText, 2);
			frame:ConnectCallback(frame.Dialog.OnAccept, frame.UpdateText, 2);
		end);
	end
	return frame;
end

--- Initialises the widget.
-- @param parent The parent of the widget.
-- @param window The window to attach the dialog to.
function TemplateBox:Initialise(parent, window)
	-- Initialise as normal, but adjust our text insets.
	base(self, parent);
	self:SetTextInsets(4, 30, 2, 2);
	-- Store the window.
	self.Window = window;
end

--- Called when the editbox gains focus.
function TemplateBox:OnEditFocusGained()
	self:ClearFocus();
	self.DialogButton:GetScript("OnClick")(self.DialogButton);
end

--- Called when the editbox loses focus.
function TemplateBox:OnEditFocusLost()
	self:HighlightText(0, 0);
end

--- Recycles the widget, allowing it to be reused.
function TemplateBox:Recycle()
	-- Recycle the dialog if needed.
	if(self.Dialog) then
		self.Dialog:Recycle();
		self.Dialog = nil;
	end
	-- Recycle as normal.
	self.Window = nil;
	base(self);
end

--- Counter texture editbox, comes with support for the counter dialog.
local CounterBox = PowerAuras:RegisterWidget("CounterBox", "EditBox");

--- Constructs/recycles an instance of the widget.
-- @param parent The parent of the widget.
function CounterBox:New(parent)
	-- Get the frame sorted.
	local frame = base(self, parent);
	-- Add button for opening the dialog.
	if(not frame.DialogButton) then
		frame.DialogButton = CreateFrame("Button", nil, frame);
		frame.DialogButton:SetPoint("TOPRIGHT", 0, 0);
		frame.DialogButton:SetSize(26, 26);
		frame.DialogButton:SetNormalTexture(
			[[Interface\ChatFrame\UI-ChatIcon-Maximize-Up]]
		);
		frame.DialogButton:SetHighlightTexture(
			[[Interface\ChatFrame\UI-ChatIcon-BlinkHilight]]
		);
		frame.DialogButton:SetPushedTexture(
			[[Interface\ChatFrame\UI-ChatIcon-Maximize-Down]]
		);
		frame.DialogButton:SetScript("OnClick", function(btn)
			-- Create the dialog.
			PlaySound("UChatScrollButton");
			frame:ClearFocus();
			frame.Dialog = PowerAuras:Create("CounterDialog", frame.Window);
			frame.Dialog:SetCancelData(frame:GetText());
			-- Connect callbacks.
			frame:ConnectCallback(frame.Dialog.OnCancel, frame.UpdateText, 2);
			frame:ConnectCallback(frame.Dialog.OnAccept, frame.UpdateText, 2);
		end);
	end
	return frame;
end

--- Initialises the widget.
-- @param parent The parent of the widget.
-- @param window The window to attach the dialog to.
function CounterBox:Initialise(parent, window)
	-- Initialise as normal, but adjust our text insets.
	base(self, parent);
	self:SetTextInsets(4, 30, 2, 2);
	-- Store the window.
	self.Window = window;
end

--- Called when the editbox gains focus.
function CounterBox:OnEditFocusGained()
	self:ClearFocus();
	self.DialogButton:GetScript("OnClick")(self.DialogButton);
end

--- Called when the editbox loses focus.
function CounterBox:OnEditFocusLost()
	self:HighlightText(0, 0);
end

--- Recycles the widget, allowing it to be reused.
function CounterBox:Recycle()
	-- Recycle the dialog if needed.
	if(self.Dialog) then
		self.Dialog:Recycle();
		self.Dialog = nil;
	end
	-- Recycle as normal.
	self.Window = nil;
	base(self);
end

--- Font editbox, comes with support for the font dialog.
local FontBox = PowerAuras:RegisterWidget("FontBox", "EditBox");

--- Constructs/recycles an instance of the widget.
-- @param parent The parent of the widget.
function FontBox:New(parent)
	-- Get the frame sorted.
	local frame = base(self, parent);
	-- Add button for opening the dialog.
	if(not frame.DialogButton) then
		frame.DialogButton = CreateFrame("Button", nil, frame);
		frame.DialogButton:SetPoint("TOPRIGHT", 0, 0);
		frame.DialogButton:SetSize(26, 26);
		frame.DialogButton:SetNormalTexture(
			[[Interface\ChatFrame\UI-ChatIcon-Maximize-Up]]
		);
		frame.DialogButton:SetHighlightTexture(
			[[Interface\ChatFrame\UI-ChatIcon-BlinkHilight]]
		);
		frame.DialogButton:SetPushedTexture(
			[[Interface\ChatFrame\UI-ChatIcon-Maximize-Down]]
		);
		frame.DialogButton:SetScript("OnClick", function(btn)
			-- Create the dialog.
			PlaySound("UChatScrollButton");
			frame:ClearFocus();
			frame.Dialog = PowerAuras:Create("FontDialog", frame.Window);
			frame.Dialog:SetCancelData(frame:GetText());
			-- Connect callbacks.
			frame:ConnectCallback(frame.Dialog.OnCancel, frame.UpdateText, 2);
			frame:ConnectCallback(frame.Dialog.OnAccept, frame.UpdateText, 2);
		end);
	end
	return frame;
end

--- Initialises the widget.
-- @param parent The parent of the widget.
-- @param window The window to attach the dialog to.
function FontBox:Initialise(parent, window)
	-- Initialise as normal, but adjust our text insets.
	base(self, parent);
	self:SetTextInsets(4, 30, 2, 2);
	-- Store the window.
	self.Window = window;
end

--- Called when the editbox gains focus.
function FontBox:OnEditFocusGained()
	self:ClearFocus();
	self.DialogButton:GetScript("OnClick")(self.DialogButton);
end

--- Called when the editbox loses focus.
function FontBox:OnEditFocusLost()
	self:HighlightText(0, 0);
end

--- Recycles the widget, allowing it to be reused.
function FontBox:Recycle()
	-- Recycle the dialog if needed.
	if(self.Dialog) then
		self.Dialog:Recycle();
		self.Dialog = nil;
	end
	-- Recycle as normal.
	self.Window = nil;
	base(self);
end

--- Display editbox, comes with support for the display dialog.
local DisplayBox = PowerAuras:RegisterWidget("DisplayBox", "EditBox");

--- Constructs/recycles an instance of the widget.
-- @param parent The parent of the widget.
function DisplayBox:New(parent)
	-- Get the frame sorted.
	local frame = base(self, parent);
	-- Add button for opening the dialog.
	if(not frame.DialogButton) then
		frame.DialogButton = CreateFrame("Button", nil, frame);
		frame.DialogButton:SetPoint("TOPRIGHT", 0, 0);
		frame.DialogButton:SetSize(26, 26);
		frame.DialogButton:SetNormalTexture(
			[[Interface\ChatFrame\UI-ChatIcon-Maximize-Up]]
		);
		frame.DialogButton:SetHighlightTexture(
			[[Interface\ChatFrame\UI-ChatIcon-BlinkHilight]]
		);
		frame.DialogButton:SetPushedTexture(
			[[Interface\ChatFrame\UI-ChatIcon-Maximize-Down]]
		);
		frame.DialogButton:SetScript("OnClick", function(btn)
			-- Create the dialog.
			PlaySound("UChatScrollButton");
			frame:ClearFocus();
			frame.Dialog = PowerAuras:Create("DisplayDialog", frame.Window);
			frame.Dialog:SetCancelData(frame:GetNumber());
			-- Connect callbacks.
			frame:ConnectCallback(frame.Dialog.OnCancel, frame.UpdateText, 2);
			frame:ConnectCallback(frame.Dialog.OnAccept, frame.UpdateText, 2);
		end);
	end
	return frame;
end

--- Initialises the widget.
-- @param parent The parent of the widget.
-- @param window The window to attach the dialog to.
function DisplayBox:Initialise(parent, window)
	-- Initialise as normal, but adjust our text insets.
	base(self, parent);
	self:SetTextInsets(4, 30, 2, 2);
	self:SetNumeric(true);
	-- Store the window.
	self.Window = window;
end

--- Recycles the widget, allowing it to be reused.
function DisplayBox:Recycle()
	-- Recycle the dialog if needed.
	if(self.Dialog) then
		self.Dialog:Recycle();
		self.Dialog = nil;
	end
	-- Recycle as normal.
	self.Window = nil;
	base(self);
end