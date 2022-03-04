--[[

Lua Module, required by ECS_Controller.lua
Licensed under the EUPL v1.2: https://eupl.eu/

]]
--[[

VARIABLES (global and local!)

]]
local ECSC_SettingsFile = MODULES_DIRECTORY.."ECS_Controller/UI_Prefs.cfg"   -- Preferences file path
local ECSC_PageTitle = "UI Settings"
ECSC_Settings = {
    {"AutoSave",0},             -- Autosave enabled
    {"AutoLoad",0},             -- Autoload enabled
    {"WindowToggleByHotkey",0}, -- Window open/close by hotkey enabled
    {"WindowToggleHotkey",85},  -- Window open/close hotkey (default: 85 = u)
    {"WindowIsOpen",1},         -- Window open/close status
    {"Window_X",100},           -- Window X position
    {"Window_Y",400},           -- Window Y position
    {"Window_W",530},           -- Window width
    {"Window_H",700},           -- Window height
    {"Window_Page",0},          -- Window page
    {"NotificationDispTime",6}, -- Notification display time
}
local ECSC_PageInitStatus = 0       -- Has the module been initialized?
--[[

FUNCTIONS

]]
--[[ Accessor: Get name of a setting ]]
function ECSC_SettingsNameGet(item)
    for i=1,#ECSC_Settings do
       if ECSC_Settings[i][1] == item then return ECSC_Settings[i][1] end
    end
end
--[[ Accessor: Get value of a setting ]]
function ECSC_SettingsValGet(item)
    for i=1,#ECSC_Settings do
       if ECSC_Settings[i][1] == item then return ECSC_Settings[i][2] end
    end
end
--[[ Accessor: Set value of a setting ]]
function ECSC_SettingsValSet(item,newvalue)
    for i=1,#ECSC_Settings do
       if ECSC_Settings[i][1] == item then ECSC_Settings[i][2] = newvalue break end
    end
end
--[[ Update window position information ]]
function ECSC_GetWindowInfo()
		if ECSC_SettingsValGet("Window_W") ~= imgui.GetWindowWidth() or ECSC_SettingsValGet("Window_H") ~= imgui.GetWindowHeight() or ECSC_SettingsValGet("Window_X") ~= ECSC_Window_Pos[1] or ECSC_SettingsValGet("Window_Y") ~= ECSC_Window_Pos[2] then
			ECSC_SettingsValSet("Window_W",imgui.GetWindowWidth())
			ECSC_SettingsValSet("Window_H",imgui.GetWindowHeight())
			ECSC_SettingsValSet("Window_X",ECSC_Window_Pos[1])
			ECSC_SettingsValSet("Window_Y",ECSC_Window_Pos[2])
            --print(ECSC_SettingsValGet("Window_X")..","..ECSC_SettingsValGet("Window_Y")..","..ECSC_SettingsValGet("Window_W")..","..ECSC_SettingsValGet("Window_H"))
			--ECSC_Settings_CheckAutosave("NoLog")
		end
end
--[[ Settings file write ]]
function ECSC_SettingsFileWrite(log)
    ECSC_Log_Write("FILE INIT WRITE: "..ECSC_SettingsFile)
    local file = io.open(ECSC_SettingsFile, "w")
    file:write(ECSC_ScriptName.." settings file created/updated on ",os.date("%x, %H:%M:%S"),"\n\n")
    for a=1,#ECSC_Settings do
        --print(ECSC_Settings[a][1].."="..ECSC_Settings[a][2])
        file:write(ECSC_Settings[a][1].."="..ECSC_Settings[a][2].."\n")
    end
    if file:seek("end") > 0 then 
        if log == "log" then ECSC_Notification("FILE WRITE SUCCESS: "..ECSC_SettingsFile,"Success","log") else ECSC_Notification("FILE WRITE SUCCESS: "..ECSC_SettingsFile,"Success") end
    else 
        if log == "log" then ECSC_Notification("FILE WRITE ERROR: "..ECSC_SettingsFile,"Error","log") else ECSC_Notification("FILE WRITE ERROR: "..ECSC_SettingsFile,"Error") end
    end
	file:close()
