Config = {}

-- 'auto' detects qbx_core, qb-core, then es_extended. Falls back to ox_inventory money item.
Config.Framework = 'auto'

Config.Money = {
    -- 'auto' uses framework cash when ESX/QB/Qbox is present, otherwise ox_inventory item.
    -- 'item' always uses ox_inventory (Config.Money.item).
    -- 'framework' always uses ESX/QB/Qbox account money.
    method = 'auto',
    item = 'money',
    account = 'cash', -- 'cash' or 'bank'
}

Config.Debug = false
Config.Command = 'hunt'
Config.ShopDistance = 3.0
Config.MaxBuyAmount = 50
Config.Brand = {
    name = 'Rebel Roleplay',
    short = 'Rebel',
    initials = 'RR',
    title = 'Rebel Hunting',
    role = 'Licensed hunter',
}

-- darktrovx/interact (resource name: interact)
Config.Interact = {
    distance = 8.0,
    interactDst = 2.0,
    offset = vec3(0.0, 0.0, 0.18),
}

----------------------------------------------------------------
-- License (must be bought from a ranger ped before shop purchases)
----------------------------------------------------------------
Config.License = {
    item = 'hunting_license',
    label = 'Rebel Hunting License',
    price = 450,
    replacePrice = 150, -- already licensed, replacing a lost card
    description = 'Issued by Rebel Ranger Lodge. Required to buy hunting gear and to harvest game.',
}

----------------------------------------------------------------
-- Level / XP
-- Start on rabbits and birds, work up to mountain lions and panthers.
----------------------------------------------------------------
Config.MaxLevel = 10
Config.LevelXP = {
    0,     -- 1
    120,   -- 2
    280,   -- 3
    500,   -- 4
    820,   -- 5
    1240,  -- 6
    1780,  -- 7
    2460,  -- 8
    3300,  -- 9
    4300,  -- 10
}

function Config.LevelFromXP(xp)
    xp = math.floor(tonumber(xp) or 0)
    local level = 1
    for i = Config.MaxLevel, 1, -1 do
        if xp >= (Config.LevelXP[i] or 0) then
            level = i
            break
        end
    end
    return level
end

function Config.XPForLevel(level)
    level = math.max(1, math.min(Config.MaxLevel, math.floor(tonumber(level) or 1)))
    return Config.LevelXP[level] or 0
end

function Config.XPToNext(xp)
    local level = Config.LevelFromXP(xp)
    if level >= Config.MaxLevel then
        return 0, Config.LevelXP[Config.MaxLevel], Config.LevelXP[Config.MaxLevel]
    end
    local current = Config.LevelXP[level]
    local nxt = Config.LevelXP[level + 1]
    return math.max(0, nxt - xp), current, nxt
end

----------------------------------------------------------------
-- Search / camp cooldown
-- You cannot sit in one spot and farm. After a harvest you must walk,
-- then wait, before the woods will show new game.
----------------------------------------------------------------
Config.Hunt = {
    requireLicense = true,
    requireZone = true,
    requireHuntingWeapon = true,
    maxActiveAnimals = 5,
    spawnRadius = { min = 38.0, max = 82.0 },
    despawnDistance = 145.0,
    -- After a harvest: wait this long AND walk this far from the carcass.
    searchCooldown = 28,      -- seconds
    walkDistance = 48.0,      -- meters from last harvest
    -- Standing still stops new spawns so players have to glass and move.
    stillTimeout = 14,        -- seconds without moving
    moveThreshold = 7.5,      -- meters that counts as "moved"
    harvestDistance = 2.4,
    harvestDuration = 7000,
    spawnInterval = 3500,
    predatorChance = 0.35,
    harvestAnim = { dict = 'amb@medic@standing@kneel@base', clip = 'base' },
}

