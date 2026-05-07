# System Flow & Mechanics (Questlings)

## 1. Core Loop: The Habit-RPG Engine
The core gameplay loop revolves around translating real-world productivity into in-game progression.

1. **Do Tasks (Home):** Users check off their daily habits or participate in multi-day **Missions**.
2. **Earn Rewards:** Completing habits generates **XP** (character leveling), **Stardust** (currency), and **Energy** (party resource).
3. **Spend Resources (Bazaar/Shop):** Users spend Stardust to purchase **Items** (Accessories, Avatar Gear, Evolution Stones).
4. **Manage Assets (Inventory):** Users equip items, manage their collected **Questlings** (pets), and monitor their Questling's status (e.g., Healthy, Sick, Sad).
5. **Collaborate (Party/Social):** Users contribute Energy to **Party Goals** (defeating Bosses or hatching Guild Eggs) and participate in **Community Challenges**.
6. **View Growth:** Users level up, unlock class abilities, and watch their equipped Questlings evolve, creating intrinsic motivation to return to the Home screen and complete more tasks.

## 2. Detailed System Components

### 2.1 Habits & Missions (Action Layer)
*   **Habits:** The fundamental building blocks. Each habit is assigned a **Category** (e.g., Fitness, Study, Mindfulness) and a **Difficulty** (Trivial, Easy, Medium, Hard). Higher difficulty yields greater rewards.
*   **Missions:** Multi-day commitments. Users pledge to complete a habit for a set number of consecutive days (e.g., a 3-day streak). Successfully completing a mission hatches an egg, rewarding the user with a specific **Questling**.
*   **Check-ins (Habit Logs):** Each time a habit is completed, the system calculates rewards based on difficulty and synergy. 
    *   *Synergy Bonus:* If the user's equipped Questling's elemental type aligns with the habit's category, a bonus (e.g., 10%) is applied to the earned XP and Stardust.

### 2.2 User Progression & Classes (RPG Layer)
*   **Experience & Levels:** Users gain XP from completing habits to level up their overarching profile.
*   **Classes:** Users can choose an RPG class (e.g., Warrior, Mage, Rogue, Healer), which grants specific passive and active benefits:
    *   *Stat Buffs:* e.g., A class might passively generate more Energy for the party per habit completed.
    *   *Special Abilities:* e.g., A Healer class can cure a Questling's "Sick" status directly, bypassing the need to buy restorative items.

### 2.3 Questlings & Tamagotchi Mechanics (Companion Layer)
*   **Obtaining Questlings:** Users earn Questlings primarily by completing Missions (hatching eggs over a set number of target days). Each Questling is permanently tied to the specific habit it was "born from."
*   **The Tamagotchi Effect:** Questlings have a live status (Healthy, Sick, Sad, Tired). Neglecting the habit a Questling was born from may cause it to become Sick or Sad, requiring the user to complete specific restorative actions or use items.
*   **Equipping:** Users choose one Questling to accompany them on the Home screen. This companion provides the active synergy bonus for matching habit categories.
*   **Evolution:** Questlings can evolve or level up using **Evolution Stones** purchased from the Bazaar, giving users a long-term goal.

### 2.4 The Bazaar & Inventory (Economy Layer)
*   **Currency:** Stardust is the primary economy currency, earned through daily habit check-ins.
*   **Items:** Users can buy Accessories for their Questlings, Avatar Gear for themselves, and functional items like Evolution Stones.
*   **Inventory Management:** Users visit the inventory to equip purchased gear, customizing their appearance and establishing a cosmetic reward system.

### 2.5 Co-op & Social Features (Multiplayer Layer)
*   **Parties (Guilds):** Users form groups. Every time a party member completes a habit, they generate a specific amount of **Energy**.
*   **Party Goals:** The pooled Energy from all members is used to tackle weekly co-op objectives:
    *   *Boss Battles:* The party must collectively generate enough Energy to deplete the boss's health before the week ends.
    *   *Guild Eggs:* Pool enough Energy to hatch a rare, shared Questling reward for the whole party.
*   **Community Challenges:** Server-wide events (e.g., "Hydration Challenge") where all players work towards a specific category of habits. Reaching the community milestone unlocks a unique Questling egg for all participants.

## 3. Summary
The system transforms basic habit-tracking into a rich, interconnected RPG ecosystem. The user's real-world actions directly fuel their personal growth (XP, Classes), their virtual pet's well-being (Questling Status, Synergy), and their social standing (Party Goals, Energy contributions). This multi-layered architecture ensures that intrinsic motivation is continuously reinforced by meaningful in-game consequences.