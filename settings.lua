local FuelValue = require("lib.fuel_value")

data:extend({
  {
    type = "double-setting",
    name = FuelValue.RECOVERY_RATE_SETTING,
    setting_type = "startup",
    default_value = 0.75,
    minimum_value = 0,
    maximum_value = 1,
    order = "a",
  },
})
