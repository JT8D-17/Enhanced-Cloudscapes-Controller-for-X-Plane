--[[

Lua module, required by ECS_Controller.lua
Licensed under the EUPL v1.2: https://eupl.eu/

]]
--[[

MENU LABELS, ITEMS AND ACTIONS

]]
local Menu_Name = "Enhanced Cloud-/Skyscapes" -- Menu title
local Menu_Items = {" Window","[Separator]","Autoload Settings"}  -- Menu entries, index starts at 1
--[[ Menu item callbacks ]]
local function Menu_Callback(itemref)
    if itemref == Menu_Items[1] then
        if ECSC_SettingsValGet("WindowIsOpen") == 0 then ECSC_Window_Show()
        elseif ECSC_SettingsValGet("WindowIsOpen") == 1 then ECSC_Window_Hide(ECSC_Window) end
        ECSC_Menu_Watchdog(1)
    end
    if itemref == Menu_Items[3] then
        if ECSC_SettingsValGet("AutoLoad") == 0 then ECSC_SettingsValSet("AutoLoad",1) ECSC_SettingsFileWrite()
        elseif ECSC_SettingsValGet("AutoLoad") == 1 then ECSC_SettingsValSet("AutoLoad",0) ECSC_SettingsFileWrite() end
        ECSC_Menu_Watchdog(3)
    end
end
--[[

INITIALIZATION

]]
local Menu_Indices = {}
for i=1,#Menu_Items do
    Menu_Indices[i] = 0
end
--[[

MENU INITALIZATION AND CLEANUP

]]
--[[ Variables for FFI ]]
local Menu_Pointer = ECSC_ffi.new("const char")
--[[ Menu initialization ]]
function ECSC_Menu_Init()
    if ECSC_XPLM ~= nil then
        ECSC_Menu_Index = ECSC_XPLM.XPLMAppendMenuItem(ECSC_XPLM.XPLMFindPluginsMenu(),Menu_Name,ECSC_ffi.cast("void *","None"),1)
        ECSC_Menu_ID = ECSC_XPLM.XPLMCreateMenu(Menu_Name,ECSC_XPLM.XPLMFindPluginsMenu(),ECSC_Menu_Index, function(inMenuRef,inItemRef) Menu_Callback(inItemRef) end,ECSC_ffi.cast("void *",Menu_Pointer))
        for i=1,#Menu_Items do
            if Menu_Items[i] ~= "[Separator]" then
                Menu_Pointer = Menu_Items[i]
                Menu_Indices[i] = ECSC_XPLM.XPLMAppendMenuItem(ECSC_Menu_ID,Menu_Items[i],ECSC_ffi.cast("void *",Menu_Pointer),1)
            else
                ECSC_XPLM.XPLMAppendMenuSeparator(ECSC_Menu_ID)
            end
        end
        ECSC_Menu_Watchdog(1)        -- Watchdog for menu item 1
        ECSC_Menu_Watchdog(3)        -- Watchdog for menu item 3
        ECSC_Log_Write("INIT: "..Menu_Name.." menu initialized!")
    end
end
--[[ Menu cleanup upon script reload or session exit ]]
function ECSC_Menu_CleanUp()
   ECSC_XPLM.XPLMClearAllMenuItems(ECSC_Menu_ID)
   ECSC_XPLM.XPLMDestroyMenu(ECSC_Menu_ID)
   ECSC_XPLM.XPLMRemoveMenuItem(ECSC_XPLM.XPLMFindPluginsMenu(),ECSC_Menu_Index)
end
--[[

MENU MANIPULATION WRAPPERS

]]
--[[ Menu item name change ]]
local function ECSC_Menu_ChangeItemPrefix(index,prefix)
    ECSC_XPLM.XPLMSetMenuItemName(ECSC_Menu_ID,index-1,prefix.." "..Menu_Items[index],1)
end
--[[ Menu item check status change ]]
function ECSC_Menu_CheckItem(index,state)
    index = index - 1
    local out = ECSC_ffi.new("XPLMMenuCheck[1]")
    ECSC_XPLM.XPLMCheckMenuItemState(ECSC_Menu_ID,index-1,ECSC_ffi.cast("XPLMMenuCheck *",out))
    if tonumber(out[0]) == 0 then ECSC_XPLM.XPLMCheckMenuItem(ECSC_Menu_ID,index,1) end
    if state == "Activate" and tonumber(out[0]) ~= 2 then ECSC_XPLM.XPLMCheckMenuItem(ECSC_Menu_ID,index,2)
    elseif state == "Deactivate" and tonumber(out[0]) ~= 1 then ECSC_XPLM.XPLMCheckMenuItem(ECSC_Menu_ID,index,1)
    end
end
--[[ Watchdog to track window state changes ]]
function ECSC_Menu_Watchdog(index)
    if index == 1 then
        if ECSC_SettingsValGet("WindowIsOpen") == 0 then ECSC_Menu_ChangeItemPrefix(index,"Open")
        elseif ECSC_SettingsValGet("WindowIsOpen") == 1 then ECSC_Menu_ChangeItemPrefix(index,"Close") end
    end
    if index == 3 then
        if ECSC_SettingsValGet("AutoLoad") == 0 then ECSC_Menu_CheckItem(index,"Deactivate")
        elseif ECSC_SettingsValGet("AutoLoad") == 1 then ECSC_Menu_CheckItem(index,"Activate") end
    end
end
