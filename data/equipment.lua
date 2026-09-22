-- Stock ox_inventory firearms, ammo, and harvest tools sold at Rebel Outfitters.
-- Keys match ox_inventory item names. Lodge NUI icons live in html/images
-- (copied from ox_inventory/web/images, plus generated custom / missing icons).

Config.Images = {
    folder = 'html/images',
    oxResource = 'ox_inventory',
    oxFolder = 'web/images',
}

Config.CustomItemImages = {
    hunting_license = true,
    hunting_axe = true,
    animal_meat = true,
    animal_leather = true,
    animal_bones = true,
    trophy_antler = true,
    trophy_fang = true,
    trophy_pelt = true,
    -- ox_inventory ships no web/images for these DLC rifles
    WEAPON_TACTICALRIFLE = true,
    WEAPON_BATTLERIFLE = true,
}

function Config.ItemImage(itemName)
    if type(itemName) ~= 'string' or itemName == '' then return nil end
    return ('images/%s.png'):format(itemName)
end

function Config.OxInventoryImage(itemName)
    if type(itemName) ~= 'string' or itemName == '' then return nil end
    return ('nui://%s/%s/%s.png'):format(Config.Images.oxResource, Config.Images.oxFolder, itemName)
end

local function add(list, name, data)
    data.item = data.item or name
    if data.weapon == true then
        data.weapon = name
    end
    data.image = data.image or Config.ItemImage(data.item)
    list[name] = data
end

local E = {}

----------------------------------------------------------------
-- Tools (custom axe + ox melee that can skin a carcass)
----------------------------------------------------------------
add(E, 'hunting_axe', {
    label = 'Skinning Axe',
    description = 'Rebel camp axe. Required to harvest leather, meat, and bone.',
    category = 'tools',
    price = 220,
    level = 1,
    weight = 900,
})
add(E, 'WEAPON_KNIFE', {
    label = 'Knife',
    description = 'Belt knife. Legal harvest tool on small game.',
    category = 'tools',
    price = 80,
    level = 1,
    weight = 300,
    weapon = true,
})
add(E, 'WEAPON_HATCHET', {
    label = 'Hatchet',
    description = 'Trail hatchet. Skins a carcass the same as the camp axe.',
    category = 'tools',
    price = 180,
    level = 1,
    weight = 1000,
    weapon = true,
})
add(E, 'WEAPON_MACHETE', {
    label = 'Machete',
    description = 'Brush blade. Works as a harvest tool in chaparral.',
    category = 'tools',
    price = 160,
    level = 3,
    weight = 1000,
    weapon = true,
})
add(E, 'WEAPON_STONE_HATCHET', {
    label = 'Stone Hatchet',
    description = 'Old stone head. Still legal for a Rebel harvest.',
    category = 'tools',
    price = 140,
    level = 7,
    weight = 800,
    weapon = true,
})
add(E, 'WEAPON_BATTLEAXE', {
    label = 'Battle Axe',
    description = 'Heavy camp axe. Fastest legal skinning tool on the board.',
    category = 'tools',
    price = 280,
    level = 7,
    weight = 6500,
    weapon = true,
})

