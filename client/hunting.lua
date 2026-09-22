lib.locale()

local hunting = false
local spawned = {}
local harvestBusy = false
local lastHarvestPos
local lastHarvestAt = 0
local lastMovePos
local lastMoveAt = 0
local camped = false
local lastWeapon = 0
local hudStatus = 'idle'
local lastZoneId

local function isDead()
    local ped = cache.ped
    return IsEntityDead(ped) or IsPedFatallyInjured(ped) or LocalPlayer.state.dead
end

function IsHarvesting()
    return harvestBusy
end

local function hunterLevel()
    return (HunterState.hunter and HunterState.hunter.level) or 1
end

local function legalWeapon(hash)
    if not hash or hash == 0 then return false end
    return Config.HuntingWeapons[hash] == true
end

local function clearEntity(entry)
    if not entry then return end
    if entry.interactId and entry.entity and GetResourceState('interact') == 'started' then
        pcall(function()
            exports.interact:RemoveLocalEntityInteraction(entry.entity, entry.interactId)
        end)
    end
    if entry.entity and DoesEntityExist(entry.entity) then
        DeleteEntity(entry.entity)
    end
end

local function purgeMissing()
    for i = #spawned, 1, -1 do
        local entry = spawned[i]
        if not entry.entity or not DoesEntityExist(entry.entity) then
            table.remove(spawned, i)
        end
    end
end

local function despawnAll()
    for i = 1, #spawned do
        clearEntity(spawned[i])
    end
    spawned = {}
end

local function despawnFar(coords)
    local maxSq = Config.Hunt.despawnDistance * Config.Hunt.despawnDistance
    for i = #spawned, 1, -1 do
        local entry = spawned[i]
        if not entry.entity or not DoesEntityExist(entry.entity) then
            table.remove(spawned, i)
        else
            local pos = GetEntityCoords(entry.entity)
            local dx, dy = pos.x - coords.x, pos.y - coords.y
            if (dx * dx + dy * dy) > maxSq then
                clearEntity(entry)
                table.remove(spawned, i)
            end
        end
    end
end

local function randomOffset(minR, maxR)
    local radius = minR + (math.random() * (maxR - minR))
    local heading = math.random() * math.pi * 2
    return math.cos(heading) * radius, math.sin(heading) * radius
end

local function pickSpawnCoords(origin)
    for _ = 1, 8 do
        local ox, oy = randomOffset(Config.Hunt.spawnRadius.min, Config.Hunt.spawnRadius.max)
        local x, y = origin.x + ox, origin.y + oy
        local found, safe = GetSafeCoordForPed(x, y, origin.z, false, 16)
        if found and safe then
            return safe
        end
        local ok, gz = GetGroundZFor_3dCoord(x, y, origin.z + 40.0, false)
        if ok then
            return vec3(x, y, gz)
        end
    end
end

local function weightedPick(pool)
    local total = 0
    for i = 1, #pool do
        total = total + (pool[i].data.weight or 10)
    end
    if total <= 0 then return pool[1] end
    local roll = math.random() * total
    local acc = 0
    for i = 1, #pool do
        acc = acc + (pool[i].data.weight or 10)
        if roll <= acc then
            return pool[i]
        end
    end
    return pool[#pool]
end

local function startHarvest(entry)
    if harvestBusy or not entry or not entry.entity then return end
    if not DoesEntityExist(entry.entity) then return end
    if not HunterState.licensed then
        Notify('notify_need_license', 'error')
        return
    end
    if hunterLevel() < (entry.level or 1) then
        Notify('notify_need_level', 'error', entry.level, entry.label)
        return
    end

    local coords = GetEntityCoords(cache.ped)
    local corpse = GetEntityCoords(entry.entity)
    if #(coords - corpse) > Config.Hunt.harvestDistance + 0.6 then
        Notify('notify_too_far', 'error')
        return
    end

    if lastHarvestPos and #(coords - lastHarvestPos) < Config.Hunt.walkDistance then
        local elapsed = GetGameTimer() - lastHarvestAt
        if elapsed < (Config.Hunt.searchCooldown * 1000) or #(coords - lastHarvestPos) < Config.Hunt.walkDistance then
            Notify('notify_search', 'error')
            return
        end
    end

    harvestBusy = true
    local ped = cache.ped
    local anim = Config.Hunt.harvestAnim
    if anim and anim.dict then
        lib.requestAnimDict(anim.dict)
        TaskPlayAnim(ped, anim.dict, anim.clip, 8.0, -8.0, -1, 1, 0.0, false, false, false)
    end

    local finished = lib.progressBar({
        duration = Config.Hunt.harvestDuration,
        label = locale('progress_harvest', entry.label),
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true, sprint = true },
    })

    ClearPedTasks(ped)
    if not finished then
        harvestBusy = false
        return
    end

    local netId = NetworkGetNetworkIdFromEntity(entry.entity)
    local result = lib.callback.await('dj-hunting:harvest', false, {
        animal = entry.id,
        netId = netId ~= 0 and netId or nil,
        weapon = entry.weapon or lastWeapon,
        coords = { x = corpse.x, y = corpse.y, z = corpse.z },
    })

    harvestBusy = false

    if not result or not result.ok then
        if result and result.errorArg2 then
            Notify(result.error, 'error', result.errorArg, result.errorArg2)
        elseif result and result.errorArg then
            Notify(result.error, 'error', result.errorArg)
        else
            Notify(result and result.error or 'notify_invalid', 'error')
        end
        return
    end

    lastHarvestPos = GetEntityCoords(cache.ped)
    lastHarvestAt = GetGameTimer()
    if result.hunter then
        HunterState.hunter = result.hunter
        HunterState.licensed = true
    end

    Notify('notify_harvested', 'success', result.label, result.xp)
    if result.leveled then
        Notify('notify_level_up', 'success', result.level)
    end

    clearEntity(entry)
    for i = #spawned, 1, -1 do
        if spawned[i] == entry then
            table.remove(spawned, i)
            break
        end
    end
