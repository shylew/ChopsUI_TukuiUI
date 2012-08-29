-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--------------------------------------------------------------------------------
-- Table/String/Output Utility
--------------------------------------------------------------------------------

do
	--- Internal iterator function for ByKey.
	-- @param t The table to iterate.
	-- @param l The last returned key.
	local function iterator(t, l)
		-- Run over the table and find the smallest value, but one that
		-- is still larger than our last key.
		local min = nil;
		for k, v in pairs(t) do
			if((min == nil or k < min) and (l == nil or k > l)) then
				min = k;
			end
		end
		-- If we have a result, return it.
		if(min ~= nil) then
			return min, t[min];
		else
			return nil, nil;
		end
	end

	--- Iterates over a table in ascending order of its key.
	-- @param t The table to iterate over.
	function PowerAuras:ByKey(t)
		return iterator, t, nil;
	end
end

--- Deeply copies simple values from a table.
-- @param old    The table to copy.
-- @param lookup Internal lookup table.
function PowerAuras:CopyTable(old, lookup)
	-- Create a new table and a lookup table.
	local new = {};
	local lookup = (lookup or { [old] = new });
	-- Iterate over existing table.
	for k, v in pairs(old) do
		if(type(v) == "table") then
			new[k] = (lookup[v] or self:CopyTable(v, lookup));
		else
			new[k] = v;
		end
	end
	-- Return new table.
	return new;
end

--- Counts the number of key => value pairs in a table.
-- @param t The table to count.
-- @param l Optional counting limit.
function PowerAuras:CountPairs(t, l)
	local c = 0;
	for k, _ in pairs(t) do
		c = c + 1;
		if(l and c >= l) then
			return c;
		end
	end
	return c;
end

do
	--- Properly formats a value for an exporting operation.
	-- @param v      The value to format.
	-- @param pretty True if the value should be pretty.
	local function FormatValue(v, pretty)
		if(type(v) == "string") then
			if(not pretty) then
				return ("%q"):format(v);
			else
				return ("|cFFE6DB74%q|r"):format(v);
			end
		elseif(type(v) == "number") then
			-- Handle special numerics.
			if(v == math.huge) then
				if(not pretty) then
					return "math.huge";
				else
					return ("|cFFAE81FFmath.huge|r"):format(v);
				end
			elseif(v == -math.huge) then
				if(not pretty) then
					return "-math.huge";
				else
					return ("|cFFAE81FF-math.huge|r"):format(v);
				end
			else
				if(not pretty) then
					return ("%g"):format(v);
				else
					return ("|cFFAE81FF%g|r"):format(v);
				end
			end
		elseif(type(v) == "nil") then
			if(not pretty) then
				return "nil";
			else
				return "|cFFAE81FFnil|r";
			end
		elseif(type(v) == "boolean") then
			if(not pretty) then
				return v and "true" or "false";
			else
				return ("|cFFAE81FF%s|r"):format(v and "true" or "false");
			end
		elseif(tostring(v) and pretty) then
			return ("|cFFFD971F%s|r"):format(tostring(v));
		else
			return "nil";
		end
	end

	--- Deeply exports the simple values of a table into string form.
	-- @param src    The table to export.
	-- @param pretty Set to true if you want the output to be pretty. This
	--               is a lot slower, but the output is actually readable.
	-- @param lookup Internal lookup table.
	-- @param level  Internal depth variable.
	function PowerAuras:ExportTable(src, pretty, lookup, level)
		-- Make sure it's a table.
		if(type(src) ~= "table") then
			return FormatValue(src, pretty);
		end
		-- Create a lookup table and a string building table.
		local str = {};
		local lookup = (lookup or { [src] = true });
		-- Get indentation.
		level = (level or pretty == true and 1 or 0);
		local ind = (pretty and string.rep("    ", level) or "");
		-- Iterate over existing table.
		for k, v in pairs(src) do
			-- Attempt to format the key.
			local fK = FormatValue(k, pretty);
			if(fK) then
				-- Now format the value.
				local fV;
				if(type(v) == "table" and not lookup[v]) then
					local nextLevel = (pretty ~= true and 0 or level + 1);
					fV = self:ExportTable(v, pretty, lookup, nextLevel);
				elseif(type(v) ~= "table") then
					fV = FormatValue(v, pretty);
				end
				-- Append key/value pair to string.
				if(not pretty) then
					tinsert(str, ("[%s]=%s"):format(fK, fV));
				else
					tinsert(str, ("%s[%s] = %s"):format(ind, fK, fV));
				end
			end
		end
		-- Return exported table.
		if(not pretty) then
			return ("{%s}"):format(table.concat(str, ","));
		elseif(pretty == true) then
			ind = string.rep("    ", level - 1);
			local contents = table.concat(str, ",\n");
			if(contents == "") then
				return "{}";
			else
				return ("{\n%s\n%s}"):format(contents, ind);
			end
		else
			-- Colors only.
			local contents = table.concat(str, ", ");
			if(contents == "") then
				return "{}";
			else
				return ("{ %s }"):format(contents);
			end
		end
	end
