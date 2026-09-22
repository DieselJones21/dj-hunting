lib.locale()
math.randomseed(os.time() % 2147483646)

local shopsById = {}
local lastHarvest = {}
local harvestedNet = {}
local cachedCatalog
local cachedField

for i = 1, #Config.Shops do
    local shop = Config.Shops[i]
    shop.pos = vec3(shop.coords.x, shop.coords.y, shop.coords.z)
    shopsById[shop.id] = shop
end

local function now()
    return os.clock()
end

local function playerCoords(src)
    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return nil end
    return GetEntityCoords(ped)
end

local function getShop(shopId)
    return shopsById[shopId]
end

local function isNearShop(src, shopId)
    local shop = getShop(shopId)
    local coords = playerCoords(src)
    if not shop or not coords then return false end
    return #(coords - shop.pos) <= (Config.ShopDistance + 2.0)
end

local function getZoneAt(src)
    local coords = playerCoords(src)
    if not coords then return nil end
    for i = 1, #Config.Zones do
        local zone = Config.Zones[i]
        local dx = coords.x - zone.coords.x
        local dy = coords.y - zone.coords.y
        if (dx * dx + dy * dy) <= zone.radiusSq then
            return zone
        end
    end
end

local function hasLicenseItem(src)
    local item = Config.License.item
    return (exports.ox_inventory:GetItemCount(src, item) or 0) > 0
end

local function isLicensed(src)
    if not Config.Hunt.requireLicense then return true end
    return Stats.HasLicenseFlag(src) and hasLicenseItem(src)
end

local function hasHarvestTool(src)
    for i = 1, #Config.HarvestTools do
        local name = Config.HarvestTools[i]
        if (exports.ox_inventory:GetItemCount(src, name) or 0) > 0 then
            return true, name
        end
    end
    return false
end

local function inventoryItem(entry)
    return entry.item or entry.weapon or entry
end

local function catalog()
    if cachedCatalog then return cachedCatalog end
    local items = {}
    for i = 1, #Config.ShopCatalogOrder do
        local name = Config.ShopCatalogOrder[i]
        local data = Config.Equipment[name]
        if data then
            local give = inventoryItem(data)
            items[#items + 1] = {
                item = name,
                give = give,
                label = data.label,
                description = data.description,
                category = data.category,
                price = data.price,
                level = data.level or 1,
                weapon = data.weapon,
                ammo = data.ammo,
                amount = data.amount or 1,
                image = data.image or Config.ItemImage(give),
            }
        end
    end
    cachedCatalog = items
    return items
end

local function fieldGuide()
    if cachedField then return cachedField end
    local list = {}
    for id, data in pairs(Config.Animals) do
        local payout = 0
        for item, count in pairs(data.harvest or {}) do
            local mat = Config.Materials[item]
            if mat then
                payout = payout + (mat.sell * count)
            end
        end
        list[#list + 1] = {
            id = id,
            label = data.label,
            description = data.description,
            level = data.level,
            xp = data.xp,
            rarity = data.rarity,
            payout = payout,
            harvest = data.harvest,
            flying = data.flying == true,
            aggressive = data.aggressive == true,
        }
    end
    table.sort(list, function(a, b)
        if a.level == b.level then
            return a.payout < b.payout
        end
        return a.level < b.level
    end)
    cachedField = list
    return list
end

local function equipmentCounts(src)
    local counts = {}
    for name, data in pairs(Config.Equipment) do
        counts[name] = exports.ox_inventory:GetItemCount(src, inventoryItem(data)) or 0
    end
    counts[Config.License.item] = exports.ox_inventory:GetItemCount(src, Config.License.item) or 0
    return counts
end

local function sellStock(src)
    local list = {}
    for name, data in pairs(Config.Materials) do
        local count = exports.ox_inventory:GetItemCount(src, name) or 0
        if count > 0 then
            list[#list + 1] = {
                item = name,
                label = data.label,
                description = data.description,
                category = 'harvest',
                rarity = name:find('trophy', 1, true) and 'legendary' or 'common',
                price = data.sell,
                count = count,
                image = Config.ItemImage(name),
            }
        end
    end
    table.sort(list, function(a, b)
        return a.price > b.price
    end)
    return list
end