end

local function attachHarvest(entry)
    if entry.interactId or not entry.entity then return end
    if GetResourceState('interact') ~= 'started' then return end
    local id = ('dj_hunting_carcass_%s'):format(entry.token)
    local ok = pcall(function()
        exports.interact:AddLocalEntityInteraction({
            entity = entry.entity,
            id = id,
            name = id,
            distance = 6.0,
            interactDst = Config.Hunt.harvestDistance,
            offset = vec3(0.0, 0.0, 0.2),
            ignoreLos = true,
            options = {
                {
                    label = locale('harvest_animal', entry.label),
                    action = function()
                        startHarvest(entry)
                    end,
                },
            },
        })
    end)
    if ok then
        entry.interactId = id
    end
end

local function spawnAnimal(zone)
    purgeMissing()
    if #spawned >= Config.Hunt.maxActiveAnimals then return end

    local pool = Config.ZoneAnimals(zone, hunterLevel())
    if #pool == 0 then return end

    local pick = weightedPick(pool)
    local coords = pickSpawnCoords(GetEntityCoords(cache.ped))
    if not coords then return end

    local model = pick.data.model
    if not lib.requestModel(model, 5000) then return end

    local ped = CreatePed(28, model, coords.x, coords.y, coords.z, math.random(0, 359) + 0.0, false, true)
    SetEntityAsMissionEntity(ped, true, true)
    SetPedFleeAttributes(ped, 0, false)
    SetBlockingOfNonTemporaryEvents(ped, false)
    SetPedCanRagdollFromPlayerImpact(ped, true)
    SetModelAsNoLongerNeeded(model)

    if pick.data.aggressive and math.random() < Config.Hunt.predatorChance then
        TaskCombatPed(ped, cache.ped, 0, 16)
    else
        TaskWanderStandard(ped, 10.0, 10)
    end

    spawned[#spawned + 1] = {
        entity = ped,
        id = pick.id,
        label = pick.data.label,
        level = pick.data.level,
        token = ('%s_%s'):format(pick.id, GetGameTimer()),
        weapon = 0,
        dead = false,
    }
end

local function canSpawn()
    if not CurrentZone then return false, 'idle' end
    if Config.Hunt.requireLicense and not HunterState.licensed then
        return false, 'nolicense'
    end
    if hunterLevel() < (CurrentZone.minLevel or 1) then
        return false, 'nolicense'
    end
    if camped then
        return false, 'camped'
    end
    if lastHarvestAt > 0 then
        local elapsed = (GetGameTimer() - lastHarvestAt) / 1000
        if elapsed < Config.Hunt.searchCooldown then
            return false, 'cooldown'
        end
        local coords = GetEntityCoords(cache.ped)
        if lastHarvestPos and #(coords - lastHarvestPos) < Config.Hunt.walkDistance then
            return false, 'search'
        end
    end
    return true, 'ready'
end

local function inHuntZone()
    return CurrentZone ~= nil
end

local function fieldNotify(key, nType, ...)
    if not Config.ShowFieldAlert(inHuntZone()) then
        return
    end
    Notify(key, nType, ...)
end

function HideHuntHud()
    camped = false
    lastMovePos = nil
    lastMoveAt = 0
    lastZoneId = nil
    hudStatus = 'idle'
    lib.hideTextUI()
    SendNUIMessage({ action = 'hud', data = { visible = false } })
end

local function updateMovement()
    if not inHuntZone() then
        if camped or lastMovePos or lastZoneId then
            HideHuntHud()
        end
        return
    end

    if lastZoneId ~= CurrentZone.id then
        lastZoneId = CurrentZone.id
        lastMovePos = GetEntityCoords(cache.ped)
        lastMoveAt = GetGameTimer()
        camped = false
        return
    end

    local coords = GetEntityCoords(cache.ped)
    if not lastMovePos then
        lastMovePos = coords
        lastMoveAt = GetGameTimer()
        return
    end
    if #(coords - lastMovePos) >= Config.Hunt.moveThreshold then
        lastMovePos = coords
        lastMoveAt = GetGameTimer()
        if camped then
            camped = false
        end
    elseif (GetGameTimer() - lastMoveAt) >= (Config.Hunt.stillTimeout * 1000) then
        if not camped then
            camped = true
            fieldNotify('notify_camped', 'inform')
        end
    end