----------------------------------------------------------------
-- Pistols
----------------------------------------------------------------
add(E, 'WEAPON_SNSPISTOL', {
    label = 'SNS Pistol',
    description = 'Pocket .45. Quiet starter sidearm for farm country.',
    category = 'pistols',
    price = 480,
    level = 1,
    weight = 465,
    weapon = true,
    ammo = 'ammo-45',
})
add(E, 'WEAPON_PISTOL', {
    label = 'Pistol',
    description = 'Standard 9mm. Legal on rabbits, birds, and farm stock.',
    category = 'pistols',
    price = 650,
    level = 1,
    weight = 1130,
    weapon = true,
    ammo = 'ammo-9',
})
add(E, 'WEAPON_COMBATPISTOL', {
    label = 'Combat Pistol',
    description = 'Compact 9mm. Cleaner follow-up shots in brush.',
    category = 'pistols',
    price = 780,
    level = 1,
    weight = 785,
    weapon = true,
    ammo = 'ammo-9',
})
add(E, 'WEAPON_VINTAGEPISTOL', {
    label = 'Vintage Pistol',
    description = 'Old Rebel 9mm. Slow, honest, still legal.',
    category = 'pistols',
    price = 720,
    level = 1,
    weight = 700,
    weapon = true,
    ammo = 'ammo-9',
})
add(E, 'WEAPON_HEAVYPISTOL', {
    label = 'Heavy Pistol',
    description = '.45 sidearm with more punch on pigs and coyote.',
    category = 'pistols',
    price = 1100,
    level = 2,
    weight = 1100,
    weapon = true,
    ammo = 'ammo-45',
})
add(E, 'WEAPON_CERAMICPISTOL', {
    label = 'Ceramic Pistol',
    description = 'Light 9mm. Easy to carry on long walks.',
    category = 'pistols',
    price = 980,
    level = 2,
    weight = 800,
    weapon = true,
    ammo = 'ammo-9',
})
add(E, 'WEAPON_DOUBLEACTION', {
    label = 'Double Action Revolver',
    description = '.38 wheelgun. Classic trail pistol.',
    category = 'pistols',
    price = 1250,
    level = 2,
    weight = 940,
    weapon = true,
    ammo = 'ammo-38',
})
add(E, 'WEAPON_PISTOLXM3', {
    label = 'WM 29 Pistol',
    description = 'Modern 9mm. Tight groups on small game.',
    category = 'pistols',
    price = 1350,
    level = 2,
    weight = 969,
    weapon = true,
    ammo = 'ammo-9',
})
add(E, 'WEAPON_APPISTOL', {
    label = 'AP Pistol',
    description = 'Full-auto 9mm. Burns ammo. Legal if you stay licensed.',
    category = 'pistols',
    price = 2100,
    level = 3,
    weight = 1400,
    weapon = true,
    ammo = 'ammo-9',
})
add(E, 'WEAPON_PISTOL50', {
    label = 'Pistol .50',
    description = 'Heavy desert pistol. Stops a boar at close range.',
    category = 'pistols',
    price = 2400,
    level = 3,
    weight = 2000,
    weapon = true,
    ammo = 'ammo-50',
})
add(E, 'WEAPON_REVOLVER', {
    label = 'Revolver',
    description = '.44 Magnum. Senora and canyon work.',
    category = 'pistols',
    price = 1850,
    level = 3,
    weight = 2260,
    weapon = true,
    ammo = 'ammo-44',
})
add(E, 'WEAPON_MARKSMANPISTOL', {
    label = 'Marksman Pistol',
    description = 'Single-shot .22. Precision small-game pistol.',
    category = 'pistols',
    price = 1600,
    level = 3,
    weight = 1588,
    weapon = true,
    ammo = 'ammo-22',
})
add(E, 'WEAPON_PISTOL_MK2', {
    label = 'Pistol MK2',
    description = 'Refined 9mm. Better glass, same legal take.',
    category = 'pistols',
    price = 2800,
    level = 5,
    weight = 1000,
    weapon = true,
    ammo = 'ammo-9',
})
add(E, 'WEAPON_SNSPISTOL_MK2', {
    label = 'SNS Pistol MK2',
    description = 'Tuned pocket .45. Light for ridge walks.',
    category = 'pistols',
    price = 2200,
    level = 5,
    weight = 465,
    weapon = true,
    ammo = 'ammo-45',
})
add(E, 'WEAPON_GADGETPISTOL', {
    label = 'Perico Pistol',
    description = 'Heavy 9mm single-stack. Hard-hitting close work.',
    category = 'pistols',
    price = 3200,
    level = 5,
    weight = 1750,
    weapon = true,
    ammo = 'ammo-9',
})
add(E, 'WEAPON_NAVYREVOLVER', {
    label = 'Navy Revolver',
    description = 'Antique .44. Slow cylinder, serious punch.',
    category = 'pistols',
    price = 2600,
    level = 5,
    weight = 4000,
    weapon = true,
    ammo = 'ammo-44',
})
add(E, 'WEAPON_REVOLVER_MK2', {
    label = 'Revolver MK2',
    description = 'Apex wheelgun. Summit kit if you hunt close.',
    category = 'pistols',
    price = 3800,
    level = 10,
    weight = 2600,
    weapon = true,
    ammo = 'ammo-44',
})

