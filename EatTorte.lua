TorteMe = TorteMe or {}

function TorteMe:EatTorte(torteSlot)

  EVENT_MANAGER:UnregisterForUpdate(TorteMe.name .. "_torteBuffReminderLoop")

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

