local FuelValue = {}

FuelValue.RECOVERY_RATE_SETTING = "wood-still-burns-energy-recovery-rate"

--- Converts a Factorio fuel value string such as "2MJ" to joules.
---
--- The conversion itself is the game's `util.parse_energy`, passed in so this module
--- stays loadable outside Factorio. That function also accepts power ("W") and
--- scales it to joules per tick, which is not a valid `fuel_value`, so only strings
--- ending in "J" are handed to it.
---@param energy string  e.g. "2MJ", "100kJ"
---@param parse_energy function  `util.parse_energy` from `__core__/lualib/util`
---@return number
function FuelValue.parse_fuel_value(energy, parse_energy)
  if type(energy) ~= "string" then
    error("energy must be a string, got " .. type(energy), 2)
  end
  if energy:sub(-1) ~= "J" then
    error("fuel value must be an energy in joules: " .. energy, 2)
  end
  return parse_energy(energy)
end

--- Tells whether an item prototype's `fuel_value` makes it burn.
---
--- An unset value and an explicit "0J" both mean the item does not burn, since zero is the
--- prototype default. Anything else was set on purpose by some mod and should be left alone.
---@param energy string|nil  the item's `fuel_value`, e.g. "3MJ"
---@param parse_energy function  `util.parse_energy` from `__core__/lualib/util`
---@return boolean
function FuelValue.has_fuel_value(energy, parse_energy)
  if energy == nil then
    return false
  end
  return FuelValue.parse_fuel_value(energy, parse_energy) > 0
end

--- Formats joules as a Factorio energy string.
---
--- Always uses plain joules so no precision is lost to a unit prefix.
---@param joules number
---@return string
function FuelValue.format_energy(joules)
  if type(joules) ~= "number" then
    error("joules must be a number, got " .. type(joules), 2)
  end
  return string.format("%.0fJ", joules)
end

--- Computes the fuel value of one crafted item, in joules.
---
--- The recovery rate is capped at 1 so that burning crafted items never yields more
--- energy than the wood spent on them.
---@param wood_joules number  fuel value of one wood
---@param wood_amount number  wood consumed by the recipe
---@param result_amount number  items produced by the recipe
---@param recovery_rate number  fraction of the wood's energy recovered, 0 to 1
---@return number
function FuelValue.compute(wood_joules, wood_amount, result_amount, recovery_rate)
  for name, value in pairs({
    wood_joules = wood_joules,
    wood_amount = wood_amount,
    result_amount = result_amount,
    recovery_rate = recovery_rate,
  }) do
    if type(value) ~= "number" then
      error(name .. " must be a number, got " .. type(value), 2)
    end
  end
  if result_amount <= 0 then
    error("result_amount must be positive", 2)
  end
  if recovery_rate < 0 or recovery_rate > 1 then
    error("recovery_rate must be between 0 and 1", 2)
  end
  return wood_joules * wood_amount / result_amount * recovery_rate
end

--- Reads how much wood a recipe consumes and how many of an item it yields.
---
--- Returns nil when the recipe cannot be reduced to plain amounts (no wood
--- ingredient, no such result, or a variable `amount_min`/`amount_max` or
--- `probability` result), so the caller can skip the item instead of guessing.
---@param recipe table  recipe prototype
---@param item_name string
---@return number|nil wood_amount
---@return number|nil result_amount
function FuelValue.wood_usage(recipe, item_name)
  local wood_amount
  for _, ingredient in ipairs(recipe.ingredients or {}) do
    if ingredient.type == "item" and ingredient.name == "wood" then
      wood_amount = ingredient.amount
    end
  end
  if wood_amount == nil then
    return nil, nil
  end
  for _, result in ipairs(recipe.results or {}) do
    if result.type == "item" and result.name == item_name then
      if result.amount == nil or (result.probability or 1) ~= 1 then
        return nil, nil
      end
      return wood_amount, result.amount
    end
  end
  return nil, nil
end

return FuelValue
