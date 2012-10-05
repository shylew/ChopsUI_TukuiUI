-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Loads the passed animation data and attaches the loaded animations to
--  a display, alongside support function for processing animations.
-- @param id         The ID number of the display.
-- @param animations The animations data table to process.
-- @param display    The display frame to attach animations to.
function PowerAuras:LoadAnimations(id, animations, display)
	-- Display state upvalues.
	local BeginShow, BeginHide, Show, Hide = DisplayStates["BeginShow"], 
		DisplayStates["BeginHide"], DisplayStates["Show"], 
		DisplayStates["Hide"];
	-- Get the animation subtables for static/triggered anims.
	local static, triggered = animations["Static"], animations["Triggered"];
	-- Immediately quit if the animation tables are empty.
	if(PowerAuras:CountPairs(static, 1) == 0
		and (PowerAuras:CountPairs(triggered, 1) == 0
			or (PowerAuras:CountPairs(triggered["Single"], 1) == 0
				and PowerAuras:CountPairs(triggered["Repeat"], 1) == 0))) then
		return true;
	end
	-- Animation collections.
	local staticAnims, triggeredAnims, triggeredLoopAnims = {}, {}, {};
	-- Channels/queue tables.
	local triggeredQueue, triggeredLoopQueue = {}, {};

	-- Apply callback to static animations.
	local OnStaticFinished = function(self)
		-- Current display state.
		local state = PowerAuras:GetDisplayActivationState(id);
		-- What animation was running?
		if(self == staticAnims["Show"] or self == "Show") then
			-- Change behaviour based on current state.
			if(state == BeginShow or state == "Hide") then
				-- Update state to Show, processed queued animations.
				if(staticAnims["Hide"]) then
					staticAnims["Hide"]:Stop();
				end
				PowerAuras:SetDisplayActivationData(id, "Show", true);
				display:Show();
				-- Process queued triggered anims.
				for channel, queue in pairs(triggeredQueue) do
					if(queue["Current"] == nil) then
						local anim = tremove(queue, 1);
						if(anim) then
							anim:Play();
							queue["Current"] = anim;
						end
					end
				end
				for channel, queue in pairs(triggeredLoopQueue) do
					if(queue["Current"] == nil) then
						local anim = tremove(queue, 1);
						if(anim) then
							anim:Play();
							queue["Current"] = anim;
						end
					end
				end
			elseif(state == BeginHide) then
				-- Play the hide animation.
				staticAnims["Hide"]:Play();
			end
		elseif(self == staticAnims["Hide"] or self == "Hide") then
			-- Change behaviour based on current state.
			if(state == BeginHide or self == "Hide") then
				-- Hide frame and stop all animations.
				PowerAuras:SetDisplayActivationData(id, "Hide", true);
				display:Hide();
				-- As we've hidden, also stop all other animations.
				if(staticAnims["Show"]) then
					staticAnims["Show"]:Stop();
				end
				for i = 1, #(triggeredAnims) do
					for j = 1, #(triggeredAnims[i]) do
						triggeredAnims[i][j]:Stop();
					end
				end
				for i = 1, #(triggeredLoopAnims) do
					for j = 1, #(triggeredLoopAnims[i]) do
						triggeredLoopAnims[i][j]:Stop();
					end
				end
				-- Wipe queues.
				for channel, queue in pairs(triggeredQueue) do
					wipe(queue);
				end
				for channel, queue in pairs(triggeredLoopQueue) do
					wipe(queue);
				end
			elseif(state == BeginShow) then
				-- Play show animation.
				staticAnims["Show"]:Play();
			end
		end
	end;

	-- Attempt to construct our static animations.
	for _, animtype in pairs({ "Show", "Hide" }) do
		local anim = static[animtype];
		if(anim and self:HasAnimationClass(anim["Type"])) then
			-- Get the class.
			local class = self:GetAnimationClass(anim["Type"]);
			if(not class:IsTypeSupported(animtype)) then
				-- Doesn't support this type.
				self:LogResourceMessage(1, "Trigger", id,
					"UnsupportedAnimation", anim["Type"], animtype);
				return false;
			end
			-- Load and set the script on it.
			local inst = class:New(anim["Parameters"], display, animtype);
			inst:SetScript("OnFinished", OnStaticFinished);
			staticAnims[animtype] = inst;
		elseif(anim) then
			-- Error creating this animation.
			self:LogResourceMessage(1, "Animation", id, "MissingClass",
				anim["Type"]);
			return false;
		end
	end

	-- Attempt to construct our triggered animations.
	for _, animtype in pairs({ "Single", "Repeat" }) do
		for channel = 1, #(triggered[animtype]) do
			-- Create tables for the queue.
			local queue, map;
			if(animtype == "Single") then
				triggeredQueue[channel] = {};
				triggeredAnims[channel] = {};
				queue = triggeredQueue[channel];
				map = triggeredAnims[channel];
			else
				triggeredLoopQueue[channel] = {};
				triggeredLoopAnims[channel] = {};
				queue = triggeredLoopQueue[channel];
				map = triggeredLoopAnims[channel];
			end

			-- Generate callback function for OnFinished.
			local callback = function(self)
				if(queue["Current"] ~= self) then return; end
				-- Anything in the queue?
				local nextAnim = tremove(queue, 1);
				queue["Current"] = nextAnim;
				if(nextAnim) then
					-- Play next.
					nextAnim:Play();
				end
			end;

			-- Construct animations.
			for i = 1, #(triggered[animtype][channel]["Animations"]) do
				local anim = triggered[animtype][channel]["Animations"][i];
				if(anim and self:HasAnimationClass(anim["Type"])) then
					-- Get class, check type support.
					local class = self:GetAnimationClass(anim["Type"]);
					if(not class:IsTypeSupported(animtype)) then
						-- Not supported.
						self:LogResourceMessage(1, "Trigger", id,
							"UnsupportedAnimation", anim["Type"], animtype);
						return false;
					end
					-- Construct.
					local g = class:New(anim["Parameters"], display, animtype);
					g:SetScript("OnFinished", callback);
					map[i] = g;
				elseif(anim) then
					-- Class missing.
					self:LogResourceMessage(1, "Animation", id, "MissingClass",
						anim["Type"]);
					return false;
				end
			end

			-- Construct the action for this channel.
			local action = triggered[animtype][channel]["Action"];
			if(not action or not self:HasAuraAction(action)) then
				self:LogResourceMessage(1, "Animation", id, "MissingAction",
					action);
			elseif(self:IsActionLoaded(action)) then
				self:LogResourceMessage(1, "Animation", id, "DependencyLoaded",
					"Action", action);
				return false;
			else
				-- Attempt to load the action.
				local state, res = self:LoadAction(action, display, channel);
				if(not state) then
					self:LogResourceMessage(1, "Animation", id,
						"DependencyFailed", "Action", action);
					return false;
				end
			end
		end
	end

	--- Called when an Animate/AnimateRepeat action has been activated.
	display.QueueAnimation = function(display, animID, loop, channel)
		-- Get the animation and queue table based on the loop parameter.
		local anim, channelQueue;
		if(loop) then
			anim = triggeredLoopAnims[channel][animID];
			channelQueue = triggeredLoopQueue[channel];
		else
			anim = triggeredAnims[channel][animID];
			channelQueue = triggeredQueue[channel];
			-- Animation required at this point.
			if(not anim) then return; end
		end
		-- Are we cancelling all loop animations on this channel?
		if(not anim and loop) then
			-- Wipe the queue, cancel playing.
			local current = channelQueue["Current"];
			if(current) then
				current:Finish();
			end
			wipe(channelQueue);
			channelQueue["Current"] = current;
		elseif(anim and anim:IsPlaying()) then
			-- Is the animation pending a finish?
			if(anim and anim:IsPendingFinish() and #(channelQueue) == 0) then
				-- Queue is empty, so add this in and continue.
				tinsert(channelQueue, anim);
			end
		elseif(channelQueue["Current"]) then
			-- Queue and finish current.
			tinsert(channelQueue, anim);
			channelQueue["Current"]:Finish();
		elseif(anim) then
			-- If we're here, no animation is playing in that channel.
			local state = self:GetDisplayActivationState(id);
			if(state == Show) then
				anim:Play();
				channelQueue["Current"] = anim;
			elseif(state == BeginShow or state == BeginHide) then
				-- Display isn't in the Show state, so we need to queue.
				tinsert(channelQueue, anim);
			end
		end
	end;

	--- Called when the frame receives a show request from the OnActivate
	--  action.
	display.OnBeginShow = function(display)
		-- Update state.
		self:SetDisplayActivationData(id, "BeginShow", true);
		display:Show();
		-- Is there a begin show animation?
		if(not staticAnims["Show"]) then
			-- There isn't, so force a show.
			OnStaticFinished("Show");
		elseif(not staticAnims["Show"]:IsPlaying()
			and (not staticAnims["Hide"]
				or not staticAnims["Hide"]:IsPlaying())) then
			-- There is, but no current animation is playing.
			staticAnims["Show"]:Play();
		end
	end;

	--- Called when the frame receives a hide request from the OnActivate
	--  action.
	display.OnBeginHide = function(display)
		-- Update state.
		self:SetDisplayActivationData(id, "BeginHide", true);
		-- Is there a begin hide animation?
		if(not staticAnims["Hide"] or PowerAuras:GetEditMode()) then
			-- There isn't, so force a hide.
			OnStaticFinished("Hide");
		elseif(not staticAnims["Hide"]:IsPlaying()
			and (not staticAnims["Show"]
				or not staticAnims["Show"]:IsPlaying())) then
			-- There is, but no current animation is playing.
			staticAnims["Hide"]:Play();
		end
	end;

	-- Loaded successfully.
	self:LogResourceMessage(3, "Animation", id, "Loaded");
	return true;
end