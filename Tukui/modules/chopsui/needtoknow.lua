local T, C, L = unpack(select(2, ...)) -- Import: T - functions, constants, variables; C - config; L - locales
assert(NeedToKnow, "ChopsUI NeedToKnow extension failed to load, make sure NeedToKnow is enabled")

-- Override the Update event in NeedToKnow to assign the proper buffs/debuffs and position the frames.
NeedToKnow.Update_ = NeedToKnow.Update
NeedToKnow.Update = function()

  ChopsuiConfigureNeedToKnowPlayerBuffs()
  ChopsuiConfigureNeedToKnowTargetDebuffs()
  NeedToKnow.Update_()

  playerFrame = _G["NeedToKnow_Group1"]
  targetFrame = _G["NeedToKnow_Group2"]

  -- Position the player buff tracker
  playerFrame:ClearAllPoints()
  playerFrame:SetPoint("BOTTOMLEFT", TukuiPlayer, "TOPLEFT", (NeedToKnow_Settings["Spec"][NEEDTOKNOW.CURRENTSPEC]["Groups"][1]["Width"] * -1) -4, 180)

  -- Position the target debuff tracker
  targetFrame:ClearAllPoints()
  if (T.Role == "Caster" and not (T.Spec == "HOLY" or T.Spec == "RESTORATION" or T.Spec == "DISCIPLINE")) then
    DEFAULT_CHAT_FRAME:AddMessage("Setting NTK to caster size because of role " .. T.Role .. " and spec " .. T.Spec)
    NeedToKnow_Settings["Spec"][NEEDTOKNOW.CURRENTSPEC]["Groups"][2]["Scale"] = 0.77
    targetFrame:SetPoint("BOTTOMLEFT", TukuiChatBackgroundRight, "TOPLEFT", (NeedToKnow_Settings["Spec"][NEEDTOKNOW.CURRENTSPEC]["Groups"][1]["Width"] * -1) - 20, 240)
  else
    DEFAULT_CHAT_FRAME:AddMessage("Setting NTK to normal size because of role " .. T.Role .. " and spec " .. T.Spec)
    NeedToKnow_Settings["Spec"][NEEDTOKNOW.CURRENTSPEC]["Groups"][2]["Scale"] = 0.6666667461395264
    targetFrame:SetPoint("BOTTOMRIGHT", TukuiTarget, "TOPRIGHT", 4, 180)
  end

end

