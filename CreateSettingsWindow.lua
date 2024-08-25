TorteMe = TorteMe or {}

function TorteMe.CreateSettingsWindow()
  local LAM = LibAddonMenu2
  local panelName = TorteMe.name .. "SettingsPanel"

  local settingsWindowData = {
    type = "panel",
    name = TorteMe.displayName,
    author = "|cff00ff@evainefaye|r",
    version = TorteMe.version,
    registerForRefresh = true,
    registerForDefaults = true
  }

  local settingsOptionsData = {
    {
      type = "checkbox",
      name = "Enable HUD",
      tooltip = "Turns on the HUD",
      getFunc = function()
          return TorteMe.sv.HUD.enabled
        end,
      setFunc = function(value)
          TorteMe.sv.HUD.enabled = value
          if GetParentZoneId(GetZoneId(GetUnitZoneIndex("player"))) == TorteMe.const.ZONEID_CYRODIIL then
            TorteMeUI:SetHidden(not value)
          end
        end,
      disabled = function() return not TorteMe.sv.Torte.enableTortes end,
      reference = "TORTE_ME_HUD_ENABLE"
    },
    {
      type = "header",
      name = "War Tortes"
    },
    {
      type = "checkbox",
      name = "Enable Tortes",
      tooltip = "Enable tracking and eating of tortes while in Cyrodiil",
      getFunc = function()
          return TorteMe.sv.Torte.enableTortes
        end,
      setFunc = function(value)
          TorteMe.sv.Torte.enableTortes = value
          TorteMe:TorteBuffReminderLoop()
        end,
      reference = "TORTE_ME_ENABLE_TORTES"
    },
    {
      type = "checkbox",
      name = "Auto Consume",
      tooltip = "Automatically eat tortes while in Cyrodiil",
      getFunc = function()
          return TorteMe.sv.Torte.autoConsume
        end,
      setFunc = function(value)
          TorteMe.sv.Torte.autoConsume = value
          TorteMe:TorteBuffReminderLoop()
        end,
      disabled = function() return not TorteMe.sv.Torte.enableTortes end,
      reference = "TORTE_ME_TRACK_AUTO_CONSUME_TORTE"
    },
    {
      type = "slider",
      name = "Torte Buff Reminder Time",
      tooltip = "How often to notify when out of tortes or needing to eat one.",
      min = 1,
      max = 30,
      step = 1,
      getFunc = function()
        return TorteMe.sv.Torte.torteNotificationTime
      end,
      setFunc = function(value)
        TorteMe.sv.Torte.torteNotificationTime = value
      end,
      disabled = function() return not TorteMe.sv.Torte.enableTortes end,
      reference = "TORTE_ME_TORTE_NOTIFICATION_TIME"
    },
    {
      type = "slider",
      name = "Low Torte Count",
      tooltip = "How many tortes you can be down to before you will be notified.",
      min = 0,
      max = 100,
      getFunc = function()
        return TorteMe.sv.Torte.torteNotifyWhenBelow
      end,
      setFunc = function(value)
        TorteMe.sv.Torte.torteNotifyWhenBelow = value
      end,
      disabled = function() return not TorteMe.sv.Torte.enableTortes end,
      reference = "TORTE_ME_TORTE_NOTIFY_WHEN_BELOW"
    },
    {
      type = "header",
      name = "Delve Bonus"
    },
    {
      type = "checkbox",
      name = "Enable Delve Bonus Reminder",
      tooltip = "Enable tracking Delve Bonus while in Cyrodiil",
      getFunc = function()
          return TorteMe.sv.Torte.enableDelves
        end,
      setFunc = function(value)
          TorteMe.sv.Torte.enableDelves = value
          TorteMe:DelveBonusReminderLoop()
        end,
      reference = "TORTE_ME_ENABLE_DELVE_BONUS"
    },
    {
      type = "slider",
      name = "Delve Bonus Reminder Time",
      tooltip = "How often to notify when you should get a new delve bonus",
      min = 0,
      max = 30,
      getFunc = function()
        return TorteMe.sv.Torte.delveNotificationTime
      end,
      setFunc = function(value)
        TorteMe.sv.Torte.delveNotificationTime = value
      end,
      disabled = function() return not TorteMe.sv.Torte.enableTortes end,
      reference = "TORTE_ME_DELVE_NOTIFICATION_TIME"
    },
    {
      type = "header",
      name = "Debug"
    },
    {
      type = "checkbox",
      name = "Enable Debug",
      tooltip = "Show Debug Messages",
      getFunc = function()
          return TorteMe.sv.Debug.showDebug
        end,
      setFunc = function(value)
          TorteMe.sv.Debug.showDebug = value
        end,
      reference = "TORTE_ME_SHOW_DEBUG",
      disabled = false
    },
    {
      type = "slider",
      name = "Debug Level",
      tooltip = "Verbosity of Debug Errors",
      min = 1,
      max = 100,
      getFunc = function()
          return TorteMe.sv.Debug.showDebugLevel
        end,
      setFunc = function(value)
          TorteMe.sv.Debug.showDebugLevel = value
        end,
      disabled = function() return not TorteMe.sv.Debug.showDebug end,
      reference = "TORTE_ME_DEBUG_LEVEL"
    }
  }

  TorteMe.settingsPanel = LAM:RegisterAddonPanel("TorteMe_LAM", settingsWindowData)
  LAM:RegisterOptionControls("TorteMe_LAM", settingsOptionsData)
end