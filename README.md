# Paper Plane Tycoon

A mobile-first Roblox tycoon: throw paper planes down a hallway, sit benches for strength, fill a hangar, open crates, rebirth.

Project path: `~/paper-plane-tycoon`

## Loop

You spawn in a **plaza hub**. Personal **hangar plots** sit around the plaza. A long **throw hallway** opens off one side.

**Throw** from a blue THROW pad: walk onto it, press space, or use the pad prompt. Strength (and your equipped plane) sets distance; distance pays coins. Throws also grant a little strength.

**Benches** (east of the plaza) are AFK strength. Sitting grants strength only — **no coins**. Free bench is open; Bronze / Silver / Gold / Diamond need the matching game pass. No pass → you are ejected and prompted.

**Hangar** stores unique planes (storage cap) and earns **offline coins** while you are away. Display stands on your plot show your best planes.

**Crates** (five): Paper, Tape, Box, Hangar, Golden. Pay coins in-game, or buy one Robux roll per crate. Odds are in **Details**. Regions that restrict paid random hide Robux crate rolls; coin crates still work, and the Index sells a guaranteed plane.

**Rotating shop** (plaza kiosk + SHOP): 3 trail / aura / trinket offers that rotate every 4 hours. Equip 3 at once, or 5 with Extra Cosmetic Slots.

**Rebirth** resets **coins, strength, and plane level**. It keeps planes, hangar upgrades, cosmetics, and player upgrades.

## What you do in Studio (about 30–60 min)

I cannot log into your Roblox account, create Game Passes, or publish. After the code is running, you:

1. Install [Roblox Studio](https://create.roblox.com/docs/studio)
2. Install the [Rojo Studio plugin](https://create.roblox.com/store/asset/13916111004)
3. Serve this place and Connect (steps below)
4. Create the experience, Game Passes, and Developer Products on Creator Hub
5. Paste the numeric IDs into `src/shared/Config/Products.lua` (every `id = 0`)
6. **File → Publish to Roblox**
7. Enable **Game Settings → Security → Enable Studio Access to API Services** so DataStores persist (Play still works without this; progress is session-only via ProfileStore.Mock)

Paid-random crate policy is handled in code with `PolicyService`. You do not flip a special switch for that.

**Do not create the old 18-pass Auto Throw / Magnet / Rainbow list.** Use only the launch set below.

## Serve into Studio

From this folder (Rokit already pinned `rojo`, `wally`, `selene`, `stylua` in `rokit.toml`):

```bash
# If tools are missing on a new machine:
curl -sSf https://raw.githubusercontent.com/rojo-rbx/rokit/main/scripts/install.sh | bash
export PATH="$HOME/.rokit/bin:$PATH"
rokit install
wally install

rojo serve
```

Then in Roblox Studio:

1. Open a **new empty Baseplate** (or any place)
2. Click the **Rojo** plugin → **Connect** (default `localhost:34872`)
3. Press **Play**

You should spawn in the plaza, see hangar plots, benches, and a hallway with THROW pads. Walk onto a pad and press space (or use the prompt) to launch the starter plane (Folded Note).

`rojo plugin install` can also install/update the Studio plugin from the CLI after `rokit install`.

## Play checklist (no Robux IDs required)

- Walk onto a THROW pad (or space / prompt) — plane flies, coins pop, a little strength
- Sit the **FREE** bench — strength ticks up, no coins
- **UP**: Plane Level + player upgrades (Strength Gain, Planes at Once, Luck)
- **HAN**: hangar Storage and Offline Income; equipped plane shows on your plot
- **IDX**: plane index, equip, guaranteed buy if paid-random is restricted
- **BOX**: Paper / Tape / Box / Hangar / Golden crates, **Details** odds that sum to 100%, pity text
- **SHOP**: rotating cosmetics (3 slots, +2 with pass) + game passes + coin packs + Robux crate rolls (prompts skip until you paste IDs)
- **DAY**: streak 1–7 coins (VIP extra); day 7 also opens a free Paper Crate
- **RB**: preview coin and strength multipliers, then confirm
- Tutorial once: hallway throw → **UP** → throw → free bench
- Offline popup after a second Play session if you wait ~30s+ between sessions (needs DataStore API for it to survive Studio restarts; Mock is per-server)

## Game Passes and Developer Products

Creator Hub: [create.roblox.com/dashboard](https://create.roblox.com/dashboard) → your experience → **Monetization**.

Open `src/shared/Config/Products.lua` and replace each `id = 0`. Price hints are starting points; retune on Creator Hub without a code change. Until IDs are set, the shop lists everything and shows a toast instead of prompting.

### Game Passes (one-time)

| Key | Name | Hint | What it does |
| --- | --- | --- | --- |
| `SkipCrateAnim` | Skip Crate Anim | R$49 | Instant crate results |
| `BenchBronze` | Bronze Bench | R$49 | Sit for 2× strength. No coins while seated |
| `ExtraCosmeticSlots` | Extra Cosmetic Slots | R$199 | Equip 5 trails/auras/trinkets instead of 3 |
| `DoubleCoins` | 2× Coins | R$199 | Permanent double coins from throws and hangar |
| `DoubleLuck` | 2× Luck | R$199 | Rare+ crate odds doubled, then re-normalized |
| `ExtraPlaneThrow` | Extra Plane Throw | R$249 | +1 plane per throw on top of the player upgrade |
| `BenchSilver` | Silver Bench | R$149 | Sit for 5× strength. No coins while seated |
| `OfflinePlus` | Offline+ | R$299 | Offline hangar cap raised to 8 hours |
| `HangarStoragePlus` | Hangar Storage+ | R$399 | +20 hangar storage |
| `VIP` | VIP | R$499 | Chat tag, +15% coins, 8h offline, extra daily coins |
| `BenchGold` | Gold Bench | R$399 | Sit for 12× strength. No coins while seated |
| `BenchDiamond` | Diamond Bench | R$799 | Sit for 30× strength. No coins while seated |

Bench passes are gated by the world seats. The shop still shows **BUY** even if you already own one.

### Developer Products (repeatable)

| Key | Name | Hint | Kind |
| --- | --- | --- | --- |
| `CoinPackS` | Coin Pack S | R$49 | +25,000 coins |
| `CoinPackM` | Coin Pack M | R$99 | +120,000 coins |
| `CoinPackL` | Coin Pack L | R$249 | +700,000 coins |
| `CoinPackXL` | Coin Pack XL | R$499 | +3,500,000 coins |
| `CratePaper` | Open Paper Crate | R$25 | One Paper Crate roll |
| `CrateTape` | Open Tape Crate | R$79 | One Tape Crate roll |
| `CrateBox` | Open Box Crate | R$149 | One Box Crate roll |
| `CrateHangar` | Open Hangar Crate | R$249 | One Hangar Crate roll |
| `CrateGolden` | Open Golden Crate | R$399 | One Golden Crate roll |
| `ShopReroll` | Reroll Rotating Shop | R$49 | New 3 cosmetics until this 4-hour window ends |

## Codes

Promo codes (edit `src/shared/Config/Codes.lua`): `RELEASE`, `PAPER`, `FOLD`, `HANGAR`, `TYCOON`. Coins, scrap, or a timed coin boost — **no crate keys**.

## Balancing

All numbers live under `src/shared/Config/`:

| File | What it drives |
| --- | --- |
| `Planes.lua` | Planes, rarities, multipliers, colors |
| `Upgrades.lua` | Plane, hangar, and player upgrade costs / max levels |
| `Crates.lua` | Five crates, weights, pity |
| `Cosmetics.lua` | Trails / auras / trinkets and rotation |
| `Products.lua` | Game passes + dev products |
| `Numbers.lua` | Cooldowns, benches, idle, rebirth, daily rewards |
| `Codes.lua` | Promo codes |

## Architecture

Server owns coins. The client only sends intent (`Throw`, `BuyUpgrade`, `OpenCrate`, …).

```
src/
  shared/Config/     tables
  shared/Remotes.lua
  shared/PlaneFactory.lua
  server/World.lua   plaza, hallway, pads, plots, benches, kiosks
  server/Services/   Data, Economy, Throw, Hangar, Plots, Benches,
                     Crate, RotationShop, Idle, Monetization, Daily, Rebirth, Codes
  client/UI          HUD, shops, crates, hangar, daily, rebirth, index
  client/Controllers throw camera / FX
place/               Rojo map root (World.lua fills the hub on boot)
```

Wally: ProfileStore (server), Promise, Signal, Janitor.

## Optional polish after launch

Swap plane MeshIds in `PlaneFactory`, hire UI art, add music. Not required to publish.
