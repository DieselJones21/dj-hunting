-- Paste these entries inside ox_inventory/data/items.lua
-- (inside the existing `return { ... }` table, before the closing `}`).
--
-- Guns and ammo sold by Rebel Outfitters are stock ox_inventory items
-- (every base GTA firearm in data/weapons.lua that uses regular ammo,
-- plus ammo-9 / 22 / 38 / 44 / 45 / 50 / rifle / rifle2 / shotgun /
-- sniper / heavysniper / musket). Those already ship with ox_inventory.
--
-- Copy PNGs from install/inventory_images/ into ox_inventory/web/images/
-- so the inventory UI can show the generated hunting items (and the two
-- DLC rifles ox_inventory does not ship icons for).
-- Lodge NUI icons already live in this resource at html/images/.

return {
    ['hunting_license'] = {
        label = 'Rebel Hunting License',
        weight = 10,
        stack = false,
        close = true,
        consume = 0,
        description = 'Issued by Rebel Ranger Lodge. Required to buy hunting gear and harvest game.',
        client = { image = 'hunting_license.png' },
    },
    ['hunting_axe'] = {
        label = 'Skinning Axe',
        weight = 900,
        stack = false,
        close = true,
        consume = 0,
        description = 'Short camp axe. Required to harvest leather, meat, and bone.',
        client = { image = 'hunting_axe.png' },
    },
    ['animal_meat'] = {
        label = 'Game Meat',
        weight = 180,
        stack = true,
        close = false,
        description = 'Cleaned cuts from a legal Rebel harvest.',
        client = { image = 'animal_meat.png' },
    },
    ['animal_leather'] = {
        label = 'Hide',
        weight = 220,
        stack = true,
        close = false,
        description = 'Salted hide for the tannery.',
        client = { image = 'animal_leather.png' },
    },
    ['animal_bones'] = {
        label = 'Bones',
        weight = 140,
        stack = true,
        close = false,
        description = 'Clean bone for crafts and stock.',
        client = { image = 'animal_bones.png' },
    },
    ['trophy_antler'] = {
        label = 'Trophy Antler',
        weight = 400,
        stack = true,
        close = false,
        description = 'A heavy rack. Lodge wall money.',
        client = { image = 'trophy_antler.png' },
    },
    ['trophy_fang'] = {
        label = 'Predator Fang',
        weight = 80,
        stack = true,
        close = false,
        description = 'Taken from a legal mountain cat.',
        client = { image = 'trophy_fang.png' },
    },
    ['trophy_pelt'] = {
        label = 'Rebel Pelt',
        weight = 650,
        stack = true,
        close = false,
        description = 'Apex hide. Highest payout in the woods.',
        client = { image = 'trophy_pelt.png' },
    },
}
