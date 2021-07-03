--[[

Lua Module, required by EC_Controller.lua
Licensed under the EUPL v1.2: https://eupl.eu/

]]
--[[

VARIABLES (local to this module)

]]
local ECC_PageTitle = "Cloud Settings"      -- Page title
local ECC_PageInitStatus = 0            -- Page initialization variable
local ECC_PresetDirectory = MODULES_DIRECTORY.."EC_Controller"
local ECC_PresetLastSelected = "New Preset" -- DO NOT CHANGE
local PresetList = {"New Preset"} -- DO NOT ADD MORE ELEMENTS HERE
local PresetSaveModeActive = false     -- Is the save mode for a new preset active?
local TempPresetName = ""
local ECC_Cld_Subpage = 1
local ECC_Cld_AdvMode = false
local ECC_SubPageAssignments = { }
--[[

FUNCTIONS

]]
--[[ Write record file of last preset used ]]
local function ECC_LastPresetFileWrite()
    --ECC_Log_Write("FILE INIT WRITE: "..outputfile)
    local file = io.open(ECC_PresetDirectory.."/ActivePreset.cfg", "w")
    file:write(ECC_PresetLastSelected)
    --if file:seek("end") > 0 then ECC_Notification("FILE WRITE SUCCESS: "..outputfile,"Success","log") else ECC_Notification("FILE WRITE ERROR: "..outputfile,"Error","log") end
	file:close()
end
--[[ Read record file of last preset used ]]
local function ECC_LastPresetFileRead()
    --ECC_Log_Write("FILE INIT WRITE: "..outputfile)
    local file = io.open(ECC_PresetDirectory.."/ActivePreset.cfg", "r")
    if file then
        local i = 0
        for line in file:lines() do
            ECC_PresetLastSelected = line
            i = i+1
        end
        file:close()
        print(ECC_PresetLastSelected)
        --if i ~= nil and i > 0 then ECC_Notification("FILE READ SUCCESS: "..inputfile,"Success","log") else ECC_Notification("FILE READ ERROR: "..inputfile,"Error","log") end
    end
end
--[[ Preset selector ]]
local function ECC_PresetSelector(inputtable)
    if not PresetSaveModeActive then
        imgui.TextUnformatted("Active Preset:      ") imgui.SameLine()
        imgui.PushItemWidth(ECC_SettingsValGet("Window_W")-315)
        if imgui.BeginCombo("##presetselect010",ECC_PresetLastSelected) then
            for i = 1, #inputtable do
                if imgui.Selectable(inputtable[i], choice == i) then
                    choice = i
                    ECC_PresetLastSelected = inputtable[i]
                    if ECC_PresetLastSelected ~= inputtable[1] then ECC_LoadPresetVals(ECC_PresetLastSelected..".cfg") ECC_LastPresetFileWrite() end
                end
            end
        imgui.EndCombo()
        end
        ECC_ItemTooltip("Selects a preset from "..ECC_PresetDirectory)
        imgui.PopItemWidth()
        imgui.SameLine()
        if imgui.Button("Rescan",60,20) then ECC_GetFileList(ECC_PresetDirectory,inputtable,"EC_Preset") end
        ECC_ItemTooltip("Scans for presets in "..ECC_PresetDirectory)
        --imgui.SameLine()
        --if imgui.Button("Load",60,20) then ECC_LoadPresetVals() end
        imgui.SameLine()
        if imgui.Button("Save",60,20) then
            PresetSaveModeActive = true
            if ECC_PresetLastSelected == inputtable[1] then TempPresetName = "EC_Preset_"..inputtable[1]..".cfg" end
            if ECC_PresetLastSelected ~= inputtable[1] then TempPresetName = ECC_PresetLastSelected..".cfg" end
        end
        ECC_ItemTooltip("Save this preset")
    else
        imgui.TextUnformatted("Save This Preset As:") imgui.SameLine()
        imgui.PushItemWidth(ECC_SettingsValGet("Window_W")-315)
        local changed,buffer = imgui.InputText("##PresetName",TempPresetName, 31) ECC_ItemTooltip("Enter the new preset's name (30 characters maximum).")
        if changed and buffer ~= "" and tostring(buffer) then TempPresetName = buffer buffer = nil end
        imgui.PopItemWidth()
        imgui.SameLine()
        if imgui.Button("OK",60,20) then ECC_PresetFileWrite(TempPresetName) ECC_PresetLastSelected = TempPresetName:gsub("%.cfg", "") TempPresetName = "" PresetSaveModeActive = false ECC_GetFileList(ECC_PresetDirectory,inputtable,"EC_Preset") end
        ECC_ItemTooltip("Save this preset to "..ECC_PresetDirectory)
        imgui.SameLine()
        if imgui.Button("Cancel",60,20) then TempPresetName = "" PresetSaveModeActive = false ECC_GetFileList(ECC_PresetDirectory,inputtable,"EC_Preset") end
        ECC_ItemTooltip("Cancel the save process and return to the preset selector")
    end
    imgui.Dummy((ECC_SettingsValGet("Window_W")-30),10)
