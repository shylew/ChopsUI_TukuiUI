local T, C, L = unpack(Tukui)
ChopsUI.RegisterModule("needtoknow", NeedToKnow)

-- Override the Update event in NeedToKnow to assign the proper buffs/debuffs
-- and position the frames.
NeedToKnow.Update_ = NeedToKnow.Update
NeedToKnow.Update = function()

  ChopsUI.modules.needtoknow.ConfigurePlayerBuffs()
  ChopsUI.modules.needtoknow.ConfigureTargetDebuffs()
  ChopsUI.modules.needtoknow.ConfigureCooldowns()
  NeedToKnow.Update_()

  playerFrame = _G["NeedToKnow_Group1"]
  targetFrame = _G["NeedToKnow_Group2"]
  cdFrame = _G["NeedToKnow_Group3"]

  -- Position the player buff tracker
  if playerFrame ~= nil then
    playerFrame:ClearAllPoints()
    frameWidth = NeedToKnow.ProfileSettings.Groups[1].Width
    playerFrame:SetPoint("BOTTOMLEFT", TukuiPlayer, "TOPLEFT", (frameWidth * -1) -4, 180)
  end

  -- Position the target debuff tracker
  if targetFrame ~= nil then
    targetFrame:ClearAllPoints()
    targetFrame:SetPoint("BOTTOMRIGHT", TukuiTarget, "TOPRIGHT", 4, 180)
  end

  -- Positon the CD tracker
  if cdFrame ~= nil then
    cdFrame:ClearAllPoints()
    cdFrame:SetPoint("BOTTOMLEFT", TukuiChatBackgroundLeft, "TOPLEFT", 0, 130)
  end

end

