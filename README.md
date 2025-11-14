# Bug Defense 🐛🏠

A Swift 6.2 tower defense game where you defend your house against waves of attacking bugs!

## Game Overview

In **Bug Defense**, bugs are constantly trying to attack your house. Your mission is to strategically place defensive structures to stop them before they reach your home. Survive all 100 waves to achieve victory!

### Core Gameplay

- **House Defense**: Your house sits at the center of the map with 100 HP. Protect it at all costs!
- **Grid-Based Placement**: Place towers, traps, and walls on a 20x15 tile grid
- **Progressive Waves**: 100 increasingly difficult waves with diverse bug types and boss waves every 25
- **Smart Pathfinding**: Bugs use A* pathfinding to navigate around your defenses
- **Multi-Layered Progression**: Upgrade trees, research lab, card system, and module customization

## Bug Types

Each wave brings different types of bugs with unique characteristics:

| Bug Type | Health | Speed | Damage | Reward | Special Ability |
|----------|--------|-------|--------|--------|----------------|
| 🐜 **Ant** | 20 | Medium | 5 | 💰 10 | Basic enemy |
| 🪲 **Beetle** | 50 | Slow | 10 | 💰 25 | Tanky, high health |
| 🕷️ **Spider** | 15 | Fast | 3 | 💰 15 | Quick movement |
| 👹 **Boss** | 200 | Medium | 25 | 💰 100 | Appears every 5 waves |
| 🦗 **Splitter** | 30 | Medium | 8 | 💰 20 | Splits into 2 ants when killed |
| 🦟 **Mosquito** | 12 | Fast | 4 | 💰 18 | FLIES - ignores walls, takes direct path |
| 🐝 **Wasp** | 25 | Very Fast | 12 | 💰 30 | FLIES - ignores walls, high damage |

## Defensive Structures

**10 structures total!** New advanced towers unlock every 5 waves.

### Starting Structures (Wave 1)

#### Basic Tower - 💰 $50
- **Range**: 3 tiles | **Damage**: 10 | **Attack Speed**: 1.0s | **Health**: 100 HP
- Affordable all-rounder for early defense

#### Sniper Tower - 💰 $100
- **Range**: 5 tiles | **Damage**: 30 | **Attack Speed**: 2.0s | **Health**: 80 HP
- High damage, long range tower for taking out tough bugs

#### Machine Gun Tower - 💰 $75
- **Range**: 2.5 tiles | **Damage**: 5 | **Attack Speed**: 0.3s | **Health**: 90 HP
- Very fast firing rate, lower damage per shot, great for swarms

#### Slow Trap - 💰 $30
- **Range**: 1.5 tiles | **Effect**: Slows by 50% for 2s | **Health**: 50 HP
- Passive structure, great for choke points

#### Wall - 💰 $20
- **Health**: 200 HP
- Blocks bug pathfinding, highly durable

### Advanced Towers

#### 🔓 Cannon Tower - 💰 $150 (Unlocks Wave 5)
- **Range**: 4 tiles | **Damage**: 40 | **Attack Speed**: 3.0s | **Health**: 120 HP
- **Special**: Built-in splash damage to nearby bugs (80px radius, 50% damage)
- Slow but devastating AoE attacks

#### 🔓 Lightning Tower - 💰 $200 (Unlocks Wave 10)
- **Range**: 3.5 tiles | **Damage**: 20 | **Attack Speed**: 1.5s | **Health**: 100 HP
- **Special**: Chains to up to 3 additional bugs (50% damage per chain)
- Purple lightning arcs between targets

#### 🔓 Freeze Tower - 💰 $175 (Unlocks Wave 15)
- **Range**: 3 tiles | **Damage**: 8 | **Attack Speed**: 1.0s | **Health**: 110 HP
- **Special**: Slows all bugs in 100px radius by 50% for 3 seconds
- Area control specialist

#### 🔓 Poison Tower - 💰 $225 (Unlocks Wave 20)
- **Range**: 3.5 tiles | **Damage**: 15 | **Attack Speed**: 2.0s | **Health**: 95 HP
- **Special**: Applies 5 ticks of DoT over 5 seconds (total damage = initial hit)
- Excellent against high-health bugs

