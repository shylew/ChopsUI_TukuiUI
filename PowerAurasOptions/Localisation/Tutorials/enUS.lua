-- Lock down local environment. Set function environment to the localization
-- table.
local PowerAuras = _G["PowerAuras"];
setfenv(1, PowerAuras.L);

-- Ensure current locale matches one on file.
-- if(GetLocale() != "enUS") then return; end

Tutorials_1_Name = "Displays";
Tutorials_1_Desc = "These tutorials will teach you the basics of creating, editing and linking displays.";

Tutorials_1_1_Name = "Creating a Texture";
Tutorials_1_1_Desc = "This tutorial covers how to create a display. The created display will be a texture, and the follow-up tutorials will cover how to configure it.";

Tutorials_1_1_1_Name = "Displays";
Tutorials_1_1_1_Desc = "Click the Displays tab.";
Tutorials_1_1_2_Name = "Create Display";
Tutorials_1_1_2_Desc = "Click the Create button, pictured to the left, and select 'Texture' from the dropdown.";
Tutorials_1_1_3_Name = "Select Display";
Tutorials_1_1_3_Desc = "Select your newly created texture display in the grid on the left to complete the tutorial.";

Tutorials_1_2_Name = "Styling the Texture";
Tutorials_1_2_Desc = "This tutorial expands upon the previous one by covering the various controls available for changing how our created texture looks.";

Tutorials_1_2_1_Name = "Select Display";
Tutorials_1_2_1_Desc = "Select the texture display you wish to configure.";
Tutorials_1_2_2_Name = "Style";
Tutorials_1_2_2_Desc = "This is a list of all the editor categories for this particular display. Click the 'Style' category.";
Tutorials_1_2_3_Name = "Change Texture";
Tutorials_1_2_3_Desc = "Let's start by changing what texture is used. This editbox can be used for specifying a custom texture, or you can click the button here to open the texture picking dialog. Open the dialog now.";
Tutorials_1_2_4_Name = "Texture Dialog";
Tutorials_1_2_4_Desc = "This is a grid containing all of the textures that we could find. You can select one to preview it on the left, or filter the shown ones via the dropdown menu at the top. Select a texture that you like and click 'Accept' at the bottom.";
Tutorials_1_2_5_Name = "Additional Options";
Tutorials_1_2_5_Desc = "There are a lot of things you can do to alter how the texture looks, for example you can change the colour, rotate it or flip the texture. Make changes to three of these settings to finish the tutorial.";

Tutorials_1_3_Name = "Positioning [INCOMPLETE]";
Tutorials_1_3_Desc = "This tutorial covers how to position a display on the screen.";

Tutorials_1_3_1_Name = "Select Display";
Tutorials_1_3_1_Desc = "Select the texture display you wish to configure.";
Tutorials_1_3_2_Name = "Layout and Positioning";
Tutorials_1_3_2_Desc = "Click the 'Layout and Positioning' category.";
Tutorials_1_3_3_Name = "Positioning";
Tutorials_1_3_3_Desc = "These two editboxes control the X and Y co-ordinates for your display. Positive X values will move the display toward the right, and positive Y values will move the display down. Alter these co-ordinates to continue the tutorial.";
Tutorials_1_3_4_Name = "Anchors";
Tutorials_1_3_4_Desc = "Points are used for positioning the display. They are either a corner, side or the center of the display. The anchor point is the point that is attached to the relative point. Change the anchor point to 'Top' to continue.";
Tutorials_1_3_5_Name = "Relative Anchor";
Tutorials_1_3_5_Desc = "The relative anchor point is where the previous anchor point is attached to, so if the anchor is set to 'Top' and this is set to 'Bottom', then the top of the display will be attached to the bottom of the parent, which will be covered next. Change this to 'Top' to continue.";
Tutorials_1_3_6_Name = "Parent";
Tutorials_1_3_6_Desc = "Displays can be parented to any other display, regardless of what aura it is in. By default, a display has no parent and will simply use your screen for positioning. This editbox takes a display ID number, if left empty then the display will have no parent. A parent display dialog is available by clicking this button. Click the button to continue.";
Tutorials_1_3_7_Name = "Parent Dialog";
Tutorials_1_3_7_Desc = "This is a grid containing a preview of all of your displays in the current profile. You can select a display to parent to from here. Either choose a display and click 'Accept', or click 'Cancel' to finish the tutorial."

Tutorials_1_4_Name = "Basic Animations [INCOMPLETE]";
Tutorials_1_4_Desc = "This tutorial covers how to create a basic animation for when a display is shown on the screen";