-- Tools that can skin a carcass. hunting_axe plus stock ox melee sold at the lodge.
Config.HarvestTools = {
    'hunting_axe',
    'WEAPON_HATCHET',
    'WEAPON_BATTLEAXE',
    'WEAPON_STONE_HATCHET',
    'WEAPON_MACHETE',
    'WEAPON_KNIFE',
}

-- Store catalog (all base GTA ox_inventory firearms + ammo + harvest tools)
-- is defined in data/equipment.lua after this file loads.

----------------------------------------------------------------
-- Sellable harvest
----------------------------------------------------------------
Config.Materials = {
    animal_meat = {
        label = 'Game Meat',
        description = 'Cleaned cuts. Rebel kitchens pay by the pound.',
        sell = 22,
        weight = 180,
        image = 'images/animal_meat.png',
    },
    animal_leather = {
        label = 'Hide',
        description = 'Salted hide for the tannery.',
        sell = 34,
        weight = 220,
        image = 'images/animal_leather.png',
    },
    animal_bones = {
        label = 'Bones',
        description = 'Clean bone for crafts and stock.',
        sell = 14,
        weight = 140,
        image = 'images/animal_bones.png',
    },
    trophy_antler = {
        label = 'Trophy Antler',
        description = 'A heavy rack. Lodge wall money.',
        sell = 220,
        weight = 400,
        image = 'images/trophy_antler.png',
    },
    trophy_fang = {
        label = 'Predator Fang',
        description = 'Taken from a legal mountain cat.',
        sell = 310,
        weight = 80,
        image = 'images/trophy_fang.png',
    },
    trophy_pelt = {
        label = 'Rebel Pelt',
        description = 'Apex hide. Highest payout in the woods.',
        sell = 540,
        weight = 650,
        image = 'images/trophy_pelt.png',
    },
}