----------------------------------------------------------------
-- SMGs
----------------------------------------------------------------
add(E, 'WEAPON_MINISMG', {
    label = 'Mini SMG',
    description = 'Compact 9mm. Fast follow-ups in timber.',
    category = 'smgs',
    price = 1650,
    level = 2,
    weight = 1270,
    weapon = true,
    ammo = 'ammo-9',
})
add(E, 'WEAPON_MACHINEPISTOL', {
    label = 'Machine Pistol',
    description = 'Spray 9mm. Keep it legal and walk after the take.',
    category = 'smgs',
    price = 1450,
    level = 2,
    weight = 1400,
    weapon = true,
    ammo = 'ammo-9',
})
add(E, 'WEAPON_MICROSMG', {
    label = 'Micro SMG',
    description = '.45 compact. Brush country sidearm.',
    category = 'smgs',
    price = 2100,
    level = 3,
    weight = 3000,
    weapon = true,
    ammo = 'ammo-45',
})
add(E, 'WEAPON_SMG', {
    label = 'SMG',
    description = 'Service 9mm. Mid-woods workhorse.',
    category = 'smgs',
    price = 2400,
    level = 3,
    weight = 3084,
    weapon = true,
    ammo = 'ammo-9',
})
add(E, 'WEAPON_TECPISTOL', {
    label = 'Tactical SMG',
    description = 'Modern 9mm PDW. Tight groups on moving game.',
    category = 'smgs',
    price = 2650,
    level = 4,
    weight = 1500,
    weapon = true,
    ammo = 'ammo-9',
})
add(E, 'WEAPON_COMBATPDW', {
    label = 'Combat PDW',
    description = 'Carbine-length 9mm. Good in Paleto timber.',
    category = 'smgs',
    price = 2800,
    level = 4,
    weight = 2300,
    weapon = true,
    ammo = 'ammo-9',
})
add(E, 'WEAPON_ASSAULTSMG', {
    label = 'Assault SMG',
    description = 'Rifle-caliber SMG. Opens deer country early.',
    category = 'smgs',
    price = 3100,
    level = 4,
    weight = 2900,
    weapon = true,
    ammo = 'ammo-rifle',
})
add(E, 'WEAPON_SMG_MK2', {
    label = 'SMG MK2',
    description = 'Tuned 9mm. Ridge walks and cat country.',
    category = 'smgs',
    price = 4200,
    level = 7,
    weight = 2700,
    weapon = true,
    ammo = 'ammo-9',
})

----------------------------------------------------------------
-- Shotguns
----------------------------------------------------------------
add(E, 'WEAPON_MUSKET', {
    label = 'Musket',
    description = 'Old Rebel trail gun. Legal on rabbits, birds, and farm stock.',
    category = 'shotguns',
    price = 850,
    level = 1,
    weight = 4500,
    weapon = true,
    ammo = 'ammo-musket',
})
add(E, 'WEAPON_SAWNOFFSHOTGUN', {
    label = 'Sawn Off Shotgun',
    description = 'Short 12ga. Close brush and hogs.',
    category = 'shotguns',
    price = 1400,
    level = 3,
    weight = 2380,
    weapon = true,
    ammo = 'ammo-shotgun',
})
add(E, 'WEAPON_DBSHOTGUN', {
    label = 'Double Barrel Shotgun',
    description = 'Two barrels. Honest farm and chaparral gun.',
    category = 'shotguns',
    price = 1550,
    level = 3,
    weight = 3175,
    weapon = true,
    ammo = 'ammo-shotgun',
})
add(E, 'WEAPON_PUMPSHOTGUN', {
    label = 'Pump Shotgun',
    description = 'Chaparral 12ga. Pigs, boar, and coyote.',
    category = 'shotguns',
    price = 1850,
    level = 3,
    weight = 3400,
    weapon = true,
    ammo = 'ammo-shotgun',
})
add(E, 'WEAPON_BULLPUPSHOTGUN', {
    label = 'Bullpup Shotgun',
    description = 'Compact 12ga. Tight timber shots.',
    category = 'shotguns',
    price = 2300,
    level = 4,
    weight = 3100,
    weapon = true,
    ammo = 'ammo-shotgun',
})
add(E, 'WEAPON_COMBATSHOTGUN', {
    label = 'Combat Shotgun',
    description = 'Semi 12ga. Fast follow-ups on charging boar.',
    category = 'shotguns',
    price = 2600,
    level = 4,
    weight = 4400,
    weapon = true,
    ammo = 'ammo-shotgun',
})
add(E, 'WEAPON_AUTOSHOTGUN', {
    label = 'Sweeper Shotgun',
    description = 'Auto 12ga. Burns shells. Walk after the harvest.',
    category = 'shotguns',
    price = 2750,
    level = 4,
    weight = 4400,
    weapon = true,
    ammo = 'ammo-shotgun',
})
add(E, 'WEAPON_HEAVYSHOTGUN', {
    label = 'Heavy Shotgun',
    description = 'Box-fed 12ga. Thick hide country.',
    category = 'shotguns',
    price = 3200,
    level = 5,
    weight = 3600,
    weapon = true,
    ammo = 'ammo-shotgun',
})
add(E, 'WEAPON_ASSAULTSHOTGUN', {
    label = 'Assault Shotgun',
    description = 'Full-auto 12ga. Legal only with a Rebel license.',
    category = 'shotguns',
    price = 3400,
    level = 5,
    weight = 5200,
    weapon = true,
    ammo = 'ammo-shotgun',
})
add(E, 'WEAPON_PUMPSHOTGUN_MK2', {
    label = 'Pump Shotgun MK2',
    description = 'Tuned pump. Deer and canyon work.',
    category = 'shotguns',
    price = 3900,
    level = 6,
    weight = 3200,
    weapon = true,
    ammo = 'ammo-shotgun',
})

