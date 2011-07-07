local L = LibStub('AceLocale-3.0'):GetLocale('Ellipsis')

local aoeSpells = {
}

local uniqueSpells = {
}

local cooldownGroups = {
}

local totemGroups = { -- Fire = 1 Earth = 2 Water = 3 Air = 4 (Blizzard's ordering)
}

function Ellipsis:DefineClassSpells()
	local class = select(2, UnitClass('player'))
	local aoe = self.aoeSpells
	local name, rank, icon

	-- Fill out class-specific aoe spells
	if (aoeSpells[class]) then
		for spellID, duration in pairs(aoeSpells[class]) do
			name, _, icon = GetSpellInfo(spellID)
			aoe[name] = {duration, icon}
		end
	end

	-- Fill out unique (one existance total) spells for class
	if (uniqueSpells[class]) then
		for spellID in pairs(uniqueSpells[class]) do
			name = GetSpellInfo(spellID)
			self.uniqueSpells[name] = true
		end
	end

	-- Fill out special groups of cooldowns (hunter traps, shaman shocks, etc)
	if (cooldownGroups[class]) then
		for spellID, data in pairs(cooldownGroups[class]) do
			name = GetSpellInfo(spellID)
			self.cooldownGroups[name] = {L[data[1]], data[2]}
		end
	end

	-- Special cases for certain classes
	if (class == 'WARLOCK') then -- setup enslave demon
		self.specialSpell = GetSpellInfo(1098)
	elseif (class == 'SHAMAN') then -- used when checking for totemic call (as it will kill a bunch of timers)
		self.isShaman = true
		self.specialSpell = GetSpellInfo(36936)

		for spellID, totemType in pairs(totemGroups) do
			name = GetSpellInfo(spellID)
			self.totemGroups[name] = totemType
		end
	end
end
