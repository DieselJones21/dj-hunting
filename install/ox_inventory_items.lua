-- Paste these entries inside ox_inventory/data/items.lua
-- (inside the existing `return { ... }` table, before the closing `}`).
--
-- Guns sold by Rebel Outfitters use stock ox_inventory weapon items:
--   WEAPON_MUSKET, WEAPON_PUMPSHOTGUN, WEAPON_MARKSMANRIFLE,
--   WEAPON_SNIPERRIFLE, WEAPON_HEAVYSNIPER
-- and ammo:
--   ammo-musket, ammo-shotgun, ammo-rifle, ammo-sniper
--
-- To use custom spawn names, change `weapon` and `item` on each gun in
-- config.lua, then make sure that weapon item exists in ox_inventory.

return {
    ['hunting_license'] = {
        label = 'Rebel Hunting License',
        weight = 10,
        stack = false,
        close = true,
        consume = 0,
        description = 'Issued by Rebel Ranger Lodge. Required to buy hunting gear and harvest game.',
    },
    ['hunting_axe'] = {
        label = 'Skinning Axe',
        weight = 900,
        stack = false,
        close = true,
        consume = 0,
        description = 'Short camp axe. Required to harvest leather, meat, and bone.',
    },
    ['animal_meat'] = {
        label = 'Game Meat',
        weight = 180,
        stack = true,
        close = false,
        description = 'Cleaned cuts from a legal Rebel harvest.',
    },
    ['animal_leather'] = {
        label = 'Hide',
        weight = 220,
        stack = true,
        close = false,
        description = 'Salted hide for the tannery.',
    },
    ['animal_bones'] = {
        label = 'Bones',
        weight = 140,
        stack = true,
        close = false,
        description = 'Clean bone for crafts and stock.',
    },
    ['trophy_antler'] = {
        label = 'Trophy Antler',
        weight = 400,
        stack = true,
        close = false,
        description = 'A heavy rack. Lodge wall money.',
    },
    ['trophy_fang'] = {
        label = 'Predator Fang',
        weight = 80,
        stack = true,
        close = false,
        description = 'Taken from a legal mountain cat.',
    },
    ['trophy_pelt'] = {
        label = 'Rebel Pelt',
        weight = 650,
        stack = true,
        close = false,
        description = 'Apex hide. Highest payout in the woods.',
    },
}
