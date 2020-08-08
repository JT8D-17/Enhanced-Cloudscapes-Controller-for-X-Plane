--[[

AircraftHelper component (load manager function library), required by AircraftHelper.lua

]]
--[[

VARIABLES (local to this module)

]]
local ECC_LM_DeleteStationNum = 0                       -- Selected payload station to delete
local ECC_LM_CG_Limits = {0,"in",0,"in"}                -- Center of gravity limits
local ECC_LM_EmptyCGOffset = {0,"in"}                   -- Empty center of gravity offset from the value specified in PlaneMaker
local ECC_LM_SubPage = 0                                -- Current subpage of the wload manager window
local ECC_LM_Cache_m = {0,0,0,0,0}                      -- Property cache for masses {empty,payload,ZFW,fuel,total}
local ECC_LM_DispUnits = {"lbs","ft"}                   -- Display units
local ECC_LM_Cache_CG = {0}                             -- Property cache for CG {empty}
--[[

DATAREFS (local to this module)

]]
local ECC_DR_MassEmpty  = dataref_table("sim/aircraft/weight/acf_m_empty")				-- Empty aircraft weight (kilograms)
local ECC_DR_MassFuel  = dataref_table("sim/flightmodel/weight/m_fuel") 				-- Fuel mass in tank (kilograms; table!)
local ECC_DR_MassMaximum  = dataref_table("sim/aircraft/weight/acf_m_max")				-- Maximum aircraft weight (kilograms)
local ECC_DR_MassFuelTotal  = dataref_table("sim/aircraft/weight/acf_m_fuel_tot") 		-- Maximum total fuel mass (kilograms)
local ECC_DR_NumFuelTanks = dataref_table("sim/aircraft/overflow/acf_num_tanks") 		-- Number of fuel tanks
local ECC_DR_CGRef  = dataref_table("sim/aircraft/weight/acf_cgZ_original") 		    -- Reference CG from the visual origin (feet)
--[[

FUNCTIONS

]]
--[[ Refresh property cache ]]
local function ECC_LM_RefreshCache()
    --[[ Masses ]]
    -- Reset cache values
    for a=1,#ECC_LM_Cache_m do
        ECC_LM_Cache_m[a] = 0
    end
    -- Update empty mass
    ECC_LM_Cache_m[1] = ECC_DR_MassEmpty[0]
    -- Loop through payload stations
    for b=1,#ECC_LM_Stations do
        --Check station unit and if lbs convert to kg
        if ECC_LM_Stations[b][5] == "lbs" then
            --print("Station "..b.." mass is "..ECC_LM_Stations[b][2].." lbs ("..ECC_UnitConverter(ECC_LM_Stations[b][2],"lbs","kg").." kg)")
           ECC_LM_Cache_m[2] = ECC_LM_Cache_m[2] + ECC_UnitConverter(ECC_LM_Stations[b][2],"lbs","kg") -- Add mass from station to total mass
        else
           --print("Station "..b.." mass is "..ECC_LM_Stations[b][2].." kg")
           ECC_LM_Cache_m[2] = ECC_LM_Cache_m[2] + ECC_LM_Stations[b][2] -- Add mass from station to total mass
        end
    end
    ECC_LM_Cache_m[3] = ECC_LM_Cache_m[1] + ECC_LM_Cache_m[2] -- Calculate ZFW
    -- Loop through number of fuel tanks
    for c=1,ECC_DR_NumFuelTanks[0] do
        ECC_LM_Cache_m[4] = ECC_LM_Cache_m[4] + ECC_DR_MassFuel[(c-1)]
    end
    ECC_LM_Cache_m[5] = ECC_LM_Cache_m[3] + ECC_LM_Cache_m[4]
    --[[ Center of Gravity ]]
    -- Reset cache values
    for d=1,#ECC_LM_Cache_CG do
        ECC_LM_Cache_CG[d] = 0
    end
    -- Apply offset to predefined CoG
    if ECC_LM_EmptyCGOffset[2] == "in" then
        ECC_LM_Cache_CG[1] = ECC_DR_CGRef[0] + ECC_UnitConverter(ECC_LM_EmptyCGOffset[1],"in","ft")
    elseif ECC_LM_EmptyCGOffset[2] == "cm" then
        ECC_LM_Cache_CG[1] = ECC_DR_CGRef[0] + ECC_UnitConverter(ECC_LM_EmptyCGOffset[1],"cm","ft")
     elseif ECC_LM_EmptyCGOffset[2] == "m" then
        ECC_LM_Cache_CG[1] = ECC_DR_CGRef[0] + ECC_UnitConverter(ECC_LM_EmptyCGOffset[1],"m","ft")
    end
