-- Sick Status Automation
-- Created: 2026-05-06

-- 1. Enable pg_cron extension if not already enabled
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- 2. Function to mark Questlings as sick if habits are missed
CREATE OR REPLACE FUNCTION check_for_sick_questlings()
RETURNS VOID AS $$
BEGIN
  -- Update Questlings whose assigned habit was missed for > 24 hours
  -- Only target 'healthy' ones to avoid redundant updates
  UPDATE questlings
  SET status = 'sick'
  WHERE status = 'healthy'
    AND habit_id IS NOT NULL
    AND habit_id IN (
      SELECT id FROM habits
      WHERE last_completed_at < NOW() - INTERVAL '24 hours'
      OR (last_completed_at IS NULL AND created_at < NOW() - INTERVAL '24 hours')
    );
END;
$$ LANGUAGE plpgsql;

-- 3. Schedule the check to run every hour (or once daily at midnight)
-- Using '0 * * * *' for every hour to catch status changes closer to the 24h mark
SELECT cron.schedule('check-sick-questlings', '0 * * * *', 'SELECT check_for_sick_questlings()');