----------------------------------------------------------------
-- Animals (every huntable GTA land / air wildlife ped)
-- level = hunter rank required to harvest
-- xp = XP granted on a legal harvest
-- harvest = items given (server-authoritative)
----------------------------------------------------------------
Config.Animals = {
    rabbit = {
        label = 'Rabbit',
        model = `a_c_rabbit_01`,
        level = 1,
        xp = 18,
        rarity = 'common',
        zoneTypes = { farmland = true, brush = true, desert = true, forest = true, hills = true, canyon = true, wetland = true },
        description = 'Starter game. Fast, small, and everywhere the grass is short.',
        harvest = { animal_meat = 1, animal_leather = 1, animal_bones = 1 },
        aggressive = false,
        weight = 28,
    },
    hen = {
        label = 'Hen',
        model = `a_c_hen`,
        level = 1,
        xp = 14,
        rarity = 'common',
        zoneTypes = { farmland = true, wetland = true, forest = true },
        description = 'Farmyard bird. Easy meat if you stay legal.',
        harvest = { animal_meat = 1, animal_bones = 1 },
        aggressive = false,
        weight = 22,
    },
    pigeon = {
        label = 'Pigeon',
        model = `a_c_pigeon`,
        level = 1,
        xp = 12,
        rarity = 'common',
        zoneTypes = { farmland = true, wetland = true, hills = true },
        description = 'City and farm bird. Good for learning the glass.',
        harvest = { animal_meat = 1, animal_bones = 1 },
        aggressive = false,
        flying = true,
        weight = 18,
    },
    crow = {
        label = 'Crow',
        model = `a_c_crow`,
        level = 2,
        xp = 20,
        rarity = 'common',
        zoneTypes = { farmland = true, brush = true, desert = true, forest = true, hills = true, mountain = true, canyon = true },
        description = 'Watchful. Spooks other game if you camp.',
        harvest = { animal_meat = 1, animal_bones = 1 },
        aggressive = false,
        flying = true,
        weight = 20,
    },
    seagull = {
        label = 'Seagull',
        model = `a_c_seagull`,
        level = 2,
        xp = 18,
        rarity = 'common',
        zoneTypes = { wetland = true, desert = true, forest = true },
        description = 'Coastal and lake bird. Thin meat, still legal.',
        harvest = { animal_meat = 1, animal_bones = 1 },
        aggressive = false,
        flying = true,
        weight = 16,
    },
    cormorant = {
        label = 'Cormorant',
        model = `a_c_cormorant`,
        level = 2,
        xp = 24,
        rarity = 'uncommon',
        zoneTypes = { wetland = true, canyon = true, forest = true },
        description = 'Water bird along creeks and the Zancudo flats.',
        harvest = { animal_meat = 1, animal_leather = 1, animal_bones = 1 },
        aggressive = false,
        flying = true,
        weight = 14,
    },
    hawk = {
        label = 'Hawk',
        model = `a_c_chickenhawk`,
        level = 3,
        xp = 40,
        rarity = 'uncommon',
        zoneTypes = { brush = true, desert = true, canyon = true, mountain = true, hills = true },
        description = 'Thermal hunter. Harder shot, better XP.',
        harvest = { animal_meat = 1, animal_bones = 1, animal_leather = 1 },
        aggressive = false,
        flying = true,
        weight = 12,
    },
    pig = {
        label = 'Pig',
        model = `a_c_pig`,
        level = 3,
        xp = 48,
        rarity = 'uncommon',
        zoneTypes = { farmland = true, brush = true, wetland = true },
        description = 'Farm and chaparral hog. Thick hide, honest meat.',
        harvest = { animal_meat = 3, animal_leather = 2, animal_bones = 2 },
        aggressive = false,
        weight = 16,
    },
    cow = {
        label = 'Cow',
        model = `a_c_cow`,
        level = 4,
        xp = 55,
        rarity = 'uncommon',
        zoneTypes = { farmland = true },
        description = 'Grapeseed stock. Heavy harvest, still a legal take.',
        harvest = { animal_meat = 4, animal_leather = 3, animal_bones = 2 },
        aggressive = false,
        weight = 10,
    },
    boar = {
        label = 'Boar',
        model = `a_c_boar`,
        level = 4,
        xp = 70,
        rarity = 'uncommon',
        zoneTypes = { brush = true, forest = true, mountain = true, wetland = true, hills = true },
        description = 'Will charge if you crowd it. Solid mid-tier payday.',
        harvest = { animal_meat = 3, animal_leather = 3, animal_bones = 2 },
        aggressive = true,
        weight = 14,
    },
    coyote = {
        label = 'Coyote',
        model = `a_c_coyote`,
        level = 5,
        xp = 85,
        rarity = 'rare',
        zoneTypes = { brush = true, desert = true, canyon = true, hills = true, mountain = true },
        description = 'Night runner of Senora and the canyons.',
        harvest = { animal_meat = 2, animal_leather = 3, animal_bones = 2 },
        aggressive = true,
        weight = 12,
    },
    deer = {
        label = 'Deer',
        model = `a_c_deer`,
        level = 6,
        xp = 120,
        rarity = 'rare',
        zoneTypes = { forest = true, mountain = true, hills = true, canyon = true },
        description = 'The Rebel paycheck. Glass a ridge, do not camp the trail.',
        harvest = { animal_meat = 4, animal_leather = 3, animal_bones = 3, trophy_antler = 1 },
        aggressive = false,
        weight = 10,
    },
    mtlion = {
        label = 'Mountain Lion',
        model = `a_c_mtlion`,
        level = 8,
        xp = 180,
        rarity = 'legendary',
        zoneTypes = { mountain = true, peak = true },
        description = 'Chiliad and Josiah cat. It hunts back.',
        harvest = { animal_meat = 3, animal_leather = 4, animal_bones = 3, trophy_fang = 1 },
        aggressive = true,
        weight = 6,
    },
    panther = {
        label = 'Panther',
        model = `a_c_panther`,
        level = 10,
        xp = 260,
        rarity = 'legendary',
        zoneTypes = { peak = true },
        description = 'Apex of San Andreas. Summit only. Highest Rebel payout.',
        harvest = { animal_meat = 4, animal_leather = 5, animal_bones = 3, trophy_pelt = 1 },
        aggressive = true,
        weight = 3,
    },
}

