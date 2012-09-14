-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Upvalues.
local tonumber = _G.tonumber;
local UnitAura = _G.UnitAura;

--- Shared checks module. Place functions in here that are shared between
--  multiple class resources (eg. buff checking in triggers and sources).
local Shared = PowerAuras:RegisterModule("SharedChecks");

--------------------------------------------------------------------------------
-- UnitAura Trigger/Source Checks
-- Note: These should be called as functions, not methods.
--------------------------------------------------------------------------------

do
	local tooltip = PowerAuras.ScanTooltip;

	--- Checks the tooltip of an effect for a match.
	-- @param unit   The unit to check.
	-- @param index  The effect index.
	-- @param match  The match to find.
	-- @param filter The filter for UnitAura.
	function Shared.CheckAuraTooltip(unit, index, match, filter)
		-- Set up the tooltip.
		tooltip:SetOwner(UIParent, "ANCHOR_NONE");
		tooltip:SetUnitAura(unit, index, filter);
		-- Scan lines.
		for _, left, right in PowerAuras:GetTooltipLines() do
			if(left:find(match, 1, true) or right:find(match, 1, true)) then
				return true;
			end
		end
		-- Done.
		tooltip:Hide();
		return false;
	end
end

--- Callback function for CheckUnits. Called when a unit needs to be checked.
-- @param unit    The unit to be checked.
-- @param filt    The filter to pass to UnitAura.
-- @param matches The table of matches to process.
-- @param start   The index to start from. Optional, defaults to 1.
function Shared.CheckUnitAura(unit, filt, matches, start)
	-- Check for effects on this unit.
	local i, max, start = 1, 40, start or 1;
	-- If start is 1, wrapping isn't needed.
	local wrapped = (start == 1);
	while(i <= max) do
		-- Get the real index.
		local j = ((start + i - 2) % max) + 1;
		-- Get effect data.
		-- NOTE: 5.1.0 (or later) will have the cast by player character (cbPC)
		-- argument will always be at index #14.
		local name, _, _, v0, _, _, _, caster, isStealable, _,
			id, _, _, v1, v2, v3--[[, cbPC]] = UnitAura(unit, j, filt);
		-- Effect exists?
		if(not name and not wrapped) then
			-- Wrap around.
			i = max - (((start + max - 2) % max) + 1) + 1;
			wrapped = true;
		elseif(not name and wrapped) then
			-- Not found, and we've wrapped.
			return false;
		else
			-- Process matches.
			for k = 1, #(matches) do
				-- Get the match.
				local match = matches[k];
				-- Extract the values.
				local effect = match.Effect;
				local ignoreCase = match.IgnoreCase;
				local exact, pattern = match.Exact, match.Pattern;
				local tip = (match.UseTooltip and match.Tooltip or nil);

				-- Case insensitive?
				local name = (ignoreCase and name:lower() or name);

				-- Test name/ID.
				if(id == tonumber(effect)
					or exact and name == effect
					or not exact and name:find(effect, 1, not pattern)
					or tip and Shared.CheckAuraTooltip(unit, j, tip, filt)) then
					-- Extract more values.
					local castBy, stealable = match.CastBy, match.Stealable;
					local count, src = match.Count, match.CountSource;
					local op = match.Operator;
					
					-- Passed name/ID test. Test the rest of the things.
					local result = ((castBy and caster == castBy or not castBy)
						and (stealable and isStealable or not stealable)
						and PowerAuras:CheckOperator(
							(src == 0 and v0
								or (src == 1 and tonumber(v1)
									or src == 2 and tonumber(v2)
									or src == 3 and tonumber(v3))
								or 0),
							op,
							count
						)
					);
					-- Succeeded?
					if(result) then
						return true, j, k;
					end
				end
			end
			-- Next.
			i = i + 1;
		end
	end
	-- Getting here indicates failure.
	return false;
end