--[[

Lua Module, required by ECS_Controller.lua
Licensed under the EUPL v1.2: https://eupl.eu/

]]
--[[

VARIABLES (local to this module)

]]
local ECSC_PageTitle = "Cloud/Sky Settings"      -- Page title
local ECSC_PageInitStatus = 0            -- Page initialization variable
local ECSC_PresetDirectory = MODULES_DIRECTORY.."ECS_Controller"
local ECSC_PresetLastSelected = "New Preset" -- DO NOT CHANGE
local PresetList = {"New Preset"} -- DO NOT ADD MORE ELEMENTS HERE
local PresetSaveModeActive = false     -- Is the save mode for a new preset active?
local TempPresetName = ""
local ECSC_Cld_Subpage = 1
local ECSC_Cld_AdvMode = false
local ECSC_SubPageAssignments = { }
--[[

FUNCTIONS

]]
--[[ Write record file of last preset used ]]
local function ECSC_LastPresetFileWrite()
    --ECSC_Log_Write("FILE INIT WRITE: "..outputfile)
    local file = io.open(ECSC_PresetDirectory.."/ActivePreset.cfg", "w")
    file:write(ECSC_PresetLastSelected)
    --if file:seek("end") > 0 then ECSC_Notification("FILE WRITE SUCCESS: "..outputfile,"Success","log") else ECSC_Notification("FILE WRITE ERROR: "..outputfile,"Error","log") end
	file:close()
end
--[[ Read record file of last preset used ]]
local function ECSC_LastPresetFileRead()
    --ECSC_Log_Write("FILE INIT WRITE: "..outputfile)
    local file = io.open(ECSC_PresetDirectory.."/ActivePreset.cfg", "r")
    if file then
        local i = 0
        for line in file:lines() do
            ECSC_PresetLastSelected = line
            i = i+1
        end
        file:close()
        --print(ECSC_PresetLastSelected)
        --if i ~= nil and i > 0 then ECSC_Notification("FILE READ SUCCESS: "..inputfile,"Success","log") else ECSC_Notification("FILE READ ERROR: "..inputfile,"Error","log") end
    end
end
--[[ Preset selector ]]
local function ECSC_PresetSelector(inputtable)
    if not PresetSaveModeActive then
        imgui.TextUnformatted("Active Preset:      ") imgui.SameLine()
        imgui.PushItemWidth(ECSC_SettingsValGet("Window_W")-315)
        if imgui.BeginCombo("##presetselect010",ECSC_PresetLastSelected) then
            for i = 1, #inputtable do
                if imgui.Selectable(inputtable[i], choice == i) then
                    choice = i
                    ECSC_PresetLastSelected = inputtable[i]
                    if ECSC_PresetLastSelected ~= inputtable[1] then ECSC_LoadPresetVals(ECSC_PresetLastSelected..".cfg") ECSC_LastPresetFileWrite() end
                end
            end
        imgui.EndCombo()
        end
        ECSC_ItemTooltip("Selects a preset from "..ECSC_PresetDirectory)
        imgui.PopItemWidth()
        imgui.SameLine()
        if imgui.Button("Rescan",60,20) then ECSC_GetFileList(ECSC_PresetDirectory,inputtable,"ECSC_Preset") end
        ECSC_ItemTooltip("Scans for presets in "..ECSC_PresetDirectory)
        --imgui.SameLine()
        --if imgui.Button("Load",60,20) then ECSC_LoadPresetVals() end
        imgui.SameLine()
        if imgui.Button("Save",60,20) then
            PresetSaveModeActive = true
            if ECSC_PresetLastSelected == inputtable[1] then TempPresetName = "ECSC_Preset_"..inputtable[1]..".cfg" end
            if ECSC_PresetLastSelected ~= inputtable[1] then TempPresetName = ECSC_PresetLastSelected..".cfg" end
        end
        ECSC_ItemTooltip("Save this preset")
    else
        imgui.TextUnformatted("Save This Preset As:") imgui.SameLine()
        imgui.PushItemWidth(ECSC_SettingsValGet("Window_W")-315)
        local changed,buffer = imgui.InputText("##PresetName",TempPresetName, 31) ECSC_ItemTooltip("Enter the new preset's name (30 characters maximum).")
        if changed and buffer ~= "" and tostring(buffer) then TempPresetName = buffer buffer = nil end
        imgui.PopItemWidth()
        imgui.SameLine()
        if imgui.Button("OK",60,20) then ECSC_PresetFileWrite(TempPresetName) ECSC_PresetLastSelected = TempPresetName:gsub("%.cfg", "") TempPresetName = "" PresetSaveModeActive = false ECSC_GetFileList(ECSC_PresetDirectory,inputtable,"ECSC_Preset") end
        ECSC_ItemTooltip("Save this preset to "..ECSC_PresetDirectory)
        imgui.SameLine()
        if imgui.Button("Cancel",60,20) then TempPresetName = "" PresetSaveModeActive = false ECSC_GetFileList(ECSC_PresetDirectory,inputtable,"ECSC_Preset") end
        ECSC_ItemTooltip("Cancel the save process and return to the preset selector")
    end
    imgui.Dummy((ECSC_SettingsValGet("Window_W")-30),10)
