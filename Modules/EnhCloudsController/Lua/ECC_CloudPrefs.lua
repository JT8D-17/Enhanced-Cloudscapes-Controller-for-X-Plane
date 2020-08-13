--[[

Lua module, required by AircraftHelper.lua
Licensed under the EUPL v1.2: https://eupl.eu/

]]
--[[

VARIABLES (local to this module)

]]
local ECC_PresetFile = MODULES_DIRECTORY.."EnhCloudsController/EC_Preset.cfg"
local ECC_Cld_PluginInstalled = false   -- Check if cloud plugin is installed
local ECC_Cld_Subpage = 1
local ECC_Cld_AdvMode = false
local ECC_SubPageAssignments = { }
--[[

DATAREFS (local to this module)

]]
-- Dataref table content: "1: Dref name",2: Dref size,{3: Dref value(s)},"4: Dref title",{5: Dref default values},{6: Dref value range},{7: Copy of dref value range},8: Display mode (numeric/percent),9:Display precision,10: Sub page group
local ECC_Cld_DRefs = {
        {"enhanced_cloudscapes/cloud_map_scale",1,{},"Cloud Map Scale",{},{0,0.00001},{},1,1,1},          -- #1 ,Default 0.000005
        {"enhanced_cloudscapes/base_noise_scale",1,{},"Base Noise Scale",{},{0,0.0001},{},1,1,1},         -- #2 ,Default 0.000025
        {"enhanced_cloudscapes/detail_noise_scale",1,{},"Detail Noise Scale",{},{0,0.001},{},1,1,1},      -- #3 ,Default 0.0002
        {"enhanced_cloudscapes/blue_noise_scale",1,{},"Blue Noise Scale",{},{0,0.1},{},1,1,1},            -- #4 ,Default 0.01
        {"enhanced_cloudscapes/cirrus/height",1,{},"Cirrus Layer Height",{},{0,10000},{},0,1,2},          -- #5 ,Default 2500.0
        {"enhanced_cloudscapes/scattered/height",1,{},"Scattered Layer Height",{},{0,10000},{},0,1,2},    -- #6 ,Default 4000.0
        {"enhanced_cloudscapes/broken/height",1,{},"Broken Layer Height",{},{0,10000},{},0,1,2},          -- #7 ,Default 5000.0
        {"enhanced_cloudscapes/overcast/height",1,{},"Overcast Layer Height",{},{0,10000},{},0,1,2},      -- #8 ,Default 5000.0
        {"enhanced_cloudscapes/stratus/height",1,{},"Stratus Layer Height",{},{0,10000},{},0,1,2},        -- #9 ,Default 6000.0
        {"enhanced_cloudscapes/cirrus/coverage",1,{},"Cirrus Layer Coverage",{},{0,1.0},{},1,1,3},        -- #10,Default 0.375
        {"enhanced_cloudscapes/scattered/coverage",1,{},"Scattered Layer Coverage",{},{0,1.0},{},1,1,3},  -- #11,Default 0.75
        {"enhanced_cloudscapes/broken/coverage",1,{},"Broken Layer Coverage",{},{0,1.0},{},1,1,3},        -- #12,Default 0.85
        {"enhanced_cloudscapes/overcast/coverage",1,{},"Overcast Layer Coverage",{},{0,1.0},{},1,1,3},    -- #13,Default 0.95
        {"enhanced_cloudscapes/stratus/coverage",1,{},"Stratus Layer Coverage",{},{0,1.0},{},1,1,3},      -- #14,Default 1.0
        {"enhanced_cloudscapes/cirrus/base_noise_ratios",3,{},"Cirrus Base Noise Ratios",{},{0,1.0},{},0,4,4},         -- #15,Defaults 0.625, 0.25, 0.125
        {"enhanced_cloudscapes/scattered/base_noise_ratios",3,{},"Scattered Base Noise Ratios",{},{0,1.0},{},0,4,4},   -- #16,Defaults 0.625, 0.25, 0.125
        {"enhanced_cloudscapes/broken/base_noise_ratios",3,{},"Broken Base Noise Ratios",{},{0,1.0},{},0,4,4},         -- #17,Defaults 0.625, 0.25, 0.125
        {"enhanced_cloudscapes/overcast/base_noise_ratios",3,{},"Overcast Base Noise Ratios",{},{0,1.0},{},0,4,4},     -- #18,Defaults 0.625, 0.25, 0.125
        {"enhanced_cloudscapes/stratus/base_noise_ratios",3,{},"Stratus Base Noise Ratios",{},{0,1.0},{},0,4,4},       -- #19,Defaults 0.625, 0.25, 0.125
        {"enhanced_cloudscapes/cirrus/detail_noise_ratios",3,{},"Cirrus Detail Noise Ratios",{},{0,1.0},{},0,4,5},        -- #20,Defaults 0.25, 0.125, 0.0625
        {"enhanced_cloudscapes/scattered/detail_noise_ratios",3,{},"Scattered Detail Noise Ratios",{},{0,1.0},{},0,4,5},  -- #21,Defaults 0.625, 0.25, 0.125
        {"enhanced_cloudscapes/broken/detail_noise_ratios",3,{},"Broken Detail Noise Ratios",{},{0,1.0},{},0,4,5},        -- #22,Defaults 0.625, 0.25, 0.125
        {"enhanced_cloudscapes/overcast/detail_noise_ratios",3,{},"Overcast Detail Noise Ratios",{},{0,1.0},{},0,4,5},    -- #23,Defaults 0.625, 0.25, 0.125
        {"enhanced_cloudscapes/stratus/detail_noise_ratios",3,{},"Stratus Detail Noise Ratios",{},{0,1.0},{},0,4,5},      -- #24,Defaults 0.625, 0.25, 0.125
        {"enhanced_cloudscapes/cirrus/density_multiplier",1,{},"Cirrus Density Multiplier",{},{0,0.01},{},0,4,6},             -- #25,Default 0.0015
        {"enhanced_cloudscapes/scattered/density_multiplier",1,{},"Scattered Density Multiplier",{},{0,0.01},{},0,4,6},       -- #26,Default 0.0035
        {"enhanced_cloudscapes/broken/density_multiplier",1,{},"Broken Density Multiplier",{},{0,0.01},{},0,4,6},             -- #27,Default 0.004
        {"enhanced_cloudscapes/overcast/density_multiplier",1,{},"Overcast Density Multiplier",{},{0,0.01},{},0,4,6},         -- #28,Default 0.004
        {"enhanced_cloudscapes/stratus/density_multiplier",1,{},"Stratus Density Multiplier",{},{0,0.01},{},0,4,6},           -- #29,Default 0.0045
        {"enhanced_cloudscapes/sun_gain",1,{},"Sun Gain",{},{0,10.0},{},1,2,7},                                  -- #30,Default 3.25
        {"enhanced_cloudscapes/ambient_tint",3,{},"Ambient Tint",{},{0,10.0},{},1,1,7},                          -- #31,Defaults 1.0, 1.0, 1.0
        {"enhanced_cloudscapes/ambient_gain",1,{},"Ambient Gain",{},{0,10.0},{},1,1,7},                          -- #32,Default 1.5
        {"enhanced_cloudscapes/forward_mie_scattering",1,{},"Forward Mie Scattering",{},{0,1.0},{},1,2,7},       -- #33,Default 0.85
        {"enhanced_cloudscapes/backward_mie_scattering",1,{},"Backward Mie Scattering",{},{0,1.0},{},1,2,7},     -- #34,Default 0.25
        {"enhanced_cloudscapes/atmosphere_bottom_tint",3,{},"Atmosphere Bottom Tint",{},{0,1.0},{},1,2,7},       -- #35,Defaults 0.55, 0.775, 1.0
        {"enhanced_cloudscapes/atmosphere_top_tint",3,{},"Atmosphere Top Tint",{},{0,1.0},{},1,2,7},             -- #36,Defaults 0.45, 0.675, 1.0
        {"enhanced_cloudscapes/atmospheric_blending",1,{},"Atmospheric Blending",{},{0,1.0},{},1,3,7},           -- #37,Default 0.675    
        {"enhanced_cloudscapes/rendering_resolution_ratio",1,{},"Rendering Resolution Ratio",{},{0,1.0},{},1,1,8},    -- #38,Default 0.7    
        {"enhanced_cloudscapes/skip_fragments",1,{},"Skip Fragments",{},{0,10.0},{},1,1,8},                           -- #39,Default 1.0    
    }
