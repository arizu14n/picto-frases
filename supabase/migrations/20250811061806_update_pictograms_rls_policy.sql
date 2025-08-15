-- Drop the old policy
DROP POLICY IF EXISTS "Users can insert their own pictograms." ON public.pictograms;

-- Create the new, more permissive policy
CREATE POLICY "Allow authenticated users to insert their own or default pictograms."
  ON public.pictograms FOR INSERT WITH CHECK (user_id IS NULL OR auth.uid() = user_id);