Tutorials_1_4_1_Name = "Select Display";
Tutorials_1_4_1_Desc = "Select the texture display you wish to configure.";
Tutorials_1_4_2_Name = "Animations";
Tutorials_1_4_2_Desc = "Click the 'Animations' category.";
Tutorials_1_4_3_Name = "Animation Types";
Tutorials_1_4_3_Desc = "Animations are split into two main categories, Show/Hide animations are the focus of this tutorial, Triggered animations will be covered later. Select the 'On Show' animation.";
Tutorials_1_4_4_Name = "Animation Type";
Tutorials_1_4_4_Desc = "This dropdown is for selecting the type of animation to use. The animations available in each category vary, but most are available here. Click the dropdown and select the 'Wiggle' animation to continue.";
Tutorials_1_4_5_Name = "Settings";
Tutorials_1_4_5_Desc = "There are some settings for controlling how the animation plays. All animations have a Speed setting available, but other settings will vary based upon the selected type. Change both the settings to finish the tutorial.";

Tutorials_1_5_Name = "Sound [INCOMPLETE]";
Tutorials_1_5_Desc = "This tutorial covers how to make a sound play whenever a display is shown on the screen.";
Tutorials_1_5_1_Name = "Select Display";
Tutorials_1_5_1_Desc = "Select the texture display you wish to configure.";
Tutorials_1_5_2_Name = "Sound";
Tutorials_1_5_2_Desc = "Click the 'Sound' category.";
Tutorials_1_5_3_Name = "Sound Types";
Tutorials_1_5_3_Desc = "Sounds that are linked to displays can be played when the display either shows, or is hidden. You can enable a sound by checking the 'Enable Sound' checkbox. Do so now for the 'On Show' sound to continue.";
Tutorials_1_5_4_Name = "Sound File";
Tutorials_1_5_4_Desc = "Similar to the texture option, you can use the editbox here to play a custom sound file, or click the button to open the sound picking dialog. Click the button to continue.";
Tutorials_1_5_5_Name = "Sound Dialog";
Tutorials_1_5_5_Desc = "This is a list of all the registered sound files. You can click the small button here to preview the sound file, and click the row itself to select the sound. Select a sound and click 'Accept' to continue.";
Tutorials_1_5_6_Name = "Sound Channel";
Tutorials_1_5_6_Desc = "This dropdown controls what channel the sound is played on. Different channels may have differing volumes, based upon your sound settings. Select a different channel to finish the tutorial."

Tutorials_2_Name = "Activation";
Tutorials_2_Desc = "These tutorials will teach you how to make a display show or hide in response to triggers.";

Tutorials_2_1_Name = "Basic Activation [NYI]";
Tutorials_2_1_Desc = "This tutorial will cover how to use the basic editor to make a display show whenever you gain a certain buff.";
Tutorials_2_2_Name = "Additional Triggers [NYI]";
Tutorials_2_2_Desc = "This tutorial expands upon the previous one by demonstrating the use of additional triggers within the basic editor. The end result will be a display that activates whenever you gain a buff, and are mounted at the same time.";
Tutorials_2_3_Name = "Advanced Triggers [NYI]";
Tutorials_2_3_Desc = "This tutorial will show how to use the advanced editor in order to create more complex trigger combinations.";

Tutorials_3_Name = "Advanced Displays";
Tutorials_3_Desc = "Using knowledge gained from the activation tutorials, these will cover the use of triggers with other actions, such as triggered animations or display actions.";

Tutorials_3_1_Name = "Triggered Animations [NYI]";
Tutorials_3_1_Desc = "This tutorial will cover how to create a triggered animation. We will create two animations, a 'Single' and 'Repeat' one. This will also cover the concept of animation channels.";
Tutorials_3_2_Name = "Display Actions [NYI]";
Tutorials_3_2_Desc = "This tutorial will cover the concept of display actions, what they are, what they can do and will demonstrate this by having you create a Color action.";

Tutorials_4_Name = "Sources";
Tutorials_4_Desc = "These tutorials will cover the basics of sources, and how they can interact with both displays and triggers alike. In addition, this will cover the usage of additional display types such as timers and stack counters.";

Tutorials_4_1_Name = "Basics [NYI]";
Tutorials_4_1_Desc = "This tutorial introduces the concept of sources, and has you attach one to an existing texture display in order to have the displayed texture change dynamically in response to an event.";
Tutorials_4_2_Name = "Timers [NYI]";
Tutorials_4_2_Desc = "This tutorial will teach you how to create a timer display, and the use of a source with a timer.";
Tutorials_4_3_Name = "Stacks [NYI]";
Tutorials_4_3_Desc = "Similar to the previous tutorial, this will show you how to create a stacks display and attach a source to it.";

Tutorials_5_Name = "Actions";
Tutorials_5_Desc = "These tutorials will cover the use of standalone actions. Standalone actions are for processing things not necessarily related to a display, such as playing a sound.";

Tutorials_5_1_Name = "I'm Running out of Ideas [NYI]";
Tutorials_5_1_Desc = "Which is why I'll come back to this later.";