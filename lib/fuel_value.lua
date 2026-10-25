local FuelValue = {}

FuelValue.RECOVERY_RATE_SETTING = "wood-still-burns-energy-recovery-rate"

local UNIT_MULTIPLIERS = {
  [""] = 1,
  k = 1e3,
  M = 1e6,
  G = 1e9,
  T = 1e12,
  P = 1e15,
  E = 1e18,
  Z = 1e21,
  Y = 1e24,
}

--- Converts a Factorio energy string such as "2MJ" to joules.
---
--- Prototypes express `fuel_value` as a string with an SI prefix, so the arithmetic
--- has to go through a plain number first.
---@param energy string  e.g. "2MJ", "100kJ", "1.5MJ"
---@return number
function FuelValue.parse_energy(energy)
  if type(energy) ~= "string" then
    error("energy must be a string, got " .. type(energy), 2)
  end
  local amount, prefix = energy:match("^(%d+%.?%d*)([kMGTPEZY]?)J$")
  if amount == nil then
    error("invalid energy string: " .. energy, 2)
  end
  return tonumber(amount) * UNIT_MULTIPLIERS[prefix]
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
