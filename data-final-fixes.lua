local FuelValue = require("lib.fuel_value")
local WoodenItems = require("lib.wooden_items")
local util = require("util")

-- Runs at final-fixes so that other mods' changes to wood's fuel value, to these recipes and to
-- the registrations are taken into account.
local wood = data.raw.item["wood"]
local recovery_rate = settings.startup[FuelValue.RECOVERY_RATE_SETTING].value

if wood == nil or wood.fuel_value == nil then
  log("wood-still-burns: wood has no fuel value; nothing to do")
elseif recovery_rate > 0 then
  local wood_joules = FuelValue.parse_fuel_value(wood.fuel_value, util.parse_energy)
  for _, item_name in ipairs(WoodenItems.collect(data.raw["mod-data"], log)) do
    local item = WoodenItems.find_item(data.raw, item_name)
    local recipe = data.raw.recipe[item_name]
    local wood_amount, result_amount
    if recipe ~= nil then
      wood_amount, result_amount = FuelValue.wood_usage(recipe, item_name)
    end
    if item == nil or wood_amount == nil then
      log("wood-still-burns: skipping " .. item_name .. " (item or recipe not usable)")
    else
      item.fuel_categories = wood.fuel_categories
      item.fuel_value =
        FuelValue.format_energy(FuelValue.compute(wood_joules, wood_amount, result_amount, recovery_rate))
    end
  end
end
