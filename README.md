# Rebel Hunting

XP hunting for FiveM, branded for **Rebel Roleplay**. Players buy a **hunting license** from the ranger, kit up at Rebel Outfitters (axe + ranked guns), walk **logical San Andreas grounds**, harvest with an **axe**, and sell **meat, hide, bone, and trophies** through a modern lodge UI that matches the fishing script.

You cannot camp a spot and farm. After every harvest the woods go quiet until you **walk off the carcass** and wait out the search cooldown.

## Requirements

- [ox_lib](https://github.com/overextended/ox_lib)
- [ox_inventory](https://github.com/overextended/ox_inventory)
- [interact](https://github.com/darktrovx/interact) (lodge / outfitter peds)
- ESX, QBCore, Qbox, or ox_inventory `money` item

## Install

1. Drop this folder into `resources` as `dj-hunting`.
2. Open `ox_inventory/data/items.lua` and paste the item blocks from `install/ox_inventory_items.lua` **inside** the existing `return { ... }` table. Do not replace the whole file.
3. Guns use stock ox_inventory weapons (`WEAPON_MUSKET`, `WEAPON_PUMPSHOTGUN`, `WEAPON_MARKSMANRIFLE`, `WEAPON_SNIPERRIFLE`, `WEAPON_HEAVYSNIPER`) and ammo (`ammo-musket`, `ammo-shotgun`, `ammo-rifle`, `ammo-sniper`). Those items already ship with ox_inventory.
4. Restart `ox_inventory`, then start this resource:

```cfg
ensure ox_lib
ensure ox_inventory
ensure interact
ensure dj-hunting
```

5. Open `config.lua` and set `Config.Money` to match your server.

### Custom gun spawn names

Every rifle in `Config.Equipment` has a `weapon` (GTA spawn / hash name) and `item` (ox_inventory item). Swap those two fields to whatever pack you run:

```lua
hunting_rifle_apex = {
    weapon = 'WEAPON_YOURSPAWN', -- spawn name
    item = 'WEAPON_YOURSPAWN',   -- ox_inventory item, usually the same
    ...
}
```

The store will not sell a gun until the hunter rank on that entry is met.

## How to hunt

1. Go to **Rebel Ranger Lodge** (Paleto Forest cabin) and buy a **hunting license** from the ranger ped. Outfitters will not sell gear without it.
2. Buy a **Skinning Axe** and a **Trail Musket** (or a higher gun you have ranked for).
3. Walk into a hunting ground. Animals only spawn while you are **moving**. Stand still and the woods dry up.
4. Kill with a **licensed hunting gun**. Other weapons do not count.
5. Walk up to the carcass and harvest (interact or **E**). You must have the axe. You get **meat, hide, and bone** — trophies on deer, mountain lion, and panther.
6. After a harvest you must **walk ~48m** and wait **28s** before the next animal will show. No sitting and shooting.
7. Sell the satchel at any Rebel Outfitter.

`/hunt` or **F7** shows rank, XP, and license. Admin: `/huntingkit` and `/huntingxp [amount]` (`group.admin`).

## Rank and animals

Start on small game and work up. Harvest XP is server-side.

| Rank | Unlocks | Typical payout |
| --- | --- | --- |
| 1 | Rabbit, hen, pigeon | meat / bone |
| 2 | Crow, seagull, cormorant | + hide on cormorant |
| 3 | Hawk, pig | thicker harvest |
| 4 | Cow, boar | farm / brush payday |
| 5 | Coyote | rare hide |
| 6 | Deer | trophy antler |
| 7 | Ridge rifle | mountain country |
| 8 | Mountain lion | trophy fang |
| 9 | Apex rifle | summit kit |
| 10 | Panther | Rebel pelt |

## Grounds

Blips are on. Zones sit on real wildlife country, not downtown:

- Grapeseed Farms, Paleto Forest, Lago Zancudo — starter
- Great Chaparral, Senora Desert, Alamo North, Cassidy Creek, Procopio Woods, Baytree Canyon
- Raton Canyon, Tataviam, Tongva Hills, Palomino Highlands, Banham Canyon
- Chiliad Wilderness, Braddock Pass, Mount Josiah
- Chiliad Summit — level 8+, lion and panther

## Lodge UI

Same modern card layout as the fishing script, Rebel-branded (ember / charcoal):

- **License** — buy papers from the ranger
- **Store** — axe, ranked guns, ammo (locked without a license)
- **Sell** — meat, hide, bone, trophies
- **Field** — bestiary with rank locks and estimated payout
- **Tasks** — daily walks, claimed at the lodge
- **Board** — most takes / most money, today and all-time

Stats save to `data/stats.json`.

Outfitters: Rebel Ranger Lodge, Grapeseed Outfitters, Senora Trading Post, Chiliad Ridge Outfitters.

## Preview the UI

Open `html/index.html` in a browser (outside FiveM). Query flags:

- `?view=shop` `sell` `license` `field` `tasks` `board`
- `?licensed=0` to see the locked store
