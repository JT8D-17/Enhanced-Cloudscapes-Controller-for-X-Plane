--[[

AircraftHelper component (load manager function library), required by AircraftHelper.lua

]]
--[[

VARIABLES (local to this module)

]]
local ACH_LM_DeleteStationNum = 0                       -- Selected payload station to delete
local ACH_LM_CG_Limits = {0,"in",0,"in"}                -- Center of gravity limits
local ACH_LM_EmptyCGOffset = {0,"in"}                   -- Empty center of gravity offset from the value specified in PlaneMaker
local ACH_LM_SubPage = 0                                -- Current subpage of the wload manager window
local ACH_LM_Cache_m = {0,0,0,0,0}                      -- Property cache for masses {empty,payload,ZFW,fuel,total}
local ACH_LM_DispUnits = {"lbs","ft"}                   -- Display units
local ACH_LM_Cache_CG = {0}                             -- Property cache for CG {empty}
--[[

DATAREFS (local to this module)

]]
local ACH_DR_MassEmpty  = dataref_table("sim/aircraft/weight/acf_m_empty")				-- Empty aircraft weight (kilograms)
local ACH_DR_MassFuel  = dataref_table("sim/flightmodel/weight/m_fuel") 				-- Fuel mass in tank (kilograms; table!)
local ACH_DR_MassMaximum  = dataref_table("sim/aircraft/weight/acf_m_max")				-- Maximum aircraft weight (kilograms)
local ACH_DR_MassFuelTotal  = dataref_table("sim/aircraft/weight/acf_m_fuel_tot") 		-- Maximum total fuel mass (kilograms)
local ACH_DR_NumFuelTanks = dataref_table("sim/aircraft/overflow/acf_num_tanks") 		-- Number of fuel tanks
local ACH_DR_CGRef  = dataref_table("sim/aircraft/weight/acf_cgZ_original") 		    -- Reference CG from the visual origin (feet)
--[[

FUNCTIONS

]]
--[[ Refresh property cache ]]
local function ACH_LM_RefreshCache()
    --[[ Masses ]]
    -- Reset cache values
    for a=1,#ACH_LM_Cache_m do
        ACH_LM_Cache_m[a] = 0
    end
    -- Update empty mass
    ACH_LM_Cache_m[1] = ACH_DR_MassEmpty[0]
    -- Loop through payload stations
    for b=1,#ACH_LM_Stations do
        --Check station unit and if lbs convert to kg
        if ACH_LM_Stations[b][5] == "lbs" then
            --print("Station "..b.." mass is "..ACH_LM_Stations[b][2].." lbs ("..ACH_UnitConverter(ACH_LM_Stations[b][2],"lbs","kg").." kg)")
           ACH_LM_Cache_m[2] = ACH_LM_Cache_m[2] + ACH_UnitConverter(ACH_LM_Stations[b][2],"lbs","kg") -- Add mass from station to total mass
        else
           --print("Station "..b.." mass is "..ACH_LM_Stations[b][2].." kg")
           ACH_LM_Cache_m[2] = ACH_LM_Cache_m[2] + ACH_LM_Stations[b][2] -- Add mass from station to total mass
        end
    end
    ACH_LM_Cache_m[3] = ACH_LM_Cache_m[1] + ACH_LM_Cache_m[2] -- Calculate ZFW
    -- Loop through number of fuel tanks
    for c=1,ACH_DR_NumFuelTanks[0] do
        ACH_LM_Cache_m[4] = ACH_LM_Cache_m[4] + ACH_DR_MassFuel[(c-1)]
    end
    ACH_LM_Cache_m[5] = ACH_LM_Cache_m[3] + ACH_LM_Cache_m[4]
    --[[ Center of Gravity ]]
    -- Reset cache values
    for d=1,#ACH_LM_Cache_CG do
        ACH_LM_Cache_CG[d] = 0
    end
    -- Apply offset to predefined CoG
    if ACH_LM_EmptyCGOffset[2] == "in" then
        ACH_LM_Cache_CG[1] = ACH_DR_CGRef[0] + ACH_UnitConverter(ACH_LM_EmptyCGOffset[1],"in","ft")
    elseif ACH_LM_EmptyCGOffset[2] == "cm" then
        ACH_LM_Cache_CG[1] = ACH_DR_CGRef[0] + ACH_UnitConverter(ACH_LM_EmptyCGOffset[1],"cm","ft")
     elseif ACH_LM_EmptyCGOffset[2] == "m" then
        ACH_LM_Cache_CG[1] = ACH_DR_CGRef[0] + ACH_UnitConverter(ACH_LM_EmptyCGOffset[1],"m","ft")
    end
