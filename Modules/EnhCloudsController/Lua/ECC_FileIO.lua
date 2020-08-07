--[[

Lua Module, required by EnhCloudsController.lua
Licensed under the EUPL v1.2: https://eupl.eu/

]]
--[[ File write function ]]
function ECC_WriteTableToFile(targetfile,sourcetable,quietflag)
	if quietflag ~= "NoLog" then ECC_Log_Write("FILE INIT WRITE: "..targetfile) end
	file = io.open(targetfile, "w")
	file:write("-- "..ECC_ScriptName.." save file, created "..os.date().." --\n") -- Write file header
	for param, value in ECC_PairsByKeys(sourcetable) do -- Save sorted list
		local valtype = type(value) -- Store value type
		value=tostring(value) -- Convert all values to string (useful for booleans)
		-- print(param.." = "..value.." : "..valtype)
		file:write(param," = ",value," : ",valtype,"\n") -- Write parameter, value and type to file
	end
	if quietflag ~= "NoLog" then if file:seek("end") > 0 then ECC_Notification("FILE WRITE SUCCESS: "..targetfile,"Success","log") else ECC_Notification("FILE WRITE ERROR: "..targetfile,"Error","log") end end
	file:close()
end
--[[ Wrapper for writing to file ]]
function ECC_File_Write(target,quietflag)
	if tostring(target) == "PrefsFile" then
		ECC_WriteTableToFile(ECC_PrefsFile,ECC_Preferences,quietflag)
	end
end
--[[ File reading function ]]
function ECC_ReadFileToTable(sourcefile,targettable)
	local file = io.open(sourcefile, "r")
	if file then
		ECC_Log_Write("FILE INIT READ: "..sourcefile)
		local i = 0
		for line in file:lines() do
			local linenew=string.gsub(line, '\r$', '') -- Remove carriage return from end of line
			local position = string.find(line, "=", 2, true)
			if position then
				local param, value, valtype = line:match("(.*)%s=%s(.*)%s:%s(.*)") --Split line
				--print("Param: "..param.." Value: "..value.." Type: "..valtype)
				if ECC_Check_Autoload and ECC_Preferences.AA_Autoload then i = 0 break end -- Abort loading when "Autoload" variable is found and set to "false"
				if valtype == "boolean" then targettable[param] = ( value == "true" ) -- Checks for and sets boolean values. Credit to jjj.
				elseif valtype == "number" then targettable[param] = tonumber(value) -- Checks for and sets number type values. Credit to jjj.
				else targettable[param] = value end -- Interprets value as string. Credit to jjj.
				--ECC_Log_Write("-- "..param.." = "..value)
				i = i + 1
			end
		end
		file:close()
		if i ~= nil and i > 0 then ECC_Notification("FILE READ SUCCESS: "..sourcefile,"Success","log") else ECC_Notification("FILE READ ERROR: "..sourcefile,"Error","log") end
		--ECC_Check_Autoload = false
	else
        ECC_Notification("FILE NOT FOUND: "..sourcefile,"Error","log")
		ECC_Check_AutoLoad = false
	end
end
--[[ Wrapper for file reading ]]
function ECC_File_Read(target)
	if tostring(target) == "PrefsFile" then
		ECC_ReadFileToTable(ECC_PrefsFile,ECC_Preferences)
	end
end
--[[

OTHER FILE IO OPERATIONS

]]
--[[ Write to log file ]]
function ECC_Log_Write(string)
	local file = io.open(ECC_LogFile, "a") -- Check if file exists
	file:write(os.date("%x, %H:%M:%S"),": ",string,"\n")
	file:close()
end
--[[ Deletes a file ]]--
function ECC_File_Delete(target)
	if tostring(target) == "PrefsFile" then os.remove(ECC_PrefsFile) ECC_Notification("FILE DELETE: "..ECC_PrefsFile,"Warning","log") end
	if tostring(target) == "Log" then os.remove(ECC_LogFile) ECC_Notification("FILE DELETE: "..ECC_LogFile,"Warning","log") end
end
