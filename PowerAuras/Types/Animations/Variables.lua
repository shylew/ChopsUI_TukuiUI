-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

-- Modules.
local Coroutines = PowerAuras:GetModules("Coroutines");

--- Creates a static animation on a display.
-- @param id       The ID of the display.
-- @param animType The static animation type.
-- @param class    The animation class.
function PowerAuras:CreateStaticAnimation(id, animType, class)
	-- Get the display and the class.
	local display = self:GetAuraDisplay(id);
	local animClass = self:GetAnimationClass(class);
	-- Does this class support the type?
	if(not animClass:IsTypeSupported(animType)) then
		return false;
	end
	-- If the animation here exists, replace it.
	if(display["Animations"]["Static"][animType]) then
		self:DeleteStaticAnimation(id);
	end
	-- Create, fire and return.
	display["Animations"]["Static"][animType] = {
		Type = class,
		Parameters = self:CopyTable(animClass:GetDefaultParameters()),
	};
	self.OnOptionsEvent("STATIC_ANIMATION_CREATED", id, animType, class);
	return true;
end

--- Deletes a static animation from a display.
-- @param id       The ID of the display.
-- @param animType The static animation type.
function PowerAuras:DeleteStaticAnimation(id, animType)
	-- Remove the animation from the aura.
	local display = self:GetAuraDisplay(id);
	if(display["Animations"]["Static"][animType]) then
		-- Delete and fire callbacks.
		display["Animations"]["Static"][animType] = nil;
		self.OnOptionsEvent("STATIC_ANIMATION_DELETED", id, animType);
	end
end

--- Creates an animation channel for a display.
-- @param id    The ID of the display.
-- @param group The type of channel to create.
function PowerAuras:CreateAnimationChannel(id, group)
	-- Grab the display, find a suitable index.
	local display = self:GetAuraDisplay(id);
	local index = #(display["Animations"]["Triggered"][group]) + 1;
	-- Construct an Animate action for this channel.
	local auraID = self:SplitAuraDisplayID(id);
	local actionID = self:CreateAuraAction(
		auraID,
		group == "Single" and "Animate" or "AnimateRepeat"
	);
	-- Construct channel.
	display["Animations"]["Triggered"][group][index] = {
		Animations = {},
		Action = actionID,
	};
	self.OnOptionsEvent("TRIGGERED_ANIMATION_CHANNEL_CREATED",
		id, group, index);
	return true, index, actionID;
end

--- Deletes an animation channel from a display.
-- @param id    The ID of the display.
-- @param group The type of channel to remove.
-- @param index The index of the channel to remove.
function PowerAuras:DeleteAnimationChannel(id, group, index)
	-- Remove the channel.
	local display = self:GetAuraDisplay(id);
	local anims = display["Animations"]["Triggered"][group];
	if(anims[index]) then
		-- Delete and fire callbacks.
		local chan = tremove(anims, index);
		self.OnOptionsEvent("TRIGGERED_ANIMATION_CHANNEL_DELETED",
			id, group, index);
		-- Remove unused resources.
		Coroutines:Queue(self:DeleteUnusedResources());
	end
end

--- Creates a triggered animation.
-- @param id      The ID of the display.
-- @param group   The group of the animation (Single/Repeat).
-- @param channel The channel ID.
-- @param class   The class of the animation.
-- @param index   Optional index to place the animation at. If an animation
--                already exists here, it will be replaced.
function PowerAuras:CreateTriggeredAnimation(id, group, channel, class, index)
	-- Get to the channel!
	local display = self:GetAuraDisplay(id);
	local anims = display.Animations.Triggered[group][channel].Animations;
	-- Fix the index ID to be between 1 and #(anims) + 1.
	index = math.min(index or math.huge, #(anims) + 1);
	-- Does the animation in this slot exist?
	if(anims[index]) then
		anims[index] = nil;
	end
	-- Construct an animation.
	local animClass = self:GetAnimationClass(class);
	anims[index] = {
		Type = class,
		Parameters = self:CopyTable(animClass:GetDefaultParameters()),
	};
	self.OnOptionsEvent("TRIGGERED_ANIMATION_CREATED",
		id, group, channel, class, index);
	return true, index;
end

--- Deletes a triggered animation.
-- @param id    The ID of the display.
-- @param group The group of the animation (Single/Repeat).
-- @param cID   The channel ID.
-- @param index The index of the animation to remove.
function PowerAuras:DeleteTriggeredAnimation(id, group, cID, index)
	-- Get to the channel!
	local display = self:GetAuraDisplay(id);
	local anims = display.Animations.Triggered[group][cID].Animations;
	-- Does the animation in this slot exist?
	if(anims[index]) then
		tremove(anims, index);
		-- Reindex animation ID's.
		PowerAuras:ReindexResourceID("Animation", index, nil, id, group, cID);
		-- Fire GUI events.
		self.OnOptionsEvent("TRIGGERED_ANIMATION_DELETED",
			id, group, cID, index);
		return true;
	else
		return false;
	end
end