--[[

Lua module, required by EnhCloudsController.lua
Licensed under the EUPL v1.2: https://eupl.eu/

]]
--[[

MENU LABELS, ITEMS AND ACTIONS

]]
local Menu_Name = "Enchanced Cloudscapes" -- Menu title
local Menu_Items = {"Controller Window","[Separator]","Autoload Settings"}  -- Menu entries, index starts at 1
--[[ Menu item callbacks ]]
function Menu_Callback(itemref)
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

MODULES

]]
local ffi = require ("ffi")                 -- LuaJIT FFI module
local XPLM = nil                            -- Define namespace for XPLM library
--[[ Load XPLM library ]]
ECC_Log_Write(string.format("FFI XPLM: Operating system is: %s",ffi.os))
if SYSTEM == "IBM" then XPLM = ffi.load("XPLM_64")  -- Windows 64bit
    elseif SYSTEM == "LIN" then XPLM = ffi.load("Resources/plugins/XPLM_64.so")  -- Linux 64bit (Requires "Resources/plugins/" for some reason)
    elseif SYSTEM == "APL" then XPLM = ffi.load("Resources/plugins/XPLM.framework/XPLM") -- 64bit MacOS (Requires "Resources/plugins/" for some reason)
    else return 
end
if XPLM ~= nil then ECC_Log_Write("FFI XPLM: Initialized!") end
--[[

C DEFINITIONS AND VARIABLES

]]
--[[ Add C definitions to FFI ]]
ffi.cdef([[
    /* XPLMUtilities*/
    typedef void *XPLMCommandRef;
    /* XPLMMenus */
    typedef int XPLMMenuCheck;
    typedef void *XPLMMenuID;
    typedef void (*XPLMMenuHandler_f)(void *inMenuRef,void *inItemRef);
    XPLMMenuID XPLMFindPluginsMenu(void);
    XPLMMenuID XPLMFindAircraftMenu(void);
    XPLMMenuID XPLMCreateMenu(const char *inName, XPLMMenuID inParentMenu, int inParentItem, XPLMMenuHandler_f inHandler,void *inMenuRef);
    void XPLMDestroyMenu(XPLMMenuID inMenuID);
    void XPLMClearAllMenuItems(XPLMMenuID inMenuID);
    int XPLMAppendMenuItem(XPLMMenuID inMenu,const char *inItemName,void *inItemRef,int inDeprecatedAndIgnored);
    int XPLMAppendMenuItemWithCommand(XPLMMenuID inMenu,const char *inItemName,XPLMCommandRef inCommandToExecute);
    void XPLMAppendMenuSeparator(XPLMMenuID inMenu);      
    void XPLMSetMenuItemName(XPLMMenuID inMenu,int inIndex,const char *inItemName,int inForceEnglish);
    void XPLMCheckMenuItem(XPLMMenuID inMenu,int index,XPLMMenuCheck inCheck);
    void XPLMCheckMenuItemState(XPLMMenuID inMenu,int index,XPLMMenuCheck *outCheck);
    void XPLMEnableMenuItem(XPLMMenuID inMenu,int index,int enabled);      
    void XPLMRemoveMenuItem(XPLMMenuID inMenu,int inIndex);
    ]])
--[[ Variables for FFI ]]
local Menu_ID = nil
local Menu_Pointer = ffi.new("const char")
--[[

MENU INITALIZATION AND CLEANUP

]]

--[[ Menu initialization ]]
function ECC_Menu_Init()
    if XPLM ~= nil then
        Menu_ID = XPLM.XPLMCreateMenu(Menu_Name,nil,0, function(inMenuRef,inItemRef) Menu_Callback(inItemRef) end,ffi.cast("void *",Menu_Pointer))
        for i=1,#Menu_Items do
            if Menu_Items[i] ~= "[Separator]" then
                Menu_Pointer = Menu_Items[i]
                Menu_Indices[i] = XPLM.XPLMAppendMenuItem(Menu_ID,Menu_Items[i],ffi.cast("void *",Menu_Pointer),1)
            else
                XPLM.XPLMAppendMenuSeparator(Menu_ID)
            end
        end
        ECC_Menu_Watchdog(1)        -- Watchdog for menu item 1
        ECC_Menu_Watchdog(3)        -- Watchdog for menu item 3
        ECC_Log_Write("INIT: "..Menu_Name.." menu initialized!")
    end
end
--[[ Menu cleanup upon script reload or session exit ]]
function ECC_Menu_CleanUp()
   --XPLM.XPLMClearAllMenuItems(XPLM.XPLMFindPluginsMenu())
   XPLM.XPLMDestroyMenu(Menu_ID)
end
--[[

MENU MANIPULATION WRAPPERS

]]
--[[ Menu item name change ]]
function ECC_Menu_ChangeItemPrefix(index,prefix)
    XPLM.XPLMSetMenuItemName(Menu_ID,index-1,prefix.." "..Menu_Items[index],1)
end
--[[ Menu item check status change ]]
function ECC_Menu_CheckItem(index,state)
    index = index - 1
    local out = ffi.new("XPLMMenuCheck[1]")
    XPLM.XPLMCheckMenuItemState(Menu_ID,index-1,ffi.cast("XPLMMenuCheck *",out))
    if tonumber(out[0]) == 0 then XPLM.XPLMCheckMenuItem(Menu_ID,index,1) end
    if state == "Activate" and tonumber(out[0]) ~= 2 then XPLM.XPLMCheckMenuItem(Menu_ID,index,2)
    elseif state == "Deactivate" and tonumber(out[0]) ~= 1 then XPLM.XPLMCheckMenuItem(Menu_ID,index,1)
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
