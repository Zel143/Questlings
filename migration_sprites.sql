-- ==========================================
-- MIGRATION: Add sprite_path to questling_dictionary
-- and update default data with the 4 actual starters
-- ==========================================

-- 1. Add the sprite_path column if it doesn't exist
ALTER TABLE questling_dictionary 
ADD COLUMN IF NOT EXISTS sprite_path VARCHAR(255);

-- 2. Remove old starter data that doesn't match actual sprites
DELETE FROM questling_dictionary WHERE id IN (
  '11111111-1111-1111-1111-111111111111',
  '22222222-2222-2222-2222-222222222222',
  '33333333-3333-3333-3333-333333333333'
);

-- 3. Insert the 4 actual starters with sprite paths
INSERT INTO questling_dictionary (id, name, elemental_type, description, base_hatch_days, sprite_path) VALUES
('11111111-1111-1111-1111-111111111111', 'Sports-ling', 'Sports', 'A fiery red bird that loves athletics and outdoor adventure.', 3, 'assets/sprites/Sports-ling/Starter1.jpg'),
('22222222-2222-2222-2222-222222222222', 'Tech-ling', 'Tech', 'A brainy capybara equipped with a laptop, always debugging.', 3, 'assets/sprites/Tech-ling/Starter2.jpg'),
('33333333-3333-3333-3333-333333333333', 'Art-ling', 'Art', 'A creative chameleon that paints with every color it finds.', 3, 'assets/sprites/Art-ling/Starter3.png'),
('44444444-4444-4444-4444-444444444444', 'Skool-ling', 'School', 'A wise owl scholar with a backpack full of knowledge.', 3, 'assets/sprites/Skool-ling/Starter4.jpg')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  elemental_type = EXCLUDED.elemental_type,
  description = EXCLUDED.description,
  sprite_path = EXCLUDED.sprite_path;

-- 4. Add RLS for questling_dictionary if not already present
ALTER TABLE questling_dictionary ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can view questling_dictionary." ON questling_dictionary;
CREATE POLICY "Anyone can view questling_dictionary." ON questling_dictionary FOR SELECT USING (true);
