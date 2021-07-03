--[[

Lua Module, required by EC_Controller.lua
Licensed under the EUPL v1.2: https://eupl.eu/

]]
--[[

VARIABLES (local to this module)

]]
local ECC_LogFile = MODULES_DIRECTORY.."EC_Controller/Log.txt"          -- Log file path
ECC_NotificationStack = { }                     -- Array for the notification stack 
local toremove = {}
--[[

FUNCTIONS

]]
--[[ Write to log file ]]
function ECC_Log_Write(string)
	local file = io.open(ECC_LogFile, "a") -- Check if file exists
	file:write(os.date("%x, %H:%M:%S"),": ",string,"\n")
	file:close()
end
--[[ Delete log file ]]
function ECC_Log_Delete()
    os.remove(ECC_LogFile) ECC_Notification("FILE DELETE: "..ECC_LogFile,"Warning","log")
end
--[[ Available types: "Success","Advisory","Warning","Error"]]
function ECC_Notification(messagestring,messagetype,writelog)
    ECC_NotificationStack[(#ECC_NotificationStack+1)] = {}
    ECC_NotificationStack[#ECC_NotificationStack][1] = messagestring
    ECC_NotificationStack[#ECC_NotificationStack][2] = messagetype
    ECC_NotificationStack[#ECC_NotificationStack][3] = os.clock() + ECC_SettingsValGet("NotificationDispTime")
    --print(table.concat(ECC_NotificationStack[#ECC_NotificationStack],";",1,#ECC_NotificationStack[#ECC_NotificationStack]))
    if writelog == "log" then
        ECC_Log_Write(messagestring)
    end
end
--[[ 

IMGUI WINDOW ELEMENT

]]
function ECC_Win_Notifications()
    --------------------------------------------------------
	imgui.Separator()
	--------------------------------------------------------
    imgui.TextUnformatted("Notifications:")
    -- Only display when message stack table is empty
    if #ECC_NotificationStack == 0 then
        imgui.TextUnformatted("(None)")
    end
    -- Loop through stack, see if a stack message is valid, then display it colored according to type. If not valid anymore, mark it for deletion by noting the subtable index
    for k=1,#ECC_NotificationStack do
        if os.clock() <= ECC_NotificationStack[k][3] then
            if tostring(ECC_NotificationStack[k][2]) == "Success" then imgui.PushStyleColor(imgui.constant.Col.Text, ECC_ImguiColors[5]) imgui.TextUnformatted(ECC_NotificationStack[k][1]) imgui.PopStyleColor()
            elseif tostring(ECC_NotificationStack[k][2]) == "Advisory" then imgui.PushStyleColor(imgui.constant.Col.Text, ECC_ImguiColors[6]) imgui.TextUnformatted(ECC_NotificationStack[k][1]) imgui.PopStyleColor() 
            elseif tostring(ECC_NotificationStack[k][2]) == "Warning" then imgui.PushStyleColor(imgui.constant.Col.Text, ECC_ImguiColors[7]) imgui.TextUnformatted(ECC_NotificationStack[k][1]) imgui.PopStyleColor()
            elseif tostring(ECC_NotificationStack[k][2]) == "Error" then imgui.PushStyleColor(imgui.constant.Col.Text, ECC_ImguiColors[4]) imgui.TextUnformatted(ECC_NotificationStack[k][1]) imgui.PopStyleColor() end
        else
            toremove[#toremove+1] = k
        end
    end
    -- If index table for deletion is not empty, loop through it and delete the subtable from the message stack table by index
    if #toremove > 0 then
        for l=1,#toremove do
            table.remove(ECC_NotificationStack,toremove[l])
            --imgui.TextUnformatted(toremove[l])
            toremove = {}
        end
    end
end
