TorteMe = TorteMe or {}

--[[
************************************************************************************

Checks if player is currently in Cyrodiil or a Cyrodiil sub zone

Return: isPlayerInCyrodiil bool

************************************************************************************
--]]

function TorteMe:IsPlayerInCyrodiil()
  local isPlayerInCyrodiil = false
  if GetParentZoneId(GetZoneId(GetUnitZoneIndex("player"))) == TorteMe.const.ZONEID_CYRODIIL then
    isPlayerInCyrodiil = true
  end
  return isPlayerInCyrodiil
end


--[[
************************************************************************************

Searches the Players buffs for any of the buff(s) provided in TorteMe.torteBuffs.
Will complete search in the order of the buffs being provided in the table and will
stop looking once it finds one and returns the information about the buff.

Return: torteBuffInfo {torteBuffActive bool, buffId number, buffName string, buffEnding number}

************************************************************************************
--]]

function TorteMe:DoesPlayerHaveTorteBuff()

  local torteBuffInfo = {
    torteBuffActive = false,
    torteBuffId = 0,
    torteBuffName = "",
    torteBuffEnding = 0
  }

  local numBuffs = GetNumBuffs("player")
  if numBuffs > 0 then
    for i = 1, numBuffs do
      for j = 1, #TorteMe.torteBuffs do
        local buffName,_, timeEnding,_,_,_,_,_,_,_,id = GetUnitBuffInfo("player", i)
        TorteMe:Log("Checking " .. id .. " against " .. TorteMe.torteBuffs[j], true, 5)
        if id == TorteMe.torteBuffs[j] then
          torteBuffInfo.torteBuffActive = true
          torteBuffInfo.torteBuffId = id
          torteBuffInfo.torteBuffName = buffName
          torteBuffInfo.torteBuffEnding = timeEnding
          break
        end
      end
      if torteBuffInfo.torteBuffActive == true then break end
    end
  end
  return torteBuffInfo
end


--[[
************************************************************************************

Searches the Players buffs for any of the buff(s) provided in TorteMe.blessingofWar.
Will complete search in the order of the buffs being provided in the table and will
stop looking once it finds one and returns the information about the buff.

Return: delveBonusInfo {delveBonusActive bool, buffId number, buffName string, buffEnding number}

************************************************************************************
--]]

function TorteMe:DoesPlayerHaveDelveBonus()

  local delveBonusInfo = {
    delveBonusActive = false,
    delveBonusId = 0,
    delveBonusName = "",
    delveBonusEnding = 0
  }

  local numBuffs = GetNumBuffs("player")
  if numBuffs > 0 then
    for i = 1, numBuffs do
      for j = 1, #TorteMe.delveBonusBuffs do
        local buffName,_, timeEnding,_,_,_,_,_,_,_,id = GetUnitBuffInfo("player", i)
        TorteMe:Log("Checking " .. id .. " against " .. TorteMe.delveBonusBuffs[j], true, 5)
        if id == TorteMe.delveBonusBuffs[j] then
          delveBonusInfo.delveBonusActive = true
          delveBonusInfo.delveBonusId = id
          delveBonusInfo.delveBonusName = buffName
          delveBonusInfo.delveBonusEnding = timeEnding
          break
        end
      end
      if delveBonusInfo.delveBonusActive == true then break end
    end
  end
  return delveBonusInfo
end

--[[
************************************************************************************

Searches bag(s) to see if you have torte(s) based on list provided in

Return: torteInventoryInfo {torteFound bool, torteSlot number}

************************************************************************************
--]]

function TorteMe:DoesPlayerHaveTortes()
  local torteInventoryInfo = {
    torteFound = false,
    torteSlot = -1
  }

  for j = 1, #TorteMe.torteItems do
    for slotId = 0, GetBagSize(BAG_BACKPACK) do
      local bagItemId = GetItemId(BAG_BACKPACK, slotId)
      if bagItemId == TorteMe.torteItems[j] then
        torteInventoryInfo.torteFound = true
        torteInventoryInfo.torteSlot = slotId
      end
      if torteInventoryInfo.torteFound then
        break
      end
    end
  end
  q = TorteMe:GetTotalTorteCount()
  return torteInventoryInfo
