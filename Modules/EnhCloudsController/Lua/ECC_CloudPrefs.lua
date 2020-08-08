--[[

Lua module, required by AircraftHelper.lua
Licensed under the EUPL v1.2: https://eupl.eu/

]]
--[[

VARIABLES (local to this module)

]]
local ECC_Cld_DRefs = { }
local ECC_Cld_PluginInstalled = false   -- Check if cloud plugin is installed
local ECC_Cld_SubPages = {"Global Scalars","Clouds: Height","Clouds: Coverage","Clouds: Base Noise Ratios","Clouds: Detail Noise Ratios","Clouds: Density Multipliers","Atmospherics"}
local ECC_Cld_Subpage = 1
local ECC_Cld_AdvMode = false
--[[

MODULE INITIALIZATION

]]
-- Check if plugin is installed
if XPLMFindDataRef("enhanced_cloudscapes/cirrus/height") and XPLMFindDataRef("enhanced_cloudscapes/scattered/height")
and XPLMFindDataRef("enhanced_cloudscapes/broken/height") and XPLMFindDataRef("enhanced_cloudscapes/overcast/height")
and XPLMFindDataRef("enhanced_cloudscapes/stratus/height") then ECC_Cld_PluginInstalled = true end

--[[

DATAREFS (local to this module)

]]
if ECC_Cld_PluginInstalled then
    -- Dataref container table. The second subtable is filled with default values and also indicates the number of the dataref elements
    -- Subtables: Dataref, caption, default value(s), limit(s)
    ECC_Cld_DRefs = {
        {dataref_table("enhanced_cloudscapes/cloud_map_scale"),"Cloud Map Scale",{0},{0,0.00001}},          -- #1 ,Default 0.000005
        {dataref_table("enhanced_cloudscapes/base_noise_scale"),"Base Noise Scale",{0},{0,0.0001}},         -- #2 ,Default 0.000025
        {dataref_table("enhanced_cloudscapes/detail_noise_scale"),"Detail Noise Scale",{0},{0,0.001}},      -- #3 ,Default 0.0002
        {dataref_table("enhanced_cloudscapes/blue_noise_scale"),"Blue Noise Scale",{0},{0,0.1}},            -- #4 ,Default 0.01
        {dataref_table("enhanced_cloudscapes/cirrus/height"),"Cirrus Layer Height",{0},{0,10000}},          -- #5 ,Default 2500.0
        {dataref_table("enhanced_cloudscapes/scattered/height"),"Scattered Layer Height",{0},{0,10000}},    -- #6 ,Default 4000.0
        {dataref_table("enhanced_cloudscapes/broken/height"),"Broken Layer Height",{0},{0,10000}},          -- #7 ,Default 5000.0
        {dataref_table("enhanced_cloudscapes/overcast/height"),"Overcast Layer Height",{0},{0,10000}},      -- #8 ,Default 5000.0
        {dataref_table("enhanced_cloudscapes/stratus/height"),"Stratus Layer Height",{0},{0,10000}},        -- #9 ,Default 6000.0
        {dataref_table("enhanced_cloudscapes/cirrus/coverage"),"Cirrus Layer Coverage",{0},{0,1.0}},        -- #10,Default 0.375
        {dataref_table("enhanced_cloudscapes/scattered/coverage"),"Scattered Layer Coverage",{0},{0,1.0}},  -- #11,Default 0.75
        {dataref_table("enhanced_cloudscapes/broken/coverage"),"Broken Layer Coverage",{0},{0,1.0}},        -- #12,Default 0.85
        {dataref_table("enhanced_cloudscapes/overcast/coverage"),"Overcast Layer Coverage",{0},{0,1.0}},    -- #13,Default 0.95
        {dataref_table("enhanced_cloudscapes/stratus/coverage"),"Stratus Layer Coverage",{0},{0,1.0}},      -- #14,Default 1.0
        {dataref_table("enhanced_cloudscapes/cirrus/base_noise_ratios"),"Cirrus Base Noise Ratios",{0,0,0},{0,1.0}},         -- #15,Defaults 0.625, 0.25, 0.125
        {dataref_table("enhanced_cloudscapes/scattered/base_noise_ratios"),"Scattered Base Noise Ratios",{0,0,0},{0,1.0}},   -- #16,Defaults 0.625, 0.25, 0.125
        {dataref_table("enhanced_cloudscapes/broken/base_noise_ratios"),"Broken Base Noise Ratios",{0,0,0},{0,1.0}},         -- #17,Defaults 0.625, 0.25, 0.125
        {dataref_table("enhanced_cloudscapes/overcast/base_noise_ratios"),"Overcast Base Noise Ratios",{0,0,0},{0,1.0}},     -- #18,Defaults 0.625, 0.25, 0.125
        {dataref_table("enhanced_cloudscapes/stratus/base_noise_ratios"),"Stratus Base Noise Ratios",{0,0,0},{0,1.0}},       -- #19,Defaults 0.625, 0.25, 0.125
        {dataref_table("enhanced_cloudscapes/cirrus/detail_noise_ratios"),"Cirrus Detail Noise Ratios",{0,0,0},{0,1.0}},        -- #20,Defaults 0.25, 0.125, 0.0625
        {dataref_table("enhanced_cloudscapes/scattered/detail_noise_ratios"),"Scattered Detail Noise Ratios",{0,0,0},{0,1.0}},  -- #21,Defaults 0.625, 0.25, 0.125
        {dataref_table("enhanced_cloudscapes/broken/detail_noise_ratios"),"Broken Detail Noise Ratios",{0,0,0},{0,1.0}},        -- #22,Defaults 0.625, 0.25, 0.125
        {dataref_table("enhanced_cloudscapes/overcast/detail_noise_ratios"),"Overcast Detail Noise Ratios",{0,0,0},{0,1.0}},    -- #23,Defaults 0.625, 0.25, 0.125
        {dataref_table("enhanced_cloudscapes/stratus/detail_noise_ratios"),"Stratus Detail Noise Ratios",{0,0,0},{0,1.0}},      -- #24,Defaults 0.625, 0.25, 0.125
        {dataref_table("enhanced_cloudscapes/cirrus/density_multiplier"),"Cirrus Density Multiplier",{0},{0,0.01}},             -- #25,Default 0.0015
        {dataref_table("enhanced_cloudscapes/scattered/density_multiplier"),"Scattered Density Multiplier",{0},{0,0.01}},       -- #26,Default 0.0035
        {dataref_table("enhanced_cloudscapes/broken/density_multiplier"),"Broken Density Multiplier",{0},{0,0.01}},             -- #27,Default 0.004
        {dataref_table("enhanced_cloudscapes/overcast/density_multiplier"),"Overcast Density Multiplier",{0},{0,0.01}},         -- #28,Default 0.004
        {dataref_table("enhanced_cloudscapes/stratus/density_multiplier"),"Stratus Density Multiplier",{0},{0,0.01}},           -- #29,Default 0.0045
        {dataref_table("enhanced_cloudscapes/sun_gain"),"Sun Gain",{0},{0,10.0}},                           -- #30,Default 3.25
        {dataref_table("enhanced_cloudscapes/ambient_tint"),"Ambient Tint",{0,0,0},{0,10.0}},               -- #31,Defaults 1.0, 1.0, 1.0
        {dataref_table("enhanced_cloudscapes/ambient_gain"),"Ambient Gain",{0},{0,10.0}},                   -- #32,Default 1.5
        {dataref_table("enhanced_cloudscapes/forward_mie_scattering"),"Forward Mie Scattering",{0},{0,1.0}},    -- #33,Default 0.85
        {dataref_table("enhanced_cloudscapes/backward_mie_scattering"),"Backward Mie Scattering",{0},{0,1.0}},  -- #34,Default 0.25
        {dataref_table("enhanced_cloudscapes/atmosphere_bottom_tint"),"Atmosphere Bottom Tint",{0,0,0},{0,1.0}},-- #35,Defaults 0.55, 0.775, 1.0
        {dataref_table("enhanced_cloudscapes/atmosphere_top_tint"),"Atmosphere Top Tint",{0,0,0},{0,1.0}},      -- #36,Defaults 0.45, 0.675, 1.0
        {dataref_table("enhanced_cloudscapes/atmospheric_blending"),"Atmospheric Blending",{0},{0,1.0}},        -- #37,Default 0.675    
    }
    -- Get default values
    for i=1,#ECC_Cld_DRefs do
        if #ECC_Cld_DRefs[i][3] == 1 then
            ECC_Cld_DRefs[i][3][1] = ECC_Cld_DRefs[i][1][0]
            --print(i.." : "..ECC_Cld_DRefs[i][3][1]) 
        end
        if #ECC_Cld_DRefs[i][3] == 2 then 
            ECC_Cld_DRefs[i][3][1] = ECC_Cld_DRefs[i][1][0]
            ECC_Cld_DRefs[i][3][2] = ECC_Cld_DRefs[i][1][1]
            --print(i.." : "..ECC_Cld_DRefs[i][3][1]..", "..ECC_Cld_DRefs[i][3][2]) 
        end
        if #ECC_Cld_DRefs[i][3] == 3 then
            ECC_Cld_DRefs[i][3][1] = ECC_Cld_DRefs[i][1][0]
            ECC_Cld_DRefs[i][3][2] = ECC_Cld_DRefs[i][1][1]
            ECC_Cld_DRefs[i][3][3] = ECC_Cld_DRefs[i][1][2]
            --print(i.." : "..ECC_Cld_DRefs[i][3][1]..", "..ECC_Cld_DRefs[i][3][2]..", "..ECC_Cld_DRefs[i][3][3]) 
        end
    end