#### 🔓 Laser Tower - 💰 $300 (Unlocks Wave 25)
- **Range**: 6 tiles | **Damage**: 50 | **Attack Speed**: 2.5s | **Health**: 85 HP
- **Special**: Instant beam damage with red laser visual
- Ultimate tower with massive damage and range

### Tower Strategy

- **Early Game (1-10)**: Spam Machine Gun + Basic towers for cost efficiency
- **Mid Game (10-20)**: Unlock Lightning & Freeze for crowd control
- **Late Game (20+)**: Mix Poison & Laser for boss waves
- **Boss Waves**: Cannon + Lightning combo for AoE devastation
- **Module Synergies**: Equip splash modules on Cannon, crit modules on Laser

## Upgrade Trees

Earn currency by killing bugs and spend it on powerful upgrades across three specialization trees:

### ⚔️ Attack Tree
Maximize your offensive power!

1. **Sharpened Ammo** (💰 $100) - +20% damage to all towers
2. **Critical Strike** (💰 $200) - 15% chance to deal double damage
3. **Multi-Target** (💰 $400) - +50% damage, towers can hit 2 targets
4. **Elemental Fury** (💰 $800) - +100% damage, attacks burn enemies

### 🛡️ Defense Tree
Fortify your structures and house!

1. **Reinforced Walls** (💰 $100) - +30% health to all structures
2. **House Armor** (💰 $200) - +50% house health, reduces damage by 25%
3. **Auto-Repair** (💰 $400) - Structures repair 2 HP/second
4. **Damage Reflection** (💰 $800) - Structures reflect 50% of damage taken

### ⚡ Speed Tree
Attack faster and control the battlefield!

1. **Rapid Fire** (💰 $100) - +25% attack speed
2. **Enhanced Traps** (💰 $200) - +50% attack speed, traps slow by 75%
3. **Cooldown Reduction** (💰 $400) - +75% attack speed
4. **Time Warp** (💰 $800) - Double attack speed, auto-repair doubled

## 🔬 Research Lab - Permanent Upgrades

The Research Lab offers **permanent upgrades** that persist across all games, providing lasting improvements to your defenses!

### Research Coins 🪙

- Earn **Research Coins** by completing waves (3 coins per wave, +5 bonus every 5 waves)
- These are separate from regular currency and never reset
- Invest in long-term upgrades that make future runs easier

### Available Research Upgrades

#### Enhanced Ammunition (Max Level 10)
- **Cost**: 5 🪙 (first level), +3 🪙 per level
- **Effect**: +5% damage per level (up to +50% at max level)

#### Advanced Targeting (Max Level 10)
- **Cost**: 5 🪙 (first level), +3 🪙 per level
- **Effect**: +5% attack speed per level (up to +50% at max level)

#### Long-Range Optics (Max Level 5)
- **Cost**: 8 🪙 (first level), +5 🪙 per level
- **Effect**: +10% tower range per level (up to +50% at max level)

#### Reinforced Materials (Max Level 8)
- **Cost**: 6 🪙 (first level), +4 🪙 per level
- **Effect**: +10% structure health per level (up to +80% at max level)

#### Efficient Engineering (Max Level 6)
- **Cost**: 10 🪙 (first level), +6 🪙 per level
- **Effect**: -5% tower construction costs per level (up to -30% at max level)

#### Victory Bonus (Max Level 5)
- **Cost**: 12 🪙 (first level), +8 🪙 per level
- **Effect**: +20% research coins from waves per level (up to +100% at max level)

### Research Strategy

1. **Early Game**: Focus on damage or attack speed for easier early waves
2. **Mid Game**: Invest in range to cover more ground
3. **Late Game**: Max out Victory Bonus for exponential coin growth
4. **Cost Reduction**: Great for experimentation with different tower placements

**Note**: Research upgrades stack multiplicatively with regular upgrade trees, creating powerful synergies!