-- Configure the NeedToKnow player buff bars
function ChopsuiConfigureNeedToKnowPlayerBuffs()

  for i = 1, NEEDTOKNOW.MAXBARS do
    NeedToKnow_Settings["Spec"][NEEDTOKNOW.CURRENTSPEC]["Groups"][1]["Bars"][i]["Enabled"] = false
  end

  if T.myclass == "DEATHKNIGHT" then

    if T.Spec == "BLOOD" then
      ChopsuiNeedToKnowPlayerBuff(3, "Icebound Fortitude", { 0.01, 0.56, 0.6 }, true)
      ChopsuiNeedToKnowPlayerBuff(4, "Vampiric Blood", { 0.74, 0, 0.02 }, true)
      ChopsuiNeedToKnowPlayerBuff(5, "Bone Shield", { 0.04, 0.46, 0.98 }, true)
      ChopsuiNeedToKnowPlayerBuff(6, "Blade Barrier", { 0.6, 0, 0.07 }, true)
    elseif T.Spec == "FROST" then
      ChopsuiNeedToKnowPlayerBuff(5, "Pillar of Frost", { 0, 1, 0.91 }, true)
      ChopsuiNeedToKnowPlayerBuff(6, "Killing Machine", { 0, 0.68, 1 }, true)
    elseif T.Spec == "UNHOLY" then
      ChopsuiNeedToKnowPlayerBuff(5, "Icebound Fortitude", { 0.01, 0.56, 0.6 }, true)
      ChopsuiNeedToKnowPlayerBuff(6, "Shadow Infusion, Dark Transformation", { 0, 0.6, 0.03 }, true, "pet")
    end

  elseif T.myclass == "DRUID" then

    if T.Spec == "FERALCOMBAT" then
      if T.Role == "dps" then
        ChopsuiNeedToKnowPlayerBuff(1, "Predator's Swiftness", { 0.6, 0.38, 0 }, true)
        ChopsuiNeedToKnowPlayerBuff(2, "Barkskin", { 0.70, 0.68, 0 }, true)
        ChopsuiNeedToKnowPlayerBuff(3, "Survival Instincts", { 0.25, 0.6, 0.45 }, true)
        ChopsuiNeedToKnowPlayerBuff(4, "Berserk", { 0.71, 0, 1 }, true)
        ChopsuiNeedToKnowPlayerBuff(5, "Stampede", { 0.74, 0.33, 0 }, true)
        ChopsuiNeedToKnowPlayerBuff(6, "Savage Roar", { 0.92, 0.76, 0 }, true)
      end
    end

  elseif T.myclass == "MAGE" then

    if T.Spec == "ARCANE" then
      ChopsuiNeedToKnowPlayerBuff(1, "Invisibility", { 0, 1, 0.86 }, true)
      ChopsuiNeedToKnowPlayerBuff(2, "Mage Ward", { 0.74, 0, 0.83 }, true)
      ChopsuiNeedToKnowPlayerBuff(3, "Arcane Power", { 0.76, 0.43, 0.21 }, true)
      ChopsuiNeedToKnowPlayerBuff(4, "Presence of Mind", { 0, 0.59, 1 }, true)
      ChopsuiNeedToKnowPlayerBuff(5, "Arcane Missiles!", { 0, 0.34, 0.6 }, true)
      ChopsuiNeedToKnowPlayerBuff(6, "Arcane Potency", { 0, 1, 0.91 }, true)
    elseif T.Spec == "FIRE" then
      ChopsuiNeedToKnowPlayerBuff(1, "Invisibility", { 0, 1, 0.86 }, true)
      ChopsuiNeedToKnowPlayerBuff(2, "Mage Ward", { 0.74, 0, 0.83 }, true)
    elseif T.Spec == "FROST" then
      ChopsuiNeedToKnowPlayerBuff(3, "Icy Veins", { 0, 1, 0.81 }, true)
      ChopsuiNeedToKnowPlayerBuff(4, "Ice Barrier", { 0, 0.41, 0.67 }, true)
      ChopsuiNeedToKnowPlayerBuff(5, "Fingers of Frost", { 0, 0.52, 0.6 }, true)
      ChopsuiNeedToKnowPlayerBuff(6, "Brain Freeze", { 0.87, 0.48, 0 }, true)
    end

  elseif T.myclass == "PALADIN" then

    ChopsuiNeedToKnowPlayerBuff(1, "Divine Shield, Divine Protection", { 0.78, 0, 0.06 }, true)
    ChopsuiNeedToKnowPlayerBuff(5, "Avenging Wrath", { 0.91, 0.85, 0 }, true)
    ChopsuiNeedToKnowPlayerBuff(6, "Judgements of the Pure", { 0.6, 0.44, 0 }, true)
    
    if T.Spec == "HOLY" then
      ChopsuiNeedToKnowPlayerBuff(2, "Conviction", { 0.6, 0.23, 0.09 }, true)
      ChopsuiNeedToKnowPlayerBuff(3, "Divine Plea", { 0.74, 0.59, 0 }, true)
      ChopsuiNeedToKnowPlayerBuff(4, "Divine Favor", { 0.86, 0.86, 0.86 }, true)
    elseif T.Spec == "PROTECTION" then
      ChopsuiNeedToKnowPlayerBuff(2, "Guardian of Ancient Kings", { 1, 0.30, 0 }, true)
      ChopsuiNeedToKnowPlayerBuff(3, "Ardent Defender", { 0.6, 0.44, 0 }, true)
      ChopsuiNeedToKnowPlayerBuff(4, "Inquisition", { 1, 0.60, 0 }, true)
      ChopsuiNeedToKnowPlayerBuff(6, "Sacred Duty", { 0, 0.41, 0.6 }, true)
    elseif T.Spec == "RETRIBUTION" then
      ChopsuiNeedToKnowPlayerBuff(2, "Inquisition", { 1, 0.60, 0 }, true)
      ChopsuiNeedToKnowPlayerBuff(3, "The Art of War", { 1, 0.94, 0 }, true)
      ChopsuiNeedToKnowPlayerBuff(4, "Hand of Light", { 0.87, 0, 1 },true)
    end

  elseif T.myclass == "PRIEST" then

    if T.Spec == "DISCIPLINE" then
      ChopsuiNeedToKnowPlayerBuff(1, "Borrowed Time", { 0.96, 0.65, 0 }, true)
      ChopsuiNeedToKnowPlayerBuff(2, "Evangelism", { 0.91, 0.88, 0.96 }, true)
      ChopsuiNeedToKnowPlayerBuff(3, "Archangel", { 1, 0.86, 0.01 }, true)
      ChopsuiNeedToKnowPlayerBuff(4, "Inner Focus", { 0, 0.79, 1 }, true)
      ChopsuiNeedToKnowPlayerBuff(5, "Fade", { 0, 0.37, 1 }, true)
    elseif T.Spec == "SHADOW" then
      ChopsuiNeedToKnowPlayerBuff(1, "Shadow Orb", { 0.5, 0.08, 0.57 }, true)
      ChopsuiNeedToKnowPlayerBuff(2, "Dark Evangelism", { 0.45, 0.43, 0.48 }, true)
      ChopsuiNeedToKnowPlayerBuff(3, "Dark Archangel", { 1, 0.25, 0 }, true)
      ChopsuiNeedToKnowPlayerBuff(4, "Dispersion", { 0.02, 0.64, 0.13 }, true)
      ChopsuiNeedToKnowPlayerBuff(5, "Fade", { 0, 0.37, 1 }, true)
    end

  elseif T.myclass == "ROGUE" then

    if T.Spec == "ASSASSINATION" then
      ChopsuiNeedToKnowPlayerBuff(2, "Cloak of Shadows", { 0.6, 0, 0.49 }, true)
      ChopsuiNeedToKnowPlayerBuff(3, "Feint", { 0, 0.57, 6 }, true)
      ChopsuiNeedToKnowPlayerBuff(4, "Overkill", { 0.80, 0.01, 0 }, true)
      ChopsuiNeedToKnowPlayerBuff(5, "Envenom", { 0.01, 0.53, 0 }, true)
      ChopsuiNeedToKnowPlayerBuff(6, "Slice and Dice", { 0.86, 0.67, 0 }, true)
    elseif T.Spec == "COMBAT" then
      ChopsuiNeedToKnowPlayerBuff(1, "Shallow Insight, Moderate Insight, Deep Insight", { 0.6, 0, 0.49 }, true)
      ChopsuiNeedToKnowPlayerBuff(2, "Cloak of Shadows", { 0.6, 0, 0.49 }, true)
      ChopsuiNeedToKnowPlayerBuff(3, "Feint", { 0, 0.57, 6 }, true)
      ChopsuiNeedToKnowPlayerBuff(4, "Adrenaline Rush", { 0.80, 0.01, 0 }, true)
      ChopsuiNeedToKnowPlayerBuff(5, "Blade Flurry", { 0.01, 0.53, 0 }, true)
      ChopsuiNeedToKnowPlayerBuff(6, "Slice and Dice", { 0.86, 0.67, 0 }, true)
    end

  elseif T.myclass == "SHAMAN" then

    if T.Spec == "ELEMENTAL" then
      ChopsuiNeedToKnowPlayerBuff(2, "Spiritwalker's Grace", { 0.41, 1, 0 }, true)
      ChopsuiNeedToKnowPlayerBuff(3, "Unleash Flame", { 0.6, 0.03, 0 }, true)
      ChopsuiNeedToKnowPlayerBuff(4, "Elemental Mastery", { 0, 0.38, 0.86 }, true)
      ChopsuiNeedToKnowPlayerBuff(5, "Lightning Shield", { 0, 0.60, 0.74 }, true)
      ChopsuiNeedToKnowPlayerBuff(6, "Flametongue", { 0.69, 0.42, 0 }, true, "mhand")
    elseif T.Spec == "RESTORATION" then
      ChopsuiNeedToKnowPlayerBuff(2, "Spiritwalker's Grace", { 0.41, 1, 0 }, true)
      ChopsuiNeedToKnowPlayerBuff(3, "Stoneclaw Totem", { 0.6, 0.10, 0 }, true)
      ChopsuiNeedToKnowPlayerBuff(4, "Tidal Waves", { 0.03, 0.88, 1 }, true)
      ChopsuiNeedToKnowPlayerBuff(5, "Water Shield", { 0, 0.60, 0.74 }, true)
      ChopsuiNeedToKnowPlayerBuff(6, "Earthliving", { 0, 0.81, 0.4 }, true, "mhand")
    end

  elseif T.myclass == "WARLOCK" then

    if T.Spec == "AFFLICTION" then

      ChopsuiNeedToKnowPlayerBuff(6, "Eradication", { 0.53, 0, 0.78 }, true)

    elseif T.Spec == "DEMONOLOGY" then

      ChopsuiNeedToKnowPlayerBuff(6, "Metamorphosis", { 0.53, 0, 0.78 }, true)
      ChopsuiNeedToKnowPlayerBuff(6, "Molten Core", { 0.91, 0.54, 0 }, true)

    elseif T.Spec == "DESTRUCTION" then

      ChopsuiNeedToKnowPlayerBuff(6, "Improved Soul Fire", { 0.91, 0.54, 0 }, true)

    end

  elseif T.myclass == "WARRIOR" then

    if T.Spec == "PROTECTION" then
      ChopsuiNeedToKnowPlayerBuff(1, "Shield Wall", { 0.19, 0.71, 0.78 }, true)
      ChopsuiNeedToKnowPlayerBuff(2, "Last Stand", { 0.75, 0.58, 0 }, true)
      ChopsuiNeedToKnowPlayerBuff(3, "Earthen Armor", { 0.25, 0.25, 0.25 }, true)
      ChopsuiNeedToKnowPlayerBuff(4, "Shield Block, Spell Reflection", { 0.91, 0.91, 0.91 }, true)
      ChopsuiNeedToKnowPlayerBuff(5, "Hold the Line", { 0.14, 0.6, 0.2 }, true)
      ChopsuiNeedToKnowPlayerBuff(6, "Thunderstruck", { 0.6, 0, 0.05 }, true)
    end

  end
  