end

local function pushHud()
    if IsShopOpen() or not inHuntZone() then
        SendNUIMessage({ action = 'hud', data = { visible = false } })
        return
    end
    local h = HunterState.hunter or {}
    local allowed, status = canSpawn()
    if allowed then status = #spawned > 0 and 'ready' or 'searching' end
    hudStatus = status

    local cooldownLeft = 0
    if lastHarvestAt > 0 then
        cooldownLeft = math.max(0, Config.Hunt.searchCooldown - ((GetGameTimer() - lastHarvestAt) / 1000))
    end

    SendNUIMessage({
        action = 'hud',
        data = {
            visible = CurrentZone ~= nil,
            zone = CurrentZone and CurrentZone.name or '',
            hint = CurrentZone and CurrentZone.hint or '',
            level = h.level or 1,
            xp = h.xp or 0,
            toNext = h.toNext or 0,
            floor = h.floor or 0,
            next = h.next or 0,
            max = h.max or Config.MaxLevel,
            licensed = HunterState.licensed == true,
            status = status,
            cooldown = math.ceil(cooldownLeft),
            brand = Config.Brand.short,
        },
    })
end

CreateThread(function()
    while true do
        local wait = CurrentZone and 400 or 1500
        updateMovement()
        if CurrentZone then
            despawnFar(GetEntityCoords(cache.ped))
        else
            if #spawned > 0 then
                despawnAll()
            end
            lib.hideTextUI()
        end
        pushHud()
        Wait(wait)
    end
end)

CreateThread(function()
    while true do
        local wait = Config.Hunt.spawnInterval
        if CurrentZone then
            local allowed = canSpawn()
            if allowed and not isDead() and not cache.vehicle and not harvestBusy and not IsShopOpen() then
                spawnAnimal(CurrentZone)
            end
        end
        Wait(wait)
    end
end)

CreateThread(function()
    while true do
        local sleep = 750
        if #spawned > 0 then
            sleep = 200
            for i = 1, #spawned do
                local entry = spawned[i]
                if entry.entity and DoesEntityExist(entry.entity) and IsEntityDead(entry.entity) and not entry.dead then
                    entry.dead = true
                    local killer = GetPedSourceOfDeath(entry.entity)
                    if killer == cache.ped then
                        local cause = GetPedCauseOfDeath(entry.entity)
                        entry.weapon = cause
                        lastWeapon = cause
                        if Config.Hunt.requireHuntingWeapon and not legalWeapon(cause) then
                            fieldNotify('notify_need_weapon', 'error')
                        else
                            attachHarvest(entry)
                        end
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

CreateThread(function()
    while true do
        local wait = 800
        if #spawned > 0 and not harvestBusy then
            local coords = GetEntityCoords(cache.ped)
            for i = 1, #spawned do
                local entry = spawned[i]
                if entry.dead and entry.entity and DoesEntityExist(entry.entity) then
                    if #(coords - GetEntityCoords(entry.entity)) <= Config.Hunt.harvestDistance then
                        wait = 0
                        lib.showTextUI(locale('harvest_animal', entry.label), { position = 'left-center' })
                        if IsControlJustPressed(0, 38) then
                            lib.hideTextUI()
                            startHarvest(entry)
                        end
                        break
                    end
                end
            end
        else
            lib.hideTextUI()
        end
        Wait(wait)
    end
end)

AddEventHandler('gameEventTriggered', function(name, args)
    if name ~= 'CEventNetworkEntityDamage' then return end
    local victim = args[1]
    local attacker = args[2]
    if attacker ~= cache.ped then return end
    local weapon = args[7] or args[5]
    if type(weapon) == 'number' then
        lastWeapon = weapon
    end
    for i = 1, #spawned do
        if spawned[i].entity == victim then
            spawned[i].weapon = lastWeapon
            break
        end
    end
end)

lib.addCommand(Config.Command, {
    help = 'Rebel hunting status',
}, function()
    refreshHuntCommand()
end)

function refreshHuntCommand()
    local payload = lib.callback.await('dj-hunting:state', false)
    if payload and payload.hunter then
        HunterState.hunter = payload.hunter
        HunterState.licensed = payload.licensed == true
    end
    local h = HunterState.hunter or {}
    lib.notify({
        title = Config.Brand.title,
        description = CurrentZone
            and ('%s · L%s · %s XP'):format(CurrentZone.name, h.level or 1, h.xp or 0)
            or ('Not in a hunting ground · L%s'):format(h.level or 1),
        type = 'inform',
    })
end

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    despawnAll()
    lib.hideTextUI()
    SendNUIMessage({ action = 'hud', data = { visible = false } })
end)