Config.AnimalByModel = {}
for id, data in pairs(Config.Animals) do
    Config.AnimalByModel[data.model] = id
end

----------------------------------------------------------------
-- Hunting grounds (logical San Andreas wildlife country)
----------------------------------------------------------------
Config.Zones = {
    {
        id = 'grapeseed',
        name = 'Grapeseed Farms',
        type = 'farmland',
        coords = vec3(1960.0, 4940.0, 45.0),
        radius = 380.0,
        minLevel = 1,
        hint = 'Rabbits, hens, pigs, and cattle. Best first woods.',
    },
    {
        id = 'zancudo',
        name = 'Lago Zancudo Wetlands',
        type = 'wetland',
        coords = vec3(-2180.0, 2530.0, 3.0),
        radius = 260.0,
        minLevel = 1,
        hint = 'Birds and hogs on the flats.',
    },
    {
        id = 'paleto_forest',
        name = 'Paleto Forest',
        type = 'forest',
        coords = vec3(-580.0, 5800.0, 36.0),
        radius = 380.0,
        minLevel = 1,
        hint = 'Lodge woods. Rabbits, boar, later deer.',
    },
    {
        id = 'chaparral',
        name = 'Great Chaparral',
        type = 'brush',
        coords = vec3(-180.0, 1910.0, 198.0),
        radius = 320.0,
        minLevel = 1,
        hint = 'Brush country. Boar and coyote once you rank up.',
    },
    {
        id = 'senora',
        name = 'Grand Senora Desert',
        type = 'desert',
        coords = vec3(850.0, 2800.0, 52.0),
        radius = 400.0,
        minLevel = 2,
        hint = 'Open glass. Rabbits, coyotes, hawks.',
    },
    {
        id = 'alamo_north',
        name = 'Alamo North Brush',
        type = 'brush',
        coords = vec3(1310.0, 4368.0, 41.0),
        radius = 260.0,
        minLevel = 2,
        hint = 'Sage and coyote above the sea.',
    },
    {
        id = 'cassidy',
        name = 'Cassidy Creek Woods',
        type = 'forest',
        coords = vec3(-840.0, 4430.0, 20.0),
        radius = 260.0,
        minLevel = 2,
        hint = 'Creek timber. Deer start showing here.',
    },
    {
        id = 'procopio',
        name = 'Procopio Woods',
        type = 'forest',
        coords = vec3(1420.0, 6560.0, 18.0),
        radius = 260.0,
        minLevel = 2,
        hint = 'North coast timber above Paleto.',
    },
    {
        id = 'baytree',
        name = 'Baytree Canyon',
        type = 'canyon',
        coords = vec3(480.0, 1280.0, 210.0),
        radius = 240.0,
        minLevel = 2,
        hint = 'Tight canyon. Coyotes and hawks.',
    },
    {
        id = 'raton',
        name = 'Raton Canyon',
        type = 'canyon',
        coords = vec3(-1460.0, 1480.0, 116.0),
        radius = 300.0,
        minLevel = 3,
        hint = 'River canyon. Deer and coyote.',
    },
    {
        id = 'tataviam',
        name = 'Tataviam Mountains',
        type = 'mountain',
        coords = vec3(2250.0, 980.0, 110.0),
        radius = 320.0,
        minLevel = 3,
        hint = 'East ridges. Deer and canyon cats later.',
    },
    {
        id = 'tongva',
        name = 'Tongva Hills',
        type = 'hills',
        coords = vec3(-1860.0, 1960.0, 136.0),
        radius = 280.0,
        minLevel = 3,
        hint = 'West hills. Quiet deer country.',
    },
    {
        id = 'palomino',
        name = 'Palomino Highlands',
        type = 'hills',
        coords = vec3(2340.0, -400.0, 85.0),
        radius = 280.0,
        minLevel = 3,
        hint = 'South-east highlands. Deer and hawks.',
    },
    {
        id = 'banham',
        name = 'Banham Canyon',
        type = 'canyon',
        coords = vec3(-2800.0, 1420.0, 100.0),
        radius = 240.0,
        minLevel = 3,
        hint = 'Pacific rim canyon. Glass the slopes.',
    },
    {
        id = 'chiliad',
        name = 'Chiliad Wilderness',
        type = 'mountain',
        coords = vec3(450.0, 5560.0, 780.0),
        radius = 420.0,
        minLevel = 4,
        hint = 'Big mountain. Deer, boar, then mountain lion.',
    },
    {
        id = 'braddock',
        name = 'Braddock Pass',
        type = 'mountain',
        coords = vec3(1610.0, 4550.0, 76.0),
        radius = 240.0,
        minLevel = 5,
        hint = 'Pass timber. Lions start appearing.',
    },
    {
        id = 'josiah',
        name = 'Mount Josiah',
        type = 'mountain',
        coords = vec3(-1120.0, 4620.0, 136.0),
        radius = 280.0,
        minLevel = 6,
        hint = 'Steep cat country. Bring a ridge rifle.',
    },
    {
        id = 'chiliad_peak',
        name = 'Chiliad Summit',
        type = 'peak',
        coords = vec3(501.0, 5604.0, 797.0),
        radius = 180.0,
        minLevel = 8,
        hint = 'Apex only. Mountain lion and panther.',
    },
}