end

-- Configure the NeedToKnow target debuff bars
function ChopsuiConfigureNeedToKnowTargetDebuffs()

  for i = 1, NEEDTOKNOW.MAXBARS do
    NeedToKnow_Settings["Spec"][NEEDTOKNOW.CURRENTSPEC]["Groups"][2]["Bars"][i]["Enabled"] = false
  end
  
  if T.myclass == "DEATHKNIGHT" then

    ChopsuiNeedToKnowTargetDebuff(5, "Blood Plague", { 0.6, 0, 0.07 }, true)
    ChopsuiNeedToKnowTargetDebuff(6, "Frost Fever", { 0.07, 0.65, 0.81 }, true)

    if T.Spec == "BLOOD" then
      ChopsuiNeedToKnowTargetDebuff(4, "Vindication, Demoralizing Roar, Curse of Weakness, Demoralizing Shout, Scarlet Fever", { 0.19, 0.71, 0.78 }, false)
    elseif T.Spec == "FROST" then
      ChopsuiNeedToKnowTargetDebuff(4, "Hungering Cold", { 0, 0.6, 1 }, true)
    elseif T.Spec == "UNHOLY" then
      ChopsuiNeedToKnowTargetDebuff(3, "Unholy Blight", { 0, 0.51, 0.14 }, true)
      ChopsuiNeedToKnowTargetDebuff(4, "Ebon Plague", { 0.6, 0, 0.54 }, true)
    end

  elseif T.myclass == "DRUID" then

    if T.Spec == "FERALCOMBAT" then
      if T.Role == "dps" then
        ChopsuiNeedToKnowTargetDebuff(2, "Pounce", { 0, 0.44, 0.6 }, true)
        ChopsuiNeedToKnowTargetDebuff(3, "Rip", { 0.89, 0.38, 0 }, true)
        ChopsuiNeedToKnowTargetDebuff(4, "Rake", { 0.6, 0.02, 0 }, true)
        ChopsuiNeedToKnowTargetDebuff(5, "Faerie Fire, Expose Armor, Sunder Armor", { 0.6, 0, 0.55 }, false)
        ChopsuiNeedToKnowTargetDebuff(6, "Mangle, Trauma", { 0.6, 0.34, 0 }, false)
      end
    end

  elseif T.myclass == "MAGE" then

    if T.Spec == "ARCANE" then
    elseif T.Spec == "FIRE" then
      ChopsuiNeedToKnowTargetDebuff(2, "Combustion", { 0.68, 0, 0.01 }, true)
      ChopsuiNeedToKnowTargetDebuff(3, "Pyroblast!", { 1, 0.76, 0 }, true)
      ChopsuiNeedToKnowTargetDebuff(4, "Ignite", { 1, 0.18, 0 }, true)
      ChopsuiNeedToKnowTargetDebuff(5, "Critical Mass", { 0, 0.55, 0.69 }, true)
      ChopsuiNeedToKnowTargetDebuff(6, "Living Bomb", { 1, 0.57, 0 }, true)
    elseif T.Spec == "FROST" then
      ChopsuiNeedToKnowTargetDebuff(2, "Frost Nova", { 0, 0.52, 0.88 }, true)
      ChopsuiNeedToKnowTargetDebuff(3, "Cone of Cold", { 0, 0.73, 0.67 }, true)
      ChopsuiNeedToKnowTargetDebuff(4, "Deep Freeze", { 0, 0.29, 0.6 }, true)
      ChopsuiNeedToKnowTargetDebuff(5, "Frostfire Bolt", { 0.76, 0.46, 0 }, true)
      ChopsuiNeedToKnowTargetDebuff(6, "Frostbolt", { 0, 0.45, 0.6 }, true)
    end

  elseif T.myclass == "PALADIN" then

    if T.Spec == "HOLY" then
      ChopsuiNeedToKnowTargetDebuff(1, "Hammer of Justice", { 0, 0.57, 0.6 }, true)
    elseif T.Spec == "PROTECTION" then
      ChopsuiNeedToKnowTargetDebuff(3, "Hammer of Justice", { 0, 0.57, 0.6 }, true)
      ChopsuiNeedToKnowTargetDebuff(4, "Censure", { 1, 0.98, 0 }, true)
      ChopsuiNeedToKnowTargetDebuff(5, "Vindication, Demoralizing Roar, Curse of Weakness, Demoralizing Shout, Scarlet Fever", { 0.19, 0.71, 0.78 }, false)
      ChopsuiNeedToKnowTargetDebuff(6, "Frost Fever, Infected Wounds, Judgements of the Just, Thunder Clap", { 0.28, 0.79, 0.30 }, false)
    elseif T.Spec == "RETRIBUTION" then
      ChopsuiNeedToKnowTargetDebuff(4, "Hammer of Justice", { 0, 0.57, 0.6 }, true)
      ChopsuiNeedToKnowTargetDebuff(5, "Repentence", { 0.04, 0.29, 0.6 }, true)
      ChopsuiNeedToKnowTargetDebuff(6, "Censure", { 1, 0.98, 0 }, true)
    end

  elseif T.myclass == "PRIEST" then

    if T.Spec == "SHADOW" then
      ChopsuiNeedToKnowTargetDebuff(1, "Vampiric Touch", { 0, 0.38, 0.6 }, true)
      ChopsuiNeedToKnowTargetDebuff(2, "Shadow Word: Pain", { 0.86, 0.41, 0 }, true)
      ChopsuiNeedToKnowTargetDebuff(3, "Devouring Plague", { 0.62, 0, 0.75 }, true)
      ChopsuiNeedToKnowTargetDebuff(4, "Mind Flay, Mind Sear", { 0.38, 0.76, 0.81 }, true)
    end

  elseif T.myclass == "ROGUE" then

    if T.Spec == "ASSASSINATION" then
      ChopsuiNeedToKnowTargetDebuff(2, "Cheap Shot, Kidney Shot", { 1, 0.94, 0 }, true)
      ChopsuiNeedToKnowTargetDebuff(3, "Garrote", { 0.92, 0.39, 0 }, true)
      ChopsuiNeedToKnowTargetDebuff(4, "Vendetta", { 0.64, 1, 0.94 }, true)
      ChopsuiNeedToKnowTargetDebuff(5, "Rupture", { 0.68, 0.04, 0 }, true)
      ChopsuiNeedToKnowTargetDebuff(6, "Deadly Poison", { 0.01, 0.53, 0 }, true)
    elseif T.Spec == "COMBAT" then
      ChopsuiNeedToKnowTargetDebuff(2, "Cheap Shot, Kidney Shot", { 1, 0.94, 0 }, true)
      ChopsuiNeedToKnowTargetDebuff(3, "Garrote", { 0.92, 0.39, 0 }, true)
      ChopsuiNeedToKnowTargetDebuff(4, "Revealing Strike", { 0.64, 1, 0.94 }, true)
      ChopsuiNeedToKnowTargetDebuff(5, "Rupture", { 0.68, 0.04, 0 }, true)
      ChopsuiNeedToKnowTargetDebuff(6, "Deadly Poison", { 0.01, 0.53, 0 }, true)
    end

  elseif T.myclass == "SHAMAN" then

    if T.Spec == "ELEMENTAL" then
      ChopsuiNeedToKnowTargetDebuff(5, "Hex", { 0, 0.53, 0.02 }, true)
      ChopsuiNeedToKnowTargetDebuff(6, "Flame Shock", { 0.91, 0.54, 0 }, true, { 1, 1, 0 }, "Lava Burst")
    elseif T.Spec == "RESTORATION" then
      ChopsuiNeedToKnowTargetDebuff(6, "Flame Shock", { 0.91, 0.54, 0 }, true)
    end

  elseif T.myclass == "WARLOCK" then

    ChopsuiNeedToKnowTargetDebuff(3, "Bane of Agony, Bane of Doom", { 0.79, 0.52, 0 }, true)
    ChopsuiNeedToKnowTargetDebuff(4, "Shadow and Flame", { 0, 0.10, 0.96 }, true)
    ChopsuiNeedToKnowTargetDebuff(5, "Corruption", { 0.74, 0, 0.06 }, true)
    ChopsuiNeedToKnowTargetDebuff(6, "Curse of the Elements, Curse of Tongues", { 0.53, 0, 0.78 }, true)
    
    if T.Spec == "AFFLICTION" then

      ChopsuiNeedToKnowTargetDebuff(1, "Haunt", { 0, 0.74, 1 }, true)
      ChopsuiNeedToKnowTargetDebuff(2, "Unstable Affliction", { 0.47, 0.31, 0 }, true)

    elseif T.Spec == "DEMONOLOGY" then

      ChopsuiNeedToKnowTargetDebuff(2, "Immolate", { 0.91, 0.54, 0 }, true)

    elseif T.Spec == "DESTRUCTION" then
      
      ChopsuiNeedToKnowTargetDebuff(2, "Immolate", { 0.91, 0.54, 0 }, true)

    end

  elseif T.myclass == "WARRIOR" then

    if T.Spec == "PROTECTION" then
      ChopsuiNeedToKnowTargetDebuff(1, "Shockwave", { 0.04, 0.29, 0.6 }, true)
      ChopsuiNeedToKnowTargetDebuff(2, "Concussion Blow", { 0.91, 0.91, 0.91 }, true)
      ChopsuiNeedToKnowTargetDebuff(3, "Rend", { 0.6, 0.01, 0 }, true)
      ChopsuiNeedToKnowTargetDebuff(4, "Expose Armor, Sunder Armor, Faerie Fire", { 0.75, 0.58, 0 }, false)
      ChopsuiNeedToKnowTargetDebuff(5, "Vindication, Demoralizing Roar, Curse of Weakness, Demoralizing Shout, Scarlet Fever", { 0.19, 0.71, 0.78 }, false)
      ChopsuiNeedToKnowTargetDebuff(6, "Frost Fever, Infected Wounds, Judgements of the Just, Thunder Clap", { 0.28, 0.79, 0.30 }, false)
    end

  end
  
