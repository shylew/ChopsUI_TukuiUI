------------------------------------------------------------------------------
-- CONFIGURE NEEDTOKNOW
------------------------------------------------------------------------------
function ChopsuiNeedToKnowConfigure()

  -- Always set the CURRENTSPEC of NeedToKnow to 1, we handle spec changing
  -- internally.
  NeedToKnow.ExecutiveFrame_OLD_PLAYER_LOGIN = NeedToKnow.ExecutiveFrame_PLAYER_LOGIN
  NeedToKnow.ExecutiveFrame_PLAYER_LOGIN = function()
    NeedToKnow.ExecutiveFrame_OLD_PLAYER_LOGIN()
    NEEDTOKNOW.CURRENTSPEC = 1
    NeedToKnow.Update()
  end

  -- Remove the talent update event from the NeedToKnow Executive Frame
  _G["NeedToKnow_ExecutiveFrame"]:UnregisterEvent("PLAYER_TALENT_UPDATE")

  -- Override the group update function to properly attach the player and
  -- target frames to the player and target unit frame
  NeedToKnow.Old_Group_Update = NeedToKnow.Group_Update
  NeedToKnow.Group_Update = function(groupID)

    NeedToKnow.Old_Group_Update(groupID)
    local groupName = "NeedToKnow_Group" .. groupID
    local group = _G[groupName]

    if groupID == 1 then

      -- If this is group 1, attach it to the player frame
      group:ClearAllPoints()
      group:SetPoint("BOTTOMLEFT", oUF_Tukz_player, "TOPLEFT", 0, TukuiDB.Scale(150))
      
    elseif groupID == 2 then

      -- If this is group 1, attach it to the target frame
      local xOffset = NeedToKnow_Settings["Spec"][1]["Groups"][2]["Width"] * -1
      group:ClearAllPoints()
      group:SetPoint("BOTTOMRIGHT", oUF_Tukz_target, "TOPRIGHT", xOffset, TukuiDB.Scale(220))

    end

  end

  NeedToKnow.Update()

  -- Configure the NeedToKnow bars
  local eventFrame = CreateFrame("Frame")
  eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
  eventFrame:SetScript("OnEvent", function()

    -- Disable all player buffs and target debuffs
    for groupId = 1, 2 do
      for barId = 1, NEEDTOKNOW.MAXBARS do
        NeedToKnow_Settings["Spec"][1]["Groups"][groupId]["Bars"][barId]["Enabled"] = false
        NeedToKnow_Settings["Spec"][1]["Groups"][groupId]["Bars"][barId]["AuraName"] = ""
        NeedToKnow_Settings["Spec"][1]["Groups"][groupId]["Bars"][barId]["BarColor"] = {
          ["r"] = 0.6,
          ["b"] = 0.6,
          ["g"] = 0.6,
          ["a"] = 1
        }
      end
    end

    -- Set up player buffs
    ChopsuiNeedToKnowConfigurePlayerBuffs()

    -- Set up target debuffs
    ChopsuiNeedToKnowConfigureTargetDebuffs()

    -- Lock NeedToKnow
    NeedToKnow_Settings["Locked"] = true

    -- Update NeedToKnow
    NeedToKnow.Update()

    -- Disable this event
    eventFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")

  end)

end

