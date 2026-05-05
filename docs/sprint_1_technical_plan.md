# Questlings - Sprint 1 Technical Plan: Core Habit Loop

**Focus:** Establish the functional connection between the Flutter frontend and Supabase backend for the daily habit checklist and "Sick Status" automation.

---

## Formal Backlog

### 1. [SQL] Habit Completion RPC & Triggers
*   **Priority:** High
*   **Complexity:** Medium
*   **Description:** Implement the backend logic to handle habit completion.
*   **Tasks:**
    *   Create a Postgres function `complete_habit(habit_id UUID)` that updates `last_completed_at`.
    *   Add trigger to heal the associated `questling` (set `status` to 'healthy') if it was 'sick'.
    *   Increment user's `current_streak` in the `profiles` table.
*   **Definition of Done:** 
    *   SQL script successfully run in Supabase SQL Editor.
    *   Manual update of `last_completed_at` in DB results in status change from `sick` to `healthy`.

### 2. [Flutter] Habit Checklist UI & Provider
*   **Priority:** High
*   **Complexity:** Medium
*   **Description:** Build the UI for the daily habits and wire it to a Riverpod provider.
*   **Tasks:**
    *   Create `HabitListProvider` to stream today's habits from Supabase.
    *   Implement `HabitTile` widget with a checkbox.
    *   Call Supabase RPC on checkbox toggle.
*   **Definition of Done:** 
    *   Checklist displays live data from `habits` table.
    *   Checking a habit updates the DB and triggers a UI refresh (Realtime).

### 3. [SQL/Edge] The "Cron" Sick Automation
*   **Priority:** Medium
*   **Complexity:** High
*   **Description:** Automatically mark Questlings as `sick` if a habit is missed for 24+ hours.
*   **Tasks:**
    *   Draft `pg_cron` schedule or Edge Function logic.
    *   Query: `UPDATE questlings SET status = 'sick' WHERE id IN (SELECT questling_id FROM habits WHERE last_completed_at < NOW() - INTERVAL '24 hours')`.
*   **Definition of Done:** 
    *   A test habit with an old `last_completed_at` results in the Questling's status becoming `sick` after the function runs.

### 4. [Flutter] UI Status Feedback (Sick State)
*   **Priority:** Medium
*   **Complexity:** Low
*   **Description:** Reflect the "Sick" status on the Home Screen.
*   **Tasks:**
    *   Update `HomeScreen` to display a "Sick" badge/indicator if `equipped_questling.status == 'sick'`.
    *   Apply a grayscale or desaturation filter to the `PixelFilter` if the Questling is sick.
*   **Definition of Done:** 
    *   Questling image looks visually "sick" when status is `sick` in the DB.

---

## Technical Targets

| Component | Target File(s) |
| :--- | :--- |
| **Backend** | Supabase SQL Editor / `schema.md` updates |
| **Logic** | `lib/models/habit.dart`, `lib/core/providers/habit_provider.dart` |
| **UI** | `lib/features/home/widgets/habit_checklist.dart` |
| **Integration** | `lib/core/supabase_client.dart` |
