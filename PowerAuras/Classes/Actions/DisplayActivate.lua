-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Frame used for processing timers.
local Throttle = PowerAuras.Throttle(function(self, elapsed)
	-- Iterate over the list.
	local item = self.List.Start;
	while(item) do
		-- Execute function.
		local res = item.Func(elapsed);
		-- Next item.
		item = item.Next;
		-- Destroy the item we just processed?
		if(res) then
			if(item) then
				self.List:Remove(item.Prev.Func);
			else
				self.List:Remove(self.List.End.Func);
			end
		end
	end
end);

--- Double linked of displays that need processing by our throttled frame.
Throttle.List = {
	Start = nil,
	End = nil,
	Tables = setmetatable({}, { __mode = "v" }),
};

--- Adds a function to the list.
-- @param elem The function to add.
function Throttle.List:Add(elem)
	-- Don't duplicate entries.
	if(self[elem]) then
		return;
	end

	-- Create an item table.
	local item = tremove(self.Tables) or { Prev = nil, Next = nil, Func = nil };
	item.Prev, item.Next, item.Func = self.End, nil, elem;
	-- Add to the end of the chain.
	if(self.End) then
		self.End.Next = item;
	end

	-- Set this one as the end and add it.
	self.End = item;
	self.Start = self.Start or item;
	self[elem] = item;
end

--- Removes a function from the list.
-- @param elem The function to remove.
function Throttle.List:Remove(elem)
	-- Check if it exists.
	if(not self[elem]) then
		return;
	end

	-- Remove from the chain.
	local item = self[elem];
	if(item.Prev) then
		item.Prev.Next = item.Next;
	end
	if(item.Next) then
		item.Next.Prev = item.Prev;
	end

	-- Remove pointers to this one.
	if(self.End == item) then
		self.End = item.Next;
	end
	if(self.Start == item) then
		self.Start = item.Next;
	end

	-- Recycle.
	tinsert(self.Tables, wipe(item));
	self[elem] = nil;
end

-- Pause the throttle when appropriate.
PowerAuras.OnAddOnLoaded:Connect(function() Throttle.Update:Play(); end);
PowerAuras.OnOptionsEvent:Connect(function(event, state)
	if(event == "EDIT_MODE") then
		-- Empty the list.
		local k, v = next(Throttle.List);
		while(k) do
			if(k ~= "Add" and k ~= "Remove" and k ~= "Tables") then
				if(type(v) == "table" and k ~= "Start" and k ~= "End") then
					tinsert(Throttle.List.Tables, wipe(v));
				end
				Throttle.List[k] = nil;
			end
			k, v = next(Throttle.List, k);
		end

		-- Pause/play the animation.
		if(state) then
			Throttle.Update:Pause();
		else
			Throttle.LastUpdate = GetTime();
			Throttle.Update:Play();
		end
	end
end);

--- Sets the shown state of a display.
-- @param display The display to process.
-- @param id      The ID of the display.
-- @param state   The state to set.
-- @param async   The async parameter for SetDisplayActivationData.
local function SetDisplayState(display, id, state, async)
	if(state == "Show") then
		if(display.OnBeginShow) then
			display:OnBeginShow();
		else
			PowerAuras:SetDisplayActivationData(id, "Show", async);
			display:Show();
		end
	elseif(state == "Hide") then
		if(display.OnBeginHide) then
			display:OnBeginHide();
		else
			PowerAuras:SetDisplayActivationData(id, "Hide", async);
			display:Hide();
		end
	end
end

--- Activate action. Shows/hides a display based on criteria.
local DisplayActivate = PowerAuras:RegisterActionClass("DisplayActivate", {
	Parameters = {
		[1] = 0.0,   -- Onset delay. Delays the showing of the display.
		[2] = 0.0,   -- Custom duration to show the display for.
		[3] = false, -- If set to true, the delays/sequences in this sequence
		             -- will override any currently active ones. Note that
		             -- onsets are only included if currently in an onset.
     	[4] = 1,     -- Changes how the current progress is handled if
     	             -- the display deactivates/reactivates while in the
     	             -- onset phase.
 	    [5] = false, -- If true, the display cannot be killed in the onset.
 	    [6] = 1,     -- Changes how the progress is reset if the display
 	                 -- deactivates/reactivates while in the duration phase.
        [7] = 0,     -- Changes how the current progress is modified if
                     -- an override is performed.
	},
});