------------------------------------------------------------------------------
-- CONFIGURE NEEDTOKNOW PLAYER BUFFS
------------------------------------------------------------------------------
function ChopsuiNeedToKnowConfigurePlayerBuffs()

  if TukuiDB.myclass == "DEATHKNIGHT" then

    if TukuiDB.myspec == "BLOOD" then
      ChopsuiNeedToKnowPlayerBuff(3, "Icebound Fortitude", 0.01, 0.56, 0.6, true)
      ChopsuiNeedToKnowPlayerBuff(4, "Vampiric Blood", 0.74, 0, 0.02, true)
      ChopsuiNeedToKnowPlayerBuff(5, "Bone Shield", 0.04, 0.46, 0.98, true)
      ChopsuiNeedToKnowPlayerBuff(6, "Blade Barrier", 0.6, 0, 0.07, true)
    elseif TukuiDB.myspec == "FROST" then
      ChopsuiNeedToKnowPlayerBuff(5, "Pillar of Frost", 0, 1, 0.91, true)
      ChopsuiNeedToKnowPlayerBuff(6, "Killing Machine", 0, 0.68, 1, true)
    elseif TukuiDB.myspec == "UNHOLY" then
      ChopsuiNeedToKnowPlayerBuff(5, "Icebound Fortitude", 0.01, 0.56, 0.6, true)
      ChopsuiNeedToKnowPlayerBuff(6, "Shadow Infusion, Dark Transformation", 0, 0.6, 0.03, true, "pet")
    end

  elseif TukuiDB.myclass == "DRUID" then

    --if TukuiDB.myspec == "FERALCOMBAT" then
    --  if TukuiDB.myrole == "DPS" then
    --    ChopsuiNeedToKnowPlayerBuff(1, "Predator's Swiftness", 0.6, 0.38, 0, true)
    --    ChopsuiNeedToKnowPlayerBuff(2, "Barkskin", 0.70, 0.68, 0, true)
    --    ChopsuiNeedToKnowPlayerBuff(3, "Survival Instincts", 0.25, 0.6, 0.45, true)
    --    ChopsuiNeedToKnowPlayerBuff(4, "Berserk", 0.71, 0, 1, true)
    --    ChopsuiNeedToKnowPlayerBuff(5, "Stampede", 0.74, 0.33, 0, true)
    --    ChopsuiNeedToKnowPlayerBuff(6, "Savage Roar", 0.92, 0.76, 0, true)
    --  end
    --end

  elseif TukuiDB.myclass == "PALADIN" then

    ChopsuiNeedToKnowPlayerBuff(1, "Divine Shield, Divine Protection", 0.78, 0, 0.06, true)
    ChopsuiNeedToKnowPlayerBuff(5, "Avenging Wrath", 0.91, 0.85, 0, true)
    ChopsuiNeedToKnowPlayerBuff(6, "Judgements of the Pure", 0.6, 0.44, 0, true)
    
    if TukuiDB.myspec == "HOLY" then
      ChopsuiNeedToKnowPlayerBuff(2, "Conviction", 0.6, 0.23, 0.09, true)
      ChopsuiNeedToKnowPlayerBuff(3, "Divine Plea", 0.74, 0.59, 0, true)
      ChopsuiNeedToKnowPlayerBuff(4, "Divine Favor", 0.86, 0.86, 0.86, true)
    elseif TukuiDB.myspec == "PROTECTION" then
      ChopsuiNeedToKnowPlayerBuff(2, "Guardian of Ancient Kings", 1, 0.30, 0, true)
      ChopsuiNeedToKnowPlayerBuff(3, "Ardent Defender", 0.6, 0.44, 0, true)
      ChopsuiNeedToKnowPlayerBuff(4, "Inquisition", 1, 0.60, 0, true)
      ChopsuiNeedToKnowPlayerBuff(6, "Sacred Duty", 0, 0.41, 0.6, true)
    elseif TukuiDB.myspec == "RETRIBUTION" then
      ChopsuiNeedToKnowPlayerBuff(2, "Inquisition", 1, 0.60, 0, true)
      ChopsuiNeedToKnowPlayerBuff(3, "The Art of War", 1, 0.94, 0, true)
      ChopsuiNeedToKnowPlayerBuff(4, "Hand of Light", 0.87, 0, 1,true)
    end

  elseif TukuiDB.myclass == "PRIEST" then

    if TukuiDB.myspec == "DISCIPLINE" then
      ChopsuiNeedToKnowPlayerBuff(1, "Borrowed Time", 0.96, 0.65, 0, true)
      ChopsuiNeedToKnowPlayerBuff(2, "Evangelism", 0.91, 0.88, 0.96, true)
      ChopsuiNeedToKnowPlayerBuff(3, "Archangel", 1, 0.86, 0.01, true)
      ChopsuiNeedToKnowPlayerBuff(4, "Inner Focus", 0, 0.79, 1, true)
      ChopsuiNeedToKnowPlayerBuff(5, "Fade", 0, 0.37, 1, true)
    elseif TukuiDB.myspec == "SHADOW" then
      ChopsuiNeedToKnowPlayerBuff(1, "Shadow Orb", 0.5, 0.08, 0.57, true)
      ChopsuiNeedToKnowPlayerBuff(2, "Dark Evangelism", 0.45, 0.43, 0.48, true)
      ChopsuiNeedToKnowPlayerBuff(3, "Dark Archangel", 1, 0.25, 0, true)
      ChopsuiNeedToKnowPlayerBuff(4, "Dispersion", 0.02, 0.64, 0.13, true)
      ChopsuiNeedToKnowPlayerBuff(5, "Fade", 0, 0.37, 1, true)
    end

  elseif TukuiDB.myclass == "SHAMAN" then

    if TukuiDB.myspec == "RESTORATION" then
      ChopsuiNeedToKnowPlayerBuff(2, "Spiritwalker's Grace", 0.41, 1, 0, true)
      ChopsuiNeedToKnowPlayerBuff(3, "Stoneclaw Totem", 0.6, 0.10, 0, true)
      ChopsuiNeedToKnowPlayerBuff(4, "Tidal Waves", 0.03, 0.88, 1, true)
      ChopsuiNeedToKnowPlayerBuff(5, "Water Shield", 0, 0.60, 0.74, true)
      ChopsuiNeedToKnowPlayerBuff(6, "Earthliving", 0, 0.81, 0.4, true, "mhand")
    end

  elseif TukuiDB.myclass == "WARLOCK" then

  elseif TukuiDB.myclass == "WARRIOR" then

    if TukuiDB.myspec == "PROTECTION" then
      ChopsuiNeedToKnowPlayerBuff(1, "Shield Wall", 0.19, 0.71, 0.78, true)
      ChopsuiNeedToKnowPlayerBuff(2, "Last Stand", 0.75, 0.58, 0, true)
      ChopsuiNeedToKnowPlayerBuff(3, "Earthen Armor", 0.25, 0.25, 0.25, true)
      ChopsuiNeedToKnowPlayerBuff(4, "Shield Block, Spell Reflection", 0.91, 0.91, 0.91, true)
      ChopsuiNeedToKnowPlayerBuff(5, "Hold the Line", 0.14, 0.6, 0.2, true)
      ChopsuiNeedToKnowPlayerBuff(6, "Thunderstruck", 0.6, 0, 0.05, true)
    end

  end

