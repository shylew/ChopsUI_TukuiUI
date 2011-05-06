local T, C, L = unpack(select(2, ...)) -- Import: T - functions, constants, variables; C - config; L - locales
assert(NRunDB_Char, "ChopsUI NugRunning extension failed to load, make sure NugRunning is enabled")

function ChopsuiNugRunningReset()

  local profile = UnitName("player") .. "@" .. GetRealmName()

  ---- Reset the character profile
  if not NRunDB_Global["charspec"] then
    NRunDB_Global["charspec"] = {}
  end
  NRunDB_Global["charspec"][profile] = {}

  ---- Anchor the frame
  NRunDB_Char["anchor"] = {
    ["parent"] = "TukuiChatBackgroundRight",
    ["x"] = -203,
    ["y"] = 0,
    ["point"] = "BOTTOMRIGHT",
    ["to"] = "TOPLEFT",
  }
  NRunDB_Char["width"] = 193
  NRunDB_Char["cooldownsEnabled"] = false

end
