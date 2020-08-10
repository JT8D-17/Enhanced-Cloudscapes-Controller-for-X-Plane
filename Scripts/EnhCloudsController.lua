--[[ 

Enhanced Clouds Controller
Licensed under the EUPL v1.2: https://eupl.eu/

BK, xxyyzzzz
 ]]
 
--[[

REQUIREMENTS

]]
if not SUPPORTS_FLOATING_WINDOWS then
	print("Imgui not supported by your FlyWithLua version. Please update to the latest release")
	return
end
--[[ Required modules,DO NOT MODIFY LOAD ORDER! ]]
require("EnhCloudsController/Lua/ECC_Notifications")    -- Imgui Window Element: Notifications
require("EnhCloudsController/Lua/ECC_FileIO")           -- File input/output scripts
require("EnhCloudsController/Lua/ECC_Globals")          -- Global variables and datarefs
require("EnhCloudsController/Lua/ECC_Helpers")          -- Helper functions
require("EnhCloudsController/Lua/ECC_Settings")         -- Imgui Window Element: Settings
require("EnhCloudsController/Lua/ECC_CloudPrefs")       -- Cloud preferences window

-- Specific

--[[

PATHS

]]
--ECC_AircraftSaveFile = AIRCRAFT_PATH.."Z_ECC_Config.cfg" 		     -- Aircraft save file path
ECC_PrefsFile = MODULES_DIRECTORY.."EnhCloudsController/UI_Prefs.cfg"   -- Preferences file path
ECC_LogFile = MODULES_DIRECTORY.."EnhCloudsController/Log.txt"          -- Log file path
--[[

VARIABLES (local to this module)

]]
ECC_ScriptName = "Enhanced Cloudscapes Controller"
local ECC_Initialized = false 	-- Has the script been initialized?

--[[

DATAREFS (local to this module)

]]

local ECC_DRef_SimPaused = dataref_table("sim/time/paused")	-- Simulator

--[[

FUNCTIONS

]]

--[[ Script initialization. This function is executed once and then basically locked until the next (re)load ]]--
function ECC_Init()
	ECC_File_Delete("Log")					-- Delete the old log file
	ECC_Log_Write("INIT: Beginning "..ECC_ScriptName.." initialization")
	ECC_Table_Sort(ECC_Preferences)	 	-- Trigger sorting and recreation of initial preferences parameter table
	ECC_Check_Autoload = true 				--Enable autoloading status mode check
	ECC_File_Read("PrefsFile") 				--Trigger reading the save file and writing the contents to the target table
	if ECC_Preferences.AAA_Is_ECC_Window_Open then ECC_Window_Show() end -- If window open flag was true, build the window
    --ECC_PluginStatusNotification()
	ECC_Initialized = true
	if ECC_Initialized then print("---> "..ECC_ScriptName.." initialized.") ECC_Log_Write("INIT: Finished "..ECC_ScriptName.." initialization") end
end

--[[

LOOPS

]]
--[[ Main Loop (1 second) ]]
function ECC_Main_1sec()
	if not ECC_Initialized then ECC_Init() end
	if ECC_Initialized and ECC_DRef_SimPaused[0] == 0 then
        
	end
end
do_often("ECC_Main_1sec()")

--[[

IMGUI WINDOW MANAGEMENT

]]
--[[ Show Window ]]
function ECC_Window_Show()
	ECC_Window = float_wnd_create(ECC_Preferences.AAA_Window_W, ECC_Preferences.AAA_Window_H, 1, true)
	float_wnd_set_position(ECC_Window, ECC_Preferences.AAA_Window_X, ECC_Preferences.AAA_Window_Y)
	float_wnd_set_title(ECC_Window, ECC_ScriptName)
	float_wnd_set_imgui_builder(ECC_Window, "ECC_Window_Build")
	float_wnd_set_onclose(ECC_Window, "ECC_Window_Hide")
	ECC_Preferences.AAA_Is_ECC_Window_Open = true
	ECC_CheckAutosave()
	--print("Window open: "..tostring(ECC_Preferences.AAA_Is_ECC_Window_Open))
	ECC_Log_Write("Window Opening")
end
--[[ Hide Window ]]
function ECC_Window_Hide(ECC_Window)
	if ECC_Window then float_wnd_destroy(ECC_Window) end
	ECC_Preferences.AAA_Is_ECC_Window_Open = false
	ECC_CheckAutosave()
	--print("Window open: "..tostring(ECC_Preferences.AAA_Is_ECC_Window_Open))
	ECC_Log_Write("Window Closing")
end
--[[ Toggle Window ]]
function ECC_Window_Toggle()
	if not ECC_Preferences.AAA_Is_ECC_Window_Open then ECC_Window_Show() else ECC_Window_Hide(ECC_Window) end
end
--[[ Open Window by Keystroke ]]
function ECC_Window_By_Key()
	if ECC_Preferences.AAA_WindowToggleHotkeyEnable and KEY_ACTION=="pressed" and VKEY==ECC_Preferences.AAA_WindowToggleHotkey then
		ECC_Window_Toggle()
		RESUME_KEY = true
		--print("Pressed "..ECC_Preferences.AAA_WindowToggleHotkey)
	end
end
do_on_keystroke("ECC_Window_By_Key()")


--[[

IMGUI WINDOW BUILDER

]]
function ECC_Window_Build(ECC_Window,xpos,ypos)
	ECC_Window_Pos={xpos,ypos}
	--[[ Window styling ]]
	imgui.PushStyleColor(imgui.constant.Col.Button,ECC_ImguiColors[1])
	imgui.PushStyleColor(imgui.constant.Col.ButtonHovered,ECC_ImguiColors[2])
	imgui.PushStyleColor(imgui.constant.Col.ButtonActive,ECC_ImguiColors[2])
	imgui.PushStyleColor(imgui.constant.Col.Text,ECC_ImguiColors[3])
	imgui.PushStyleColor(imgui.constant.Col.TextSelectedBg,ECC_ImguiColors[2])
	imgui.PushStyleColor(imgui.constant.Col.FrameBg,ECC_ImguiColors[1])
	imgui.PushStyleColor(imgui.constant.Col.FrameBgHovered,ECC_ImguiColors[2])
	imgui.PushStyleColor(imgui.constant.Col.FrameBgActive,ECC_ImguiColors[2])
	imgui.PushStyleColor(imgui.constant.Col.Header,ECC_ImguiColors[1])
	imgui.PushStyleColor(imgui.constant.Col.HeaderActive,ECC_ImguiColors[2])
	imgui.PushStyleColor(imgui.constant.Col.HeaderHovered,ECC_ImguiColors[2])
	imgui.PushStyleColor(imgui.constant.Col.CheckMark,ECC_ImguiColors[3])
    imgui.PushTextWrapPos(ECC_Preferences.AAA_Window_W-15)
    imgui.Dummy((ECC_Preferences.AAA_Window_W-15),10)
	--[[ Window Content ]]
    ECC_Win_CloudPrefs()
	ECC_Win_Settings()
    imgui.Dummy((ECC_Preferences.AAA_Window_W-15),10)
    ECC_Win_Notifications()
	--[[ End Window Styling ]]
	imgui.PopStyleColor(12)
    imgui.PopTextWrapPos()
--[[ End Imgui Window ]]
end
--[[

MACROS AND COMMANDS

]]

add_macro(ECC_ScriptName..": Toggle Window", "ECC_Window_Show()","ECC_Window_Hide(ECC_Window)","deactivate")
create_command(ECC_ScriptName.."/Window/Toggle", "Toggle Window", "ECC_Window_Toggle()", "", "")
