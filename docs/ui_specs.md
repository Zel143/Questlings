# Questlings - UI Specifications

Detailed layout and interaction design for the Questlings mobile app.

## 1. Global Navigation (Bottom Nav Bar)
* **Home:** Active quests and equipped Questling.
* **Habits:** Management of all daily habits and missions.
* **Inventory:** "Pokedex" of collected Questlings.
* **Party:** Social features, Boss/Egg progress.
* **Shop/Bazaar:** Customization and items.

---

## 2. Home Screen (The Daily Loop)
The primary interaction hub.

### Visual Layout
* **Top Header:** User Avatar, Level Bar, Gold/Stardust count.
* **Center Stage:** The "Equipped" Questling with idle animations.
    * *Sick/Sad State:* Questling appears greyed out or with a "ZZZ" icon if a habit was missed.
* **Active Mission Widget:** A card showing the current 3+ day mission progress (e.g., "Day 2/3").
* **Daily Checklist (Lower Half):** Scrollable list of habits for today.

### Key Buttons & Actions
* **Habit Check-box:** Tapping triggers a "success" animation:
    1. Questling jumps/cheers.
    2. Energy orbs fly from the habit card toward the Top Header.
    3. Gold/XP numbers pop up (+10 XP, +5 Gold).
* **Heal Button:** Only appears on a habit card if the Questling is `sick`. Completing the habit "heals" it.
* **Questling Interaction:** Tapping the creature triggers a unique sound or animation.

---

## 3. Inventory Screen (The Quest-Dex)
Grid view of all species.

### Visual Layout
* **Filter Bar:** Filter by Type (Water, Earth, etc.) or Status (Equipped, Collected).
* **Grid:** 3-column view of Questling icons.
    * *Locked Species:* Shown as a silhouette.

### Interaction
* **Questling Detail Modal:** Tapping an icon opens a modal:
    * **Stats:** Level, XP, Birth Date (Hatch Date).
    * **Habit Origin:** "Born from: Drink Water".
    * **"Equip" Button:** Swap current home screen companion.
    * **"Accessory" Button:** Open customization for this creature.

---

## 4. Party Screen (Co-op)
Focus on collective effort.

### Visual Layout
* **Active Goal Card (Top):** Visual of the Boss or Guild Egg.
    * **Global Progress Bar:** 0% -> 100% of weekly goal.
* **Contribution Leaderboard:** List of party members and their "Weekly Energy" contribution.
* **Party Chat/Feed:** "Ranzel completed 'Morning Run' (+50 Energy!)".

### Key Buttons
* **Invite Button:** Generates/copies the 6-character party code.
* **Leave Party:** (In settings sub-menu).

---

## 5. Habit Management Screen
Creation and editing of goals.

### Visual Layout
* **"+" Floating Action Button (FAB):** Opens the "New Habit" workflow.
* **Habit Cards:** Shows Difficulty (Trivial/Easy/Med/Hard) and Current Streak.

### New Habit Workflow
1. Enter Title.
2. Select Difficulty.
3. **Select Category (Icons):** Triggers the "Associated Type" preview (e.g., "Choosing Fitness will attract Earth-types!").
