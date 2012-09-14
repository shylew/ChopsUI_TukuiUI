-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Coroutines module. Allows the background processing of tasks.
local Coroutines = PowerAuras:RegisterModule("Coroutines", {
	-- Frame used for processing.
	Frame = CreateFrame("Frame"),
	-- List of queued coroutines.
	List = {},
	-- Current coroutine.
	Current = nil,
	-- Deferred execution list.
	DeferredList = {},
	-- Reusable tables.
	Reusable = setmetatable({}, { __mode = "v" }),
	-- Consecutive OnUpdates for deferred functions.
	ConsecutiveRuns = 0,
	-- Maximum consecutive OnUpdate calls before erroring out.
	MAX_CONSECUTIVE = 5,
});

--- Returns the total number of queued coroutines.
-- @return The number of queued coroutines, including the currently processed
--         one. Also returns a boolean if one is being processed.
function Coroutines:Count()
	return #(self.List) + (self.Current and 1 or 0), not not self.Current;
end

--- Processed the active and queued coroutines.
function Coroutines:Process()
	-- Try to run as many as possible before stalling.
	local elapsed, start = 0, debugprofilestop();
	while(elapsed < 16 and (self.Current or self.List[1])) do
		-- Do we need to fetch from the queue?
		if(not self.Current) then
			self.Current = tremove(self.List, 1);
			if(self.Current) then
				PowerAuras.OnOptionsEvent("COROUTINE_START", self.Current[2]);
			end
		end

		-- Process it.
		if(self.Current) then
			local co = self.Current[1];
			local state, prog = coroutine.resume(co);
			if(not state) then
				-- Error occurred.
				PowerAuras:PrintError("Coroutine error: %s", prog);
				self.Current = nil;
			elseif(coroutine.status(co) == "dead") then
				-- Done processing.
				self.Current = nil;
			end

			-- Did we finish, or just advance?
			if(not self.Current) then
				PowerAuras.OnOptionsEvent("COROUTINE_END");
			else
				PowerAuras.OnOptionsEvent("COROUTINE_UPDATE", prog or -1);
			end
		else
			-- There isn't a coroutine to process.
			PowerAuras.OnOptionsEvent("COROUTINE_QUEUE_END");
			self.Frame.Group:Stop();
		end

		-- Update elapsed time.
		elapsed = (debugprofilestop() - start);
	end

	-- Did we not run anything?
	if(elapsed == 0) then
		-- There isn't a coroutine to process.
		PowerAuras.OnOptionsEvent("COROUTINE_QUEUE_END");
		self.Frame.Group:Stop();
	end
end

--- Queues a coroutine for processing.
-- @param co   The coroutine to queue.
-- @param text The text to display while processing.
function Coroutines:Queue(co, text)
	-- Add to queue.
	tinsert(self.List, { co, text });

	-- Notify the world.
	PowerAuras.OnOptionsEvent("COROUTINE_QUEUED", self:Count());

	-- Ensure the animation is looping.
	if(not self.Frame.Group:IsPlaying()) then
		self.Frame.Group:Play();
		PowerAuras.OnOptionsEvent("COROUTINE_QUEUE_START");
	end
end

--- OnUpdate script handler for deferred function processing.
local function OnUpdate()
	-- Run all deferred functions.
	for i = #(Coroutines.DeferredList), 1, -1 do
		-- Call them in protected mode.
		local data = tremove(Coroutines.DeferredList, i);
		local state, err = pcall(data[1], unpack(data, 2));

		-- Success?
		if(not state) then
			PowerAuras:PrintError("Error: %s", err);
			PowerAuras:PrintDebug("Error: %s", err);
		end

		-- Recycle table.
		tinsert(Coroutines.Reusable, wipe(data));
	end

	-- Disconnect script. Only if we have no deferred functions left.
	if(#(Coroutines.DeferredList) == 0) then
		Coroutines.Frame:SetScript("OnUpdate", nil);
		Coroutines.ConsecutiveRuns = 0;
		PowerAuras.OnOptionsEvent("DEFERRED_EXEC_END", false);
	elseif(Coroutines.ConsecutiveRuns > Coroutines.MAX_CONSECUTIVE) then
		Coroutines.Frame:SetScript("OnUpdate", nil);
		Coroutines.ConsecutiveRuns = 0;
		PowerAuras.OnOptionsEvent("DEFERRED_EXEC_END", true);
		error("Deferred Update Loop: Deferred functions queued repeatedly.");
	else
		Coroutines.ConsecutiveRuns = Coroutines.ConsecutiveRuns + 1;
	end
end

--- Runs a function at the end of the current frame. This does not fire
--  any coroutine events. Multiple copies of the same function are removed, but
--  only if added consecutively.
-- @param func The function to execute.
-- @param ...  Arguments to pass to the function.
function Coroutines:Deferred(func, ...)
	-- Check for collision.
	local prev = self.DeferredList[#(self.DeferredList)];
	if(prev and prev[1] == func) then
		-- Check arguments.
		local same = true;
		if(select("#", ...) ~= #(prev) - 1) then
			-- Different arg count.
			same = false;
		else
			for i = 1, #(prev) - 1 do
				if(prev[i + 1] ~= select(i, ...)) then
					-- Different arg at this index.
					same = false;
					break;
				end
			end
		end

		-- Did we find a matching call?
		if(same) then
			return;
		end
	end

	-- Add deferred call.
	local data = tremove(self.Reusable) or {};
	data[1] = func;
	for i = 1, select("#", ...) do
		data[i + 1] = select(i, ...);
	end
	tinsert(self.DeferredList, data);

	-- Add script if needed.
	if(not self.Frame:GetScript("OnUpdate")) then
		self.Frame:SetScript("OnUpdate", OnUpdate);
	end
end

-- Initialise the frame.
Coroutines.Frame.Group = Coroutines.Frame:CreateAnimationGroup();
Coroutines.Frame.Group.Loop = Coroutines.Frame.Group:CreateAnimation();
Coroutines.Frame.Group.Loop:SetDuration(1 / 18);
Coroutines.Frame.Group:SetLooping("REPEAT");
Coroutines.Frame.Group:SetScript("OnLoop", function()
	Coroutines:Process();
end);