--- Constructor function for the action. Generates and returns an activator.
-- @param id      The ID of the action.
-- @param params  Parameters for constructing the action.
-- @param display The display to create the action for.
-- @param dID     The ID of the display.
function DisplayActivate:New(id, parameters, display, dID)
	-- Generated function upvalue. We use it for some trickery.
	local activator;
	local cOnset, cLimit = 0, 0;
	local cProg, cState, cSeq, cImmo = 0, 0, nil, false;

	-- Generate our onset/duration handler.
	-- @param elapsed Time since the last update.
	local function OnUpdate(elapsed)
		-- Rather, we're processing our onsets/durations.
		cProg = cProg + elapsed;
-- PowerAuras:PrintInfo("Advance time to %.2f", cProg);
		-- Passed our onset?
		if(cState == 0 and (cOnset == 0 or cProg >= cOnset)) then
-- PowerAuras:PrintInfo("Set state to duration");
			cProg = cProg - cOnset;
			-- Update our show state.
			if(cSeq or cImmo) then
				-- The criteria are still active, show.
				cState = 1;
-- PowerAuras:PrintInfo("Still active, show!");
			else
-- PowerAuras:PrintInfo("Killed in onset");
				cState = 2;
				cProg = 0;
			end
		elseif(cState == 1 and (cLimit > 0 and cProg >= cLimit)) then
			-- We have a duration and we exceeded it.
			cState = 2;
			cProg = 0;
-- PowerAuras:PrintInfo("Set state to hide");
		elseif(cState == 1 and cLimit == 0 and not cSeq) then
-- PowerAuras:PrintInfo("Killed (async)!");
			cState = 2;
			cProg = 0;
		end

		-- Have we died yet?
		if(cState == 2) then
-- PowerAuras:PrintInfo("I'm dead!");
			SetDisplayState(display, dID, "Hide", true);
			-- If the sequence is still active, go to state 3 (dead).
			cState = (cSeq and 3 or 0);
			cOnset, cLimit, cSeq, cImmo = 0, 0, nil, false;
			return true;
		elseif(cState >= 1 and not display:IsShown()) then
			-- We're supposed to be showing.
			SetDisplayState(display, dID, "Show", true);
		end
	end

	-- Generate the function.
	return function(seq, old, onset, duration, override, rOn, immo, rDur, rOv)
		-- Are we activating or deactivating?
		if(seq and not old) then
			-- Activating. Got an onset or a duration?
			if(onset > 0 or duration > 0) then
				-- Put ourselves into the list and store our onset/duration.
-- PowerAuras:PrintInfo("Activated!");
				Throttle.List:Add(OnUpdate);
				cOnset = onset;
				cLimit = duration;
				cSeq = seq;
				cImmo = immo;
				-- Rolling onset/duration?
				cProg = (cState == 0 and (rOn == 0 and cProg
						or rOn == 1 and 0
						or rOn == 2 and (cProg > 0 and cProg - cOnset or 0))
					or cState == 1 and (rDur == 0 and cProg
						or rDur == 1 and 0
						or rDur == 2 and cProg - cLimit)
					or cProg);
				-- If there's no onset, show immediately.
				if(cState == 0 and cOnset == 0) then
					SetDisplayState(display, dID, "Show", false);
					cState = 1;
				end
			else
				-- Activate as normal.
				SetDisplayState(display, dID, "Show", false);
			end
		elseif(not seq and old) then
			-- Deactivating.
			if(cState > 0 or Throttle.List[OnUpdate]) then
				-- Remove from updates.
				cSeq = nil;
				if(cState == 1 and cLimit == 0 or cState >= 2) then
-- PowerAuras:PrintInfo("Killed!");
					Throttle.List:Remove(OnUpdate);
					cOnset, cLimit, cSeq, cState, cImmo = 0, 0, nil, 0, false;
					-- Kill the display if it's showing.
					if(display:IsShown()) then
						SetDisplayState(display, dID, "Hide", false);
					end
				-- else
-- PowerAuras:PrintInfo("Kill paused, override in progress");
				end
			else
				-- Deactivate as normal.
				SetDisplayState(display, dID, "Hide", false);
			end
		elseif(seq ~= old and override) then
			-- Sequence changing with an override.
			cOnset = onset;
			cLimit = duration;
			cSeq = seq;
			cImmo = immo;
			-- Handle the progress.
			cProg = (rOv == 0 and cProg
				or rOv == 1 and 0
				or rOv == 2
					and ((cState == 0 and cProg > 0 or cState == 1)
						and cProg - (cState == 0 and cOnset or cLimit)
						or 0)
				or cProg);
			-- Ensure we're updating.
			if(not Throttle.List[OnUpdate]) then
				Throttle.List:Add(OnUpdate);
			end
		elseif(seq ~= old and cState > 0) then
			-- Update the sequence, just incase we need it.
			cSeq = seq;
		end
	end;