end
--[[ Settings file read ]]
function ECSC_SettingsFileRead()
    local file = io.open(ECSC_SettingsFile, "r")
    if file then
        ECSC_Log_Write("FILE INIT READ: "..ECSC_SettingsFile)
        local i = 0
        local temptable = { }
        for line in file:lines() do
            if string.match(line,"^AutoLoad") then
               ECSC_Settings_LineSplit(line,"([^=]+)")
               if tonumber(ECSC_Settings_LineSplitResult[2]) == 0 then
                   --print("Aborting!")
                   break
               end
            end
            if string.match(line,"^[A-Z,a-z].+=") then
                ECSC_Settings_LineSplit(line,"([^=]+)")
                temptable[#temptable+1] = ECSC_Settings_LineSplitResult
                --print(#temptable..": "..table.concat(temptable[#temptable],","))
                i = i+1
            end
            for j=1,#temptable do
                for k=1,#ECSC_Settings do
                    if temptable[j][1] == ECSC_Settings[k][1] then
                        --print("Match temptable "..temptable[j][1].." with Settings table "..ECSC_Settings[k][1].." at "..k)
                        ECSC_Settings[k][2] = tonumber(temptable[j][2]) -- Current value(s)
                    end
                end
            end       
        end
        file:close()
        --for l=1,#ECSC_Settings do print(table.concat(ECSC_Settings[l],": ")) end
		if i ~= nil and i > 0 then ECSC_Notification("FILE READ SUCCESS: "..ECSC_SettingsFile,"Success","log") else ECSC_Notification("FILE READ ERROR: "..ECSC_SettingsFile,"Error","log") end
    else
        ECSC_Notification("FILE NOT FOUND: "..ECSC_SettingsFile,"Error","log")
		--ECSC_Check_AutoLoad = false
	end   
end
--[[ Settings file delete ]]
function ECSC_SettingsFileDelete()
   os.remove(ECSC_SettingsFile) ECSC_Notification("FILE DELETE: "..ECSC_SettingsFile,"Warning")
end
--[[ Check Autosave status ]]
function ECSC_Settings_CheckAutosave(log)
    if ECSC_SettingsValGet("AutoSave") == 1 then
        if log == "log" then ECSC_SettingsFileWrite("log")
        else ECSC_SettingsFileWrite() end
    end
end
--[[ Determine string from value ]]
function ECSC_ValToStr(input)
    local string = ""
        if input == 0 then string = "Enable" 
        elseif input == 1 then string = "Disable" end
    return string
end
--[[ Splits a line at the designated delimiter ]]
function ECSC_Settings_LineSplit(input,delim)
	ECSC_Settings_LineSplitResult = {}
	--print(input)
	for i in string.gmatch(input,delim) do table.insert(ECSC_Settings_LineSplitResult,i) end
	--print("ECSC_Settings_LineSplitResult: "..table.concat(ECSC_Settings_LineSplitResult,",",1,#ECSC_Settings_LineSplitResult))
	return ECSC_Settings_LineSplitResult
end
--[[ Page initialization ]]
local function ECSC_Page_Init()
    if ECSC_PageInitStatus == 0 then ECSC_Refresh_PageDB(ECSC_PageTitle) ECSC_PageInitStatus = 1 end
end
--[[

IMGUI WINDOW ELEMENT

]]
function ECSC_Win_Settings()
    --[[ Check page init status ]]
    ECSC_Page_Init()
    --[[ Button ]]
    if ECSC_SettingsValGet("Window_Page") == ECSC_PageNumGet("Main Menu") then
        imgui.Dummy((ECSC_SettingsValGet("Window_W")-30),19)
        if imgui.Button(ECSC_PageTitle,(ECSC_SettingsValGet("Window_W")-30),20) then
            ECSC_SettingsValSet("Window_Page",ECSC_PageNumGet(ECSC_PageTitle))
            ECSC_Settings_CheckAutosave()
        end
        ECSC_ItemTooltip("Manage "..ECSC_ScriptName.."' UI and general module settings")
    end
    --[[ Page ]]
    if ECSC_SettingsValGet("Window_Page") == ECSC_PageNumGet(ECSC_PageTitle) then
        --[[ Set the page title ]]
        float_wnd_set_title(ECSC_Window, ECSC_ScriptName.." ("..ECSC_PageTitle..")")
        --[[ "Main Menu" button ]]
        ECSC_Win_Button_Back("Main Menu")
        --[[ Message display time ]]
        imgui.PushItemWidth(50)
        local changed,buffer = imgui.InputInt("  Notification Display Time (Seconds) ##10",ECSC_SettingsValGet("NotificationDispTime"),0,0)
        if changed then ECSC_SettingsValSet("NotificationDispTime",buffer) ECSC_Settings_CheckAutosave() buffer = nil end
        ECSC_ItemTooltip("Affects notifications at the bottom of the main window")
        imgui.PopItemWidth()
        imgui.Dummy((ECSC_SettingsValGet("Window_W")-30),19)
        --[[ Hotkey options ]]
        if imgui.Button(ECSC_ValToStr(ECSC_SettingsValGet("WindowToggleByHotkey")).." Window Toggling By Hotkey ##20",(ECSC_SettingsValGet("Window_W")-30),20) then
            if ECSC_SettingsValGet("WindowToggleByHotkey") == 0 then ECSC_SettingsValSet("WindowToggleByHotkey",1)
            elseif ECSC_SettingsValGet("WindowToggleByHotkey") == 1 then ECSC_SettingsValSet("WindowToggleByHotkey",0) end
            ECSC_Settings_CheckAutosave()
        end
        ECSC_ItemTooltip("Manages a custom hotkey for toggling the main window, avoiding a permanent key binding in X-Plane's keyboard configuration menu.\nWARNING: This key will be blocked for use by X-Plane or any other script/tool")
        if ECSC_SettingsValGet("WindowToggleByHotkey") == 1 then
            imgui.PushItemWidth(((ECSC_SettingsValGet("Window_W") / 2)-30))
            local changed,buffer = imgui.InputInt("  Keyboard Key Code##21",ECSC_SettingsValGet("WindowToggleHotkey"),0,0)
            if changed then ECSC_SettingsValSet("WindowToggleHotkey",buffer) ECSC_Settings_CheckAutosave() buffer = nil end
            ECSC_ItemTooltip("Find keyboard key codes with FlyWithLua's 'Show Keystroke Numbers' function (see FWL menu).\nAlternatively, you can assign a key to this script's 'Toggle Window' command in XP11's keyboard assignment menu. Make sure to disable this internal hotkey before doing so.")
            imgui.PopItemWidth() 
            imgui.Dummy((ECSC_SettingsValGet("Window_W")-30),19)
        end
        --[[ Autosave options ]]
        if imgui.Button(ECSC_ValToStr(ECSC_SettingsValGet("AutoSave")).." Autosave##30",(ECSC_SettingsValGet("Window_W")-30),20) then
            if ECSC_SettingsValGet("AutoSave") == 0 then ECSC_SettingsValSet("AutoSave",1)
            elseif ECSC_SettingsValGet("AutoSave") == 1 then ECSC_SettingsValSet("AutoSave",0) end
            ECSC_SettingsFileWrite()
        end
        ECSC_ItemTooltip("Toggles global autosaving (UI and all modules) for "..ECSC_ScriptName)
    --			if ECSC_SettingsValGet("AutoSave") then
    --				imgui.SameLine() imgui.TextUnformatted("(interval in seconds):") imgui.SameLine()
    --				local changed, newAutoSave_Time = imgui.InputText("##41", ECSC_Preferences.AutoSave_Time, 4)
    --				if changed and newAutoSave_Time ~= "" and tonumber(newAutoSave_Time) then ECSC_Preferences.AutoSave_Time = newAutoSave_Time ECSC_SettingsFileWrite() end
    --			end
        --[[ Autoload options ]]
        if imgui.Button(ECSC_ValToStr(ECSC_SettingsValGet("AutoLoad")).." Autoload##40",(ECSC_SettingsValGet("Window_W")-30),20) then
            if ECSC_SettingsValGet("AutoLoad") == 0 then ECSC_SettingsValSet("AutoLoad",1)
            elseif ECSC_SettingsValGet("AutoLoad") == 1 then ECSC_SettingsValSet("AutoLoad",0) end
            ECSC_SettingsFileWrite()
        end
        ECSC_ItemTooltip("Toggles global autloading (UI and all modules) after script start for "..ECSC_ScriptName)
        imgui.Dummy((ECSC_SettingsValGet("Window_W")-30),19)
        -- [[ Window information ]]
        imgui.TextUnformatted("Current Window Size (W,H) / Pos. (X,Y): "..imgui.GetWindowWidth()..","..imgui.GetWindowHeight().." / "..ECSC_Window_Pos[1]..","..ECSC_Window_Pos[2])
        imgui.TextUnformatted("Screen Width / Height:                  "..SCREEN_WIDTH.." x "..SCREEN_HIGHT.." Px")
        ECSC_GetWindowInfo()
        imgui.TextUnformatted("Window size is saved automatically!")
        imgui.Dummy((ECSC_SettingsValGet("Window_W")-30),19)
        -- [[ Settings file control buttons ]]
        if imgui.Button("Save UI Settings ##50",(ECSC_SettingsValGet("Window_W")-30),20) then ECSC_SettingsFileWrite() end
        ECSC_ItemTooltip("Saves stored UI settings to "..ECSC_SettingsFile)
        if imgui.Button("Load UI Settings ##60",(ECSC_SettingsValGet("Window_W")-30),20) then ECSC_SettingsFileRead() end
        ECSC_ItemTooltip("Loads stored UI settings from "..ECSC_SettingsFile)
        imgui.Dummy((ECSC_SettingsValGet("Window_W")-30),19)
        if imgui.Button("Delete UI Settings",(ECSC_SettingsValGet("Window_W")-30),20) then ECSC_SettingsFileDelete() ECSC_Initialized = false end
        ECSC_ItemTooltip("Deletes stored UI settings")
        -- End of settings page 		
    end
end
