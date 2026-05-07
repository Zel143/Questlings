-- ==========================================
-- PARTY INVITE RPC + GOALS RLS
-- Run this ENTIRE file in Supabase SQL Editor
-- ==========================================

-- ──────────────────────────────────────────
-- 1. invite_to_party — SECURITY DEFINER RPC
--    Adds a friend to the caller's party.
--    If the caller has no party, creates one.
-- ──────────────────────────────────────────

CREATE OR REPLACE FUNCTION invite_to_party(p_friend_id UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_my_id    UUID;
  v_party_id UUID;
  v_id1      UUID;
  v_id2      UUID;
BEGIN
  v_my_id := auth.uid();

  -- Verify they are actually friends
  IF v_my_id < p_friend_id THEN
    v_id1 := v_my_id; v_id2 := p_friend_id;
  ELSE
    v_id1 := p_friend_id; v_id2 := v_my_id;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM friendships
    WHERE user_id_1 = v_id1 AND user_id_2 = v_id2
  ) THEN
    RAISE EXCEPTION 'You are not friends with this user';
  END IF;

  -- Get or create the caller's party
  SELECT party_id INTO v_party_id FROM users WHERE id = v_my_id;

  IF v_party_id IS NULL THEN
    INSERT INTO parties (name) VALUES ('Party') RETURNING id INTO v_party_id;
    UPDATE users SET party_id = v_party_id WHERE id = v_my_id;
    INSERT INTO party_members (user_id, party_id, weekly_energy_contribution)
    VALUES (v_my_id, v_party_id, 0) ON CONFLICT DO NOTHING;
  END IF;

  -- Enforce 4-member party cap
  IF (SELECT COUNT(*) FROM party_members WHERE party_id = v_party_id) >= 4 THEN
    RAISE EXCEPTION 'Party is full (max 4 members)';
  END IF;

  -- Add the friend to the party
  UPDATE users SET party_id = v_party_id WHERE id = p_friend_id;
  INSERT INTO party_members (user_id, party_id, weekly_energy_contribution)
  VALUES (p_friend_id, v_party_id, 0) ON CONFLICT DO NOTHING;
END;
$$;

-- ──────────────────────────────────────────
-- 2. party_goals RLS policies
-- ──────────────────────────────────────────

ALTER TABLE party_goals ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Party members can view their party goals" ON party_goals;
CREATE POLICY "Party members can view their party goals"
ON party_goals FOR SELECT
USING (
  party_id IN (
    SELECT party_id FROM party_members WHERE user_id = auth.uid()
  )
);

DROP POLICY IF EXISTS "Party members can create goals" ON party_goals;
CREATE POLICY "Party members can create goals"
ON party_goals FOR INSERT
WITH CHECK (
  party_id IN (
    SELECT party_id FROM party_members WHERE user_id = auth.uid()
  )
);

DROP POLICY IF EXISTS "Party members can update goals" ON party_goals;
CREATE POLICY "Party members can update goals"
ON party_goals FOR UPDATE
USING (
  party_id IN (
    SELECT party_id FROM party_members WHERE user_id = auth.uid()
  )
);
