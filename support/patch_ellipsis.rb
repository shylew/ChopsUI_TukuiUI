#!/usr/bin/env ruby

def patch_class_data

  lua = File.open(File.join('Ellipsis', 'ClassData.lua'), 'r').read

  lua_replacement = "local aoeSpells = {}\r\n"
  lua_replacement << "local uniqueSpells = {}\r\n"
  lua_replacement << "local cooldownGroups = {}\r\n"
  lua_replacement << "local totemGroups = {}\r\n"
  lua_replacement << "function Ellipsis:DefineClassSpells"

  lua.gsub!(/(.*?)local aoeSpells.*?function Ellipsis\:DefineClassSpells(.*)/, "$1#{lua_replacement}$2")

  # File.open(File.join('Ellipsis', 'ClassData.lua'), 'w') { |f| f.puts lua }
  puts lua
  
end

patch_class_data
