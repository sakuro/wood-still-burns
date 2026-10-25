local FuelValue = require("lib.fuel_value")

describe("FuelValue", function()
  describe("parse_energy", function()
    it("applies SI prefixes", function()
      assert.are.equal(2e6, FuelValue.parse_energy("2MJ"))
      assert.are.equal(100e3, FuelValue.parse_energy("100kJ"))
      assert.are.equal(1.5e6, FuelValue.parse_energy("1.5MJ"))
      assert.are.equal(30, FuelValue.parse_energy("30J"))
    end)

    it("rejects malformed strings", function()
      assert.has_error(function()
        FuelValue.parse_energy("2MW")
      end)
      assert.has_error(function()
        FuelValue.parse_energy("MJ")
      end)
    end)

    it("rejects non-strings", function()
      assert.has_error(function()
        FuelValue.parse_energy(2000000)
      end)
    end)
  end)

  describe("format_energy", function()
    it("writes plain joules", function()
      assert.are.equal("3000000J", FuelValue.format_energy(3e6))
      assert.are.equal("750000J", FuelValue.format_energy(0.75e6))
    end)
  end)

  describe("compute", function()
    local wood = 2e6

    it("recovers all energy at a rate of 1", function()
      assert.are.equal(4e6, FuelValue.compute(wood, 2, 1, 1)) -- wooden-chest
      assert.are.equal(1e6, FuelValue.compute(wood, 1, 2, 1)) -- small-electric-pole
    end)

    it("scales by the recovery rate", function()
      assert.are.equal(3e6, FuelValue.compute(wood, 2, 1, 0.75))
      assert.are.equal(0.75e6, FuelValue.compute(wood, 1, 2, 0.75))
    end)

    it("returns zero at a rate of 0", function()
      assert.are.equal(0, FuelValue.compute(wood, 2, 1, 0))
    end)

    it("rejects out-of-range rates", function()
      assert.has_error(function()
        FuelValue.compute(wood, 2, 1, 1.01)
      end)
      assert.has_error(function()
        FuelValue.compute(wood, 2, 1, -0.1)
      end)
    end)

    it("rejects non-numbers and empty results", function()
      assert.has_error(function()
        FuelValue.compute("2MJ", 2, 1, 1)
      end)
      assert.has_error(function()
        FuelValue.compute(wood, 2, 0, 1)
      end)
    end)
  end)

  describe("wood_usage", function()
    it("reads amounts from a recipe", function()
      local recipe = {
        ingredients = {
          { type = "item", name = "wood", amount = 1 },
          { type = "item", name = "copper-cable", amount = 2 },
        },
        results = { { type = "item", name = "small-electric-pole", amount = 2 } },
      }
      local wood_amount, result_amount = FuelValue.wood_usage(recipe, "small-electric-pole")
      assert.are.equal(1, wood_amount)
      assert.are.equal(2, result_amount)
    end)

    it("returns nil without a wood ingredient", function()
      local recipe = {
        ingredients = { { type = "item", name = "iron-plate", amount = 2 } },
        results = { { type = "item", name = "wooden-chest", amount = 1 } },
      }
      assert.is_nil(FuelValue.wood_usage(recipe, "wooden-chest"))
    end)

    it("returns nil for probabilistic or variable results", function()
      local ingredients = { { type = "item", name = "wood", amount = 2 } }
      local probabilistic = {
        ingredients = ingredients,
        results = { { type = "item", name = "wooden-chest", amount = 1, probability = 0.5 } },
      }
      local variable = {
        ingredients = ingredients,
        results = { { type = "item", name = "wooden-chest", amount_min = 1, amount_max = 2 } },
      }
      assert.is_nil(FuelValue.wood_usage(probabilistic, "wooden-chest"))
      assert.is_nil(FuelValue.wood_usage(variable, "wooden-chest"))
    end)
  end)
end)
