TorteMe = TorteMe or {}

TorteMe.name = "TorteMe"
TorteMe.displayName = "Torte Me"
TorteMe.version = "0.1"
TorteMe.initialLoad = true -- DO NOT CHANGE THIS VALUE


TorteMe.delveBonusBuffs = {
--61259, --Increase Max Health (Fishy Sticks) ***THIS IS A DEBUG ONLY VALUE REMOVE FOR PRODUCTION ***
66282 -- Blessing of War
}

TorteMe.torteBuffs = {
  147734, --Alliance Skill Gain 150% Boost (White-Gold War-Torte)
  147733, --Alliance Skill Gain 100% Boost (Molten War Torte)
  147687  --Alliance Skill Gain 50% Boost (Colovian War Torte)
}

TorteMe.torteItems = {
  171432, --Alliance Skill Gain 150% Boost (White-Gold War-Torte)
  171329, --Alliance Skill Gain 100% Boost (Molten War Torte)
  171323  --Alliance Skill Gain 50% Boost (Colovian War Torte)
}
TorteMe.const = {
  ZONEID_CYRODIIL = 181,
}

TorteMe.torteLoopType = "none"
TorteMe.torteEventsInitialized = false
TorteMe.torteInventoryReminderText = "|cffff00You are |cff0000OUT|cffff00 of War Tortes.|r"
TorteMe.torteBuffReminderText = "|cffff00You need to |cff0000EAT|cffff00 a War Torte.|r"


TorteMe.delveBonusExpiredText = "|cffff00Visit a |cff0000DELVE|cffff00 and kill a boss to refresh your bonus."

-- DEFAULT VALUES
TorteMe.Defaults = {}

--Torte
TorteMe.Defaults.Torte = {}
TorteMe.Defaults.Torte.enableTortes = true
TorteMe.Defaults.Torte.autoConsume = true
TorteMe.Defaults.Torte.torteNotifyWhenBelow = 5
TorteMe.Defaults.Torte.torteNotificationTime = 5

--Delve
TorteMe.Defaults.Torte.enableDelves = true
TorteMe.Defaults.Torte.delveNotificationTime = 10


--TorteBuffHUD
TorteMe.Defaults.HUD = {}
TorteMe.Defaults.HUD.left = 30
TorteMe.Defaults.HUD.right = 50
TorteMe.Defaults.HUD.width = 150
TorteMe.Defaults.HUD.height = 100
TorteMe.Defaults.HUD.enabled = false

--Debug
TorteMe.Defaults.Debug = {}
TorteMe.Defaults.Debug.showDebug = false --Should be false by default
TorteMe.Defaults.Debug.showDebugLevel = 2

--Zone Info
TorteMe.Defaults.Zone = {}
TorteMe.Defaults.Zone.parentZoneId = 0
TorteMe.Defaults.Zone.oldParentZoneId = 0
TorteMe.Defaults.Zone.zoneName = "Unknown"
TorteMe.Defaults.Zone.oldZoneName = "Unknown"

--[[
*****************************************************************************************
                                     BEGIN FUNCTIONS
*****************************************************************************************
--]]

function TorteMe.OnAddOnLoaded(event, addonName)
  if addonName == TorteMe.name then
    TorteMe:Initialize()
    EVENT_MANAGER:UnregisterForEvent(TorteMe.name, EVENT_ADD_ON_LOADED)
    TorteMe:RestoreHUDPosition()
  end
end

--[[
*****************************************************************************************

  Setup Saved Variabless and registers event that will run after every loading screen.
  This will run only on initial loqad or if you perform /reloadUI

*****************************************************************************************
--]]

function TorteMe.Initialize()
  TorteMe.sv = ZO_SavedVars:NewCharacterIdSettings("TorteMeVariables", 1, nil, TorteMe.Defaults)
  EVENT_MANAGER:RegisterForEvent(TorteMe.name, EVENT_PLAYER_ACTIVATED, TorteMe.OnPlayerLoaded)
end

--[[
*****************************************************************************************

  Runs after any loading screen regardless of if it was from zoning or from /reloadui.

  playerZoned: true = just logged in or zoned
        false = a /reloadui was performed.

  initialLoad: Is set to true when add in is initial loaded set to false here.  Is used
              to flag that you need to run CreateSettingsWindow which should only happen
        once.

  Will call captureZoneInfo to capture old/new Zone information and save it to variables.
*****************************************************************************************
--]]

-- Function Runs anytime a load screen has been activated it simply continues to get Status noting it was activated by an event vs. timer
function TorteMe.OnPlayerLoaded(_, playerZoned)
  EVENT_MANAGER:UnregisterForEvent(TorteMe.name, EVENT_PLAYER_ACTIVATED)
  EVENT_MANAGER:RegisterForEvent(TorteMe.name, EVENT_PLAYER_ACTIVATED, TorteMe.OnPlayerLoaded)

  if TorteMe.initialLoad then
    TorteMe:Log("|r" .. TorteMe.displayName .. " by |cff0000@evainefaye |rloaded.")
    TorteMe:CreateSettingsWindow()
    if playerZoned then
      TorteMe:CaptureZoneInfo("login")
    else
      TorteMe:CaptureZoneInfo("reload")
    end
  else
    TorteMe:CaptureZoneInfo("zone")
  end


  --This portion handles initalizing or cancelling the reminder loop depending on if your in our of cyrodiil and the status of turning on or off the tracking.
  --You have just logged in (while inside), done a reloadui (while inside) or zoned into cyrodiil from outside of Cyrodiil.
  if (TorteMe:IsPlayerInCyrodiil() and TorteMe.initialLoad == true) or (TorteMe:IsPlayerInCyrodiil() and initialLoad == false and TorteMe.sv.Zone.oldParentZoneId ~= TorteMe.const.ZONEID_CYRODIIL)  then
    --You have zoned into cyrdooil, have enable tortes turned on but haqve not initialized your events
    if TorteMe.sv.Torte.enableTortes == true then
      if TorteMe.torteEventsInitialized == false then
        TorteMe:InitializeCyrodiilTorteEvents()
      end
    else
      --you do not have enable tortes turned on, so turn off events if they got turned on somehow.
      if TorteMe.torteEventsInitalized == true then
        TorteMe:CancelCyrodiilTorteEvents()
      end
    end
  end
  TorteMe.initialLoad = false
  TorteMe:TorteSetup()
end

EVENT_MANAGER:RegisterForEvent(TorteMe.name, EVENT_ADD_ON_LOADED, TorteMe.OnAddOnLoaded)