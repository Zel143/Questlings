-- ==========================================
-- PARTY MEMBERS RLS
-- ==========================================

ALTER TABLE party_members ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Members can view their own party's members" ON party_members;
CREATE POLICY "Members can view their own party's members"
ON party_members FOR SELECT
USING (
  party_id IN (
    SELECT party_id FROM party_members WHERE user_id = auth.uid()
  )
);

-- Note: Inserting/Updating is handled by SECURITY DEFINER RPCs (invite_to_party, accept_friend_request)