## 🎴 Card System - Powerful Equipment Slots

The Card System offers **5 equipment slots** for powerful cards that provide unique bonuses!

### How Cards Work

- **Boss Waves**: Defeat boss waves (every **25 waves**) to earn random cards
- **5 Equipment Slots**: Only 5 cards can be active at once
- **Slot Unlocking**: Use research coins to unlock additional slots:
  - Slot 1: Unlocked by default
  - Slot 2: 50 🪙
  - Slot 3: 100 🪙
  - Slot 4: 150 🪙
  - Slot 5: 200 🪙
- **Strategic Choices**: Choose which cards to equip based on your playstyle

### Available Cards

#### Common Cards
- **⚔️ Damage Boost**: +30% damage to all towers
- **⚡ Rapid Fire**: +40% attack speed
- **🛡️ Fortification**: +50% structure health
- **📡 Range Extender**: +40% tower range
- **📦 Starter Pack**: Start with +200 currency each wave

#### Rare Cards
- **🎯 Sniper Nest**: Sniper towers cost 50% less, +20% range
- **💰 Economy Bonus**: +25% currency from bug kills
- **☠️ Poison Darts**: Attacks deal 20% damage over 3 seconds
- **🧲 Coin Magnet**: +50% research coins from waves
- **🔧 Auto Repair**: Structures repair 5 HP/second

#### Epic Cards
- **🎲 Multishot**: Towers hit 2 targets simultaneously
- **⏱️ Time Warp**: +50% attack speed, -30% bug speed
- **❄️ Slow Field**: All bugs move 25% slower

#### Legendary Cards
- **💥 Critical Mass**: 25% chance to deal triple damage
- **💣 Explosive Ammo**: Attacks deal splash damage to nearby bugs

### Card Strategy

1. **Unlock slots progressively** as you earn coins
2. **Mix offensive and defensive** cards for balance
3. **Synergize with research** - cards stack with permanent upgrades
4. **Boss waves are harder** - 2.5x more bugs than regular waves!
5. **Collect them all** - 15 unique cards with different rarities

## 💎 Module System - Tower Customization

The Module System allows you to equip **up to 4 modules per tower** for deep customization and powerful special effects!

### Gem Currency 💎

- **New Currency**: Gems are used to purchase modules
- **Conversion**: Convert coins to gems at 100:1 ratio (expensive!)
- **Module Drops**: Modules drop randomly when you kill bugs (5% base rate, scales with wave)
- **Drop Scaling**: Higher waves drop higher level modules

### Module Types & Effects

Each tower can equip **4 modules** from these 8 types:

#### ⚔️ Damage Module
- **Effect**: +5% damage per level (up to +150% at level 30)
- **Stacks with**: All other damage bonuses
- **Best for**: Maximizing single-target damage

#### ⚡ Attack Speed Module
- **Effect**: +3% attack speed per level (up to +90% at level 30)
- **Stacks with**: All speed upgrades
- **Best for**: Fast-firing tower builds

#### 🎯 Range Module
- **Effect**: +4% range per level (up to +120% at level 30)
- **Stacks with**: Research range upgrades
- **Best for**: Covering more ground with fewer towers

#### 💥 Critical Chance Module
- **Effect**: +2% crit chance per level (up to 60% at level 30)
- **Special**: Critical hits deal **2x damage**
- **Best for**: Burst damage builds

#### 🗡️ Piercing Module
- **Effect**: +10% pierce chance per level (up to 300% at level 30)
- **Special**: Piercing shots damage multiple bugs in a line (50% damage)
- **Best for**: Dense waves with many bugs

#### 💣 Splash Module
- **Effect**: +15% splash damage per level (up to 450% at level 30)
- **Special**: Damages all bugs within 60-pixel radius of target
- **Best for**: Grouped enemies, AoE damage

#### 🩸 Lifesteal Module
- **Effect**: +1% lifesteal per level (up to 30% at level 30)
- **Special**: Heals tower for % of damage dealt
- **Best for**: Sustaining tower health, reducing repair needs

