const fs = require('fs');
const path = require('path');
const assert = require('assert');

const root = path.join(__dirname, '..');

const LEVEL_XP = [0, 120, 280, 500, 820, 1240, 1780, 2460, 3300, 4300];

function levelFromXP(xp) {
  let level = 1;
  for (let i = LEVEL_XP.length; i >= 1; i -= 1) {
    if (xp >= LEVEL_XP[i - 1]) {
      level = i;
      break;
    }
  }
  return level;
}

function harvestValue(harvest, prices) {
  return Object.entries(harvest).reduce((sum, [item, count]) => sum + (prices[item] || 0) * count, 0);
}

const prices = {
  animal_meat: 22,
  animal_leather: 34,
  animal_bones: 14,
  trophy_antler: 220,
  trophy_fang: 310,
  trophy_pelt: 540,
};

const animals = {
  rabbit: { level: 1, harvest: { animal_meat: 1, animal_leather: 1, animal_bones: 1 } },
  deer: { level: 6, harvest: { animal_meat: 4, animal_leather: 3, animal_bones: 3, trophy_antler: 1 } },
  panther: { level: 10, harvest: { animal_meat: 4, animal_leather: 5, animal_bones: 3, trophy_pelt: 1 } },
};

assert.strictEqual(levelFromXP(0), 1);
assert.strictEqual(levelFromXP(119), 1);
assert.strictEqual(levelFromXP(120), 2);
assert.strictEqual(levelFromXP(540), 4);
assert.strictEqual(levelFromXP(4300), 10);
assert.strictEqual(harvestValue(animals.rabbit.harvest, prices), 70);
assert.strictEqual(harvestValue(animals.deer.harvest, prices), 452);
assert.ok(harvestValue(animals.panther.harvest, prices) > harvestValue(animals.deer.harvest, prices));
assert.ok(animals.panther.level > animals.deer.level);
assert.ok(animals.deer.level > animals.rabbit.level);

const required = [
  'fxmanifest.lua',
  'config.lua',
  'data/equipment.lua',
  'README.md',
  'html/index.html',
  'html/style.css',
  'html/app.js',
  'client/main.lua',
  'client/hunting.lua',
  'server/main.lua',
  'server/bridge.lua',
  'server/stats.lua',
  'locales/en.json',
  'install/ox_inventory_items.lua',
];

for (const file of required) {
  assert.ok(fs.existsSync(path.join(root, file)), `missing ${file}`);
}

const html = fs.readFileSync(path.join(root, 'html/index.html'), 'utf8');
const css = fs.readFileSync(path.join(root, 'html/style.css'), 'utf8');
const js = fs.readFileSync(path.join(root, 'html/app.js'), 'utf8');
const config = fs.readFileSync(path.join(root, 'config.lua'), 'utf8');
const equipment = fs.readFileSync(path.join(root, 'data/equipment.lua'), 'utf8');
const items = fs.readFileSync(path.join(root, 'install/ox_inventory_items.lua'), 'utf8');
const locale = fs.readFileSync(path.join(root, 'locales/en.json'), 'utf8');

assert.match(html, /Rebel Hunting/);
assert.match(html, /DJ FIVEM SCRIPTS/);
assert.match(css, /--accent: #ff2a2a/);
assert.match(js, /buyLicense/);
assert.match(js, /SHOP_NAV/);
assert.match(js, /WEAPON_PISTOL/);
assert.match(js, /inv-icon/);
assert.match(js, /images\/\$\{give\}\.png/);
assert.match(config, /hunting_license/);
assert.match(config, /searchCooldown/);
assert.match(config, /walkDistance/);
assert.match(config, /a_c_panther/);
assert.match(config, /a_c_mtlion/);
assert.match(config, /a_c_deer/);
assert.match(config, /ammo-sniper/);
assert.match(equipment, /WEAPON_MUSKET/);
assert.match(equipment, /WEAPON_PISTOL/);
assert.match(equipment, /WEAPON_ASSAULTRIFLE/);
assert.match(equipment, /WEAPON_HEAVYSNIPER/);
assert.match(equipment, /ammo-9/);
assert.match(equipment, /ox_inventory/);
assert.match(equipment, /category = 'hunting'/);
assert.doesNotMatch(equipment, /WEAPON_SMG/);
assert.doesNotMatch(equipment, /WEAPON_MINISMG/);
assert.doesNotMatch(equipment, /WEAPON_COMBATMG/);
assert.doesNotMatch(equipment, /WEAPON_GUSENBERG/);
assert.doesNotMatch(js, /label: 'SMGs'/);
assert.match(items, /client = \{ image = 'hunting_license\.png' \}/);
assert.match(locale, /notify_need_license/);
assert.match(locale, /notify_need_axe/);
assert.match(locale, /notify_camped/);

const webImages = [
  'html/images/WEAPON_PISTOL.png',
  'html/images/WEAPON_MUSKET.png',
  'html/images/WEAPON_ASSAULTRIFLE.png',
  'html/images/WEAPON_HEAVYSNIPER.png',
  'html/images/ammo-9.png',
  'html/images/ammo-sniper.png',
  'html/images/hunting_license.png',
  'html/images/hunting_axe.png',
  'html/images/animal_meat.png',
  'html/images/animal_leather.png',
  'html/images/animal_bones.png',
  'html/images/trophy_antler.png',
  'html/images/WEAPON_TACTICALRIFLE.png',
  'html/images/WEAPON_BATTLERIFLE.png',
  'install/inventory_images/hunting_license.png',
  'install/inventory_images/hunting_axe.png',
];

for (const file of webImages) {
  assert.ok(fs.existsSync(path.join(root, file)), `missing ${file}`);
  assert.ok(fs.statSync(path.join(root, file)).size > 500, `empty ${file}`);
}

require('child_process').execFileSync(process.execPath, ['--check', path.join(root, 'html/app.js')]);

console.log('dj-hunting tests passed');