end


--[[
************************************************************************************

Searches bag(s) and gets a count of the total number of torte items you have.

Return: totalTorteCount number

************************************************************************************
--]]

function TorteMe:GetTotalTorteCount()
  local totalTorteCount = 0
  for j = 1, #TorteMe.torteItems do
    for slotId = 0, GetBagSize(BAG_BACKPACK) do
      local bagItemId = GetItemId(BAG_BACKPACK, slotId)
      if bagItemId == TorteMe.torteItems[j] then
        local size = GetSlotStackSize(BAG_BACKPACK, slotId)
        totalTorteCount = totalTorteCount + size
      end
    end
  end
  return totalTorteCount
end

--[[
************************************************************************************

Gets value of TorteMe.sv.Torte.autoConsume

Return: TorteMe.sv.Torte.autoConsume bool

************************************************************************************
--]]

function TorteMe:IsAutoConsumeEnabled()
  return TorteMe.sv.Torte.autoConsume
end

--[[
************************************************************************************
                              DELVE BONUS EVENTS
************************************************************************************
--]]

function TorteMe.OnDelveBonusChanged( eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType )
  if changeType == 1 then
    TorteMe:Log("Delve Bonus Started: " .. effectName .. "endTime: " .. endTime, true, 10)
    TorteMe:UpdateDelveHUD(effectName, endTime)
    EVENT_MANAGER:UnregisterForUpdate(TorteMe.name .. "_DelveBonusReminderLoop")
  end

  if changeType == 2 then
    TorteMe:Log("Delve Bonus Ended: " .. effectName, true, 10)
    EVENT_MANAGER:UnregisterForUpdate(TorteMe.name .. "_DelveBonusReminderLoop")
    TorteMe:DelveBonusReminderLoop()
  end
end

--[[
************************************************************************************
                              TORTE BUFF EVENTS
************************************************************************************
--]]

function TorteMe.OnTorteBuffChanged( eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType )
  --Buff Started
  local torteCount = 0
  if changeType == 1 then
    TorteMe:Log("Buff Started: " .. effectName .. " endTime: " .. endTime, true, 10)
    TorteMe:UpdateTorteHUD(effectName, endTime)


    local totalTorteCount = TorteMe:GetTotalTorteCount()
    if totalTorteCount <  TorteMe.sv.Torte.torteNotifyWhenBelow and totalTorteCount > 0 then
      TorteMe:Log("|cffff00You have |cff0000" .. totalTorteCount .. "|cffff00 War Torte(s) remaining.|r")
      TorteMe:Notify("|cffff00You have |cff0000" .. totalTorteCount .. "|cffff00 War Torte(s) remaining|r")
    elseif totalTorteCount == 0 then
      TorteMe:Log(TorteMe.torteInventoryReminderText)
      TorteMe:Notify(TorteMe.torteInventoryReminderText)
    end
    EVENT_MANAGER:UnregisterForUpdate(TorteMe.name .. "_torteBuffReminderLoop")
  end

  --Buff Ended
  if changeType == 2 then
    TorteMe:Log("Buff Ended: " .. effectName, true, 10)
    EVENT_MANAGER:UnregisterForUpdate(TorteMe.name .. "_torteBuffReminderLoop")
    TorteMe:TorteBuffReminderLoop()
  end
end

--[[
************************************************************************************
                                INVENTORY EVENTS
************************************************************************************
--]]