end

-- Configure a NeedToKnow player buff bar
function ChopsuiNeedToKnowPlayerBuff(barID, buffName, color, onlyMine, unit)

  if not unit then
    unit = "player"
  end
  colorRed, colorGreen, colorBlue = unpack(color)

  NeedToKnow_Settings["Spec"][NEEDTOKNOW.CURRENTSPEC]["Groups"][1]["Bars"][barID]["BuffOrDebuff"] = "HELPFUL"
  NeedToKnow_Settings["Spec"][NEEDTOKNOW.CURRENTSPEC]["Groups"][1]["Bars"][barID]["Enabled"] = true
  NeedToKnow_Settings["Spec"][NEEDTOKNOW.CURRENTSPEC]["Groups"][1]["Bars"][barID]["AuraName"] = buffName
  NeedToKnow_Settings["Spec"][NEEDTOKNOW.CURRENTSPEC]["Groups"][1]["Bars"][barID]["OnlyMine"] = onlyMine
  NeedToKnow_Settings["Spec"][NEEDTOKNOW.CURRENTSPEC]["Groups"][1]["Bars"][barID]["Unit"] = unit
  NeedToKnow_Settings["Spec"][NEEDTOKNOW.CURRENTSPEC]["Groups"][1]["Bars"][barID]["BarColor"] = {
    ["r"] = colorRed,
    ["g"] = colorGreen,
    ["b"] = colorBlue,
    ["a"] = 1
  }

