-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Styles the passed frame based on the passed parameters.
-- @param frame  The frame to style.
-- @param params The parameters to style from.
local function Styler(frame, params)
	-- Get the template to configure from.
	local template = PowerAuras:GetBarTemplate(params["Template"]);
	-- Configure frame according to parameters.
	frame:SetAlpha(params["Alpha"]);
	frame:SetFrameStrata(params["Strata"]);
	frame:SetSize(
		template["Size"][1] * params["Scale"],
		template["Size"][2] * params["Scale"]
	);
	-- Frame texture.
	if(template["Frame"]) then
		frame.FrameTexture = (frame.FrameTexture or frame:CreateTexture());
		frame.FrameTexture:SetDrawLayer("ARTWORK");
		frame.FrameTexture:SetAllPoints(frame);
		frame.FrameTexture:SetTexture(template["Frame"]);
		frame.FrameTexture:Show();
	elseif(frame.FrameTexture) then
		frame.FrameTexture:Hide();
	end
	-- Background texture.
	if(template["Background"]) then
		frame.BackgroundTexture = (frame.BackgroundTexture
			or frame:CreateTexture());
		frame.BackgroundTexture:SetDrawLayer("BACKGROUND");
		frame.BackgroundTexture:SetAllPoints(frame);
		frame.BackgroundTexture:SetTexture(template["Background"]);
		frame.BackgroundTexture:Show();
	elseif(frame.BackgroundTexture) then
		frame.BackgroundTexture:Hide();
	end
	-- Fill texture.
	if(template["Fill"]) then
		frame.FillTexture = (frame.FillTexture or frame:CreateTexture());
		frame.FillTexture:SetDrawLayer("BORDER");
		frame.FillTexture:SetTexture(template["Fill"]);
		frame.FillTexture:Show();
		frame.FillTexture:SetVertexColor(unpack(params["FillTint"]));
		-- Anchor based on template type.
		if(template["Type"] == "Horizontal") then
			frame.FillTexture:SetPoint("TOPLEFT");
			frame.FillTexture:SetPoint("BOTTOMLEFT");
			-- Fill to 50%.
			local frameWidth = frame:GetWidth();
			frame.FillTexture:SetWidth(0.5 * frameWidth);
			frame.FillTexture:SetTexCoord(0, 0.5, 0, 1);
		else
			-- TODO
		end
	elseif(frame.FillTexture) then
		frame.FillTexture:Hide();
	end
	-- Spark texture.
	if(template["Spark"]) then
		frame.SparkTexture = (frame.SparkTexture or frame:CreateTexture());
		frame.SparkTexture:SetDrawLayer("OVERLAY");
		frame.SparkTexture:SetTexture(template["Spark"]);
		frame.SparkTexture:SetBlendMode(template["SparkBlendMode"] or "ADD");
		frame.SparkTexture:Show();
		-- Anchor/size based on template type.
		if(template["Type"] == "Horizontal") then
			frame.SparkTexture:SetWidth(frame:GetHeight() / 8);
			frame.SparkTexture:SetPoint("TOPLEFT", frame.FillTexture, 
				"TOPRIGHT", -3, 0);
			frame.SparkTexture:SetPoint("BOTTOMLEFT", frame.FillTexture, 
				"BOTTOMRIGHT", -3, 0);
		else
			-- TODO
		end
	elseif(frame.SparkTexture) then
		frame.SparkTexture:Hide();
	end
	-- Flash texture.
	if(template["Flash"]) then
		frame.FlashTexture = (frame.FlashTexture or frame:CreateTexture());
		frame.FlashTexture:SetDrawLayer("OVERLAY");
		frame.FlashTexture:SetBlendMode(template["FlashBlendMode"] or "ADD");
		frame.FlashTexture:SetAllPoints(frame);
		frame.FlashTexture:SetTexture(template["Flash"]);
		frame.FlashTexture:SetAlpha(0.0);
		frame.FlashTexture:Show();
		-- Flash textures animate in and out really quickly.
		local tex = frame.FlashTexture;
		-- Begin show fade.
		if(not tex.BeginShow) then
			tex.BeginShow = tex:CreateAnimationGroup();
			tex.BeginShow.Anim = tex.BeginShow:CreateAnimation("Alpha");
			tex.BeginShow.Anim:SetDuration(0.2);
			tex.BeginShow.Anim:SetSmoothing("IN");
			tex.BeginShow.Anim:SetChange(1.0);
			tex.BeginShow:SetScript("OnPlay", function()
				if(tex.BeginHide:IsPlaying()) then
					local a = tex:GetAlpha();
					tex.BeginHide:Stop();
					tex:SetAlpha(a);
				end
			end);
			tex.BeginShow:SetScript("OnFinished", function()
				tex:SetAlpha(1.0);
			end);
		end
		-- Begin hide fade.
		if(not tex.BeginHide) then
			tex.BeginHide = tex:CreateAnimationGroup();
			tex.BeginHide.Anim = tex.BeginHide:CreateAnimation("Alpha");
			tex.BeginHide.Anim:SetDuration(0.2);
			tex.BeginHide.Anim:SetSmoothing("OUT");
			tex.BeginHide.Anim:SetChange(-1.0);
			tex.BeginHide:SetScript("OnPlay", function()
				if(tex.BeginShow:IsPlaying()) then
					local a = tex:GetAlpha();
					tex.BeginShow:Stop();
					tex:SetAlpha(a);
				end
			end);
			tex.BeginHide:SetScript("OnFinished", function()
				tex:SetAlpha(0.0);
			end);
		end
	elseif(frame.FlashTexture) then
		frame.FlashTexture:Hide();
	end
