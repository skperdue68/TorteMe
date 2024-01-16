TorteMe = TorteMe or {}

function TorteMe:CaptureZoneInfo(loadType)

	if loadType == "login"  or loadType == "reload" then
		TorteMe.sv.Zone.zoneId = GetZoneId(GetUnitZoneIndex("player"))
		TorteMe.sv.Zone.parentZoneId = GetParentZoneId(TorteMe.sv.Zone.zoneId)
		TorteMe.sv.Zone.zoneName = GetZoneNameById(TorteMe.sv.Zone.zoneId)
		TorteMe.sv.Zone.oldZoneId = 0
		TorteMe.sv.Zone.oldParentZoneId = 0
		TorteMe.sv.Zone.oldZoneName = "Unknown"
		if loadType == "login" then
			if TorteMe.sv.Zone.parentZoneId == 181 then
				TorteMe:Log("Welcome To Cyrodiil! - " .. TorteMe.displayName .. " enabled.")
				TorteMe:Notify("Welcome to Cyrodiil!")
				TorteMe:Log("Cyrodiil Login Detected.", true, 5)
				if TorteMe.sv.Zone.zoneId == 181 then
					TorteMe:Log("Login -> " .. TorteMe.sv.Zone.zoneName, true, 25)
				else
					TorteMe:Log("Login -> " .. TorteMe.sv.Zone.zoneName .. " (Cyrodiil)", true, 25)
				end
			else
				TorteMe:Log("Non-Cyrodiil Login Detected.", true, 5)
				TorteMe:Log("Login -> " .. TorteMe.sv.Zone.zoneName, true, 20)
			end
		else
			if TorteMe.sv.Zone.parentZoneId == 181 then
				TorteMe:Log("Welcome To Cyrodiil! - " .. TorteMe.displayName .. " enabled.")
				TorteMe:Notify("Welcome to Cyrodiil!")
				TorteMe:Log("ReloadUI IN Cyrodiil.", true, 25)
				if TorteMe.sv.Zone.zoneId == 181 then
					TorteMe:Log("ReloadUI -> " .. TorteMe.sv.Zone.zoneName, true, 25)
				else
					TorteMe:Log("ReloadUI -> " .. TorteMe.sv.Zone.zoneName .. " (Cyrodiil)", true, 25)
				end
			else 
				TorteMe:Log("Non-Cyrodiil ReloadUI Detected.", true, 5)
				TorteMe:Log("ReloadUI -> " .. TorteMe.sv.Zone.zoneName, true, 20)
			end
		end
	else
		TorteMe.sv.Zone.oldZoneId = TorteMe.sv.Zone.zoneId
		TorteMe.sv.Zone.oldParentZoneId = TorteMe.sv.Zone.parentZoneId
		TorteMe.sv.Zone.oldZoneName = TorteMe.sv.Zone.zoneName
		TorteMe.sv.Zone.zoneId = GetZoneId(GetUnitZoneIndex("player"))
		TorteMe.sv.Zone.parentZoneId = GetParentZoneId(TorteMe.sv.Zone.zoneId)
		TorteMe.sv.Zone.zoneName = GetZoneNameById(TorteMe.sv.Zone.zoneId)
		if TorteMe.sv.Zone.parentZoneId == 181 and TorteMe.sv.Zone.oldParentZoneId ~= 181 then
			TorteMe:Log("Welcome To Cyrodiil! - " .. TorteMe.displayName .. " enabled.")
			TorteMe:Notify("Welcome to Cyrodiil!")			
			TorteMe:Log("Zoned INTO Cyrodiil.", true, 5)
			TorteMe:Log(TorteMe.sv.Zone.oldZoneName .. " -> " .. TorteMe.sv.Zone.zoneName, true, 25)
		elseif TorteMe.sv.Zone.parentZoneId == 181 and TorteMe.sv.Zone.oldParentZoneId == 181 then
			TorteMe:Log("Zoned WITHIN Cyrodiil.", true, 5)
			if TorteMe.sv.Zone.oldZoneId == 181 and TorteMe.sv.Zone.zoneId ~= 181 then
				TorteMe:Log(TorteMe.sv.Zone.oldZoneName .. " -> " .. TorteMe.sv.Zone.zoneName .. " (Cyrodiil)", true, 25)
			elseif TorteMe.sv.Zone.oldZoneId ~= 181 and TorteMe.sv.Zone.zoneId == 181 then
				TorteMe:Log(TorteMe.sv.Zone.oldZoneName .. " (Cyrodiil) -> " .. TorteMe.sv.Zone.zoneName, true, 25)
			else
				TorteMe:Log(TorteMe.sv.Zone.oldZoneName .. " -> " .. TorteMe.sv.Zone.zoneName, true, 25)
			end

		elseif TorteMe.sv.Zone.parentZoneId ~= 181 and TorteMe.sv.Zone.oldParentZoneId == 181 then
			TorteMe:Log("Left Cyrodiil! - " .. TorteMe.displayName .. " disabled.")
			TorteMe:Notify("Left Cyrodiil!")			
			TorteMe:Log("Zoned OUT of Cyrodiil.", true, 5)
			if TorteMe.sv.Zone.oldZoneId == 181 then
				TorteMe:Log(TorteMe.sv.Zone.oldZoneName .. " -> " .. TorteMe.sv.Zone.zoneName, true, 20)
			elseif TorteMe.sv.Zone.oldZoneId ~=181 then
				TorteMe:Log(TorteMe.sv.Zone.oldZoneName .. "(Cyrodiil) -> " .. TorteMe.sv.Zone.zoneName, true, 20)
			end

		else
			TorteMe:Log("Left Cyrodiil! - " .. TorteMe.displayName .. "disabled.")
			TorteMe:Log("Non-Cyrodiil Zone Detected.", true, 5)
			if TorteMe.sv.Zone.oldParentZoneId == 181 and TorteMe.sv.Zone.oldZoneId ~= 181 then
				TorteMe:Log(TorteMe.sv.Zone.oldZoneName .. " (Cyrodiil) -> " .. TorteMe.sv.Zone.zoneName, true, 20)
			else 
				TorteMe:Log(TorteMe.sv.Zone.oldZoneName .. " -> " .. TorteMe.sv.Zone.zoneName, true, 20)
			end
		end
	end
end