#### 🎲 Multishot Module
- **Effect**: +5% multishot chance per level (up to 150% at level 30)
- **Special**: Fires at an additional random target (50% damage)
- **Best for**: Wave clear, multiple target damage

### Module Levels & Tiers

Modules range from **Level 1 to 30** across **6 rarity tiers**:

| Tier | Levels | Color | Drop Chance |
|------|--------|-------|-------------|
| **Common** | 1-5 | Gray | High |
| **Uncommon** | 6-10 | Green | Medium |
| **Rare** | 11-15 | Blue | Medium-Low |
| **Epic** | 16-20 | Purple | Low |
| **Legendary** | 21-25 | Orange | Very Low |
| **Mythic** | 26-30 | Red | Extremely Rare |

### Module Merging 🔧

Combine modules to upgrade them:
- **Merge 2 modules** of the same type and level → create 1 module at level+1
- Works up to Level 30 (max level)
- Example: Damage Lv.5 + Damage Lv.5 → Damage Lv.6
- Great way to upgrade low-level drops into powerful high-tier modules!

### Module Shop 🛒

Purchase modules directly with gems:
- **Cost Formula**: 50 gems + (level × 20)
- **Level 1**: 70 gems
- **Level 5**: 150 gems
- **Level 10**: 250 gems
- **Level 30**: 650 gems

### Module Effects in Combat

All module effects are **fully implemented** and stack multiplicatively:

- **Critical Hits**: 2x damage when proc'd
- **Piercing Attacks**: Damage bugs in line of fire
- **Splash Damage**: Hit bugs within 60-pixel radius
- **Lifesteal**: Heal tower based on damage dealt
- **Multishot**: Attack additional random targets

### Module Strategy

1. **Early Game**: Focus on drops, save gems
2. **Module Merging**: Merge low-level duplicates for quick upgrades
3. **Specialized Builds**:
   - **Sniper Build**: Range + Damage + Crit
   - **AoE Build**: Splash + Multishot + Attack Speed
   - **Sustain Build**: Lifesteal + Range + Attack Speed
4. **Mix & Match**: Each tower can use 4 modules from any combination
5. **Gem Conversion**: Only convert coins when you need specific modules
6. **Boss Farming**: Higher waves = better module drops

### Synergy Example

With max upgrades, research, cards, and modules:
- Base Damage: 10
- × Upgrade Tree (2.0x)
- × Research (1.5x)
- × Cards (1.3x)
- × Modules (2.5x)
- **= 97.5 damage per shot!**

Add critical hits (2x) and splash damage, and you have devastating firepower!

## How to Play

### Getting Started

1. **Build Phase**: Place structures on the grid by clicking the structure buttons at the bottom
2. **Start Wave**: Click "Start Wave" when ready (or wait for auto-start after 20 seconds)
3. **Defend**: Watch your towers automatically attack bugs
4. **Upgrade**: Between waves, click "Upgrades" to purchase enhancements
5. **Collect**: Earn modules from bug kills, cards from boss waves, and coins from wave completion
6. **Customize**: Equip modules on towers, unlock card slots, and purchase research upgrades
7. **Survive**: Protect your house through all 100 waves!

### Controls

- **Left Click**: Place selected structure on grid
- **Mouse Move**: Preview structure placement location
- **Structure Buttons**: Select which structure to place
- **Start Wave Button**: Begin the next wave
- **Upgrades Button**: Open upgrade menu (temporary upgrades per game)
- **Research Button**: Open Research Lab (permanent upgrades)
- **Cards Button**: Manage card collection and equipment slots
- **Modules Button**: Access module inventory, shop, and merging

### Strategy Tips

1. **Start with towers** near spawn points to damage bugs early
2. **Use walls strategically** to create longer paths, giving towers more time to shoot
3. **Place slow traps** in front of tower clusters to maximize damage output
4. **Balance upgrades** - don't over-invest in one tree
5. **Save currency** for expensive tier 3-4 upgrades in later waves
6. **Watch spawn points** - bugs spawn from the edges of the map
7. **Protect choke points** with multiple overlapping tower ranges
8. **Prepare for flying bugs** - walls don't stop them! Focus on tower coverage near your house starting wave 10+

