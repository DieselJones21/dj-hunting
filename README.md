# Rebel Hunting

XP hunting for FiveM, branded for **Rebel Roleplay**. Players buy a **hunting license** from the ranger, kit up at Rebel Outfitters (axe + ranked **pistols, shotguns, rifles, and hunting guns**), walk **logical San Andreas grounds**, harvest with an **axe**, and sell **meat, hide, bone, and trophies** through a modern lodge UI.

You cannot camp a spot and farm. After every harvest the woods go quiet until you **walk off the carcass** and wait out the search cooldown.

## Requirements

- [ox_lib](https://github.com/overextended/ox_lib)
- [ox_inventory](https://github.com/overextended/ox_inventory)
- [interact](https://github.com/darktrovx/interact) (lodge / outfitter peds)
- ESX, QBCore, Qbox, or ox_inventory `money` item

## Install

1. Drop this folder into `resources` as `dj-hunting`.
2. Open `ox_inventory/data/items.lua` and paste the item blocks from `install/ox_inventory_items.lua` **inside** the existing `return { ... }` table. Do not replace the whole file.
3. Copy `install/inventory_images/*.png` into `ox_inventory/web/images/` so ox_inventory can show the generated hunting items (license, axe, harvest, trophies) and the two DLC rifles ox_inventory does not ship icons for (`WEAPON_TACTICALRIFLE`, `WEAPON_BATTLERIFLE`).
4. Guns and ammo are **stock ox_inventory items** that fit hunting:
   - Pistols and revolvers
   - Field shotguns (pump, double barrel, sawn-off, bullpup, heavy)
   - Rifles and carbines
   - Hunting guns (musket, marksman, sniper, precision, heavy sniper)
   - `ammo-9` `ammo-22` `ammo-38` `ammo-44` `ammo-45` `ammo-50`
   - `ammo-rifle` `ammo-rifle2` `ammo-shotgun` `ammo-sniper` `ammo-heavysniper` `ammo-musket`
   SMGs, machine guns, launchers, ray/rail guns, and throwables are not sold.
5. Restart `ox_inventory`, then start this resource:

```cfg
ensure ox_lib
ensure ox_inventory
ensure interact
ensure dj-hunting
```

6. Open `config.lua` and set `Config.Money` to match your server.

### Inventory images

Lodge NUI icons live in `html/images/`:

- Official [ox_inventory `web/images`](https://github.com/overextended/ox_inventory/tree/main/web/images) copies for every sold gun, tool, and ammo item
- Generated icons for custom hunting items (`hunting_license`, `hunting_axe`, `animal_meat`, `animal_leather`, `animal_bones`, `trophy_antler`, `trophy_fang`, `trophy_pelt`)
- Generated icons for the two rifles ox_inventory does not ship (`WEAPON_TACTICALRIFLE`, `WEAPON_BATTLERIFLE`)

The store catalog is `data/equipment.lua`. Item keys are the ox_inventory names (`WEAPON_PISTOL`, `ammo-9`, …). Rank on each entry gates the sale. Legal harvests must use one of those sold firearms.

## How to hunt

1. Go to **Rebel Ranger Lodge** (Paleto Forest cabin) and buy a **hunting license** from the ranger ped. Outfitters will not sell gear without it.
2. Buy a **Skinning Axe** (or a hatchet / knife) and any ranked gun.
3. Walk into a hunting ground. The hunt HUD and camp / woods alerts **only appear inside a marked ground**. Animals only spawn while you are **moving**. Stand still and the woods dry up.
4. Kill with a **licensed hunting gun**. Other weapons do not count.
5. Walk up to the carcass and harvest (interact or **E**). You must have an axe / hatchet / knife. You get **meat, hide, and bone** — trophies on deer, mountain lion, and panther.
6. After a harvest you must **walk ~48m** and wait **28s** before the next animal will show. No sitting and shooting.
7. Sell the satchel at any Rebel Outfitter.

`/hunt` or **F7** shows rank, XP, and license. Admin: `/huntingkit` and `/huntingxp [amount]` (`group.admin`).

## Rank and animals

Start on small game and work up. Harvest XP is server-side.

| Rank | Unlocks | Typical payout |
| --- | --- | --- |
| 1 | Rabbit, hen, pigeon · pistols, musket, axe | meat / bone |
| 2 | Crow, seagull, cormorant · more pistols / SMGs | + hide on cormorant |
| 3 | Hawk, pig · shotguns | thicker harvest |
| 4 | Cow, boar · compact rifles | farm / brush payday |
| 5 | Coyote · service rifles | rare hide |
| 6 | Deer · marksman rifle | trophy antler |
| 7 | Sniper / precision rifles | mountain country |
| 8 | Mountain lion · MK2 rifles | trophy fang |
| 9 | Heavy sniper | summit kit |
| 10 | Panther · Heavy Sniper MK2 | Rebel pelt |

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
- **Store** — axe, pistols, shotguns, rifles, hunting guns, ammo (locked without a license)
- **Sell** — meat, hide, bone, trophies
- **Field** — bestiary with rank locks and estimated payout
- **Tasks** — daily walks, claimed at the lodge
- **Board** — most takes / most money, today and all-time

Stats save to `data/stats.json`.

Outfitters: Rebel Ranger Lodge, Grapeseed Outfitters, Senora Trading Post, Chiliad Ridge Outfitters.

## Preview the UI

Open `html/index.html` in a browser (outside FiveM). Query flags:

- `?view=shop` `sell` `license` `field` `tasks` `board`
- `?tab=pistols` `shotguns` `rifles` `hunting` `ammo` `tools`
- `?licensed=0` to see the locked store
