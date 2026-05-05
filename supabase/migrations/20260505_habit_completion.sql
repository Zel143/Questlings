-- Habit Completion RPC & Healing Logic
-- Created: 2026-05-05

-- 1. Function to complete a habit (RPC)
-- This handles updating the completion timestamp, incrementing the streak,
-- and automatically healing the associated Questling if it was sick.
CREATE OR REPLACE FUNCTION complete_habit(target_habit_id UUID)
RETURNS VOID AS $$
BEGIN
  -- Update habit completion time and streak
  UPDATE habits
  SET 
    last_completed_at = NOW(),
    current_streak = current_streak + 1
  WHERE id = target_habit_id;

  -- Heal the associated questling if it was sick
  UPDATE questlings
  SET status = 'healthy'
  WHERE habit_id = target_habit_id 
    AND status = 'sick';
END;
$$ LANGUAGE plpgsql;