## Wave Progression

The game now features **100 waves** with boss waves every **25 waves**!

- **Waves 1-3**: Only ants, slow pace (learning phase)
- **Waves 4-7**: Ants and beetles introduced
- **Waves 8-9**: Spiders join the assault, increased speed
- **Waves 10-11**: Flying bugs appear! Mosquitos ignore walls and take direct paths
- **Waves 12-14**: Splitters appear, requiring careful targeting
- **Waves 15-16**: Wasps join the fight - fast flying bugs with high damage
- **Waves 17-24**: All bug types, increasing difficulty
- **Wave 25**: 🔥 BOSS WAVE - 2.5x more bugs, earn a random card!
- **Waves 26-49**: Continuous progression
- **Wave 50**: 🔥 BOSS WAVE - Earn another card!
- **Waves 51-100**: Maximum difficulty, boss waves every 25

Boss waves award **+20 bonus research coins** and a **random card**!

## Technical Details

### Architecture

The game is built with a modular architecture:

- **GameScene**: Main SpriteKit scene managing the game loop
- **GameStateManager**: Tracks game state, currency, health, and waves
- **WaveManager**: Handles bug spawning and wave progression (boss waves every 25)
- **UpgradeManager**: Manages the three upgrade trees (per-game upgrades)
- **ResearchLab**: Manages permanent research upgrades with coins
- **CardManager**: Manages card collection and 5 equipment slots
- **ModuleManager**: Manages module inventory, drops, merging, and gems
- **PathfindingGrid**: A* pathfinding for bug navigation
- **Bug**: Enemy entities with health, movement, and attack logic
- **DefenseStructure**: Base class for all defensive structures (with 4 module slots)
- **GameHUD**: Heads-up display showing stats, controls, and currency (💰, 🪙, 💎)
- **UpgradeMenu**: Interface for purchasing per-game upgrades
- **ResearchLabMenu**: Interface for purchasing permanent research upgrades
- **CardMenu**: Interface for managing card collection and equipment
- **ModuleMenu**: Interface for module inventory, shop, and merging (3 tabs)

### Requirements

- Swift 6.2
- macOS 13+ or iOS 16+
- SpriteKit framework

### Building & Running

```bash
# Build the package
swift build

# Run tests
swift test

# Or open in Xcode
open Package.swift
```

To integrate into an app, create a view controller that presents the `GameScene`:

```swift
import SpriteKit
import BugDefense

class GameViewController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let scene = GameScene(size: CGSize(width: 800, height: 600))
        scene.scaleMode = .aspectFit

        let skView = SKView(frame: view.bounds)
        view.addSubview(skView)
        skView.presentScene(scene)
    }
}
```

## Game Design Philosophy

**Bug Defense** emphasizes:

1. **Strategic Depth**: Multiple viable strategies through diverse structures and upgrades
2. **Progressive Difficulty**: Gradual introduction of mechanics and enemy types
3. **Player Agency**: Manual wave starting and upgrade timing
4. **Risk/Reward**: Expensive upgrades vs. immediate structure purchases
5. **Replayability**: Different upgrade paths create varied playstyles

## Future Enhancements

Potential features for future versions:

- [ ] Additional tower types (Area damage, support towers)
- [ ] More bug varieties (Flying bugs, burrowing bugs)
- [ ] Special abilities (Active abilities with cooldowns)
- [ ] Difficulty modes (Easy, Normal, Hard)
- [ ] Level/map selection
- [ ] Save/load game progress
- [ ] Sound effects and music
- [ ] Particle effects and animations
- [ ] Achievements system

## Credits

Developed with Swift 6.2 and SpriteKit

Built as a demonstration of:
- SpriteKit game development
- A* pathfinding algorithm
- Object-oriented game architecture
- Progressive difficulty design
- Tower defense mechanics

## License

This project is open source and available for educational purposes.

---

**Enjoy defending your house!** 🏠⚔️🐛