end

do
	local t = {};
	local t2 = {};

	function PowerAuras:FormatString(str, values, ...)
		-- Check if varargs were supplied.
		if(select("#", ...) > 0 or type(values) ~= "table") then
			-- Place the arguments inside our upvalued temporary table and
			-- recall the function with it.
			t[1] = values;
			for i = 1, select("#", ...) do
				t[i + 1] = select(i, ...);
			end
			local s = self:FormatString(str, t);
			wipe(t);
			return s;
		end
		-- Format the string.
		return str:gsub("(%${([a-zA-Z0-9_.]+):?([0-9A-Za-z]*)})",
			function(match, key, spec)
				-- Handle vararg formatting.
				if(key == "...") then
					-- Escape string values.
					for i = 1, #(values) do
						t2[i] = type(values[i]) == "string"
							and ("%q"):format(values[i])
							or values[i];
					end
					-- Join string, wipe temp table.
					local str = (", "):join(unpack(t2));
					wipe(t2);
					-- Return string.
					return str;
				end
				-- Normal formatting.
				spec = spec and spec ~= "" and spec or "s";
				return values[key] ~= nil
						and ("%%%s"):format(spec):format(tostring(values[key]))
				 	or tonumber(key) ~= nil
				 		and values[tonumber(key)] ~= nil
						and ("%%%s"):format(spec):format(
							tostring(values[tonumber(key)])
						)
				 	or match;
			end
		);
	end
end

do
	--- List of reusable tables.
	local tables = setmetatable({}, { __mode = "v" });

	--- Iterator function for IterList.
	-- @param t The table to iterate over.
	-- @param i The current argument index.
	local function iterator(t, i)
		i = (i or 0) + 1;
		return (t[i] ~= nil and i or tinsert(tables, wipe(t))), t[i];
	end

	--- Iterates over a list of values.
	-- @param ... The values to iterate over.
	function PowerAuras:IterList(...)
		local t = (tremove(tables) or {});
		for i = 1, select("#", ...) do
			t[i] = select(i, ...);
		end
		return iterator, t, 0;
	end
end

--- Takes a table and creates a second table with the keys of the first one
--  as a list.
-- @param t The subject table.
-- @param c The table to append keys to. If not specified, it will be created.
function PowerAuras:ListKeys(t, c)
	-- Create copy table if needed.
	c = c or {};
	-- Copy keys over. Use a manually incremented variable for speed.
	local i = 1;
	for k, _ in pairs(t) do
		c[i] = k;
		i = i + 1;
	end
	return c;
end

do
	-- Temporary GC'able cache.
	local tempCache = setmetatable({}, { __mode = "v" });

	--- Loads a function via loadstring() and caches it, allowing it to be
	--  reused in the future.
	-- @param str The string to load.
	function PowerAuras:Loadstring(str)
		-- Is function cached?
		local hit = tempCache[str];
		if(not hit) then
			-- Generate and store.
			local result, code = loadstring(str, "=");
			if(not result) then
				error(code);
			else
				hit = result;
				tempCache[str] = hit;
			end
		end
		-- Done.
		return hit;
	end
end

--- Prints an error message to the chat frame.
-- @param message The base message to print. This can be a localization key.
-- @param ...     Arguments to format into the message.
function PowerAuras:PrintError(message, ...)
	print("|cFFDE4343Power Auras Classic:|r",
		tostring(message):format(tostringall(...)));
