local T, C, L = unpack(Tukui)

ChopsUI = {
  ["modules"] = {}
}

-- Register a ChopsUI module.
ChopsUI.RegisterModule = function(name, dependency)

  assert(dependency, "ChopsUI " .. name .. " module failed to load, make sure all dependencies are enabled.")

  ChopsUI["modules"][name] = {
    ["Reset"] = function() end
  }

end

-- Reset all ChopsUI modules.
ChopsUI.ResetModules = function()
  for name, _ in pairs(ChopsUI.modules) do
    ChopsUI.modules[name].Reset()
  end
end