end

------------------------------------------------------------------------------
-- CONFIGURE NEEDTOKNOW TARGET DEBUFFS
------------------------------------------------------------------------------
function ChopsuiNeedToKnowConfigureTargetDebuffs()

  if TukuiDB.myclass == "DEATHKNIGHT" then

    ChopsuiNeedToKnowTargetDebuff(5, "Blood Plague", 0.6, 0, 0.07, true)
    ChopsuiNeedToKnowTargetDebuff(6, "Frost Fever", 0.07, 0.65, 0.81, true)

    if TukuiDB.myspec == "BLOOD" then
      ChopsuiNeedToKnowTargetDebuff(4, "Vindication, Demoralizing Roar, Curse of Weakness, Demoralizing Shout, Scarlet Fever", 0.19, 0.71, 0.78, false)
    elseif TukuiDB.myspec == "FROST" then
      ChopsuiNeedToKnowTargetDebuff(4, "Hungering Cold", 0, 0.6, 1, true)
    elseif TukuiDB.myspec == "UNHOLY" then
      ChopsuiNeedToKnowTargetDebuff(3, "Unholy Blight", 0, 0.51, 0.14, true)
      ChopsuiNeedToKnowTargetDebuff(4, "Ebon Plague", 0.6, 0, 0.54, true)
    end

  elseif TukuiDB.myclass == "DRUID" then

    --if TukuiDB.myspec == "FERALCOMBAT" then
    --  if TukuiDB.myrole == "DPS" then
    --    ChopsuiNeedToKnowTargetDebuff(2, "Pounce", 0, 0.44, 0.6, true)
    --    ChopsuiNeedToKnowTargetDebuff(3, "Rip", 0.89, 0.38, 0, true)
    --    ChopsuiNeedToKnowTargetDebuff(4, "Rake", 0.6, 0.02, 0, true)
    --    ChopsuiNeedToKnowTargetDebuff(5, "Faerie Fire, Expose Armor, Sunder Armor", 0.6, 0, 0.55, false)
    --    ChopsuiNeedToKnowTargetDebuff(6, "Mangle, Trauma", 0.6, 0.34, 0, false)
    --  end
    --end

  elseif TukuiDB.myclass == "PALADIN" then

    if TukuiDB.myspec == "HOLY" then
      ChopsuiNeedToKnowTargetDebuff(1, "Hammer of Justice", 0, 0.57, 0.6, true)
    elseif TukuiDB.myspec == "PROTECTION" then
      ChopsuiNeedToKnowTargetDebuff(3, "Hammer of Justice", 0, 0.57, 0.6, true)
      ChopsuiNeedToKnowTargetDebuff(4, "Censure", 1, 0.98, 0, true)
      ChopsuiNeedToKnowTargetDebuff(5, "Vindication, Demoralizing Roar, Curse of Weakness, Demoralizing Shout, Scarlet Fever", 0.19, 0.71, 0.78, false)
      ChopsuiNeedToKnowTargetDebuff(6, "Frost Fever, Infected Wounds, Judgements of the Just, Thunder Clap", 0.28, 0.79, 0.30, false)
    elseif TukuiDB.myspec == "RETRIBUTION" then
      ChopsuiNeedToKnowTargetDebuff(4, "Hammer of Justice", 0, 0.57, 0.6, true)
      ChopsuiNeedToKnowTargetDebuff(5, "Repentence", 0.04, 0.29, 0.6, true)
      ChopsuiNeedToKnowTargetDebuff(6, "Censure", 1, 0.98, 0, true)
    end

  elseif TukuiDB.myclass == "PRIEST" then

    if TukuiDB.myspec == "SHADOW" then
      ChopsuiNeedToKnowTargetDebuff(1, "Vampiric Touch", 0, 0.38, 0.6, true)
      ChopsuiNeedToKnowTargetDebuff(2, "Shadow Word: Pain", 0.86, 0.41, 0, true)
      ChopsuiNeedToKnowTargetDebuff(3, "Devouring Plague", 0.62, 0, 0.75, true)
      ChopsuiNeedToKnowTargetDebuff(4, "Mind Flay, Mind Sear", 0.38, 0.76, 0.81, true)
    end

  elseif TukuiDB.myclass == "SHAMAN" then

    if TukuiDB.myspec == "ELEMENTAL" then
      ChopsuiNeedToKnowTargetDebuff(6, "Flame Shock", 0.91, 0.54, 0, true)
    elseif TukuiDB.myspec == "RESTORATION" then
      ChopsuiNeedToKnowTargetDebuff(6, "Flame Shock", 0.91, 0.54, 0, true)
    end

  elseif TukuiDB.myclass == "WARLOCK" then

    if TukuiDB.myspec == "AFFLICTION" then
      ChopsuiNeedToKnowTargetDebuff(1, "Haunt", 0, 0.74, 1, true)
      ChopsuiNeedToKnowTargetDebuff(2, "Unstable Affliction", 0.47, 0.31, 0, true)
      ChopsuiNeedToKnowTargetDebuff(3, "Bane of Agony", 0.79, 0.52, 0, true)
      ChopsuiNeedToKnowTargetDebuff(4, "Shadow and Flame", 0, 0.10, 0.96, true)
      ChopsuiNeedToKnowTargetDebuff(5, "Corruption", 0.74, 0, 0.06, true)
      ChopsuiNeedToKnowTargetDebuff(6, "Curse of the Elements", 0.53, 0, 0.78, true)
    end

  elseif TukuiDB.myclass == "WARRIOR" then

    if TukuiDB.myspec == "PROTECTION" then
      ChopsuiNeedToKnowTargetDebuff(1, "Shockwave", 0.04, 0.29, 0.6, true)
      ChopsuiNeedToKnowTargetDebuff(2, "Concussion Blow", 0.91, 0.91, 0.91, true)
      ChopsuiNeedToKnowTargetDebuff(3, "Rend", 0.6, 0.01, 0, true)
      ChopsuiNeedToKnowTargetDebuff(4, "Expose Armor, Sunder Armor, Faerie Fire", 0.75, 0.58, 0, false)
      ChopsuiNeedToKnowTargetDebuff(5, "Vindication, Demoralizing Roar, Curse of Weakness, Demoralizing Shout, Scarlet Fever", 0.19, 0.71, 0.78, false)
      ChopsuiNeedToKnowTargetDebuff(6, "Frost Fever, Infected Wounds, Judgements of the Just, Thunder Clap", 0.28, 0.79, 0.30, false)
    end

  end