end

-- Configure a NeedToKnow target debuff b ar
function ChopsuiNeedToKnowTargetDebuff(barID, debuffName, color, onlyMine, vctColor, vctSpell)

  colorRed, colorGreen, colorBlue = unpack(color)
  vctColorRed, vctColorGreen, vctColorBlue = nil
  if vctColor then
    vctColorRed, vctColorGreen, vctColorBlue = unpack(vctColor)
  end

  NeedToKnow_Settings["Spec"][NEEDTOKNOW.CURRENTSPEC]["Groups"][2]["Bars"][barID]["BuffOrDebuff"] = "HARMFUL"
  NeedToKnow_Settings["Spec"][NEEDTOKNOW.CURRENTSPEC]["Groups"][2]["Bars"][barID]["Enabled"] = true
  NeedToKnow_Settings["Spec"][NEEDTOKNOW.CURRENTSPEC]["Groups"][2]["Bars"][barID]["AuraName"] = debuffName
  NeedToKnow_Settings["Spec"][NEEDTOKNOW.CURRENTSPEC]["Groups"][2]["Bars"][barID]["OnlyMine"] = onlyMine
  NeedToKnow_Settings["Spec"][NEEDTOKNOW.CURRENTSPEC]["Groups"][2]["Bars"][barID]["Unit"] = "target"
  NeedToKnow_Settings["Spec"][NEEDTOKNOW.CURRENTSPEC]["Groups"][2]["Bars"][barID]["BarColor"] = {
    ["r"] = colorRed,
    ["g"] = colorGreen,
    ["b"] = colorBlue,
    ["a"] = 1
  }

  if vctColorRed and vctColorGreen and vctColorBlue then
    NeedToKnow_Settings["Spec"][NEEDTOKNOW.CURRENTSPEC]["Groups"][2]["Bars"][barID]["vtc_color"] = {
      ["r"] = vctColorRed,
      ["g"] = vctColorGreen,
      ["b"] = vctColorBlue,
      ["a"] = 0.5
    }
  end

  if vctSpell then
    NeedToKnow_Settings["Spec"][NEEDTOKNOW.CURRENTSPEC]["Groups"][2]["Bars"][barID]["vct_spell"] = vctSpell
  end

