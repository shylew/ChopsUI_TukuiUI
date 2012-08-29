-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Creates a sequence on the specified action.
-- @param id The ID of the action.
function PowerAuras:CreateAuraActionSequence(id)
	-- Get the action.
	local action = self:GetAuraAction(id);
	-- Get the class of the action.
	local class = self:GetActionClass(action["Type"]);
	-- Cap the index.
	local index = math.min(
		self:GetAuraActionSequenceCount(id) + 1,
		self.MAX_SEQUENCES_PER_ACTION
	);
	-- Create sequence.
	action["Sequences"][index] = {
		Operators = "",
		Parameters = self:CopyTable(class:GetDefaultParameters()),
	};
	-- Return the sequence ID.
	self.OnOptionsEvent("SEQUENCE_CREATED", id, index);
	return index;
end

--- Removes a sequence from an action.
-- @param id    The ID of the action.
-- @param index The sequence index number.
function PowerAuras:DeleteAuraActionSequence(id, index)
	-- Get the action.
	local action = self:GetAuraAction(id);
	tremove(action["Sequences"], index);
	-- Fire callbacks.
	self.OnOptionsEvent("SEQUENCE_DELETED", id, index);
	return true;
end

--- Removes any references to a trigger from all sequences within an action.
-- @param id    The ID of the action.
-- @param index The index of the trigger.
function PowerAuras:RemoveTriggerFromSequences(id, index)
	-- Run over all the sequences.
	for _, seq in self:GetAllAuraActionSequences(id) do
		-- Iterate over all the ID's within the operators.
		local ops = seq["Operators"];
		ops = ops:gsub("([()&|! ]*)(%d+)([()&|! ]*)", function(s, tid, e)
			-- Convert index to number.
			tid = tonumber(tid);
			-- -- Is the trigger index we found >= the one we're removing?
			if(tid == index) then
				-- Same number, this means we need to also remove some
				-- operators.
				local str1, str2;
				str1 = s:gsub("[&|!]*$", "");
				str2 = e:gsub("^[&|!]*", "");
				-- Replaced, yay!
				return ("%s%s"):format(str1, str2);
			elseif(tid >= index) then
				-- Number is larger, so we're just decrementing it.
				return ("%s%d%s"):format(s, tid - 1, e);
			else
				-- Something odd happened.
				return ("%s%d%s"):format(s, tid, e);
			end
		end);
		-- Fix issues such as invalid operators.
		ops = ops:gsub("[&|! ]+%)", ")")
			:gsub("%([&| ]+", "(") -- An ! after ( is valid, so don't replace.
			:gsub("^[&| ]", "")
			:gsub("[&|! ]$", "")
		seq["Operators"] = ops;
		-- Callbacks.
		self.OnOptionsEvent("SEQUENCE_UPDATED", id, index);
	end
end

do
	--- Internal iterator function.
	local function iterator(inv, seq)
		seq = seq + 1;
		if(not PowerAuras:HasAuraActionSequence(inv, seq)) then
			return nil, nil;
		else
			return seq, PowerAuras:GetAuraActionSequence(inv, seq);
		end
	end

	--- Returns an iterator for accessing all the sequences inside an action.
	-- @param id The ID of the action.
	function PowerAuras:GetAllAuraActionSequences(id)
		-- Return the iterator function.
		return iterator, id, 0;
	end
end

--- Retrieves an action trigger sequence with the specified index.
-- @param id    The ID of the action.
-- @param index The sequence index to retrieve.
function PowerAuras:GetAuraActionSequence(id, index)
	-- Validate it exists.
	assert(self:HasAuraActionSequence(id, index),
		L("ErrorSequenceIDInvalid", id, index));
	return self:GetAuraAction(id)["Sequences"][index];
end

--- Returns the total number of trigger sequences within a single action.
-- @param id The ID of the action.
function PowerAuras:GetAuraActionSequenceCount(id)
	return (self:HasAuraAction(id)
		and #(self:GetAuraAction(id)["Sequences"])
		or 0);
end

--- Validates that the specified sequence index for an action exists.
-- @param id    The ID of the action.
-- @param index The sequence index to validate.
function PowerAuras:HasAuraActionSequence(id, index)
	-- Validate types.
	if(not self:HasAuraAction(id) or type(index) ~= "number") then
		return false;
	else
		return not not self:GetAuraAction(id)["Sequences"][index];
	end
end