end
--[[ Add payload station ]]
local function ECC_LM_AddStation()
    ECC_LM_Stations[#ECC_LM_Stations+1] = {"[No name]",0,10000,0,"lbs",0,"in"} -- Name, Mass, Maximum mass, Mass increment, Mass unit, Lon moment arm, Lon moment arm unit
    ECC_LM_Stations[#ECC_LM_Stations][1] = "[No name "..#ECC_LM_Stations.."]"
    ECC_WriteAircraftConfig()
end

--[[ Insert payload station ]]
local function ECC_LM_InsertStation()

    
    ECC_WriteAircraftConfig()
end

--[[ Remove payload station ]]
local function ECC_LM_RemoveStation()
    table.remove(ECC_LM_Stations,ECC_LM_DeleteStationNum)
    ECC_LM_DeleteStationNum = 0
    ECC_WriteAircraftConfig()
end

local function ECC_LM_SwitchUnit(prop,station)
    if prop == "mass" then
        if ECC_LM_Stations[station][5] == "lbs" then ECC_LM_Stations[station][5] = "kg" 
        elseif ECC_LM_Stations[station][5] == "kg" then ECC_LM_Stations[station][5] = "lbs" end
    end
    if prop == "length" then
        if ECC_LM_Stations[station][7] == "in" then ECC_LM_Stations[station][7] = "ft" 
        elseif ECC_LM_Stations[station][7] == "ft" then ECC_LM_Stations[station][7] = "m" 
        elseif ECC_LM_Stations[station][7] == "m" then ECC_LM_Stations[station][7] = "cm" 
        elseif ECC_LM_Stations[station][7] == "cm" then ECC_LM_Stations[station][7] = "in" 
        end
    end
end

local function ECC_LM_SwitchUnit_Single(inputtable,index,prop)
    if prop == "mass" then
        if inputtable[index] == "lbs" then inputtable[index] = "kg" 
        elseif inputtable[index] == "kg" then inputtable[index] = "lbs" end
    end
    if prop == "length" then
        if inputtable[index] == "in" then inputtable[index] = "ft" 
        elseif inputtable[index] == "ft" then inputtable[index] = "m" 
        elseif inputtable[index] == "m" then inputtable[index] = "cm" 
        elseif inputtable[index] == "cm" then inputtable[index] = "in" 
        end
    end
end

--[[ Write payload station ]]
function ECC_WriteAircraftConfig()
    ECC_Log_Write("FILE INIT WRITE: "..ECC_AircraftSaveFile)
    local file = io.open(ECC_AircraftSaveFile, "w")
    file:write("Aircraft Helper configuration file created/updated on ",os.date("%x, %H:%M:%S"),"\n")
    file:write("SubPage="..ECC_LM_SubPage.."\n")
    file:write("DispUnits,"..ECC_LM_DispUnits[1]..","..ECC_LM_DispUnits[2].."\n")
    --[[ Write CG Limits ]]
    file:write("CG_Limits,"..ECC_LM_CG_Limits[1]..","..ECC_LM_CG_Limits[2]..","..ECC_LM_CG_Limits[3]..","..ECC_LM_CG_Limits[4].."\n")
    --[[ Write Empty CG offset ]]
    file:write("CG_Offset,"..ECC_LM_EmptyCGOffset[1]..","..ECC_LM_EmptyCGOffset[2].."\n")
    --[[ Write Payload Stations ]]
    if #ECC_LM_Stations > 0 then
        for b=1,#ECC_LM_Stations do
            file:write("PAYLOAD_STATION,")
            for c=1,#ECC_LM_Stations[b] do
                if c ~= #ECC_LM_Stations[b] then file:write(tostring(ECC_LM_Stations[b][c]),",") else file:write(tostring(ECC_LM_Stations[b][c]),"\n") end
            end
        end
    end
    if file:seek("end") > 0 then ECC_Notification("FILE WRITE SUCCESS: "..ECC_AircraftSaveFile,"Success","log") else ECC_Notification("FILE WRITE ERROR: "..ECC_AircraftSaveFile,"Error","log") end
	file:close()
end


function ECC_ReadAircraftConfig()
   local file = io.open(ECC_AircraftSaveFile, "r")
    if file then
        ECC_Log_Write("FILE INIT READ: "..ECC_AircraftSaveFile)
        local i = 0
        for line in file:lines() do
            --[[ Read subpage ]]
            if string.match(line,"^SubPage=") then
                ECC_SplitLine(line,"([^=]+)")
                ECC_LM_SubPage = tonumber(ECC_SplitResult[2])
            end
            --[[ Read display units ]]
            if string.match(line,"^DispUnits,") then
                ECC_SplitLine(line,"([^,]+)")
                ECC_LM_DispUnits[1] = tostring(ECC_SplitResult[2])
                ECC_LM_DispUnits[2] = tostring(ECC_SplitResult[3])
            end
            --[[ Read CG limits ]]
            if string.match(line,"^CG_Limits,") then
                ECC_SplitLine(line,"([^,]+)")
                ECC_LM_CG_Limits[1] = tonumber(ECC_SplitResult[2])
                ECC_LM_CG_Limits[2] = tostring(ECC_SplitResult[3])
                ECC_LM_CG_Limits[3] = tonumber(ECC_SplitResult[4])
                ECC_LM_CG_Limits[4] = tostring(ECC_SplitResult[5])
            end
            --[[ Read CoG offset ]]
            if string.match(line,"^CG_Offset,") then
                ECC_SplitLine(line,"([^,]+)")
                ECC_LM_EmptyCGOffset[1] = tonumber(ECC_SplitResult[2])
                ECC_LM_EmptyCGOffset[2] = tostring(ECC_SplitResult[3])
            end
            --[[ Read payload stations ]]
            if string.match(line,"^PAYLOAD_STATION,") then
                ECC_LM_Stations[#ECC_LM_Stations+1] = { }
                ECC_SplitLine(line,"([^,]+)")
                ECC_LM_Stations[#ECC_LM_Stations][1] = tostring(ECC_SplitResult[2]) -- Title
                ECC_LM_Stations[#ECC_LM_Stations][2] = tonumber(ECC_SplitResult[3])	-- Mass
                ECC_LM_Stations[#ECC_LM_Stations][3] = tonumber(ECC_SplitResult[4])	-- Max Mass
                ECC_LM_Stations[#ECC_LM_Stations][4] = tonumber(ECC_SplitResult[5])	-- Mass increment
                ECC_LM_Stations[#ECC_LM_Stations][5] = tostring(ECC_SplitResult[6])	-- Mass unit
                ECC_LM_Stations[#ECC_LM_Stations][6] = tonumber(ECC_SplitResult[7])	-- Moment arm
                ECC_LM_Stations[#ECC_LM_Stations][7] = tostring(ECC_SplitResult[8])	-- Moment arm unit
				--print(table.concat(ECC_LM_Stations[#ECC_LM_Stations], ",", 1,#ECC_LM_Stations[#ECC_LM_Stations]))
				--for h=1,#ECC_LM_Stations[#ECC_LM_Stations] do
					--print(type(ECC_LM_Stations[#ECC_LM_Stations][h]))
				--end
            end
            i = i+1
        end
        file:close()
		if i ~= nil and i > 0 then ECC_Notification("FILE READ SUCCESS: "..ECC_AircraftSaveFile,"Success","log") else ECC_Notification("FILE READ ERROR: "..ECC_AircraftSaveFile,"Error","log") end
    else
        ECC_Notification("FILE NOT FOUND: "..ECC_AircraftSaveFile,"Error","log")
		ECC_Check_AutoLoad = false
	end
end
--[[

IMGUI WINDOW ELEMENT

]]
function ECC_Win_LoadManager()
	--[[ Obtain and store window information ]]
	ECC_GetWindowInfo()
    --[[ Button ]]
    if ECC_Preferences.Window_Page == 0 then
        if imgui.Button("Load Manager",(ECC_Preferences.AAA_Window_W-15),20) then ECC_Preferences.Window_Page = 2 ECC_CheckAutosave() end
    end
    -- [[ Page ]]
    if ECC_Preferences.Window_Page == 2 then
        --[[ "Back" button ]]
        if imgui.Button("Main Menu ##Back2",(ECC_Preferences.AAA_Window_W-15),20) then ECC_LM_SubPage = 0 ECC_Preferences.Window_Page = 0 ECC_CheckAutosave() end
        imgui.Dummy((ECC_Preferences.AAA_Window_W-15),10)
        imgui.Separator()
        --[[ Subpage 0 or 1 ]]
        if ECC_LM_SubPage == 0 or ECC_LM_SubPage == 1 then
			if #ECC_LM_Stations == 0 then
				imgui.PushStyleColor(imgui.constant.Col.Text, ECC_ImguiColors[7]) imgui.TextUnformatted("No payload stations found. Entering edit mode will add a station.") imgui.PopStyleColor()
			else
				--[[ Station List ]]
				for a=1,#ECC_LM_Stations do
					imgui.PushID(a)
					-- Loop through stations
					if ECC_LM_SubPage == 0 then
						imgui.TextUnformatted("Station Title : "..ECC_LM_Stations[a][1])
						--imgui.TextUnformatted("Assigned Mass : "..ECC_LM_Stations[a][2].." "..ECC_LM_Stations[a][5])
						if ECC_LM_Stations[a][4] == 0 then -- Mass mode
							-- Mass slider
							imgui.PushItemWidth(ECC_Preferences.AAA_Window_W - 125)
							local changed,buffer = imgui.SliderFloat("##Station "..a.." Mass Slider 1",ECC_LM_Stations[a][2], 0, ECC_LM_Stations[a][3], "%.1f") imgui.SameLine()
							if changed then ECC_LM_Stations[a][2] = buffer buffer = nil end
							imgui.PopItemWidth()
							-- Mass type-in box
							imgui.PushItemWidth(55)
							local changed,buffer = imgui.InputText("##Station "..a.." Mass 1", ECC_RoundToInt(ECC_LM_Stations[a][2],1), 10) imgui.SameLine() imgui.TextUnformatted(ECC_LM_Stations[a][5])
							if changed and buffer ~= "" and tonumber(buffer) then 
								if ECC_LM_Stations[a][3] >= tonumber(buffer) then ECC_LM_Stations[a][2] = tonumber(buffer) else ECC_LM_Stations[a][2] = ECC_LM_Stations[a][3] end 
							buffer = nil end
							imgui.PopItemWidth()
						else -- Increment/pax mode
							local TempMass = ECC_RoundToInt(ECC_LM_Stations[a][2]/ECC_LM_Stations[a][4],0)
							local TempLim = ECC_RoundToInt(ECC_LM_Stations[a][3]/ECC_LM_Stations[a][4],0)
							-- Mass slider
							imgui.PushItemWidth(ECC_Preferences.AAA_Window_W - 125)
							local changed,buffer = imgui.SliderInt("##Station "..a.." Mass Slider 2",TempMass, 0,TempLim, "%.0d") imgui.SameLine()
							if changed then ECC_LM_Stations[a][2] = (buffer * ECC_LM_Stations[a][4]) buffer = nil end
							imgui.PopItemWidth()
							-- Mass type-in box
							imgui.PushItemWidth(55)
							local changed,buffer = imgui.InputText("##Station "..a.." Mass 2", TempMass, 10) imgui.SameLine() imgui.TextUnformatted("pax")
							if changed and buffer ~= "" and tonumber(buffer) then 
								if TempLim >= tonumber(buffer) then ECC_LM_Stations[a][2] = (buffer * ECC_LM_Stations[a][4]) else ECC_LM_Stations[a][2] = (TempLim * ECC_LM_Stations[a][4]) end 
							buffer = nil end
							imgui.PopItemWidth()
						end
						-- Mass moment display
						imgui.TextUnformatted("Moment        : "..ECC_RoundToInt(ECC_LM_Stations[a][2] * ECC_LM_Stations[a][6],1).." "..ECC_LM_Stations[a][5].."-"..ECC_LM_Stations[a][7])
						imgui.Separator()
					elseif ECC_LM_SubPage == 1 then
						imgui.PushItemWidth(185)
						--
						imgui.TextUnformatted("Title (25 chars max)       ") imgui.SameLine()
						local changed,buffer = imgui.InputText("##Station "..a.." Title",ECC_LM_Stations[a][1], 26)
						if changed and buffer ~= "" and tostring(buffer) then ECC_LM_Stations[a][1] = tostring(buffer) buffer = nil end
						--
						imgui.TextUnformatted("Mass divider (for pax/crew)") imgui.SameLine()
						local changed,buffer = imgui.InputText("##Station "..a.." IsPax", ECC_LM_Stations[a][4], 10) 
						if changed and buffer ~= "" and tonumber(buffer) then ECC_LM_Stations[a][4] = tonumber(buffer) buffer = nil end
						--
						imgui.TextUnformatted("Maximum Mass               ") imgui.SameLine()
						local changed,buffer = imgui.InputText("##Station "..a.." Maximum Mass", ECC_LM_Stations[a][3], 10) 
						if changed and buffer ~= "" and tonumber(buffer) then ECC_LM_Stations[a][3] = tonumber(buffer) buffer = nil end
						imgui.SameLine() if imgui.Button(ECC_LM_Stations[a][5].."##"..a,30,20) then ECC_LM_SwitchUnit("mass",a) end
						--
						imgui.TextUnformatted("Moment Arm from ref. point ") imgui.SameLine()
						local changed, buffer = imgui.InputText("##Station "..a.." Moment Arm", ECC_LM_Stations[a][6], 10) 
						if changed and buffer ~= "" and tonumber(buffer) then ECC_LM_Stations[a][6] = tonumber(buffer) buffer = nil end
						imgui.SameLine() if imgui.Button(ECC_LM_Stations[a][7].."##"..a,30,20) then ECC_LM_SwitchUnit("length",a) end
						--
						imgui.PopItemWidth()
						if imgui.Button("Remove Station ##"..a,150,20) then ECC_LM_DeleteStationNum = a end 
						imgui.SameLine() imgui.Dummy(95,20) imgui.SameLine() 
						if a < #ECC_LM_Stations then
							if imgui.Button("Insert Station Below ##"..a,150,20) then end
						else
							if imgui.Button("Add Station Below ##"..a,150,20) then ECC_LM_AddStation() end
						end                       
 						imgui.Separator()
					end
					imgui.PopID()
				-- End loop
				end
                -- Load screen CG stuff
                if ECC_LM_SubPage == 0 then
                    ECC_LM_RefreshCache()
                    imgui.Dummy((ECC_Preferences.AAA_Window_W-15),10)
                    imgui.PushItemWidth(185)
                    imgui.TextUnformatted("Empty weight    : "..string.format("%10.2f",ECC_UnitConverter(ECC_LM_Cache_m[1],"kg",ECC_LM_DispUnits[1]))) 
                    imgui.SameLine() if imgui.SmallButton(ECC_LM_DispUnits[1].."##1",30,20) then ECC_LM_SwitchUnit_Single(ECC_LM_DispUnits,1,"mass") ECC_CheckAutosave() end
                    imgui.TextUnformatted("Payload weight  : "..string.format("%10.2f",ECC_UnitConverter(ECC_LM_Cache_m[2],"kg",ECC_LM_DispUnits[1])))
                    imgui.SameLine() if imgui.SmallButton(ECC_LM_DispUnits[1].."##2",30,20) then ECC_LM_SwitchUnit_Single(ECC_LM_DispUnits,1,"mass") ECC_CheckAutosave() end
                    imgui.TextUnformatted("Zero fuel weight: "..string.format("%10.2f",ECC_UnitConverter(ECC_LM_Cache_m[3],"kg",ECC_LM_DispUnits[1])))
                    imgui.SameLine() if imgui.SmallButton(ECC_LM_DispUnits[1].."##3",30,20) then ECC_LM_SwitchUnit_Single(ECC_LM_DispUnits,1,"mass") ECC_CheckAutosave() end
                    imgui.TextUnformatted("Fuel weight     : "..string.format("%10.2f",ECC_UnitConverter(ECC_LM_Cache_m[4],"kg",ECC_LM_DispUnits[1])))
                    imgui.SameLine() if imgui.SmallButton(ECC_LM_DispUnits[1].."##4",30,20) then ECC_LM_SwitchUnit_Single(ECC_LM_DispUnits,1,"mass") ECC_CheckAutosave() end
                    if ECC_LM_Cache_m[5] < ECC_DR_MassMaximum[0] then  
                        imgui.PushStyleColor(imgui.constant.Col.Text, ECC_ImguiColors[7])
                        imgui.TextUnformatted("Total weight    : "..string.format("%10.2f",ECC_UnitConverter(ECC_LM_Cache_m[5],"kg",ECC_LM_DispUnits[1])))
                        imgui.PopStyleColor()
                    else
                        imgui.PushStyleColor(imgui.constant.Col.Text, ECC_ImguiColors[4])
                        imgui.TextUnformatted("Total weight    : "..string.format("%10.2f",ECC_UnitConverter(ECC_LM_Cache_m[5],"kg",ECC_LM_DispUnits[1])))
                        imgui.PopStyleColor()
                    end
                    imgui.SameLine() if imgui.SmallButton(ECC_LM_DispUnits[1].."##5",30,20) then ECC_LM_SwitchUnit_Single(ECC_LM_DispUnits,1,"mass") ECC_CheckAutosave() end
                    imgui.PopItemWidth()
                    imgui.Dummy((ECC_Preferences.AAA_Window_W-15),10)
                    imgui.TextUnformatted("CoG Empty       : "..string.format("%10.2f",ECC_UnitConverter(ECC_LM_Cache_CG[1],"ft",ECC_LM_DispUnits[2])))
                    imgui.SameLine() if imgui.SmallButton(ECC_LM_DispUnits[2].."##4",30,20) then ECC_LM_SwitchUnit_Single(ECC_LM_DispUnits,2,"length") ECC_CheckAutosave() end
                    imgui.Dummy((ECC_Preferences.AAA_Window_W-15),10)
                    imgui.Separator()
                end
                -- Station editor CG stuff
                if ECC_LM_SubPage == 1 then
                    imgui.Dummy((ECC_Preferences.AAA_Window_W-15),10)
                    imgui.PushItemWidth(185)
                    imgui.TextUnformatted("Forward CG Limit           ") imgui.SameLine()
                    local changed, buffer = imgui.InputText("##CG Limit Fwd", ECC_LM_CG_Limits[1], 10) 
					if changed and buffer ~= "" and tonumber(buffer) then ECC_LM_CG_Limits[1] = tonumber(buffer) buffer = nil end
					imgui.SameLine() if imgui.Button(ECC_LM_CG_Limits[2].."##1",30,20) then ECC_LM_SwitchUnit_Single(ECC_LM_CG_Limits,2,"length") end
                    imgui.TextUnformatted("Aft CG Limit               ") imgui.SameLine()
                    local changed, buffer = imgui.InputText("##CG Limit Aft", ECC_LM_CG_Limits[3], 10) 
					if changed and buffer ~= "" and tonumber(buffer) then ECC_LM_CG_Limits[3] = tonumber(buffer) buffer = nil end
					imgui.SameLine() if imgui.Button(ECC_LM_CG_Limits[4].."##2",30,20) then ECC_LM_SwitchUnit_Single(ECC_LM_CG_Limits,4,"length") end
                    imgui.Dummy((ECC_Preferences.AAA_Window_W-15),10)
                    imgui.TextUnformatted("Empty CG Offset from PM    ") imgui.SameLine()
                    local changed, buffer = imgui.InputText("##Ref. point offset", ECC_LM_EmptyCGOffset[1], 10) 
					if changed and buffer ~= "" and tonumber(buffer) then ECC_LM_EmptyCGOffset[1] = tonumber(buffer) buffer = nil end
					imgui.SameLine() if imgui.Button(ECC_LM_EmptyCGOffset[2].."##3",30,20) then ECC_LM_SwitchUnit_Single(ECC_LM_EmptyCGOffset,2,"length") end
                    imgui.PopItemWidth()
                    imgui.Dummy((ECC_Preferences.AAA_Window_W-15),10)
                    imgui.Separator()
                end
				--Post-Loop
				if ECC_LM_DeleteStationNum ~= 0 then ECC_LM_RemoveStation() end -- Station delete function call
			end
            
            
        end
        --[[ Subpage 0 buttons ]]
        if ECC_LM_SubPage == 0 then
			if #ECC_LM_Stations > 0 then 
					imgui.Dummy((ECC_Preferences.AAA_Window_W-15),10)
					if imgui.Button("Load",(ECC_Preferences.AAA_Window_W-15),20) then ECC_CheckAutosave() end 
					imgui.Dummy((ECC_Preferences.AAA_Window_W-15),10)
					imgui.Separator()
			end
			imgui.Dummy((ECC_Preferences.AAA_Window_W-15),10)
            if imgui.Button("Edit",(ECC_Preferences.AAA_Window_W-15),20) then ECC_LM_SubPage = 1 if #ECC_LM_Stations == 0 then ECC_LM_AddStation() end ECC_CheckAutosave() end
        end
        --[[ NOT subpage 0 buttons ]]
        if ECC_LM_SubPage ~= 0 then
            imgui.Dummy((ECC_Preferences.AAA_Window_W-15),10)
            if imgui.Button("Finish & Save",(ECC_Preferences.AAA_Window_W-15),20) then ECC_LM_SubPage = 0 ECC_WriteAircraftConfig() end
        end
    -- End of page
    end
end


--[[
function ECC_LM_GetFuel()
	for n=1,ECC_DR_NumFuelTanks[0] do
		ECC_LM_VirtualMassFuel[n] = ECC_UnitConverter(ECC_DR_MassFuel[n-1],"kg","lbs")
		--print("Tank "..n.." fuel mass: "..ECC_LM_VirtualMassFuel[n].." lbs.")
		if n == ECC_DR_NumFuelTanks[0] then ECC_LM_FuelMeasured = true end
	end
	ECC_LM_CalcCG()
end

function ECC_LM_CalcCG()
	-- Calculate virtual payload (in lbs)
	ECC_LM_VirtualMasses[1] = ECC_Preferences.LM_StationMass_0 + ECC_Preferences.LM_StationMass_1 + ECC_Preferences.LM_StationMass_2 + ECC_Preferences.LM_StationMass_3 + ECC_Preferences.LM_StationMass_4 + ECC_Preferences.LM_StationMass_5 + ECC_Preferences.LM_StationMass_6 + ECC_Preferences.LM_StationMass_7 + ECC_Preferences.LM_StationMass_8 + ECC_Preferences.LM_StationMass_9
	-- Calculate virtual zero fuel weight (in lbs)
	ECC_LM_VirtualMasses[2] = ECC_UnitConverter(ECC_DR_MassEmpty[0],"kg","lbs") + ECC_LM_VirtualMasses[1]
	-- Calculate virtual zero fuel moment (in lbs*inches) by adding all Station moments to the actual empty weight moment
	ECC_LM_VirtualMoments[1] = (ECC_UnitConverter(ECC_DR_MassEmpty[0],"kg","lbs") * ECC_Preferences.LM_CGEmpty )
	+ (ECC_Preferences.LM_StationMass_0 * ECC_Preferences.LM_StationMomentArm_0) 
	+ (ECC_Preferences.LM_StationMass_1 * ECC_Preferences.LM_StationMomentArm_1)
	+ (ECC_Preferences.LM_StationMass_2 * ECC_Preferences.LM_StationMomentArm_2)
	+ (ECC_Preferences.LM_StationMass_3 * ECC_Preferences.LM_StationMomentArm_3)
	+ (ECC_Preferences.LM_StationMass_4 * ECC_Preferences.LM_StationMomentArm_4)
	+ (ECC_Preferences.LM_StationMass_5 * ECC_Preferences.LM_StationMomentArm_5)
	+ (ECC_Preferences.LM_StationMass_6 * ECC_Preferences.LM_StationMomentArm_6)
	+ (ECC_Preferences.LM_StationMass_7 * ECC_Preferences.LM_StationMomentArm_7)
	+ (ECC_Preferences.LM_StationMass_8 * ECC_Preferences.LM_StationMomentArm_8)
	+ (ECC_Preferences.LM_StationMass_9 * ECC_Preferences.LM_StationMomentArm_9)
	-- Calculate virtual zero fuel CG (in inches)
	ECC_LM_VirtualCG[1] = ECC_LM_VirtualMoments[1] / ECC_LM_VirtualMasses[2]
	-- Calculate virtual total moment (in lbs*inches) by adding fuel moments of the variables from the UI to the virtual zero fuel moment (fuel tank moment arm converted from m to in and adjusted for datum offset)
	ECC_LM_VirtualMoments[2] = ECC_LM_VirtualMoments[1]
	+ (ECC_LM_VirtualMassFuel[1] * ((ECC_DR_MomentArmFuel[0]/ECC_Conv_inm) - ECC_Preferences.LM_DatumOffset))
	+ (ECC_LM_VirtualMassFuel[2] * ((ECC_DR_MomentArmFuel[1]/ECC_Conv_inm) - ECC_Preferences.LM_DatumOffset))
	+ (ECC_LM_VirtualMassFuel[3] * ((ECC_DR_MomentArmFuel[2]/ECC_Conv_inm) - ECC_Preferences.LM_DatumOffset))
	+ (ECC_LM_VirtualMassFuel[4] * ((ECC_DR_MomentArmFuel[3]/ECC_Conv_inm) - ECC_Preferences.LM_DatumOffset))
	+ (ECC_LM_VirtualMassFuel[5] * ((ECC_DR_MomentArmFuel[4]/ECC_Conv_inm) - ECC_Preferences.LM_DatumOffset))
	+ (ECC_LM_VirtualMassFuel[6] * ((ECC_DR_MomentArmFuel[5]/ECC_Conv_inm) - ECC_Preferences.LM_DatumOffset))
	+ (ECC_LM_VirtualMassFuel[7] * ((ECC_DR_MomentArmFuel[6]/ECC_Conv_inm) - ECC_Preferences.LM_DatumOffset))
	+ (ECC_LM_VirtualMassFuel[8] * ((ECC_DR_MomentArmFuel[7]/ECC_Conv_inm) - ECC_Preferences.LM_DatumOffset))
	+ (ECC_LM_VirtualMassFuel[9] * ((ECC_DR_MomentArmFuel[8]/ECC_Conv_inm) - ECC_Preferences.LM_DatumOffset))
	-- Sum up fuel in all tanks to calculate mass to be loaded into each fuel tank (in lbs)
	ECC_LM_VirtualMasses[3] = 0
	for n=1,9 do
		ECC_LM_VirtualMasses[3] = ECC_LM_VirtualMasses[3] + ECC_LM_VirtualMassFuel[n]
	end
	-- Calculate temporary total aircraft mass
	ECC_LM_VirtualMasses[4] = ECC_LM_VirtualMasses[2] + ECC_LM_VirtualMasses[3]
	-- Calculate total CG by dividing total moment by aircraft mass (converted from lbs to kg)
	ECC_LM_VirtualCG[2] = ECC_LM_VirtualMoments[2] / ECC_LM_VirtualMasses[4]
-- End virtual center of gravity calculation function
end

function ECC_LM_CommitLoading()
	---- Payload
	ECC_DR_MassPayload[0] = ECC_UnitConverter(ECC_LM_VirtualMasses[1],"lbs","kg")
	-- Fuel
	if ECC_LM_FuelMeasured then
		for n=1,ECC_DR_NumFuelTanks[0] do
			ECC_DR_MassFuel[n-1] = ECC_UnitConverter(ECC_LM_VirtualMassFuel[n],"lbs","kg")
			--print("New tank "..n.." fuel mass: "..ECC_LM_VirtualMassFuel[n].." lbs.")
		end
		ECC_LM_FuelMeasured = false
		ECC_LM_GetFuel()
	end
	-- Center of gravity offset from default
	ECC_DR_CG[0] = (ECC_LM_VirtualCG[2] + ECC_Preferences.LM_DatumOffset) * ECC_Conv_inm
end

--do_often("ECC_LM_CalcCG()")

]]
