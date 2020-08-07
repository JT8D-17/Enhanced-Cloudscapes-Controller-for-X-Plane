--[[

Lua Module, required by EnhCloudsController.lua
Licensed under the EUPL v1.2: https://eupl.eu/

]]
--[[
MATHEMATICAL
]]
--[[ Converter for various units ]]
function ECC_UnitConverter(invalue,inunit,outunit)
	local outvalue = 0
    -- Length
	if inunit == "nm" and outunit == "km" then outvalue = invalue * 1.85200 end 	-- Nautical miles to kilometres
	if inunit == "m" and outunit == "ft" then outvalue = invalue * 3.28084 end		-- Metre to foot
    if inunit == "m" and outunit == "in" then outvalue = invalue * 39.3701 end      -- Metre to inch
    if inunit == "m" and outunit == "cm" then outvalue = invalue * 100 end		    -- Metre to centimetre
    if inunit == "cm" and outunit == "ft" then outvalue = invalue / 30.48 end       -- Centimetre to foot
    if inunit == "cm" and outunit == "in" then outvalue = invalue / 2.54 end        -- Centimetre to inch
    if inunit == "cm" and outunit == "m" then outvalue = invalue / 100 end		    -- Centimetre to metre
    if inunit == "ft" and outunit == "m" then outvalue = invalue / 3.28084 end		-- Foot to metre
    if inunit == "ft" and outunit == "cm" then outvalue = invalue * 30.48 end		-- Foot to centimetre
	if inunit == "ft" and outunit == "in" then outvalue = invalue * 12 end		    -- Foot to inch
	if inunit == "in" and outunit == "m" then outvalue = invalue / 39.3701 end	    -- Inch to metre
	if inunit == "in" and outunit == "cm" then outvalue = invalue * 2.54 end	    -- Inch to centimetre
	if inunit == "in" and outunit == "ft" then outvalue = invalue / 12 end	        -- Inch to foot
    -- Mass
	if inunit == "kg" and outunit == "lbs" then outvalue = invalue * 2.20462 end	-- Kilograms to pounds mass
	if inunit == "lbs" and outunit == "kg" then outvalue = invalue / 2.20462 end	-- Pounds mass to kilograms
    -- Velocity
	if inunit == "kts" and outunit == "kph" then outvalue = invalue * 1.85200 end	-- Knots to kilometres per hour
	if inunit == "kts" and outunit == "mph" then outvalue = invalue * 1.15078 end	-- Knots to miles per hour
    -- No change
    if inunit == outunit then outvalue = invalue end
	return outvalue
end
--[[ Round value to nearest integer ]]
function ECC_RoundToInt(inputval,decimals)
	local power = 10^decimals
	return math.floor(inputval * power) / power
end
--[[
TABLE OPERATIONS
]]
--[[ "ECC_PairsByKeys" is a table sorting function and will sort keys/parametres alphabetically. 
It is essential for processing the input variables, since the table loaded from the save file will have to have the exact same order as the one it is overwriting.
Credit: http://www.lua.org/pil/19.3.html ]]
function ECC_PairsByKeys(t, f)
  local a = {}
  for n in pairs(t) do table.insert(a, n) end
	table.sort(a, f)
	local i = 0      -- iterator variable
	local iter = function ()   -- iterator function
		i = i + 1
		if a[i] == nil then return nil
		else return a[i], t[a[i]]
		end
	end
  return iter
end
--[[ Calls "ECC_PairsByKeys" for a table and overwrites the original table with the result ]]
function ECC_Table_Sort(table)
	for param, value in ECC_PairsByKeys(table) do -- Save sorted list
		table[param] = value
	end
end
--[[
AUTOSAVE
]]
--[[ Check autosave status and, if enabled, trigger writing to file ]]--
function ECC_CheckAutosave(quietflag)
	if ECC_Preferences.AA_Autosave then
			ECC_File_Write("PrefsFile",quietflag)
			--if ECC_Preferences.Window_Page == 2 then ECC_WriteAircraftConfig() end
	end
end
--[[
STRING OPERATIONS
]]
--[[ Splits a line at the designated delimiter ]]
function ECC_SplitLine(input,delim)
	ECC_SplitResult = {}
	--print(input)
	for i in string.gmatch(input,delim) do table.insert(ECC_SplitResult,i) end
	--print("ECC_SplitResult: "..table.concat(ECC_SplitResult,",",1,#ECC_SplitResult))
	return ECC_SplitResult
end


function ECC_GetWindowInfo()
		if ECC_Preferences.AAA_Window_W ~= imgui.GetWindowWidth() or ECC_Preferences.AAA_Window_W ~= imgui.GetWindowWidth() or ECC_Preferences.AAA_Window_X ~= xpos or ECC_Preferences.AAA_Window_Y ~= ypos then
			ECC_Preferences.AAA_Window_W = imgui.GetWindowWidth()
			ECC_Preferences.AAA_Window_H = imgui.GetWindowHeight()
			ECC_Preferences.AAA_Window_X = xpos
			ECC_Preferences.AAA_Window_Y = ypos
			--ECC_CheckAutosave("NoLog")
		end
end
