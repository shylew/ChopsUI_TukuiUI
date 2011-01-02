------------------------------------------------------------------------------
-- CONFIGURE AUDITOR2
------------------------------------------------------------------------------
function ChopsuiAuditorConfigure()
end

------------------------------------------------------------------------------
-- RESET AUDITOR2
------------------------------------------------------------------------------
function ChopsuiAuditorReset()

  -- Set cash format to "Graphical" to avoid eating up too much space in the info panel
  AuditorBroker.db.profile.cashFormat.Bar = "Graphical"
  
end
