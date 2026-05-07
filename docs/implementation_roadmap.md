# Questlings - Implementation Roadmap (Backend & Database)

Technical steps to build the Questlings backend using Supabase and Flutter.

## Phase 1: Database Setup (Supabase)
*   **Initialization:** Create a new Supabase project.
*   **Schema Application:** Run SQL migrations based on [schema.md](./schema.md).
    *   Enable Row Level Security (RLS) on all tables.
    *   Set up foreign key relationships.
*   **Auth:** Configure Email/Google providers.

## Phase 2: Logic & Automations (Edge Functions / PostgREST)
*   **Daily Status Update (The "Cron"):** 
    *   Implement a Supabase Edge Function (invoked via `pg_cron`) that runs at 00:00 UTC (or per-user timezone).
    *   **Logic:** Query all habits where `last_completed_at` > 24 hours. Update associated `questlings.status` to `sick`.
*   **Habit Completion Trigger:**
    *   Create a Postgres Trigger or Edge Function for `habits` table updates.
    *   **Logic:** When `last_completed_at` is updated:
        1. Heal `questling` if status was `sick`.
        2. Increment `current_streak`.
        3. Update `missions.current_progress`.
        4. Calculate Energy (Difficulty x Multiplier) and append to `coop_goals`.

## Phase 3: Flutter Integration
*   **Supabase SDK:** Install `supabase_flutter` package.
*   **Models:** Create Dart models for `Profile`, `Questling`, `Habit`, `Mission`, and `Party`.
*   **Realtime:** Enable Supabase Realtime for the `coop_goals` table so the Party Screen updates instantly when a teammate completes a task.

## Phase 4: Social & Security
*   **RLS Policies:**
    *   `profiles`: Users can read any profile (for parties) but only update their own.
    *   `habits`: Users can only read/write their own.
    *   `parties`: Members can read their party data.
*   **Invite System:** Implement a function to join a party via `invite_code`.
