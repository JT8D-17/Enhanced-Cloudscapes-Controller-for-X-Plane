--[[

Lua module, required by EC_Controller.lua
Licensed under the EUPL v1.2: https://eupl.eu/

]]
--[[

MENU LABELS, ITEMS AND ACTIONS

]]
local Menu_Name = "Enhanced Cloudscapes" -- Menu title
local Menu_Items = {" Window","[Separator]","Autoload Settings"}  -- Menu entries, index starts at 1
--[[ Menu item callbacks ]]
local function Menu_Callback(itemref)
    if itemref == Menu_Items[1] then
        if ECC_SettingsValGet("WindowIsOpen") == 0 then ECC_Window_Show()
        elseif ECC_SettingsValGet("WindowIsOpen") == 1 then ECC_Window_Hide(ECC_Window) end
        ECC_Menu_Watchdog(1)
    end
    if itemref == Menu_Items[3] then
        if ECC_SettingsValGet("AutoLoad") == 0 then ECC_SettingsValSet("AutoLoad",1) ECC_SettingsFileWrite()
        elseif ECC_SettingsValGet("AutoLoad") == 1 then ECC_SettingsValSet("AutoLoad",0) ECC_SettingsFileWrite() end
        ECC_Menu_Watchdog(3)
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
local Menu_ID = nil
local Menu_Pointer = ECC_ffi.new("const char")
--[[ Menu initialization ]]
function ECC_Menu_Init()
    if ECC_XPLM ~= nil then
        Menu_ID = ECC_XPLM.XPLMCreateMenu(Menu_Name,nil,0, function(inMenuRef,inItemRef) Menu_Callback(inItemRef) end,ECC_ffi.cast("void *",Menu_Pointer))
        for i=1,#Menu_Items do
            if Menu_Items[i] ~= "[Separator]" then
                Menu_Pointer = Menu_Items[i]
                Menu_Indices[i] = ECC_XPLM.XPLMAppendMenuItem(Menu_ID,Menu_Items[i],ECC_ffi.cast("void *",Menu_Pointer),1)
            else
                ECC_XPLM.XPLMAppendMenuSeparator(Menu_ID)
            end
        end
        ECC_Menu_Watchdog(1)        -- Watchdog for menu item 1
        ECC_Menu_Watchdog(3)        -- Watchdog for menu item 3
        ECC_Log_Write("INIT: "..Menu_Name.." menu initialized!")
    end
end
--[[ Menu cleanup upon script reload or session exit ]]
function ECC_Menu_CleanUp()
   ECC_XPLM.XPLMClearAllMenuItems(ECC_XPLM.XPLMFindPluginsMenu())
   --ECC_XPLM.XPLMDestroyMenu(Menu_ID)
end
--[[

MENU MANIPULATION WRAPPERS

]]
--[[ Menu item name change ]]
local function ECC_Menu_ChangeItemPrefix(index,prefix)
    ECC_XPLM.XPLMSetMenuItemName(Menu_ID,index-1,prefix.." "..Menu_Items[index],1)
end
--[[ Menu item check status change ]]
function ECC_Menu_CheckItem(index,state)
    index = index - 1
    local out = ECC_ffi.new("XPLMMenuCheck[1]")
    ECC_XPLM.XPLMCheckMenuItemState(Menu_ID,index-1,ECC_ffi.cast("XPLMMenuCheck *",out))
    if tonumber(out[0]) == 0 then ECC_XPLM.XPLMCheckMenuItem(Menu_ID,index,1) end
    if state == "Activate" and tonumber(out[0]) ~= 2 then ECC_XPLM.XPLMCheckMenuItem(Menu_ID,index,2)
    elseif state == "Deactivate" and tonumber(out[0]) ~= 1 then ECC_XPLM.XPLMCheckMenuItem(Menu_ID,index,1)
    end
end
--[[ Watchdog to track window state changes ]]
function ECC_Menu_Watchdog(index)
    if index == 1 then
        if ECC_SettingsValGet("WindowIsOpen") == 0 then ECC_Menu_ChangeItemPrefix(index,"Open")
        elseif ECC_SettingsValGet("WindowIsOpen") == 1 then ECC_Menu_ChangeItemPrefix(index,"Close") end
    end
    if index == 3 then
        if ECC_SettingsValGet("AutoLoad") == 0 then ECC_Menu_CheckItem(index,"Deactivate")
        elseif ECC_SettingsValGet("AutoLoad") == 1 then ECC_Menu_CheckItem(index,"Activate") end
    end
end

