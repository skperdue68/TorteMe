TorteMe = TorteMe or {}

-- Valid loadType = login, reload, zone
function TorteMe:CaptureZoneInfo(loadType)

  local loadTypeStr = ""
  local zoneDirectionStrInCyro = ""
  local zoneDirectionStrExitCyro = ""
  local zoneDirectionStrEnterCyro = ""
  local zoneDirectionStr = ""

  if loadType == "login" or loadType == "reload" then
    TorteMe.sv.Zone.oldZoneId = 0
    TorteMe.sv.Zone.oldParentZoneId = 0
    TorteMe.sv.Zone.oldZoneName = "Unknown"
    TorteMe.sv.Zone.zoneId = GetZoneId(GetUnitZoneIndex("player"))
    TorteMe.sv.Zone.parentZoneId = GetParentZoneId(TorteMe.sv.Zone.zoneId)
    TorteMe.sv.Zone.zoneName = GetZoneNameById(TorteMe.sv.Zone.zoneId)
    if loadType == "login" then
      loadTypeStr = "Login"
    elseif loadType == "reload" then
      loadTypeStr = "ReloadUI"
    end
  elseif loadType == "zone" then
    TorteMe.sv.Zone.oldZoneId = TorteMe.sv.Zone.zoneId
    TorteMe.sv.Zone.oldParentZoneId = TorteMe.sv.Zone.parentZoneId
    TorteMe.sv.Zone.oldZoneName = TorteMe.sv.Zone.zoneName
    TorteMe.sv.Zone.zoneId = GetZoneId(GetUnitZoneIndex("player"))
    TorteMe.sv.Zone.parentZoneId = GetParentZoneId(TorteMe.sv.Zone.zoneId)
    TorteMe.sv.Zone.zoneName = GetZoneNameById(TorteMe.sv.Zone.zoneId)
    loadTypeStr = "Zone Change"
  end

  zoneDirectionStrInCyro = TorteMe.sv.Zone.oldZoneName .. " -> " .. TorteMe.sv.Zone.zoneName
  zoneDirectionStrExitCyro = TorteMe.sv.Zone.oldZoneName .. " (Cyrodiil) -> " .. TorteMe.sv.Zone.zoneName
  zoneDirectionStrEnterCyro = TorteMe.sv.Zone.oldZoneName .. " -> " .. TorteMe.sv.Zone.zoneName.." (Cyrodiil) "

  TorteMe:Log("oldParentZoneId "..TorteMe.sv.Zone.oldParentZoneId.." newParentZoneId "..TorteMe.sv.Zone.parentZoneId, true, 25)

  if TorteMe.sv.Zone.parentZoneId == TorteMe.const.ZONEID_CYRODIIL and TorteMe.sv.Zone.oldParentZoneId ~= TorteMe.const.ZONEID_CYRODIIL then
    TorteMe:Log("Welcome To Cyrodiil! - " .. TorteMe.displayName .. " enabled.")
    TorteMe:Notify("Welcome to Cyrodiil!")
    zoneDirectionStr = zoneDirectionStrEnterCyro
  elseif TorteMe.sv.Zone.parentZoneId ~= TorteMe.const.ZONEID_CYRODIIL and TorteMe.sv.Zone.oldParentZoneId == TorteMe.const.ZONEID_CYRODIIL then
    TorteMe:Log("Left Cyrodiil! - " .. TorteMe.displayName .. " disabled.")
    TorteMe:Notify("Left Cyrodiil!")
    zoneDirectionStr = zoneDirectionStrExitCyro
  elseif TorteMe.sv.Zone.parentZoneId == TorteMe.const.ZONEID_CYRODIIL and TorteMe.sv.Zone.oldParentZoneId == TorteMe.const.ZONEID_CYRODIIL then
    TorteMe:Log("Movement in Cyrodiil - " .. TorteMe.displayName .. " enabled.")
    TorteMe:Notify("Scene Change in Cyrodiil")
    zoneDirectionStr = zoneDirectionStrInCyro
  end

  if TorteMe.sv.Zone.parentZoneId == TorteMe.const.ZONEID_CYRODIIL or TorteMe.sv.Zone.oldParentZoneId == TorteMe.const.ZONEID_CYRODIIL then
    TorteMe:Log(loadTypeStr.." Detected.", true, 25)
    TorteMe:Log(zoneDirectionStr, true, 20)
  end
end