local function shopPayload(src)
    local extra = Stats.Hud(src)
    local licensed = isLicensed(src)
    return {
        ok = true,
        player = {
            name = Bridge.GetPlayerName(src),
            cash = Bridge.GetMoney(src),
        },
        catalog = catalog(),
        goods = sellStock(src),
        field = fieldGuide(),
        equipment = equipmentCounts(src),
        licensed = licensed,
        licensedFlag = Stats.HasLicenseFlag(src),
        license = {
            item = Config.License.item,
            label = Config.License.label,
            description = Config.License.description,
            price = Stats.HasLicenseFlag(src) and Config.License.replacePrice or Config.License.price,
            owned = licensed,
            image = Config.ItemImage(Config.License.item),
        },
        tasks = extra.tasks,
        board = extra.board,
        you = extra.you,
        hunter = extra.hunter,
        resetsIn = extra.resetsIn,
    }
end

local function hunterState(src)
    local extra = Stats.Hud(src)
    return {
        ok = true,
        licensed = isLicensed(src),
        hunter = extra.hunter,
        zone = nil,
    }
end

lib.callback.register('dj-hunting:openShop', function(source, shopId)
    if type(shopId) ~= 'string' or not isNearShop(source, shopId) then
        return { ok = false, error = 'notify_too_far' }
    end
    return shopPayload(source)
end)

lib.callback.register('dj-hunting:state', function(source)
    return hunterState(source)
end)

lib.callback.register('dj-hunting:buyLicense', function(source, shopId)
    if not Bridge.RateLimit(source, 'license', 0.6) then
        return { ok = false, error = 'notify_busy' }
    end
    if type(shopId) ~= 'string' or not isNearShop(source, shopId) then
        return { ok = false, error = 'notify_too_far' }
    end

    local shop = getShop(shopId)
    if not shop or not shop.sellsLicense then
        return { ok = false, error = 'notify_invalid' }
    end

    if hasLicenseItem(source) then
        return { ok = false, error = 'notify_invalid' }
    end

    local replacing = Stats.HasLicenseFlag(source)
    local price = replacing and Config.License.replacePrice or Config.License.price
    if not Bridge.RemoveMoney(source, price) then
        return { ok = false, error = 'notify_no_money' }
    end

    if not exports.ox_inventory:CanCarryItem(source, Config.License.item, 1) then
        Bridge.AddMoney(source, price)
        return { ok = false, error = 'notify_cannot_carry' }
    end

    local added = exports.ox_inventory:AddItem(source, Config.License.item, 1, {
        description = 'Rebel Ranger Lodge · licensed hunter',
    })
    if not added then
        Bridge.AddMoney(source, price)
        return { ok = false, error = 'notify_cannot_carry' }
    end

    Stats.GrantLicense(source)

    return {
        ok = true,
        replaced = replacing,
        label = Config.License.label,
        total = price,
        cash = Bridge.GetMoney(source),
        refresh = shopPayload(source),
    }
end)

lib.callback.register('dj-hunting:buy', function(source, shopId, itemName, amount)
    if not Bridge.RateLimit(source, 'buy', 0.25) then
        return { ok = false, error = 'notify_busy' }
    end
    amount = math.floor(tonumber(amount) or 0)
    if type(shopId) ~= 'string' or type(itemName) ~= 'string' or not isNearShop(source, shopId) then
        return { ok = false, error = 'notify_too_far' }
    end
    if amount < 1 or amount > Config.MaxBuyAmount then
        return { ok = false, error = 'notify_invalid' }
    end
    if not isLicensed(source) then
        return { ok = false, error = 'notify_need_license_shop' }
    end

    local item = Config.Equipment[itemName]
    if not item then
        return { ok = false, error = 'notify_invalid' }
    end

    local player = Stats.Get(source)
    local level = Config.LevelFromXP(player.xp or 0)
    if level < (item.level or 1) then
        return { ok = false, error = 'notify_locked_gun', errorArg = item.level }
    end

    local giveName = inventoryItem(item)
    local giveCount = amount * (item.amount or 1)
    local total = item.price * amount
    if not Bridge.RemoveMoney(source, total) then
        return { ok = false, error = 'notify_no_money' }
    end

    if not exports.ox_inventory:CanCarryItem(source, giveName, giveCount) then
        Bridge.AddMoney(source, total)
        return { ok = false, error = 'notify_cannot_carry' }
    end

    local added = exports.ox_inventory:AddItem(source, giveName, giveCount)
    if not added then
        Bridge.AddMoney(source, total)
        return { ok = false, error = 'notify_cannot_carry' }
    end

    return {
        ok = true,
        amount = giveCount,
        label = item.label,
        total = total,
        cash = Bridge.GetMoney(source),
    }
end)

