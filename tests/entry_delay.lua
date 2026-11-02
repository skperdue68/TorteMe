-- Run from the repository root: lua tests/entry_delay.lua
-- Exercise real player-load, setup, reminder and consumption code with a fake clock.
local now, parentZone, campaign, uses, updates, hasBuff, slot, activation
local function reset()
  now, parentZone, campaign, uses = 0, 999, "Grey Host", 0
  updates, hasBuff, slot, activation = {}, false, 2, nil
  EVENT_MANAGER = {}
  function EVENT_MANAGER:RegisterForEvent(_, event, callback)
    if event == EVENT_PLAYER_ACTIVATED then activation = callback end
  end
  function EVENT_MANAGER:UnregisterForEvent() end
  function EVENT_MANAGER:RegisterForUpdate(name, interval, callback)
    updates[name] = { at = now + interval, interval = interval, callback = callback }
  end
  function EVENT_MANAGER:UnregisterForUpdate(name) updates[name] = nil end
  function GetGameTimeMilliseconds() return now end
  function GetUnitZoneIndex() return 1 end
  function GetZoneId() return parentZone end
  function GetParentZoneId() return parentZone end
  function GetCurrentCampaignId() return 42 end
  function GetCampaignName() return campaign end
  function GetBagSize() return 8 end
  function GetItemId(_, index) return index == slot and 171432 or 0 end
  function CallSecureProtected(_, bag, index)
    if bag then
      assert(parentZone == 181, "Cannot consume after leaving Cyrodiil")
      assert(index == slot, "Must select the current inventory slot at expiry")
      uses = uses + 1
    end
    return true
  end
  function IsUnitInCombat() return false end
  function IsUnitDeadOrReincarnating() return false end
  function IsUnitSwimming() return false end
  BAG_BACKPACK, EVENT_PLAYER_ACTIVATED = 1, 1
  TorteMe = nil
  dofile("TorteMe.lua")
  dofile("Helpers.lua")
  dofile("EatTorte.lua")
  dofile("TorteSetup.lua")
  TorteMe.sv = {
    Torte = { enableTortes = true, autoConsume = true, enableDelves = false, torteNotificationTime = 5 },
    HUD = { enabled = false }, Zone = { parentZoneId = 999 },
  }
  function TorteMe:Log() end
  function TorteMe:Notify() end
  function TorteMe:DumpTable() end
  function TorteMe:CreateSettingsWindow() end
  function TorteMe:CaptureZoneInfo()
    self.sv.Zone.oldParentZoneId = self.sv.Zone.parentZoneId
    self.sv.Zone.parentZoneId = parentZone
  end
  function TorteMe:InitializeCyrodiilTorteEvents() self.torteEventsInitialized = true end
  function TorteMe:CancelCyrodiilTorteEvents() self.torteEventsInitialized = false end
  function TorteMe:DoesPlayerHaveTorteBuff()
    return { torteBuffActive = hasBuff, torteBuffName = "Alliance Skill Gain", torteBuffEnding = 900 }
  end
  function TorteMe:UpdateTorteHUD() end
  TorteMeUI = { SetHidden = function() end }
  TorteMeUITorteBuffTime = { SetText = function() end, SetColor = function() end }
end
local function advance(ms)
  local target = now + ms
  while true do
    local name, update
    for key, value in pairs(updates) do
      if value.at <= target and (not update or value.at < update.at) then name, update = key, value end
    end
    if not update then break end
    now = update.at
    update.at = update.at + update.interval
    update.callback()
  end
  now = target
end
local function enter()
  parentZone = 181
  TorteMe.OnPlayerLoaded(nil, true)
end
local function leave()
  parentZone = 999
  TorteMe.OnPlayerLoaded(nil, true)
end

reset()
TorteMe.OnPlayerLoaded(nil, true) -- Initial login outside Cyrodiil.
enter()
assert(uses == 0, "Entering Cyrodiil must not consume immediately")
advance(299999)
assert(uses == 0, "Consumption must wait the full five minutes")
slot = 6 -- The delayed attempt must not reuse a stale inventory slot.
advance(1)
assert(uses == 1, "Consumption should start at five minutes when eligible")

reset(); enter(); advance(120000); leave(); advance(600000)
assert(uses == 0 and next(updates) == nil, "Leaving must cancel pending consumption and timers")
TorteMe:EatTorte(2)
assert(uses == 0, "A stale direct eating call must not consume outside Cyrodiil")

reset(); enter(); advance(120000); leave(); advance(1000); enter(); advance(299999)
assert(uses == 0, "Re-entry must start a fresh five-minute wait")
advance(1)
assert(uses == 1, "Fresh entry must consume only after its own delay")

reset(); enter(); advance(120000); TorteMe.OnPlayerLoaded(nil, true); advance(180000)
assert(uses == 1, "Travel within Cyrodiil must not restart the entry delay")

reset(); enter(); advance(60000); TorteMe:TorteBuffReminderLoop(); TorteMe:EatTorte(2)
assert(uses == 0, "Settings/event callbacks and direct calls must respect the delay")
advance(240000)
assert(uses == 1, "Other callbacks must not remove the scheduled delayed attempt")

reset(); enter(); advance(60000)
TorteMe.sv.Torte.enableTortes = false
TorteMe:TorteBuffReminderLoop()
assert(not TorteMe.torteEventsInitialized, "Disabling tracking during the wait must still cancel events")
advance(240000)
assert(uses == 0, "Disabled tracking must not consume at expiry")

for _, condition in ipairs({ "disabled", "manual", "buff", "vengeance", "empty" }) do
  reset(); enter()
  if condition == "disabled" then TorteMe.sv.Torte.enableTortes = false end
  if condition == "manual" then TorteMe.sv.Torte.autoConsume = false end
  if condition == "buff" then hasBuff = true end
  if condition == "vengeance" then campaign = "Vengeance" end
  if condition == "empty" then slot = -1 end
  advance(300000)
  assert(uses == 0, "Expiry must respect current eligibility: " .. condition)
end

reset(); parentZone = 181; TorteMe.OnPlayerLoaded(nil, false); advance(299999)
assert(uses == 0, "Login/reload inside Cyrodiil must wait five minutes")
advance(1)
assert(uses == 1, "Login/reload delay must eventually allow consumption")
print("PASS: five-minute entry delay, cancellation, re-entry, subzones and expiry eligibility")
