--[[

Lua Module, required by EnhCloudsController.lua
Licensed under the EUPL v1.2: https://eupl.eu/

]]
--[[

VARIABLES (used globally by multiple modules)

]]
--[[ Common Preferences. More "A"s --> earlier loading ]]
ECC_Preferences = {
	AAA_WindowToggleHotkeyEnable = false, 	-- Enable window toggling by hotkey (true/false)?
	AAA_WindowToggleHotkey = 85, 			-- Key to toggle tweak window (Default/Start: "85" = "u")
	AAA_Is_ECC_Window_Open = true, -- Is the window open?
	AAA_Window_W = 530, 					-- Initial window width in pixel
	AAA_Window_H = 600, 					-- Initial window height in pixel
	AAA_Window_X = 100, 					-- Initial window position x in pixel
	AAA_Window_Y = 400,						-- Initial window position y in pixel
	AA_Autosave = false, 					-- Trigger writing to save file after almost every UI interaction
	AA_Autoload = false, 					-- Controls automatic loading of save file content during initialization
	A_NotificationDisplayTime = 5, 			-- Start value for message display time (seconds)
    Window_Page = 0,                        -- Start value for the winow page
}


ECC_Check_Autoload = false						-- Enables check of the autoloading condition
ECC_Window_Pos={0,0}							-- Window position x,y
ECC_NotificationStack = { }                     -- Array for the notification stack 
ECC_ImguiColors={0x33FFAE00,0xBBFFAE00,0xFFC8C8C8,0xFF0000FF,0xFF19CF17,0xFFB6CDBA,0xFF40aee5} -- Imgui: Control elements passive, control elements active, text, negative, positive, neutral, caution


--[[

DATAREFS (used globally by multiple modules)

]]
--[[ Initialize datarefs locally to avoid FWL complaining about dataref access by multiple scripts ]]

--[[local DRef2  = dataref_table("sim/flightmodel/weight/m_fixed")				-- Current payload (kilograms)
local DRef5  = dataref_table("sim/flightmodel/weight/m_total")				-- Total aircraft weight (kilograms)
local DRef8  = dataref_table("sim/flightmodel/misc/cgz_ref_to_default") 	-- Current CG, in meters from reference CG
local DRef9  = dataref_table("sim/aircraft/overflow/acf_tank_Z") 			-- Longitudinal fuel tank location from reference CG, in meters; table! ]]

--[[ Turns local dataref variables into global variables ]]

--[[ ECC_LM_DR_ActualMassPayload 	= DRef2
ECC_LM_DR_ActualMassTotal 		= DRef5
ECC_LM_DR_ActualCG 				= DRef8
ECC_LM_DR_MomentArmFuel 		= DRef9 ]]
