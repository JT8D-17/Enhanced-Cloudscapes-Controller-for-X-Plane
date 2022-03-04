--[[

Lua Module, required by ECS_Controller.lua
Licensed under the EUPL v1.2: https://eupl.eu/

]]
--[[

VARIABLES (local to this module)

]]
ECSC_PageDB = {}                 -- Subpage database, generated at initialization
--[[

MODULES

]]
ECSC_XPLM = nil                              -- Define namespace for XPLM library

--[[ Load XPLM library ]]
ECSC_Log_Write(string.format("FFI XPLM: Operating system is: %s",ECSC_ffi.os))
if SYSTEM == "IBM" then ECSC_XPLM = ECSC_ffi.load("XPLM_64")  -- Windows 64bit
    elseif SYSTEM == "LIN" then ECSC_XPLM = ECSC_ffi.load("Resources/plugins/XPLM_64.so")  -- Linux 64bit (Requires "Resources/plugins/" for some reason)
    elseif SYSTEM == "APL" then ECSC_XPLM = ECSC_ffi.load("Resources/plugins/XPLM.framework/XPLM") -- 64bit MacOS (Requires "Resources/plugins/" for some reason)
    else return
end
if ECSC_XPLM ~= nil then ECSC_Log_Write("FFI XPLM: Initialized!") end
--[[

C DEFINITIONS AND VARIABLES

]]
--[[ Add C definitions to FFI ]]
ECSC_ffi.cdef([[
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
    /* XPLMDataAccess - inop because they're dumb cunts and can not be accessed */
    /* typedef void *XPLMDataRef;
    int XPLMGetDatab(XPLMDataRef inDataRef,void *outValue,int inOffset,int inMaxBytes);
    void XPLMSetDatab(XPLMDataRef inDataRef,void *inValue,int inOffset,int inLength); */
    ]])
--[[

FUNCTIONS

]]
--[[ Refresh page database ]]
function ECSC_Refresh_PageDB(intitle)
    --print(ECSC_ScriptName..": Updating window page database")
    ECSC_PageDB[#ECSC_PageDB+1] = {}
    ECSC_PageDB[#ECSC_PageDB][1] = intitle
    ECSC_PageDB[#ECSC_PageDB][2] = #ECSC_PageDB
    --for i=1,#ECSC_PageDB do
       --print(ECSC_ScriptName..": "..table.concat(ECSC_PageDB[i]," : "))
    --end
end
--[[ Find page number by title ]]
function ECSC_PageNumGet(intitle)
    local result
    for i=1,#ECSC_PageDB do
      if ECSC_PageDB[i][1] == intitle then result = ECSC_PageDB[i][2] end
    end
    return result
end
--[[ Displays a tooltip ]]
function ECSC_ItemTooltip(string)
    if imgui.IsItemActive() or imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.PushTextWrapPos(imgui.GetFontSize() * 30)
        imgui.TextUnformatted(string)
        imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end

--[[ Gets a list of files from a directory using the specified filter and outputs them to a table ]]
function ECSC_GetFileList(inputdir,outputtable,filter)
    local resfile = nil
    if SYSTEM == "IBM" then resfile = io.popen('dir "'..inputdir..'" /b')
    elseif SYSTEM == "LIN" then resfile = io.popen('ls -AU1N "'..inputdir..'"')
    elseif SYSTEM == "APL" then
    else return end
    if resfile ~= nil then
        for i=2, #outputtable do outputtable[i] = nil end -- Reset output table
        for filename in resfile:lines() do
            if string.find(filename,filter) then
                outputtable[#outputtable+1] = filename:match "[^.]+"
            end
        end
        resfile:close()
        --print(table.concat(outputtable,", "))
    end
    return outputtable
end