--[[

FUNCTIONS

]]
--[[ Find Enhanced Cloudscape plugin datarefs and index those that are not present ]]
function ECC_FindInopDrefs(intable)
    local FailedDrefs = {}
    for i=1,#intable do
        if XPLMFindDataRef(intable[i][1]) == nil then
            FailedDrefs[#FailedDrefs+1] = i            
        end
    end
    --print("ECC: Could not find datarefs in dataref table indices "..table.concat(FailedDrefs,","))
    if #FailedDrefs ~= #intable then ECC_Cld_PluginInstalled = true end
end
--[[ Dataref accessor ]]
function ECC_AccessDref(intable,mode)
    for i=1,#intable do
        local dref = XPLMFindDataRef(intable[i][1])
        if dref ~= nil then
            if intable[i][2] == 1 then
                    --print(XPLMGetDataRefTypes(dref))
                if mode == "read" then
                    if XPLMGetDataRefTypes(dref) == 1 then intable[i][3][0] = XPLMGetDatai(dref) end
                    if XPLMGetDataRefTypes(dref) == 2 then intable[i][3][0] = XPLMGetDataf(dref) end
                    if XPLMGetDataRefTypes(dref) == 4 then intable[i][3][0] = XPLMGetDatad(dref) end
                end
                --print(i.." : "..intable[i][3][0]) 
                if mode == "write" then 
                    if XPLMGetDataRefTypes(dref) == 1 then XPLMSetDatai(dref,intable[i][3][0]) end
                    if XPLMGetDataRefTypes(dref) == 2 then XPLMSetDataf(dref,intable[i][3][0]) end
                    if XPLMGetDataRefTypes(dref) == 4 then XPLMSetDatad(dref,intable[i][3][0]) end
                end
            else
                --print(XPLMGetDataRefTypes(dref))
                if mode == "read" then 
                    if XPLMGetDataRefTypes(dref) == 8 then intable[i][3] = XPLMGetDatavf(dref,0,intable[i][2]) end
                    if XPLMGetDataRefTypes(dref) == 16 then intable[i][3] = XPLMGetDatavi(dref,0,intable[i][2]) end
                end
                --print(i.." : "..table.concat(intable[i][3],", ",0))
                if mode == "write" then 
                    if XPLMGetDataRefTypes(dref) == 8 then XPLMSetDatavf(dref, intable[i][3],0,intable[i][2]) end
                    if XPLMGetDataRefTypes(dref) == 16 then XPLMSetDatavi(dref, intable[i][3],0,intable[i][2]) end
                end
            end
        end
    end
end
--[[ Copy default values ]]
function ECC_CopyDefaults(intable)
    for i=1,#intable do
        -- Dataref values
        for j=0,#intable[i][3] do
            intable[i][5][j] = intable[i][3][j] 
        end
        --print(i.." : "..table.concat(intable[i][5],", ",0))
        -- Value range
        for k=1,#intable[i][6] do
            intable[i][7][k] = intable[i][6][k] 
        end
        --print(i.." : "..table.concat(intable[i][7],", ",1))
    end
end
--[[ Sub page indexer and item counter ]]
function ECC_SubPageBuilder()
    ECC_SubPageAssignments = { }
    local highestgroupnum = 0
    local temptable = { }
    -- Loop through dref entries
    for i=1,#ECC_Cld_DRefs do
        if ECC_Cld_DRefs[i][10] > highestgroupnum then highestgroupnum = ECC_Cld_DRefs[i][10] end
    end
    -- Create empty tables in temp table
    for i=1,highestgroupnum do
        temptable[i] = { }
    end
    -- Loop through dref entries
    for i=1,#ECC_Cld_DRefs do
        if XPLMFindDataRef(ECC_Cld_DRefs[i][1]) ~= nil then
            temptable[ECC_Cld_DRefs[i][10]][(#temptable[ECC_Cld_DRefs[i][10]]+1)] = i
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
-- [[ Input elements like sliders and buttons]]
function ECC_InputElements(index,subindex,mode,displayformat)
    imgui.PushItemWidth(ECC_Preferences.AAA_Window_W - 190)
    if mode == 1 then
        -- Slider in percentage
        local changed,buffer = imgui.SliderFloat("%##Slider pct"..index..subindex,ECC_FloatToPercent(ECC_Cld_DRefs[index][3][subindex],ECC_Cld_DRefs[index][6][1],ECC_Cld_DRefs[index][6][2]),0,100,"%."..displayformat.."f")
        if changed then ECC_Cld_DRefs[index][3][subindex] = ECC_PercentToFloat(buffer,ECC_Cld_DRefs[index][6][1],ECC_Cld_DRefs[index][6][2]) buffer = nil end
    elseif mode == 0 then
        local changed,buffer = imgui.SliderFloat(" ##Slider num"..index..subindex,ECC_Cld_DRefs[index][3][subindex],ECC_Cld_DRefs[index][6][1],ECC_Cld_DRefs[index][6][2],"%."..displayformat.."f")
        if changed then ECC_Cld_DRefs[index][3][subindex] = buffer buffer = nil end
    end
    imgui.PopItemWidth() imgui.SameLine()
    --
    imgui.PushItemWidth(75)
    if mode == 1 then
        local changed,buffer = imgui.InputFloat("##Text pct"..index..subindex, ECC_FloatToPercent(ECC_Cld_DRefs[index][3][subindex],ECC_Cld_DRefs[index][6][1],ECC_Cld_DRefs[index][6][2]),0,0,"%."..ECC_Cld_DRefs[index][9].."f")  
        if changed then
            if buffer < 0 then ECC_Cld_DRefs[index][3][subindex] = ECC_PercentToFloat(0,ECC_Cld_DRefs[index][6][1],ECC_Cld_DRefs[index][6][2])
            elseif buffer > 100 then ECC_Cld_DRefs[index][3][subindex] = ECC_PercentToFloat(100,ECC_Cld_DRefs[index][6][1],ECC_Cld_DRefs[index][6][2])
            else ECC_Cld_DRefs[index][3][subindex] = ECC_PercentToFloat(buffer,ECC_Cld_DRefs[index][6][1],ECC_Cld_DRefs[index][6][2]) end
            buffer = nil 
        end
        imgui.SameLine() imgui.TextUnformatted("%")
    elseif mode == 0 then
       local changed,buffer = imgui.InputFloat("##Text num"..index..subindex, ECC_Cld_DRefs[index][3][subindex],ECC_Cld_DRefs[index][6][1], ECC_Cld_DRefs[index][6][2],"%."..ECC_Cld_DRefs[index][9].."f")
        if changed then
            if buffer < ECC_Cld_DRefs[index][6][1] then ECC_Cld_DRefs[index][3][subindex] = ECC_Cld_DRefs[index][6][1]
            elseif buffer > ECC_Cld_DRefs[index][6][2] then ECC_Cld_DRefs[index][3][subindex] = ECC_Cld_DRefs[index][6][2]
            else ECC_Cld_DRefs[index][3][subindex] = buffer end
            buffer = nil 
        end
        imgui.SameLine() imgui.TextUnformatted(" ")
    end
    imgui.SameLine()
    imgui.PopItemWidth()
    if imgui.Button("Reset ##"..index..subindex,45,20) then ECC_Cld_DRefs[index][3][subindex] = ECC_Cld_DRefs[index][5][subindex] end
end
--[[ Delete a preset file ]]
function ECC_PresetFileDelete()
   os.remove(ECC_PresetFile) ECC_Notification("FILE DELETE: "..ECC_PresetFile,"Warning") 
end
--[[ Write preset file ]]
function ECC_PresetFileWrite()
    ECC_Log_Write("FILE INIT WRITE: "..ECC_PresetFile)
    local file = io.open(ECC_PresetFile, "w")
    file:write("Enhanced Cloudscapes Controller preset created/updated on ",os.date("%x, %H:%M:%S"),"\n")
    file:write("\n")
    for d=1,#ECC_Cld_DRefs do
        --print("{"..ECC_Cld_DRefs[d][1]..",{"..table.concat(ECC_Cld_DRefs[d][3],",",0).."}}")
        if ECC_Cld_DRefs[d][3][0] ~= nil then
            file:write(ECC_Cld_DRefs[d][1]..";"..table.concat(ECC_Cld_DRefs[d][3],",",0)..";"..ECC_Cld_DRefs[d][4]..";"..table.concat(ECC_Cld_DRefs[d][6],",")..";"..tostring(ECC_Cld_DRefs[d][8])..";"..ECC_Cld_DRefs[d][9]..";"..ECC_Cld_DRefs[d][10].."\n")
        end
    end
    if file:seek("end") > 0 then ECC_Notification("FILE WRITE SUCCESS: "..ECC_PresetFile,"Success","log") else ECC_Notification("FILE WRITE ERROR: "..ECC_PresetFile,"Error","log") end
	file:close()
end
--[[ Read preset file ]]
function ECC_PresetFileRead()
    local file = io.open(ECC_PresetFile, "r")
    if file then
        ECC_Log_Write("FILE INIT READ: "..ECC_PresetFile)
        local i = 0
        local temptable = { }
        for line in file:lines() do
            if string.match(line,"^enhanced") then
                ECC_SplitLine(line,"([^;]+)")
                temptable[#temptable+1] = ECC_SplitResult
                -- Dataref to look for
                temptable[#temptable][1] = tostring(temptable[#temptable][1])
                ECC_SplitLine(temptable[#temptable][2],"([^,]+)")
                -- Current values
                temptable[#temptable][2] = {}
                for j=1,#ECC_SplitResult do
                    temptable[#temptable][2][j-1] = tonumber(ECC_SplitResult[j])
                end
                -- Caption
                -- Value rangle limits
                ECC_SplitLine(temptable[#temptable][4],"([^,]+)")
                temptable[#temptable][4] = {}
                for j=1,#ECC_SplitResult do
                    temptable[#temptable][4][j] = tonumber(ECC_SplitResult[j])
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
           for k=1,#ECC_Cld_DRefs do
                if temptable[j][1] == ECC_Cld_DRefs[k][1] then 
                    -- print("Match temptable "..temptable[j][1].." with Dref table "..ECC_Cld_DRefs[k][1].." at "..k)
                    ECC_Cld_DRefs[k][3] = temptable[j][2] -- Current value(s)
                    ECC_Cld_DRefs[k][4] = temptable[j][3] -- Caption
                    ECC_Cld_DRefs[k][6] = temptable[j][4] -- Value range limits
                    ECC_Cld_DRefs[k][8] = temptable[j][5] -- Display in percent
                    ECC_Cld_DRefs[k][9] = temptable[j][6] -- Display precision
                    ECC_Cld_DRefs[k][10] = temptable[j][7] -- Group
                    
                end
           end
        end
        --for j=1,#temptable do
            --print(type(temptable[j][1])..": "..temptable[j][1].." ; "..type(temptable[j][2])..": "..table.concat(temptable[j][2],",",0).." ; "..type(temptable[j][3])..": "..temptable[j][3].." ; "..type(temptable[j][4])..": "..table.concat(temptable[j][4],",").." ; "..type(temptable[j][5])..": "..temptable[j][5].." ; "..type(temptable[j][6])..": "..temptable[j][6].." ; "..type(temptable[j][7])..": "..temptable[j][7])
        --end
        file:close()
		if i ~= nil and i > 0 then ECC_Notification("FILE READ SUCCESS: "..ECC_PresetFile,"Success","log") else ECC_Notification("FILE READ ERROR: "..ECC_PresetFile,"Error","log") end
    else
        ECC_Notification("FILE NOT FOUND: "..ECC_PresetFile,"Error","log")
		--ECC_Check_AutoLoad = false
	end   
end
--[[ 

INITIALIZATION

]]
-- Check if plugin is installed and display logged notifications
ECC_FindInopDrefs(ECC_Cld_DRefs)
-- If yes, do the remaining init stuff
if ECC_Cld_PluginInstalled then
    --[[ Read dataref values ]]
    ECC_AccessDref(ECC_Cld_DRefs,"read")
    --[[ Note default dataref values ]]
    ECC_CopyDefaults(ECC_Cld_DRefs)
    -- Index number of subpages with items
    ECC_SubPageBuilder()
    --
    --ECC_PresetFileDelete()
end

--[[

IMGUI WINDOW ELEMENT

]]
function ECC_Win_CloudPrefs()
    if ECC_Preferences.Window_Page == 0 then
        --[[ Obtain and store window information ]]
        ECC_GetWindowInfo()
        --[["Plugin not installed" warning ]]
        if not ECC_Cld_PluginInstalled then
            imgui.PushStyleColor(imgui.constant.Col.Text, ECC_ImguiColors[4]) imgui.TextUnformatted("\"Enchanced Cloudscapes\" plugin is not installed!") imgui.PopStyleColor()       
        else
            --[[ Sub page flip buttons ]]
            if imgui.Button("<< ##a",20,20) then ECC_Cld_Subpage = ECC_Cld_Subpage - 1 if ECC_Cld_Subpage == 0 then ECC_Cld_Subpage = #ECC_SubPageAssignments end end
            imgui.SameLine() imgui.Dummy((ECC_Preferences.AAA_Window_W-185) / 2,20) imgui.SameLine() 
            imgui.TextUnformatted("Group "..ECC_Cld_Subpage.." of "..#ECC_SubPageAssignments) 
            imgui.SameLine() imgui.Dummy((ECC_Preferences.AAA_Window_W-185) / 2,20) imgui.SameLine()
            if imgui.Button(">> ##b",20,20) then ECC_Cld_Subpage = ECC_Cld_Subpage + 1 if ECC_Cld_Subpage > #ECC_SubPageAssignments then ECC_Cld_Subpage = 1 end end
            --[[ Read datarefs ]]
            ECC_AccessDref(ECC_Cld_DRefs,"read")
            --[[ Begin subwindow ]]
            if ECC_Preferences.Window_Page == 0 then
                -- Loop thorugh the selected section of the sub page assignment table
                for q=1,#ECC_SubPageAssignments[ECC_Cld_Subpage] do
                    local inputindex = ECC_SubPageAssignments[ECC_Cld_Subpage][q]
                    imgui.Dummy((ECC_Preferences.AAA_Window_W-30),15)
                    -- Caption
                    if not ECC_Cld_AdvMode then
                        imgui.TextUnformatted(ECC_Cld_DRefs[inputindex][4]..":") 
                    else
                        imgui.PushItemWidth(ECC_Preferences.AAA_Window_W - 190)
                        local changed,buffer = imgui.InputText("##"..inputindex,ECC_Cld_DRefs[inputindex][4],48)
                        if changed then ECC_Cld_DRefs[inputindex][4] = buffer end
                        imgui.PopItemWidth()
                    end
                    --
                    for k=0,#ECC_Cld_DRefs[inputindex][3] do
                        ECC_InputElements(inputindex,k,ECC_Cld_DRefs[inputindex][8],ECC_Cld_DRefs[inputindex][9])
                    end
                    --Advanced: Text input for value range limit
                    if ECC_Cld_AdvMode then
                        --Display mode selector button
                        local currentmode = ECC_Cld_DRefs[inputindex][8]
                        local buttoncaption = ""
                        if currentmode == 0 then buttoncaption = "Switch Display To Percentage" end
                        if currentmode == 1 then buttoncaption = "Switch Display To Numerical" end
                        if imgui.Button(buttoncaption.."##dispmode"..inputindex,(ECC_Preferences.AAA_Window_W - 190),20) then 
                            if ECC_Cld_DRefs[inputindex][8] == 1 then 
                                ECC_Cld_DRefs[inputindex][8] = 0
                                for l=0,#ECC_Cld_DRefs[inputindex][3] do
                                    ECC_PercentToFloat(ECC_Cld_DRefs[inputindex][3][l],ECC_Cld_DRefs[inputindex][6][1],ECC_Cld_DRefs[inputindex][6][2])
                                    ECC_Cld_DRefs[inputindex][9] = 6
                                end
                            elseif ECC_Cld_DRefs[inputindex][8] == 0 then
                                ECC_Cld_DRefs[inputindex][8] = 1
                                for l=0,#ECC_Cld_DRefs[inputindex][3] do
                                    ECC_FloatToPercent(ECC_Cld_DRefs[inputindex][3][l],ECC_Cld_DRefs[inputindex][6][1],ECC_Cld_DRefs[inputindex][6][2])
                                    ECC_Cld_DRefs[inputindex][9] = 1
                                end
                            end 
                        end
                        -- Low limit
                        imgui.TextUnformatted("Lower Raw Value Limit: ") imgui.SameLine()
                        imgui.PushItemWidth(100)
                        local changed,buffer = imgui.InputFloat("##Lo"..inputindex, ECC_Cld_DRefs[inputindex][6][1],0,0,"%.10f") imgui.SameLine()
                        if changed then ECC_Cld_DRefs[inputindex][6][1] = buffer buffer = nil end
                        imgui.PopItemWidth()
                        if imgui.Button("Reset ##Lo"..inputindex,50,20) then ECC_Cld_DRefs[inputindex][6][1] = ECC_Cld_DRefs[inputindex][7][1] end
                        -- High limit
                        imgui.TextUnformatted("Upper Raw Value Limit: ") imgui.SameLine()
                        imgui.PushItemWidth(100)
                        local changed,buffer = imgui.InputFloat("##Hi"..inputindex, ECC_Cld_DRefs[inputindex][6][2],0,0,"%.10f") imgui.SameLine()
                        if changed then ECC_Cld_DRefs[inputindex][6][2] = buffer buffer = nil end
                        imgui.PopItemWidth()
                        if imgui.Button("Reset ##Hi"..inputindex,50,20) then ECC_Cld_DRefs[inputindex][6][2] = ECC_Cld_DRefs[inputindex][7][2] end
                        -- Precision
                        imgui.TextUnformatted("Display Precision    : ") imgui.SameLine()
                        imgui.PushItemWidth(100)
                        local changed,buffer = imgui.InputInt("##Decimals"..inputindex, ECC_Cld_DRefs[inputindex][9],0,0)
                        if changed then ECC_Cld_DRefs[inputindex][9] = buffer buffer = nil end
                        imgui.PopItemWidth()
                        imgui.TextUnformatted("Display In Group     : ") imgui.SameLine()
                        imgui.PushItemWidth(100)
                        local changed,buffer = imgui.InputInt("##Page"..inputindex, ECC_Cld_DRefs[inputindex][10],0,0)
                        if changed then ECC_Cld_DRefs[inputindex][10] = buffer buffer = nil end
                        imgui.PopItemWidth() imgui.SameLine()
                        if imgui.Button("Apply ##"..inputindex,50,20) then ECC_SubPageBuilder() ECC_Cld_Subpage = #ECC_SubPageAssignments break end
                    end
                end
            --[[ End subwindow ]]
            end
            imgui.Dummy((ECC_Preferences.AAA_Window_W-30),20)
            --"Advanced" checkbox
            local changed, newECC_Cld_AdvMode = imgui.Checkbox("Advanced Settings", ECC_Cld_AdvMode)
            if changed then ECC_Cld_AdvMode = newECC_Cld_AdvMode end
            --[[ Write datarefs ]]
            ECC_AccessDref(ECC_Cld_DRefs,"write")
            imgui.Dummy((ECC_Preferences.AAA_Window_W-30),20)
            --[[ "Load preset" button ]]
            if imgui.Button("Load Preset",100,20) then ECC_PresetFileRead() ECC_SubPageBuilder() ECC_Cld_Subpage = #ECC_SubPageAssignments end
            imgui.SameLine() imgui.Dummy((ECC_Preferences.AAA_Window_W-250),5) imgui.SameLine()
            --[[ "Save preset" button ]]
            if imgui.Button("Save Preset",100,20) then ECC_PresetFileWrite() end
            
        end
        --imgui.Dummy((ECC_Preferences.AAA_Window_W-30),20)
    end
end