lib.callback.register('dj-hunting:sell', function(source, shopId, itemName, amount)
    if not Bridge.RateLimit(source, 'sell', 0.25) then
        return { ok = false, error = 'notify_busy' }
    end
    amount = math.floor(tonumber(amount) or 0)
    if type(shopId) ~= 'string' or type(itemName) ~= 'string' or not isNearShop(source, shopId) then
        return { ok = false, error = 'notify_too_far' }
    end

    local mat = Config.Materials[itemName]
    if not mat or amount < 1 or amount > 200 then
        return { ok = false, error = 'notify_invalid' }
    end

    local have = exports.ox_inventory:GetItemCount(source, itemName) or 0
    if have < amount then
        return { ok = false, error = 'notify_invalid' }
    end

    local removed = exports.ox_inventory:RemoveItem(source, itemName, amount)
    if not removed then
        return { ok = false, error = 'notify_invalid' }
    end

    local total = mat.sell * amount
    if not Bridge.AddMoney(source, total) then
        exports.ox_inventory:AddItem(source, itemName, amount)
        return { ok = false, error = 'notify_invalid' }
    end

    Stats.RecordSell(source, total)

    return {
        ok = true,
        amount = amount,
        label = mat.label,
        total = total,
        cash = Bridge.GetMoney(source),
    }
end)

