--[[

Lua Module, required by EnhCloudsController.lua
Licensed under the EUPL v1.2: https://eupl.eu/

]]
--[[

VARIABLES (used globally by multiple modules)

]]
--[[ Common Preferences. More "A"s --> earlier loading ]]
ECC_Preferences = {
	AAA_WindowToggleHotkeyEnable = false, 	  -- Enable window toggling by hotkey (true/false)?
	AAA_WindowToggleHotkey = 85, 			  -- Key to toggle tweak window (Default/Start: "85" = "u")
	AAA_Is_ECC_Window_Open = true,            -- Is the window open?
	AAA_Window_W = 530, 					  -- Initial window width in pixel
	AAA_Window_H = 600, 					  -- Initial window height in pixel
	AAA_Window_X = 100, 					  -- Initial window position x in pixel
	AAA_Window_Y = 400,						  -- Initial window position y in pixel
	AA_Autosave = false, 				      -- Trigger writing to save file after almost every UI interaction
	AA_Autoload = false, 				      -- Controls automatic loading of save file content during initialization
	A_NotificationDisplayTime = 5, 	          -- Start value for message display time (seconds)
    Window_Page = 0,                          -- Start value for the winow page
}



