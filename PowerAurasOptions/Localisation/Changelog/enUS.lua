-- Lock down local environment. Set function environment to the localization
-- table.
local PowerAuras = _G["PowerAuras"];
setfenv(1, PowerAuras.L);

-- Ensure current locale matches one on file.
-- if(GetLocale() != "enUS") then return; end

-- Changelog data texts, update these whenever we do a new release.
ChangelogHelpIcon1  = [[Interface\HelpFrame\HelpIcon-CharacterStuck]];
ChangelogHelpTitle1 = "This is an beta-quality release."
ChangelogHelpText1  = "Expect bugs. Nothing is set in stone. What you see is not necessarily even close to being complete. |cFFFF8000Read the Release Notes on the next page carefully.|r"

ChangelogHelpIcon2  = [[Interface\PaperDollInfoFrame\Character-Plus]];
ChangelogHelpTitle2 = "Where next? What's new?"
ChangelogHelpText2  = "You'll find the release notes on the next page, click the \"Next\" button below when you're ready to go.";

ChangelogHelpIcon3  = [[Interface\HelpFrame\ReportLagIcon-Chat]];
ChangelogHelpTitle3 = "Feedback is appreciated!";
ChangelogHelpText3  = "Good or bad, we want the feedback so that we can improve the addon. Post any feedback in a comment on Curse or WoWInterface.";

-- Add items for notes below, the frame will pick them up automatically.
ChangelogReleaseNotesTitle = "Known Issues";
ChangelogReleaseNotes1  = "Copying and moving of Auras/Displays is planned, but not currently implemented.";
ChangelogReleaseNotes2  = "Importing and exporting of Auras/Displays is planned, but not currently implemented.";
ChangelogReleaseNotes3  = "Several trigger types (Equipment and Spell Alert) have been temporarily disabled. They'll be re-enabled soon.";