#!/usr/bin/env ruby

def patch_automail

  lua = File.open(File.join('TradeSkillMaster_Mailing', 'automail.lua'), 'r').read
  if lua =~ /delay\.doneTimer = 2/

    lua.gsub!(/delay\.doneTimer = 2/, 'delay.doneTimer = 5')
    
    File.open(File.join('TradeSkillMaster_Mailing', 'automail.lua'), 'w') { |f| f.puts lua }

  end

end

patch_automail
