# Registering wooden items

Wood Still Burns derives a fuel value for items whose recipe uses wood. Other mods can add their own items to that set by declaring a `mod-data` prototype in the data stage. `fuel_value` is fixed in the data stage, so a runtime `remote` interface cannot do this.

## Registration

Example: a mod that makes Krastorio 2's basic tech card burnable.

```lua
data:extend({
  {
    type = "mod-data",
    name = "my-mod-wood-still-burns",
    data_type = "wood-still-burns.items",
    data = { items = { "kr-basic-tech-card" } },
  },
})
```

- `name` only has to be unique; use your mod's name.
- `data.items` is an array of item names. Any item-derived prototype type works (`item`, `tool`, `ammo`, ...).
- Without Wood Still Burns the prototype does nothing, so no dependency is required.

## How the value is derived

The fuel value is calculated at `data-final-fixes` from the item's own recipe (wood used / items crafted) and wood's fuel value, as described in the README. Changes other mods make to wood or to the recipe are followed. For example, Krastorio 2 lowers wood to 1.25MJ, and its `kr-basic-tech-card` (5 wood and 5 copper cable make 5 cards) then burns for about 0.94MJ at the default recovery rate.

An item is skipped, with a log entry, when it does not exist, when no recipe has the item's name, when that recipe has no wood ingredient, or when the recipe's result is variable or probabilistic. Malformed registrations are logged and ignored.

## Items that are not mainly wood

Only the wood in the recipe counts, whatever else it contains. The base game's `shotgun` (a `gun`; 5 wood among iron, gears and copper) can be registered and then burns for 7.5MJ at the default rate. This is not recommended: wood is not its main material, and the value says nothing about the rest.