end

-- Reset NeedToKnow
function ChopsuiNeedToKnowReset()

  -- Reset the settings of NeedToKnow
  NeedToKnow_Settings = CopyTable(NEEDTOKNOW.DEFAULTS)
  NeedToKnow_Settings["Locked"] = true

  -- Change the texture and font
  NeedToKnow_Settings["BarTexture"] = "TukuiNormalTexture"
  NeedToKnow_Settings["BarFont"] = [[Interface\Addons\Tukui\medias\fonts\normal_font.ttf]]

  for i = 1,2 do

    -- Change the player bar look&feel
    NeedToKnow_Settings["Spec"][i]["Groups"][1]["Enabled"] = true
    NeedToKnow_Settings["Spec"][i]["Groups"][1]["NumberBars"] = 6
    NeedToKnow_Settings["Spec"][i]["Groups"][1]["Scale"] = 0.6666667461395264
    NeedToKnow_Settings["Spec"][i]["Groups"][1]["Width"] = 290

    -- Change the target bar look&feel
    NeedToKnow_Settings["Spec"][i]["Groups"][2]["Enabled"] = true
    NeedToKnow_Settings["Spec"][i]["Groups"][2]["NumberBars"] = 6
    NeedToKnow_Settings["Spec"][i]["Groups"][2]["Scale"] = 0.6666667461395264
    NeedToKnow_Settings["Spec"][i]["Groups"][2]["Width"] = 290

  end
  
end