end
--[[ Add payload station ]]
local function ACH_LM_AddStation()
    ACH_LM_Stations[#ACH_LM_Stations+1] = {"[No name]",0,10000,0,"lbs",0,"in"} -- Name, Mass, Maximum mass, Mass increment, Mass unit, Lon moment arm, Lon moment arm unit
    ACH_LM_Stations[#ACH_LM_Stations][1] = "[No name "..#ACH_LM_Stations.."]"
    ACH_WriteAircraftConfig()
end

--[[ Insert payload station ]]
local function ACH_LM_InsertStation()

    
    ACH_WriteAircraftConfig()
end

--[[ Remove payload station ]]
local function ACH_LM_RemoveStation()
    table.remove(ACH_LM_Stations,ACH_LM_DeleteStationNum)
    ACH_LM_DeleteStationNum = 0
    ACH_WriteAircraftConfig()
end

local function ACH_LM_SwitchUnit(prop,station)
    if prop == "mass" then
        if ACH_LM_Stations[station][5] == "lbs" then ACH_LM_Stations[station][5] = "kg" 
        elseif ACH_LM_Stations[station][5] == "kg" then ACH_LM_Stations[station][5] = "lbs" end
    end
    if prop == "length" then
        if ACH_LM_Stations[station][7] == "in" then ACH_LM_Stations[station][7] = "ft" 
        elseif ACH_LM_Stations[station][7] == "ft" then ACH_LM_Stations[station][7] = "m" 
        elseif ACH_LM_Stations[station][7] == "m" then ACH_LM_Stations[station][7] = "cm" 
        elseif ACH_LM_Stations[station][7] == "cm" then ACH_LM_Stations[station][7] = "in" 
        end
    end
end

local function ACH_LM_SwitchUnit_Single(inputtable,index,prop)
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
function ACH_WriteAircraftConfig()
    ACH_Log_Write("FILE INIT WRITE: "..ACH_AircraftSaveFile)
    local file = io.open(ACH_AircraftSaveFile, "w")
    file:write("Aircraft Helper configuration file created/updated on ",os.date("%x, %H:%M:%S"),"\n")
    file:write("SubPage="..ACH_LM_SubPage.."\n")
    file:write("DispUnits,"..ACH_LM_DispUnits[1]..","..ACH_LM_DispUnits[2].."\n")
    --[[ Write CG Limits ]]
    file:write("CG_Limits,"..ACH_LM_CG_Limits[1]..","..ACH_LM_CG_Limits[2]..","..ACH_LM_CG_Limits[3]..","..ACH_LM_CG_Limits[4].."\n")
    --[[ Write Empty CG offset ]]
    file:write("CG_Offset,"..ACH_LM_EmptyCGOffset[1]..","..ACH_LM_EmptyCGOffset[2].."\n")
    --[[ Write Payload Stations ]]
    if #ACH_LM_Stations > 0 then
        for b=1,#ACH_LM_Stations do
            file:write("PAYLOAD_STATION,")
            for c=1,#ACH_LM_Stations[b] do
                if c ~= #ACH_LM_Stations[b] then file:write(tostring(ACH_LM_Stations[b][c]),",") else file:write(tostring(ACH_LM_Stations[b][c]),"\n") end
            end
        end
    end
    if file:seek("end") > 0 then ACH_Notification("FILE WRITE SUCCESS: "..ACH_AircraftSaveFile,"Success","log") else ACH_Notification("FILE WRITE ERROR: "..ACH_AircraftSaveFile,"Error","log") end
	file:close()
end


function ACH_ReadAircraftConfig()
   local file = io.open(ACH_AircraftSaveFile, "r")
    if file then
        ACH_Log_Write("FILE INIT READ: "..ACH_AircraftSaveFile)
        local i = 0
        for line in file:lines() do
            --[[ Read subpage ]]
            if string.match(line,"^SubPage=") then
                ACH_SplitLine(line,"([^=]+)")
                ACH_LM_SubPage = tonumber(ACH_SplitResult[2])
            end
            --[[ Read display units ]]
            if string.match(line,"^DispUnits,") then
                ACH_SplitLine(line,"([^,]+)")
                ACH_LM_DispUnits[1] = tostring(ACH_SplitResult[2])
                ACH_LM_DispUnits[2] = tostring(ACH_SplitResult[3])
            end
            --[[ Read CG limits ]]
            if string.match(line,"^CG_Limits,") then
                ACH_SplitLine(line,"([^,]+)")
                ACH_LM_CG_Limits[1] = tonumber(ACH_SplitResult[2])
                ACH_LM_CG_Limits[2] = tostring(ACH_SplitResult[3])
                ACH_LM_CG_Limits[3] = tonumber(ACH_SplitResult[4])
                ACH_LM_CG_Limits[4] = tostring(ACH_SplitResult[5])
            end
            --[[ Read CoG offset ]]
            if string.match(line,"^CG_Offset,") then
                ACH_SplitLine(line,"([^,]+)")
                ACH_LM_EmptyCGOffset[1] = tonumber(ACH_SplitResult[2])
                ACH_LM_EmptyCGOffset[2] = tostring(ACH_SplitResult[3])
            end
            --[[ Read payload stations ]]
            if string.match(line,"^PAYLOAD_STATION,") then
                ACH_LM_Stations[#ACH_LM_Stations+1] = { }
                ACH_SplitLine(line,"([^,]+)")
                ACH_LM_Stations[#ACH_LM_Stations][1] = tostring(ACH_SplitResult[2]) -- Title
                ACH_LM_Stations[#ACH_LM_Stations][2] = tonumber(ACH_SplitResult[3])	-- Mass
                ACH_LM_Stations[#ACH_LM_Stations][3] = tonumber(ACH_SplitResult[4])	-- Max Mass
                ACH_LM_Stations[#ACH_LM_Stations][4] = tonumber(ACH_SplitResult[5])	-- Mass increment
                ACH_LM_Stations[#ACH_LM_Stations][5] = tostring(ACH_SplitResult[6])	-- Mass unit
                ACH_LM_Stations[#ACH_LM_Stations][6] = tonumber(ACH_SplitResult[7])	-- Moment arm
                ACH_LM_Stations[#ACH_LM_Stations][7] = tostring(ACH_SplitResult[8])	-- Moment arm unit
				--print(table.concat(ACH_LM_Stations[#ACH_LM_Stations], ",", 1,#ACH_LM_Stations[#ACH_LM_Stations]))
				--for h=1,#ACH_LM_Stations[#ACH_LM_Stations] do
					--print(type(ACH_LM_Stations[#ACH_LM_Stations][h]))
				--end
            end
            i = i+1
        end
        file:close()
		if i ~= nil and i > 0 then ACH_Notification("FILE READ SUCCESS: "..ACH_AircraftSaveFile,"Success","log") else ACH_Notification("FILE READ ERROR: "..ACH_AircraftSaveFile,"Error","log") end
    else
        ACH_Notification("FILE NOT FOUND: "..ACH_AircraftSaveFile,"Error","log")
		ACH_Check_AutoLoad = false
	end
end
--[[

IMGUI WINDOW ELEMENT

]]
function ACH_Win_LoadManager()
	--[[ Obtain and store window information ]]
	ACH_GetWindowInfo()
    --[[ Button ]]
    if ACH_Preferences.Window_Page == 0 then
        if imgui.Button("Load Manager",(ACH_Preferences.AAA_Window_W-15),20) then ACH_Preferences.Window_Page = 2 ACH_CheckAutosave() end
    end
    -- [[ Page ]]
    if ACH_Preferences.Window_Page == 2 then
        --[[ "Back" button ]]
        if imgui.Button("Main Menu ##Back2",(ACH_Preferences.AAA_Window_W-15),20) then ACH_LM_SubPage = 0 ACH_Preferences.Window_Page = 0 ACH_CheckAutosave() end
        imgui.Dummy((ACH_Preferences.AAA_Window_W-15),10)
        imgui.Separator()
        --[[ Subpage 0 or 1 ]]
        if ACH_LM_SubPage == 0 or ACH_LM_SubPage == 1 then
			if #ACH_LM_Stations == 0 then
				imgui.PushStyleColor(imgui.constant.Col.Text, ACH_ImguiColors[7]) imgui.TextUnformatted("No payload stations found. Entering edit mode will add a station.") imgui.PopStyleColor()
			else
				--[[ Station List ]]
				for a=1,#ACH_LM_Stations do
					imgui.PushID(a)
					-- Loop through stations
					if ACH_LM_SubPage == 0 then
						imgui.TextUnformatted("Station Title : "..ACH_LM_Stations[a][1])
						--imgui.TextUnformatted("Assigned Mass : "..ACH_LM_Stations[a][2].." "..ACH_LM_Stations[a][5])
						if ACH_LM_Stations[a][4] == 0 then -- Mass mode
							-- Mass slider
							imgui.PushItemWidth(ACH_Preferences.AAA_Window_W - 125)
							local changed,buffer = imgui.SliderFloat("##Station "..a.." Mass Slider 1",ACH_LM_Stations[a][2], 0, ACH_LM_Stations[a][3], "%.1f") imgui.SameLine()
							if changed then ACH_LM_Stations[a][2] = buffer buffer = nil end
							imgui.PopItemWidth()
							-- Mass type-in box
							imgui.PushItemWidth(55)
							local changed,buffer = imgui.InputText("##Station "..a.." Mass 1", ACH_RoundToInt(ACH_LM_Stations[a][2],1), 10) imgui.SameLine() imgui.TextUnformatted(ACH_LM_Stations[a][5])
							if changed and buffer ~= "" and tonumber(buffer) then 
								if ACH_LM_Stations[a][3] >= tonumber(buffer) then ACH_LM_Stations[a][2] = tonumber(buffer) else ACH_LM_Stations[a][2] = ACH_LM_Stations[a][3] end 
							buffer = nil end
							imgui.PopItemWidth()
						else -- Increment/pax mode
							local TempMass = ACH_RoundToInt(ACH_LM_Stations[a][2]/ACH_LM_Stations[a][4],0)
							local TempLim = ACH_RoundToInt(ACH_LM_Stations[a][3]/ACH_LM_Stations[a][4],0)
							-- Mass slider
							imgui.PushItemWidth(ACH_Preferences.AAA_Window_W - 125)
							local changed,buffer = imgui.SliderInt("##Station "..a.." Mass Slider 2",TempMass, 0,TempLim, "%.0d") imgui.SameLine()
							if changed then ACH_LM_Stations[a][2] = (buffer * ACH_LM_Stations[a][4]) buffer = nil end
							imgui.PopItemWidth()
							-- Mass type-in box
							imgui.PushItemWidth(55)
							local changed,buffer = imgui.InputText("##Station "..a.." Mass 2", TempMass, 10) imgui.SameLine() imgui.TextUnformatted("pax")
							if changed and buffer ~= "" and tonumber(buffer) then 
								if TempLim >= tonumber(buffer) then ACH_LM_Stations[a][2] = (buffer * ACH_LM_Stations[a][4]) else ACH_LM_Stations[a][2] = (TempLim * ACH_LM_Stations[a][4]) end 
							buffer = nil end
							imgui.PopItemWidth()
						end
						-- Mass moment display
						imgui.TextUnformatted("Moment        : "..ACH_RoundToInt(ACH_LM_Stations[a][2] * ACH_LM_Stations[a][6],1).." "..ACH_LM_Stations[a][5].."-"..ACH_LM_Stations[a][7])
						imgui.Separator()
					elseif ACH_LM_SubPage == 1 then
						imgui.PushItemWidth(185)
						--
						imgui.TextUnformatted("Title (25 chars max)       ") imgui.SameLine()
						local changed,buffer = imgui.InputText("##Station "..a.." Title",ACH_LM_Stations[a][1], 26)
						if changed and buffer ~= "" and tostring(buffer) then ACH_LM_Stations[a][1] = tostring(buffer) buffer = nil end
						--
						imgui.TextUnformatted("Mass divider (for pax/crew)") imgui.SameLine()
						local changed,buffer = imgui.InputText("##Station "..a.." IsPax", ACH_LM_Stations[a][4], 10) 
						if changed and buffer ~= "" and tonumber(buffer) then ACH_LM_Stations[a][4] = tonumber(buffer) buffer = nil end
						--
						imgui.TextUnformatted("Maximum Mass               ") imgui.SameLine()
						local changed,buffer = imgui.InputText("##Station "..a.." Maximum Mass", ACH_LM_Stations[a][3], 10) 
						if changed and buffer ~= "" and tonumber(buffer) then ACH_LM_Stations[a][3] = tonumber(buffer) buffer = nil end
						imgui.SameLine() if imgui.Button(ACH_LM_Stations[a][5].."##"..a,30,20) then ACH_LM_SwitchUnit("mass",a) end
						--
						imgui.TextUnformatted("Moment Arm from ref. point ") imgui.SameLine()
						local changed, buffer = imgui.InputText("##Station "..a.." Moment Arm", ACH_LM_Stations[a][6], 10) 
						if changed and buffer ~= "" and tonumber(buffer) then ACH_LM_Stations[a][6] = tonumber(buffer) buffer = nil end
						imgui.SameLine() if imgui.Button(ACH_LM_Stations[a][7].."##"..a,30,20) then ACH_LM_SwitchUnit("length",a) end
						--
						imgui.PopItemWidth()
						if imgui.Button("Remove Station ##"..a,150,20) then ACH_LM_DeleteStationNum = a end 
						imgui.SameLine() imgui.Dummy(95,20) imgui.SameLine() 
						if a < #ACH_LM_Stations then
							if imgui.Button("Insert Station Below ##"..a,150,20) then end
						else
							if imgui.Button("Add Station Below ##"..a,150,20) then ACH_LM_AddStation() end
						end                       
 						imgui.Separator()
					end
					imgui.PopID()
				-- End loop
				end
                -- Load screen CG stuff
                if ACH_LM_SubPage == 0 then
                    ACH_LM_RefreshCache()
                    imgui.Dummy((ACH_Preferences.AAA_Window_W-15),10)
                    imgui.PushItemWidth(185)
                    imgui.TextUnformatted("Empty weight    : "..string.format("%10.2f",ACH_UnitConverter(ACH_LM_Cache_m[1],"kg",ACH_LM_DispUnits[1]))) 
                    imgui.SameLine() if imgui.SmallButton(ACH_LM_DispUnits[1].."##1",30,20) then ACH_LM_SwitchUnit_Single(ACH_LM_DispUnits,1,"mass") ACH_CheckAutosave() end
                    imgui.TextUnformatted("Payload weight  : "..string.format("%10.2f",ACH_UnitConverter(ACH_LM_Cache_m[2],"kg",ACH_LM_DispUnits[1])))
                    imgui.SameLine() if imgui.SmallButton(ACH_LM_DispUnits[1].."##2",30,20) then ACH_LM_SwitchUnit_Single(ACH_LM_DispUnits,1,"mass") ACH_CheckAutosave() end
                    imgui.TextUnformatted("Zero fuel weight: "..string.format("%10.2f",ACH_UnitConverter(ACH_LM_Cache_m[3],"kg",ACH_LM_DispUnits[1])))
                    imgui.SameLine() if imgui.SmallButton(ACH_LM_DispUnits[1].."##3",30,20) then ACH_LM_SwitchUnit_Single(ACH_LM_DispUnits,1,"mass") ACH_CheckAutosave() end
                    imgui.TextUnformatted("Fuel weight     : "..string.format("%10.2f",ACH_UnitConverter(ACH_LM_Cache_m[4],"kg",ACH_LM_DispUnits[1])))
                    imgui.SameLine() if imgui.SmallButton(ACH_LM_DispUnits[1].."##4",30,20) then ACH_LM_SwitchUnit_Single(ACH_LM_DispUnits,1,"mass") ACH_CheckAutosave() end
                    if ACH_LM_Cache_m[5] < ACH_DR_MassMaximum[0] then  
                        imgui.PushStyleColor(imgui.constant.Col.Text, ACH_ImguiColors[7])
                        imgui.TextUnformatted("Total weight    : "..string.format("%10.2f",ACH_UnitConverter(ACH_LM_Cache_m[5],"kg",ACH_LM_DispUnits[1])))
                        imgui.PopStyleColor()
                    else
                        imgui.PushStyleColor(imgui.constant.Col.Text, ACH_ImguiColors[4])
                        imgui.TextUnformatted("Total weight    : "..string.format("%10.2f",ACH_UnitConverter(ACH_LM_Cache_m[5],"kg",ACH_LM_DispUnits[1])))
                        imgui.PopStyleColor()
                    end
                    imgui.SameLine() if imgui.SmallButton(ACH_LM_DispUnits[1].."##5",30,20) then ACH_LM_SwitchUnit_Single(ACH_LM_DispUnits,1,"mass") ACH_CheckAutosave() end
                    imgui.PopItemWidth()
                    imgui.Dummy((ACH_Preferences.AAA_Window_W-15),10)
                    imgui.TextUnformatted("CoG Empty       : "..string.format("%10.2f",ACH_UnitConverter(ACH_LM_Cache_CG[1],"ft",ACH_LM_DispUnits[2])))
                    imgui.SameLine() if imgui.SmallButton(ACH_LM_DispUnits[2].."##4",30,20) then ACH_LM_SwitchUnit_Single(ACH_LM_DispUnits,2,"length") ACH_CheckAutosave() end
                    imgui.Dummy((ACH_Preferences.AAA_Window_W-15),10)
                    imgui.Separator()
                end
                -- Station editor CG stuff
                if ACH_LM_SubPage == 1 then
                    imgui.Dummy((ACH_Preferences.AAA_Window_W-15),10)
                    imgui.PushItemWidth(185)
                    imgui.TextUnformatted("Forward CG Limit           ") imgui.SameLine()
                    local changed, buffer = imgui.InputText("##CG Limit Fwd", ACH_LM_CG_Limits[1], 10) 
					if changed and buffer ~= "" and tonumber(buffer) then ACH_LM_CG_Limits[1] = tonumber(buffer) buffer = nil end
					imgui.SameLine() if imgui.Button(ACH_LM_CG_Limits[2].."##1",30,20) then ACH_LM_SwitchUnit_Single(ACH_LM_CG_Limits,2,"length") end
                    imgui.TextUnformatted("Aft CG Limit               ") imgui.SameLine()
                    local changed, buffer = imgui.InputText("##CG Limit Aft", ACH_LM_CG_Limits[3], 10) 
					if changed and buffer ~= "" and tonumber(buffer) then ACH_LM_CG_Limits[3] = tonumber(buffer) buffer = nil end
					imgui.SameLine() if imgui.Button(ACH_LM_CG_Limits[4].."##2",30,20) then ACH_LM_SwitchUnit_Single(ACH_LM_CG_Limits,4,"length") end
                    imgui.Dummy((ACH_Preferences.AAA_Window_W-15),10)
                    imgui.TextUnformatted("Empty CG Offset from PM    ") imgui.SameLine()
                    local changed, buffer = imgui.InputText("##Ref. point offset", ACH_LM_EmptyCGOffset[1], 10) 
					if changed and buffer ~= "" and tonumber(buffer) then ACH_LM_EmptyCGOffset[1] = tonumber(buffer) buffer = nil end
					imgui.SameLine() if imgui.Button(ACH_LM_EmptyCGOffset[2].."##3",30,20) then ACH_LM_SwitchUnit_Single(ACH_LM_EmptyCGOffset,2,"length") end
                    imgui.PopItemWidth()
                    imgui.Dummy((ACH_Preferences.AAA_Window_W-15),10)
                    imgui.Separator()
                end
				--Post-Loop
				if ACH_LM_DeleteStationNum ~= 0 then ACH_LM_RemoveStation() end -- Station delete function call
			end
            
            
        end
        --[[ Subpage 0 buttons ]]
        if ACH_LM_SubPage == 0 then
			if #ACH_LM_Stations > 0 then 
					imgui.Dummy((ACH_Preferences.AAA_Window_W-15),10)
					if imgui.Button("Load",(ACH_Preferences.AAA_Window_W-15),20) then ACH_CheckAutosave() end 
					imgui.Dummy((ACH_Preferences.AAA_Window_W-15),10)
					imgui.Separator()
			end
			imgui.Dummy((ACH_Preferences.AAA_Window_W-15),10)
            if imgui.Button("Edit",(ACH_Preferences.AAA_Window_W-15),20) then ACH_LM_SubPage = 1 if #ACH_LM_Stations == 0 then ACH_LM_AddStation() end ACH_CheckAutosave() end
        end
        --[[ NOT subpage 0 buttons ]]
        if ACH_LM_SubPage ~= 0 then
            imgui.Dummy((ACH_Preferences.AAA_Window_W-15),10)
            if imgui.Button("Finish & Save",(ACH_Preferences.AAA_Window_W-15),20) then ACH_LM_SubPage = 0 ACH_WriteAircraftConfig() end
        end
    -- End of page
    end
end


--[[
function ACH_LM_GetFuel()
	for n=1,ACH_DR_NumFuelTanks[0] do
		ACH_LM_VirtualMassFuel[n] = ACH_UnitConverter(ACH_DR_MassFuel[n-1],"kg","lbs")
		--print("Tank "..n.." fuel mass: "..ACH_LM_VirtualMassFuel[n].." lbs.")
		if n == ACH_DR_NumFuelTanks[0] then ACH_LM_FuelMeasured = true end
	end
	ACH_LM_CalcCG()
end

function ACH_LM_CalcCG()
	-- Calculate virtual payload (in lbs)
	ACH_LM_VirtualMasses[1] = ACH_Preferences.LM_StationMass_0 + ACH_Preferences.LM_StationMass_1 + ACH_Preferences.LM_StationMass_2 + ACH_Preferences.LM_StationMass_3 + ACH_Preferences.LM_StationMass_4 + ACH_Preferences.LM_StationMass_5 + ACH_Preferences.LM_StationMass_6 + ACH_Preferences.LM_StationMass_7 + ACH_Preferences.LM_StationMass_8 + ACH_Preferences.LM_StationMass_9
	-- Calculate virtual zero fuel weight (in lbs)
	ACH_LM_VirtualMasses[2] = ACH_UnitConverter(ACH_DR_MassEmpty[0],"kg","lbs") + ACH_LM_VirtualMasses[1]
	-- Calculate virtual zero fuel moment (in lbs*inches) by adding all Station moments to the actual empty weight moment
	ACH_LM_VirtualMoments[1] = (ACH_UnitConverter(ACH_DR_MassEmpty[0],"kg","lbs") * ACH_Preferences.LM_CGEmpty )
	+ (ACH_Preferences.LM_StationMass_0 * ACH_Preferences.LM_StationMomentArm_0) 
	+ (ACH_Preferences.LM_StationMass_1 * ACH_Preferences.LM_StationMomentArm_1)
	+ (ACH_Preferences.LM_StationMass_2 * ACH_Preferences.LM_StationMomentArm_2)
	+ (ACH_Preferences.LM_StationMass_3 * ACH_Preferences.LM_StationMomentArm_3)
	+ (ACH_Preferences.LM_StationMass_4 * ACH_Preferences.LM_StationMomentArm_4)
	+ (ACH_Preferences.LM_StationMass_5 * ACH_Preferences.LM_StationMomentArm_5)
	+ (ACH_Preferences.LM_StationMass_6 * ACH_Preferences.LM_StationMomentArm_6)
	+ (ACH_Preferences.LM_StationMass_7 * ACH_Preferences.LM_StationMomentArm_7)
	+ (ACH_Preferences.LM_StationMass_8 * ACH_Preferences.LM_StationMomentArm_8)
	+ (ACH_Preferences.LM_StationMass_9 * ACH_Preferences.LM_StationMomentArm_9)
	-- Calculate virtual zero fuel CG (in inches)
	ACH_LM_VirtualCG[1] = ACH_LM_VirtualMoments[1] / ACH_LM_VirtualMasses[2]
	-- Calculate virtual total moment (in lbs*inches) by adding fuel moments of the variables from the UI to the virtual zero fuel moment (fuel tank moment arm converted from m to in and adjusted for datum offset)
	ACH_LM_VirtualMoments[2] = ACH_LM_VirtualMoments[1]
	+ (ACH_LM_VirtualMassFuel[1] * ((ACH_DR_MomentArmFuel[0]/ACH_Conv_inm) - ACH_Preferences.LM_DatumOffset))
	+ (ACH_LM_VirtualMassFuel[2] * ((ACH_DR_MomentArmFuel[1]/ACH_Conv_inm) - ACH_Preferences.LM_DatumOffset))
	+ (ACH_LM_VirtualMassFuel[3] * ((ACH_DR_MomentArmFuel[2]/ACH_Conv_inm) - ACH_Preferences.LM_DatumOffset))
	+ (ACH_LM_VirtualMassFuel[4] * ((ACH_DR_MomentArmFuel[3]/ACH_Conv_inm) - ACH_Preferences.LM_DatumOffset))
	+ (ACH_LM_VirtualMassFuel[5] * ((ACH_DR_MomentArmFuel[4]/ACH_Conv_inm) - ACH_Preferences.LM_DatumOffset))
	+ (ACH_LM_VirtualMassFuel[6] * ((ACH_DR_MomentArmFuel[5]/ACH_Conv_inm) - ACH_Preferences.LM_DatumOffset))
	+ (ACH_LM_VirtualMassFuel[7] * ((ACH_DR_MomentArmFuel[6]/ACH_Conv_inm) - ACH_Preferences.LM_DatumOffset))
	+ (ACH_LM_VirtualMassFuel[8] * ((ACH_DR_MomentArmFuel[7]/ACH_Conv_inm) - ACH_Preferences.LM_DatumOffset))
	+ (ACH_LM_VirtualMassFuel[9] * ((ACH_DR_MomentArmFuel[8]/ACH_Conv_inm) - ACH_Preferences.LM_DatumOffset))
	-- Sum up fuel in all tanks to calculate mass to be loaded into each fuel tank (in lbs)
	ACH_LM_VirtualMasses[3] = 0
	for n=1,9 do
		ACH_LM_VirtualMasses[3] = ACH_LM_VirtualMasses[3] + ACH_LM_VirtualMassFuel[n]
	end
	-- Calculate temporary total aircraft mass
	ACH_LM_VirtualMasses[4] = ACH_LM_VirtualMasses[2] + ACH_LM_VirtualMasses[3]
	-- Calculate total CG by dividing total moment by aircraft mass (converted from lbs to kg)
	ACH_LM_VirtualCG[2] = ACH_LM_VirtualMoments[2] / ACH_LM_VirtualMasses[4]
-- End virtual center of gravity calculation function
end

function ACH_LM_CommitLoading()
	---- Payload
	ACH_DR_MassPayload[0] = ACH_UnitConverter(ACH_LM_VirtualMasses[1],"lbs","kg")
	-- Fuel
	if ACH_LM_FuelMeasured then
		for n=1,ACH_DR_NumFuelTanks[0] do
			ACH_DR_MassFuel[n-1] = ACH_UnitConverter(ACH_LM_VirtualMassFuel[n],"lbs","kg")
			--print("New tank "..n.." fuel mass: "..ACH_LM_VirtualMassFuel[n].." lbs.")
		end
		ACH_LM_FuelMeasured = false
		ACH_LM_GetFuel()
	end
	-- Center of gravity offset from default
	ACH_DR_CG[0] = (ACH_LM_VirtualCG[2] + ACH_Preferences.LM_DatumOffset) * ACH_Conv_inm
end

--do_often("ACH_LM_CalcCG()")

]]
