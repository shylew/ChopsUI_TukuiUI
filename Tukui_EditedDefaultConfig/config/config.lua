local C = {}

-- Override TukUI general settings.
C["general"] = {
  ["autoscale"] = false, -- Disable auto scaling.
  ["uiscale"] = 0.60, -- Lower the UI scale a bit.
  ["overridelowtohigh"] = true, -- Always use high resolution UI, regardless of screen resolution.
  ["bordercolor"] = { .36, .36, .36 }, -- Use a brighter border color than the default UI.
  ["blizzardreskin"] = false -- Don't reskin Blizzard frames.
}

-- Override TukUI unit frame settings.
C["unitframes"] = {
  ["cbicons"] = false, -- Disable cast bar icons.
  ["totdebuffs"] = true, -- Enable target-of-target debuffs.
  ["showtotalhpmp"] = true, -- Show total HP/MP on unit frames.
  ["maintank"] = true, -- Show main tank frames.
  ["onlyselfdebuffs"] = true, -- Only show own debuffs on target.
  ["weakenedsoulbar"] = false, -- Disable the Weakened Soul bar.
  ["raid"] = false
}

-- Override TukUI aura settings.
C["auras"] = {
  ["flash"] = true -- Flash warning for buff with time < 30 seconds.
}

-- Override TukUI bag settings.
C["bags"] = {
  ["enable"] = false -- Disable the TukUI bags.
}

-- Override TukUI loot settings.
C["loot"] = {
  ["autogreed"] = false -- Disable auto-greed/auto-disenchant.
}

-- Override TukUI chat settings.
--C["chat"] = {
--  ["background"] = false -- Use background panels behind chat frames.
--}

-- Override TukUI nameplate settings.
C["nameplate"] = {
  ["showhealth"] = true, -- Show health in name plates.
  ["enhancethreat"] = true -- Use threat-enhanced name plates.
}

-- Override TukUI invite settings.
C["invite"] = {
  ["autoaccept"] = false -- Disable auto-accepting group invites.
}

-- Override TukUI error settings.
C["error"] = {
  ["enable"] = false -- Disable the error blocker.
}

-- Override TukUI font settings.
C["media"] = {
  ["dmgfont"] = [=[Interface\Addons\Tukui\medias\fonts\normal_font.ttf]=] -- Change the combat text font.
}

-- Override TukUI data text settings.
C["datatext"] = {
  ["bags"] = 12, -- Show bag status in the left part of the second data text container on the right.
  ["wowtime"] = 13, -- Show the current time in the right part of the second data text container on the right.
}

-- Make the configuration changes public.
TukuiEditedDefaultConfig = C
