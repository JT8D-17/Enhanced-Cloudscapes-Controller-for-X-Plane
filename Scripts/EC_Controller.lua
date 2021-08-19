--[[ 

Enhanced Cloudscapes Controller
Licensed under the EUPL v1.2: https://eupl.eu/

Release for Enhanced Cloudscapes Beta 20201124: https://github.com/FarukEroglu2048/Enhanced-Cloudscapes

Contributors:
BK (JT8D-17)
Faruk Eroglu (Biological Nanobot)
 ]]
--[[

REQUIREMENTS

]]
if not SUPPORTS_FLOATING_WINDOWS then
	print("Imgui not supported by your FlyWithLua version. Please update to the latest release")
	return
end
--[[ Required modules,DO NOT MODIFY LOAD ORDER! ]]
ECC_ffi = require ("ffi")                     -- LuaJIT FFI module
require("EC_Controller/Lua/ECC_Log+Notify")   -- Imgui Window Element: Notifications
require("EC_Controller/Lua/ECC_Common")       -- Imgui Window Element: FileIO
require("EC_Controller/Lua/ECC_Settings")     -- Imgui Window Element: Settings
require("EC_Controller/Lua/ECC_Datarefs")     -- Datarefs and accessors
require("EC_Controller/Lua/ECC_Menu")         -- Menu entries for the plugins menu
require("EC_Controller/Lua/ECC_Main")         -- Cloud settings main module
--[[

VARIABLES (local or global)

]]
ECC_ScriptName = "Enhanced Cloudscapes Controller"   -- Name of the script
local ECC_PageTitle = "Main Menu"   -- Main menu page title - DO NOT EDIT!
local ECC_Initialized = false       -- Has the script been initialized?
local ECC_PageInitStatus = 0        -- Has the window been initialized?
ECC_Check_Autoload = false          -- Enables check of the autoloading condition
ECC_Window_Pos={0,0}                -- Window position x,y
ECC_ImguiColors={0x33FFAE00,0xBBFFAE00,0xFFC8C8C8,0xFF0000FF,0xFF19CF17,0xFFB6CDBA,0xFF40aee5} -- Imgui: Control elements passive, control elements active, text, negative, positive, neutral, caution
ECC_Menu_ID = nil                   -- ID of the main ECC menu
ECC_Menu_Index = nil                -- Index of the ECC menu in the plugins menu
--[[

INITIALIZATION

]]
local function ECC_Main_Init()
    ECC_Log_Delete()					-- Delete the old log file
    ECC_Log_Write("INIT: Beginning "..ECC_ScriptName.." initialization")
    ECC_SettingsFileRead() 				-- Trigger reading the UI settings file
    if ECC_SettingsValGet("WindowIsOpen") == 1 then ECC_Window_Show() end -- If window open flag was true, build the window
    ECC_Menu_Init()
    ECC_ModuleInit_Main()               -- Initialize main module (cloud settings window)
    ECC_Initialized = true
    if ECC_Initialized then print("---> "..ECC_ScriptName.." initialized.") ECC_Log_Write("INIT: Finished "..ECC_ScriptName.." initialization") end
end
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
    ECC_Menu_Watchdog(1)
end
--[[ Hide Window ]]
function ECC_Window_Hide(ECC_Window)
	if ECC_Window then float_wnd_destroy(ECC_Window) end
	ECC_SettingsValSet("WindowIsOpen",0)
	ECC_Settings_CheckAutosave()
	--print("Window open: "..ECC_SettingsValGet("WindowIsOpen"))
	ECC_Log_Write("Window Closing")
    ECC_Menu_Watchdog(1)
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
--[[ Open Window and switch to page ]]
function ECC_Window_GoTo(inpage)
    if ECC_SettingsValGet("WindowIsOpen") == 0 then ECC_Window_Show() end
    ECC_SettingsValSet("Window_Page",inpage)
end
--[[ Asset: "Main Menu" button ]]
function ECC_Win_Button_Back(target)
    if imgui.Button(target,(ECC_SettingsValGet("Window_W")-30),20) then
        ECC_SettingsValSet("Window_Page",ECC_PageNumGet(target))
        float_wnd_set_title(ECC_Window, ECC_ScriptName)
        ECC_Settings_CheckAutosave()
    end
    ECC_ItemTooltip("Return to "..target)
    imgui.Dummy((ECC_SettingsValGet("Window_W")-30),10)
    imgui.Separator()
end
--[[ 

IMGUI WINDOW ELEMENT

]]
--[[ Page initialization ]]
local function ECC_Page_Init()
    if ECC_PageInitStatus == 0 then ECC_Refresh_PageDB(ECC_PageTitle)
        if ECC_SettingsValGet("AutoLoad") ~= 1 or ECC_SettingsValGet("Window_Page") == 0 then ECC_SettingsValSet("Window_Page",ECC_PageNumGet(ECC_PageTitle)) end
    ECC_PageInitStatus = 1 end
end
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
    ECC_Win_Main()
	ECC_Win_Settings()
    imgui.Dummy((ECC_SettingsValGet("Window_W")-30),10)
    ECC_Win_Notifications()
	--[[ End Window Styling ]]
	imgui.PopStyleColor(12)
    imgui.PopTextWrapPos()
    --[[ Check page init status ]]
    ECC_Page_Init()
    --[[ Page ]]
    if ECC_SettingsValGet("Window_Page") == ECC_PageNumGet(ECC_PageTitle) then
        --[[ Set the page title ]]
        float_wnd_set_title(ECC_Window, ECC_ScriptName.." ("..ECC_PageTitle..")")
    end
--[[ End Imgui Window ]]
end
--[[

INITIALIZATION

]]
--[[ Has to run in a 1 second loop to work ]]
function ECC_Main_1sec()
    if not ECC_Initialized then
        ECC_Main_Init()
    end
end
do_often("ECC_Main_1sec()")
--[[

EXIT

]]
do_on_exit("ECC_Menu_CleanUp()")
--[[

MACROS AND COMMANDS

]]
add_macro("Enhanced Cloudscapes Controller: Toggle Window", "ECC_Window_Show()","ECC_Window_Hide(ECC_Window)","deactivate")
create_command("Enhanced Cloudscapes Controller/Window/Toggle", "Toggle Window", "ECC_Window_Toggle()", "", "")
