const resourceName = (() => {
  try { return GetParentResourceName(); } catch { return null; }
})();

const inFiveM = Boolean(resourceName);
const app = document.getElementById('app');
const content = document.getElementById('content');
const stats = document.getElementById('stats');
const tabsEl = document.getElementById('tabs');
const navEl = document.getElementById('nav');
const search = document.getElementById('search');
const toastEl = document.getElementById('toast');
const playerNameEl = document.getElementById('player-name');
const playerAvatarEl = document.getElementById('player-avatar');
const playerRoleEl = document.getElementById('player-role');
const titleEl = document.getElementById('shop-title');
const subtitleEl = document.getElementById('shop-subtitle');
const hudEl = document.getElementById('hud');
const hudZone = document.getElementById('hud-zone');
const hudHint = document.getElementById('hud-hint');
const hudLevel = document.getElementById('hud-level');
const hudStatus = document.getElementById('hud-status');
const hudXp = document.getElementById('hud-xp');

const ICONS = {
  license: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><rect x="3" y="5" width="18" height="14" rx="2"/><path d="M7 12h6M7 9h10M7 15h4"/></svg>',
  shop: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M4 7h16l-1.2 12.4A2 2 0 0 1 16.81 21H7.19a2 2 0 0 1-1.99-1.6L4 7z"/><path d="M8 7V5a4 4 0 0 1 8 0v2"/></svg>',
  sell: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M4 12c4-6 12-6 16 0-4 6-12 6-16 0z"/><circle cx="12" cy="12" r="2.2"/></svg>',
  field: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M12 3c-2 6-8 9-9 9 6 1 9 6 9 9 0-3 3-8 9-9-1 0-7-3-9-9z"/></svg>',
  tasks: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>',
  board: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M4 19V5M4 19h16M8 15v4M12 11v8M16 8v11"/></svg>',
  gun: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M3 14h11l7-4v2l-4 4H10"/><path d="M8 14v4H6"/></svg>',
  axe: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M14 4l6 6-3 1-4-4 1-3z"/><path d="M12 8 4 20"/></svg>',
};

const BRAND_LOGO = '<img class="empty-logo" src="brand/logo.png" alt="DJ FiveM Scripts" decoding="async" draggable="false" />';

function emptyState(title, copy) {
  return `<div class="empty">${BRAND_LOGO}<strong>${escapeHtml(title)}</strong><p>${escapeHtml(copy)}</p></div>`;
}

function inventoryName(item) {
  return item.give || item.weapon || item.item || '';
}

function fallbackIcon(item) {
  const category = item.category;
  if (category === 'tools') return ICONS.axe;
  if (category === 'ammo') return ICONS.shop;
  if (item.weapon || ['pistols', 'shotguns', 'rifles', 'hunting', 'snipers', 'guns'].includes(category)) {
    return ICONS.gun;
  }
  if (item.rarity === 'legendary' || item.aggressive) return ICONS.field;
  return ICONS.field;
}

function iconFor(item) {
  const name = inventoryName(item);
  const src = item.image || (name ? `images/${name}.png` : '');
  const fallback = fallbackIcon(item);
  if (!src) return fallback;
  return `<img class="inv-icon" src="${escapeHtml(src)}" alt="" decoding="async" draggable="false" onerror="this.style.display='none';const s=this.nextElementSibling;if(s)s.hidden=false"/><span class="icon-fallback" hidden>${fallback}</span>`;
}

const CATEGORIES = [
  { id: 'all', label: 'All gear' },
  { id: 'pistols', label: 'Pistols' },
  { id: 'shotguns', label: 'Shotguns' },
  { id: 'rifles', label: 'Rifles' },
  { id: 'hunting', label: 'Hunting' },
  { id: 'ammo', label: 'Ammo' },
  { id: 'tools', label: 'Tools' },
];

const SELL_TABS = [
  { id: 'all', label: 'All harvest' },
  { id: 'materials', label: 'Materials' },
  { id: 'trophies', label: 'Trophies' },
];

const FIELD_TABS = [
  { id: 'all', label: 'All game' },
  { id: 'open', label: 'Unlocked' },
  { id: 'locked', label: 'Locked' },
];

const BOARD_TABS = [
  { id: 'today', label: 'Today' },
  { id: 'all', label: 'All time' },
];

const SHOP_NAV = [
  { id: 'license', label: 'License', icon: 'license' },
  { id: 'shop', label: 'Store', icon: 'shop' },
  { id: 'sell', label: 'Sell', icon: 'sell' },
  { id: 'field', label: 'Field', icon: 'field' },
  { id: 'tasks', label: 'Tasks', icon: 'tasks' },
  { id: 'board', label: 'Board', icon: 'board' },
];

function gear(item, label, category, price, level, description, extra = {}) {
  const give = extra.give || extra.weapon || item;
  return {
    item,
    give,
    label,
    description,
    category,
    price,
    level,
    weapon: extra.weapon,
    ammo: extra.ammo,
    amount: extra.amount || 1,
    image: `images/${give}.png`,
  };
}