-- Configure the NeedToKnow player buff bars
function ChopsUI.modules.needtoknow.ConfigurePlayerBuffs()

  for i = 1, NeedToKnow.ProfileSettings.Groups[1].NumberBars do
    NeedToKnow.ProfileSettings.Groups[1].Bars[i].Enabled = false
  end

  if T.myclass == "DEATHKNIGHT" then

    if T.Spec == "BLOOD" then
      ChopsUI.modules.needtoknow.PlayerBuff(3, "Icebound Fortitude", { 0.01, 0.56, 0.6 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(4, "Vampiric Blood", { 0.74, 0, 0.02 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(5, "Bone Shield", { 0.04, 0.46, 0.98 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(6, "Blade Barrier", { 0.6, 0, 0.07 }, true)
    elseif T.Spec == "FROST" then
      ChopsUI.modules.needtoknow.PlayerBuff(5, "Pillar of Frost", { 0, 1, 0.91 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(6, "Killing Machine", { 0, 0.68, 1 }, true)
    elseif T.Spec == "UNHOLY" then
      ChopsUI.modules.needtoknow.PlayerBuff(5, "Icebound Fortitude", { 0.01, 0.56, 0.6 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(6, "Shadow Infusion, Dark Transformation", { 0, 0.6, 0.03 }, true, "pet")
    end

  elseif T.myclass == "DRUID" then

    if T.Spec== "BALANCE" then
      ChopsUI.modules.needtoknow.PlayerBuff(1, "Volcanic Power", { 0.25, 0.25, 0.25 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(2, "Heroism, Bloodlust", { 0.6, 0.01, 0 }, false)
      ChopsUI.modules.needtoknow.PlayerBuff(3, "Shooting Stars", { 0, 0.10, 0.96 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(4, "Lunar Shower", { 0, 0.60, 0.74 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(5, "Nature's Grace", { 0.6, 0, 0.55 }, true)
    elseif T.Spec == "FERALCOMBAT" then
      if T.Role == "Melee" then
        ChopsUI.modules.needtoknow.PlayerBuff(1, "Predator's Swiftness", { 0.6, 0.38, 0 }, true)
        ChopsUI.modules.needtoknow.PlayerBuff(2, "Barkskin", { 0.70, 0.68, 0 }, true)
        ChopsUI.modules.needtoknow.PlayerBuff(3, "Survival Instincts", { 0.25, 0.6, 0.45 }, true)
        ChopsUI.modules.needtoknow.PlayerBuff(4, "Berserk", { 0.71, 0, 1 }, true)
        ChopsUI.modules.needtoknow.PlayerBuff(5, "Stampede", { 0.74, 0.33, 0 }, true)
        ChopsUI.modules.needtoknow.PlayerBuff(6, "Savage Roar", { 0.92, 0.76, 0 }, true)
      elseif T.Role == "Tank" then
        ChopsUI.modules.needtoknow.PlayerBuff(1, "Barkskin", { 0.19, 0.71, 0.78 }, true)
        ChopsUI.modules.needtoknow.PlayerBuff(2, "Survival Instincts", { 0.75, 0.58, 0 }, true)
        ChopsUI.modules.needtoknow.PlayerBuff(3, "Earthen Armor", { 0.25, 0.25, 0.25 }, true)
        ChopsUI.modules.needtoknow.PlayerBuff(4, "Savage Defense", { 0.91, 0.91, 0.91 }, true)
        ChopsUI.modules.needtoknow.PlayerBuff(5, "Pulverize", { 0.14, 0.6, 0.2 }, true)
        ChopsUI.modules.needtoknow.PlayerBuff(6, "Berserk", { 0.6, 0, 0.05 }, true)
      end
    end

  elseif T.myclass == "HUNTER" then

    ChopsUI.modules.needtoknow.PlayerBuff(5, "Call of the Wild", { 0.28, 0.79, 0.30 }, true)
    ChopsUI.modules.needtoknow.PlayerBuff(6, "Culling the Herd", { 1, 0.57, 0 }, true)
    
    if T.Spec == "MARKSMANSHIP" then
      ChopsUI.modules.needtoknow.PlayerBuff(3, "Improved Steady Shot", { 0.91, 0.85, 0 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(4, "Ready, Set, Aim...", { 0.6, 0.01, 0 }, true)
    elseif T.Spec == "SURVIVAL" then
      ChopsUI.modules.needtoknow.PlayerBuff(3, "Lock and Load", { 0.6, 0.01, 0 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(4, "Sniper Training", { 0.19, 0.71, 0.78 }, true)
    end

  elseif T.myclass == "MAGE" then

    if T.Spec == "ARCANE" then
      ChopsUI.modules.needtoknow.PlayerBuff(1, "Invisibility", { 0, 1, 0.86 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(2, "Mage Ward", { 0.74, 0, 0.83 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(3, "Arcane Power", { 0.76, 0.43, 0.21 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(4, "Presence of Mind", { 0, 0.59, 1 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(5, "Arcane Missiles!", { 0, 0.34, 0.6 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(6, "Arcane Potency", { 0, 1, 0.91 }, true)
    elseif T.Spec == "FIRE" then
      ChopsUI.modules.needtoknow.PlayerBuff(1, "Invisibility", { 0, 1, 0.86 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(2, "Mage Ward", { 0.74, 0, 0.83 }, true)
    elseif T.Spec == "FROST" then
      ChopsUI.modules.needtoknow.PlayerBuff(3, "Icy Veins", { 0, 1, 0.81 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(4, "Ice Barrier", { 0, 0.41, 0.67 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(5, "Fingers of Frost", { 0, 0.52, 0.6 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(6, "Brain Freeze", { 0.87, 0.48, 0 }, true)
    end

  elseif T.myclass == "PALADIN" then

    ChopsUI.modules.needtoknow.PlayerBuff(1, "Divine Shield, Divine Protection", { 0.78, 0, 0.06 }, true)
    ChopsUI.modules.needtoknow.PlayerBuff(5, "Avenging Wrath", { 0.91, 0.85, 0 }, true)
    ChopsUI.modules.needtoknow.PlayerBuff(6, "Judgements of the Pure", { 0.6, 0.44, 0 }, true)
    
    if T.Spec == "HOLY" then
      ChopsUI.modules.needtoknow.PlayerBuff(2, "Conviction", { 0.6, 0.23, 0.09 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(3, "Divine Plea", { 0.74, 0.59, 0 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(4, "Divine Favor", { 0.86, 0.86, 0.86 }, true)
    elseif T.Spec == "PROTECTION" then
      ChopsUI.modules.needtoknow.PlayerBuff(2, "Guardian of Ancient Kings", { 1, 0.30, 0 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(3, "Ardent Defender", { 0.6, 0.44, 0 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(4, "Inquisition", { 1, 0.60, 0 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(6, "Sacred Duty", { 0, 0.41, 0.6 }, true)
    elseif T.Spec == "RETRIBUTION" then
      ChopsUI.modules.needtoknow.PlayerBuff(2, "Inquisition", { 1, 0.60, 0 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(3, "The Art of War", { 1, 0.94, 0 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(4, "Hand of Light", { 0.87, 0, 1 },true)
    end

  elseif T.myclass == "PRIEST" then

    if T.Spec == "DISCIPLINE" then
      ChopsUI.modules.needtoknow.PlayerBuff(1, "Borrowed Time", { 0.96, 0.65, 0 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(2, "Evangelism", { 0.91, 0.88, 0.96 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(3, "Archangel", { 1, 0.86, 0.01 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(4, "Inner Focus", { 0, 0.79, 1 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(5, "Fade", { 0, 0.37, 1 }, true)
    elseif T.Spec == "SHADOW" then
      ChopsUI.modules.needtoknow.PlayerBuff(1, "Shadow Orb", { 0.5, 0.08, 0.57 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(2, "Dark Evangelism", { 0.45, 0.43, 0.48 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(3, "Dark Archangel", { 1, 0.25, 0 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(4, "Dispersion", { 0.02, 0.64, 0.13 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(5, "Fade", { 0, 0.37, 1 }, true)
    end

  elseif T.myclass == "ROGUE" then

    if T.Spec == "ASSASSINATION" then
      ChopsUI.modules.needtoknow.PlayerBuff(2, "Cloak of Shadows", { 0.6, 0, 0.49 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(3, "Feint", { 0, 0.57, 6 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(4, "Overkill", { 0.80, 0.01, 0 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(5, "Envenom", { 0.01, 0.53, 0 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(6, "Slice and Dice", { 0.86, 0.67, 0 }, true)
    elseif T.Spec == "COMBAT" then
      ChopsUI.modules.needtoknow.PlayerBuff(1, "Shallow Insight, Moderate Insight, Deep Insight", { 0.6, 0, 0.49 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(2, "Cloak of Shadows", { 0.6, 0, 0.49 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(3, "Feint", { 0, 0.57, 6 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(4, "Adrenaline Rush", { 0.80, 0.01, 0 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(5, "Blade Flurry", { 0.01, 0.53, 0 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(6, "Slice and Dice", { 0.86, 0.67, 0 }, true)
    elseif T.Spec == "SUBTLETY" then
      ChopsUI.modules.needtoknow.PlayerBuff(3, "Feint", { 0, 0.57, 6 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(2, "Cloak of Shadows", { 0.6, 0, 0.49 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(5, "Recuperate", { 0.01, 0.53, 0 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(6, "Slice and Dice", { 0.86, 0.67, 0 }, true)
    end

  elseif T.myclass == "SHAMAN" then

    if T.Spec == "ELEMENTAL" then
      ChopsUI.modules.needtoknow.PlayerBuff(2, "Spiritwalker's Grace", { 0.41, 1, 0 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(3, "Unleash Flame", { 0.6, 0.03, 0 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(4, "Elemental Mastery", { 0, 0.38, 0.86 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(5, "Lightning Shield", { 0, 0.60, 0.74 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(6, "Flametongue", { 0.69, 0.42, 0 }, true, "mhand")
    elseif T.Spec == "RESTORATION" then
      ChopsUI.modules.needtoknow.PlayerBuff(2, "Spiritwalker's Grace", { 0.41, 1, 0 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(3, "Stoneclaw Totem", { 0.6, 0.10, 0 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(4, "Tidal Waves", { 0.03, 0.88, 1 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(5, "Water Shield", { 0, 0.60, 0.74 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(6, "Earthliving", { 0, 0.81, 0.4 }, true, "mhand")
    end

  elseif T.myclass == "WARLOCK" then

    if T.Spec == "AFFLICTION" then

      ChopsUI.modules.needtoknow.PlayerBuff(6, "Eradication", { 0.53, 0, 0.78 }, true)

    elseif T.Spec == "DEMONOLOGY" then

      ChopsUI.modules.needtoknow.PlayerBuff(4, "Demon Soul: Felhunter, Demon Soul: Felguard", { 0.74, 0, 0.06 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(5, "Metamorphosis", { 0.53, 0, 0.78 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(6, "Molten Core", { 0.91, 0.54, 0 }, true)

    elseif T.Spec == "DESTRUCTION" then

      ChopsUI.modules.needtoknow.PlayerBuff(6, "Improved Soul Fire", { 0.91, 0.54, 0 }, true)

    end

  elseif T.myclass == "WARRIOR" then

    if T.Spec == "ARMS" then
      ChopsUI.modules.needtoknow.PlayerBuff(1, "Recklessness", { 0.91, 0.54, 0 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(2, "Golem's Strength", { 0.86, 0.67, 0 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(3, "Deadly Calm", { 0.41, 1, 0 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(4, "Executioner", { 0.6, 0.01, 0 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(5, "Inner Rage", { 0.91, 0.91, 0.91 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(6, "Sweeping Strikes", { 0.14, 0.6, 0.2 }, true)
    elseif T.Spec == "PROTECTION" then
      ChopsUI.modules.needtoknow.PlayerBuff(1, "Shield Wall", { 0.19, 0.71, 0.78 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(2, "Last Stand", { 0.75, 0.58, 0 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(3, "Earthen Armor", { 0.25, 0.25, 0.25 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(4, "Shield Block, Spell Reflection", { 0.91, 0.91, 0.91 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(5, "Hold the Line", { 0.14, 0.6, 0.2 }, true)
      ChopsUI.modules.needtoknow.PlayerBuff(6, "Thunderstruck", { 0.6, 0, 0.05 }, true)
    end

  end
  
end

-- Configure the NeedToKnow target debuff bars
function ChopsUI.modules.needtoknow.ConfigureTargetDebuffs()

  for i = 1, NeedToKnow.ProfileSettings.Groups[2].NumberBars do
    NeedToKnow.ProfileSettings.Groups[2].Bars[i].Enabled = false
  end

  if T.myclass == "DEATHKNIGHT" then

    ChopsUI.modules.needtoknow.TargetDebuff(5, "Blood Plague", { 0.6, 0, 0.07 }, true)
    ChopsUI.modules.needtoknow.TargetDebuff(6, "Frost Fever", { 0.07, 0.65, 0.81 }, true)

    if T.Spec == "BLOOD" then
      ChopsUI.modules.needtoknow.TargetDebuff(4, "Vindication, Demoralizing Roar, Curse of Weakness, Demoralizing Shout, Scarlet Fever", { 0.19, 0.71, 0.78 }, false)
    elseif T.Spec == "FROST" then
      ChopsUI.modules.needtoknow.TargetDebuff(4, "Hungering Cold", { 0, 0.6, 1 }, true)
    elseif T.Spec == "UNHOLY" then
      ChopsUI.modules.needtoknow.TargetDebuff(3, "Unholy Blight", { 0, 0.51, 0.14 }, true)
      ChopsUI.modules.needtoknow.TargetDebuff(4, "Ebon Plague", { 0.6, 0, 0.54 }, true)
    end

  elseif T.myclass == "DRUID" then

    if T.Spec == "BALANCE" then

      ChopsUI.modules.needtoknow.TargetDebuff(1, "Insect Swarm", { 0.03, 0.72, 0.05 }, true)
      ChopsUI.modules.needtoknow.TargetDebuff(2, "Moonfire, Sunfire", { 0.82, 0.8, 0.8 }, true)

    elseif T.Spec == "FERALCOMBAT" then
      if T.Role == "Melee" then
        ChopsUI.modules.needtoknow.TargetDebuff(2, "Pounce", { 0, 0.44, 0.6 }, true)
        ChopsUI.modules.needtoknow.TargetDebuff(3, "Rip", { 0.89, 0.38, 0 }, true)
        ChopsUI.modules.needtoknow.TargetDebuff(4, "Rake", { 0.6, 0.02, 0 }, true)
        ChopsUI.modules.needtoknow.TargetDebuff(5, "Faerie Fire, Expose Armor, Sunder Armor", { 0.6, 0, 0.55 }, false)
        ChopsUI.modules.needtoknow.TargetDebuff(6, "Mangle, Trauma", { 0.6, 0.34, 0 }, false)
      elseif T.Role == "Tank" then
        ChopsUI.modules.needtoknow.TargetDebuff(1, "Thrash", { 0.04, 0.29, 0.6 }, true)
        ChopsUI.modules.needtoknow.TargetDebuff(2, "Mangle, Trauma", { 0.6, 0.34, 0 }, false)
        ChopsUI.modules.needtoknow.TargetDebuff(3, "Lacerate", { 0.6, 0.01, 0 }, true)
        ChopsUI.modules.needtoknow.TargetDebuff(4, "Faerie Fire, Sunder Armor, Expose Armor", { 0.75, 0.58, 0 }, false)
        ChopsUI.modules.needtoknow.TargetDebuff(5, "Demoralizing Roar, Demoralizing Shout, Vindication, Curse of Weakness, Scarlet Fever", { 0.19, 0.71, 0.78 }, false)
        ChopsUI.modules.needtoknow.TargetDebuff(6, "Infected Wounds, Thunder Clap, Frost Fever, Judgements of the Just", { 0.28, 0.79, 0.30 }, false)
      end
    end

  elseif T.myclass == "HUNTER" then

    ChopsUI.modules.needtoknow.TargetDebuff(5, "Hunter's Mark, Marked for Death", { 0.6, 0.01, 0 }, true)
    ChopsUI.modules.needtoknow.TargetDebuff(6, "Serpent Sting", { 0.28, 0.79, 0.30 }, true)

    if T.Spec == "MARKSMANSHIP" then
      ChopsUI.modules.needtoknow.TargetDebuff(4, "Piercing Shots", { 0, 0.10, 0.96 }, true)
    elseif T.Spec == "SURVIVAL" then
      ChopsUI.modules.needtoknow.TargetDebuff(3, "Black Arrow", { 0, 0.10, 0.96 }, true)
      ChopsUI.modules.needtoknow.TargetDebuff(4, "Explosive Shot", { 1, 0.57, 0 }, true)
    end

  elseif T.myclass == "MAGE" then

    if T.Spec == "ARCANE" then
    elseif T.Spec == "FIRE" then
      ChopsUI.modules.needtoknow.TargetDebuff(2, "Combustion", { 0.68, 0, 0.01 }, true)
      ChopsUI.modules.needtoknow.TargetDebuff(3, "Pyroblast!", { 1, 0.76, 0 }, true)
      ChopsUI.modules.needtoknow.TargetDebuff(4, "Ignite", { 1, 0.18, 0 }, true)
      ChopsUI.modules.needtoknow.TargetDebuff(5, "Critical Mass", { 0, 0.55, 0.69 }, true)
      ChopsUI.modules.needtoknow.TargetDebuff(6, "Living Bomb", { 1, 0.57, 0 }, true)
    elseif T.Spec == "FROST" then
      ChopsUI.modules.needtoknow.TargetDebuff(2, "Frost Nova", { 0, 0.52, 0.88 }, true)
      ChopsUI.modules.needtoknow.TargetDebuff(3, "Cone of Cold", { 0, 0.73, 0.67 }, true)
      ChopsUI.modules.needtoknow.TargetDebuff(4, "Deep Freeze", { 0, 0.29, 0.6 }, true)
      ChopsUI.modules.needtoknow.TargetDebuff(5, "Frostfire Bolt", { 0.76, 0.46, 0 }, true)
      ChopsUI.modules.needtoknow.TargetDebuff(6, "Frostbolt", { 0, 0.45, 0.6 }, true)
    end

  elseif T.myclass == "PALADIN" then

    if T.Spec == "HOLY" then
      ChopsUI.modules.needtoknow.TargetDebuff(1, "Hammer of Justice", { 0, 0.57, 0.6 }, true)
    elseif T.Spec == "PROTECTION" then
      ChopsUI.modules.needtoknow.TargetDebuff(3, "Hammer of Justice", { 0, 0.57, 0.6 }, true)
      ChopsUI.modules.needtoknow.TargetDebuff(4, "Censure", { 1, 0.98, 0 }, true)
      ChopsUI.modules.needtoknow.TargetDebuff(5, "Vindication, Demoralizing Roar, Curse of Weakness, Demoralizing Shout, Scarlet Fever", { 0.19, 0.71, 0.78 }, false)
      ChopsUI.modules.needtoknow.TargetDebuff(6, "Judgements of the Just, Frost Fever, Infected Wounds, Thunder Clap", { 0.28, 0.79, 0.30 }, false)
    elseif T.Spec == "RETRIBUTION" then
      ChopsUI.modules.needtoknow.TargetDebuff(4, "Hammer of Justice", { 0, 0.57, 0.6 }, true)
      ChopsUI.modules.needtoknow.TargetDebuff(5, "Repentence", { 0.04, 0.29, 0.6 }, true)
      ChopsUI.modules.needtoknow.TargetDebuff(6, "Censure", { 1, 0.98, 0 }, true)
    end

  elseif T.myclass == "PRIEST" then

    if T.Spec == "DISCIPLINE" then
      ChopsUI.modules.needtoknow.TargetDebuff(1, "Holy Fire", { 0.86, 0.41, 0 }, true)
    elseif T.Spec == "SHADOW" then
      ChopsUI.modules.needtoknow.TargetDebuff(1, "Vampiric Touch", { 0, 0.38, 0.6 }, true)
      ChopsUI.modules.needtoknow.TargetDebuff(2, "Shadow Word: Pain", { 0.86, 0.41, 0 }, true)
      ChopsUI.modules.needtoknow.TargetDebuff(3, "Devouring Plague", { 0.62, 0, 0.75 }, true)
      ChopsUI.modules.needtoknow.TargetDebuff(4, "Mind Flay, Mind Sear", { 0.38, 0.76, 0.81 }, true)
    end

  elseif T.myclass == "ROGUE" then

    if T.Spec == "ASSASSINATION" then
      ChopsUI.modules.needtoknow.TargetDebuff(2, "Cheap Shot, Kidney Shot", { 1, 0.94, 0 }, true)
      ChopsUI.modules.needtoknow.TargetDebuff(3, "Garrote", { 0.92, 0.39, 0 }, true)
      ChopsUI.modules.needtoknow.TargetDebuff(4, "Vendetta", { 0.64, 1, 0.94 }, true)
      ChopsUI.modules.needtoknow.TargetDebuff(5, "Rupture", { 0.68, 0.04, 0 }, true)
      ChopsUI.modules.needtoknow.TargetDebuff(6, "Deadly Poison", { 0.01, 0.53, 0 }, true)
    elseif T.Spec == "COMBAT" then
      ChopsUI.modules.needtoknow.TargetDebuff(2, "Cheap Shot, Kidney Shot", { 1, 0.94, 0 }, true)
      ChopsUI.modules.needtoknow.TargetDebuff(3, "Garrote", { 0.92, 0.39, 0 }, true)
      ChopsUI.modules.needtoknow.TargetDebuff(4, "Revealing Strike", { 0.64, 1, 0.94 }, true)
      ChopsUI.modules.needtoknow.TargetDebuff(5, "Rupture", { 0.68, 0.04, 0 }, true)
      ChopsUI.modules.needtoknow.TargetDebuff(6, "Deadly Poison", { 0.01, 0.53, 0 }, true)
    elseif T.Spec == "SUBTLETY" then
      ChopsUI.modules.needtoknow.TargetDebuff(3, "Find Weakness", { 0.64, 1, 0.94 }, true)
      ChopsUI.modules.needtoknow.TargetDebuff(4, "89775", { 0.92, 0.39, 0 }, true) -- Glyph of Hemorrhage debuff
      ChopsUI.modules.needtoknow.TargetDebuff(5, "Rupture", { 0.68, 0.04, 0 }, true)
      ChopsUI.modules.needtoknow.TargetDebuff(6, "Deadly Poison", { 0.01, 0.53, 0 }, true)
    end

  elseif T.myclass == "SHAMAN" then

    if T.Spec == "ELEMENTAL" then
      ChopsUI.modules.needtoknow.TargetDebuff(5, "Hex", { 0, 0.53, 0.02 }, true)
      ChopsUI.modules.needtoknow.TargetDebuff(6, "Flame Shock", { 0.91, 0.54, 0 }, true, { 1, 1, 0 }, "Lava Burst")
    elseif T.Spec == "RESTORATION" then
      ChopsUI.modules.needtoknow.TargetDebuff(6, "Flame Shock", { 0.91, 0.54, 0 }, true)
    end

  elseif T.myclass == "WARLOCK" then

    ChopsUI.modules.needtoknow.TargetDebuff(3, "Bane of Agony, Bane of Doom", { 0, 0.38, 0.01 }, true)
    ChopsUI.modules.needtoknow.TargetDebuff(4, "Shadow and Flame", { 0, 0.10, 0.96 }, true)
    ChopsUI.modules.needtoknow.TargetDebuff(5, "Corruption", { 0.74, 0, 0.06 }, true)
    ChopsUI.modules.needtoknow.TargetDebuff(6, "Curse of the Elements, Curse of Tongues", { 0.53, 0, 0.78 }, true)
    
    if T.Spec == "AFFLICTION" then

      ChopsUI.modules.needtoknow.TargetDebuff(1, "Haunt", { 0, 0.74, 1 }, true)
      ChopsUI.modules.needtoknow.TargetDebuff(2, "Unstable Affliction", { 0.47, 0.31, 0 }, true)

    elseif T.Spec == "DEMONOLOGY" then

      ChopsUI.modules.needtoknow.TargetDebuff(2, "Immolate", { 0.91, 0.54, 0 }, true)
      ChopsUI.modules.needtoknow.TargetDebuff(1, "Hand of Gul'dan", { 0.90, 0.85, 0.43 }, true)

    elseif T.Spec == "DESTRUCTION" then
      
      ChopsUI.modules.needtoknow.TargetDebuff(2, "Immolate", { 0.91, 0.54, 0 }, true)

    end

  elseif T.myclass == "WARRIOR" then

    if T.Spec == "ARMS" then
      ChopsUI.modules.needtoknow.TargetDebuff(1, "Rend", { 0.6, 0.01, 0 }, true)
      ChopsUI.modules.needtoknow.TargetDebuff(2, "Colossus Smash", { 0.75, 0.58, 0 }, true)
      ChopsUI.modules.needtoknow.TargetDebuff(3, "Deep Wounds", { 0.91, 0.54, 0 }, true)
    elseif T.Spec == "PROTECTION" then
      ChopsUI.modules.needtoknow.TargetDebuff(1, "Shockwave", { 0.04, 0.29, 0.6 }, true)
      ChopsUI.modules.needtoknow.TargetDebuff(2, "Concussion Blow", { 0.91, 0.91, 0.91 }, true)
      ChopsUI.modules.needtoknow.TargetDebuff(3, "Rend", { 0.6, 0.01, 0 }, true)
      ChopsUI.modules.needtoknow.TargetDebuff(4, "Sunder Armor, Expose Armor, Faerie Fire", { 0.75, 0.58, 0 }, false)
      ChopsUI.modules.needtoknow.TargetDebuff(5, "Demoralizing Shout, Vindication, Demoralizing Roar, Curse of Weakness, Scarlet Fever", { 0.19, 0.71, 0.78 }, false)
      ChopsUI.modules.needtoknow.TargetDebuff(6, "Thunder Clap, Frost Fever, Infected Wounds, Judgements of the Just", { 0.28, 0.79, 0.30 }, false)
    end

  end
  
end

-- Configure the NeedToKnow cooldown bars
function ChopsUI.modules.needtoknow.ConfigureCooldowns()

  for i = 1, NeedToKnow.ProfileSettings.Groups[3].NumberBars do
    NeedToKnow.ProfileSettings.Groups[3].Bars[i].Enabled = false
  end

  if T.CheckRole() == "Caster" then
    ChopsUI.modules.needtoknow.Cooldown(5, "Volcanic Destruction", { 0, 0.45, 0.6 }, 45)
    ChopsUI.modules.needtoknow.Cooldown(6, "Power Torrent", { 0.03, 0.88, 1 }, 45)
  elseif T.CheckRole() == "Melee" then
    ChopsUI.modules.needtoknow.Cooldown(6, "Tol'vir Agility, Golem's Strength", { 0, 0.45, 0.6 }, 45)
  end

  if T.myclass == "DRUID" then
    if T.Spec == "BALANCE" then
      ChopsUI.modules.needtoknow.Cooldown(4, "Force of Nature", { 0.6, 0, 0.55 })
      ChopsUI.modules.needtoknow.Cooldown(3, "Starfall", { 0.91, 0.91, 0.91 })
      ChopsUI.modules.needtoknow.Cooldown(2, "Starsurge", { 0.6, 0, 0.54 })
      ChopsUI.modules.needtoknow.Cooldown(1, "Nature's Grace", { 0.28, 0.79, 0.30 }, 60)
    end
  elseif T.myclass == "ROGUE" then
    if T.Spec == "SUBTLETY" then
      ChopsUI.modules.needtoknow.Cooldown(1, "Shadow Dance", { 0.53, 0, 0.78 })
      ChopsUI.modules.needtoknow.Cooldown(2, "Vanish", { 0.91, 0.91, 0.91 })
      ChopsUI.modules.needtoknow.Cooldown(3, "Preparation", { 0.75, 0.58, 0 })
    end
  end

end

-- Configure a NeedToKnow player buff bar
function ChopsUI.modules.needtoknow.PlayerBuff(barId, buffName, color, onlyMine, unit)

  if not unit then
    unit = "player"
  end
  colorRed, colorGreen, colorBlue = unpack(color)

  NeedToKnow.ProfileSettings.Groups[1].Bars[barId].BuffOrDebuff = "HELPFUL"
  NeedToKnow.ProfileSettings.Groups[1].Bars[barId].Enabled = true
  NeedToKnow.ProfileSettings.Groups[1].Bars[barId].AuraName = buffName
  NeedToKnow.ProfileSettings.Groups[1].Bars[barId].OnlyMine = onlyMine
  NeedToKnow.ProfileSettings.Groups[1].Bars[barId].Unit = unit
  NeedToKnow.ProfileSettings.Groups[1].Bars[barId].BarColor = {
    ["r"] = colorRed,
    ["g"] = colorGreen,
    ["b"] = colorBlue,
    ["a"] = 1
  }

end

-- Configure a NeedToKnow target debuff bar
function ChopsUI.modules.needtoknow.TargetDebuff(barId, debuffName, color, onlyMine, vctColor, vctSpell)

  colorRed, colorGreen, colorBlue = unpack(color)
  vctColorRed, vctColorGreen, vctColorBlue = nil
  if vctColor then
    vctColorRed, vctColorGreen, vctColorBlue = unpack(vctColor)
  end

  NeedToKnow.ProfileSettings.Groups[2].Bars[barId].BuffOrDebuff = "HARMFUL"
  NeedToKnow.ProfileSettings.Groups[2].Bars[barId].Enabled = true
  NeedToKnow.ProfileSettings.Groups[2].Bars[barId].AuraName = debuffName
  NeedToKnow.ProfileSettings.Groups[2].Bars[barId].OnlyMine = onlyMine
  NeedToKnow.ProfileSettings.Groups[2].Bars[barId].Unit = "target"
  NeedToKnow.ProfileSettings.Groups[2].Bars[barId].BarColor = {
    ["r"] = colorRed,
    ["g"] = colorGreen,
    ["b"] = colorBlue,
    ["a"] = 1
  }

  if vctColorRed and vctColorGreen and vctColorBlue then
    NeedToKnow.ProfileSettings.Groups[2].Bars[barId].vtc_color = {
      ["r"] = vctColorRed,
      ["g"] = vctColorGreen,
      ["b"] = vctColorBlue,
      ["a"] = 0.5
    }
  end

  if vctSpell then
    NeedToKnow.ProfileSettings.Groups[2].Bars[barId].vtc_spell = vctSpell
  end

end

-- Configure a NeedToKnow cooldown.
function ChopsUI.modules.needtoknow.Cooldown(barId, cooldownName, color, duration)

  colorRed, colorGreen, colorBlue = unpack(color)

  -- If we have a duration specified, we need to track some kind of ICD. if we
  -- don't, just track a normal spell cd.
  if duration ~= nil then
    NeedToKnow.ProfileSettings.Groups[3].Bars[barId].BuffOrDebuff = "BUFFCD"
    NeedToKnow.ProfileSettings.Groups[3].Bars[barId].buffcd_duration = duration
  else
    NeedToKnow.ProfileSettings.Groups[3].Bars[barId].BuffOrDebuff = "CASTCD"
  end
  NeedToKnow.ProfileSettings.Groups[3].Bars[barId].Enabled = true
  NeedToKnow.ProfileSettings.Groups[3].Bars[barId].AuraName = cooldownName
  NeedToKnow.ProfileSettings.Groups[3].Bars[barId].OnlyMine = true
  NeedToKnow.ProfileSettings.Groups[3].Bars[barId].Unit = "player"
  NeedToKnow.ProfileSettings.Groups[3].Bars[barId].BarColor = {
    ["r"] = colorRed,
    ["g"] = colorGreen,
    ["b"] = colorBlue,
    ["a"] = 1
  }

end

-- Reset NeedToKnow
function ChopsUI.modules.needtoknow.Reset()

  -- Reset the settings of NeedToKnow
  NeedToKnow.CharSettings["Locked"] = true

  -- Change the texture and font
  NeedToKnow.ProfileSettings["BarTexture"] = "TukuiNormalTexture"
  NeedToKnow.ProfileSettings["BarFont"] = "TukuiNormalFont"

  -- Set up the player group.
  playerGroup = CopyTable(NEEDTOKNOW.GROUP_DEFAULTS)
  playerGroup.Enabled = true
  playerGroup.NumberBars = 6
  playerGroup.Scale = 0.6666667461395264
  playerGroup.Width = 290
  playerGroup.FixedDuration = nil

  -- Set up the target group
  targetGroup = CopyTable(NEEDTOKNOW.GROUP_DEFAULTS)
  targetGroup.Enabled = true
  targetGroup.NumberBars = 6
  targetGroup.Scale = 0.6666667461395264
  targetGroup.Width = 290
  targetGroup.FixedDuration = nil

  -- Set up the cooldown group.
  cdGroup = CopyTable(NEEDTOKNOW.GROUP_DEFAULTS)
  cdGroup.Enabled = true
  cdGroup.NumberBars = 6
  cdGroup.Scale = 0.80
  cdGroup.Width = 475
  cdGroup.FixedDuration = nil
  
  -- Assign the new groups to NeedToKnow.
  NeedToKnow.ProfileSettings.Groups = {
    playerGroup,
    targetGroup,
    cdGroup
  }
  NeedToKnow.ProfileSettings.nGroups = 3

end
