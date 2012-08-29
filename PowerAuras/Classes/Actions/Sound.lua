-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Sound action. Plays a sound when activated.
local Sound = PowerAuras:RegisterActionClass("Sound", {
	Parameters = {
		[1] = [[Interface\AddOns\PowerAuras\Sounds\shot.ogg]], -- Sound file.
		[2] = "MASTER",   -- Channel.
		[3] = false,      -- True if WoW sound, false otherwise.
	},
});

--- Constructor function for the action. Generates and returns an activator.
-- @param id      The ID of the action.
-- @param params  Parameters for constructing the action.
function Sound:New(id, parameters)
	-- Generate the activator.
	return function(seqID, oldSeqID, sound, channel, isWoW)
		if(seqID and seqID ~= oldSeqID) then
			if(isWoW) then
				PlaySound(sound, channel);
			else
				PlaySoundFile(sound, channel);
			end
		end
	end;
end

--- Constructs the sequence editor for an action.
-- @param frame The frame to apply widgets to.
-- @param ...   The ID's to pass to Get/SetParameter calls.
function Sound:CreateSequenceEditor(frame, ...)
	-- Create sound pickerydoo.
	local soundbox = PowerAuras:Create("SoundBox", frame, PowerAuras.Editor);
	soundbox:SetUserTooltip("Sound_Path");
	soundbox:SetTitle(SOUND_LABEL);
	soundbox:SetPadding(4, 0, 2, 0);
	soundbox:SetRelativeWidth(0.6);
	soundbox.IsWoW = PowerAuras:GetParameter("Sequence", 3, ...);
	soundbox:SetText(tostring(PowerAuras:GetParameter("Sequence", 1, ...)));
	soundbox:ConnectParameter("Sequence", 1, soundbox.SetText, ...);
	soundbox:ConnectParameter("Sequence", 3, PowerAuras:Loadstring([[
		local self, value = ...;
		self.IsWoW = value;
	]]), ...);
	local callback = PowerAuras:FormatString([[
		local self, path, isWoW = ...;
		self.IsWoW = isWoW;
		PowerAuras:SetParameter("Sequence", 1, path, ${...});
		PowerAuras:SetParameter("Sequence", 3, isWoW, ${...});
	]], ...);
	soundbox.OnAccept:Connect(callback);
	soundbox.OnCancel:Connect(callback);

	-- Channel dropdown.
	local channel = PowerAuras:Create("SimpleDropdown", frame);
	channel:SetUserTooltip("Sound_Channel");
	channel:SetTitle(CHANNEL);
	channel:SetPadding(2, 0, 4, 0);
	channel:SetRelativeWidth(0.3875);
	channel:AddCheckItem("MASTER", MASTER);
	channel:AddCheckItem("SFX", EFFECTS_SUBHEADER);
	channel:AddCheckItem("MUSIC", MUSIC_VOLUME);
	channel:AddCheckItem("AMBIENCE", AMBIENCE_VOLUME);
	local param = tostring(PowerAuras:GetParameter("Sequence", 2, ...));
	channel:SetText(param);
	channel:SetItemChecked(param, true);
	channel:ConnectParameter("Sequence", 2, channel.SetText, ...);
	channel.OnValueUpdated:Connect(PowerAuras:FormatString([[
		local self, key = ...;
		self:SetText(key);
		self:CloseMenu();
		for _, item in pairs(self.ItemsByKey["__ROOT__"]) do
			self:SetItemChecked(item.Key, item.Key == key);
		end
		PowerAuras:SetParameter("Sequence", 2, key, ${...});
	]], ...));
	-- Add widgets to frame.
	frame:AddWidget(soundbox);
	frame:AddStretcher();
	frame:AddWidget(channel);
end

--- Upgrades an action from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The parameter table to be updated.
function Sound:Upgrade(version, params)
end

--- Small workaround for sounds on displays :)
local Sound = PowerAuras:CopyTable(Sound);
local DisplaySound = PowerAuras:RegisterActionClass("DisplaySound", Sound);

--- Returns the target user of this action.
function DisplaySound:GetTarget()
	return "Display";
end