end
--[[

FUNCTIONS

]]
--[[ Display a notification (and log it) if the EC plugin was found or not ]]
function ECC_PluginStatusNotification()
    if ECC_Cld_PluginInstalled then
        ECC_Notification("PLUGIN FIND SUCCESS: Enhanced Cloudscapes plugin found!","Success","log")
    else
        ECC_Notification("PLUGIN FIND ERROR: Enhanced Cloudscapes plugin not installed!","Error","log")
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
-- 
function ECC_InputElements(index,subindex,mode,unit)
    --[[imgui.PushItemWidth(ECC_Preferences.AAA_Window_W - 155)
    if mode == "percent" then
        -- Slider in percentage
        local changed,buffer = imgui.SliderFloat(unit.." ",ECC_FloatToPercent(ECC_Cld_DRefs[index][1][subindex],ECC_Cld_DRefs[index][4][1],ECC_Cld_DRefs[index][4][2]),0,100,displayformat)
        if changed then ECC_Cld_DRefs[index][1][subindex] = ECC_PercentToFloat(buffer,ECC_Cld_DRefs[index][4][1],ECC_Cld_DRefs[index][4][2]) buffer = nil end
    elseif mode == "numeric" then
        local changed,buffer = imgui.SliderFloat(unit.." ",ECC_Cld_DRefs[index][1][subindex],ECC_Cld_DRefs[index][4][1],ECC_Cld_DRefs[index][4][2],displayformat)
        if changed then ECC_Cld_DRefs[index][1][subindex] = buffer buffer = nil end
    end
    imgui.PopItemWidth() imgui.SameLine()
    --
    ]]
    imgui.PushItemWidth(40)
    if mode == "percent" then
        local changed,buffer = imgui.InputText("##", ECC_FloatToPercent(ECC_Cld_DRefs[index][1][subindex],ECC_Cld_DRefs[index][4][1],ECC_Cld_DRefs[index][4][2]), 10)  
        if changed and buffer ~= "" and tonumber(buffer) then
            if tonumber(buffer) < 0 then ECC_Cld_DRefs[index][1][subindex] = ECC_PercentToFloat(0,ECC_Cld_DRefs[index][4][1],ECC_Cld_DRefs[index][4][2])
            elseif tonumber(buffer) > 100 then ECC_Cld_DRefs[index][1][subindex] = ECC_PercentToFloat(100,ECC_Cld_DRefs[index][4][1],ECC_Cld_DRefs[index][4][2])
            else ECC_Cld_DRefs[index][1][subindex] = ECC_PercentToFloat(tonumber(buffer),ECC_Cld_DRefs[index][4][1],ECC_Cld_DRefs[index][4][2]) end
            buffer = nil 
        end  
    elseif mode == "numeric" then
        local changed,buffer = imgui.InputText("##", ECC_Cld_DRefs[index][1][subindex], 10)
        if changed and buffer ~= "" and tonumber(buffer) then
            if tonumber(buffer) < ECC_Cld_DRefs[index][4][1] then ECC_Cld_DRefs[index][1][subindex] = ECC_Cld_DRefs[index][4][1]
            elseif tonumber(buffer) > ECC_Cld_DRefs[index][4][2] then ECC_Cld_DRefs[index][1][subindex] = ECC_Cld_DRefs[index][4][2]
            else ECC_Cld_DRefs[index][1][subindex] = tonumber(buffer) end
            buffer = nil 
        end
    end
    imgui.SameLine() imgui.TextUnformatted(unit) imgui.SameLine()
    imgui.PopItemWidth()
    if imgui.Button("Reset",50,20) then ECC_Cld_DRefs[index][1][subindex] = ECC_Cld_DRefs[j][3][1] end