function TorteMe.OnInventoryUpdate(eventCode, bagId, slotIndex, isNewItem, itemSoundCategory, updateReason, stackCountChange)
  -- Only process inventory changes in your own bag

  if TorteMe.loopType == "inventory" then
    local isTorte = false
    local totalTorteCount = TorteMe:GetTotalTorteCount()
    if stackCountChange > 0 and bagId ==1 then
      for j = 1, #TorteMe.torteItems do
        local itemId = GetItemId(bagId, slotIndex)
        if itemId == TorteMe.torteItems[j]  then
          isTorte = true
          break
        end
      end
      if (totalTorteCount - stackCountChange == 0) then
        TorteMe:Log("You now have War Torte(s).")
        TorteMe:Notify("You now have War Torte(s)")
      end
      if isTorte == true then
        TorteMe:TorteBuffReminderLoop()
        return
      end
    end
  end
  if TorteMe.loopType == "eat" then
    if stackCountChange < 0 and bagId == 1 then
      local totalTorteCount = TorteMe:GetTotalTorteCount()
      if totalTorteCount == 0 then
      torteBuffInfo = TorteMe:DoesPlayerHaveTorteBuff()
        if torteBuffInfo.torteBuffActive == false then
          TorteMe.loopType = "inventory"
          TorteMe:TorteBuffReminderLoop()
          return
        end
      end
    end
  end
end

--[[
************************************************************************************
                                LOG FUNCTION
************************************************************************************
--]]

function TorteMe:Log(message, isDebug, debugLevel)
  if TorteMe.sv.Debug.showDebug == true and debugLevel ~= nil and isDebug then
    if TorteMe.sv.Debug.showDebugLevel  <= debugLevel then
      df("|cffff00[ |cf21000DEBUG %s |c22ffed%s|cffff00] |c22ffed%s|r", GetTimeStamp(), TorteMe.displayName, tostring(message))
    end
  elseif isDebug == false or isDebug == nil then
    df("|cffff00[ |c22ffed%s |cffff00] |c22ffed%s|r", TorteMe.displayName, tostring(message))
  end
end


--[[
************************************************************************************
                                DUMP TABLE FUNCTION
************************************************************************************
--]]

function TorteMe:DumpTable(table, tableName, isDebug, showOnScreen, debugLevel)
  if TorteMe.sv.Debug.showDebug == true and debugLevel ~= nil and isDebug then
    if TorteMe.sv.Debug.showDebugLevel  <= debugLevel then
      TorteMe:Log("*** START TABLE DUMP ***", true, TorteMe.sv.Debug.showDebugLevel)
      TorteMe:Log("Table: |cffff00" ..  tableName .. "|r", true, TorteMe.sv.Debug.showDebugLevel)
      for key,value in pairs(table) do
        TorteMe:Log(key .. " |cffff00" .. tostring(value) .. "|r", true, TorteMe.sv.Debug.showDebugLevel)
      end
      TorteMe:Log("*** END TABLE DUMP ***", true, TorteMe.sv.Debug.showDebugLevel)
    end
  end
end

--[[
************************************************************************************
                                CANCEL CYRODIIL TORTE EVENTS
************************************************************************************
--]]