const DEMO = {
  ok: true,
  player: { name: 'Diesel Jones', cash: 8420 },
  catalog: [
    gear('hunting_axe', 'Skinning Axe', 'tools', 220, 1, 'Rebel camp axe. Required to harvest leather, meat, and bone.'),
    gear('WEAPON_KNIFE', 'Knife', 'tools', 80, 1, 'Belt knife. Legal harvest tool on small game.', { weapon: 'WEAPON_KNIFE' }),
    gear('WEAPON_HATCHET', 'Hatchet', 'tools', 180, 1, 'Trail hatchet. Skins a carcass the same as the camp axe.', { weapon: 'WEAPON_HATCHET' }),
    gear('WEAPON_MACHETE', 'Machete', 'tools', 160, 3, 'Brush blade. Works as a harvest tool in chaparral.', { weapon: 'WEAPON_MACHETE' }),
    gear('WEAPON_STONE_HATCHET', 'Stone Hatchet', 'tools', 140, 7, 'Old stone head. Still legal for a Rebel harvest.', { weapon: 'WEAPON_STONE_HATCHET' }),
    gear('WEAPON_BATTLEAXE', 'Battle Axe', 'tools', 280, 7, 'Heavy camp axe. Fastest legal skinning tool on the board.', { weapon: 'WEAPON_BATTLEAXE' }),
    gear('WEAPON_SNSPISTOL', 'SNS Pistol', 'pistols', 480, 1, 'Pocket .45. Quiet starter sidearm for farm country.', { weapon: 'WEAPON_SNSPISTOL', ammo: 'ammo-45' }),
    gear('WEAPON_PISTOL', 'Pistol', 'pistols', 650, 1, 'Standard 9mm. Legal on rabbits, birds, and farm stock.', { weapon: 'WEAPON_PISTOL', ammo: 'ammo-9' }),
    gear('WEAPON_COMBATPISTOL', 'Combat Pistol', 'pistols', 780, 1, 'Compact 9mm. Cleaner follow-up shots in brush.', { weapon: 'WEAPON_COMBATPISTOL', ammo: 'ammo-9' }),
    gear('WEAPON_VINTAGEPISTOL', 'Vintage Pistol', 'pistols', 720, 1, 'Old Rebel 9mm. Slow, honest, still legal.', { weapon: 'WEAPON_VINTAGEPISTOL', ammo: 'ammo-9' }),
    gear('WEAPON_HEAVYPISTOL', 'Heavy Pistol', 'pistols', 1100, 2, '.45 sidearm with more punch on pigs and coyote.', { weapon: 'WEAPON_HEAVYPISTOL', ammo: 'ammo-45' }),
    gear('WEAPON_CERAMICPISTOL', 'Ceramic Pistol', 'pistols', 980, 2, 'Light 9mm. Easy to carry on long walks.', { weapon: 'WEAPON_CERAMICPISTOL', ammo: 'ammo-9' }),
    gear('WEAPON_DOUBLEACTION', 'Double Action Revolver', 'pistols', 1250, 2, '.38 wheelgun. Classic trail pistol.', { weapon: 'WEAPON_DOUBLEACTION', ammo: 'ammo-38' }),
    gear('WEAPON_PISTOLXM3', 'WM 29 Pistol', 'pistols', 1350, 2, 'Modern 9mm. Tight groups on small game.', { weapon: 'WEAPON_PISTOLXM3', ammo: 'ammo-9' }),
    gear('WEAPON_APPISTOL', 'AP Pistol', 'pistols', 2100, 3, 'Full-auto 9mm. Burns ammo. Legal if you stay licensed.', { weapon: 'WEAPON_APPISTOL', ammo: 'ammo-9' }),
    gear('WEAPON_PISTOL50', 'Pistol .50', 'pistols', 2400, 3, 'Heavy desert pistol. Stops a boar at close range.', { weapon: 'WEAPON_PISTOL50', ammo: 'ammo-50' }),
    gear('WEAPON_REVOLVER', 'Revolver', 'pistols', 1850, 3, '.44 Magnum. Senora and canyon work.', { weapon: 'WEAPON_REVOLVER', ammo: 'ammo-44' }),
    gear('WEAPON_MARKSMANPISTOL', 'Marksman Pistol', 'pistols', 1600, 3, 'Single-shot .22. Precision small-game pistol.', { weapon: 'WEAPON_MARKSMANPISTOL', ammo: 'ammo-22' }),
    gear('WEAPON_PISTOL_MK2', 'Pistol MK2', 'pistols', 2800, 5, 'Refined 9mm. Better glass, same legal take.', { weapon: 'WEAPON_PISTOL_MK2', ammo: 'ammo-9' }),
    gear('WEAPON_SNSPISTOL_MK2', 'SNS Pistol MK2', 'pistols', 2200, 5, 'Tuned pocket .45. Light for ridge walks.', { weapon: 'WEAPON_SNSPISTOL_MK2', ammo: 'ammo-45' }),
    gear('WEAPON_GADGETPISTOL', 'Perico Pistol', 'pistols', 3200, 5, 'Heavy 9mm single-stack. Hard-hitting close work.', { weapon: 'WEAPON_GADGETPISTOL', ammo: 'ammo-9' }),
    gear('WEAPON_NAVYREVOLVER', 'Navy Revolver', 'pistols', 2600, 5, 'Antique .44. Slow cylinder, serious punch.', { weapon: 'WEAPON_NAVYREVOLVER', ammo: 'ammo-44' }),
    gear('WEAPON_REVOLVER_MK2', 'Revolver MK2', 'pistols', 3800, 10, 'Apex wheelgun. Summit kit if you hunt close.', { weapon: 'WEAPON_REVOLVER_MK2', ammo: 'ammo-44' }),
    gear('WEAPON_SAWNOFFSHOTGUN', 'Sawn Off Shotgun', 'shotguns', 1400, 3, 'Short 12ga. Close brush and hogs.', { weapon: 'WEAPON_SAWNOFFSHOTGUN', ammo: 'ammo-shotgun' }),
    gear('WEAPON_DBSHOTGUN', 'Double Barrel Shotgun', 'shotguns', 1550, 3, 'Two barrels. Honest farm and chaparral gun.', { weapon: 'WEAPON_DBSHOTGUN', ammo: 'ammo-shotgun' }),
    gear('WEAPON_PUMPSHOTGUN', 'Pump Shotgun', 'shotguns', 1850, 3, 'Chaparral 12ga. Pigs, boar, and coyote.', { weapon: 'WEAPON_PUMPSHOTGUN', ammo: 'ammo-shotgun' }),
    gear('WEAPON_BULLPUPSHOTGUN', 'Bullpup Shotgun', 'shotguns', 2300, 4, 'Compact 12ga. Tight timber shots.', { weapon: 'WEAPON_BULLPUPSHOTGUN', ammo: 'ammo-shotgun' }),
    gear('WEAPON_HEAVYSHOTGUN', 'Heavy Shotgun', 'shotguns', 3200, 5, 'Box-fed 12ga. Thick hide country.', { weapon: 'WEAPON_HEAVYSHOTGUN', ammo: 'ammo-shotgun' }),
    gear('WEAPON_PUMPSHOTGUN_MK2', 'Pump Shotgun MK2', 'shotguns', 3900, 6, 'Tuned pump. Deer and canyon work.', { weapon: 'WEAPON_PUMPSHOTGUN_MK2', ammo: 'ammo-shotgun' }),
    gear('WEAPON_COMPACTRIFLE', 'Compact Rifle', 'rifles', 2800, 4, 'Short 7.62. First real woods rifle.', { weapon: 'WEAPON_COMPACTRIFLE', ammo: 'ammo-rifle2' }),
    gear('WEAPON_ASSAULTRIFLE', 'Assault Rifle', 'rifles', 3600, 5, '7.62 service rifle. Mid-country workhorse.', { weapon: 'WEAPON_ASSAULTRIFLE', ammo: 'ammo-rifle2' }),
    gear('WEAPON_CARBINERIFLE', 'Carbine Rifle', 'rifles', 3800, 5, '5.56 carbine. Senora and canyon glass.', { weapon: 'WEAPON_CARBINERIFLE', ammo: 'ammo-rifle' }),
    gear('WEAPON_ADVANCEDRIFLE', 'Advanced Rifle', 'rifles', 4100, 5, 'Bullpup 5.56. Fast handling in timber.', { weapon: 'WEAPON_ADVANCEDRIFLE', ammo: 'ammo-rifle' }),
    gear('WEAPON_SPECIALCARBINE', 'Special Carbine', 'rifles', 4300, 6, '5.56 all-rounder. Opens deer country.', { weapon: 'WEAPON_SPECIALCARBINE', ammo: 'ammo-rifle' }),
    gear('WEAPON_BULLPUPRIFLE', 'Bullpup Rifle', 'rifles', 4000, 6, 'Compact 5.56. Tight canyon shots.', { weapon: 'WEAPON_BULLPUPRIFLE', ammo: 'ammo-rifle' }),
    gear('WEAPON_MILITARYRIFLE', 'Military Rifle', 'rifles', 4500, 6, 'Service 5.56. Steady on a ridge.', { weapon: 'WEAPON_MILITARYRIFLE', ammo: 'ammo-rifle' }),
    gear('WEAPON_TACTICALRIFLE', 'Tactical Rifle', 'rifles', 4800, 7, 'Long 5.56. Glass a line, do not camp it.', { weapon: 'WEAPON_TACTICALRIFLE', ammo: 'ammo-rifle' }),
    gear('WEAPON_BATTLERIFLE', 'Battle Rifle', 'rifles', 5200, 7, 'Heavy 7.62. Mountain lion country.', { weapon: 'WEAPON_BATTLERIFLE', ammo: 'ammo-rifle2' }),
    gear('WEAPON_HEAVYRIFLE', 'Heavy Rifle', 'rifles', 5400, 7, 'Hard-hitting 5.56. Cat country rifle.', { weapon: 'WEAPON_HEAVYRIFLE', ammo: 'ammo-rifle' }),
    gear('WEAPON_ASSAULTRIFLE_MK2', 'Assault Rifle MK2', 'rifles', 6200, 8, 'Tuned 7.62. High-country workhorse.', { weapon: 'WEAPON_ASSAULTRIFLE_MK2', ammo: 'ammo-rifle2' }),
    gear('WEAPON_CARBINERIFLE_MK2', 'Carbine Rifle MK2', 'rifles', 6400, 8, 'Tuned 5.56. Precision ridge rifle.', { weapon: 'WEAPON_CARBINERIFLE_MK2', ammo: 'ammo-rifle' }),
    gear('WEAPON_SPECIALCARBINE_MK2', 'Special Carbine MK2', 'rifles', 6600, 8, 'Apex 5.56 carbine. Summit kit.', { weapon: 'WEAPON_SPECIALCARBINE_MK2', ammo: 'ammo-rifle' }),
    gear('WEAPON_BULLPUPRIFLE_MK2', 'Bullpup Rifle MK2', 'rifles', 6800, 9, 'Tuned bullpup. Tight timber at rank nine.', { weapon: 'WEAPON_BULLPUPRIFLE_MK2', ammo: 'ammo-rifle' }),
    gear('WEAPON_MUSKET', 'Musket', 'hunting', 850, 1, 'Old Rebel trail gun. Legal on rabbits, birds, and farm stock.', { weapon: 'WEAPON_MUSKET', ammo: 'ammo-musket' }),
    gear('WEAPON_MARKSMANRIFLE', 'Marksman Rifle', 'hunting', 4200, 6, 'Semi 7.62. Opens deer and canyon game.', { weapon: 'WEAPON_MARKSMANRIFLE', ammo: 'ammo-sniper' }),
    gear('WEAPON_PRECISIONRIFLE', 'Precision Rifle', 'hunting', 7200, 7, 'Bolt 7.62. One clean shot, then walk.', { weapon: 'WEAPON_PRECISIONRIFLE', ammo: 'ammo-sniper' }),
    gear('WEAPON_SNIPERRIFLE', 'Sniper Rifle', 'hunting', 7800, 7, 'Long glass for mountain lion country.', { weapon: 'WEAPON_SNIPERRIFLE', ammo: 'ammo-sniper' }),
    gear('WEAPON_MARKSMANRIFLE_MK2', 'Marksman Rifle MK2', 'hunting', 9200, 8, 'Tuned marksman. Cat country glass.', { weapon: 'WEAPON_MARKSMANRIFLE_MK2', ammo: 'ammo-sniper' }),
    gear('WEAPON_HEAVYSNIPER', 'Heavy Sniper', 'hunting', 14500, 9, '.50 BMG. Top-end hunting rifle for panther country.', { weapon: 'WEAPON_HEAVYSNIPER', ammo: 'ammo-heavysniper' }),
    gear('WEAPON_HEAVYSNIPER_MK2', 'Heavy Sniper MK2', 'hunting', 18500, 10, 'Apex .50. Highest Rebel glass on the mountain.', { weapon: 'WEAPON_HEAVYSNIPER_MK2', ammo: 'ammo-heavysniper' }),
    gear('ammo-9', '9mm', 'ammo', 12, 1, 'Pistol ammunition.', { amount: 24 }),
    gear('ammo-45', '.45 ACP', 'ammo', 13, 1, 'SNS and heavy pistol ammunition.', { amount: 24 }),
    gear('ammo-musket', '.50 Ball', 'ammo', 8, 1, 'Paper loads for the Musket.', { amount: 10 }),
    gear('ammo-38', '.38 LC', 'ammo', 14, 2, 'Double-action revolver loads.', { amount: 12 }),
    gear('ammo-22', '.22 Long Rifle', 'ammo', 10, 3, 'Marksman pistol ammunition.', { amount: 16 }),
    gear('ammo-44', '.44 Magnum', 'ammo', 16, 3, 'Revolver and Navy loads.', { amount: 12 }),
    gear('ammo-50', '.50 AE', 'ammo', 22, 3, 'Pistol .50 ammunition.', { amount: 12 }),
    gear('ammo-shotgun', '12 Gauge', 'ammo', 14, 3, 'Buckshot for every lodge shotgun.', { amount: 16 }),
    gear('ammo-rifle', '5.56x45', 'ammo', 16, 4, 'Carbine and 5.56 rifle ammunition.', { amount: 30 }),
    gear('ammo-rifle2', '7.62x39', 'ammo', 18, 4, 'Assault rifle and battle rifle ammunition.', { amount: 30 }),
    gear('ammo-sniper', '7.62x51', 'ammo', 28, 6, 'Marksman and sniper ammunition.', { amount: 12 }),
    gear('ammo-heavysniper', '.50 BMG', 'ammo', 35, 9, 'Heavy sniper ammunition.', { amount: 8 }),
  ],
  goods: [
    { item: 'animal_meat', label: 'Game Meat', description: 'Cleaned cuts.', rarity: 'common', price: 22, count: 8, image: 'images/animal_meat.png' },
    { item: 'animal_leather', label: 'Hide', description: 'Salted hide.', rarity: 'common', price: 34, count: 5, image: 'images/animal_leather.png' },
    { item: 'animal_bones', label: 'Bones', description: 'Clean bone.', rarity: 'common', price: 14, count: 6, image: 'images/animal_bones.png' },
    { item: 'trophy_antler', label: 'Trophy Antler', description: 'A heavy rack.', rarity: 'legendary', price: 220, count: 1, image: 'images/trophy_antler.png' },
    { item: 'trophy_fang', label: 'Predator Fang', description: 'Taken from a legal mountain cat.', rarity: 'legendary', price: 310, count: 1, image: 'images/trophy_fang.png' },
    { item: 'trophy_pelt', label: 'Rebel Pelt', description: 'Apex hide.', rarity: 'legendary', price: 540, count: 1, image: 'images/trophy_pelt.png' },
  ],
  field: [
    { id: 'rabbit', label: 'Rabbit', description: 'Starter game.', level: 1, xp: 18, rarity: 'common', payout: 70 },
    { id: 'hen', label: 'Hen', description: 'Farmyard bird.', level: 1, xp: 14, rarity: 'common', payout: 36 },
    { id: 'pigeon', label: 'Pigeon', description: 'Good for learning the glass.', level: 1, xp: 12, rarity: 'common', payout: 36 },
    { id: 'crow', label: 'Crow', description: 'Watchful.', level: 2, xp: 20, rarity: 'common', payout: 36 },
    { id: 'seagull', label: 'Seagull', description: 'Coastal bird.', level: 2, xp: 18, rarity: 'common', payout: 36 },
    { id: 'cormorant', label: 'Cormorant', description: 'Water bird.', level: 2, xp: 24, rarity: 'uncommon', payout: 70 },
    { id: 'hawk', label: 'Hawk', description: 'Harder shot, better XP.', level: 3, xp: 40, rarity: 'uncommon', payout: 70 },
    { id: 'pig', label: 'Pig', description: 'Thick hide, honest meat.', level: 3, xp: 48, rarity: 'uncommon', payout: 162 },
    { id: 'cow', label: 'Cow', description: 'Heavy harvest.', level: 4, xp: 55, rarity: 'uncommon', payout: 218 },
    { id: 'boar', label: 'Boar', description: 'Will charge if you crowd it.', level: 4, xp: 70, rarity: 'uncommon', payout: 196 },
    { id: 'coyote', label: 'Coyote', description: 'Night runner of Senora.', level: 5, xp: 85, rarity: 'rare', payout: 174 },
    { id: 'deer', label: 'Deer', description: 'The Rebel paycheck.', level: 6, xp: 120, rarity: 'rare', payout: 452 },
    { id: 'mtlion', label: 'Mountain Lion', description: 'It hunts back.', level: 8, xp: 180, rarity: 'legendary', payout: 438 },
    { id: 'panther', label: 'Panther', description: 'Apex of San Andreas.', level: 10, xp: 260, rarity: 'legendary', payout: 840 },
  ],
  equipment: { hunting_axe: 1, WEAPON_MUSKET: 1, 'ammo-musket': 20, WEAPON_PISTOL: 1 },
  tasks: [
    { id: 'harvest_any', label: 'Walk the woods', description: 'Harvest 6 animals of any kind today.', count: 6, progress: 3, claimed: false, reward: 220, rewardItems: [] },
    { id: 'harvest_small', label: 'Small game', description: 'Harvest 4 rabbits, hens, or birds.', count: 4, progress: 4, claimed: false, reward: 180, rewardItems: [] },
    { id: 'harvest_deer', label: 'Rack run', description: 'Harvest 2 deer.', count: 2, progress: 0, claimed: false, reward: 350, rewardItems: [] },
    { id: 'harvest_predator', label: 'Cat country', description: 'Harvest a coyote, mountain lion, or panther.', count: 1, progress: 0, claimed: false, reward: 500, rewardItems: [{ item: 'ammo-sniper', count: 2, label: '7.62x51' }] },
    { id: 'sell_cash', label: 'Lodge payout', description: 'Sell $500 worth of harvest today.', count: 500, progress: 210, claimed: false, reward: 150, rewardItems: [] },
  ],
  board: {
    dailyHarvest: { rows: [{ rank: 1, name: 'Diesel Jones', value: 9, me: true }, { rank: 2, name: 'Kai', value: 6 }], you: { rank: 1, value: 9 } },
    dailyMoney: { rows: [{ rank: 1, name: 'Kai', value: 980 }, { rank: 2, name: 'Diesel Jones', value: 640, me: true }], you: { rank: 2, value: 640 } },
    harvest: { rows: [{ rank: 1, name: 'Kai', value: 140 }, { rank: 2, name: 'Diesel Jones', value: 41, me: true }], you: { rank: 2, value: 41 } },
    money: { rows: [{ rank: 1, name: 'Kai', value: 18400 }, { rank: 2, name: 'Diesel Jones', value: 3120, me: true }], you: { rank: 2, value: 3120 } },
  },
  you: { harvests: 41, money: 3120, dailyHarvest: 9, dailyMoney: 640, xp: 540, level: 4 },
  hunter: { level: 4, xp: 540, toNext: 280, floor: 500, next: 820, max: 10, licensed: true, harvests: 41 },
  licensed: true,
  licensedFlag: true,
  license: { item: 'hunting_license', label: 'Rebel Hunting License', description: 'Issued by Rebel Ranger Lodge.', price: 450, owned: true, image: 'images/hunting_license.png' },
  resetsIn: 14600,
};

