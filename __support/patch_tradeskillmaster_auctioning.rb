#!/usr/bin/env ruby

def patch_bot_check

  # I don't bot, but this check is fucking annoying when you post a million
  # times a day and you get this check like 15 times in a row.
  lua = File.open(File.join('TradeSkillMaster_Auctioning', 'modules', 'post.lua'), 'r').read
  if lua =~ %r|if info ~= rNum and ShouldCheck\(\)|

    lua.gsub!(%r|if info ~= rNum and ShouldCheck\(\)|, 'if info ~= rNum and !ShouldCheck() and true == false')

    File.open(File.join('TradeSkillMaster_Auctioning', 'modules', 'post.lua'), 'w') { |f| f.puts lua }

  end
  
end

patch_bot_check
