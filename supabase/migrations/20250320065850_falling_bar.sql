/*
  # Create Schulte Table Training Records Schema

  1. New Tables
    - `schulte_records`
      - `id` (uuid, primary key)
      - `user_id` (uuid, references auth.users)
      - `grid_size` (integer)
      - `completion_time` (float)
      - `created_at` (timestamp)

  2. Security
    - Enable RLS on `schulte_records` table
    - Add policies for authenticated users to manage their own records
*/

CREATE TABLE IF NOT EXISTS schulte_records (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users NOT NULL,
  grid_size integer NOT NULL,
  completion_time float NOT NULL,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE schulte_records ENABLE ROW LEVEL SECURITY;

DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'schulte_records' 
    AND policyname = 'Users can insert their own records'
  ) THEN
    CREATE POLICY "Users can insert their own records"
      ON schulte_records
      FOR INSERT
      TO authenticated
      WITH CHECK (auth.uid() = user_id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'schulte_records' 
    AND policyname = 'Users can read their own records'
  ) THEN
    CREATE POLICY "Users can read their own records"
      ON schulte_records
      FOR SELECT
      TO authenticated
      USING (auth.uid() = user_id);
  END IF;
END $$;