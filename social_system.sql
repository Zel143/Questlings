-- ==========================================
-- SOCIAL & FRIENDS SYSTEM
-- Run the ENTIRE file in Supabase SQL Editor
-- ==========================================

-- Friend Requests
CREATE TABLE IF NOT EXISTS friend_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    receiver_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(sender_id, receiver_id),
    CONSTRAINT no_self_request CHECK (sender_id <> receiver_id)
);

-- Friendships (accepted friend pairs)
CREATE TABLE IF NOT EXISTS friendships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id_1 UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    user_id_2 UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id_1, user_id_2),
    CONSTRAINT no_self_friendship CHECK (user_id_1 <> user_id_2)
);

-- ==========================================
-- ROW LEVEL SECURITY
-- ==========================================

-- friend_requests
ALTER TABLE friend_requests ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view their own sent/received requests." ON friend_requests;
CREATE POLICY "Users can view their own sent/received requests."
ON friend_requests FOR SELECT
USING (auth.uid() = sender_id OR auth.uid() = receiver_id);

DROP POLICY IF EXISTS "Users can send friend requests." ON friend_requests;
CREATE POLICY "Users can send friend requests."
ON friend_requests FOR INSERT
WITH CHECK (auth.uid() = sender_id);

DROP POLICY IF EXISTS "Users can delete requests they are part of." ON friend_requests;
CREATE POLICY "Users can delete requests they are part of."
ON friend_requests FOR DELETE
USING (auth.uid() = sender_id OR auth.uid() = receiver_id);

-- friendships
ALTER TABLE friendships ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view friendships they are part of." ON friendships;
CREATE POLICY "Users can view friendships they are part of."
ON friendships FOR SELECT
USING (auth.uid() = user_id_1 OR auth.uid() = user_id_2);

DROP POLICY IF EXISTS "Users can create a friendship they are part of." ON friendships;
CREATE POLICY "Users can create a friendship they are part of."
ON friendships FOR INSERT
WITH CHECK (auth.uid() = user_id_1 OR auth.uid() = user_id_2);

DROP POLICY IF EXISTS "Users can remove a friendship they are part of." ON friendships;
CREATE POLICY "Users can remove a friendship they are part of."
ON friendships FOR DELETE
USING (auth.uid() = user_id_1 OR auth.uid() = user_id_2);

-- ==========================================
-- ACCEPT FRIEND REQUEST FUNCTION (RPC)
-- Uses SECURITY DEFINER so it can update BOTH users'
-- party_id without RLS blocking cross-user updates.
-- ==========================================
CREATE OR REPLACE FUNCTION accept_friend_request(
  p_request_id UUID,
  p_sender_id  UUID
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_my_id        UUID;
  v_sender_party UUID;
  v_my_party     UUID;
  v_party_id     UUID;
  v_id1          UUID;
  v_id2          UUID;
BEGIN
  v_my_id := auth.uid();

  -- Verify the request is legitimate (must exist and belong to caller)
  IF NOT EXISTS (
    SELECT 1 FROM friend_requests
    WHERE id = p_request_id
      AND receiver_id = v_my_id
      AND sender_id   = p_sender_id
  ) THEN
    RAISE EXCEPTION 'Friend request not found or you are not the receiver';
  END IF;

  -- ── 1. Insert friendship (normalised order prevents duplicates) ──
  IF v_my_id < p_sender_id THEN
    v_id1 := v_my_id;  v_id2 := p_sender_id;
  ELSE
    v_id1 := p_sender_id; v_id2 := v_my_id;
  END IF;

  INSERT INTO friendships (user_id_1, user_id_2)
  VALUES (v_id1, v_id2)
  ON CONFLICT DO NOTHING;

  -- ── 2. Party assignment ──
  SELECT party_id INTO v_my_party     FROM users WHERE id = v_my_id;
  SELECT party_id INTO v_sender_party FROM users WHERE id = p_sender_id;

  IF v_my_party IS NOT NULL THEN
    -- Receiver already has a party — add sender to it
    v_party_id := v_my_party;
  ELSIF v_sender_party IS NOT NULL THEN
    -- Sender already has a party — add receiver to it
    v_party_id := v_sender_party;
  ELSE
    -- Neither has a party — create a brand-new one
    INSERT INTO parties (name) VALUES ('Party') RETURNING id INTO v_party_id;
  END IF;

  -- Update receiver if needed
  IF v_my_party IS DISTINCT FROM v_party_id THEN
    -- Enforce 4-member party cap
    IF (SELECT COUNT(*) FROM party_members WHERE party_id = v_party_id) >= 4 THEN
      RAISE EXCEPTION 'Party is full (max 4 members)';
    END IF;
    UPDATE users SET party_id = v_party_id WHERE id = v_my_id;
    INSERT INTO party_members (user_id, party_id, weekly_energy_contribution)
    VALUES (v_my_id, v_party_id, 0)
    ON CONFLICT DO NOTHING;
  END IF;

  -- Update sender if needed
  IF v_sender_party IS DISTINCT FROM v_party_id THEN
    -- Enforce 4-member party cap
    IF (SELECT COUNT(*) FROM party_members WHERE party_id = v_party_id) >= 4 THEN
      RAISE EXCEPTION 'Party is full (max 4 members)';
    END IF;
    UPDATE users SET party_id = v_party_id WHERE id = p_sender_id;
    INSERT INTO party_members (user_id, party_id, weekly_energy_contribution)
    VALUES (p_sender_id, v_party_id, 0)
    ON CONFLICT DO NOTHING;
  END IF;

  -- ── 3. Delete the request (always, even on duplicate friendship) ──
  DELETE FROM friend_requests WHERE id = p_request_id;
END;
$$;

-- ==========================================
-- ENABLE REALTIME
-- ==========================================
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime' AND tablename = 'friend_requests'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE friend_requests;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime' AND tablename = 'friendships'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE friendships;
  END IF;
END $$;
