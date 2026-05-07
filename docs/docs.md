# Questlings - Design Specification

## Overview

A productivity application that merges Pokemon-style collection mechanics with habit tracking, built using Flutter and Supabase. The goal is to encourage positive habit formation through a compelling "Tamagotchi-style" responsibility loop and cooperative social features.

## Core Mechanics

* **The Goal:** Complete "Missions" (multi-day habit quests) to earn specific Questlings.
* **The Punishment (The Tamagotchi Effect):** If a user misses a habit on their quest, their assigned Questling becomes "Sick/Sad." Quest progress resets, but the creature is not lost. The user must complete a habit the next day to heal them.
* **The Social Feature (Co-op Bosses/Eggs):** Users form "Parties." Everyone's individual habit completions generate "Energy" that is pooled together to defeat a Boss or hatch a massive Guild Egg at the end of the week.

## App Structure & User Flow

### A. Onboarding & The First Quest

*For detailed UI layouts and button placements, see [ui_specs.md](./ui_specs.md).*

1. **Welcome:** The user is greeted by an NPC/Guide.
2. **Pick a Path:** The user chooses their first habit category (e.g., "Fitness," "Study," "Mindfulness").
3. **The Starter Egg:** The user is given an Egg tied to that category.
4. **First Quest:** The app assigns a 3-day mission (e.g., "Drink water 3 days in a row").

### B. The Daily Loop (The Home Screen)

1. **Active Quests View:** Displays current active habits and the assigned Questlings.
2. **Status Check:** Visual indicators if a Questling is sick (missed yesterday) and requires a "Heal" action (doing the habit today).
3. **Check-in:** The user taps to complete their habit.
4. **Reward:** Visual progress on the personal mission and "Energy" flying up into the global pool for the Party's Co-op Goal.

### C. The Inventory (The "Pokedex")

* A grid interface showing all collected Questlings.
* Tapping a Questling displays its stats, the habit it was born from, and an option to "Equip" it to accompany the user on the Home Screen.

### D. The Party Tab (Co-op)

* Displays the current weekly Boss or Guild Egg.
* A progress bar indicating the total Energy needed and current pool.
* A party roster showing the weekly Energy contribution of each member.

---

## 1. Economy & Customization (Gear Up)

* **Currency (Stardust):** Completing habits and missions rewards the user with currency.
* **The Bazaar:** A shop where users can spend currency on:
  * **Questling Accessories:** Hats, scarves, or items that your "Equipped" Questling can wear.
  * **User Avatar Gear:** Items to customize the player's profile (swords, armor, etc.).
  * **Evolution Stones:** Rare items used to evolve certain Questlings after they reach a specific level.

## 2. Progression & Stats (RPG Layers)

* **User Levels:** As the user earns Experience (XP), they level up.
* **Player Classes:** Upon reaching a certain level (e.g., Level 10), users could choose a class (Warrior, Mage, Rogue, Healer) which grants:
  * **Special Abilities:** e.g., A "Healer" could use a skill to instantly cure a "Sick" Questling without needing a recovery habit.
  * **Stat Buffs:** Different classes might earn more Energy for the Party's Co-op Goal.

## 3. Social Expansion (Beyond Co-op)

* **Community Challenges:** Curated task lists created by the community or the developers.
  * *Questlings Twist:* Joining a "Hydration Challenge" gives everyone a specific "Water-Type Egg" to hatch together.
* **The Tavern (Chat/Guilds):** A place for users to find parties or discuss specific habit categories (e.g., a "Fitness Guild").

## 4. Enhanced Quests (Battle Monsters)

* **Boss Mechanics:** While our primary focus is on "Energy Pooling," we can add "Boss HP."
  * Doing habits "deals damage" to the Boss.
  * Missing habits causes the Boss to "attack" the party, potentially making multiple party members' Questlings "Tired" or "Sad" at once.

## 5. Habit Intensity

* **Task Difficulty:** Users can tag habits as Trivial, Easy, Medium, or Hard.
  * Harder habits reward more XP, Gold, and Mission progress.

## 6. Questling Types & Habit Mapping

Questlings are categorized by elemental types that align with specific habit categories. This ensures that the creature a user is "raising" feels thematic to the work being done.

*   **Mapping Table:** See [types_mapping.md](./types_mapping.md) for the full breakdown.
*   **Gameplay Synergy:** Performing a habit with an "Equipped" Questling of the matching type provides a 10% bonus to Energy contribution.
