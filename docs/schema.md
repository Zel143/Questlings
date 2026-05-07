# Questlings - Database Schema (Supabase/PostgreSQL)

This document outlines the database structure for the Questlings mobile app.

## 1. `profiles`
Tracks user-specific RPG stats and party membership.

| Column | Type | Description |
| :--- | :--- | :--- |
| `id` | uuid (PK) | References `auth.users` |
| `username` | text | Display name |
| `experience_points` | integer | Total XP earned |
| `level` | integer | Calculated from XP |
| `gold` | integer | Currency for the Bazaar |
| `class` | text | warrior, mage, rogue, healer, or null |
| `party_id` | uuid (FK) | References `parties.id` |
| `updated_at` | timestamp | |

## 2. `questlings`
The collection of creatures owned by users.

| Column | Type | Description |
| :--- | :--- | :--- |
| `id` | uuid (PK) | |
| `owner_id` | uuid (FK) | References `profiles.id` |
| `species_id` | text | Unique identifier for the creature type |
| `nickname` | text | User-defined name |
| `status` | text | healthy, sick, tired |
| `habit_id` | uuid (FK) | Assigned habit (null if unassigned) |
| `is_equipped` | boolean | True if visible on home screen |
| `created_at` | timestamp | |

## 3. `habits`
User-defined daily habits.

| Column | Type | Description |
| :--- | :--- | :--- |
| `id` | uuid (PK) | |
| `user_id` | uuid (FK) | References `profiles.id` |
| `title` | text | e.g., "Drink Water" |
| `difficulty` | text | trivial, easy, medium, hard |
| `category` | text | fitness, study, mindfulness, etc. |
| `current_streak` | integer | |
| `last_completed_at`| timestamp | Used to calculate "Sick" status |
| `created_at` | timestamp | |

## 4. `missions`
Multi-day quests to unlock new Questlings.

| Column | Type | Description |
| :--- | :--- | :--- |
| `id` | uuid (PK) | |
| `user_id` | uuid (FK) | References `profiles.id` |
| `habit_id` | uuid (FK) | The habit tied to this mission |
| `target_days` | integer | Total days required |
| `current_progress` | integer | Days completed in streak |
| `reward_species_id`| text | Species unlocked on completion |
| `status` | text | active, completed, failed |

## 5. `parties`
Groups for co-op play.

| Column | Type | Description |
| :--- | :--- | :--- |
| `id` | uuid (PK) | |
| `name` | text | |
| `invite_code` | text | Unique 6-char code for joining |
| `created_at` | timestamp | |

## 6. `coop_goals`
Active weekly objectives for a party.

| Column | Type | Description |
| :--- | :--- | :--- |
| `id` | uuid (PK) | |
| `party_id` | uuid (FK) | References `parties.id` |
| `type` | text | boss, egg |
| `target_value` | integer | Total energy/HP needed |
| `current_value` | integer | Total energy/HP pooled |
| `ends_at` | timestamp | Usually Sunday at midnight |

---

## Technical Notes

### Sick/Sad Status Logic
*   **Logic:** If `now() - habits.last_completed_at > 24 hours` (adjusted for the user's "day start" time), the assigned Questling's status shifts to `sick`.
*   **Implementation:** Can be handled via a **Supabase Edge Function** (Cron job) that runs nightly to update statuses and reset mission progress.

### Energy Contribution
*   When a user completes a habit, a trigger or edge function:
    1. Increments `habits.current_streak`.
    2. Increments `missions.current_progress`.
    3. Calculates Energy based on `difficulty` (e.g., Easy=10, Hard=50).
    4. Adds that Energy to the active `coop_goals.current_value` for their party.