end

--- Display class definition.
local TimerBar = PowerAuras:RegisterDisplayClass("TimerBar", {
	--- Dictionary of default parameters this display uses.
	Parameters = {
		Alpha = 1.0,
		FillTint = { 1.0, 1.0, 1.0 },
		Invert = false,
		Template = "Amber",
		Scale = 1.0,
		Strata = "LOW",
	},
	--- Dictionary of action classes this display supports.
	Actions = {
		DisplayActivate = true,
		DisplayColor    = true,
		DisplayScale    = true,
		DisplaySound    = true,
		DisplayBarGlow  = true,
	},
	--- Dictionary of provider services required by this display type.
	Services = {
		Timer = true,
	},
	--- Dictionary of optional provider services that can be used by this
	--  display type.
	OptServices = {},
});

--- Constructs a new instance of the display and returns it.
-- @param frame    A frame to use for the display. The frame may have been
--                 used by a previous display of this type.
-- @param id       The ID number of the display.
-- @param params   The parameters to construct the display from.
function TimerBar:New(frame, id, params)
	-- Get the template data.
	local template = PowerAuras:GetBarTemplate(params["Template"]);
	-- Pass the frame and data to the styler function.
	Styler(frame, params);

	-- Support for providers.
	local timeStart, timeEnd = 0, 2^31 - 1;
	function frame:OnProviderUpdate()
		local newStart, newEnd = self.Provider.Timer();
		-- The one case we ignore is if the start changes but the
		-- end time doesn't.
		if(newStart ~= timeStart and newEnd ~= timeEnd) then
			-- Set as normal.
			timeStart, timeEnd = newStart, newEnd;
		elseif(newStart == timeStart and newEnd ~= timeEnd) then
			-- Start time is the same, so this is a timer extension.
			timeEnd = newEnd;
		end
	end;

	-- Function upvalues.
	local startInset, endInset = (template["StartInset"] or 0), 
		(template["EndInset"] or 0);
	local fillType, fillInvert = template["Type"], params["Invert"];

	-- OnUpdate handler for the display. Updates the timer bar.
	function frame:OnUpdate()
		-- Get current time.
		local timeNow = GetTime();
		-- Calculate progress from 0-100%.
		local num = (timeNow - timeStart);
		local den = (timeEnd - timeStart);
		local progress = (den > 0 and (num / den) or 1);
		-- Bar insets based on template data.
		progress = startInset + progress * (1 - endInset - startInset);
		-- Cap between insets.
		progress = math.min(1 - endInset, math.max(startInset, progress));
		-- Update fill.
		local fW, fH =  self:GetSize();
		if(fillType == "Horizontal") then
			if(fillInvert) then
				self.FillTexture:SetWidth(fW - (progress * fW));
				self.FillTexture:SetTexCoord(0, (1 - progress), 0, 1);
			else
				self.FillTexture:SetWidth((progress * fW));
				self.FillTexture:SetTexCoord(0, progress, 0, 1);
			end
		else
			-- TODO
		end
	end;

	-- Done!
	frame:Hide();
	return frame;
end

--- Applies an action to an instance of the display class.
-- @param display The display instance itself.
-- @param action  The action class name, such as "DisplayColor".
-- @param ...     Sequence parameters of the action.
function TimerBar:ApplyAction(action, display, ...)
	if(action == "DisplayColor") then
		local r, g, b = ...;
		if(display.FillTexture) then
			local a = display.FillTexture:GetAlpha();
			display.FillTexture:SetVertexColor(r, g, b, a);
		end
	elseif(action == "DisplayScale") then
		display:SetSize(...);
	end
end

