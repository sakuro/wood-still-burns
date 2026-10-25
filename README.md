# Wood Still Burns

[![Downloads](https://img.shields.io/badge/dynamic/json.svg?label=Downloads&url=https%3A%2F%2Fmods.factorio.com%2Fapi%2Fmods%2Fwood-still-burns&query=%24.downloads_count)](https://mods.factorio.com/mod/wood-still-burns)

Gives wooden chests and small electric poles a fuel value, derived from the wood in their recipes:

    wood fuel value x wood used in the recipe / items crafted x energy recovery rate

The values are calculated from the recipes and from wood's fuel value rather than hard-coded, so changes made by other mods to either are reflected.

The energy recovery rate is a startup setting (0 to 1, default 0.75); at 0 no fuel value is set. At the default rate a wooden chest burns for 3MJ and a small electric pole for 0.75MJ, the same values as WoodDoesBurn.

Generated from [sakuro/factorio-mod-scaffold](https://github.com/sakuro/factorio-mod-scaffold)
