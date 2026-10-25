local WoodenItems = require("lib.wooden_items")

local function registration(items, data_type)
  return {
    type = "mod-data",
    data_type = data_type or WoodenItems.DATA_TYPE,
    data = { items = items },
  }
end

describe("WoodenItems", function()
  describe("collect", function()
    local warnings
    local function warn(message)
      table.insert(warnings, message)
    end

    before_each(function()
      warnings = {}
    end)

    it("returns an empty list when there is no mod-data", function()
      assert.are.same({}, WoodenItems.collect(nil, warn))
    end)

    it("collects items from several registrants in registrant-name order", function()
      local mod_data = {
        ["b-mod"] = registration({ "b-item" }),
        ["a-mod"] = registration({ "a-item-1", "a-item-2" }),
      }
      assert.are.same({ "a-item-1", "a-item-2", "b-item" }, WoodenItems.collect(mod_data, warn))
      assert.are.same({}, warnings)
    end)

    it("removes duplicates across registrants", function()
      local mod_data = {
        ["a-mod"] = registration({ "shared", "a-item" }),
        ["b-mod"] = registration({ "shared" }),
      }
      assert.are.same({ "shared", "a-item" }, WoodenItems.collect(mod_data, warn))
    end)

    it("ignores mod-data of other data types", function()
      local mod_data = {
        ["a-mod"] = registration({ "a-item" }, "other.thing"),
        ["no-type"] = { type = "mod-data", data = { items = { "x" } } },
      }
      assert.are.same({}, WoodenItems.collect(mod_data, warn))
      assert.are.same({}, warnings)
    end)

    it("ignores and logs a registration whose items is not a table", function()
      local mod_data = { ["a-mod"] = registration("a-item") }
      assert.are.same({}, WoodenItems.collect(mod_data, warn))
      assert.are.equal(1, #warnings)
      assert.is_truthy(warnings[1]:find("a-mod", 1, true))
    end)

    it("ignores and logs a registration whose items is not an array", function()
      local mod_data = { ["a-mod"] = registration({ chest = "a-item" }) }
      assert.are.same({}, WoodenItems.collect(mod_data, warn))
      assert.are.equal(1, #warnings)
    end)

    it("ignores and logs a registration without items", function()
      local mod_data = { ["a-mod"] = { type = "mod-data", data_type = WoodenItems.DATA_TYPE, data = {} } }
      assert.are.same({}, WoodenItems.collect(mod_data, warn))
      assert.are.equal(1, #warnings)
    end)

    it("skips and logs non-string elements but keeps the valid ones", function()
      local mod_data = { ["a-mod"] = registration({ "ok", 42, "also-ok" }) }
      assert.are.same({ "ok", "also-ok" }, WoodenItems.collect(mod_data, warn))
      assert.are.equal(1, #warnings)
    end)
  end)

  describe("find_item", function()
    local item_types = { item = 0, tool = 0, ammo = 0 }
    local chest = { type = "item", name = "wooden-chest" }
    local card = { type = "tool", name = "example-science-card" }
    local raw = {
      item = { ["wooden-chest"] = chest },
      tool = { ["example-science-card"] = card },
      recipe = { ["wooden-chest"] = {} },
    }

    it("finds an item of type item", function()
      assert.are.equal(chest, WoodenItems.find_item(raw, "wooden-chest", item_types))
    end)

    it("finds an item of another item-derived type", function()
      assert.are.equal(card, WoodenItems.find_item(raw, "example-science-card", item_types))
    end)

    it("does not look in non-item prototype types", function()
      assert.is_nil(WoodenItems.find_item({ recipe = { ["only-a-recipe"] = {} } }, "only-a-recipe", item_types))
    end)

    it("returns nil for an unknown name", function()
      assert.is_nil(WoodenItems.find_item(raw, "missing", item_types))
    end)
  end)
end)
