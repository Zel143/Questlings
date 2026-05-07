-- ==========================================
-- SOCIAL & FRIENDS SYSTEM
-- ==========================================

-- Friend Requests
CREATE TABLE friend_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    receiver_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(sender_id, receiver_id),
    CONSTRAINT no_self_request CHECK (sender_id <> receiver_id)
);

-- Friendships (accepted friend pairs)
CREATE TABLE friendships (
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

CREATE POLICY "Users can view their own sent/received requests."
ON friend_requests FOR SELECT
USING (auth.uid() = sender_id OR auth.uid() = receiver_id);

CREATE POLICY "Users can send friend requests."
ON friend_requests FOR INSERT
WITH CHECK (auth.uid() = sender_id);

CREATE POLICY "Users can delete requests they are part of."
ON friend_requests FOR DELETE
USING (auth.uid() = sender_id OR auth.uid() = receiver_id);

-- friendships (split policy — avoids overly broad FOR ALL)
ALTER TABLE friendships ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view friendships they are part of."
ON friendships FOR SELECT
USING (auth.uid() = user_id_1 OR auth.uid() = user_id_2);

CREATE POLICY "Users can create a friendship they are part of."
ON friendships FOR INSERT
WITH CHECK (auth.uid() = user_id_1 OR auth.uid() = user_id_2);

CREATE POLICY "Users can remove a friendship they are part of."
ON friendships FOR DELETE
USING (auth.uid() = user_id_1 OR auth.uid() = user_id_2);

-- ==========================================
-- ENABLE REALTIME
-- Run these in the Supabase SQL Editor so that .stream() pushes
-- live events to connected clients immediately.
-- ==========================================
ALTER PUBLICATION supabase_realtime ADD TABLE friend_requests;
ALTER PUBLICATION supabase_realtime ADD TABLE friendships;
