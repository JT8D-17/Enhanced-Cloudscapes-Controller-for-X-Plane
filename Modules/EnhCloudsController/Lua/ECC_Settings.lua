--[[

Lua Module, required by EnhCloudsController.lua
Licensed under the EUPL v1.2: https://eupl.eu/

]]
--[[

VARIABLES

]]
ECC_Settings = {
    WindowToggleByHotkey = 0,
    WindowIsOpen = 1,
    
    
}
--[[

FUNCTIONS

]]



--[[

IMGUI WINDOW ELEMENT

]]
function ECC_Win_Settings()
    --[[ Button ]]
    if ECC_Preferences.Window_Page == 0 then
        imgui.Dummy((ECC_Preferences.AAA_Window_W-30),19)
        if imgui.Button("ECC Preferences",(ECC_Preferences.AAA_Window_W-30),20) then ECC_Preferences.Window_Page = 1 ECC_CheckAutosave() end
    end
    -- [[ Page ]]
    if ECC_Preferences.Window_Page == 1 then
		--[[ "Back" button ]]
        if imgui.Button("Main Menu",(ECC_Preferences.AAA_Window_W-30),20) then ECC_Preferences.Window_Page = 0 ECC_CheckAutosave() end
        imgui.Dummy((ECC_Preferences.AAA_Window_W-30),10)
        imgui.Separator()
        -- Message display time
        imgui.TextUnformatted("Notification Display Time (seconds):") imgui.SameLine()
        imgui.PushItemWidth(50) local changed, newA_NotificationDisplayTime = imgui.InputText("##50", ECC_Preferences.A_NotificationDisplayTime, 3) imgui.PopItemWidth()
        if changed and newA_NotificationDisplayTime ~= "" and tonumber(newA_NotificationDisplayTime) then ECC_Preferences.A_NotificationDisplayTime = tonumber(newA_NotificationDisplayTime) ECC_CheckAutosave() end
        imgui.Dummy((ECC_Preferences.AAA_Window_W-30),19)
        -- [[ Hotkey options ]]
        local displaystringhotkey = ""
        if ECC_Settings.WindowToggleByHotkey == 0 then displaystringhotkey = "Enable" end
        if ECC_Settings.WindowToggleByHotkey == 1 then displaystringhotkey = "Disable" end
        if imgui.Button(displaystringhotkey.." Window Toggling By Hotkey ##1000",200,20) then 
            if ECC_Settings.WindowToggleByHotkey == 0 then ECC_Settings.WindowToggleByHotkey = 1 end 
            if ECC_Settings.WindowToggleByHotkey == 1 then ECC_Settings.WindowToggleByHotkey = 0 end 
            ECC_CheckAutosave() 
        end
        if ECC_Settings.WindowToggleByHotkey == 1 then imgui.SameLine()  imgui.TextUnformatted("(number):") imgui.SameLine()
            local changed, newWindowToggleHotkey = imgui.PushItemWidth(50) imgui.InputInt("##56", ECC_Preferences.AAA_WindowToggleHotkey,0,0) imgui.PopItemWidth() 
            if changed then ECC_Preferences.AAA_WindowToggleHotkey = newWindowToggleHotkey ECC_CheckAutosave() end		
            imgui.PushStyleColor(imgui.constant.Col.Text, ECC_ImguiColors[7]) imgui.TextUnformatted("Find keyboard key codes with FlyWithLua's 'Show Keystroke Numbers' function (see FWL menu).\nAlternatively, you can assign a key to this script's 'Toggle Window' command in XP11's keyboard assignment menu. Make sure to disable this internal hotkey before doing so.") imgui.PopStyleColor()
        end
        --[[ Autosave / Autoload changes ]]
        -- Autosave changes checkbox and options
        local changed, newAutosave = imgui.Checkbox("Autosave Changes##57", ECC_Preferences.AA_Autosave)
        if changed then ECC_Preferences.AA_Autosave = newAutosave ECC_File_Write("PrefsFile") end
    --			if ECC_Preferences.Autosave then
    --				imgui.SameLine() imgui.TextUnformatted("(interval in seconds):") imgui.SameLine()
    --				local changed, newAutoSave_Time = imgui.InputText("##41", ECC_Preferences.AutoSave_Time, 4)
    --				if changed and newAutoSave_Time ~= "" and tonumber(newAutoSave_Time) then ECC_Preferences.AutoSave_Time = newAutoSave_Time ECC_File_Write("PrefsFile") end
    --			end
        local changed, newAutoload = imgui.Checkbox("Autoload on Start##58", ECC_Preferences.AA_Autoload)
        if changed then ECC_Preferences.AA_Autoload = newAutoload ECC_File_Write("PrefsFile") end
        imgui.Dummy((ECC_Preferences.AAA_Window_W-30),19)
        -- [[ Window information ]]
        imgui.TextUnformatted("Current Window Size (W,H) / Pos. (X,Y): "..imgui.GetWindowWidth()..","..imgui.GetWindowHeight().." / "..ECC_Window_Pos[1]..","..ECC_Window_Pos[2])
        imgui.TextUnformatted("Screen Width / Height:                  "..SCREEN_WIDTH.." x "..SCREEN_HIGHT.." Px")
        ECC_GetWindowInfo()
        imgui.TextUnformatted("Window size is saved automatically!")
        imgui.Dummy((ECC_Preferences.AAA_Window_W-30),19)
        -- [[ Preference file control buttons ]]
        if imgui.Button("Save Preferences",(ECC_Preferences.AAA_Window_W-30),20) then ECC_File_Write("PrefsFile") end
        if imgui.Button("Load Preferences",(ECC_Preferences.AAA_Window_W-30),20) then ECC_File_Read("PrefsFile") end
        imgui.Dummy((ECC_Preferences.AAA_Window_W-30),19)
        if imgui.Button("Delete Preference File",(ECC_Preferences.AAA_Window_W-30),20) then ECC_File_Delete("PrefsFile") ECC_Initialized = false end
    -- End of settings page
    end
end
