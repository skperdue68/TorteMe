-- Run from the repository root: lua tests/vengeance.lua
local campaign = "Vengeance"
local parentZone = 181
local campaignQueries = 0
local uses = 0
local updates = {}
local notices = 0

TorteMe = {
  name = "TorteMe",
  const = { ZONEID_CYRODIIL = 181 },
  sv = { Torte = { autoConsume = true, enableTortes = true, torteNotificationTime = 5 } },
  torteEventsInitialized = true,
}
function GetUnitZoneIndex() return 1 end
function GetZoneId() return 181 end
function GetParentZoneId() return parentZone end
function GetCurrentCampaignId() return 42 end
function GetCampaignName(id)
  assert(id == 42)
  campaignQueries = campaignQueries + 1
  return campaign
end
EVENT_MANAGER = {}
function EVENT_MANAGER:UnregisterForUpdate(name) updates[name] = nil end
function EVENT_MANAGER:RegisterForUpdate(name, delay, callback) updates[name] = callback end
function CallSecureProtected() uses = uses + 1; return true end
function IsUnitInCombat() return false end
function IsUnitDeadOrReincarnating() return false end
function IsUnitSwimming() return false end
BAG_BACKPACK = 1

dofile("Helpers.lua")
dofile("EatTorte.lua")
function TorteMe:Log() end
function TorteMe:DumpTable() end
function TorteMe:Notify() notices = notices + 1 end
function TorteMe:DoesPlayerHaveTortes() return { torteFound = true, torteSlot = 1 } end
function TorteMe:DoesPlayerHaveTorteBuff() return { torteBuffActive = false } end

local function check(condition, message) assert(condition, message) end
check(not TorteMe:IsAutoConsumeEnabled(), "Auto consume must be disabled in Vengeance")
check(TorteMe.sv.Torte.autoConsume, "Saved preference must remain enabled")
TorteMe:EatTorte(1)
check(uses == 0, "Direct consumption must not call UseItem in Vengeance")
check(next(updates) == nil, "Blocked consumption must not schedule retries")
updates.TorteMe_torteBuffReminderLoop = function() end
TorteMe:TorteBuffReminderLoop()
check(next(updates) == nil, "Vengeance must cancel an existing torte reminder timer")
check(uses == 0 and notices == 0, "Vengeance must not try to eat or prompt eating")

campaign = "Grey Host"
check(TorteMe:IsAutoConsumeEnabled(), "Auto consume must resume in another campaign")
TorteMe:TorteBuffReminderLoop()
check(uses > 0, "Normal campaigns must still attempt consumption")
check(updates.TorteMe_torteBuffReminderLoop ~= nil, "Normal consumption must retain retry behavior")
TorteMe.sv.Torte.autoConsume = false
check(not TorteMe:IsAutoConsumeEnabled(), "Disabled saved preference must be respected")
campaign = "Vengeance"
check(not TorteMe:IsAutoConsumeEnabled(), "Disabled preference must remain disabled in Vengeance")
TorteMe.sv.Torte.autoConsume = true
parentZone = 999
local previousQueries = campaignQueries
check(TorteMe:IsAutoConsumeEnabled(), "Outside Cyrodiil, campaign name must not override preference")
check(campaignQueries == previousQueries, "Campaign lookup must only happen in Cyrodiil")
parentZone = 181
campaign = ""
check(TorteMe:IsAutoConsumeEnabled(), "Empty campaign names must not be treated as Vengeance")
campaign = nil
check(TorteMe:IsAutoConsumeEnabled(), "Missing campaign names must not be treated as Vengeance")
print("PASS: Vengeance blocks consumption and retries; other campaigns and saved preferences preserved")