function TorteMe:CancelCyrodiilTorteEvents()
  if TorteMe.torteEventsInitialized == true then
    TorteMe:Log("Cancelling Cyrodiil Delve Bonus Events", true, 20)
    for j = 1, #TorteMe.delveBonusBuffs do
      EVENT_MANAGER:UnregisterForEvent(TorteMe.name .. "_DelveBonusEvent_" .. TorteMe.delveBonusBuffs[j], EVENT_EFFECT_CHANGED)
    end
    TorteMe:Log("Cancelling Cyrodiil Torte Events", true, 20)
    for j = 1, #TorteMe.torteBuffs do
      EVENT_MANAGER:UnregisterForEvent(TorteMe.name .. "_TorteBuffEvent_" .. TorteMe.torteBuffs[j], EVENT_EFFECT_CHANGED)
    end
    EVENT_MANAGER:UnregisterForEvent(TorteMe.name .. "_InventoryEvent", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    EVENT_MANAGER:UnregisterForUpdate(TorteMe.name .. "_torteBuffReminderLoop")
    TorteMe.torteEventsInitialized = false
    TorteMe.torteloopType = "none"
  end
end


--[[
************************************************************************************
                                INITIALIZE CYRODIIL EVENTS
************************************************************************************
--]]

function TorteMe:InitializeCyrodiilTorteEvents()
  if   TorteMe.torteEventsInitialized == false then
    TorteMe:Log("Initializing Cyrodiil Delve Bonus Events", true, 20)
    for j = 1, #TorteMe.delveBonusBuffs do
      EVENT_MANAGER:UnregisterForEvent(TorteMe.name .. "_DelveBonusEvent_" .. TorteMe.delveBonusBuffs[j], EVENT_EFFECT_CHANGED)
      EVENT_MANAGER:RegisterForEvent(TorteMe.name ..   "_DelveBonusEvent_" .. TorteMe.delveBonusBuffs[j], EVENT_EFFECT_CHANGED, TorteMe.OnDelveBonusChanged)
      EVENT_MANAGER:AddFilterForEvent(TorteMe.name ..  "_DelveBonusEvent_" .. TorteMe.delveBonusBuffs[j], EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
      EVENT_MANAGER:AddFilterForEvent(TorteMe.name ..  "_DelveBonusEvent_" .. TorteMe.delveBonusBuffs[j], EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, TorteMe.delveBonusBuffs[j])
    end

    TorteMe:Log("Initializing Cyrodiil Torte Events", true, 20)
    for j = 1, #TorteMe.torteBuffs do
      EVENT_MANAGER:UnregisterForEvent(TorteMe.name .. "_TorteBuffEvent_" .. TorteMe.torteBuffs[j], EVENT_EFFECT_CHANGED)
      EVENT_MANAGER:RegisterForEvent(TorteMe.name .. "_TorteBuffEvent_" .. TorteMe.torteBuffs[j], EVENT_EFFECT_CHANGED, TorteMe.OnTorteBuffChanged)
      EVENT_MANAGER:AddFilterForEvent(TorteMe.name .. "_TorteBuffEvent_" .. TorteMe.torteBuffs[j], EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
      EVENT_MANAGER:AddFilterForEvent(TorteMe.name .. "_TorteBuffEvent_" .. TorteMe.torteBuffs[j], EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, TorteMe.torteBuffs[j])
    end
    EVENT_MANAGER:UnregisterForEvent(TorteMe.name .. "_InventoryEvent_BACK_PACK", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    EVENT_MANAGER:RegisterForEvent(TorteMe.name .. "_InventoryEvent_BACK_PACK", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, TorteMe.OnInventoryUpdate)
    EVENT_MANAGER:AddFilterForEvent(TorteMe.name .. "_InventoryEvent_BACK_PACK", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_BACKPACK)
    EVENT_MANAGER:AddFilterForEvent(TorteMe.name .. "_InventoryEvent_BACK_PACK", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)
    EVENT_MANAGER:UnregisterForUpdate(TorteMe.name .. "_torteBuffReminderLoop")
    TorteMe.torteEventsInitialized = true
    TorteMe.loopType = "none"
  end
end



--[[
************************************************************************************
                                DELVE BONUS REMINDER LOOP
************************************************************************************
--]]


function TorteMe:DelveBonusReminderLoop()
  local delveNotificationTime = (TorteMe.sv.Torte.delveNotificationTime * 60 * 1000)

  local isPlayerInCyrodiil = TorteMe:IsPlayerInCyrodiil()
  local delveBonusInfo = TorteMe:DoesPlayerHaveDelveBonus()


  TorteMe:Log("Entering Delve Bonus Reminder Loop", true, 25)
  TorteMe:Log("Is Player In Cyrodiil: " .. tostring(isPlayerInCyrodiil), true, 15)
  TorteMe:Log("Tortes Enabled: " .. tostring(TorteMe.sv.Torte.enableTortes), true, 15)
  if isPlayerInCyrodiil == true and TorteMe.sv.Torte.enableTortes == false and TorteMe.torteEventsInitialized == true then
    TorteMe:CancelCyrodiilTorteEvents()
    return
  end

  -- If your in cyrodiil have enable tortes turned on but have not initalized the events then do so now.
  if isPlayerInCyrodiil == true and TorteMe.sv.Torte.enableTortes == true and TorteMe.torteEventsInitialized == false then
    TorteMe:Log("Catch In Cyrodiil without initalizing events", true, 15)
    TorteMe:InitializeCyrodiilTorteEvents()
  end


  --*** SHOULD NOT LOOP ***

  --Not in Cyrodiil or tortes are turned off safeguard, cancel events, set loop type to none and return
  if isPlayerInCyrodiil == false or TorteMe.sv.Torte.enableTortes == true and TorteMe.torteEventsInitialized == true then
    TorteMe:Log("Catch Exited of Cyrodiil without cancelling events", true, 15)
    TorteMe:CancelCyrodiilTorteEvents()
    return
  end

  --You have the buff currently dont need to do anything.
  if delveBonusInfo.delveBonusActive == true then
    TorteMe:Log("You have the delve bonus, " .. delveBonusInfo.delveBonusName .. ", so cancelling loop.", true, 20)
    EVENT_MANAGER:UnregisterForUpdate(TorteMe.name .. "_delveBonusReminderLoop")
    return
  end


  if delveBonusInfo.delveBonusActive == false then
    EVENT_MANAGER:UnregisterForUpdate(TorteMe.name .. "_delveBonusReminderLoop")
    if TorteMe.sv.Torte.delveNotificationTime > 0 then
      TorteMe:Log(TorteMe.delveBonusExpiredText)
      TorteMe:Notify(TorteMe.delveBonusExpiredText)
    else
      delveNotificationTime = 60 * 1000
    end
  end
  EVENT_MANAGER:RegisterForUpdate(TorteMe.name .. "_delveBonusReminderLoop", delveNotificationTime, function() TorteMe:DelveBonusReminderLoop() end)
end

--[[
************************************************************************************
                                TORTE BUFF REMINDER LOOP
************************************************************************************
--]]

function TorteMe:TorteBuffReminderLoop()

  local torteNotificationTime = (TorteMe.sv.Torte.torteNotificationTime * 60 * 1000)

  local isPlayerInCyrodiil = TorteMe:IsPlayerInCyrodiil()
  local torteInventoryInfo = TorteMe:DoesPlayerHaveTortes()
  local torteBuffInfo = TorteMe:DoesPlayerHaveTorteBuff()
  local autoConsume = TorteMe:IsAutoConsumeEnabled()

  TorteMe:Log("Entering Torte Buff Reminder Loop", true, 25)
  TorteMe:Log("Is Player In Cyrodiil: " .. tostring(isPlayerInCyrodiil), true, 15)
  TorteMe:Log("Tortes Enabled: " .. tostring(TorteMe.sv.Torte.enableTortes), true, 15)
  TorteMe:DumpTable(torteInventoryInfo, "torteInventoryInfo", true, 10)
  TorteMe:DumpTable(torteBuffInfo, "torteBuffInfo", true, 10)
  TorteMe:Log("autoConsume: " .. tostring(autoConsume), true,15)

  if isPlayerInCyrodiil == true and TorteMe.sv.Torte.enableTortes == false and TorteMe.torteEventsInitialized == true then
    TorteMe:CancelCyrodiilTorteEvents()
    return
  end

  -- If your in cyrodiil have enable tortes turned on but have not initalized the events then do so now.
  if isPlayerInCyrodiil == true and TorteMe.sv.Torte.enableTortes == true and TorteMe.torteEventsInitialized == false then
    TorteMe:Log("Catch In Cyrodiil without initalizing events", true, 15)
    TorteMe:InitializeCyrodiilTorteEvents()
  end


  --*** SHOULD NOT LOOP ***

  --Not in Cyrodiil or tortes are turned off safeguard, cancel events, set loop type to none and return
  if isPlayerInCyrodiil == false or TorteMe.enableTortes == true and TorteMe.torteEventsInitialized == true then
    TorteMe:Log("Catch Exited of Cyrodiil without cancelling events", true, 15)
    TorteMe:CancelCyrodiilTorteEvents()
    return
  end

  --You have the buff currently dont need to do anything.
  if torteBuffInfo.torteBuffActive == true then
    TorteMe:Log("You have the torte buff, " .. torteBuffInfo.torteBuffName .. ", so cancelling loop.", true, 20)
    EVENT_MANAGER:UnregisterForUpdate(TorteMe.name .. "_torteBuffReminderLoop")
    TorteMe.loopType = "none"
    return
  end


  --AutoConsume Enabled so call the eat routine the eat routine has its own timers to try to eat but will call the buff reminder loop each time to check for other issues. such as having run out of tortes turning off auto consume, etc.
  if torteBuffInfo.torteBuffActive == false and torteInventoryInfo.torteFound == true and autoConsume == true then
    EVENT_MANAGER:UnregisterForUpdate(TorteMe.name .. "_torteBuffReminderLoop")
    local reminderText = TorteMe.torteInventoryReminderText
    -- *** Try to Eat ***
    TorteMe:EatTorte(torteInventoryInfo.torteSlot)
    return
  end


  -- *** LOOP NOTICE ***
  -- *** Notify you are out of tortes
  if torteBuffInfo.torteBuffActive == false and torteInventoryInfo.torteFound == false then
    EVENT_MANAGER:UnregisterForUpdate(TorteMe.name .. "_torteBuffReminderLoop")
    TorteMe:Log(TorteMe.torteInventoryReminderText)
    TorteMe:Notify(TorteMe.torteInventoryReminderText)
    TorteMe.loopType = "inventory"
  end

  -- *** Notify you need to try to eat ***
  if torteBuffInfo.torteBuffActive == false and torteInventoryInfo.torteFound == true and autoConsume == false then
    EVENT_MANAGER:UnregisterForUpdate(TorteMe.name .. "_torteBuffReminderLoop")
    TorteMe:Log(TorteMe.torteBuffReminderText)
    TorteMe:Notify(TorteMe.torteBuffReminderText)
    TorteMe.loopType = "eat"
  end

  if TorteMe.loopType == "inventory" or TorteMe.loopType == "eat" then
    EVENT_MANAGER:RegisterForUpdate(TorteMe.name .. "_torteBuffReminderLoop", torteNotificationTime, function() TorteMe:TorteBuffReminderLoop() end)
  end
end


--[[
*************************************************************************************************************************
      Gets the remaining time on a buff formatted as 0h 0m 0s    as well as the total seconds
--]]

function TorteMe:TimeRemaining(timeEnd)
  local timeSec = zo_max(zo_roundToNearest(timeEnd - GetGameTimeMilliseconds() / 1000, 1), 0)
  local timeStr = FormatTimeSeconds(timeSec, TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL, TIME_FORMAT_PRECISION_SECONDS, TIME_FORMAT_DIRECTION_DESCENDING)
  return timeSec, timeStr
end

--[[
*************************************************************************************************************************
              UPDATE TORTE HUD
*************************************************************************************************************************
--]]
function TorteMe:UpdateTorteHUD(buffName, timeEnd)
  local timeSec = zo_max(zo_roundToNearest(timeEnd - GetGameTimeMilliseconds() / 1000, 1), 0)
  local timeStr = FormatTimeSeconds(timeSec, TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL, TIME_FORMAT_PRECISION_SECONDS, TIME_FORMAT_DIRECTION_DESCENDING)
  TorteMeUITorteBuffTime:SetText(timeStr)
  TorteMeUITorteBuffTime:SetColor(0,255,0,255)
  EVENT_MANAGER:RegisterForUpdate(TorteMe.name .. "_TorteTimer", 1000, function ()
    timeSec = timeSec -1
    if timeSec > 0 then
      if timeSec > 180 then
        TorteMeUITorteBuffTime:SetColor(0,255,0,255)
      end
      local timeStr = FormatTimeSeconds(timeSec, TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL, TIME_FORMAT_PRECISION_SECONDS, TIME_FORMAT_DIRECTION_DESCENDING)
      TorteMeUITorteBuffTime:SetText(timeStr)
      if timeSec < 181 then
        TorteMeUITorteBuffTime:SetColor(255,255,0,255)
      end
    else
      TorteMeUITorteBuffTime:SetText("EXPIRED")
      TorteMeUITorteBuffTime:SetColor(255,0,0,255)
      EVENT_MANAGER:UnregisterForUpdate(TorteMe.name .. "_TorteTimer")
    end
  end)
end


--[[
*************************************************************************************************************************
              UPDATE DELVE HUD
*************************************************************************************************************************
--]]
function TorteMe:UpdateDelveHUD(buffName, timeEnd)
  local timeSec = zo_max(zo_roundToNearest(timeEnd - GetGameTimeMilliseconds() / 1000, 1), 0)
  local timeStr = FormatTimeSeconds(timeSec, TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL, TIME_FORMAT_PRECISION_SECONDS, TIME_FORMAT_DIRECTION_DESCENDING)
  TorteMeUIDelveBonusTime:SetText(timeStr)
  TorteMeUIDelveBonusTime:SetColor(0,255,0,255)
  EVENT_MANAGER:RegisterForUpdate(TorteMe.name .. "_DelveTimer", 1000, function ()
    timeSec = timeSec -1
    if timeSec > 0 then
      if timeSec > 180 then
        TorteMeUIDelveBonusTime:SetColor(0,255,0,255)
      end
      local timeStr = FormatTimeSeconds(timeSec, TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL, TIME_FORMAT_PRECISION_SECONDS, TIME_FORMAT_DIRECTION_DESCENDING)
      TorteMeUIDelveBonusTime:SetText(timeStr)
      if timeSec < 181 then
        TorteMeUIDelveBonusTime:SetColor(255,255,0,255)
      end
    else
      TorteMeUIDelveBonusTime:SetText("EXPIRED")
      TorteMeUIDelveBonusTime:SetColor(255,0,0,255)
      EVENT_MANAGER:UnregisterForUpdate(TorteMe.name .. "_DelveTimer")
    end
  end)
end


--[[

Displays a message in the middle of the screen

--]]

function TorteMe:Notify(message)
  local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.NONE)
  messageParams:SetText("|cffff00" .. message .. "|r")
  messageParams:SetLifespanMS(5000)
  CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
end


--[[
************************************************************************************
                              HUD FUNCTIONS
************************************************************************************
--]]

function TorteMe.OnIndicatorMoveStop()
  TorteMe.sv.HUD.left = TorteMeUI:GetLeft()
  TorteMe.sv.HUD.top = TorteMeUI:GetTop()
end

function TorteMe.OnResizeStop()
  TorteMe.sv.HUD.width = TorteMeUI:GetWidth()
  TorteMe.sv.HUD.height = TorteMeUI:GetHeight()
end

function TorteMe:RestoreHUDPosition()
  local left = TorteMe.sv.HUD.left
  local top = TorteMe.sv.HUD.top
  local height = TorteMe.sv.HUD.height
  local width = TorteMe.sv.HUD.width

  TorteMeUI:ClearAnchors()
  TorteMeUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
  TorteMeUI:SetWidth(width)
  TorteMeUI:SetHeight(height)
end