for i = 1, #Config.Zones do
    local zone = Config.Zones[i]
    zone.radiusSq = zone.radius * zone.radius
end

Config.ShowZoneBlips = true
Config.ShowZoneRadius = false
Config.ZoneBlip = {
    sprite = 141,
    scale = 0.7,
    shortRange = true,
    farmland = { color = 25, label = 'Rebel Hunting · Farm' },
    wetland = { color = 3, label = 'Rebel Hunting · Wetland' },
    forest = { color = 2, label = 'Rebel Hunting · Forest' },
    brush = { color = 21, label = 'Rebel Hunting · Brush' },
    desert = { color = 5, label = 'Rebel Hunting · Desert' },
    canyon = { color = 44, label = 'Rebel Hunting · Canyon' },
    hills = { color = 11, label = 'Rebel Hunting · Hills' },
    mountain = { color = 1, label = 'Rebel Hunting · Mountain' },
    peak = { color = 6, label = 'Rebel Hunting · Summit' },
}

Config.PedSpawn = {
    distance = 85.0,
    despawn = 125.0,
    interval = 1500,
}

Config.ZoneCheck = {
    inside = 850,
    nearby = 1500,
    far = 2500,
    nearbyRadius = 220.0,
}

Config.PedSpawn.distanceSq = Config.PedSpawn.distance * Config.PedSpawn.distance
Config.PedSpawn.despawnSq = Config.PedSpawn.despawn * Config.PedSpawn.despawn
Config.ZoneCheck.nearbySq = Config.ZoneCheck.nearbyRadius * Config.ZoneCheck.nearbyRadius

