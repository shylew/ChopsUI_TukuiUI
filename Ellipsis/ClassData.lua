local L = LibStub('AceLocale-3.0'):GetLocale('Ellipsis')

local aoeSpells = {
	['WARLOCK'] = {
		[5484] = 8, -- howl of terror
		[30283] = 3, -- shadowfury
		[47897] = 6, -- shadowflame
	},
	['DEATHKNIGHT'] = {
		[43265] = 10, -- death and decay
	},
	['DRUID'] = {
		[99] = 30, -- demo roar
		[740] = 8, -- tranquility
		[5209] = 6, -- challenging roar
		[16914] = 10, -- hurricane
		[33831] = 30, -- force of nature
	},
	['PRIEST'] = {
		[8122] = 8, -- psychic scream
		[64843] = 8, -- divine hymn
	},
	['HUNTER'] = {
		[1499] = 60, -- freezing trap
		[13795] = 60, -- immolation trap
		[13809] = 60 , -- ice trap
		[13813] = 60, -- explosive trap
		[13809] = 60, -- frost trap
		[34600] = 60, -- snake trap
	},
	['MAGE'] = {
		[11113] = 3, -- blast wave
		[120] = 8, -- cone of cold
		[122] = 8, -- frost nova
		[31661] = 5, -- dragon's breath
		[80353] = 40, -- time warp
	},
	['WARRIOR'] = {
		[1161] = 6, -- challenging shout
		[1160] = 30, -- demo shout
		[5246] = 8, -- intimidating shout
		[12323] = 6, -- piercing howl
		[6343] = 30, -- thunder clap
		[46968] = 4, -- shockwave
	},
	['ROGUE'] = {
		[1725] = 10, -- distract
	},
	['SHAMAN'] = {
		[2062] = 120, -- earth elemental
		[2484] = 45, -- earthbind
		[2894] = 120, -- fire elemental
		[8227] = 300, -- flametongue
		[8177] = 45, -- grounding
		[5394] = 300, -- healing stream
		[8190] = 20, -- magma
		[5675] = 300, -- mana spring
		[16190] = 12, -- mana tide
		[3599] = 60, -- searing
		[5730] = 15, -- stoneclaw
		[8071] = 300, -- stoneskin
		[8075] = 300, -- strength of earth
		[8143] = 300, -- tremor
		[8512] = 300, -- windfury
		[3738] = 300, -- wrath of air
		[8184] = 300, -- elemental resistance
		[87718] = 300, -- tranquil mind
		[32182] = 40, -- heroism
		[2825] = 40, -- bloodlust
		[51533] = 45, -- feral spirit (wolves)
	},
	['PALADIN'] = {
		[26573] = 10, -- consecration
	},
}

local uniqueSpells = {
	['WARLOCK'] = {
		[6358] = true, -- seduction
		[710] = true, -- banish
		[1098] = true, -- enslave demon
	},
	['DRUID'] = {
		[2637] = true, -- hibernate
	},
	['PRIEST'] = {
		[33076] = true, -- prayer of mending
	},
	['HUNTER'] = {
		[1130] = true, -- hunter's mark
	},
	['MAGE'] = {
		[118] = true, -- polymorph
		[28271] = true, -- polymorph: turtle
		[28272] = true, -- polymorph: pig
		[31589] = true, -- slow
		[61025] = true, -- polymorph: serpent
		[61305] = true, -- polymorph: cat
		[61721] = true, -- polymorph: rabbit
		[61780] = true, -- polymorph: turkey (wth)
	},
	['ROGUE'] = {
		[6770] = true, -- sap
	},
	['SHAMAN'] = {
		[974] = true, -- earth shield
		[51514] = true, -- hex
	},
}

local cooldownGroups = {
	['HUNTER'] = {
		[1499] = {'Traps', [[Interface\Icons\Ability_Ensnare]]}, -- freezing trap
		[13795] = {'Traps', [[Interface\Icons\Ability_Ensnare]]}, -- immolation trap
		[13813] = {'Traps', [[Interface\Icons\Ability_Ensnare]]}, -- explosive trap
		[13809] = {'Traps', [[Interface\Icons\Ability_Ensnare]]}, -- frost trap
		[34600] = {'Traps', [[Interface\Icons\Ability_Ensnare]]}, -- snake trap
		[13809] = {'Traps', [[Interface\Icons\Ability_Ensnare]]}, -- ice trap
	},
	['SHAMAN'] = {
		[8042] = {'Shocks', [[Interface\Icons\Spell_Nature_WispSplode]]}, -- earth shock
		[8050] = {'Shocks', [[Interface\Icons\Spell_Nature_WispSplode]]}, -- flame shock
		[8056] = {'Shocks', [[Interface\Icons\Spell_Nature_WispSplode]]}, -- frost shock
	},
}

local totemGroups = { -- Fire = 1 Earth = 2 Water = 3 Air = 4 (Blizzard's ordering)
	[2062] = 2, -- earth elemental
	[2484] = 2, -- earthbind
	[2894] = 1, -- fire elemental
	[8227] = 1, -- flametongue
	[8177] = 4, -- grounding
	[5394] = 3, -- healing stream
	[8190] = 1, -- magma
	[5675] = 3, -- mana spring
	[16190] = 3, -- mana tide
	[3599] = 1, -- searing
	[5730] = 2, -- stoneclaw
	[8071] = 2, -- stoneskin
	[8075] = 2, -- strength of earth
	[8143] = 2, -- tremor
	[8512] = 4, -- windfury
	[3738] = 4, -- wrath of air
	[8184] = 3, -- elemental resistance
	[87718] = 3, -- tranquil mind
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
