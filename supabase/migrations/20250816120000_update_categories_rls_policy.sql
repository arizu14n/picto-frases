-- Drop the old policy
DROP POLICY IF EXISTS "Users can insert their own categories." ON public.categories;

-- Create the new, more permissive policy
CREATE POLICY "Allow authenticated users to insert their own or default categories."
  ON public.categories FOR INSERT WITH CHECK (user_id IS NULL OR auth.uid() = user_id);
