TorteMe = TorteMe or {}

function TorteMe:EatTorte(torteSlot)

  EVENT_MANAGER:UnregisterForUpdate(TorteMe.name .. "_torteBuffReminderLoop")

  -- Recheck location, settings and the entry wait immediately before item use.
  if not TorteMe:IsPlayerInCyrodiil() or not TorteMe.sv.Torte.enableTortes
    or not TorteMe:IsAutoConsumeEnabled() or TorteMe:IsTorteConsumptionDelayed() then
    return
  end

  if torteSlot >= 0 then

    local amISecure = CallSecureProtected("UseItem")

    if amISecure == true then

      if IsUnitInCombat("player") or IsUnitDeadOrReincarnating("player") or IsUnitSwimming("player") then
      end

      CallSecureProtected("UseItem", BAG_BACKPACK, torteSlot)
    end
  end
  EVENT_MANAGER:RegisterForUpdate(TorteMe.name .. "_torteBuffReminderLoop", 10000, function() TorteMe:TorteBuffReminderLoop() end)
end

