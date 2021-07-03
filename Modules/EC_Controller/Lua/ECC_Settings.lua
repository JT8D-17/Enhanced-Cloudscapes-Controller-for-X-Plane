--[[

Lua Module, required by EC_Controller.lua
Licensed under the EUPL v1.2: https://eupl.eu/

]]
--[[

VARIABLES (global and local!)

]]
local ECC_SettingsFile = MODULES_DIRECTORY.."EC_Controller/UI_Prefs.cfg"   -- Preferences file path
local ECC_PageTitle = "UI Settings"
ECC_Settings = {
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
local ECC_PageInitStatus = 0       -- Has the module been initialized?
--[[

FUNCTIONS

]]
--[[ Accessor: Get name of a setting ]]
function ECC_SettingsNameGet(item)
    for i=1,#ECC_Settings do
       if ECC_Settings[i][1] == item then return ECC_Settings[i][1] end
    end
end
--[[ Accessor: Get value of a setting ]]
function ECC_SettingsValGet(item)
    for i=1,#ECC_Settings do
       if ECC_Settings[i][1] == item then return ECC_Settings[i][2] end
    end
end
--[[ Accessor: Set value of a setting ]]
function ECC_SettingsValSet(item,newvalue)
    for i=1,#ECC_Settings do
       if ECC_Settings[i][1] == item then ECC_Settings[i][2] = newvalue break end
    end
end
--[[ Update window position information ]]
function ECC_GetWindowInfo()
		if ECC_SettingsValGet("Window_W") ~= imgui.GetWindowWidth() or ECC_SettingsValGet("Window_H") ~= imgui.GetWindowHeight() or ECC_SettingsValGet("Window_X") ~= ECC_Window_Pos[1] or ECC_SettingsValGet("Window_Y") ~= ECC_Window_Pos[2] then
			ECC_SettingsValSet("Window_W",imgui.GetWindowWidth())
			ECC_SettingsValSet("Window_H",imgui.GetWindowHeight())
			ECC_SettingsValSet("Window_X",ECC_Window_Pos[1])
			ECC_SettingsValSet("Window_Y",ECC_Window_Pos[2])
            --print(ECC_SettingsValGet("Window_X")..","..ECC_SettingsValGet("Window_Y")..","..ECC_SettingsValGet("Window_W")..","..ECC_SettingsValGet("Window_H"))
			--ECC_Settings_CheckAutosave("NoLog")
		end
end
--[[ Settings file write ]]
function ECC_SettingsFileWrite(log)
    ECC_Log_Write("FILE INIT WRITE: "..ECC_SettingsFile)
    local file = io.open(ECC_SettingsFile, "w")
    file:write(ECC_ScriptName.." settings file created/updated on ",os.date("%x, %H:%M:%S"),"\n\n")
    for a=1,#ECC_Settings do
        --print(ECC_Settings[a][1].."="..ECC_Settings[a][2])
        file:write(ECC_Settings[a][1].."="..ECC_Settings[a][2].."\n")
    end
    if file:seek("end") > 0 then 
        if log == "log" then ECC_Notification("FILE WRITE SUCCESS: "..ECC_SettingsFile,"Success","log") else ECC_Notification("FILE WRITE SUCCESS: "..ECC_SettingsFile,"Success") end
    else 
        if log == "log" then ECC_Notification("FILE WRITE ERROR: "..ECC_SettingsFile,"Error","log") else ECC_Notification("FILE WRITE ERROR: "..ECC_SettingsFile,"Error") end
    end
	file:close()
end
--[[ Settings file read ]]
function ECC_SettingsFileRead()
    local file = io.open(ECC_SettingsFile, "r")
    if file then
        ECC_Log_Write("FILE INIT READ: "..ECC_SettingsFile)
        local i = 0
        local temptable = { }
        for line in file:lines() do
            if string.match(line,"^AutoLoad") then
               ECC_Settings_LineSplit(line,"([^=]+)")
               if tonumber(ECC_Settings_LineSplitResult[2]) == 0 then
                   --print("Aborting!")
                   break
               end
            end
            if string.match(line,"^[A-Z,a-z].+=") then
                ECC_Settings_LineSplit(line,"([^=]+)")
                temptable[#temptable+1] = ECC_Settings_LineSplitResult
                --print(#temptable..": "..table.concat(temptable[#temptable],","))
                i = i+1
            end
            for j=1,#temptable do
                for k=1,#ECC_Settings do
                    if temptable[j][1] == ECC_Settings[k][1] then
                        --print("Match temptable "..temptable[j][1].." with Settings table "..ECC_Settings[k][1].." at "..k)
                        ECC_Settings[k][2] = tonumber(temptable[j][2]) -- Current value(s)
                    end
                end
            end       
        end
        file:close()
        --for l=1,#ECC_Settings do print(table.concat(ECC_Settings[l],": ")) end
		if i ~= nil and i > 0 then ECC_Notification("FILE READ SUCCESS: "..ECC_SettingsFile,"Success","log") else ECC_Notification("FILE READ ERROR: "..ECC_SettingsFile,"Error","log") end
    else
        ECC_Notification("FILE NOT FOUND: "..ECC_SettingsFile,"Error","log")
		--ECC_Check_AutoLoad = false
	end   
end
--[[ Settings file delete ]]
function ECC_SettingsFileDelete()
   os.remove(ECC_SettingsFile) ECC_Notification("FILE DELETE: "..ECC_SettingsFile,"Warning")
end
--[[ Check Autosave status ]]
function ECC_Settings_CheckAutosave(log)
    if ECC_SettingsValGet("AutoSave") == 1 then
        if log == "log" then ECC_SettingsFileWrite("log")
        else ECC_SettingsFileWrite() end
    end
end
--[[ Determine string from value ]]
function ECC_ValToStr(input)
    local string = ""
        if input == 0 then string = "Enable" 
        elseif input == 1 then string = "Disable" end
    return string
end
--[[ Splits a line at the designated delimiter ]]
function ECC_Settings_LineSplit(input,delim)
	ECC_Settings_LineSplitResult = {}
	--print(input)
	for i in string.gmatch(input,delim) do table.insert(ECC_Settings_LineSplitResult,i) end
	--print("ECC_Settings_LineSplitResult: "..table.concat(ECC_Settings_LineSplitResult,",",1,#ECC_Settings_LineSplitResult))
	return ECC_Settings_LineSplitResult
end
--[[ Page initialization ]]
local function ECC_Page_Init()
    if ECC_PageInitStatus == 0 then ECC_Refresh_PageDB(ECC_PageTitle) ECC_PageInitStatus = 1 end
end
--[[

IMGUI WINDOW ELEMENT

]]
function ECC_Win_Settings()
    --[[ Check page init status ]]
    ECC_Page_Init()
    --[[ Button ]]
    if ECC_SettingsValGet("Window_Page") == ECC_PageNumGet("Main Menu") then
        imgui.Dummy((ECC_SettingsValGet("Window_W")-30),19)
        if imgui.Button(ECC_PageTitle,(ECC_SettingsValGet("Window_W")-30),20) then
            ECC_SettingsValSet("Window_Page",ECC_PageNumGet(ECC_PageTitle))
            ECC_Settings_CheckAutosave()
        end
        ECC_ItemTooltip("Manage "..ECC_ScriptName.."' UI and general module settings")
    end
    --[[ Page ]]
    if ECC_SettingsValGet("Window_Page") == ECC_PageNumGet(ECC_PageTitle) then
        --[[ Set the page title ]]
        float_wnd_set_title(ECC_Window, ECC_ScriptName.." ("..ECC_PageTitle..")")
        --[[ "Main Menu" button ]]
        ECC_Win_Button_Back("Main Menu")
        --[[ Message display time ]]
        imgui.PushItemWidth(50)
        local changed,buffer = imgui.InputInt("  Notification Display Time (Seconds) ##10",ECC_SettingsValGet("NotificationDispTime"),0,0)
        if changed then ECC_SettingsValSet("NotificationDispTime",buffer) ECC_Settings_CheckAutosave() buffer = nil end
        ECC_ItemTooltip("Affects notifications at the bottom of the main window")
        imgui.PopItemWidth()
        imgui.Dummy((ECC_SettingsValGet("Window_W")-30),19)
        --[[ Hotkey options ]]
        if imgui.Button(ECC_ValToStr(ECC_SettingsValGet("WindowToggleByHotkey")).." Window Toggling By Hotkey ##20",(ECC_SettingsValGet("Window_W")-30),20) then
            if ECC_SettingsValGet("WindowToggleByHotkey") == 0 then ECC_SettingsValSet("WindowToggleByHotkey",1)
            elseif ECC_SettingsValGet("WindowToggleByHotkey") == 1 then ECC_SettingsValSet("WindowToggleByHotkey",0) end
            ECC_Settings_CheckAutosave()
        end
        ECC_ItemTooltip("Manages a custom hotkey for toggling the main window, avoiding a permanent key binding in X-Plane's keyboard configuration menu.\nWARNING: This key will be blocked for use by X-Plane or any other script/tool")
        if ECC_SettingsValGet("WindowToggleByHotkey") == 1 then
            imgui.PushItemWidth(((ECC_SettingsValGet("Window_W") / 2)-30))
            local changed,buffer = imgui.InputInt("  Keyboard Key Code##21",ECC_SettingsValGet("WindowToggleHotkey"),0,0)
            if changed then ECC_SettingsValSet("WindowToggleHotkey",buffer) ECC_Settings_CheckAutosave() buffer = nil end
            ECC_ItemTooltip("Find keyboard key codes with FlyWithLua's 'Show Keystroke Numbers' function (see FWL menu).\nAlternatively, you can assign a key to this script's 'Toggle Window' command in XP11's keyboard assignment menu. Make sure to disable this internal hotkey before doing so.")
            imgui.PopItemWidth() 
            imgui.Dummy((ECC_SettingsValGet("Window_W")-30),19)
        end
        --[[ Autosave options ]]
        if imgui.Button(ECC_ValToStr(ECC_SettingsValGet("AutoSave")).." Autosave##30",(ECC_SettingsValGet("Window_W")-30),20) then
            if ECC_SettingsValGet("AutoSave") == 0 then ECC_SettingsValSet("AutoSave",1)
            elseif ECC_SettingsValGet("AutoSave") == 1 then ECC_SettingsValSet("AutoSave",0) end
            ECC_SettingsFileWrite()
        end
        ECC_ItemTooltip("Toggles global autosaving (UI and all modules) for "..ECC_ScriptName)
    --			if ECC_SettingsValGet("AutoSave") then
    --				imgui.SameLine() imgui.TextUnformatted("(interval in seconds):") imgui.SameLine()
    --				local changed, newAutoSave_Time = imgui.InputText("##41", ECC_Preferences.AutoSave_Time, 4)
    --				if changed and newAutoSave_Time ~= "" and tonumber(newAutoSave_Time) then ECC_Preferences.AutoSave_Time = newAutoSave_Time ECC_SettingsFileWrite() end
    --			end
        --[[ Autoload options ]]
        if imgui.Button(ECC_ValToStr(ECC_SettingsValGet("AutoLoad")).." Autoload##40",(ECC_SettingsValGet("Window_W")-30),20) then
            if ECC_SettingsValGet("AutoLoad") == 0 then ECC_SettingsValSet("AutoLoad",1)
            elseif ECC_SettingsValGet("AutoLoad") == 1 then ECC_SettingsValSet("AutoLoad",0) end
            ECC_SettingsFileWrite()
        end
        ECC_ItemTooltip("Toggles global autloading (UI and all modules) after script start for "..ECC_ScriptName)
        imgui.Dummy((ECC_SettingsValGet("Window_W")-30),19)
        -- [[ Window information ]]
        imgui.TextUnformatted("Current Window Size (W,H) / Pos. (X,Y): "..imgui.GetWindowWidth()..","..imgui.GetWindowHeight().." / "..ECC_Window_Pos[1]..","..ECC_Window_Pos[2])
        imgui.TextUnformatted("Screen Width / Height:                  "..SCREEN_WIDTH.." x "..SCREEN_HIGHT.." Px")
        ECC_GetWindowInfo()
        imgui.TextUnformatted("Window size is saved automatically!")
        imgui.Dummy((ECC_SettingsValGet("Window_W")-30),19)
        -- [[ Settings file control buttons ]]
        if imgui.Button("Save UI Settings ##50",(ECC_SettingsValGet("Window_W")-30),20) then ECC_SettingsFileWrite() end
        ECC_ItemTooltip("Saves stored UI settings to "..ECC_SettingsFile)
        if imgui.Button("Load UI Settings ##60",(ECC_SettingsValGet("Window_W")-30),20) then ECC_SettingsFileRead() end
        ECC_ItemTooltip("Loads stored UI settings from "..ECC_SettingsFile)
        imgui.Dummy((ECC_SettingsValGet("Window_W")-30),19)
        if imgui.Button("Delete UI Settings",(ECC_SettingsValGet("Window_W")-30),20) then ECC_SettingsFileDelete() ECC_Initialized = false end
        ECC_ItemTooltip("Deletes stored UI settings")
        -- End of settings page 		
    end
end
