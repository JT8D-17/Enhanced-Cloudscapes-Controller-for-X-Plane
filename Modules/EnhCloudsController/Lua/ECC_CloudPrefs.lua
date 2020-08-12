--[[

Lua module, required by AircraftHelper.lua
Licensed under the EUPL v1.2: https://eupl.eu/

]]
--[[

VARIABLES (local to this module)

]]
local ECC_PresetFile = MODULES_DIRECTORY.."EnhCloudsController/EC_Preset.cfg"
local ECC_Cld_DRefs = { }
local ECC_Cld_PluginInstalled = false   -- Check if cloud plugin is installed
local ECC_Cld_Subpage = 1
local ECC_Cld_AdvMode = false
local ECC_SubPageAssignments = { }
--[[

DATAREFS (local to this module)

]]
-- Dataref table content: "1: Dref name",2: Dref size,{3: Dref value(s)},"4: Dref title",{5: Dref default values},{6: Dref value range},{7: Copy of dref value range},8: Display mode (numeric/percent),9:Display precision,10: Sub page group
local ECC_Cld_DRefs = {
        {"enhanced_cloudscapes/cloud_map_scale",1,{},"Cloud Map Scale",{},{0,0.00001},{},true,1,1},          -- #1 ,Default 0.000005
        {"enhanced_cloudscapes/base_noise_scale",1,{},"Base Noise Scale",{},{0,0.0001},{},true,1,1},         -- #2 ,Default 0.000025
        {"enhanced_cloudscapes/detail_noise_scale",1,{},"Detail Noise Scale",{},{0,0.001},{},true,1,1},      -- #3 ,Default 0.0002
        {"enhanced_cloudscapes/blue_noise_scale",1,{},"Blue Noise Scale",{},{0,0.1},{},true,1,1},            -- #4 ,Default 0.01
        {"enhanced_cloudscapes/cirrus/height",1,{},"Cirrus Layer Height",{},{0,10000},{},false,1,2},          -- #5 ,Default 2500.0
        {"enhanced_cloudscapes/scattered/height",1,{},"Scattered Layer Height",{},{0,10000},{},false,1,2},    -- #6 ,Default 4000.0
        {"enhanced_cloudscapes/broken/height",1,{},"Broken Layer Height",{},{0,10000},{},false,1,2},          -- #7 ,Default 5000.0
        {"enhanced_cloudscapes/overcast/height",1,{},"Overcast Layer Height",{},{0,10000},{},false,1,2},      -- #8 ,Default 5000.0
        {"enhanced_cloudscapes/stratus/height",1,{},"Stratus Layer Height",{},{0,10000},{},false,1,2},        -- #9 ,Default 6000.0
        {"enhanced_cloudscapes/cirrus/coverage",1,{},"Cirrus Layer Coverage",{},{0,1.0},{},true,1,3},        -- #10,Default 0.375
        {"enhanced_cloudscapes/scattered/coverage",1,{},"Scattered Layer Coverage",{},{0,1.0},{},true,1,3},  -- #11,Default 0.75
        {"enhanced_cloudscapes/broken/coverage",1,{},"Broken Layer Coverage",{},{0,1.0},{},true,1,3},        -- #12,Default 0.85
        {"enhanced_cloudscapes/overcast/coverage",1,{},"Overcast Layer Coverage",{},{0,1.0},{},true,1,3},    -- #13,Default 0.95
        {"enhanced_cloudscapes/stratus/coverage",1,{},"Stratus Layer Coverage",{},{0,1.0},{},true,1,3},      -- #14,Default 1.0
        {"enhanced_cloudscapes/cirrus/base_noise_ratios",3,{},"Cirrus Base Noise Ratios",{},{0,1.0},{},false,4,4},         -- #15,Defaults 0.625, 0.25, 0.125
        {"enhanced_cloudscapes/scattered/base_noise_ratios",3,{},"Scattered Base Noise Ratios",{},{0,1.0},{},false,4,4},   -- #16,Defaults 0.625, 0.25, 0.125
        {"enhanced_cloudscapes/broken/base_noise_ratios",3,{},"Broken Base Noise Ratios",{},{0,1.0},{},false,4,4},         -- #17,Defaults 0.625, 0.25, 0.125
        {"enhanced_cloudscapes/overcast/base_noise_ratios",3,{},"Overcast Base Noise Ratios",{},{0,1.0},{},false,4,4},     -- #18,Defaults 0.625, 0.25, 0.125
        {"enhanced_cloudscapes/stratus/base_noise_ratios",3,{},"Stratus Base Noise Ratios",{},{0,1.0},{},false,4,4},       -- #19,Defaults 0.625, 0.25, 0.125
        {"enhanced_cloudscapes/cirrus/detail_noise_ratios",3,{},"Cirrus Detail Noise Ratios",{},{0,1.0},{},false,4,5},        -- #20,Defaults 0.25, 0.125, 0.0625
        {"enhanced_cloudscapes/scattered/detail_noise_ratios",3,{},"Scattered Detail Noise Ratios",{},{0,1.0},{},false,4,5},  -- #21,Defaults 0.625, 0.25, 0.125
        {"enhanced_cloudscapes/broken/detail_noise_ratios",3,{},"Broken Detail Noise Ratios",{},{0,1.0},{},false,4,5},        -- #22,Defaults 0.625, 0.25, 0.125
        {"enhanced_cloudscapes/overcast/detail_noise_ratios",3,{},"Overcast Detail Noise Ratios",{},{0,1.0},{},false,4,5},    -- #23,Defaults 0.625, 0.25, 0.125
        {"enhanced_cloudscapes/stratus/detail_noise_ratios",3,{},"Stratus Detail Noise Ratios",{},{0,1.0},{},false,4,5},      -- #24,Defaults 0.625, 0.25, 0.125
        {"enhanced_cloudscapes/cirrus/density_multiplier",1,{},"Cirrus Density Multiplier",{},{0,0.01},{},false,4,6},             -- #25,Default 0.0015
        {"enhanced_cloudscapes/scattered/density_multiplier",1,{},"Scattered Density Multiplier",{},{0,0.01},{},false,4,6},       -- #26,Default 0.0035
        {"enhanced_cloudscapes/broken/density_multiplier",1,{},"Broken Density Multiplier",{},{0,0.01},{},false,4,6},             -- #27,Default 0.004
        {"enhanced_cloudscapes/overcast/density_multiplier",1,{},"Overcast Density Multiplier",{},{0,0.01},{},false,4,6},         -- #28,Default 0.004
        {"enhanced_cloudscapes/stratus/density_multiplier",1,{},"Stratus Density Multiplier",{},{0,0.01},{},false,4,6},           -- #29,Default 0.0045
        {"enhanced_cloudscapes/sun_gain",1,{},"Sun Gain",{},{0,10.0},{},true,2,7},                                  -- #30,Default 3.25
        {"enhanced_cloudscapes/ambient_tint",3,{},"Ambient Tint",{},{0,10.0},{},true,1,7},                          -- #31,Defaults 1.0, 1.0, 1.0
        {"enhanced_cloudscapes/ambient_gain",1,{},"Ambient Gain",{},{0,10.0},{},true,1,7},                          -- #32,Default 1.5
        {"enhanced_cloudscapes/forward_mie_scattering",1,{},"Forward Mie Scattering",{},{0,1.0},{},true,2,7},       -- #33,Default 0.85
        {"enhanced_cloudscapes/backward_mie_scattering",1,{},"Backward Mie Scattering",{},{0,1.0},{},true,2,7},     -- #34,Default 0.25
        {"enhanced_cloudscapes/atmosphere_bottom_tint",3,{},"Atmosphere Bottom Tint",{},{0,1.0},{},true,2,7},       -- #35,Defaults 0.55, 0.775, 1.0
        {"enhanced_cloudscapes/atmosphere_top_tint",3,{},"Atmosphere Top Tint",{},{0,1.0},{},true,2,7},             -- #36,Defaults 0.45, 0.675, 1.0
        {"enhanced_cloudscapes/atmospheric_blending",1,{},"Atmospheric Blending",{},{0,1.0},{},true,3,7},           -- #37,Default 0.675    
        {"enhanced_cloudscapes/rendering_resolution_ratio",1,{},"Rendering Resolution Ratio",{},{0,1.0},{},true,1,8},    -- #38,Default 0.7    
        {"enhanced_cloudscapes/skip_fragments",1,{},"Skip Fragments",{},{0,10.0},{},true,1,8},                           -- #39,Default 1.0    
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
    for i=1,#ECC_Cld_DRefs do
        if ECC_SubPageAssignments[ECC_Cld_DRefs[i][10]] == nil and XPLMFindDataRef(ECC_Cld_DRefs[i][1]) ~= nil then 
            ECC_SubPageAssignments[ECC_Cld_DRefs[i][10]] = {}
            ECC_SubPageAssignments[ECC_Cld_DRefs[i][10]][(#ECC_SubPageAssignments[ECC_Cld_DRefs[i][10]]+1)] = i
        elseif XPLMFindDataRef(ECC_Cld_DRefs[i][1]) ~= nil then
            ECC_SubPageAssignments[ECC_Cld_DRefs[i][10]][(#ECC_SubPageAssignments[ECC_Cld_DRefs[i][10]]+1)] = i
        end
    end
    for m=1,#ECC_SubPageAssignments do
        if ECC_SubPageAssignments[m] == nil then
            for n=m,#ECC_SubPageAssignments do
                ECC_SubPageAssignments[n] = ECC_SubPageAssignments[(n+1)] 
            end
        end
    end
    for m=1,#ECC_SubPageAssignments do
        print("ECC: Subpage "..m.." items: "..table.concat(ECC_SubPageAssignments[m],",").." ("..#ECC_SubPageAssignments[m]..")")
    end
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
    imgui.PushItemWidth(ECC_Preferences.AAA_Window_W - 165)
    if mode then
        -- Slider in percentage
        local changed,buffer = imgui.SliderFloat("%##Slider pct"..index..subindex,ECC_FloatToPercent(ECC_Cld_DRefs[index][3][subindex],ECC_Cld_DRefs[index][6][1],ECC_Cld_DRefs[index][6][2]),0,100,"%."..displayformat.."f")
        if changed then ECC_Cld_DRefs[index][3][subindex] = ECC_PercentToFloat(buffer,ECC_Cld_DRefs[index][6][1],ECC_Cld_DRefs[index][6][2]) buffer = nil end
    else
        local changed,buffer = imgui.SliderFloat(" ##Slider num"..index..subindex,ECC_Cld_DRefs[index][3][subindex],ECC_Cld_DRefs[index][6][1],ECC_Cld_DRefs[index][6][2],"%."..displayformat.."f")
        if changed then ECC_Cld_DRefs[index][3][subindex] = buffer buffer = nil end
    end
    imgui.PopItemWidth() imgui.SameLine()
    --
    imgui.PushItemWidth(50)
    if mode then
        local changed,buffer = imgui.InputText("##Text pct"..index..subindex, ECC_FloatToPercent(ECC_Cld_DRefs[index][3][subindex],ECC_Cld_DRefs[index][6][1],ECC_Cld_DRefs[index][6][2]),6)  
        if changed and buffer ~= "" and tonumber(buffer) then
            if tonumber(buffer) < 0 then ECC_Cld_DRefs[index][3][subindex] = ECC_PercentToFloat(0,ECC_Cld_DRefs[index][6][1],ECC_Cld_DRefs[index][6][2])
            elseif tonumber(buffer) > 100 then ECC_Cld_DRefs[index][3][subindex] = ECC_PercentToFloat(100,ECC_Cld_DRefs[index][6][1],ECC_Cld_DRefs[index][6][2])
            else ECC_Cld_DRefs[index][3][subindex] = ECC_PercentToFloat(tonumber(buffer),ECC_Cld_DRefs[index][6][1],ECC_Cld_DRefs[index][6][2]) end
            buffer = nil 
        end
        imgui.SameLine() imgui.TextUnformatted("%")
    else
       local changed,buffer = imgui.InputText("##Text num"..index..subindex, ECC_Cld_DRefs[index][3][subindex],6)
        if changed and buffer ~= "" and tonumber(buffer) then
            if tonumber(buffer) < ECC_Cld_DRefs[index][6][1] then ECC_Cld_DRefs[index][3][subindex] = ECC_Cld_DRefs[index][6][1]
            elseif tonumber(buffer) > ECC_Cld_DRefs[index][6][2] then ECC_Cld_DRefs[index][3][subindex] = ECC_Cld_DRefs[index][6][2]
            else ECC_Cld_DRefs[index][3][subindex] = tonumber(buffer) end
            buffer = nil 
        end
        imgui.SameLine() imgui.TextUnformatted(" ")
    end
    imgui.SameLine()
    imgui.PopItemWidth()
    if imgui.Button("Reset ##"..index..subindex,50,20) then ECC_Cld_DRefs[index][3][subindex] = ECC_Cld_DRefs[index][5][subindex] end
end
--[[ Delete a preset file ]]
function ECC_PresetFileDelete()
   os.remove(ECC_PresetFile) ECC_Notification("FILE DELETE: "..ECC_PresetFile,"Warning") 
end
--[[ ]]
function ECC_PresetFileWrite()
    ECC_Log_Write("FILE INIT WRITE: "..ECC_PresetFile)
    local file = io.open(ECC_PresetFile, "w")
    file:write("Enhanced Cloudscapes Controller file created/updated on ",os.date("%x, %H:%M:%S"),"\n")
    file:write("\n")
    --file:write("SubPage="..ECC_LM_SubPage.."\n")
    --file:write("DispUnits,"..ECC_LM_DispUnits[1]..","..ECC_LM_DispUnits[2].."\n")
    --[[ Write CG Limits ]]
    --file:write("CG_Limits,"..ECC_LM_CG_Limits[1]..","..ECC_LM_CG_Limits[2]..","..ECC_LM_CG_Limits[3]..","..ECC_LM_CG_Limits[4].."\n")
    --[[ Write Empty CG offset ]]
    --file:write("CG_Offset,"..ECC_LM_EmptyCGOffset[1]..","..ECC_LM_EmptyCGOffset[2].."\n")
    --[[ Write Payload Stations ]]
    --if #ECC_LM_Stations > 0 then
        --for b=1,#ECC_LM_Stations do
            --file:write("PAYLOAD_STATION,")
            --for c=1,#ECC_LM_Stations[b] do
                --if c ~= #ECC_LM_Stations[b] then file:write(tostring(ECC_LM_Stations[b][c]),",") else file:write(tostring(ECC_LM_Stations[b][c]),"\n") end
            --end
        --end
    --end
    if file:seek("end") > 0 then ECC_Notification("FILE WRITE SUCCESS: "..ECC_PresetFile,"Success","log") else ECC_Notification("FILE WRITE ERROR: "..ECC_PresetFile,"Error","log") end
	file:close()
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
    ECC_PresetFileDelete()
end

--[[

IMGUI WINDOW ELEMENT

]]
function ECC_Win_CloudPrefs()
    --[[ Obtain and store window information ]]
    ECC_GetWindowInfo()
    --[["Plugin not installed" warning ]]
    if not ECC_Cld_PluginInstalled then
        imgui.PushStyleColor(imgui.constant.Col.Text, ECC_ImguiColors[4]) imgui.TextUnformatted("\"Enchanced Cloudscapes\" plugin is not installed!") imgui.PopStyleColor()       
    else
        --[[ Sub page flip buttons ]]
        if imgui.Button("<< ##a",20,20) then ECC_Cld_Subpage = ECC_Cld_Subpage - 1 if ECC_Cld_Subpage == 0 then ECC_Cld_Subpage = #ECC_SubPageAssignments end end
        imgui.SameLine() imgui.Dummy((ECC_Preferences.AAA_Window_W-175) / 2,20) imgui.SameLine() 
        imgui.TextUnformatted("Page "..ECC_Cld_Subpage.." of "..#ECC_SubPageAssignments) 
        imgui.SameLine() imgui.Dummy((ECC_Preferences.AAA_Window_W-175) / 2,20) imgui.SameLine()
        if imgui.Button(">> ##b",20,20) then ECC_Cld_Subpage = ECC_Cld_Subpage + 1 if ECC_Cld_Subpage > #ECC_SubPageAssignments then ECC_Cld_Subpage = 1 end end
        --[[ Read datarefs ]]
        ECC_AccessDref(ECC_Cld_DRefs,"read")
        --[[ Begin subwindow ]]
        if ECC_Preferences.Window_Page == 0 then
            -- Loop thorugh the selected section of the sub page assignment table
            for q=1,#ECC_SubPageAssignments[ECC_Cld_Subpage] do
                local inputindex = ECC_SubPageAssignments[ECC_Cld_Subpage][q]
                imgui.Dummy((ECC_Preferences.AAA_Window_W-15),15)
                -- Caption
                imgui.TextUnformatted(ECC_Cld_DRefs[inputindex][4]..":")
                --
                for k=0,#ECC_Cld_DRefs[inputindex][3] do
                    ECC_InputElements(inputindex,k,ECC_Cld_DRefs[inputindex][8],ECC_Cld_DRefs[inputindex][9])
                end
                --Advanced: Text input for value range limit
                if ECC_Cld_AdvMode then
                    -- Low limit
                    imgui.TextUnformatted("Lower Raw Value Limit: ") imgui.SameLine()
                    imgui.PushItemWidth(100)
                    local changed,buffer = imgui.InputText("##Lo"..inputindex, ECC_Cld_DRefs[inputindex][6][1], 20) imgui.SameLine()
                    if changed and buffer ~= "" and tonumber(buffer) then ECC_Cld_DRefs[inputindex][6][1] = tonumber(buffer) buffer = nil end
                    imgui.PopItemWidth()
                    if imgui.Button("Reset ##Lo"..inputindex,50,20) then ECC_Cld_DRefs[inputindex][6][1] = ECC_Cld_DRefs[inputindex][7][1] end
                    -- High limit
                    imgui.TextUnformatted("Upper Raw Value Limit: ") imgui.SameLine()
                    imgui.PushItemWidth(100)
                    local changed,buffer = imgui.InputText("##Hi"..inputindex, ECC_Cld_DRefs[inputindex][6][2], 20) imgui.SameLine()
                    if changed and buffer ~= "" and tonumber(buffer) then ECC_Cld_DRefs[inputindex][6][2] = tonumber(buffer) buffer = nil end
                    imgui.PopItemWidth()
                    if imgui.Button("Reset ##Hi"..inputindex,50,20) then ECC_Cld_DRefs[inputindex][6][2] = ECC_Cld_DRefs[inputindex][7][2] end
                    -- Precision
                    imgui.TextUnformatted("Display Precision    : ") imgui.SameLine()
                    imgui.PushItemWidth(100)
                    local changed,buffer = imgui.InputText("##Decimals"..inputindex, ECC_Cld_DRefs[inputindex][9], 20)
                    if changed and buffer ~= "" and tonumber(buffer) then ECC_Cld_DRefs[inputindex][9] = tonumber(buffer) buffer = nil end
                    imgui.PopItemWidth()
                    --Display mode selector checkbox
                    local changed, newValDispMode = imgui.Checkbox("Display As Percentage ##"..inputindex, ECC_Cld_DRefs[inputindex][8])
                    if changed then if ECC_Cld_DRefs[inputindex][8] then 
                        ECC_Cld_DRefs[inputindex][8] = false
                        for l=0,#ECC_Cld_DRefs[inputindex][3] do
                            ECC_PercentToFloat(ECC_Cld_DRefs[inputindex][3][l],ECC_Cld_DRefs[inputindex][6][1],ECC_Cld_DRefs[inputindex][6][2])
                            ECC_Cld_DRefs[inputindex][9] = 6
                        end
                    else 
                        ECC_Cld_DRefs[inputindex][8] = true
                        for l=0,#ECC_Cld_DRefs[inputindex][3] do
                            ECC_FloatToPercent(ECC_Cld_DRefs[inputindex][3][l],ECC_Cld_DRefs[inputindex][6][1],ECC_Cld_DRefs[inputindex][6][2])
                            ECC_Cld_DRefs[inputindex][9] = 1
                        end
                    end end
                end
            end
        --[[ End subwindow ]]
        end
        imgui.Dummy((ECC_Preferences.AAA_Window_W-15),20)
        --"Advanced" checkbox
        local changed, newECC_Cld_AdvMode = imgui.Checkbox("Advanced Settings", ECC_Cld_AdvMode)
        if changed then ECC_Cld_AdvMode = newECC_Cld_AdvMode end
        --if imgui.Button("Advanced Settings",(ECC_Preferences.AAA_Window_W-15),20) then if not ECC_Cld_AdvMode then ECC_Cld_AdvMode = true else ECC_Cld_AdvMode = false end end
        --[[ Write datarefs ]]
        ECC_AccessDref(ECC_Cld_DRefs,"write")
    end
    imgui.Dummy((ECC_Preferences.AAA_Window_W-15),20)
end
