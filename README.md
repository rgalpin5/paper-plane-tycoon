# Paper Plane Tycoon

A mobile-first Roblox +1 tycoon: throw paper planes, upgrade the hangar, collect planes from crates, idle overnight, rebirth.

Project path: `~/paper-plane-tycoon`

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

You should spawn on a rooftop, see a big **THROW** button, and earn coins on the first throw (starter plane: Folded Note).

`rojo plugin install` can also install/update the Studio plugin from the CLI after `rokit install`.

## Play checklist (no Robux IDs required)

- THROW (button or spacebar) launches a plane, camera follows, coins pop
- **UP** shop: Power / Paper Quality / Fold Precision / Wing Span, plus buy-max
- **HAN** hangar: Capacity, Idle Rate, Offline Hours, Display Slots, Auto Throw unlock
- **IDX** index: 30 planes, silhouettes for missing, equip/unequip
- **BOX** crates: Paper / Hangar / Golden / Daily, **Details** odds that sum to 100%, pity text
- **SHOP** gamepasses + coin packs (prompts skip until you paste IDs)
- **DAY** streak 1–7, free crate on day 7
- **RB** rebirth shows exact multiplier gain before you confirm
- Tutorial once: throw → buy one upgrade → throw again
- Offline popup after a second Play session if you wait ~30s+ between sessions (needs DataStore API for it to survive Studio restarts; Mock is per-server)

## Create products, then paste IDs

Creator Hub: [create.roblox.com/dashboard](https://create.roblox.com/dashboard) → your experience → **Monetization**.

Open `src/shared/Config/Products.lua` and replace each `id = 0`. Comments in that file list every pass and product. Price hints are starting points; retune on Creator Hub without a code change.

Until IDs are set, the shop lists everything and shows a toast instead of prompting.

Promo codes (edit `src/shared/Config/Codes.lua`): `RELEASE`, `PAPER`, `FOLD`, `HANGAR`, `TYCOON`.

## Balancing

All numbers live under `src/shared/Config/`:

| File | What it drives |
| --- | --- |
| `Planes.lua` | 30 planes, rarities, multipliers, colors |
| `Upgrades.lua` | Plane + hangar costs / max levels |
| `Crates.lua` | Crate weights, pity |
| `Products.lua` | Gamepasses + dev products |
| `Numbers.lua` | Cooldowns, idle caps, rebirth, daily rewards |
| `Codes.lua` | Promo codes |

## Architecture

Server owns coins. The client only sends intent (`Throw`, `BuyUpgrade`, `OpenCrate`, …).

```
src/
  shared/Config/     tables
  shared/Remotes.lua
  shared/PlaneFactory.lua
  server/Services/   Data, Economy, Throw, Hangar, Crate, Idle, Monetization, Daily, Rebirth, Codes
  client/UI          HUD, shops, crates, hangar, daily, rebirth, index
  client/Controllers Throw camera / FX
place/               Rojo map root (World.lua fills rooftop + hangar on boot)
```

Wally: ProfileStore (server), Promise, Signal, Janitor.

## Optional polish after launch

Swap plane MeshIds in `PlaneFactory`, hire UI art, add music. Not required to publish.