lib.callback.register('dj-hunting:sellAll', function(source, shopId)
    if not Bridge.RateLimit(source, 'sellAll', 0.75) then
        return { ok = false, error = 'notify_busy' }
    end
    if type(shopId) ~= 'string' or not isNearShop(source, shopId) then
        return { ok = false, error = 'notify_too_far' }
    end

    local sold = {}
    local payout = 0

    for name, data in pairs(Config.Materials) do
        local count = exports.ox_inventory:GetItemCount(source, name) or 0
        if count > 0 then
            sold[#sold + 1] = { item = name, count = count, price = data.sell }
            payout = payout + data.sell * count
        end
    end

    if #sold == 0 then
        return { ok = false, error = 'notify_no_goods' }
    end

    for i = 1, #sold do
        local entry = sold[i]
        if not exports.ox_inventory:RemoveItem(source, entry.item, entry.count) then
            for r = 1, i - 1 do
                exports.ox_inventory:AddItem(source, sold[r].item, sold[r].count)
            end
            return { ok = false, error = 'notify_invalid' }
        end
    end

    if not Bridge.AddMoney(source, payout) then
        for i = 1, #sold do
            exports.ox_inventory:AddItem(source, sold[i].item, sold[i].count)
        end
        return { ok = false, error = 'notify_invalid' }
    end

    Stats.RecordSell(source, payout)

    return { ok = true, total = payout, cash = Bridge.GetMoney(source) }
end)

lib.callback.register('dj-hunting:harvest', function(source, payload)
    if not Bridge.RateLimit(source, 'harvest', 1.2) then
        return { ok = false, error = 'notify_busy' }
    end

    payload = payload or {}
    local animalId = payload.animal
    local animal = type(animalId) == 'string' and Config.Animals[animalId]
    if not animal then
        return { ok = false, error = 'notify_invalid' }
    end

    if Config.Hunt.requireLicense and not isLicensed(source) then
        return { ok = false, error = 'notify_need_license' }
    end

    local hasTool = hasHarvestTool(source)
    if not hasTool then
        return { ok = false, error = 'notify_need_axe' }
    end

    local coords = playerCoords(source)
    if not coords then
        return { ok = false, error = 'notify_invalid' }
    end

    local zone = getZoneAt(source)
    if Config.Hunt.requireZone and not zone then
        return { ok = false, error = 'notify_need_zone' }
    end
    if zone and not Config.AnimalInZone(animal, zone) then
        return { ok = false, error = 'notify_need_zone' }
    end
    if zone and Config.LevelFromXP(Stats.Get(source).xp or 0) < (zone.minLevel or 1) then
        return { ok = false, error = 'notify_zone_level', errorArg = zone.minLevel }
    end

    local hunter = Stats.Get(source)
    local level = Config.LevelFromXP(hunter.xp or 0)
    if level < (animal.level or 1) then
        return { ok = false, error = 'notify_need_level', errorArg = animal.level, errorArg2 = animal.label }
    end

    if Config.Hunt.requireHuntingWeapon then
        local weaponHash = tonumber(payload.weapon)
        if not weaponHash or not Config.HuntingWeapons[weaponHash] then
            return { ok = false, error = 'notify_need_weapon' }
        end
    end

    local corpse = payload.coords
    if type(corpse) == 'table' and corpse.x and corpse.y then
        local target = vec3(corpse.x + 0.0, corpse.y + 0.0, (corpse.z or coords.z) + 0.0)
        if #(coords - target) > (Config.Hunt.harvestDistance + 3.0) then
            return { ok = false, error = 'notify_too_far' }
        end
    end

    local netId = tonumber(payload.netId)
    if netId and harvestedNet[netId] then
        return { ok = false, error = 'notify_already_harvested' }
    end

    local stamp = lastHarvest[source]
    if stamp then
        local elapsed = now() - stamp.time
        if elapsed < Config.Hunt.searchCooldown then
            return { ok = false, error = 'notify_cooldown', errorArg = math.ceil(Config.Hunt.searchCooldown - elapsed) }
        end
        if #(coords - stamp.pos) < Config.Hunt.walkDistance then
            return { ok = false, error = 'notify_search' }
        end
    end

    local granted = {}
    for item, count in pairs(animal.harvest or {}) do
        granted[#granted + 1] = { item = item, count = count }
        if not exports.ox_inventory:CanCarryItem(source, item, count) then
            return { ok = false, error = 'notify_cannot_carry' }
        end
    end

    for i = 1, #granted do
        local entry = granted[i]
        if not exports.ox_inventory:AddItem(source, entry.item, entry.count) then
            for r = 1, i - 1 do
                exports.ox_inventory:RemoveItem(source, granted[r].item, granted[r].count)
            end
            return { ok = false, error = 'notify_cannot_carry' }
        end
    end

    if netId then
        harvestedNet[netId] = true
        SetTimeout(120000, function()
            harvestedNet[netId] = nil
        end)
    end

    lastHarvest[source] = { time = now(), pos = coords }

    local after, before, totalXP = Stats.AddXP(source, animal.xp or 0)
    Stats.RecordHarvest(source, {
        animal = animalId,
        rarity = animal.rarity,
        zone = zone and zone.id or nil,
    })

    return {
        ok = true,
        animal = animalId,
        label = animal.label,
        xp = animal.xp or 0,
        totalXP = totalXP,
        level = after,
        leveled = after > before,
        items = granted,
        hunter = Stats.Hud(source).hunter,
        cooldown = Config.Hunt.searchCooldown,
        walk = Config.Hunt.walkDistance,
    }
end)

lib.callback.register('dj-hunting:claimTask', function(source, shopId, taskId)
    if not Bridge.RateLimit(source, 'claim', 0.5) then
        return { ok = false, error = 'notify_busy' }
    end
    if type(shopId) ~= 'string' or not isNearShop(source, shopId) then
        return { ok = false, error = 'notify_too_far' }
    end
    return Stats.Claim(source, taskId)
end)

lib.addCommand('huntingkit', {
    help = 'Give a Rebel hunting test kit',
    restricted = 'group.admin',
}, function(source)
    Stats.GrantLicense(source)
    exports.ox_inventory:AddItem(source, Config.License.item, 1)
    exports.ox_inventory:AddItem(source, 'hunting_axe', 1)
    local starter = Config.Equipment.WEAPON_MUSKET
    if starter then
        exports.ox_inventory:AddItem(source, inventoryItem(starter), 1)
        if starter.ammo then
            exports.ox_inventory:AddItem(source, starter.ammo, 40)
        end
    end
    TriggerClientEvent('ox_lib:notify', source, {
        title = 'Rebel Hunting',
        description = 'Test kit added. License flagged.',
        type = 'success',
    })
end)

lib.addCommand('huntingxp', {
    help = 'Set hunting XP (admin)',
    params = { { name = 'xp', type = 'number', help = 'Total XP' } },
    restricted = 'group.admin',
}, function(source, args)
    local level, xp = Stats.SetXP(source, args.xp)
    TriggerClientEvent('ox_lib:notify', source, {
        title = 'Rebel Hunting',
        description = ('XP set to %s · level %s'):format(xp, level),
        type = 'success',
    })
    TriggerClientEvent('dj-hunting:sync', source, hunterState(source))
end)

AddEventHandler('playerDropped', function()
    lastHarvest[source] = nil
    Bridge.ClearRate(source)
end)
