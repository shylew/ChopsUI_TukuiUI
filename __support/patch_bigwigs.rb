#!/usr/bin/env ruby

def patch_loader
  
  lua = File.open(File.join('BigWigs', 'Loader.lua'), 'r').read

  unless lua =~ /function BigWigs_LoadAndEnableCore/

    # Add ChopsUI external loader code
    lua << "\n-- ChopsUI hack to allow external initialization of BigWigs\r\n"
    lua << "function BigWigs_LoadAndEnableCore()\r\n"
    lua << "  loadAndEnableCore()\r\n"
    lua << "end\r\n"

    File.open(File.join('BigWigs', 'Loader.lua'), 'w') { |f| f.puts lua }

  end

end

def patch_bars_plugin

  lua = File.open(File.join('BigWigs_Plugins', 'Bars.lua'), 'r').read

  unless lua =~ /ChopsUI\.modules\.bigwigs\.RepositionFrame/

    # Add a call to ChopsUI to reposition the frames during initizliation
    lua.gsub!(/display\:RefixPosition\(\)/, "display:RefixPosition()\r\n  ChopsUI.modules.bigwigs.RepositionFrame(frameName)")

    File.open(File.join('BigWigs_Plugins', 'Bars.lua'), 'w') { |f| f.puts lua }

  end

end

def patch_messages_plugin

  lua = File.open(File.join('BigWigs_Plugins', 'Messages.lua'), 'r').read

  unless lua =~ /ChopsUI\.modules\.bigwigs\.RepositionFrame/

    # Add a call to ChopsUI to reposition the frames during initizliation
    lua.gsub!(/display\:RefixPosition\(\)/, "display:RefixPosition()\r\n  ChopsUI.modules.bigwigs.RepositionFrame(frameName)")

    File.open(File.join('BigWigs_Plugins', 'Messages.lua'), 'w') { |f| f.puts lua }

  end

end

patch_loader
patch_bars_plugin
patch_messages_plugin
