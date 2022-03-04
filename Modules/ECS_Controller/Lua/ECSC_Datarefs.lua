--[[

Lua Module, required by ECS_Controller.lua
Licensed under the EUPL v1.2: https://eupl.eu/

]]
--[[

VARIABLES

]]
ECSC_PluginInstalled = false   -- Check if cloud plugin is installed
-- Dataref table content: "1: Dref name",2: Dref size,{3: Dref value(s)},"4: Dref title",{5: Dref default values},{6: Dref value range},{7: Copy of dref value range},8: Display mode (numeric/percent),9:Display precision,10: Sub page group
ECSC_DatarefTable = {
        {"enhanced_cloudscapes/cloud_map_scale",1,{},"Cloud Map Scale",{},{0,0.000025},{},0,8,1},
        {"enhanced_cloudscapes/base_noise_scale",1,{},"Base Noise Scale",{},{0,0.00025},{},0,8,1},
        {"enhanced_cloudscapes/detail_noise_scale",1,{},"Detail Noise Scale",{},{0,0.0025},{},0,6,1},
        {"enhanced_cloudscapes/blue_noise_scale",1,{},"Blue Noise Scale",{},{0,0.25},{},0,4,1},

        {"enhanced_cloudscapes/cirrus/coverage",1,{},"Cirrus Layer Coverage",{},{0,1.0},{},1,2,2},
        {"enhanced_cloudscapes/few/coverage",1,{},"Few Layer Coverage",{},{0,1.0},{},1,2,2},
        {"enhanced_cloudscapes/scattered/coverage",1,{},"Scattered Layer Coverage",{},{0,1.0},{},1,2,2},
        {"enhanced_cloudscapes/broken/coverage",1,{},"Broken Layer Coverage",{},{0,1.0},{},1,2,2},
        {"enhanced_cloudscapes/overcast/coverage",1,{},"Overcast Layer Coverage",{},{0,1.0},{},1,2,2},
        {"enhanced_cloudscapes/stratus/coverage",1,{},"Stratus Layer Coverage",{},{0,1.0},{},1,2,2},

        {"enhanced_cloudscapes/cirrus/density",1,{},"Cirrus Density",{},{0,0.01},{},0,6,3},
        {"enhanced_cloudscapes/few/density",1,{},"Few Density",{},{0,0.01},{},0,6,3},
        {"enhanced_cloudscapes/scattered/density",1,{},"Scattered Density",{},{0,0.01},{},0,6,3},
        {"enhanced_cloudscapes/broken/density",1,{},"Broken Density",{},{0,0.01},{},0,6,3},
        {"enhanced_cloudscapes/overcast/density",1,{},"Overcast Density",{},{0,0.01},{},0,6,3},
        {"enhanced_cloudscapes/stratus/density",1,{},"Stratus Density",{},{0,0.01},{},0,6,3},

        {"enhanced_cloudscapes/cirrus/base_noise_ratios",3,{},"Cirrus Base Noise Ratios",{},{0,1.0},{},1,2,4},
        {"enhanced_cloudscapes/few/base_noise_ratios",3,{},"Few Base Noise Ratios",{},{0,1.0},{},1,2,4},
        {"enhanced_cloudscapes/scattered/base_noise_ratios",3,{},"Scattered Base Noise Ratios",{},{0,1.0},{},1,2,4},
        {"enhanced_cloudscapes/broken/base_noise_ratios",3,{},"Broken Base Noise Ratios",{},{0,1.0},{},1,2,4},
        {"enhanced_cloudscapes/overcast/base_noise_ratios",3,{},"Overcast Base Noise Ratios",{},{0,1.0},{},1,2,4},
        {"enhanced_cloudscapes/stratus/base_noise_ratios",3,{},"Stratus Base Noise Ratios",{},{0,1.0},{},1,2,4},

        {"enhanced_cloudscapes/cirrus/detail_noise_ratios",3,{},"Cirrus Detail Noise Ratios",{},{0,1.0},{},1,2,5},
        {"enhanced_cloudscapes/few/detail_noise_ratios",3,{},"Few Detail Noise Ratios",{},{0,1.0},{},1,2,5},
        {"enhanced_cloudscapes/scattered/detail_noise_ratios",3,{},"Scattered Detail Noise Ratios",{},{0,1.0},{},1,2,5},
        {"enhanced_cloudscapes/broken/detail_noise_ratios",3,{},"Broken Detail Noise Ratios",{},{0,1.0},{},1,2,5},
        {"enhanced_cloudscapes/overcast/detail_noise_ratios",3,{},"Overcast Detail Noise Ratios",{},{0,1.0},{},1,2,5},
        {"enhanced_cloudscapes/stratus/detail_noise_ratios",3,{},"Stratus Detail Noise Ratios",{},{0,1.0},{},1,2,5},

        {"enhanced_cloudscapes/base_anvil",1,{},"Base Anvil",{},{0,10.0},{},0,2,6},
        {"enhanced_cloudscapes/top_anvil",1,{},"Top Anvil",{},{0,10.0},{},0,2,6},

        {"enhanced_cloudscapes/light_attenuation",1,{},"Light Attenuation",{},{0,10.0},{},0,2,7},
        {"enhanced_cloudscapes/sun_gain",1,{},"Sun Gain",{},{0,20.0},{},0,2,7},
        {"enhanced_cloudscapes/ambient_gain",1,{},"Ambient Gain",{},{0,20.0},{},0,2,7},
        {"enhanced_cloudscapes/mie_scattering",1,{},"Mie Scattering",{},{0,1.0},{},0,4,7},
        {"enhanced_cloudscapes/atmosphere_bottom_tint",3,{},"Atmosphere Bottom Tint",{},{0,1.0},{},1,2,7},
        {"enhanced_cloudscapes/atmosphere_top_tint",3,{},"Atmosphere Top Tint",{},{0,1.0},{},1,2,7},
        {"enhanced_cloudscapes/atmospheric_blending",1,{},"Atmospheric Blending",{},{0,1.0},{},1,2,7},

        {"enhanced_cloudscapes/skip_fragments",1,{},"Skip Fragments",{},{0,1},{},0,0,8},
        {"enhanced_cloudscapes/rendering_resolution_ratio",1,{},"Rendering Resolution Ratio",{},{0,1.0},{},0,2,8},
        {"enhanced_cloudscapes/sample_step_count",1,{},"Sample Step Count",{},{0,256},{},0,0,8},
        {"enhanced_cloudscapes/sun_step_count",1,{},"Sun Step Count",{},{0,32},{},0,0,8},
        {"enhanced_cloudscapes/maximum_sample_step_size",1,{},"Maximum Sample Step Size",{},{50,2500.0},{},0,2,8},
        {"enhanced_cloudscapes/maximum_sun_step_size",1,{},"Maximum Sun Step Size",{},{50,2500.0},{},0,2,8},
        {"enhanced_cloudscapes/use_blue_noise_dithering",1,{},"Use Blue Noise Dithering",{},{0,1},{},0,0,8},

        {"enhanced_skyscapes/clouds/ambient_gain",1,{},"Ambient Gain",{},{0,25.0},{},0,1,2},
        {"enhanced_skyscapes/clouds/base_noise_scale",1,{},"Base Noise Scale",{},{0.000001,0.0001},{},0,7,1},
        {"enhanced_skyscapes/clouds/cloud_map_scale",1,{},"Cloud Map Scale",{},{0.0000001,0.00001},{},0,8,1},
        {"enhanced_skyscapes/clouds/detail_noise_scale",1,{},"Detail Noise Scale",{},{0.00001,0.001},{},0,6,1},
        {"enhanced_skyscapes/clouds/draw",1,{},"Draw Clouds",{},{0,1},{},0,0,3},
        {"enhanced_skyscapes/clouds/maximum_drawing_distance",1,{},"Maximum Cloud Draw Distance (m)",{},{0,1000000},{},0,0,3},
        {"enhanced_skyscapes/clouds/minimum_shadow_transmittance",1,{},"Shadow Transmittance",{},{0,1.0},{},0,3,2},
        {"enhanced_skyscapes/clouds/resolution_ratio",1,{},"Cloud Resolution Ratio",{},{0,1.0},{},0,2,3},
        {"enhanced_skyscapes/clouds/skip_fragments",1,{},"Skip Fragments",{},{0,2},{},0,0,3},
        {"enhanced_skyscapes/clouds/sun_gain",1,{},"Sun Gain",{},{0,25},{},0,1,2},
        {"enhanced_skyscapes/sky/desaturation_ratio",1,{},"Desaturation Ratio",{},{0,1.0},{},0,3,2},
    }

--[[

FUNCTIONS

]]
--[[ Find Enhanced Cloudscape plugin datarefs and index those that are not present ]]
function ECSC_FindInopDrefs(intable)
    local FailedDrefs = {}
    for i=1,#intable do
        if XPLMFindDataRef(intable[i][1]) == nil then
            FailedDrefs[#FailedDrefs+1] = i
        end
    end
    --print("ECC: Could not find datarefs in dataref table indices "..table.concat(FailedDrefs,","))
    if #FailedDrefs ~= #intable then ECSC_PluginInstalled = true end
end
--[[ Dataref accessor ]]
function ECSC_AccessDref(intable,mode)
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
function ECSC_CopyDefaults(intable)
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