----------------------------------------------------------------
-- Rifles + LMGs
----------------------------------------------------------------
add(E, 'WEAPON_COMPACTRIFLE', {
    label = 'Compact Rifle',
    description = 'Short 7.62. First real woods rifle.',
    category = 'rifles',
    price = 2800,
    level = 4,
    weight = 3600,
    weapon = true,
    ammo = 'ammo-rifle2',
})
add(E, 'WEAPON_ASSAULTRIFLE', {
    label = 'Assault Rifle',
    description = '7.62 service rifle. Mid-country workhorse.',
    category = 'rifles',
    price = 3600,
    level = 5,
    weight = 4500,
    weapon = true,
    ammo = 'ammo-rifle2',
})
add(E, 'WEAPON_CARBINERIFLE', {
    label = 'Carbine Rifle',
    description = '5.56 carbine. Senora and canyon glass.',
    category = 'rifles',
    price = 3800,
    level = 5,
    weight = 3100,
    weapon = true,
    ammo = 'ammo-rifle',
})
add(E, 'WEAPON_ADVANCEDRIFLE', {
    label = 'Advanced Rifle',
    description = 'Bullpup 5.56. Fast handling in timber.',
    category = 'rifles',
    price = 4100,
    level = 5,
    weight = 3100,
    weapon = true,
    ammo = 'ammo-rifle',
})
add(E, 'WEAPON_GUSENBERG', {
    label = 'Gusenberg',
    description = '.45 drum. Old-school brush sweeper.',
    category = 'rifles',
    price = 4800,
    level = 5,
    weight = 4900,
    weapon = true,
    ammo = 'ammo-45',
})
add(E, 'WEAPON_SPECIALCARBINE', {
    label = 'Special Carbine',
    description = '5.56 all-rounder. Opens deer country.',
    category = 'rifles',
    price = 4300,
    level = 6,
    weight = 3000,
    weapon = true,
    ammo = 'ammo-rifle',
})
add(E, 'WEAPON_BULLPUPRIFLE', {
    label = 'Bullpup Rifle',
    description = 'Compact 5.56. Tight canyon shots.',
    category = 'rifles',
    price = 4000,
    level = 6,
    weight = 2900,
    weapon = true,
    ammo = 'ammo-rifle',
})
add(E, 'WEAPON_MILITARYRIFLE', {
    label = 'Military Rifle',
    description = 'Service 5.56. Steady on a ridge.',
    category = 'rifles',
    price = 4500,
    level = 6,
    weight = 3600,
    weapon = true,
    ammo = 'ammo-rifle',
})
add(E, 'WEAPON_TACTICALRIFLE', {
    label = 'Tactical Rifle',
    description = 'Long 5.56. Glass a line, do not camp it.',
    category = 'rifles',
    price = 4800,
    level = 7,
    weight = 3400,
    weapon = true,
    ammo = 'ammo-rifle',
})
add(E, 'WEAPON_BATTLERIFLE', {
    label = 'Battle Rifle',
    description = 'Heavy 7.62. Mountain lion country.',
    category = 'rifles',
    price = 5200,
    level = 7,
    weight = 3300,
    weapon = true,
    ammo = 'ammo-rifle2',
})
add(E, 'WEAPON_HEAVYRIFLE', {
    label = 'Heavy Rifle',
    description = 'Hard-hitting 5.56. Cat country rifle.',
    category = 'rifles',
    price = 5400,
    level = 7,
    weight = 3300,
    weapon = true,
    ammo = 'ammo-rifle',
})
add(E, 'WEAPON_MG', {
    label = 'Machine Gun',
    description = 'Sustained 7.62. Legal only with papers. Walk after.',
    category = 'rifles',
    price = 7200,
    level = 8,
    weight = 9000,
    weapon = true,
    ammo = 'ammo-rifle2',
})
add(E, 'WEAPON_ASSAULTRIFLE_MK2', {
    label = 'Assault Rifle MK2',
    description = 'Tuned 7.62. High-country workhorse.',
    category = 'rifles',
    price = 6200,
    level = 8,
    weight = 2950,
    weapon = true,
    ammo = 'ammo-rifle2',
})
add(E, 'WEAPON_CARBINERIFLE_MK2', {
    label = 'Carbine Rifle MK2',
    description = 'Tuned 5.56. Precision ridge rifle.',
    category = 'rifles',
    price = 6400,
    level = 8,
    weight = 3000,
    weapon = true,
    ammo = 'ammo-rifle',
})
add(E, 'WEAPON_SPECIALCARBINE_MK2', {
    label = 'Special Carbine MK2',
    description = 'Apex 5.56 carbine. Summit kit.',
    category = 'rifles',
    price = 6600,
    level = 8,
    weight = 3370,
    weapon = true,
    ammo = 'ammo-rifle',
})
add(E, 'WEAPON_BULLPUPRIFLE_MK2', {
    label = 'Bullpup Rifle MK2',
    description = 'Tuned bullpup. Tight timber at rank nine.',
    category = 'rifles',
    price = 6800,
    level = 9,
    weight = 2900,
    weapon = true,
    ammo = 'ammo-rifle',
})
add(E, 'WEAPON_COMBATMG', {
    label = 'Combat MG',
    description = 'Belt 5.56. Heavy and loud. Still a legal hunting gun.',
    category = 'rifles',
    price = 8800,
    level = 9,
    weight = 7500,
    weapon = true,
    ammo = 'ammo-rifle',
})
add(E, 'WEAPON_COMBATMG_MK2', {
    label = 'Combat MG MK2',
    description = 'Apex machine gun. Panther country only if you stay moving.',
    category = 'rifles',
    price = 11000,
    level = 10,
    weight = 8000,
    weapon = true,
    ammo = 'ammo-rifle2',
})