end

------------------------------------------------------------------------------
-- SET A NEEDTOKNOW PLAYER BUFF
------------------------------------------------------------------------------
function ChopsuiNeedToKnowPlayerBuff(barID, buffName, red, green, blue, onlyMine, unit)

  if not unit then
    unit = "player"
  end

  NeedToKnow_Settings["Spec"][1]["Groups"][1]["Bars"][barID]["BuffOrDebuff"] = "HELPFUL"
  NeedToKnow_Settings["Spec"][1]["Groups"][1]["Bars"][barID]["Enabled"] = true
  NeedToKnow_Settings["Spec"][1]["Groups"][1]["Bars"][barID]["AuraName"] = buffName
  NeedToKnow_Settings["Spec"][1]["Groups"][1]["Bars"][barID]["OnlyMine"] = onlyMine
  NeedToKnow_Settings["Spec"][1]["Groups"][1]["Bars"][barID]["Unit"] = unit
  NeedToKnow_Settings["Spec"][1]["Groups"][1]["Bars"][barID]["BarColor"] = {
    ["r"] = red,
    ["g"] = green,
    ["b"] = blue,
    ["a"] = 1
  }

end

------------------------------------------------------------------------------
-- SET A NEEDTOKNOW TARGET DEBUFF
------------------------------------------------------------------------------
function ChopsuiNeedToKnowTargetDebuff(barID, debuffName, red, green, blue)

  NeedToKnow_Settings["Spec"][1]["Groups"][2]["Bars"][barID]["BuffOrDebuff"] = "HARMFUL"
  NeedToKnow_Settings["Spec"][1]["Groups"][2]["Bars"][barID]["Enabled"] = true
  NeedToKnow_Settings["Spec"][1]["Groups"][2]["Bars"][barID]["AuraName"] = debuffName
  NeedToKnow_Settings["Spec"][1]["Groups"][2]["Bars"][barID]["OnlyMine"] = onlyMine
  NeedToKnow_Settings["Spec"][1]["Groups"][2]["Bars"][barID]["Unit"] = "target"
  NeedToKnow_Settings["Spec"][1]["Groups"][2]["Bars"][barID]["BarColor"] = {
    ["r"] = red,
    ["g"] = green,
    ["b"] = blue,
    ["a"] = 1
  }
  