end
--[[ Sub page indexer and item counter ]]
function ECSC_SubPageBuilder()
    ECSC_SubPageAssignments = { }
    local highestgroupnum = 0
    local temptable = { }
    -- Loop through dref entries
    for i=1,#ECSC_DatarefTable do
        if ECSC_DatarefTable[i][10] > highestgroupnum then highestgroupnum = ECSC_DatarefTable[i][10] end
    end
    -- Create empty tables in temp table
    for i=1,highestgroupnum do
        temptable[i] = { }
    end
    -- Loop through dref entries
    for i=1,#ECSC_DatarefTable do
        if XPLMFindDataRef(ECSC_DatarefTable[i][1]) ~= nil then
            temptable[ECSC_DatarefTable[i][10]][(#temptable[ECSC_DatarefTable[i][10]]+1)] = i
        end
    end
    for m=1,#temptable do
       if #temptable[m] ~= 0 then
           ECSC_SubPageAssignments[#ECSC_SubPageAssignments+1] = temptable[m]
       end
    end
    --[[for m=1,#ECSC_SubPageAssignments do
        print("ECC: Subpage "..m.." items: "..table.concat(ECSC_SubPageAssignments[m],",").." ("..#ECSC_SubPageAssignments[m]..")")
    end]]
end
--[[ Convert a floating number to a percentage ]]
function ECSC_FloatToPercent(input,limitlow,limithigh)
    local output_pct = 0
    output_pct = (input / (limithigh - limitlow)) * 100
    return output_pct
end
--[[ Convert a percentage to a floating number ]]
function ECSC_PercentToFloat(input,limitlow,limithigh)
    output_float = (input * (limithigh - limitlow)) / 100
    return output_float
end
--[[ Splits a line at the designated delimiter ]]
function ECSC_Clouds_LineSplit(input,delim)
	ECSC_Clouds_LineSplitResult = {}
	--print(input)
	for i in string.gmatch(input,delim) do table.insert(ECSC_Clouds_LineSplitResult,i) end
	--print("ECSC_Clouds_LineSplitResult: "..table.concat(ECSC_Clouds_LineSplitResult,",",1,#ECSC_Clouds_LineSplitResult))
	return ECSC_Clouds_LineSplitResult
end
-- [[ Input elements like sliders and buttons]]
function ECSC_InputElements(index,subindex,mode,displayformat)
    imgui.PushItemWidth(ECSC_SettingsValGet("Window_W") - 190)
    if mode == 1 then
        -- Slider in percentage
        local changed,buffer = imgui.SliderFloat("%##Slider pct"..index..subindex,ECSC_FloatToPercent(ECSC_DatarefTable[index][3][subindex],ECSC_DatarefTable[index][6][1],ECSC_DatarefTable[index][6][2]),0,100,"%."..displayformat.."f")
        if changed then ECSC_DatarefTable[index][3][subindex] = ECSC_PercentToFloat(buffer,ECSC_DatarefTable[index][6][1],ECSC_DatarefTable[index][6][2]) buffer = nil end
    elseif mode == 0 then
        local changed,buffer = imgui.SliderFloat(" ##Slider num"..index..subindex,ECSC_DatarefTable[index][3][subindex],ECSC_DatarefTable[index][6][1],ECSC_DatarefTable[index][6][2],"%."..displayformat.."f")
        if changed then ECSC_DatarefTable[index][3][subindex] = buffer buffer = nil end
    end
    imgui.PopItemWidth() imgui.SameLine()
    --
    imgui.PushItemWidth(75)
    if mode == 1 then
        local changed,buffer = imgui.InputFloat("##Text pct"..index..subindex, ECSC_FloatToPercent(ECSC_DatarefTable[index][3][subindex],ECSC_DatarefTable[index][6][1],ECSC_DatarefTable[index][6][2]),0,0,"%."..ECSC_DatarefTable[index][9].."f")
        if changed then
            if buffer < 0 then ECSC_DatarefTable[index][3][subindex] = ECSC_PercentToFloat(0,ECSC_DatarefTable[index][6][1],ECSC_DatarefTable[index][6][2])
            elseif buffer > 100 then ECSC_DatarefTable[index][3][subindex] = ECSC_PercentToFloat(100,ECSC_DatarefTable[index][6][1],ECSC_DatarefTable[index][6][2])
            else ECSC_DatarefTable[index][3][subindex] = ECSC_PercentToFloat(buffer,ECSC_DatarefTable[index][6][1],ECSC_DatarefTable[index][6][2]) end
            buffer = nil
        end
        imgui.SameLine() imgui.TextUnformatted("%")
    elseif mode == 0 then
       local changed,buffer = imgui.InputFloat("##Text num"..index..subindex, ECSC_DatarefTable[index][3][subindex],ECSC_DatarefTable[index][6][1], ECSC_DatarefTable[index][6][2],"%."..ECSC_DatarefTable[index][9].."f")
        if changed then
            if buffer < ECSC_DatarefTable[index][6][1] then ECSC_DatarefTable[index][3][subindex] = ECSC_DatarefTable[index][6][1]
            elseif buffer > ECSC_DatarefTable[index][6][2] then ECSC_DatarefTable[index][3][subindex] = ECSC_DatarefTable[index][6][2]
            else ECSC_DatarefTable[index][3][subindex] = buffer end
            buffer = nil
        end
        imgui.SameLine() imgui.TextUnformatted(" ")
    end
    imgui.SameLine()
    imgui.PopItemWidth()
    if imgui.Button("Reset ##"..index..subindex,45,20) then ECSC_DatarefTable[index][3][subindex] = ECSC_DatarefTable[index][5][subindex] end
    ECSC_ItemTooltip("Resets this value to the plugin default")
end
--[[ Delete a preset file ]]
function ECSC_PresetFileDelete()
   os.remove(ECSC_PresetFile) ECSC_Notification("FILE DELETE: "..ECSC_PresetFile,"Warning")
end
--[[ Write preset file ]]
function ECSC_PresetFileWrite(filename)
    local outputfile = ECSC_PresetDirectory.."/"..filename
    ECSC_Log_Write("FILE INIT WRITE: "..outputfile)
    local file = io.open(outputfile, "w")
    file:write("Enhanced Cloudscapes Controller preset created/updated on ",os.date("%x, %H:%M:%S"),"\n")
    file:write("\n")
    for d=1,#ECSC_DatarefTable do
        --print("{"..ECSC_DatarefTable[d][1]..",{"..table.concat(ECSC_DatarefTable[d][3],",",0).."}}")
        if ECSC_DatarefTable[d][3][0] ~= nil then
            file:write(ECSC_DatarefTable[d][1]..";"..table.concat(ECSC_DatarefTable[d][3],",",0)..";"..ECSC_DatarefTable[d][4]..";"..table.concat(ECSC_DatarefTable[d][6],",")..";"..tostring(ECSC_DatarefTable[d][8])..";"..ECSC_DatarefTable[d][9]..";"..ECSC_DatarefTable[d][10].."\n")
        end
    end
    if file:seek("end") > 0 then ECSC_Notification("FILE WRITE SUCCESS: "..outputfile,"Success","log") else ECSC_Notification("FILE WRITE ERROR: "..outputfile,"Error","log") end
	file:close()
end
--[[ Read preset file ]]
function ECSC_PresetFileRead(filename)
    local inputfile = ECSC_PresetDirectory.."/"..filename
    local file = io.open(inputfile, "r")
    if file then
        ECSC_Log_Write("FILE INIT READ: "..inputfile)
        local i = 0
        local temptable = { }
        for line in file:lines() do
            if string.match(line,"^enhanced") then
                ECSC_Clouds_LineSplit(line,"([^;]+)")
                temptable[#temptable+1] = ECSC_Clouds_LineSplitResult
                -- Dataref to look for
                temptable[#temptable][1] = tostring(temptable[#temptable][1])
                ECSC_Clouds_LineSplit(temptable[#temptable][2],"([^,]+)")
                -- Current values
                temptable[#temptable][2] = {}
                for j=1,#ECSC_Clouds_LineSplitResult do
                    temptable[#temptable][2][j-1] = tonumber(ECSC_Clouds_LineSplitResult[j])
                end
                -- Caption
                -- Value rangle limits
                ECSC_Clouds_LineSplit(temptable[#temptable][4],"([^,]+)")
                temptable[#temptable][4] = {}
                for j=1,#ECSC_Clouds_LineSplitResult do
                    temptable[#temptable][4][j] = tonumber(ECSC_Clouds_LineSplitResult[j])
                end
                -- Display in percent true/false
                temptable[#temptable][5] = tonumber(temptable[#temptable][5])
                -- Display precision
                temptable[#temptable][6] = tonumber(temptable[#temptable][6])
                -- Group
                temptable[#temptable][7] = tonumber(temptable[#temptable][7])
            end
            i = i+1
        end
        for j=1,#temptable do
           for k=1,#ECSC_DatarefTable do
                if temptable[j][1] == ECSC_DatarefTable[k][1] then
                    -- print("Match temptable "..temptable[j][1].." with Dref table "..ECSC_DatarefTable[k][1].." at "..k)
                    ECSC_DatarefTable[k][3] = temptable[j][2] -- Current value(s)
                    ECSC_DatarefTable[k][4] = temptable[j][3] -- Caption
                    ECSC_DatarefTable[k][6] = temptable[j][4] -- Value range limits
                    ECSC_DatarefTable[k][8] = temptable[j][5] -- Display in percent
                    ECSC_DatarefTable[k][9] = temptable[j][6] -- Display precision
                    ECSC_DatarefTable[k][10] = temptable[j][7] -- Group

                end
           end
        end
        --[[for j=1,#temptable do
            print(type(temptable[j][1])..": "..temptable[j][1].." ; "..type(temptable[j][2])..": "..table.concat(temptable[j][2],",",0).." ; "..type(temptable[j][3])..": "..temptable[j][3].." ; "..type(temptable[j][4])..": "..table.concat(temptable[j][4],",").." ; "..type(temptable[j][5])..": "..temptable[j][5].." ; "..type(temptable[j][6])..": "..temptable[j][6].." ; "..type(temptable[j][7])..": "..temptable[j][7])
        end]]
        file:close()
		if i ~= nil and i > 0 then ECSC_Notification("FILE READ SUCCESS: "..inputfile,"Success","log") else ECSC_Notification("FILE READ ERROR: "..inputfile,"Error","log") end
    else
        ECSC_Notification("FILE NOT FOUND: "..inputfile,"Error","log")
		--ECSC_Check_AutoLoad = false
	end
end
--[[ Preset load handler ]]
function ECSC_LoadPresetVals(filename)
    ECSC_Log_Write("ECC PRESET: Started loading values from "..filename)
    ECSC_PresetFileRead(filename)                -- Read preset file
    ECSC_AccessDref(ECSC_DatarefTable,"write")    -- Write values to datarefs
    ECSC_SubPageBuilder()                        -- Build subpage indexes
    ECSC_Cld_Subpage = #ECSC_SubPageAssignments   -- Limit page selection to avoid landing on a blank page
    ECSC_Log_Write("ECC PRESET: Finished loading values from "..filename)
end
--[[ 

INITIALIZATION

]]
function ECSC_ModuleInit_Main()
    -- Check if plugin is installed and display logged notifications
    ECSC_FindInopDrefs(ECSC_DatarefTable)
    -- If yes, do the remaining init stuff
    if ECSC_PluginInstalled then
        ECSC_AccessDref(ECSC_DatarefTable,"read")    -- Read dataref values
        ECSC_CopyDefaults(ECSC_DatarefTable)         -- Note default dataref values
        ECSC_SubPageBuilder()                    -- Index number of subpages with items
        ECSC_GetFileList(ECSC_PresetDirectory,PresetList,"ECSC_Preset")
        if #PresetList >= 1 then ECSC_PresetLastSelected = PresetList[1] end
        if ECSC_SettingsValGet("AutoLoad") == 1 then
            ECSC_LastPresetFileRead()
            if ECSC_PresetLastSelected ~= PresetList[1] then ECSC_LoadPresetVals(ECSC_PresetLastSelected..".cfg") ECSC_Log_Write("ECC PRESET: Triggered loading values from "..ECSC_PresetLastSelected..".cfg") end
        end
    end
end
--[[ 

IMGUI WINDOW ELEMENT

]]
--[[ Window page initialization ]]
local function ECSC_Page_Init()
    if ECSC_PageInitStatus == 0 then ECSC_Refresh_PageDB(ECSC_PageTitle) ECSC_PageInitStatus = 1 end
end
--[[ Window content ]]
function ECSC_Win_Main()
    --[[ Check page init status ]]
    ECSC_Page_Init()
    --[[ Button ]]
    if ECSC_SettingsValGet("Window_Page") == ECSC_PageNumGet("Main Menu") then
        --imgui.Dummy((ECSC_SettingsValGet("Window_W")-30),19)
        if imgui.Button(ECSC_PageTitle,(ECSC_SettingsValGet("Window_W")-30),20) then
            ECSC_SettingsValSet("Window_Page",ECSC_PageNumGet(ECSC_PageTitle))
            float_wnd_set_title(ECSC_Window, ECSC_ScriptName.." ("..ECSC_PageTitle..")")
            ECSC_Settings_CheckAutosave()
        end
        ECSC_ItemTooltip("Opens the Cloud Settings window")
    end
    --[[ Page ]]
    if ECSC_SettingsValGet("Window_Page") == ECSC_PageNumGet(ECSC_PageTitle) then
        --[[ Set the page title ]]
        float_wnd_set_title(ECSC_Window, ECSC_ScriptName.." ("..ECSC_PageTitle..")")
        --[[ "Main Menu" button ]]
        ECSC_Win_Button_Back("Main Menu")
        imgui.Dummy((ECSC_SettingsValGet("Window_W")-30),10)
        --[[ File content ]]
        --[["Plugin not installed" warning ]]
        if not ECSC_PluginInstalled then
            imgui.PushStyleColor(imgui.constant.Col.Text, ECSC_ImguiColors[4]) imgui.TextUnformatted("\"Enchanced Cloudscapes\" plugin is not installed!") imgui.PopStyleColor()
        else
            ECSC_PresetSelector(PresetList)
            --[[ Sub page flip buttons ]]
            if imgui.Button("<< ##a",20,20) then ECSC_Cld_Subpage = ECSC_Cld_Subpage - 1 if ECSC_Cld_Subpage == 0 then ECSC_Cld_Subpage = #ECSC_SubPageAssignments end end
            imgui.SameLine() imgui.Dummy((ECSC_SettingsValGet("Window_W")-185) / 2,20) imgui.SameLine()
            imgui.TextUnformatted("Group "..ECSC_Cld_Subpage.." of "..#ECSC_SubPageAssignments)
            imgui.SameLine() imgui.Dummy((ECSC_SettingsValGet("Window_W")-185) / 2,20) imgui.SameLine()
            if imgui.Button(">> ##b",20,20) then ECSC_Cld_Subpage = ECSC_Cld_Subpage + 1 if ECSC_Cld_Subpage > #ECSC_SubPageAssignments then ECSC_Cld_Subpage = 1 end end
            --[[ Read datarefs ]]
            ECSC_AccessDref(ECSC_DatarefTable,"read")
            --[[ Begin subwindow ]]
            -- Loop thorugh the selected section of the sub page assignment table
            for q=1,#ECSC_SubPageAssignments[ECSC_Cld_Subpage] do
                local inputindex = ECSC_SubPageAssignments[ECSC_Cld_Subpage][q]
                imgui.Dummy((ECSC_SettingsValGet("Window_W")-30),15)
                -- Caption
                if not ECSC_Cld_AdvMode then
                    imgui.TextUnformatted(ECSC_DatarefTable[inputindex][4]..":")
                else
                    imgui.PushItemWidth(ECSC_SettingsValGet("Window_W") - 190)
                    local changed,buffer = imgui.InputText("##"..inputindex,ECSC_DatarefTable[inputindex][4],48)
                    if changed then ECSC_DatarefTable[inputindex][4] = buffer end
                    imgui.PopItemWidth()
                end
                --
                for k=0,#ECSC_DatarefTable[inputindex][3] do
                    ECSC_InputElements(inputindex,k,ECSC_DatarefTable[inputindex][8],ECSC_DatarefTable[inputindex][9])
                end
                --Advanced: Text input for value range limit
                if ECSC_Cld_AdvMode then
                    --Display mode selector button
                    local currentmode = ECSC_DatarefTable[inputindex][8]
                    local buttoncaption = ""
                    if currentmode == 0 then buttoncaption = "Switch Display To Percentage" end
                    if currentmode == 1 then buttoncaption = "Switch Display To Numerical" end
                    if imgui.Button(buttoncaption.."##dispmode"..inputindex,(ECSC_SettingsValGet("Window_W") - 190),20) then
                        if ECSC_DatarefTable[inputindex][8] == 1 then
                            ECSC_DatarefTable[inputindex][8] = 0
                            for l=0,#ECSC_DatarefTable[inputindex][3] do
                                ECSC_PercentToFloat(ECSC_DatarefTable[inputindex][3][l],ECSC_DatarefTable[inputindex][6][1],ECSC_DatarefTable[inputindex][6][2])
                                ECSC_DatarefTable[inputindex][9] = 6
                            end
                        elseif ECSC_DatarefTable[inputindex][8] == 0 then
                            ECSC_DatarefTable[inputindex][8] = 1
                            for l=0,#ECSC_DatarefTable[inputindex][3] do
                                ECSC_FloatToPercent(ECSC_DatarefTable[inputindex][3][l],ECSC_DatarefTable[inputindex][6][1],ECSC_DatarefTable[inputindex][6][2])
                                ECSC_DatarefTable[inputindex][9] = 1
                            end
                        end
                    end
                    -- Low limit
                    imgui.TextUnformatted("Lower Raw Value Limit: ") imgui.SameLine()
                    imgui.PushItemWidth(100)
                    local changed,buffer = imgui.InputFloat("##Lo"..inputindex, ECSC_DatarefTable[inputindex][6][1],0,0,"%.10f") imgui.SameLine()
                    if changed then ECSC_DatarefTable[inputindex][6][1] = buffer buffer = nil end
                    imgui.PopItemWidth()
                    if imgui.Button("Reset ##Lo"..inputindex,50,20) then ECSC_DatarefTable[inputindex][6][1] = ECSC_DatarefTable[inputindex][7][1] end
                    -- High limit
                    imgui.TextUnformatted("Upper Raw Value Limit: ") imgui.SameLine()
                    imgui.PushItemWidth(100)
                    local changed,buffer = imgui.InputFloat("##Hi"..inputindex, ECSC_DatarefTable[inputindex][6][2],0,0,"%.10f") imgui.SameLine()
                    if changed then ECSC_DatarefTable[inputindex][6][2] = buffer buffer = nil end
                    imgui.PopItemWidth()
                    if imgui.Button("Reset ##Hi"..inputindex,50,20) then ECSC_DatarefTable[inputindex][6][2] = ECSC_DatarefTable[inputindex][7][2] end
                    -- Precision
                    imgui.TextUnformatted("Display Precision    : ") imgui.SameLine()
                    imgui.PushItemWidth(100)
                    local changed,buffer = imgui.InputInt("##Decimals"..inputindex, ECSC_DatarefTable[inputindex][9],0,0)
                    if changed then ECSC_DatarefTable[inputindex][9] = buffer buffer = nil end
                    imgui.PopItemWidth()
                    imgui.TextUnformatted("Display In Group     : ") imgui.SameLine()
                    imgui.PushItemWidth(100)
                    local changed,buffer = imgui.InputInt("Preset##Page"..inputindex, ECSC_DatarefTable[inputindex][10],0,0)
                    if changed then ECSC_DatarefTable[inputindex][10] = buffer buffer = nil end
                    imgui.PopItemWidth() imgui.SameLine()
                    if imgui.Button("Apply ##"..inputindex,50,20) then ECSC_SubPageBuilder() ECSC_Cld_Subpage = #ECSC_SubPageAssignments break end
                end
            --[[ End subwindow ]]
            end
            imgui.Dummy((ECSC_SettingsValGet("Window_W")-30),20)
            --"Advanced" checkbox
            local changed, newECSC_Cld_AdvMode = imgui.Checkbox("Advanced Settings", ECSC_Cld_AdvMode)
            if changed then ECSC_Cld_AdvMode = newECSC_Cld_AdvMode end
            --[[ Write datarefs ]]
            ECSC_AccessDref(ECSC_DatarefTable,"write")
            imgui.Dummy((ECSC_SettingsValGet("Window_W")-30),20)
            --imgui.SameLine() imgui.Dummy((ECSC_SettingsValGet("Window_W")-250),5) imgui.SameLine()
        end
    --[[ End page ]]    
    end
end