end
--
function ECC_Slider(inputvar,index,mode,unit,displayformat)
    local outputvar = nil
    imgui.PushItemWidth(ECC_Preferences.AAA_Window_W - 155)
    if mode == "percent" then
        -- Slider in percentage
        local changed,buffer = imgui.SliderFloat(unit.." ",ECC_FloatToPercent(inputvar,ECC_Cld_DRefs[index][4][1],ECC_Cld_DRefs[index][4][2]),0,100,displayformat)
        if changed then outputvar = ECC_PercentToFloat(buffer,ECC_Cld_DRefs[index][4][1],ECC_Cld_DRefs[index][4][2]) buffer = nil end
    elseif mode == "numeric" then
        local changed,buffer = imgui.SliderFloat(unit.." ",inputvar,ECC_Cld_DRefs[index][4][1],ECC_Cld_DRefs[index][4][2],displayformat)
        if changed then outputvar = buffer buffer = nil end
    end
    imgui.PopItemWidth()
    return outputvar
end
function ECC_InputBox(inputvar,index,mode,unit,displayformat)
    local outputvar = nil
    imgui.PushItemWidth(40)
    if mode == "percent" then
        local changed,buffer = imgui.InputText(" ", ECC_RoundToInt(ECC_FloatToPercent(inputvar,ECC_Cld_DRefs[index][4][1],ECC_Cld_DRefs[index][4][2]),displayformat), 10)  
        if changed and buffer ~= "" and tonumber(buffer) then
            if tonumber(buffer) < 0 then outputvar = ECC_PercentToFloat(0,ECC_Cld_DRefs[index][4][1],ECC_Cld_DRefs[index][4][2])
            elseif tonumber(buffer) > 100 then outputvar = ECC_PercentToFloat(100,ECC_Cld_DRefs[index][4][1],ECC_Cld_DRefs[index][4][2])
            else outputvar = ECC_PercentToFloat(tonumber(buffer),ECC_Cld_DRefs[index][4][1],ECC_Cld_DRefs[index][4][2]) end
            buffer = nil 
        end  
    elseif mode == "numeric" then
        local changed,buffer = imgui.InputText(" ", ECC_RoundToInt(inputvar,displayformat), 10)
        if changed and buffer ~= "" and tonumber(buffer) then
            if tonumber(buffer) < ECC_Cld_DRefs[index][4][1] then outputvar = ECC_Cld_DRefs[index][4][1]
            elseif tonumber(buffer) > ECC_Cld_DRefs[index][4][2] then outputvar = ECC_Cld_DRefs[index][4][2]
            else outputvar = tonumber(buffer) end
            buffer = nil 
        end
    end
    imgui.SameLine() imgui.TextUnformatted(unit)
    imgui.PopItemWidth() 
    return outputvar
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
        --[[ Begin subwindow ]]
        if ECC_Preferences.Window_Page == 0 then
            --[[Parameter subpage dropdown selector]]
            imgui.TextUnformatted("Select a parameter group:")
            imgui.Dummy((ECC_Preferences.AAA_Window_W-15),5)
            imgui.PushItemWidth(ECC_Preferences.AAA_Window_W - 15)
            if imgui.BeginCombo("##1",ECC_Cld_SubPages[ECC_Cld_Subpage]) then
                for i = 1, #ECC_Cld_SubPages do
                    if imgui.Selectable(ECC_Cld_SubPages[i], ECC_Cld_Subpage == i) then
                        ECC_Cld_Subpage = i
                    end
                end
                imgui.EndCombo()
            end
            imgui.PopItemWidth()
            -- Parameters for the displayed dref section: start index, end index, mode
            local ECC_SectionParams = {0,0,nil,nil,nil}
            if ECC_Cld_Subpage == 1 then ECC_SectionParams = {1,4,"percent","%","%.1f"} end
            if ECC_Cld_Subpage == 2 then ECC_SectionParams = {5,9,"numeric","m","%.1f"} end
            if ECC_Cld_Subpage == 3 then ECC_SectionParams = {10,14,"percent","%","%.1f"} end
            if ECC_Cld_Subpage == 4 then ECC_SectionParams = {15,19,"numeric"," ","%.4f"} end
            if ECC_Cld_Subpage == 5 then ECC_SectionParams = {20,24,"numeric"," ","%.1f"} end
            if ECC_Cld_Subpage == 6 then ECC_SectionParams = {25,29,"percent","%","%.1f"} end
            if ECC_Cld_Subpage == 7 then ECC_SectionParams = {30,37,"percent","%","%.1f"} end
            -- Loop thorugh the selected section of the dataref table
            for j=ECC_SectionParams[1],ECC_SectionParams[2] do
                --imgui.PushID(j)
                imgui.Dummy((ECC_Preferences.AAA_Window_W-15),15)
                -- Caption
                imgui.TextUnformatted(ECC_Cld_DRefs[j][2]..":")
                --
                --[[if #ECC_Cld_DRefs[j][3] == 1 then
                    -- SLIDER (inputvar, index, mode, unit)
                    ECC_Cld_DRefs[j][1][0] = ECC_Slider(ECC_Cld_DRefs[j][1][0],j,ECC_SectionParams[3],ECC_SectionParams[4]) imgui.SameLine()
                    -- INPUTBOX (inputvar, index, mode, unit)
                    ECC_Cld_DRefs[j][1][0] = ECC_InputBox(ECC_Cld_DRefs[j][1][0],j,ECC_SectionParams[3],ECC_SectionParams[4]) imgui.SameLine()
                    if imgui.Button("Reset ##"..j,50,20) then ECC_Cld_DRefs[j][1][0] = ECC_Cld_DRefs[j][3][1] end
                end]]
                if j < 15 or j >= 25 and j <= 31 or j >= 32 and j <= 35 or j > 36 then
                    --ECC_InputElements(j,0,ECC_SectionParams[3],ECC_SectionParams[4])
                else
                    local changed,buffer = imgui.InputText("100"..j, ECC_Cld_DRefs[j][1][0], 10)
                    if changed and buffer ~= "" and tonumber(buffer) then print(buffer)
                        if tonumber(buffer) < ECC_Cld_DRefs[j][4][1] then ECC_Cld_DRefs[j][1][0] = ECC_Cld_DRefs[j][4][1]
                        elseif tonumber(buffer) > ECC_Cld_DRefs[j][4][2] then ECC_Cld_DRefs[j][1][0] = ECC_Cld_DRefs[j][4][2]
                        else ECC_Cld_DRefs[j][1][0] = tonumber(buffer) end
                        buffer = nil 
                    end    
                    local changed,buffer1 = imgui.InputText("101"..j, ECC_Cld_DRefs[j][1][1], 10)
                    if changed and buffer1 ~= "" and tonumber(buffer1) then print(buffer1)
                        if tonumber(buffer1) < ECC_Cld_DRefs[j][4][1] then ECC_Cld_DRefs[j][1][1] = ECC_Cld_DRefs[j][4][1]
                        elseif tonumber(buffer1) > ECC_Cld_DRefs[j][4][2] then ECC_Cld_DRefs[j][1][1] = ECC_Cld_DRefs[j][4][2]
                        else ECC_Cld_DRefs[j][1][1] = tonumber(buffer1) end
                        buffer1 = nil 
                    end
                    local changed,buffer2 = imgui.InputText("102"..j, ECC_Cld_DRefs[j][1][2], 10)
                    if changed and buffer2 ~= "" and tonumber(buffer2) then print(buffer2)
                        if tonumber(buffer2) < ECC_Cld_DRefs[j][4][1] then ECC_Cld_DRefs[j][1][2] = ECC_Cld_DRefs[j][4][1]
                        elseif tonumber(buffer2) > ECC_Cld_DRefs[j][4][2] then ECC_Cld_DRefs[j][1][2] = ECC_Cld_DRefs[j][4][2]
                        else ECC_Cld_DRefs[j][1][2] = tonumber(buffer2) end
                        buffer2 = nil 
                    end
                    
                    
                end
                --[[ if #ECC_Cld_DRefs[j][3] == 3 then
                    imgui.PushID(100+j)
                    -- SLIDER (inputvar, index, mode, unit)
                    ECC_Cld_DRefs[j][1][0] = ECC_Slider(ECC_Cld_DRefs[j][1][0],j,ECC_SectionParams[3],ECC_SectionParams[4]) imgui.SameLine()
                    -- INPUTBOX (inputvar, index, mode, unit)
                    ECC_Cld_DRefs[j][1][0] = ECC_InputBox(ECC_Cld_DRefs[j][1][0],j,ECC_SectionParams[3],ECC_SectionParams[4]) imgui.SameLine()
                    if imgui.Button("Reset ##"..j,50,20) then ECC_Cld_DRefs[j][1][0] = ECC_Cld_DRefs[j][3][1] end
                    imgui.PopID()
                    imgui.PushID(101+j)
                    -- SLIDER (inputvar, index, mode, unit)
                    ECC_Cld_DRefs[j][1][1] = ECC_Slider(ECC_Cld_DRefs[j][1][1],j,ECC_SectionParams[3],ECC_SectionParams[4]) imgui.SameLine()
                    -- INPUTBOX (inputvar, index, mode, unit)
                    ECC_Cld_DRefs[j][1][1] = ECC_InputBox(ECC_Cld_DRefs[j][1][1],j,ECC_SectionParams[3],ECC_SectionParams[4]) imgui.SameLine()
                    if imgui.Button("Reset ##"..j,50,20) then ECC_Cld_DRefs[j][1][1] = ECC_Cld_DRefs[j][3][1] end
                    imgui.PopID()
                    imgui.PushID(102+j)
                    -- SLIDER (inputvar, index, mode, unit)
                    ECC_Cld_DRefs[j][1][2] = ECC_Slider(ECC_Cld_DRefs[j][1][2],j,ECC_SectionParams[3],ECC_SectionParams[4]) imgui.SameLine()
                    -- INPUTBOX (inputvar, index, mode, unit)
                    ECC_Cld_DRefs[j][1][2] = ECC_InputBox(ECC_Cld_DRefs[j][1][2],j,ECC_SectionParams[3],ECC_SectionParams[4]) imgui.SameLine()
                    if imgui.Button("Reset ##"..j,50,20) then ECC_Cld_DRefs[j][1][2] = ECC_Cld_DRefs[j][3][1] end
                    imgui.PopID()
                end    ]]           
                --Advanced: Text input for value range limit
                if ECC_Cld_AdvMode then
                    imgui.PushItemWidth(ECC_Preferences.AAA_Window_W - 200)
                    local changed,buffer = imgui.InputText("Lower Raw Value Limit ##"..j, ECC_Cld_DRefs[j][4][1], 20)
                    if changed and buffer ~= "" and tonumber(buffer) then ECC_Cld_DRefs[j][4][2] = tonumber(buffer) buffer = nil end
                    local changed,buffer = imgui.InputText("Upper Raw Value Limit ##"..j, ECC_Cld_DRefs[j][4][2], 20)
                    if changed and buffer ~= "" and tonumber(buffer) then ECC_Cld_DRefs[j][4][2] = tonumber(buffer) buffer = nil end
                    imgui.PopItemWidth()
                end
                --imgui.PopID()
            -- End loop
            end
        --[[ End subwindow ]]
        end
        imgui.Dummy((ECC_Preferences.AAA_Window_W-15),20)
        --"Advanced" button
        local changed, newECC_Cld_AdvMode = imgui.Checkbox("Breakage Mode", ECC_Cld_AdvMode)
        if changed then ECC_Cld_AdvMode = newECC_Cld_AdvMode end
        --if imgui.Button("Advanced Settings",(ECC_Preferences.AAA_Window_W-15),20) then if not ECC_Cld_AdvMode then ECC_Cld_AdvMode = true else ECC_Cld_AdvMode = false end end
    end
    imgui.Dummy((ECC_Preferences.AAA_Window_W-15),20)
end
