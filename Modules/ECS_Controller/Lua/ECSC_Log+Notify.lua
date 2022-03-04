--[[

Lua Module, required by ECS_Controller.lua
Licensed under the EUPL v1.2: https://eupl.eu/

]]
--[[

VARIABLES (local to this module)

]]
local ECSC_LogFile = MODULES_DIRECTORY.."ECS_Controller/Log.txt"          -- Log file path
ECSC_NotificationStack = { }                     -- Array for the notification stack
local toremove = {}
--[[

FUNCTIONS

]]
--[[ Write to log file ]]
function ECSC_Log_Write(string)
	local file = io.open(ECSC_LogFile, "a") -- Check if file exists
	file:write(os.date("%x, %H:%M:%S"),": ",string,"\n")
	file:close()
end
--[[ Delete log file ]]
function ECSC_Log_Delete()
    os.remove(ECSC_LogFile) ECSC_Notification("FILE DELETE: "..ECSC_LogFile,"Warning","log")
end
--[[ Available types: "Success","Advisory","Warning","Error"]]
function ECSC_Notification(messagestring,messagetype,writelog)
    ECSC_NotificationStack[(#ECSC_NotificationStack+1)] = {}
    ECSC_NotificationStack[#ECSC_NotificationStack][1] = messagestring
    ECSC_NotificationStack[#ECSC_NotificationStack][2] = messagetype
    ECSC_NotificationStack[#ECSC_NotificationStack][3] = os.clock() + ECSC_SettingsValGet("NotificationDispTime")
    --print(table.concat(ECSC_NotificationStack[#ECSC_NotificationStack],";",1,#ECSC_NotificationStack[#ECSC_NotificationStack]))
    if writelog == "log" then
        ECSC_Log_Write(messagestring)
    end
end
--[[ 

IMGUI WINDOW ELEMENT

]]
function ECSC_Win_Notifications()
    --------------------------------------------------------
	imgui.Separator()
	--------------------------------------------------------
    imgui.TextUnformatted("Notifications:")
    -- Only display when message stack table is empty
    if #ECSC_NotificationStack == 0 then
        imgui.TextUnformatted("(None)")
    end
    -- Loop through stack, see if a stack message is valid, then display it colored according to type. If not valid anymore, mark it for deletion by noting the subtable index
    for k=1,#ECSC_NotificationStack do
        if os.clock() <= ECSC_NotificationStack[k][3] then
            if tostring(ECSC_NotificationStack[k][2]) == "Success" then imgui.PushStyleColor(imgui.constant.Col.Text, ECSC_ImguiColors[5]) imgui.TextUnformatted(ECSC_NotificationStack[k][1]) imgui.PopStyleColor()
            elseif tostring(ECSC_NotificationStack[k][2]) == "Advisory" then imgui.PushStyleColor(imgui.constant.Col.Text, ECSC_ImguiColors[6]) imgui.TextUnformatted(ECSC_NotificationStack[k][1]) imgui.PopStyleColor()
            elseif tostring(ECSC_NotificationStack[k][2]) == "Warning" then imgui.PushStyleColor(imgui.constant.Col.Text, ECSC_ImguiColors[7]) imgui.TextUnformatted(ECSC_NotificationStack[k][1]) imgui.PopStyleColor()
            elseif tostring(ECSC_NotificationStack[k][2]) == "Error" then imgui.PushStyleColor(imgui.constant.Col.Text, ECSC_ImguiColors[4]) imgui.TextUnformatted(ECSC_NotificationStack[k][1]) imgui.PopStyleColor() end
        else
            toremove[#toremove+1] = k
        end
    end
    -- If index table for deletion is not empty, loop through it and delete the subtable from the message stack table by index
    if #toremove > 0 then
        for l=1,#toremove do
            table.remove(ECSC_NotificationStack,toremove[l])
            --imgui.TextUnformatted(toremove[l])
            toremove = {}
        end
    end
end
