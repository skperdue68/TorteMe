TorteMe = TorteMe or {}

--[[
  Tun Upon Zone Into or out of Cyroddiil, when auto consume is turned on or off, or when you turn on or off tacking of tortes.
  Does NOT run if you zone WITHIN cyrodiil.
--]]

function TorteMe:TorteSetup()

  TorteMe:Log("Player Login, Zone, or reload detected.", true, 25)
  local isPlayerInCyrodiil = TorteMe:IsPlayerInCyrodiil()
  TorteMe:Log("Is Player in Cyrodiil: " .. tostring(isPlayerInCyrodiil), true, 50)

  --Player is IN cyrodiil but torte tracking is turned off OR player is not in cyrodiil, then disable events and do nothing further
  if (TorteMe.sv.Torte.enableTortes == false and isPlayerInCyrodiil == true) or (isPlayerInCyrodiil == false and TorteMe.torteEventsInitialized == true) then
    TorteMe:Log("Tortes Enabled: " .. tostring(TorteMe.sv.Torte.enableTortes), true, 50)
    TorteMeUI:SetHidden(true)
    TorteMe:CancelCyrodiilTorteEvents()
    return
  end
  if (TorteMe.sv.Torte.enableTortes == true and isPlayerInCyrodiil ) and TorteMe.torteEventsInitialized == false then
    TorteMe:Log("Tortes Enabled: " .. tostring(TorteMe.sv.Torte.enableTortes), true, 50)
    TorteMe:InitializeCyrodiilTorteEvents()
  end
  if (isPlayerInCyrodiil) then
    TorteMeUI:SetHidden(not TorteMe.sv.HUD.enabled)
  else
    TorteMeUI:SetHidden(true)
  end

  if TorteMe.sv.Torte.enableDelves == true then
    local delveBonusInfo = TorteMe:DoesPlayerHaveDelveBonus()
    if delveBonusInfo.delveBonusActive == true then
      TorteMe:UpdateDelveHUD(delveBonusInfo.delveBonusName, delveBonusInfo.delveBonusEnding)
    else
      TorteMeUIDelveBonusTime:SetText("EXPIRED")
      TorteMeUIDelveBonusTime:SetColor(255,0,0,255)
    end
    TorteMe:DelveBonusReminderLoop()
  end

  if TorteMe.sv.Torte.enableTortes == true then
    local torteBuffInfo = TorteMe:DoesPlayerHaveTorteBuff()
    if torteBuffInfo.torteBuffActive == true then
      TorteMe:UpdateTorteHUD(torteBuffInfo.torteBuffName, torteBuffInfo.torteBuffEnding)
    else
      TorteMeUITorteBuffTime:SetText("EXPIRED")
      TorteMeUITorteBuffTime:SetColor(255,0,0,255)
    end
    TorteMe:TorteBuffReminderLoop()
  end
end