end

--- Prints a pretty informational message to the chat frame.
-- @param message The base message to print. This can be a localization key.
-- @param ...     Arguments to format into the message.
function PowerAuras:PrintInfo(message, ...)
	print("|cFF4EA5CDPower Auras Classic:|r",
		tostring(message):format(tostringall(...)));
end

--- Prints a successful operation message to the chat frame.
-- @param message The base message to print. This can be a localization key.
-- @param ...     Arguments to format into the message.
function PowerAuras:PrintSuccess(message, ...)
	print("|cFF61B832Power Auras Classic:|r",
		tostring(message):format(tostringall(...)));
end

--- Prints a warning message to the chat frame.
-- @param message The base message to print. This can be a localization key.
-- @param ...     Arguments to format into the message.
function PowerAuras:PrintWarning(message, ...)
	print("|cFFEAAF51Power Auras Classic:|r",
		tostring(message):format(tostringall(...)));
end

--------------------------------------------------------------------------------
-- Spell Lookup Utility
--------------------------------------------------------------------------------

-- Deferred spell finding utility.
local Finder = PowerAuras.Throttle(function(self, elapsed)
	-- Queue upvalues.
	local queue = self.Queue;
	local queueCount = #(queue);

	-- Iterate over spells, the cap depends upon our combat state.
	local cap = (InCombatLockdown() and 50 or 250);
	cap = math.ceil(cap / (queueCount / 16));
	local hardCap = 150000;
	local limit = math.min(self.Progress + cap, hardCap);

	-- Iterate.
	for i = self.Progress, limit do
		-- Get the spell data.
		local name = GetSpellInfo(i);

		-- Check if the spell exists.
		if(name) then
			-- Process matches.
			for j = 1, queueCount, 4 do
				-- Extract data.
				local mName, flags, checks, var = queue[j],
					queue[j + 1], queue[j + 2], queue[j + 3];

				-- Spell match?
				local discard = (checks == hardCap or not mName);
				if(name == mName and not discard) then
					-- Right, so was this a callback or an any check?
					if((bit.band(flags, PowerAuras.SPELL_MATCH_ANY)
						or type(var) == "function") and not discard) then
						-- If it's a callback, it decides how we proceed.
						discard = (type(var) ~= "function" or var(name, i));
					end

					-- Process automated flagging.
					local a = bit.band(flags, PowerAuras.SPELL_MATCH_MASK);
					if(a == PowerAuras.SPELL_MATCH_ACTION) then
						PowerAuras:MarkActionID(var);
					elseif(a == PowerAuras.SPELL_MATCH_PROVIDER) then
						PowerAuras:MarkProvider(var);
					elseif(a == PowerAuras.SPELL_MATCH_TRIGGER_TYPE) then
						PowerAuras:MarkTriggerType(var);
					end
				end

				-- Discarding?
				checks = checks + 1;
				if(discard and mName) then
					queue[j] = false;
				elseif(not discard) then
					queue[j + 2] = checks;
				end
			end
		else
			-- Increment queue counters.
			for j = 1, queueCount, 4 do
				local mName, checks = queue[j], queue[j + 2] + 1;
				local discard = (checks == hardCap or not mName);
				-- Flag for removal?
				if(discard and mName) then
					queue[j] = false;
				elseif(not discard) then
					queue[j + 2] = checks;
				end
			end
		end
	end

	-- Did we hit the end?
	if(limit >= hardCap) then
		-- Clean our data up.
		for i = queueCount, 1, -4 do
			if(not queue[i - 3]) then
				tremove(queue, i);
				tremove(queue, i - 1);
				tremove(queue, i - 2);
				tremove(queue, i - 3);
			end
		end
		-- Reset progress.
		self.Progress = 1;
	else
		self.Progress = limit + 1;
	end

	-- Time to stop?
	if(#(queue) == 0) then
		self.Update:Stop();
	end
end);

-- Queue table for the spell finder.
Finder.Queue = {};

-- Current spell ID.
Finder.Progress = 1;

--- Forcibly finds a spell ID from a name by iterating over every spell.
-- @param name  The name of the spell.
-- @param flags The flags for the finding process.
-- @param var   Additional argument for the passed flags.
function PowerAuras:FindSpellByName(name, flags, var)
	-- Insert into the queue.
	local i = #(Finder.Queue) + 1;
	Finder.Queue[i] = name;
	Finder.Queue[i + 1] = flags;
	Finder.Queue[i + 2] = 0;
	Finder.Queue[i + 3] = var;

	-- Start the finder if needed.
	if(not Finder.Update:IsPlaying()) then
		Finder.Update:Play();
	end
end

--------------------------------------------------------------------------------
-- Unit Utility
--------------------------------------------------------------------------------

--- Executes a function for each of the passed units, factoring in custom
--  unit ID's and group specifiers. Units must exist for this to pass.
-- @param unit The units to check. If a string, then just the passed unit
--             is checked. If a table, then all specified units are checked.
-- @param func The function to execute. It will be called with the unit ID as
--             the first argument. The function must return true/false on
--             success or failure. The function may optionally return up to
--             three values which will also be returned on a successful match.
-- @param ...  Additional arguments to pass to the function.
-- @return True if the conditions are met, false if not. Also fails if units
--         do not exist. Also returns the unit ID that was checked, alongside
--         the three optional return values from the callback on success.
function PowerAuras:CheckUnits(unit, func, ...)
	-- Iterate over units if you passed a table.
	if(type(unit) == "table") then
		-- Support all/any checks via a table pair.
		local isAny = not not unit.IsAny;
		-- Store the return values in this scope so we can return the
		-- last check data on failure.
		local state, id, r1, r2, r3;
		for i = 1, #(unit) do
			-- Check the unit.
			state, id, r1, r2, r3 = self:CheckUnits(unit[i], func, ...);
			-- Check state.
			if(state and isAny) then
				-- Unit passed, and we only needed the one.
				return true, id, r1, r2, r3;
			elseif(not state and not isAny) then
				-- Unit failed, needed all.
				return false, id;
			end
		end
		-- Did we pass?
		if(isAny) then
			-- We'd have passed by now if the any check has passed.
			return false, id;
		else
			-- We'd have failed by now if the all check had failed.
			return true, id, r1, r2, r3;
		end
	end
	-- Otherwise, check this unit.
	local id, name, index, spec = unit:match("^((%a-)(%d*))%-?([alny]*)$");
	index = tonumber(index);
	-- Right, is this a group unit?
	if(specifier ~= "" and not index and self.GroupUnitIDs[name]) then
		-- That it is, is this a 'group' type unit?
		if(name == "group") then
			name = (IsInRaid() and "raid" or "party");
		end
		-- Determine the total number of units to scan, and how we're
		-- handling failures.
		local count = #(self.GroupUnitIDs[name]);
		local isAny = (spec == "any");
		-- Store returns out of scope.
		local state, realID, r1, r2, r3;
		-- Check units. If doing party, start from 0 as this will
		-- cover our player unit.
		for i = (name == "party" and 0 or 1), count do
			-- Get the proper unit ID.
			realID = self:GetUnitID(name, i);
			-- Ensure the unit exists.
			if(UnitExists(realID)) then
				-- Process check.
				checked = true;
				state, r1, r2, r3 = func(realID, ...);
				-- Was this a hit?
				if(state and isAny) then
					-- Successful isAny check.
					return true, realID, r1, r2, r3;
				elseif(not state and not isAny) then
					-- Failed isAll check.
					return false, realID;
				end
			elseif(not isAny) then
				-- Unit doesn't exist, so that's a failure.
				return false, realID;
			end
		end
		-- Check final state.
		if(isAny) then
			-- We'd have passed by now if the any check has passed.
			return false, realID;
		else
			-- We'd have failed by now if the all check had failed.
			return true, realID, r1, r2, r3;
		end
	else
		-- Replace party0 with player.
		if(id == "party0") then
			id = "player";
		elseif(id:sub(1, 5) == "group") then
			if(IsInRaid()) then
				id = self:GetUnitID("raid", tonumber(id:sub(6)));
			else
				-- group1 is analogous to party0 (player), and group5 is
				-- the same as party4, so decrement the number.
				id = self:GetUnitID("party", tonumber(id:sub(6)) - 1);
			end
		end
		-- Check if unit exists, then call the function if so.
		if(UnitExists(id)) then
			local state, r1, r2, r3 = func(id, ...);
			return state, id, r1, r2, r3;
		else
			-- Failed.
			return false, id;
		end
	end
end

--- Decodes a unit data string.
-- @param data  The data to decode.
-- @param table If set to true, the return value will always be a table.
-- @return The decoded data as either a table or a string.
function PowerAuras:DecodeUnits(data, table)
	-- Test if the data is that of a unit.
	if(not self:IsValidUnitID(data)) then
		-- It isn't, try to safely load it.
		local units = loadstring(("return %s"):format(self:DecodeString(data)));
		if(type(units) == "function") then
			local state, result = pcall(units);
			if(state and result) then
				-- Done.
				return result;
			end
		end
	end
	-- Otherwise, assume it IS valid (this allows for custom units to
	-- work just fine in string form).
	if(table) then
		return { data };
	else
		return data;
	end
end

--- Encodes unit data.
-- @param data The data to encode. Either as a string or table.
-- @return The encoded data as a string.
function PowerAuras:EncodeUnits(data)
	-- If it's a string, just return.
	if(type(data) == "string") then
		return data;
	elseif(type(data) == "table") then
		if(#(data) == 1) then
			-- Single unit, extract and return.
			return data[1];
		else
			-- Otherwise, encode it.
			return self:EncodeString(self:ExportTable(data));
		end
	else
		return "";
	end
end

--- Returns a usable unitID for API functions.
-- @param unit The unit to get an ID for.
-- @param id   Unit offset ID. Only valid for group type units.
function PowerAuras:GetUnitID(unit, id)
	-- If unit isn't a group unit, then we're fine.
	if(self.GroupUnitIDs[unit]) then
		-- If group, default to largest possible thing.
		if(unit == "group") then
			unit = (IsInRaid() and "raid" or "party");
		end
		-- If party and id == 0, then it's a player.
		if(unit == "party" and id == 0) then
			return "player";
		else
			return ("%s%d"):format(unit, id);
		end
	else
		-- Simply return the unit.
		return unit;
	end
end

--- Checks if the passed value is a valid unit ID.
-- @param id The unit ID to check.
function PowerAuras:IsValidUnitID(id)
	-- Type check.
	if(type(id) ~= "string") then
		return false;
	end
	-- Check for single unit match.
	if(tContains(self.SingleUnitIDs, id)) then
		return true;
	end
	-- Is it a group unit specifier?
	local name, index, spec = id:match("^(%a-)(%d*)%-?([alny]*)$");
	if(self.GroupUnitIDs[name]
		and ((spec == "any" or spec == "all" and index == "")
			or (self.GroupUnitIDs[name][tonumber(index)] and spec == ""))) then
		return true;
	end
	-- Probably not a unit. Note that we don't support things like mouseover,
	-- because the API fires nothing for them. In addition, this is false
	-- for unit names.
	return false;
end

--------------------------------------------------------------------------------
-- Match Utility
--------------------------------------------------------------------------------

--- Processes an operator and returns a boolean value.
-- @param value    The value to work on.
-- @param operator The specified operator.
-- @param match    The value to match.
function PowerAuras:CheckOperator(value, operator, match)
	return (operator == "<" and (value < match)
		or operator == ">" and (value > match)
		or operator == "~=" and (value ~= match)
		or operator == "==" and (value == match)
		or operator == "<=" and (value <= match)
		or operator == ">=" and (value >= match));
end

--- Decodes a match string and loads it.
-- @param data The string to decode.
-- @param trim If set to true, the defaults table is removed.
-- @return The decoded and filled in table.
function PowerAuras:DecodeMatch(data, trim)
	-- Decode and load the table.
	data = assert(loadstring(("return %s"):format(self:DecodeString(data))))();
	-- Fill in defaults.
	local defaults = assert(data[0], "Missing default data table!");
	for i = 1, #(data) do
		for k, v in pairs(defaults) do
			if(data[i][k] == nil) then
				data[i][k] = v;
			end
		end
	end
	-- Remove defaults (as they're just wasting memory).
	data[0] = (not trim and data[0] or nil);
	-- Done.
	return data;
end

--- Encodes a match string from the passed data.
-- @param data The table to encode.
-- @param The encoded and stripped table.
function PowerAuras:EncodeMatch(data)
	-- Remove defaults from the data.
	local defaults = assert(data[0], "Missing default data table!");
	for i = 1, #(data) do
		local k, v = next(data[i]);
		while(k) do
			if(v == defaults[k]) then
				data[i][k] = nil;
			end
			k, v = next(data[i], k);
		end
	end
	-- Now compress into a string.
	return self:EncodeString(self:ExportTable(data));
end

do
	--- Scanning tooltip.
	local tooltip = PowerAuras.ScanTooltip;

	--- Iterator function for GetTooltipLines.
	-- @param max  The maximum number of lines.
	-- @param line The line index.
	local function iterator(max, line)
		-- Increment lines.
		line = line + 1;
		if(line <= max) then
			-- Is the line stored?
			if(not tooltip[line]) then
				tooltip[line] = {
					[1] = _G[tooltip:GetName() .. "TextLeft" .. line],
					[2] = _G[tooltip:GetName() .. "TextRight" .. line],
				};
			end
			-- Return the line strings.
			local regions = tooltip[line];
			-- Return regions.
			return line, regions[1]:GetText() or "", regions[2]:GetText() or "";
		end
	end

	--- Returns an iterator for accessing the lines of our scanning tooltip.
	function PowerAuras:GetTooltipLines()
		return iterator, self.ScanTooltip:NumLines(), 0;
	end
end

--------------------------------------------------------------------------------
-- Encode/Decode Utility.
--------------------------------------------------------------------------------

local ind = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";
local inv = setmetatable({}, {
	__index = function(t, k)
		-- Find the requested character.
		for i = 1, #(ind) do
			if(ind:sub(i, i) == k) then
				t[k] = i - 1;
				return i - 1;
			end
		end
		-- Failed.
		t[k] = 0;
		return 0;
	end;
});

do
	-- Reusable output table.
	local out = {};

	--- Implementation of base64 for encoding string data.
	-- @param data The data to be encoded.
	-- @return The data encoded as a string.
	function PowerAuras:EncodeString(data)
		-- Reset output table.
		wipe(out);
		-- Apply padding if string length isn't a multiple of 3.
		local padding = "";
		if((#(data) % 3) > 0) then
			padding = ("="):rep(3 - (#(data) % 3));
		end
		-- Iterate over the string.
		for i = 1, #(data), 3 do
			-- Combine the three characters into a single 24 bit number.
			local v = 0;
			for j = 2, 0, -1 do
				local k = ((i - 1) + 3 - j);
				v = bit.bor(v, bit.lshift(data:sub(k, k):byte() or 0, j * 8));
			end
			-- Split the number into 6-bit numbers and add them to the output.
			for j = 3, 0, -1 do
				local index = bit.band(bit.rshift(v, j * 6), 0x3F);
				tinsert(out, ind:sub(index + 1, index + 1));
			end
		end
		-- Done.
		local outStr = table.concat(out, "");
		return outStr:sub(1, #(outStr) - #(padding)) .. padding;
	end

	--- Decodes a base64 string.
	-- @param data The data to be decoded.
	-- @return The data decoded as a string.
	function PowerAuras:DecodeString(data)
		-- Reset output table.
		wipe(out);
		-- Apply zero padding to padded characters.
		local padding = "";
		local m = data:match("=?=$");
		if(m) then
			data = data:gsub("==$", "AA"):gsub("=$", "A");
		end
		-- Iterate over data, four chracters at a time.
		for i = 1, #(data), 4 do
			-- Extract the 6 bit numbers.
			local v = 0;
			for j = 0, 3 do
				local k = ((i - 1) + j + 1);
				local l = 18 - (j * 6);
				v = bit.bor(v, bit.lshift(inv[data:sub(k, k)], l));
			end
			-- Split the 24 bit number into a three characters.
			for j = 2, 0, -1 do
				tinsert(out, string.char(bit.band(bit.rshift(v, j * 8), 255)));
			end
		end
		-- Remove null characters from the padding.
		return table.concat(out, ""):sub(1, #(out) - (m and #(m) or 0));
	end
end