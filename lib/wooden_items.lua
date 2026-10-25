local WoodenItems = {}

--- `data_type` of the `mod-data` prototypes that register wooden items.
WoodenItems.DATA_TYPE = "wood-still-burns.items"

local function is_array(value)
  if type(value) ~= "table" then
    return false
  end
  local count = 0
  for _ in pairs(value) do
    count = count + 1
  end
  return count == #value
end

--- Collects the item names registered through `mod-data` prototypes.
---
--- Malformed registrations are reported through `warn` and left out rather than
--- raised, so one mod's mistake cannot stop every other mod from loading. Registrants
--- are visited in name order because `pairs` order is unspecified and the result
--- should not change between runs.
---@param mod_data table|nil  `data.raw["mod-data"]`: prototype name to prototype
---@param warn fun(message: string)
---@return string[] names  de-duplicated item names
function WoodenItems.collect(mod_data, warn)
  local registrants = {}
  for registrant, prototype in pairs(mod_data or {}) do
    if prototype.data_type == WoodenItems.DATA_TYPE then
      table.insert(registrants, registrant)
    end
  end
  table.sort(registrants)

  local names, seen = {}, {}
  for _, registrant in ipairs(registrants) do
    local items = mod_data[registrant].data and mod_data[registrant].data.items
    if not is_array(items) then
      warn("wood-still-burns: ignoring " .. registrant .. " (data.items must be an array of item names)")
    else
      for _, name in ipairs(items) do
        if type(name) ~= "string" then
          warn("wood-still-burns: ignoring a non-string item name in " .. registrant)
        elseif not seen[name] then
          seen[name] = true
          table.insert(names, name)
        end
      end
    end
  end
  return names
end

--- Finds an item prototype by name across every item-derived prototype type.
---
--- Items are not all `type = "item"`: tools (e.g. vanilla science packs), ammo, capsules and so
--- on live under their own types in `data.raw`. `defines.prototypes.item` lists them all.
---@param raw table  `data.raw`
---@param name string
---@param item_types table|nil  keys are item-derived type names; defaults to `defines.prototypes.item`
---@return table|nil prototype
function WoodenItems.find_item(raw, name, item_types)
  for type_name in pairs(item_types or defines.prototypes.item) do
    local prototypes = raw[type_name]
    if prototypes ~= nil and prototypes[name] ~= nil then
      return prototypes[name]
    end
  end
  return nil
end

return WoodenItems
