# 🚀 Supabase Database Setup Instructions

## Manual Table Creation

### Step 1: Access Supabase Dashboard
1. Go to [https://supabase.com/dashboard](https://supabase.com/dashboard)
2. Select your project: `txtnvjycwjngtmqxjohj`
3. Navigate to **SQL Editor** in the left sidebar
4. Click **New Query**

### Step 2: Execute the SQL Script
Copy and paste the following SQL script into the SQL Editor and click **Run**:

```sql
-- Create users table
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  login TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  token TEXT,
  avatar TEXT DEFAULT '',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create measure_units table
CREATE TABLE IF NOT EXISTS measure_units (
  id SERIAL PRIMARY KEY,
  one TEXT NOT NULL,
  few TEXT NOT NULL,
  many TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create ingredients table
CREATE TABLE IF NOT EXISTS ingredients (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  caloriesForUnit REAL NOT NULL DEFAULT 0,
  measureUnit_id INTEGER REFERENCES measure_units(id),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create recipes table
CREATE TABLE IF NOT EXISTS recipes (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  duration INTEGER NOT NULL DEFAULT 0,
  photo TEXT DEFAULT '',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create recipe_steps table
CREATE TABLE IF NOT EXISTS recipe_steps (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  duration INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create recipe_step_links table
CREATE TABLE IF NOT EXISTS recipe_step_links (
  id SERIAL PRIMARY KEY,
  number INTEGER NOT NULL,
  recipe_id INTEGER NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
  step_id INTEGER NOT NULL REFERENCES recipe_steps(id) ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create recipe_ingredients table
CREATE TABLE IF NOT EXISTS recipe_ingredients (
  id SERIAL PRIMARY KEY,
  count INTEGER NOT NULL,
  ingredient_id INTEGER NOT NULL REFERENCES ingredients(id) ON DELETE CASCADE,
  recipe_id INTEGER NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create comments table
CREATE TABLE IF NOT EXISTS comments (
  id SERIAL PRIMARY KEY,
  text TEXT NOT NULL,
  photo TEXT DEFAULT '',
  datetime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  recipe_id INTEGER NOT NULL REFERENCES recipes(id) ON DELETE CASCADE
);

-- Create freezer table
CREATE TABLE IF NOT EXISTS freezer (
  id SERIAL PRIMARY KEY,
  count REAL NOT NULL,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  ingredient_id INTEGER NOT NULL REFERENCES ingredients(id) ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create favorites table
CREATE TABLE IF NOT EXISTS favorites (
  id SERIAL PRIMARY KEY,
  recipe_id INTEGER NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(recipe_id, user_id)
);

-- Insert default measure units
INSERT INTO measure_units (one, few, many) VALUES
  ('gram', 'grams', 'grams'),
  ('kilogram', 'kilograms', 'kilograms'),
  ('liter', 'liters', 'liters'),
  ('milliliter', 'milliliters', 'milliliters'),
  ('piece', 'pieces', 'pieces'),
  ('cup', 'cups', 'cups'),
  ('tablespoon', 'tablespoons', 'tablespoons'),
  ('teaspoon', 'teaspoons', 'teaspoons')
ON CONFLICT DO NOTHING;

-- Insert sample ingredients
INSERT INTO ingredients (name, caloriesForUnit, measureUnit_id) VALUES
  ('Flour', 364, 1),
  ('Sugar', 387, 1),
  ('Eggs', 155, 5),
  ('Milk', 42, 4),
  ('Butter', 717, 1),
  ('Salt', 0, 8),
  ('Olive Oil', 884, 7),
  ('Chicken Breast', 165, 1),
  ('Tomatoes', 18, 1),
  ('Onions', 40, 1)
ON CONFLICT DO NOTHING;

-- Insert sample recipes
INSERT INTO recipes (name, duration, photo) VALUES
  ('Pancakes', 20, 'https://example.com/pancakes.jpg'),
  ('Scrambled Eggs', 10, 'https://example.com/eggs.jpg'),
  ('Grilled Chicken', 25, 'https://example.com/chicken.jpg'),
  ('Caesar Salad', 15, 'https://example.com/salad.jpg'),
  ('Chocolate Cake', 60, 'https://example.com/cake.jpg')
ON CONFLICT DO NOTHING;

-- Insert sample recipe steps
INSERT INTO recipe_steps (name, duration) VALUES
  ('Mix dry ingredients', 5),
  ('Add wet ingredients', 3),
  ('Cook on medium heat', 10),
  ('Flip and cook other side', 5),
  ('Serve hot', 1),
  ('Preheat oven to 350°F', 10),
  ('Beat eggs until fluffy', 3),
  ('Season with salt and pepper', 1)
ON CONFLICT DO NOTHING;

-- Insert sample recipe step links (connecting recipes to steps)
INSERT INTO recipe_step_links (recipe_id, step_id, number) VALUES
  (1, 1, 1), -- Pancakes: Mix dry ingredients
  (1, 2, 2), -- Pancakes: Add wet ingredients  
  (1, 3, 3), -- Pancakes: Cook on medium heat
  (1, 4, 4), -- Pancakes: Flip and cook other side
  (1, 5, 5), -- Pancakes: Serve hot
  (2, 7, 1), -- Scrambled Eggs: Beat eggs until fluffy
  (2, 3, 2), -- Scrambled Eggs: Cook on medium heat
  (2, 8, 3), -- Scrambled Eggs: Season with salt and pepper
  (2, 5, 4)  -- Scrambled Eggs: Serve hot
ON CONFLICT DO NOTHING;

-- Insert sample recipe ingredients (connecting recipes to ingredients)
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, count) VALUES
  (1, 1, 200), -- Pancakes: 200g Flour
  (1, 2, 50),  -- Pancakes: 50g Sugar
  (1, 3, 2),   -- Pancakes: 2 Eggs
  (1, 4, 250), -- Pancakes: 250ml Milk
  (1, 5, 30),  -- Pancakes: 30g Butter
  (2, 3, 3),   -- Scrambled Eggs: 3 Eggs
  (2, 5, 20),  -- Scrambled Eggs: 20g Butter
  (2, 6, 1),   -- Scrambled Eggs: 1 tsp Salt
  (3, 8, 500), -- Grilled Chicken: 500g Chicken Breast
  (3, 7, 2),   -- Grilled Chicken: 2 tbsp Olive Oil
  (3, 6, 1)    -- Grilled Chicken: 1 tsp Salt
ON CONFLICT DO NOTHING;
```

### Step 3: Verify Table Creation
After executing the SQL script:
1. Go to **Table Editor** in the left sidebar
2. You should see all the created tables listed:
   - users
   - measure_units
   - ingredients
   - recipes
   - recipe_steps
   - recipe_step_links
   - recipe_ingredients
   - comments
   - freezer
   - favorites

### Step 4: Test the Setup
Run the verification script to confirm everything is working:

```bash
cd api
node check_supabase_tables.js
```

You should see successful results for all table operations.

### Step 5: Test the API
Start the API server and test the endpoints:

```bash
# Start the server
vercel dev

# In another terminal, test the recipes endpoint
curl http://localhost:3000/recipe
```

You should now see a JSON response with the sample recipes instead of the error.

## Troubleshooting

### If you still get "relation does not exist" errors:
1. Make sure you executed the SQL script in the correct Supabase project
2. Check that you're using the correct SUPABASE_URL and SUPABASE_ANON_KEY in your `.env` file
3. Verify the tables exist in the Table Editor
4. Try refreshing your browser and running the SQL script again

### If you get permission errors:
1. Make sure you're using the `anon` key, not the `service_role` key
2. Check that Row Level Security (RLS) is disabled for testing, or configure appropriate policies

### Environment Variables
Ensure your `.env` file contains:
```
SUPABASE_URL=https://txtnvjycwjngtmqxjohj.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

## Next Steps
Once the tables are created and the API is working:
1. The `/recipe` endpoint should return sample recipes
2. User registration and authentication will work
3. All other API endpoints will function properly
4. You can start using the Flutter app with the API

---

**This setup needs to be done only once.** After the tables are created, they will persist in your Supabase database.