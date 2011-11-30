local T, C, L = unpack(Tukui)

-- Copy the old ChatSetup function.
T.OriginalChatSetup = T.ChatSetup

-- Override the new ChatSetup function.
T.ChatSetup = function()

  -- Call the original ChatSetup function.
  T.OriginalChatSetup()

  -- Do some extra modifications to the chat setup.
   ChangeChatColor("OFFICER", 0.79, 0.57, 0) -- Change officer chat color to be more distinct from guild.

   -- This is kind of dirty, but I couldn't find any better points of entry to
   -- hook into the /resetui process.
   ChopsUI.ResetModules()

end