const SHOP_VIEWS = new Set(['license', 'shop', 'sell', 'field', 'tasks', 'board']);
const NUI_ACTIONS = new Set(['close', 'buy', 'sell', 'sellAll', 'buyLicense', 'claimTask', 'refresh']);

const HUD_COPY = {
  searching: 'Glassing the line',
  ready: 'Game in the area',
  camped: 'Keep walking',
  cooldown: 'Woods settling',
  search: 'Walk off the last take',
  nolicense: 'No license',
  idle: 'Outside a ground',
};

const state = {
  view: 'shop',
  tab: 'all',
  query: '',
  qty: {},
  shop: { label: 'Rebel Hunting', subtitle: 'forest outfitter', views: ['license', 'shop', 'sell', 'field', 'tasks', 'board'], sellsLicense: true },
  player: { name: 'Hunter', cash: 0 },
  catalog: [],
  goods: [],
  field: [],
  equipment: {},
  tasks: [],
  board: { dailyHarvest: { rows: [] }, dailyMoney: { rows: [] }, harvest: { rows: [] }, money: { rows: [] } },
  you: { harvests: 0, money: 0, dailyHarvest: 0, dailyMoney: 0 },
  hunter: { level: 1, xp: 0, toNext: 120, max: 10, licensed: false, harvests: 0 },
  licensed: false,
  licensedFlag: false,
  license: { label: 'Rebel Hunting License', price: 450, owned: false, description: '', image: 'images/hunting_license.png' },
  resetsIn: 0,
  brand: { name: 'Rebel Roleplay', role: 'Licensed hunter', initials: 'RR' },
  busy: false,
};