----------------------------------------------------------------
-- Outfitter / ranger peds
----------------------------------------------------------------
Config.Shops = {
    {
        id = 'lodge',
        label = 'Rebel Ranger Lodge',
        subtitle = 'Licenses · guns · buyback',
        ped = `s_m_y_ranger_01`,
        coords = vec4(-679.22, 5834.47, 17.33, 135.0),
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        blip = { sprite = 141, color = 17, scale = 0.9, label = 'Rebel Ranger Lodge' },
        defaultView = 'license',
        sellsLicense = true,
        views = { 'license', 'shop', 'sell', 'field', 'tasks', 'board' },
    },
    {
        id = 'grapeseed',
        label = 'Grapeseed Outfitters',
        subtitle = 'Farm country gear',
        ped = `a_m_m_farmer_01`,
        coords = vec4(1707.37, 4778.31, 42.02, 93.0),
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        blip = { sprite = 141, color = 17, scale = 0.8, label = 'Rebel Outfitters' },
        defaultView = 'shop',
        sellsLicense = false,
        views = { 'shop', 'sell', 'field', 'tasks', 'board' },
    },
    {
        id = 'senora',
        label = 'Senora Trading Post',
        subtitle = 'Desert buyback',
        ped = `a_m_m_hillbilly_01`,
        coords = vec4(591.49, 2743.96, 42.04, 185.0),
        scenario = 'WORLD_HUMAN_SMOKING',
        blip = { sprite = 141, color = 17, scale = 0.8, label = 'Rebel Outfitters' },
        defaultView = 'sell',
        sellsLicense = false,
        views = { 'shop', 'sell', 'field', 'tasks', 'board' },
    },
    {
        id = 'chiliad',
        label = 'Chiliad Ridge Outfitters',
        subtitle = 'High-country gear',
        ped = `s_m_m_trucker_01`,
        coords = vec4(425.18, 5613.96, 766.63, 270.0),
        scenario = 'WORLD_HUMAN_STAND_IMPATIENT',
        blip = { sprite = 141, color = 1, scale = 0.8, label = 'Rebel Outfitters' },
        defaultView = 'shop',
        sellsLicense = false,
        views = { 'shop', 'sell', 'field', 'tasks', 'board' },
    },
}

Config.ShopViews = { 'license', 'shop', 'sell', 'field', 'tasks', 'board' }

----------------------------------------------------------------
-- Daily tasks (reset at Config.DailyResetHour, server time)
----------------------------------------------------------------
Config.DailyResetHour = 0
Config.LeaderboardSize = 10

Config.DailyTasks = {
    {
        id = 'harvest_any',
        label = 'Walk the woods',
        description = 'Harvest 6 animals of any kind today.',
        type = 'harvest',
        count = 6,
        reward = { money = 220 },
    },
    {
        id = 'harvest_small',
        label = 'Small game',
        description = 'Harvest 4 rabbits, hens, or birds.',
        type = 'harvest_small',
        count = 4,
        reward = { money = 180 },
    },
    {
        id = 'harvest_deer',
        label = 'Rack run',
        description = 'Harvest 2 deer.',
        type = 'harvest_item',
        animal = 'deer',
        count = 2,
        reward = { money = 350 },
    },
    {
        id = 'harvest_predator',
        label = 'Cat country',
        description = 'Harvest a coyote, mountain lion, or panther.',
        type = 'harvest_rarity',
        rarities = { rare = true, legendary = true },
        count = 1,
        reward = { money = 500, items = { { 'ammo-sniper', 2 } } },
    },
    {
        id = 'sell_cash',
        label = 'Lodge payout',
        description = 'Sell $500 worth of harvest today.',
        type = 'sell',
        count = 500,
        reward = { money = 150 },
    },
    {
        id = 'buy_license_day',
        label = 'Papers in order',
        description = 'Hold a valid Rebel hunting license.',
        type = 'license',
        count = 1,
        reward = { money = 75 },
    },
}

function Config.AnimalInZone(animal, zone)
    if not animal or not zone then return false end
    if animal.zoneTypes and animal.zoneTypes[zone.type] then
        return true
    end
    return false
end

function Config.ZoneAnimals(zone, hunterLevel)
    local list = {}
    if not zone then return list end
    hunterLevel = hunterLevel or 1
    for id, animal in pairs(Config.Animals) do
        if Config.AnimalInZone(animal, zone) and hunterLevel >= (animal.level or 1) and hunterLevel >= (zone.minLevel or 1) then
            list[#list + 1] = { id = id, data = animal }
        end
    end
    return list
end
