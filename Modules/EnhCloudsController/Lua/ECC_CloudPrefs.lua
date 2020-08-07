--[[

Lua module, required by AircraftHelper.lua
Licensed under the EUPL v1.2: https://eupl.eu/

]]
--[[

VARIABLES (local to this module)

]]
local ECC_DRefs = { }
local ECC_Cld_PluginInstalled = false   -- Check if cloud plugin is installed

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
    ECC_DRefs = {
        {dataref_table("enhanced_cloudscapes/cloud_map_scale"),{0}},
        {dataref_table("enhanced_cloudscapes/base_noise_scale"),{0}},                    -- Default 000025
        {dataref_table("enhanced_cloudscapes/detail_noise_scale"),{0}},                  -- Default 0.0002
        {dataref_table("enhanced_cloudscapes/blue_noise_scale"),{0}},                    -- Default 0.01
        {dataref_table("enhanced_cloudscapes/cirrus/height"),{0}},                       -- Default 2500.0
        {dataref_table("enhanced_cloudscapes/scattered/height"),{0}},                    -- Default 4000.0
        {dataref_table("enhanced_cloudscapes/broken/height"),{0}},                       -- Default 5000.0
        {dataref_table("enhanced_cloudscapes/overcast/height"),{0}},                     -- Default 5000.0
        {dataref_table("enhanced_cloudscapes/stratus/height"),{0}},                      -- Default 6000.0
        {dataref_table("enhanced_cloudscapes/cirrus/coverage"),{0}},                    -- Default 0.375
        {dataref_table("enhanced_cloudscapes/scattered/coverage"),{0}},                 -- Default 0.75
        {dataref_table("enhanced_cloudscapes/broken/coverage"),{0}},                    -- Default 0.85
        {dataref_table("enhanced_cloudscapes/overcast/coverage"),{0}},                 -- Default 0.95
        {dataref_table("enhanced_cloudscapes/stratus/coverage"),{0}},                  -- Default 1.0
        {dataref_table("enhanced_cloudscapes/cirrus/base_noise_ratios"),{0,0,0}},         -- Defaults 0.625, 0.25, 0.125
        {dataref_table("enhanced_cloudscapes/scattered/base_noise_ratios"),{0,0,0}},      -- Defaults 0.625, 0.25, 0.125
        {dataref_table("enhanced_cloudscapes/broken/base_noise_ratios"),{0,0,0}},         -- Defaults 0.625, 0.25, 0.125
        {dataref_table("enhanced_cloudscapes/overcast/base_noise_ratios"),{0,0,0}},       -- Defaults 0.625, 0.25, 0.125
        {dataref_table("enhanced_cloudscapes/stratus/base_noise_ratios"),{0,0,0}},        -- Defaults 0.625, 0.25, 0.125
        {dataref_table("enhanced_cloudscapes/cirrus/detail_noise_ratios"),{0,0,0}},     -- Defaults 0.25, 0.125, 0.0625
        {dataref_table("enhanced_cloudscapes/scattered/detail_noise_ratios"),{0,0,0}},  -- Defaults 0.625, 0.25, 0.125
        {dataref_table("enhanced_cloudscapes/broken/detail_noise_ratios"),{0,0,0}},     -- Defaults 0.625, 0.25, 0.125
        {dataref_table("enhanced_cloudscapes/overcast/detail_noise_ratios"),{0,0,0}},   -- Defaults 0.625, 0.25, 0.125
        {dataref_table("enhanced_cloudscapes/stratus/detail_noise_ratios"),{0,0,0}},    -- Defaults 0.625, 0.25, 0.125
        {dataref_table("enhanced_cloudscapes/cirrus/density_multiplier"),{0}},          -- Default 0.0015
        {dataref_table("enhanced_cloudscapes/scattered/density_multiplier"),{0}},       -- Default 0.0035
        {dataref_table("enhanced_cloudscapes/broken/density_multiplier"),{0}},          -- Default 0.004
        {dataref_table("enhanced_cloudscapes/overcast/density_multiplier"),{0}},        -- Default 0.004
        {dataref_table("enhanced_cloudscapes/stratus/density_multiplier"),{0}},         -- Default 0.0045
        {dataref_table("enhanced_cloudscapes/sun_gain"),{0}},                                    -- Default 3.25
        {dataref_table("enhanced_cloudscapes/ambient_tint"),{0,0,0}},                             -- Defaults 1.0, 1.0, 1.0
        {dataref_table("enhanced_cloudscapes/ambient_gain"),{0}},                            -- Default 1.5
        {dataref_table("enhanced_cloudscapes/forward_mie_scattering"),{0}},        -- Default 0.85
        {dataref_table("enhanced_cloudscapes/backward_mie_scattering"),{0}},      -- Default 0.25
        {dataref_table("enhanced_cloudscapes/atmosphere_bottom_tint"),{0,0,0}},         -- Defaults 0.55, 0.775, 1.0
        {dataref_table("enhanced_cloudscapes/atmosphere_top_tint"),{0,0,0}},               -- Defaults 0.45, 0.675, 1.0
        {dataref_table("enhanced_cloudscapes/atmospheric_blending"),{0}},            -- Default 0.675    
    }
    -- Get default values
    for i=1,#ECC_DRefs do
        if #ECC_DRefs[i][2] == 1 then
            ECC_DRefs[i][2][1] = ECC_DRefs[i][1][0]
            --print(i.." : "..ECC_DRefs[i][2][1]) 
        end
        if #ECC_DRefs[i][2] == 2 then 
            ECC_DRefs[i][2][1] = ECC_DRefs[i][1][0]
            ECC_DRefs[i][2][2] = ECC_DRefs[i][1][1]
            --print(i.." : "..ECC_DRefs[i][2][1]..", "..ECC_DRefs[i][2][2]) 
        end
        if #ECC_DRefs[i][2] == 3 then
            ECC_DRefs[i][2][1] = ECC_DRefs[i][1][0]
            ECC_DRefs[i][2][2] = ECC_DRefs[i][1][1]
            ECC_DRefs[i][2][3] = ECC_DRefs[i][1][2]
            --print(i.." : "..ECC_DRefs[i][2][1]..", "..ECC_DRefs[i][2][2]..", "..ECC_DRefs[i][2][3]) 
        end
    end
end
--[[

FUNCTIONS

]]


--[[

IMGUI WINDOW ELEMENT

]]
function ECC_Win_CloudPrefs()
    
    
    
end
