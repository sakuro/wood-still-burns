local WoodenItems = require("lib.wooden_items")

-- Registered like any other mod's items, so the built-in ones exercise the same path.
data:extend({
  {
    type = "mod-data",
    name = "wood-still-burns",
    data_type = WoodenItems.DATA_TYPE,
    data = { items = { "wooden-chest", "small-electric-pole" } },
  },
})