----------------------------------------------------------------
-- Snipers
----------------------------------------------------------------
add(E, 'WEAPON_MARKSMANRIFLE', {
    label = 'Marksman Rifle',
    description = 'Semi 7.62. Opens deer and canyon game.',
    category = 'snipers',
    price = 4200,
    level = 6,
    weight = 7500,
    weapon = true,
    ammo = 'ammo-sniper',
})
add(E, 'WEAPON_PRECISIONRIFLE', {
    label = 'Precision Rifle',
    description = 'Bolt 7.62. One clean shot, then walk.',
    category = 'snipers',
    price = 7200,
    level = 7,
    weight = 4800,
    weapon = true,
    ammo = 'ammo-sniper',
})
add(E, 'WEAPON_SNIPERRIFLE', {
    label = 'Sniper Rifle',
    description = 'Long glass for mountain lion country.',
    category = 'snipers',
    price = 7800,
    level = 7,
    weight = 5000,
    weapon = true,
    ammo = 'ammo-sniper',
})
add(E, 'WEAPON_MARKSMANRIFLE_MK2', {
    label = 'Marksman Rifle MK2',
    description = 'Tuned marksman. Cat country glass.',
    category = 'snipers',
    price = 9200,
    level = 8,
    weight = 4000,
    weapon = true,
    ammo = 'ammo-sniper',
})
add(E, 'WEAPON_HEAVYSNIPER', {
    label = 'Heavy Sniper',
    description = '.50 BMG. Top-end hunting rifle for panther country.',
    category = 'snipers',
    price = 14500,
    level = 9,
    weight = 12700,
    weapon = true,
    ammo = 'ammo-heavysniper',
})
add(E, 'WEAPON_HEAVYSNIPER_MK2', {
    label = 'Heavy Sniper MK2',
    description = 'Apex .50. Highest Rebel glass on the mountain.',
    category = 'snipers',
    price = 18500,
    level = 10,
    weight = 14000,
    weapon = true,
    ammo = 'ammo-heavysniper',
})