--- Creates a static preview of a display for use with the editor.
-- @param frame The frame to attach the preview to.
-- @param id    The ID of the display to preview.
function TimerBar:CreatePreview(frame, id)
	-- Initial styling.
	local display = PowerAuras:GetAuraDisplay(id);
	Styler(frame, display["Parameters"]);
	-- OnUpdate throttle data.
	frame:SetID(id);
	frame.Progress = frame.Progress or 0;
	frame.LastUpdate = frame.LastUpdate or GetTime();
	-- Fix the fill texture overflowing.
	if(not frame.Hooked) then
		frame.Hooked = true;
		frame:HookScript("OnSizeChanged", function(frame)
			frame.Update = true;
			frame:GetScript("OnUpdate")(frame);
		end);
	end
	-- Add OnUpdate script for previewing the bar at different fill values.
	if(not frame:GetScript("OnUpdate")) then
		frame:SetScript("OnUpdate", function(self)
			-- Throttle.
			if(self.LastUpdate > GetTime() - 0.025 and not self.Update
				or not PowerAuras:HasAuraDisplay(self:GetID())) then
				return;
			end
			-- Update progress.
			local elapsed = GetTime() - self.LastUpdate;
			self.Progress = self.Progress + (elapsed / 0.025) * 0.00625;
			if(self.Progress > 1) then
				self.Progress = 0;
			end
			-- Get template/display data.
			local display = PowerAuras:GetAuraDisplay(self:GetID());
			local params = display["Parameters"];
			local template = PowerAuras:GetBarTemplate(params["Template"]);
			if(not template) then
				return;
			end

			-- Update bar.
			local sI, eI = template["StartInset"], template["EndInset"];
			local progress = sI + self.Progress * (1 - eI - sI);
			-- Cap between insets.
			progress = math.min(1 - eI, math.max(sI, progress));
			-- Update fill.
			local fW, fH =  self:GetSize();
			if(template["Type"] == "Horizontal") then
				if(params["Invert"]) then
					self.FillTexture:SetWidth(fW - (progress * fW));
					self.FillTexture:SetTexCoord(0, (1 - progress), 0, 1);
				else
					self.FillTexture:SetWidth((progress * fW));
					self.FillTexture:SetTexCoord(0, progress, 0, 1);
				end
			else
				-- TODO
			end
			
			-- Set next update time.
			self.LastUpdate = GetTime();
			self.Update = false;
		end);
	end
end

--- Populates the style editor frame with widgets for controlling the
--  parameters of the display.
-- @param frame The frame to populate with controls.
-- @param ...   ID's to match against for the editor.
function TimerBar:CreateStyleEditor(frame, ...)
	-- Template picker.
	local template = PowerAuras:Create("TemplateBox", frame, PowerAuras.Editor);
	template:SetUserTooltip("DTimerBar_Template");
	template:SetText(PowerAuras:GetParameter("Display", "Template", ...));
	template:SetPadding(4, 0, 2, 0);
	template:SetRelativeWidth(0.55);
	template:SetTitle(L["Template"]);
	template:ConnectParameter("Display", "Template", template.SetText, ...);
	template.OnValueUpdated:Connect(PowerAuras:FormatString([[
		local self, value = ...;
		PowerAuras:SetParameter("Display", "Template", value, ${...});
	]], ...));

	-- Fill tint.
	local picker = PowerAuras:Create("P_ColorPicker", frame);
	picker:SetUserTooltip("Color");
	picker:LinkParameter("Display", "FillTint", ...);
	picker:SetMargins(0, 20, 0, 0);
	picker:SetPadding(2, 0, 2, 0);
	picker:SetRelativeWidth(0.175);

	-- Bar inversion.
	local invert = PowerAuras:Create("P_Checkbox", frame);
	invert:SetUserTooltip("DTimerBar_Invert");
	invert:LinkParameter("Display", "Invert", ...);
	invert:SetRelativeWidth(0.275);
	invert:SetMargins(0, 20, 0, 0);
	invert:SetPadding(2, 0, 4, 0);
	invert:SetText(L["Invert"]);

	-- Alpha slider.
	local alpha = PowerAuras:Create("P_AlphaSlider", frame);
	alpha:SetUserTooltip("Opacity");
	alpha:LinkParameter("Display", "Alpha", ...);
	alpha:SetPadding(4, 0, 2, 0);
	alpha:SetRelativeWidth(0.35);

	-- Scale slider.
	local scale = PowerAuras:Create("P_ScaleSlider", frame);
	scale:SetUserTooltip("Scale");
	scale:LinkParameter("Display", "Scale", ...);
	scale:SetPadding(2, 0, 2, 0);
	scale:SetRelativeWidth(0.35);

	-- Frame strata.
	local strata = PowerAuras:Create("P_StrataDropdown", frame);
	strata:SetUserTooltip("Layer");
	strata:LinkParameter("Display", "Strata", ...);
	strata:SetPadding(2, 0, 4, 0);
	strata:SetRelativeWidth(0.3);

	-- Add widgets to layout.
	frame:AddWidget(template);
	frame:AddWidget(picker);
	frame:AddWidget(invert);
	frame:AddRow(4);
	frame:AddWidget(alpha);
	frame:AddWidget(scale);
	frame:AddWidget(strata);
end

--- Returns a table of default sequence parameters to pass to ApplyAction
--  in the event that no sequence is activated. May return nil.
-- @param action  The action class name, such as "DisplayColor".
-- @param display The display instance itself.
function TimerBar:GetActionDefaults(action, display)
	if(action == "DisplayColor") then
		if(display.FillTexture) then
			return { display.FillTexture:GetVertexColor() };
		else
			return { 1.0, 1.0, 1.0 };
		end
	elseif(action == "DisplayScale") then
		return { display:GetSize() };
	else
		-- No targets.
		return nil;
	end
end

--- Upgrades an display from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The display parameters to upgrade.
function TimerBar:Upgrade(version, params)
	
end