end
--[[ Sub page indexer and item counter ]]
function ECC_SubPageBuilder()
    ECC_SubPageAssignments = { }
    local highestgroupnum = 0
    local temptable = { }
    -- Loop through dref entries
    for i=1,#ECC_DatarefTable do
        if ECC_DatarefTable[i][10] > highestgroupnum then highestgroupnum = ECC_DatarefTable[i][10] end
    end
    -- Create empty tables in temp table
    for i=1,highestgroupnum do
        temptable[i] = { }
    end
    -- Loop through dref entries
    for i=1,#ECC_DatarefTable do
        if XPLMFindDataRef(ECC_DatarefTable[i][1]) ~= nil then
            temptable[ECC_DatarefTable[i][10]][(#temptable[ECC_DatarefTable[i][10]]+1)] = i
        end
    end
    for m=1,#temptable do
       if #temptable[m] ~= 0 then
           ECC_SubPageAssignments[#ECC_SubPageAssignments+1] = temptable[m]
       end
    end
    --[[for m=1,#ECC_SubPageAssignments do
        print("ECC: Subpage "..m.." items: "..table.concat(ECC_SubPageAssignments[m],",").." ("..#ECC_SubPageAssignments[m]..")")
    end]]
end
--[[ Convert a floating number to a percentage ]]
function ECC_FloatToPercent(input,limitlow,limithigh)
    local output_pct = 0
    output_pct = (input / (limithigh - limitlow)) * 100
    return output_pct
end
--[[ Convert a percentage to a floating number ]]
function ECC_PercentToFloat(input,limitlow,limithigh)
    output_float = (input * (limithigh - limitlow)) / 100
    return output_float
end
--[[ Splits a line at the designated delimiter ]]
function ECC_Clouds_LineSplit(input,delim)
	ECC_Clouds_LineSplitResult = {}
	--print(input)
	for i in string.gmatch(input,delim) do table.insert(ECC_Clouds_LineSplitResult,i) end
	--print("ECC_Clouds_LineSplitResult: "..table.concat(ECC_Clouds_LineSplitResult,",",1,#ECC_Clouds_LineSplitResult))
	return ECC_Clouds_LineSplitResult
end
-- [[ Input elements like sliders and buttons]]
function ECC_InputElements(index,subindex,mode,displayformat)
    imgui.PushItemWidth(ECC_SettingsValGet("Window_W") - 190)
    if mode == 1 then
        -- Slider in percentage
        local changed,buffer = imgui.SliderFloat("%##Slider pct"..index..subindex,ECC_FloatToPercent(ECC_DatarefTable[index][3][subindex],ECC_DatarefTable[index][6][1],ECC_DatarefTable[index][6][2]),0,100,"%."..displayformat.."f")
        if changed then ECC_DatarefTable[index][3][subindex] = ECC_PercentToFloat(buffer,ECC_DatarefTable[index][6][1],ECC_DatarefTable[index][6][2]) buffer = nil end
    elseif mode == 0 then
        local changed,buffer = imgui.SliderFloat(" ##Slider num"..index..subindex,ECC_DatarefTable[index][3][subindex],ECC_DatarefTable[index][6][1],ECC_DatarefTable[index][6][2],"%."..displayformat.."f")
        if changed then ECC_DatarefTable[index][3][subindex] = buffer buffer = nil end
    end
    imgui.PopItemWidth() imgui.SameLine()
    --
    imgui.PushItemWidth(75)
    if mode == 1 then
        local changed,buffer = imgui.InputFloat("##Text pct"..index..subindex, ECC_FloatToPercent(ECC_DatarefTable[index][3][subindex],ECC_DatarefTable[index][6][1],ECC_DatarefTable[index][6][2]),0,0,"%."..ECC_DatarefTable[index][9].."f")
        if changed then
            if buffer < 0 then ECC_DatarefTable[index][3][subindex] = ECC_PercentToFloat(0,ECC_DatarefTable[index][6][1],ECC_DatarefTable[index][6][2])
            elseif buffer > 100 then ECC_DatarefTable[index][3][subindex] = ECC_PercentToFloat(100,ECC_DatarefTable[index][6][1],ECC_DatarefTable[index][6][2])
            else ECC_DatarefTable[index][3][subindex] = ECC_PercentToFloat(buffer,ECC_DatarefTable[index][6][1],ECC_DatarefTable[index][6][2]) end
            buffer = nil
        end
        imgui.SameLine() imgui.TextUnformatted("%")
    elseif mode == 0 then
       local changed,buffer = imgui.InputFloat("##Text num"..index..subindex, ECC_DatarefTable[index][3][subindex],ECC_DatarefTable[index][6][1], ECC_DatarefTable[index][6][2],"%."..ECC_DatarefTable[index][9].."f")
        if changed then
            if buffer < ECC_DatarefTable[index][6][1] then ECC_DatarefTable[index][3][subindex] = ECC_DatarefTable[index][6][1]
            elseif buffer > ECC_DatarefTable[index][6][2] then ECC_DatarefTable[index][3][subindex] = ECC_DatarefTable[index][6][2]
            else ECC_DatarefTable[index][3][subindex] = buffer end
            buffer = nil
        end
        imgui.SameLine() imgui.TextUnformatted(" ")
    end
    imgui.SameLine()
    imgui.PopItemWidth()
    if imgui.Button("Reset ##"..index..subindex,45,20) then ECC_DatarefTable[index][3][subindex] = ECC_DatarefTable[index][5][subindex] end
    ECC_ItemTooltip("Resets this value to the plugin default")
end
--[[ Delete a preset file ]]
function ECC_PresetFileDelete()
   os.remove(ECC_PresetFile) ECC_Notification("FILE DELETE: "..ECC_PresetFile,"Warning")
end
--[[ Write preset file ]]
function ECC_PresetFileWrite(filename)
    local outputfile = ECC_PresetDirectory.."/"..filename
    ECC_Log_Write("FILE INIT WRITE: "..outputfile)
    local file = io.open(outputfile, "w")
    file:write("Enhanced Cloudscapes Controller preset created/updated on ",os.date("%x, %H:%M:%S"),"\n")
    file:write("\n")
    for d=1,#ECC_DatarefTable do
        --print("{"..ECC_DatarefTable[d][1]..",{"..table.concat(ECC_DatarefTable[d][3],",",0).."}}")
        if ECC_DatarefTable[d][3][0] ~= nil then
            file:write(ECC_DatarefTable[d][1]..";"..table.concat(ECC_DatarefTable[d][3],",",0)..";"..ECC_DatarefTable[d][4]..";"..table.concat(ECC_DatarefTable[d][6],",")..";"..tostring(ECC_DatarefTable[d][8])..";"..ECC_DatarefTable[d][9]..";"..ECC_DatarefTable[d][10].."\n")
        end
    end
    if file:seek("end") > 0 then ECC_Notification("FILE WRITE SUCCESS: "..outputfile,"Success","log") else ECC_Notification("FILE WRITE ERROR: "..outputfile,"Error","log") end
	file:close()
end
--[[ Read preset file ]]
function ECC_PresetFileRead(filename)
    local inputfile = ECC_PresetDirectory.."/"..filename
    local file = io.open(inputfile, "r")
    if file then
        ECC_Log_Write("FILE INIT READ: "..inputfile)
        local i = 0
        local temptable = { }
        for line in file:lines() do
            if string.match(line,"^enhanced") then
                ECC_Clouds_LineSplit(line,"([^;]+)")
                temptable[#temptable+1] = ECC_Clouds_LineSplitResult
                -- Dataref to look for
                temptable[#temptable][1] = tostring(temptable[#temptable][1])
                ECC_Clouds_LineSplit(temptable[#temptable][2],"([^,]+)")
                -- Current values
                temptable[#temptable][2] = {}
                for j=1,#ECC_Clouds_LineSplitResult do
                    temptable[#temptable][2][j-1] = tonumber(ECC_Clouds_LineSplitResult[j])
                end
                -- Caption
                -- Value rangle limits
                ECC_Clouds_LineSplit(temptable[#temptable][4],"([^,]+)")
                temptable[#temptable][4] = {}
                for j=1,#ECC_Clouds_LineSplitResult do
                    temptable[#temptable][4][j] = tonumber(ECC_Clouds_LineSplitResult[j])
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
           for k=1,#ECC_DatarefTable do
                if temptable[j][1] == ECC_DatarefTable[k][1] then
                    -- print("Match temptable "..temptable[j][1].." with Dref table "..ECC_DatarefTable[k][1].." at "..k)
                    ECC_DatarefTable[k][3] = temptable[j][2] -- Current value(s)
                    ECC_DatarefTable[k][4] = temptable[j][3] -- Caption
                    ECC_DatarefTable[k][6] = temptable[j][4] -- Value range limits
                    ECC_DatarefTable[k][8] = temptable[j][5] -- Display in percent
                    ECC_DatarefTable[k][9] = temptable[j][6] -- Display precision
                    ECC_DatarefTable[k][10] = temptable[j][7] -- Group

                end
           end
        end
        --[[for j=1,#temptable do
            print(type(temptable[j][1])..": "..temptable[j][1].." ; "..type(temptable[j][2])..": "..table.concat(temptable[j][2],",",0).." ; "..type(temptable[j][3])..": "..temptable[j][3].." ; "..type(temptable[j][4])..": "..table.concat(temptable[j][4],",").." ; "..type(temptable[j][5])..": "..temptable[j][5].." ; "..type(temptable[j][6])..": "..temptable[j][6].." ; "..type(temptable[j][7])..": "..temptable[j][7])
        end]]
        file:close()
		if i ~= nil and i > 0 then ECC_Notification("FILE READ SUCCESS: "..inputfile,"Success","log") else ECC_Notification("FILE READ ERROR: "..inputfile,"Error","log") end
    else
        ECC_Notification("FILE NOT FOUND: "..inputfile,"Error","log")
		--ECC_Check_AutoLoad = false
	end
end
--[[ Preset load handler ]]
function ECC_LoadPresetVals(filename)
    ECC_Log_Write("ECC PRESET: Started loading values from "..filename)
    ECC_PresetFileRead(filename)                -- Read preset file
    ECC_AccessDref(ECC_DatarefTable,"write")    -- Write values to datarefs
    ECC_SubPageBuilder()                        -- Build subpage indexes
    ECC_Cld_Subpage = #ECC_SubPageAssignments   -- Limit page selection to avoid landing on a blank page
    ECC_Log_Write("ECC PRESET: Finished loading values from "..filename)
end
--[[ 

INITIALIZATION

]]
function ECC_ModuleInit_Main()
    -- Check if plugin is installed and display logged notifications
    ECC_FindInopDrefs(ECC_DatarefTable)
    -- If yes, do the remaining init stuff
    if ECC_Cld_PluginInstalled then
        ECC_AccessDref(ECC_DatarefTable,"read")    -- Read dataref values
        ECC_CopyDefaults(ECC_DatarefTable)         -- Note default dataref values
        ECC_SubPageBuilder()                    -- Index number of subpages with items
        ECC_GetFileList(ECC_PresetDirectory,PresetList,"EC_Preset")
        if #PresetList >= 1 then ECC_PresetLastSelected = PresetList[1] end
        if ECC_SettingsValGet("AutoLoad") == 1 then
            ECC_LastPresetFileRead()
            if ECC_PresetLastSelected ~= PresetList[1] then ECC_LoadPresetVals(ECC_PresetLastSelected..".cfg") ECC_Log_Write("ECC PRESET: Triggered loading values from "..ECC_PresetLastSelected..".cfg") end
        end
    end
end
--[[ 

IMGUI WINDOW ELEMENT

]]
--[[ Window page initialization ]]
local function ECC_Page_Init()
    if ECC_PageInitStatus == 0 then ECC_Refresh_PageDB(ECC_PageTitle) ECC_PageInitStatus = 1 end
end
--[[ Window content ]]
function ECC_Win_Main()
    --[[ Check page init status ]]
    ECC_Page_Init()
    --[[ Button ]]
    if ECC_SettingsValGet("Window_Page") == ECC_PageNumGet("Main Menu") then
        --imgui.Dummy((ECC_SettingsValGet("Window_W")-30),19)
        if imgui.Button(ECC_PageTitle,(ECC_SettingsValGet("Window_W")-30),20) then
            ECC_SettingsValSet("Window_Page",ECC_PageNumGet(ECC_PageTitle))
            float_wnd_set_title(ECC_Window, ECC_ScriptName.." ("..ECC_PageTitle..")")
            ECC_Settings_CheckAutosave()
        end
        ECC_ItemTooltip("Opens the Cloud Settings window")
    end
    --[[ Page ]]
    if ECC_SettingsValGet("Window_Page") == ECC_PageNumGet(ECC_PageTitle) then
        --[[ Set the page title ]]
        float_wnd_set_title(ECC_Window, ECC_ScriptName.." ("..ECC_PageTitle..")")
        --[[ "Main Menu" button ]]
        ECC_Win_Button_Back("Main Menu")
        imgui.Dummy((ECC_SettingsValGet("Window_W")-30),10)
        --[[ File content ]]
        --[["Plugin not installed" warning ]]
        if not ECC_Cld_PluginInstalled then
            imgui.PushStyleColor(imgui.constant.Col.Text, ECC_ImguiColors[4]) imgui.TextUnformatted("\"Enchanced Cloudscapes\" plugin is not installed!") imgui.PopStyleColor()
        else
            ECC_PresetSelector(PresetList)
            --[[ Sub page flip buttons ]]
            if imgui.Button("<< ##a",20,20) then ECC_Cld_Subpage = ECC_Cld_Subpage - 1 if ECC_Cld_Subpage == 0 then ECC_Cld_Subpage = #ECC_SubPageAssignments end end
            imgui.SameLine() imgui.Dummy((ECC_SettingsValGet("Window_W")-185) / 2,20) imgui.SameLine()
            imgui.TextUnformatted("Group "..ECC_Cld_Subpage.." of "..#ECC_SubPageAssignments)
            imgui.SameLine() imgui.Dummy((ECC_SettingsValGet("Window_W")-185) / 2,20) imgui.SameLine()
            if imgui.Button(">> ##b",20,20) then ECC_Cld_Subpage = ECC_Cld_Subpage + 1 if ECC_Cld_Subpage > #ECC_SubPageAssignments then ECC_Cld_Subpage = 1 end end
            --[[ Read datarefs ]]
            ECC_AccessDref(ECC_DatarefTable,"read")
            --[[ Begin subwindow ]]
            -- Loop thorugh the selected section of the sub page assignment table
            for q=1,#ECC_SubPageAssignments[ECC_Cld_Subpage] do
                local inputindex = ECC_SubPageAssignments[ECC_Cld_Subpage][q]
                imgui.Dummy((ECC_SettingsValGet("Window_W")-30),15)
                -- Caption
                if not ECC_Cld_AdvMode then
                    imgui.TextUnformatted(ECC_DatarefTable[inputindex][4]..":")
                else
                    imgui.PushItemWidth(ECC_SettingsValGet("Window_W") - 190)
                    local changed,buffer = imgui.InputText("##"..inputindex,ECC_DatarefTable[inputindex][4],48)
                    if changed then ECC_DatarefTable[inputindex][4] = buffer end
                    imgui.PopItemWidth()
                end
                --
                for k=0,#ECC_DatarefTable[inputindex][3] do
                    ECC_InputElements(inputindex,k,ECC_DatarefTable[inputindex][8],ECC_DatarefTable[inputindex][9])
                end
                --Advanced: Text input for value range limit
                if ECC_Cld_AdvMode then
                    --Display mode selector button
                    local currentmode = ECC_DatarefTable[inputindex][8]
                    local buttoncaption = ""
                    if currentmode == 0 then buttoncaption = "Switch Display To Percentage" end
                    if currentmode == 1 then buttoncaption = "Switch Display To Numerical" end
                    if imgui.Button(buttoncaption.."##dispmode"..inputindex,(ECC_SettingsValGet("Window_W") - 190),20) then
                        if ECC_DatarefTable[inputindex][8] == 1 then
                            ECC_DatarefTable[inputindex][8] = 0
                            for l=0,#ECC_DatarefTable[inputindex][3] do
                                ECC_PercentToFloat(ECC_DatarefTable[inputindex][3][l],ECC_DatarefTable[inputindex][6][1],ECC_DatarefTable[inputindex][6][2])
                                ECC_DatarefTable[inputindex][9] = 6
                            end
                        elseif ECC_DatarefTable[inputindex][8] == 0 then
                            ECC_DatarefTable[inputindex][8] = 1
                            for l=0,#ECC_DatarefTable[inputindex][3] do
                                ECC_FloatToPercent(ECC_DatarefTable[inputindex][3][l],ECC_DatarefTable[inputindex][6][1],ECC_DatarefTable[inputindex][6][2])
                                ECC_DatarefTable[inputindex][9] = 1
                            end
                        end
                    end
                    -- Low limit
                    imgui.TextUnformatted("Lower Raw Value Limit: ") imgui.SameLine()
                    imgui.PushItemWidth(100)
                    local changed,buffer = imgui.InputFloat("##Lo"..inputindex, ECC_DatarefTable[inputindex][6][1],0,0,"%.10f") imgui.SameLine()
                    if changed then ECC_DatarefTable[inputindex][6][1] = buffer buffer = nil end
                    imgui.PopItemWidth()
                    if imgui.Button("Reset ##Lo"..inputindex,50,20) then ECC_DatarefTable[inputindex][6][1] = ECC_DatarefTable[inputindex][7][1] end
                    -- High limit
                    imgui.TextUnformatted("Upper Raw Value Limit: ") imgui.SameLine()
                    imgui.PushItemWidth(100)
                    local changed,buffer = imgui.InputFloat("##Hi"..inputindex, ECC_DatarefTable[inputindex][6][2],0,0,"%.10f") imgui.SameLine()
                    if changed then ECC_DatarefTable[inputindex][6][2] = buffer buffer = nil end
                    imgui.PopItemWidth()
                    if imgui.Button("Reset ##Hi"..inputindex,50,20) then ECC_DatarefTable[inputindex][6][2] = ECC_DatarefTable[inputindex][7][2] end
                    -- Precision
                    imgui.TextUnformatted("Display Precision    : ") imgui.SameLine()
                    imgui.PushItemWidth(100)
                    local changed,buffer = imgui.InputInt("##Decimals"..inputindex, ECC_DatarefTable[inputindex][9],0,0)
                    if changed then ECC_DatarefTable[inputindex][9] = buffer buffer = nil end
                    imgui.PopItemWidth()
                    imgui.TextUnformatted("Display In Group     : ") imgui.SameLine()
                    imgui.PushItemWidth(100)
                    local changed,buffer = imgui.InputInt("Preset##Page"..inputindex, ECC_DatarefTable[inputindex][10],0,0)
                    if changed then ECC_DatarefTable[inputindex][10] = buffer buffer = nil end
                    imgui.PopItemWidth() imgui.SameLine()
                    if imgui.Button("Apply ##"..inputindex,50,20) then ECC_SubPageBuilder() ECC_Cld_Subpage = #ECC_SubPageAssignments break end
                end
            --[[ End subwindow ]]
            end
            imgui.Dummy((ECC_SettingsValGet("Window_W")-30),20)
            --"Advanced" checkbox
            local changed, newECC_Cld_AdvMode = imgui.Checkbox("Advanced Settings", ECC_Cld_AdvMode)
            if changed then ECC_Cld_AdvMode = newECC_Cld_AdvMode end
            --[[ Write datarefs ]]
            ECC_AccessDref(ECC_DatarefTable,"write")
            imgui.Dummy((ECC_SettingsValGet("Window_W")-30),20)
            --imgui.SameLine() imgui.Dummy((ECC_SettingsValGet("Window_W")-250),5) imgui.SameLine()
        end
    --[[ End page ]]    
    end
end