----------------------------------------------------------------
-- Ammo (ox_inventory ammo-* items)
----------------------------------------------------------------
add(E, 'ammo-9', {
    label = '9mm',
    description = 'Pistol and SMG ammunition.',
    category = 'ammo',
    price = 12,
    level = 1,
    amount = 24,
    weight = 7,
})
add(E, 'ammo-45', {
    label = '.45 ACP',
    description = 'SNS, heavy pistol, Micro SMG, Gusenberg.',
    category = 'ammo',
    price = 13,
    level = 1,
    amount = 24,
    weight = 15,
})
add(E, 'ammo-musket', {
    label = '.50 Ball',
    description = 'Paper loads for the Musket.',
    category = 'ammo',
    price = 8,
    level = 1,
    amount = 10,
    weight = 38,
})
add(E, 'ammo-38', {
    label = '.38 LC',
    description = 'Double-action revolver loads.',
    category = 'ammo',
    price = 14,
    level = 2,
    amount = 12,
    weight = 15,
})
add(E, 'ammo-22', {
    label = '.22 Long Rifle',
    description = 'Marksman pistol ammunition.',
    category = 'ammo',
    price = 10,
    level = 3,
    amount = 16,
    weight = 3,
})
add(E, 'ammo-44', {
    label = '.44 Magnum',
    description = 'Revolver and Navy loads.',
    category = 'ammo',
    price = 16,
    level = 3,
    amount = 12,
    weight = 16,
})
add(E, 'ammo-50', {
    label = '.50 AE',
    description = 'Pistol .50 ammunition.',
    category = 'ammo',
    price = 22,
    level = 3,
    amount = 12,
    weight = 45,
})
add(E, 'ammo-shotgun', {
    label = '12 Gauge',
    description = 'Buckshot for every lodge shotgun.',
    category = 'ammo',
    price = 14,
    level = 3,
    amount = 16,
    weight = 38,
})
add(E, 'ammo-rifle', {
    label = '5.56x45',
    description = 'Carbine and 5.56 rifle ammunition.',
    category = 'ammo',
    price = 16,
    level = 4,
    amount = 30,
    weight = 4,
})
add(E, 'ammo-rifle2', {
    label = '7.62x39',
    description = 'Assault rifle and battle rifle ammunition.',
    category = 'ammo',
    price = 18,
    level = 4,
    amount = 30,
    weight = 8,
})
add(E, 'ammo-sniper', {
    label = '7.62x51',
    description = 'Marksman and sniper ammunition.',
    category = 'ammo',
    price = 28,
    level = 6,
    amount = 12,
    weight = 9,
})
add(E, 'ammo-heavysniper', {
    label = '.50 BMG',
    description = 'Heavy sniper ammunition.',
    category = 'ammo',
    price = 35,
    level = 9,
    amount = 8,
    weight = 51,
})

Config.Equipment = E

-- Weapons that count as a legal hunting kill (hashes from Config.Equipment.weapon).
Config.HuntingWeapons = {}
for _, data in pairs(Config.Equipment) do
    if data.weapon then
        Config.HuntingWeapons[joaat(data.weapon)] = true
    end
end

local categoryOrder = {
    tools = 1,
    pistols = 2,
    smgs = 3,
    shotguns = 4,
    rifles = 5,
    snipers = 6,
    ammo = 7,
}

local order = {}
for name in pairs(Config.Equipment) do
    order[#order + 1] = name
end
table.sort(order, function(a, b)
    local da, db = Config.Equipment[a], Config.Equipment[b]
    local ca = categoryOrder[da.category] or 99
    local cb = categoryOrder[db.category] or 99
    if ca ~= cb then return ca < cb end
    if (da.level or 1) ~= (db.level or 1) then return (da.level or 1) < (db.level or 1) end
    if (da.price or 0) ~= (db.price or 0) then return (da.price or 0) < (db.price or 0) end
    return (da.label or a) < (db.label or b)
end)
Config.ShopCatalogOrder = order
