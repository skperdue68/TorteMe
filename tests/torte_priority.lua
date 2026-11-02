-- Run from the repository root: lua tests/torte_priority.lua
EVENT_MANAGER = { RegisterForEvent = function() end }
BAG_BACKPACK = 1
local inventory = {}
local bagSize = 8
local checkBounds = false
function GetBagSize() return bagSize end
function GetItemId(_, slot)
  assert(not checkBounds or (slot >= 0 and slot < bagSize), "Inventory scan exceeded backpack bounds")
  return inventory[slot] or 0
end
function GetSlotStackSize() return 1 end
dofile("TorteMe.lua")
dofile("Helpers.lua")
dofile("CreateSettingsWindow.lua")
TorteMe.sv = { Torte = { enableTortes = true } }

local function expectItem(expected, label)
  local found = TorteMe:DoesPlayerHaveTortes()
  if expected == nil then
    assert(not found.torteFound and found.torteSlot == -1, label)
  else
    assert(found.torteFound and inventory[found.torteSlot] == expected, label)
  end
end

-- Regression: a weaker torte in slot zero must not replace White-Gold.
inventory = { [0] = 171323, [4] = 171432, [6] = 171329 }
expectItem(171432, "Default must keep White-Gold even with Colovian in slot zero")
checkBounds = true

-- Literal expectations independently describe each of the six menu choices.
local cases = {
  { priority = 1, first = 171432, second = 171329, third = 171323 },
  { priority = 2, first = 171432, second = 171323, third = 171329 },
  { priority = 3, first = 171329, second = 171432, third = 171323 },
  { priority = 4, first = 171329, second = 171323, third = 171432 },
  { priority = 5, first = 171323, second = 171432, third = 171329 },
  { priority = 6, first = 171323, second = 171329, third = 171432 },
}
for _, case in ipairs(cases) do
  TorteMe.sv.Torte.tortePriority = case.priority
  for slot = 0, 2 do
    inventory = { [slot] = case.third, [3] = case.second, [7] = case.first }
    expectItem(case.first, "First choice must win for priority " .. case.priority)
  end
  inventory = { [0] = case.third, [7] = case.second }
  expectItem(case.second, "Missing first choice must fall back to second")
  inventory = { [7] = case.third }
  expectItem(case.third, "Missing first two must fall back to third")
  inventory = {}
  expectItem(nil, "Empty backpack must report no tortes")
end

inventory = { [0] = 171329, [7] = 171432 }
for _, invalid in ipairs({ 0, 7, "bad" }) do
  TorteMe.sv.Torte.tortePriority = invalid
  expectItem(171432, "Invalid saved priority must use strongest-first")
end
TorteMe.sv.Torte.tortePriority = nil
expectItem(171432, "Existing characters without a priority must use strongest-first")
bagSize = 0
inventory = {}
expectItem(nil, "Zero-sized backpack must not query a slot")
bagSize = 8

-- Exercise the actual settings callbacks and their effect on inventory selection.
local options
LibAddonMenu2 = {
  RegisterAddonPanel = function() return {} end,
  RegisterOptionControls = function(_, _, controls) options = controls end,
}
TorteMe:CreateSettingsWindow()
local dropdown
for _, option in ipairs(options) do
  if option.reference == "TORTE_ME_TORTE_PRIORITY" then dropdown = option end
end
assert(dropdown and #dropdown.choices == 6, "Settings must offer all six orders")
assert(dropdown.getFunc() == 1, "Missing saved setting must display strongest-first")
local reminders = 0
function TorteMe:TorteBuffReminderLoop() reminders = reminders + 1 end
inventory = { [0] = 171432, [4] = 171329, [7] = 171323 }
for _, case in ipairs(cases) do
  dropdown.setFunc(dropdown.choicesValues[case.priority])
  assert(dropdown.getFunc() == case.priority, "Selected order must be stored and displayed")
  expectItem(case.first, "Settings choice must control the actual selected torte")
end
assert(reminders == 6, "Changing priority must refresh the reminder loop")
dropdown.setFunc(dropdown.default)
expectItem(171432, "Resetting priority must restore strongest-first")
TorteMe.sv.Torte.enableTortes = false
assert(dropdown.disabled(), "Priority control must disable when torte tracking is disabled")
print("PASS: strongest-first regression, six orders, fallbacks, backpack bounds and settings integration")
