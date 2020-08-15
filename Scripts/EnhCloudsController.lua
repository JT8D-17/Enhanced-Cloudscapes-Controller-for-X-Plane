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
require("EnhCloudsController/Lua/Log+Notify")       -- Imgui Window Element: Notifications
require("EnhCloudsController/Lua/Settings")         -- Imgui Window Element: Settings
require("EnhCloudsController/Lua/CloudPrefs")       -- Imgui Window Element: Cloud preferences
--[[

VARIABLES (local or global)

]]
ECC_ScriptName = "Enhanced Cloudscapes Controller"
local ECC_Initialized = false   -- Has the script been initialized?
ECC_Check_Autoload = false      -- Enables check of the autoloading condition
ECC_Window_Pos={0,0}            -- Window position x,y
ECC_ImguiColors={0x33FFAE00,0xBBFFAE00,0xFFC8C8C8,0xFF0000FF,0xFF19CF17,0xFFB6CDBA,0xFF40aee5} -- Imgui: Control elements passive, control elements active, text, negative, positive, neutral, caution
--[[

FUNCTIONS

]]
--[[ Show Window ]]
function ECC_Window_Show()
	ECC_Window = float_wnd_create(ECC_SettingsValGet("Window_W"), ECC_SettingsValGet("Window_H"), 1, true)
	float_wnd_set_position(ECC_Window, ECC_SettingsValGet("Window_X"), ECC_SettingsValGet("Window_Y"))
	float_wnd_set_title(ECC_Window, ECC_ScriptName)
	float_wnd_set_imgui_builder(ECC_Window, "ECC_Window_Build")
	float_wnd_set_onclose(ECC_Window, "ECC_Window_Hide")
	ECC_SettingsValSet("WindowIsOpen",1)
	ECC_Settings_CheckAutosave()
	--print("Window open: "..ECC_SettingsValGet("WindowIsOpen"))
	ECC_Log_Write("Window Opening")
end
--[[ Hide Window ]]
function ECC_Window_Hide(ECC_Window)
	if ECC_Window then float_wnd_destroy(ECC_Window) end
	ECC_SettingsValSet("WindowIsOpen",0)
	ECC_Settings_CheckAutosave()
	--print("Window open: "..ECC_SettingsValGet("WindowIsOpen"))
	ECC_Log_Write("Window Closing")
end
--[[ Toggle Window ]]
function ECC_Window_Toggle()
	if ECC_SettingsValGet("WindowIsOpen") == 0  then ECC_Window_Show() else ECC_Window_Hide(ECC_Window) end
end
--[[ Open Window by Keystroke ]]
function ECC_Window_By_Key()
	if ECC_SettingsValGet("WindowToggleByHotkey") == 1 and KEY_ACTION=="pressed" and VKEY==ECC_SettingsValGet("WindowToggleHotkey") then
		ECC_Window_Toggle()
		RESUME_KEY = true
		--print("Pressed "..ECC_SettingsValGet("WindowToggleHotkey"))
	end
end
do_on_keystroke("ECC_Window_By_Key()")
--[[ Imgui window builder ]]
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
    imgui.PushTextWrapPos(ECC_SettingsValGet("Window_W")-30)
    imgui.Dummy((ECC_SettingsValGet("Window_W")-30),10)
	--[[ Window Content ]]
    ECC_Win_CloudPrefs()
	ECC_Win_Settings()
    imgui.Dummy((ECC_SettingsValGet("Window_W")-30),10)
    ECC_Win_Notifications()
	--[[ End Window Styling ]]
	imgui.PopStyleColor(12)
    imgui.PopTextWrapPos()
--[[ End Imgui Window ]]
end
--[[

INITIALIZATION

]]
--[[ Has to run in a 1 second loop to work ]]
function ECC_Main_1sec()
	if not ECC_Initialized then 
        ECC_Log_Delete()					-- Delete the old log file
        ECC_Log_Write("INIT: Beginning "..ECC_ScriptName.." initialization")
        --ECC_Check_Autoload = true 				--Enable autoloading status mode check
        ECC_SettingsFileRead() 				--Trigger reading the save file and writing the contents to the target table
        if ECC_SettingsValGet("WindowIsOpen") == 1 then ECC_Window_Show() end -- If window open flag was true, build the window
        ECC_Initialized = true
        if ECC_Initialized then print("---> "..ECC_ScriptName.." initialized.") ECC_Log_Write("INIT: Finished "..ECC_ScriptName.." initialization") end
    end
end
do_often("ECC_Main_1sec()")
--[[

MACROS AND COMMANDS

]]
add_macro(ECC_ScriptName..": Toggle Window", "ECC_Window_Show()","ECC_Window_Hide(ECC_Window)","deactivate")
create_command(ECC_ScriptName.."/Window/Toggle", "Toggle Window", "ECC_Window_Toggle()", "", "")