end

--- Constructs the sequence editor for an action.
-- @param frame The frame to apply widgets to.
-- @param ...   The ID's to pass to Get/SetParameter calls.
function DisplayActivate:CreateSequenceEditor(frame, ...)
	-- Configurable delays/durations.
	local delay = PowerAuras:Create("P_NumberBox", frame);
	delay:SetUserTooltip("Action_DA_Delay");
	delay:SetRelativeWidth(0.25);
	delay:SetPadding(4, 0, 2, 0);
	delay:SetMinMaxValues(0, 2^31 - 1);
	delay:LinkParameter("Sequence", 1, 0, ...);
	delay:SetTitle(L["Action_DA_Delay"]);
	frame:AddWidget(delay);

	local duration = PowerAuras:Create("P_NumberBox", frame);
	duration:SetUserTooltip("Action_DA_Duration");
	duration:SetRelativeWidth(0.25);
	duration:SetPadding(2, 0, 2, 0);
	duration:SetMinMaxValues(0, 2^31 - 1);
	duration:LinkParameter("Sequence", 2, 0, ...);
	duration:SetTitle(L["Action_DA_Duration"]);
	frame:AddWidget(duration);

	-- Rolling onset.
	local rollOnset = PowerAuras:Create("P_Dropdown", frame);
	rollOnset:SetUserTooltip("Action_DA_RollingDelay");
	rollOnset:SetRelativeWidth(0.25);
	rollOnset:SetPadding(2, 0, 2, 0);
	for i = 0, 2 do
		local loc = L["Action_DA_DelayModes"][i];
		rollOnset:AddCheckItem(i, loc.Text);
		rollOnset:SetItemTooltip(i, loc.Tooltip);
	end
	rollOnset:LinkParameter("Sequence", 4, ...);
	rollOnset:SetTitle(L["Action_DA_RollingDelay"]);
	frame:AddWidget(rollOnset);

	-- Rolling duration.
	local rollDur = PowerAuras:Create("P_Dropdown", frame);
	rollDur:SetUserTooltip("Action_DA_RollingDuration");
	rollDur:SetRelativeWidth(0.25);
	rollDur:SetPadding(2, 0, 4, 0);
	for i = 0, 2 do
		local loc = L["Action_DA_DurationModes"][i];
		rollDur:AddCheckItem(i, loc.Text);
		rollDur:SetItemTooltip(i, loc.Tooltip);
	end
	rollDur:LinkParameter("Sequence", 6, ...);
	rollDur:SetTitle(L["Action_DA_RollingDuration"]);
	frame:AddWidget(rollDur);

	-- Override param.
	local override = PowerAuras:Create("P_Checkbox", frame);
	override:SetUserTooltip("Action_DA_Override");
	override:LinkParameter("Sequence", 3, ...);
	override:SetMargins(0, 20, 0, 0);
	override:SetPadding(4, 0, 2, 0);
	override:SetRelativeWidth(1 / 4);
	override:SetText(L["Action_DA_Override"]);
	frame:AddWidget(override);

	-- Immortal?
	local immortal = PowerAuras:Create("P_Checkbox", frame);
	immortal:SetUserTooltip("Action_DA_Immortal");
	immortal:LinkParameter("Sequence", 5, ...);
	immortal:SetMargins(0, 20, 0, 0);
	immortal:SetPadding(2, 0, 2, 0);
	immortal:SetRelativeWidth(1 / 4);
	immortal:SetText(L["Action_DA_Immortal"]);
	frame:AddWidget(immortal);

	-- Override rolling.
	local overRoll = PowerAuras:Create("P_Dropdown", frame);
	overRoll:SetUserTooltip("Action_DA_RollingOverride");
	overRoll:SetRelativeWidth(0.25);
	overRoll:SetPadding(2, 0, 4, 0);
	for i = 0, 2 do
		local loc = L["Action_DA_OverrideModes"][i];
		overRoll:AddCheckItem(i, loc.Text);
		overRoll:SetItemTooltip(i, loc.Tooltip);
	end
	overRoll:LinkParameter("Sequence", 7, ...);
	overRoll:SetTitle(L["Action_DA_RollingOverride"]);
	frame:AddStretcher();
	frame:AddWidget(overRoll);
end

--- Returns the target for this action. A target is what the action needs
--  to be applied to in order to work as intended.
function DisplayActivate:GetTarget()
	return "Display";
end

--- Upgrades an action from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The parameter table to be updated.
function DisplayActivate:Upgrade(version, params)
end