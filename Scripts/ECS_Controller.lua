--[[ 

Enhanced Cloud-/Skyscapes Controller
Licensed under the EUPL v1.2: https://eupl.eu/

Release for Enhanced Cloudscapes Beta 20201124: https://github.com/FarukEroglu2048/Enhanced-Cloudscapes
And
Enhanced Skyscapes

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
ECSC_ffi = require("ffi")							-- LuaJIT FFI module
require("ECS_Controller/Lua/ECSC_Log+Notify")   -- Imgui Window Element: Notifications
require("ECS_Controller/Lua/ECSC_Common")       -- Imgui Window Element: Common Elements
require("ECS_Controller/Lua/ECSC_Settings")     -- Imgui Window Element: Settings
require("ECS_Controller/Lua/ECSC_Datarefs")     -- Datarefs and accessors
require("ECS_Controller/Lua/ECSC_Menu")         -- Menu entries for the plugins menu
require("ECS_Controller/Lua/ECSC_Main")         -- Cloud settings main module
--[[

VARIABLES (local or global)

]]
ECSC_ScriptName = "Enhanced Cloud-/Skyscapes Controller"   -- Name of the script
local ECSC_PageTitle = "Main Menu"   -- Main menu page title - DO NOT EDIT!
local ECSC_Initialized = false       -- Has the script been initialized?
local ECSC_PageInitStatus = 0        -- Has the window been initialized?
ECSC_Check_Autoload = false          -- Enables check of the autoloading condition
ECSC_Window_Pos={0,0}                -- Window position x,y
ECSC_ImguiColors={0x33FFAE00,0xBBFFAE00,0xFFC8C8C8,0xFF0000FF,0xFF19CF17,0xFFB6CDBA,0xFF40aee5} -- Imgui: Control elements passive, control elements active, text, negative, positive, neutral, caution
ECSC_Menu_ID = nil                   -- ID of the main ECC menu
ECSC_Menu_Index = nil                -- Index of the ECC menu in the plugins menu
--[[

INITIALIZATION

]]
local function ECSC_Main_Init()
    ECSC_Log_Delete()					-- Delete the old log file
    ECSC_Log_Write("INIT: Beginning "..ECSC_ScriptName.." initialization")
    ECSC_SettingsFileRead() 				-- Trigger reading the UI settings file
    if ECSC_SettingsValGet("WindowIsOpen") == 1 then ECSC_Window_Show() end -- If window open flag was true, build the window
    ECSC_Menu_Init()
    ECSC_ModuleInit_Main()               -- Initialize main module (cloud settings window)
    ECSC_Initialized = true
    if ECSC_Initialized then print("---> "..ECSC_ScriptName.." initialized.") ECSC_Log_Write("INIT: Finished "..ECSC_ScriptName.." initialization") end
end
--[[

FUNCTIONS

]]
--[[ Show Window ]]
function ECSC_Window_Show()
	ECSC_Window = float_wnd_create(ECSC_SettingsValGet("Window_W"), ECSC_SettingsValGet("Window_H"), 1, true)
	float_wnd_set_position(ECSC_Window, ECSC_SettingsValGet("Window_X"), ECSC_SettingsValGet("Window_Y"))
	float_wnd_set_title(ECSC_Window, ECSC_ScriptName)
	float_wnd_set_imgui_builder(ECSC_Window, "ECSC_Window_Build")
	float_wnd_set_onclose(ECSC_Window, "ECSC_Window_Hide")
	ECSC_SettingsValSet("WindowIsOpen",1)
	ECSC_Settings_CheckAutosave()
	--print("Window open: "..ECSC_SettingsValGet("WindowIsOpen"))
	ECSC_Log_Write("Window Opening")
    ECSC_Menu_Watchdog(1)
end
--[[ Hide Window ]]
function ECSC_Window_Hide(ECSC_Window)
	if ECSC_Window then float_wnd_destroy(ECSC_Window) end
	ECSC_SettingsValSet("WindowIsOpen",0)
	ECSC_Settings_CheckAutosave()
	--print("Window open: "..ECSC_SettingsValGet("WindowIsOpen"))
	ECSC_Log_Write("Window Closing")
    ECSC_Menu_Watchdog(1)
end
--[[ Toggle Window ]]
function ECSC_Window_Toggle()
	if ECSC_SettingsValGet("WindowIsOpen") == 0  then ECSC_Window_Show() else ECSC_Window_Hide(ECSC_Window) end
end
--[[ Open Window by Keystroke ]]
function ECSC_Window_By_Key()
	if ECSC_SettingsValGet("WindowToggleByHotkey") == 1 and KEY_ACTION=="pressed" and VKEY==ECSC_SettingsValGet("WindowToggleHotkey") then
		ECSC_Window_Toggle()
		RESUME_KEY = true
		--print("Pressed "..ECSC_SettingsValGet("WindowToggleHotkey"))
	end
end
do_on_keystroke("ECSC_Window_By_Key()")
--[[ Open Window and switch to page ]]
function ECSC_Window_GoTo(inpage)
    if ECSC_SettingsValGet("WindowIsOpen") == 0 then ECSC_Window_Show() end
    ECSC_SettingsValSet("Window_Page",inpage)
end
--[[ Asset: "Main Menu" button ]]
function ECSC_Win_Button_Back(target)
    if imgui.Button(target,(ECSC_SettingsValGet("Window_W")-30),20) then
        ECSC_SettingsValSet("Window_Page",ECSC_PageNumGet(target))
        float_wnd_set_title(ECSC_Window, ECSC_ScriptName)
        ECSC_Settings_CheckAutosave()
    end
    ECSC_ItemTooltip("Return to "..target)
    imgui.Dummy((ECSC_SettingsValGet("Window_W")-30),10)
    imgui.Separator()
end
--[[ 

IMGUI WINDOW ELEMENT

]]
--[[ Page initialization ]]
local function ECSC_Page_Init()
    if ECSC_PageInitStatus == 0 then ECSC_Refresh_PageDB(ECSC_PageTitle)
        if ECSC_SettingsValGet("AutoLoad") ~= 1 or ECSC_SettingsValGet("Window_Page") == 0 then ECSC_SettingsValSet("Window_Page",ECSC_PageNumGet(ECSC_PageTitle)) end
    ECSC_PageInitStatus = 1 end
end
--[[ Imgui window builder ]]
function ECSC_Window_Build(ECSC_Window,xpos,ypos)
	ECSC_Window_Pos={xpos,ypos}
	--[[ Window styling ]]
	imgui.PushStyleColor(imgui.constant.Col.Button,ECSC_ImguiColors[1])
	imgui.PushStyleColor(imgui.constant.Col.ButtonHovered,ECSC_ImguiColors[2])
	imgui.PushStyleColor(imgui.constant.Col.ButtonActive,ECSC_ImguiColors[2])
	imgui.PushStyleColor(imgui.constant.Col.Text,ECSC_ImguiColors[3])
	imgui.PushStyleColor(imgui.constant.Col.TextSelectedBg,ECSC_ImguiColors[2])
	imgui.PushStyleColor(imgui.constant.Col.FrameBg,ECSC_ImguiColors[1])
	imgui.PushStyleColor(imgui.constant.Col.FrameBgHovered,ECSC_ImguiColors[2])
	imgui.PushStyleColor(imgui.constant.Col.FrameBgActive,ECSC_ImguiColors[2])
	imgui.PushStyleColor(imgui.constant.Col.Header,ECSC_ImguiColors[1])
	imgui.PushStyleColor(imgui.constant.Col.HeaderActive,ECSC_ImguiColors[2])
	imgui.PushStyleColor(imgui.constant.Col.HeaderHovered,ECSC_ImguiColors[2])
	imgui.PushStyleColor(imgui.constant.Col.CheckMark,ECSC_ImguiColors[3])
    imgui.PushTextWrapPos(ECSC_SettingsValGet("Window_W")-30)
    imgui.Dummy((ECSC_SettingsValGet("Window_W")-30),10)
	--[[ Window Content ]]
    ECSC_Win_Main()
	ECSC_Win_Settings()
    imgui.Dummy((ECSC_SettingsValGet("Window_W")-30),10)
    ECSC_Win_Notifications()
	--[[ End Window Styling ]]
	imgui.PopStyleColor(12)
    imgui.PopTextWrapPos()
    --[[ Check page init status ]]
    ECSC_Page_Init()
    --[[ Page ]]
    if ECSC_SettingsValGet("Window_Page") == ECSC_PageNumGet(ECSC_PageTitle) then
        --[[ Set the page title ]]
        float_wnd_set_title(ECSC_Window, ECSC_ScriptName.." ("..ECSC_PageTitle..")")
    end
--[[ End Imgui Window ]]
end
--[[

INITIALIZATION

]]
--[[ Has to run in a 1 second loop to work ]]
function ECSC_Main_1sec()
    if not ECSC_Initialized then
        ECSC_Main_Init()
    end
end
do_often("ECSC_Main_1sec()")
--[[

EXIT

]]
do_on_exit("ECSC_Menu_CleanUp()")
--[[

MACROS AND COMMANDS

]]
add_macro("Enhanced Cloud-/Skyscapes Controller: Toggle Window", "ECSC_Window_Show()","ECSC_Window_Hide(ECSC_Window)","deactivate")
create_command("Enhanced Cloud-/Skyscapes Controller/Window/Toggle", "Toggle Window", "ECSC_Window_Toggle()", "", "")