end

------------------------------------------------------------------------------
-- RESET NEEDTOKNOW
------------------------------------------------------------------------------
function ChopsuiNeedToKnowReset()

  local scale = 0.6666667461395264

  -- Reset the settings of NeedToKnow
  NeedToKnow_Settings = CopyTable(NEEDTOKNOW.DEFAULTS)

  -- Change the texture and font
  NeedToKnow_Settings["BarTexture"] = "TukTex"
  NeedToKnow_Settings["BarFont"] = "Interface\\Addons\\Tukui\\media\\fonts\\normal_font.ttf"

  -- Change the player bar look&feel
  NeedToKnow_Settings["Spec"][1]["Groups"][1]["Enabled"] = true
  NeedToKnow_Settings["Spec"][1]["Groups"][1]["NumberBars"] = 6
  NeedToKnow_Settings["Spec"][1]["Groups"][1]["Scale"] = scale
  NeedToKnow_Settings["Spec"][1]["Groups"][1]["Width"] = 290

  -- Change the target bar look&feel
  NeedToKnow_Settings["Spec"][1]["Groups"][2]["Enabled"] = true
  NeedToKnow_Settings["Spec"][1]["Groups"][2]["NumberBars"] = 6
  NeedToKnow_Settings["Spec"][1]["Groups"][2]["Scale"] = scale
  NeedToKnow_Settings["Spec"][1]["Groups"][2]["Width"] = 290

end