function money(n) {
  return '$' + Math.floor(Number(n) || 0).toLocaleString('en-US');
}

function escapeHtml(value) {
  return String(value ?? '').replace(/[&<>"']/g, (ch) => ({
    '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;',
  }[ch]));
}

function initials(name) {
  return (name || 'RR').split(/\s+/).filter(Boolean).map((p) => p[0]).join('').slice(0, 3).toUpperCase() || 'RR';
}

function toast(message) {
  if (!message) return;
  toastEl.textContent = message;
  toastEl.classList.remove('hidden');
  clearTimeout(toast.timer);
  toast.timer = setTimeout(() => toastEl.classList.add('hidden'), 2200);
}

async function nui(name, payload = {}) {
  if (!NUI_ACTIONS.has(name)) return { ok: false };
  if (!inFiveM) return mockNui(name, payload);
  const res = await fetch(`https://${resourceName}/${name}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    body: JSON.stringify(payload),
  });
  try { return await res.json(); } catch { return { ok: false }; }
}

function mockNui(name, payload) {
  if (name === 'close') return { ok: true };
  if (name === 'buyLicense') {
    if (state.licensed) return { ok: false, error: 'Already licensed' };
    if (state.player.cash < state.license.price) return { ok: false };
    state.player.cash -= state.license.price;
    state.licensed = true;
    state.licensedFlag = true;
    state.license.owned = true;
    state.hunter.licensed = true;
    return { ok: true, refresh: currentPayload() };
  }
  if (name === 'buy') {
    const item = state.catalog.find((i) => i.item === payload.item);
    const amount = Math.max(1, Math.min(50, payload.amount || 1));
    if (!item) return { ok: false };
    if (!state.licensed) return { ok: false };
    if ((state.hunter.level || 1) < (item.level || 1)) return { ok: false };
    const total = item.price * amount;
    if (state.player.cash < total) return { ok: false };
    state.player.cash -= total;
    state.equipment[item.item] = (state.equipment[item.item] || 0) + amount * (item.amount || 1);
    return { ok: true, amount: amount * (item.amount || 1), label: item.label, total, refresh: currentPayload() };
  }
  if (name === 'sell') {
    const good = state.goods.find((i) => i.item === payload.item);
    if (!good) return { ok: false };
    const amount = Math.min(payload.amount || 1, good.count);
    good.count -= amount;
    const total = good.price * amount;
    state.player.cash += total;
    state.goods = state.goods.filter((f) => f.count > 0);
    return { ok: true, amount, label: good.label, total, refresh: currentPayload() };
  }
  if (name === 'sellAll') {
    const total = state.goods.reduce((sum, f) => sum + f.price * f.count, 0);
    state.player.cash += total;
    state.goods = [];
    return { ok: true, total, refresh: currentPayload() };
  }
  if (name === 'claimTask') {
    const task = state.tasks.find((t) => t.id === payload.id);
    if (!task || task.claimed || task.progress < task.count) return { ok: false };
    task.claimed = true;
    state.player.cash += task.reward || 0;
    return { ok: true, money: task.reward, label: task.label, refresh: currentPayload() };
  }
  return currentPayload();
}

function currentPayload() {
  return {
    ok: true,
    player: state.player,
    catalog: state.catalog,
    goods: state.goods,
    field: state.field,
    equipment: state.equipment,
    tasks: state.tasks,
    board: state.board,
    you: state.you,
    hunter: state.hunter,
    licensed: state.licensed,
    licensedFlag: state.licensedFlag,
    license: state.license,
    resetsIn: state.resetsIn,
  };
}

function toArray(value) {
  if (!value) return [];
  if (Array.isArray(value)) return value;
  return Object.keys(value)
    .sort((a, b) => Number(a) - Number(b))
    .map((key) => value[key])
    .filter((entry) => entry && typeof entry === 'object' && (entry.item || entry.label || entry.id));
}

function applyPayload(payload) {
  if (!payload || payload.ok === false) return;

  if (payload.player) {
    state.player = {
      name: payload.player.name || state.player.name,
      cash: Number(payload.player.cash != null ? payload.player.cash : payload.cash || 0),
    };
  } else if (payload.cash != null) {
    state.player.cash = Number(payload.cash) || 0;
  }

  const catalog = toArray(payload.catalog);
  if (catalog.length) state.catalog = catalog;
  if (payload.goods) state.goods = toArray(payload.goods);
  if (payload.field) state.field = toArray(payload.field);
  if (payload.equipment && !Array.isArray(payload.equipment)) state.equipment = payload.equipment;
  if (payload.tasks) state.tasks = toArray(payload.tasks);
  if (payload.board) state.board = payload.board;
  if (payload.you) state.you = payload.you;
  if (payload.hunter) state.hunter = payload.hunter;
  if (payload.license) state.license = { ...state.license, ...payload.license };
  if (payload.licensed != null) state.licensed = payload.licensed === true;
  if (payload.licensedFlag != null) state.licensedFlag = payload.licensedFlag === true;
  if (payload.resetsIn != null) state.resetsIn = Number(payload.resetsIn) || 0;
  if (payload.shop) state.shop = { ...state.shop, ...payload.shop };
  if (payload.brand) state.brand = { ...state.brand, ...payload.brand };

  playerNameEl.textContent = state.player.name;
  playerAvatarEl.textContent = initials(state.player.name);
  render();
}

function allowedViews() {
  return state.shop.views && state.shop.views.length ? state.shop.views : [...SHOP_VIEWS];
}

function setView(view) {
  if (!SHOP_VIEWS.has(view)) return;
  if (!allowedViews().includes(view)) return;
  state.view = view;
  state.tab = view === 'board' ? 'today' : 'all';
  state.query = '';
  search.value = '';
  render();
}

function ownedCount(item) {
  return state.equipment[item] || 0;
}

function qtyFor(item, max) {
  const current = state.qty[item] || 1;
  return Math.max(1, Math.min(max || 50, current));
}

function formatReset(seconds) {
  seconds = Math.max(0, Math.floor(Number(seconds) || 0));
  const h = Math.floor(seconds / 3600);
  const m = Math.floor((seconds % 3600) / 60);
  if (h > 0) return `${h}h ${m}m`;
  return `${m}m`;
}

function rankLabel(rank) {
  return rank ? `#${rank}` : '—';
}

function renderNav() {
  const items = SHOP_NAV.filter((item) => allowedViews().includes(item.id));
  navEl.innerHTML = items.map((item) => `
    <button type="button" class="nav-btn ${state.view === item.id ? 'active' : ''}" data-view="${item.id}" title="${item.label}" aria-label="${item.label}">
      ${ICONS[item.icon] || ''}
    </button>
  `).join('');
}

function renderStats() {
  const h = state.hunter || {};
  const goodsCount = state.goods.reduce((a, f) => a + f.count, 0);
  const value = state.goods.reduce((a, f) => a + f.price * f.count, 0);
  const done = state.tasks.filter((t) => t.progress >= t.count).length;
  const claimed = state.tasks.filter((t) => t.claimed).length;
  const guns = state.catalog.filter((i) => i.weapon && ownedCount(i.item) > 0).length;

  let cards;
  if (state.view === 'license') {
    cards = [
      { label: 'Hunter rank', value: `L${h.level || 1}`, hint: 'XP' },
      { label: 'License', value: state.licensed ? 'Valid' : 'Needed', hint: 'RANGER' },
      { label: 'Cash on hand', value: money(state.player.cash), hint: 'WALLET' },
    ];
  } else if (state.view === 'shop') {
    cards = [
      { label: 'Cash on hand', value: money(state.player.cash), hint: 'WALLET' },
      { label: 'Hunter rank', value: `L${h.level || 1}`, hint: `${h.xp || 0} XP` },
      { label: 'Guns owned', value: String(guns), hint: 'LOADOUT' },
    ];
  } else if (state.view === 'sell') {
    cards = [
      { label: 'Cash on hand', value: money(state.player.cash), hint: 'WALLET' },
      { label: 'In the satchel', value: String(goodsCount), hint: 'HARVEST' },
      { label: 'Market value', value: money(value), hint: 'PAYOUT' },
    ];
  } else if (state.view === 'field') {
    const open = state.field.filter((a) => (h.level || 1) >= (a.level || 1)).length;
    cards = [
      { label: 'Hunter rank', value: `L${h.level || 1}`, hint: 'FIELD' },
      { label: 'Unlocked game', value: `${open}/${state.field.length || 0}`, hint: 'BESTIARY' },
      { label: 'Lifetime takes', value: String(h.harvests || 0), hint: 'LOG' },
    ];
  } else if (state.view === 'tasks') {
    cards = [
      { label: 'Tasks done', value: `${done}/${state.tasks.length || 0}`, hint: 'TODAY' },
      { label: 'Rewards claimed', value: String(claimed), hint: 'CLAIMED' },
      { label: 'Resets in', value: formatReset(state.resetsIn), hint: 'DAILY' },
    ];
  } else {
    cards = [
      { label: 'Takes today', value: String(state.you.dailyHarvest || 0), hint: 'HARVEST' },
      { label: 'Sold today', value: money(state.you.dailyMoney || 0), hint: 'CASH' },
      { label: 'Your rank', value: rankLabel(state.board.dailyHarvest && state.board.dailyHarvest.you && state.board.dailyHarvest.you.rank), hint: 'TODAY' },
    ];
  }

  stats.innerHTML = cards.map((c) => `
    <article class="stat">
      <span>${c.label}</span>
      <strong>${escapeHtml(c.value)}</strong>
      <em>${escapeHtml(c.hint)}</em>
    </article>
  `).join('');
}

function renderTabs() {
  const toolbar = document.querySelector('.toolbar');
  const hideSearch = state.view === 'tasks' || state.view === 'board' || state.view === 'license';
  toolbar.classList.toggle('search-hidden', hideSearch);

  let tabs = [];
  if (state.view === 'shop') tabs = CATEGORIES;
  else if (state.view === 'sell') tabs = SELL_TABS;
  else if (state.view === 'field') tabs = FIELD_TABS;
  else if (state.view === 'board') tabs = BOARD_TABS;

  tabsEl.innerHTML = tabs.map((tab) => `
    <button type="button" class="tab ${state.tab === tab.id ? 'active' : ''}" data-tab="${tab.id}">${tab.label}</button>
  `).join('') + (state.view === 'sell' ? '<button type="button" class="tab" data-tab="sellall">Sell all</button>' : '');
}

function matchesQuery(item) {
  const q = state.query.trim().toLowerCase();
  if (!q) return true;
  return `${item.label} ${item.description} ${item.item || ''} ${item.id || ''} ${item.category || ''} ${item.rarity || ''}`.toLowerCase().includes(q);
}

function renderLicense() {
  const owned = state.licensed;
  const price = state.license.price || 450;
  const canBuy = !owned && (state.shop.sellsLicense !== false);
  const licenseImage = state.license.image || 'images/hunting_license.png';
  content.innerHTML = `
    <div class="license-hero">
      <div class="license-art">
        <img src="${escapeHtml(licenseImage)}" alt="" decoding="async" draggable="false" />
      </div>
      <div>
        <h3>${owned ? 'Papers in order' : 'Rebel hunting license'}</h3>
        <p>${escapeHtml(state.license.description || 'Buy this from the Ranger Lodge before you can purchase guns, ammo, or the skinning axe.')}</p>
        <p>${owned ? 'You are cleared to buy gear and harvest legal game.' : 'The lodge ranger issues the only valid card. Outfitters will not sell to you without it.'}</p>
      </div>
      <button type="button" class="btn" data-act="license" ${canBuy ? '' : 'disabled'}>
        ${owned ? 'Licensed' : `${money(price)} · Buy license`}
      </button>
    </div>
    <article class="card">
      <div class="card-head">
        <div class="icon">${ICONS.field}</div>
        <span class="badge">${owned ? 'cleared' : 'locked'}</span>
      </div>
      <div>
        <h3>How Rebel hunting works</h3>
        <p>Buy the license, then an axe and a trail gun. Walk a marked ground. Animals only show if you keep moving. After a harvest, walk off the carcass and wait — camping dries up the woods. Skin with the axe for meat, hide, and bone.</p>
      </div>
    </article>
  `;
}

function renderShop() {
  if (!state.licensed) {
    content.innerHTML = emptyState('License required', 'The ranger at Rebel Lodge has to issue your papers before this counter opens.');
    return;
  }

  const items = state.catalog.filter((item) => (state.tab === 'all' || item.category === state.tab) && matchesQuery(item));
  if (!items.length) {
    content.innerHTML = emptyState('No gear matches', 'Try another tab or search the lodge.');
    return;
  }

  const level = state.hunter.level || 1;
  content.innerHTML = items.map((item) => {
    const qty = qtyFor(item.item, 50);
    const owned = ownedCount(item.item);
    const locked = level < (item.level || 1);
    const spawn = item.weapon ? ` · ${item.weapon}` : '';
    return `
      <article class="card" data-item="${escapeHtml(item.item)}">
        <div class="card-head">
          <div class="icon">${iconFor(item)}</div>
          <span class="badge ${locked ? 'locked' : ''}">${locked ? `L${item.level}` : escapeHtml(item.category)}</span>
        </div>
        <div>
          <h3>${escapeHtml(item.label)}</h3>
          <p>${escapeHtml(item.description)}${escapeHtml(spawn)}</p>
        </div>
        <div class="meta-row">
          <div class="price">${money(item.price)} <span>${item.amount && item.amount > 1 ? ` / ${item.amount}` : 'each'}</span></div>
          <span class="badge">Owned ${owned} · L${item.level || 1}</span>
        </div>
        <div class="buy-row">
          <div class="qty">
            <button type="button" data-act="minus">-</button>
            <b>${qty}</b>
            <button type="button" data-act="plus">+</button>
          </div>
          <button type="button" class="btn" data-act="buy" ${locked ? 'disabled' : ''}>${locked ? `Rank ${item.level}` : `${money(item.price * qty)} · Buy`}</button>
        </div>
      </article>
    `;
  }).join('');
}

function isTrophy(item) {
  return String(item.item || '').startsWith('trophy_') || item.rarity === 'legendary';
}

function renderSell() {
  const items = state.goods.filter((item) => {
    if (!matchesQuery(item)) return false;
    if (state.tab === 'trophies') return isTrophy(item);
    if (state.tab === 'materials') return !isTrophy(item);
    return true;
  });
  if (!items.length) {
    content.innerHTML = emptyState('Empty satchel', 'Walk a hunting ground, harvest with the axe, then sell meat, hide, and bone here.');
    return;
  }

  content.innerHTML = items.map((item) => {
    const qty = qtyFor(item.item, item.count);
    return `
      <article class="card" data-item="${escapeHtml(item.item)}">
        <div class="card-head">
          <div class="icon">${iconFor(item)}</div>
          <span class="badge ${escapeHtml(item.rarity || '')}">${escapeHtml(item.rarity || 'harvest')}</span>
        </div>
        <div>
          <h3>${escapeHtml(item.label)}</h3>
          <p>${escapeHtml(item.description)}</p>
        </div>
        <div class="meta-row">
          <div class="price">${money(item.price)} <span>each</span></div>
          <span class="badge">x${item.count} · ${money(item.price * item.count)}</span>
        </div>
        <div class="sell-row">
          <div class="qty">
            <button type="button" data-act="minus">-</button>
            <b>${qty}</b>
            <button type="button" data-act="plus">+</button>
          </div>
          <button type="button" class="btn ghost" data-act="sellone">Sell ${qty}</button>
          <button type="button" class="btn" data-act="sellstack">Sell all</button>
        </div>
      </article>
    `;
  }).join('');
}

function renderField() {
  const level = state.hunter.level || 1;
  const items = state.field.filter((item) => {
    if (!matchesQuery(item)) return false;
    const open = level >= (item.level || 1);
    if (state.tab === 'open') return open;
    if (state.tab === 'locked') return !open;
    return true;
  });
  if (!items.length) {
    content.innerHTML = emptyState('No game listed', 'Rank up or clear the search.');
    return;
  }

  content.innerHTML = items.map((item) => {
    const open = level >= (item.level || 1);
    return `
      <article class="card">
        <div class="card-head">
          <div class="icon">${ICONS.field}</div>
          <span class="badge ${open ? escapeHtml(item.rarity || '') : 'locked'}">${open ? escapeHtml(item.rarity) : `L${item.level}`}</span>
        </div>
        <div>
          <h3>${escapeHtml(item.label)}</h3>
          <p>${escapeHtml(item.description)}</p>
        </div>
        <div class="meta-row">
          <div class="price">${money(item.payout || 0)} <span>hideout</span></div>
          <span class="badge">${item.xp || 0} XP · L${item.level}</span>
        </div>
      </article>
    `;
  }).join('');
}

function renderTasks() {
  const items = state.tasks.filter((item) => matchesQuery(item));
  if (!items.length) {
    content.innerHTML = emptyState('No daily tasks', 'Come back after the next reset.');
    return;
  }

  content.innerHTML = items.map((task) => {
    const pct = Math.min(100, Math.round(((task.progress || 0) / (task.count || 1)) * 100));
    const ready = !task.claimed && (task.progress || 0) >= task.count;
    const extras = (task.rewardItems || []).map((item) => `${item.count}x ${item.label}`).join(', ');
    let action = `<button type="button" class="btn" disabled>In progress</button>`;
    if (task.claimed) action = `<button type="button" class="btn ghost" disabled>Claimed</button>`;
    else if (ready) action = `<button type="button" class="btn" data-act="claim">Claim ${money(task.reward)}</button>`;
    return `
      <article class="card task-card" data-task="${escapeHtml(task.id)}">
        <div class="card-head">
          <div class="icon">${ICONS.field}</div>
          <span class="badge ${task.claimed ? 'uncommon' : ready ? 'legendary' : ''}">${task.progress}/${task.count}</span>
        </div>
        <div>
          <h3>${escapeHtml(task.label)}</h3>
          <p>${escapeHtml(task.description)}</p>
        </div>
        <div class="bar"><i style="width:${pct}%"></i></div>
        <div class="meta-row">
          <div class="price">${money(task.reward)} <span>reward</span></div>
          <span class="badge">${escapeHtml(extras || 'Cash')}</span>
        </div>
        ${action}
      </article>
    `;
  }).join('');
}

function renderBoard() {
  const daily = state.tab !== 'all';
  const takes = daily ? state.board.dailyHarvest : state.board.harvest;
  const cash = daily ? state.board.dailyMoney : state.board.money;
  const blockHtml = (block, isMoney) => {
    const rows = (block && block.rows) || [];
    if (!rows.length) {
      return emptyState('No scores yet', 'Harvest or sell to appear here.');
    }
    const you = block.you || {};
    return rows.map((row) => `
      <div class="board-row ${row.me ? 'me' : ''}">
        <b>${row.rank}</b>
        <span>${escapeHtml(row.name)}</span>
        <span class="value">${isMoney ? money(row.value) : row.value}</span>
      </div>
    `).join('') + `<div class="board-you">You · ${rankLabel(you.rank)} · ${isMoney ? money(you.value || 0) : (you.value || 0)}</div>`;
  };

  content.innerHTML = `
    <section class="board-col">
      <h3>Most takes ${daily ? 'today' : 'all time'}</h3>
      ${blockHtml(takes, false)}
    </section>
    <section class="board-col">
      <h3>Most money ${daily ? 'today' : 'all time'}</h3>
      ${blockHtml(cash, true)}
    </section>
  `;
}

function render() {
  titleEl.textContent = state.shop.label || 'Rebel Hunting';
  subtitleEl.textContent = state.shop.subtitle || 'forest outfitter';
  playerRoleEl.textContent = state.licensed
    ? (state.brand.role || 'Licensed hunter')
    : 'Unlicensed · see the ranger';
  content.classList.toggle('tasks-view', state.view === 'tasks');
  content.classList.toggle('board-view', state.view === 'board');
  content.classList.toggle('license-view', state.view === 'license');
  renderNav();
  renderStats();
  renderTabs();
  if (state.view === 'license') renderLicense();
  else if (state.view === 'shop') renderShop();
  else if (state.view === 'sell') renderSell();
  else if (state.view === 'field') renderField();
  else if (state.view === 'tasks') renderTasks();
  else renderBoard();
}

function openUI(payload) {
  payload = payload || {};
  if (payload.shop) state.shop = { ...state.shop, ...payload.shop };
  const allowed = allowedViews();
  const fallback = allowed.includes(payload.view) ? payload.view : (allowed[0] || 'shop');
  state.view = fallback;
  state.tab = state.view === 'board' ? 'today' : 'all';
  state.query = '';
  state.qty = {};
  search.value = '';
  applyPayload(payload);
  if (!state.catalog.length) state.catalog = DEMO.catalog;
  if (!state.field.length) state.field = DEMO.field;
  app.classList.remove('hidden');
  app.setAttribute('aria-hidden', 'false');
  render();
}

function closeUI() {
  app.classList.add('hidden');
  app.setAttribute('aria-hidden', 'true');
  nui('close');
}

async function handleResult(result, fallback) {
  if (result && result.ok) {
    if (result.refresh) applyPayload(result.refresh);
    toast(fallback);
  } else {
    toast('That transaction did not go through.');
  }
}

function applyHud(data) {
  if (!data || !data.visible || !app.classList.contains('hidden')) {
    hudEl.classList.add('hidden');
    hudEl.setAttribute('aria-hidden', 'true');
    return;
  }
  hudEl.classList.remove('hidden');
  hudEl.setAttribute('aria-hidden', 'false');
  hudZone.textContent = data.zone || 'Hunting ground';
  hudHint.textContent = data.hint || '';
  hudLevel.textContent = `L${data.level || 1}`;
  const status = data.status === 'cooldown' && data.cooldown
    ? `Woods settling · ${data.cooldown}s`
    : (HUD_COPY[data.status] || HUD_COPY.searching);
  hudStatus.textContent = status;
  const floor = Number(data.floor) || 0;
  const next = Number(data.next) || floor;
  const xp = Number(data.xp) || 0;
  const span = Math.max(1, next - floor);
  const pct = next <= floor ? 100 : Math.max(4, Math.min(100, ((xp - floor) / span) * 100));
  hudXp.style.width = `${pct}%`;
}

navEl.addEventListener('click', (e) => {
  const btn = e.target.closest('.nav-btn');
  if (btn) setView(btn.dataset.view);
});

tabsEl.addEventListener('click', async (e) => {
  const btn = e.target.closest('.tab');
  if (!btn) return;
  if (btn.dataset.tab === 'sellall') {
    if (state.busy) return;
    state.busy = true;
    const result = await nui('sellAll');
    state.busy = false;
    await handleResult(result, result && result.ok ? `Sold harvest for ${money(result.total)}` : '');
    return;
  }
  state.tab = btn.dataset.tab;
  render();
});

let searchTimer = 0;
search.addEventListener('input', () => {
  state.query = String(search.value || '').slice(0, 64);
  clearTimeout(searchTimer);
  searchTimer = setTimeout(render, 80);
});

content.addEventListener('click', async (e) => {
  const btn = e.target.closest('button');
  if (!btn || state.busy) return;
  const act = btn.dataset.act;

  if (act === 'license') {
    state.busy = true;
    const result = await nui('buyLicense');
    state.busy = false;
    await handleResult(result, result && result.ok ? 'Rebel hunting license issued.' : '');
    return;
  }

  const card = e.target.closest('.card');
  if (!card) return;

  if (act === 'claim') {
    state.busy = true;
    const result = await nui('claimTask', { id: card.dataset.task });
    await handleResult(result, result && result.ok ? `Claimed ${result.label}` : '');
    state.busy = false;
    return;
  }

  const itemName = card.dataset.item;
  const item = state.view === 'shop'
    ? state.catalog.find((i) => i.item === itemName)
    : state.goods.find((i) => i.item === itemName);
  if (!item) return;

  const max = state.view === 'shop' ? 50 : item.count;
  if (act === 'minus') {
    state.qty[itemName] = Math.max(1, qtyFor(itemName, max) - 1);
    render();
    return;
  }
  if (act === 'plus') {
    state.qty[itemName] = Math.min(max, qtyFor(itemName, max) + 1);
    render();
    return;
  }

  state.busy = true;
  if (act === 'buy') {
    const amount = qtyFor(itemName, 50);
    const result = await nui('buy', { item: itemName, amount });
    await handleResult(result, result && result.ok ? `Purchased ${result.amount}x ${result.label}` : '');
  } else if (act === 'sellone') {
    const amount = qtyFor(itemName, item.count);
    const result = await nui('sell', { item: itemName, amount });
    await handleResult(result, result && result.ok ? `Sold ${result.amount}x ${result.label}` : '');
  } else if (act === 'sellstack') {
    const result = await nui('sell', { item: itemName, amount: item.count });
    await handleResult(result, result && result.ok ? `Sold ${result.amount}x ${result.label}` : '');
  }
  state.busy = false;
});

window.addEventListener('keydown', (e) => {
  if (e.key === 'Escape' && !app.classList.contains('hidden')) {
    closeUI();
  }
});

window.addEventListener('message', (event) => {
  const msg = event.data || {};
  const action = msg.action;
  const data = msg.data || msg;
  if (action === 'open') openUI(data);
  if (action === 'close') {
    app.classList.add('hidden');
    app.setAttribute('aria-hidden', 'true');
  }
  if (action === 'update') applyPayload(data);
  if (action === 'hud') applyHud(data);
});

if (!inFiveM) {
  document.body.classList.add('preview');
  const params = new URLSearchParams(location.search);
  const view = params.get('view') || 'shop';
  const tab = params.get('tab');
  const licensed = params.get('licensed') !== '0';
  const demo = {
    view,
    shop: { label: 'Rebel Hunting', subtitle: 'forest outfitter', views: ['license', 'shop', 'sell', 'field', 'tasks', 'board'], sellsLicense: true },
    ...DEMO,
    licensed,
    licensedFlag: licensed,
    hunter: { ...DEMO.hunter, licensed },
    license: { ...DEMO.license, owned: licensed, price: licensed ? 150 : 450 },
  };
  if (!licensed) {
    demo.view = view === 'shop' ? 'license' : view;
    demo.hunter.level = 1;
    demo.hunter.xp = 0;
  }
  openUI(demo);
  if (tab && (CATEGORIES.some((c) => c.id === tab) || SELL_TABS.some((c) => c.id === tab) || FIELD_TABS.some((c) => c.id === tab) || BOARD_TABS.some((c) => c.id === tab))) {
    state.tab = tab;
    render();
  }
  if (params.get('hud') !== '0') {
    applyHud({
      visible: true,
      zone: 'Paleto Forest',
      hint: 'Lodge woods. Rabbits, boar, later deer.',
      level: licensed ? 4 : 1,
      xp: licensed ? 540 : 0,
      floor: licensed ? 500 : 0,
      next: licensed ? 820 : 120,
      status: licensed ? 'ready' : 'nolicense',
      cooldown: 0,
    });
  }
}
