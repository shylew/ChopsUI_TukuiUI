local T, C, L = unpack(Tukui)
ChopsUI.RegisterModule("movie_frame_disabler")

-- In OSX, the cinematics in Dragon Soul tend to crash the game; especially the
-- one after Ultraxion. This is a hack borrowed from CinematicSkip to completely
-- disable cinematics as a temporary workaround.
--
-- TODO: Remove this module when cinematic playback on OSX is fixed.

--local oldMovieEventHandler = MovieFrame:GetScript("OnEvent")
--MovieFrame:SetScript("OnEvent", function(self, event, movieId, ...)
--  if event == "PLAY_MOVIE" then
--    print("GOT EVENT")
--    -- You still have to call OnMovieFinished, even if you never actually told
--    -- the movie frame to start the movie, otherwise you will end up in a weird
--    -- state (input stops working)
--    MovieFrame_OnMovieFinished(MovieFrame)
--    return
--  else
--    -- Other event.
--    return oldMovieEventHandler and oldMovieEventHandler(self, event, movieId, ...)
--  end
--end)
--
--print("Movie frame disabler installed")

-- Cancel cinematics after they start.
local f = CreateFrame("frame")
f:RegisterEvent("CINEMATIC_START")
f:SetScript("OnEvent", function(_, e)
  if e == "CINEMATIC_START" then
    CinematicFrame_CancelCinematic()
  end
end)

-- Hook movies and stop them before they get called
local PlayMovie_hook = MovieFrame_PlayMovie
MovieFrame_PlayMovie = function(...)
  GameMovieFinished()
end

