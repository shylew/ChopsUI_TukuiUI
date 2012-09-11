local T, C, L, G = unpack(Tukui)
ChopsUI.RegisterModule("init", ChopsUI)

function ChopsUI.modules.init.Reset()

  -- Screenshots
  SetCVar("screenshotFormat", "png")
  SetCVar("screenshotQuality", 10)

  -- Combat text
  SetCVar("CombatDamage", 1)
  SetCVar("CombatHealing", 1)
  SetCVar("CombatLogPeriodicSpells", 1)

end
