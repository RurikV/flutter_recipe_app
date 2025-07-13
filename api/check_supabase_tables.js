require('dotenv').config();
const { init, getDb } = require('./config/database');

async function checkTables() {
  try {
    console.log('Checking Supabase database tables...');
    
    await init();
    const supabase = getDb();
    
    console.log('✓ Connected to Supabase');
    
    // Try to query each table to see if it exists
    const tables = ['users', 'measure_units', 'ingredients', 'recipes', 'recipe_steps', 
                   'recipe_step_links', 'recipe_ingredients', 'comments', 'freezer', 'favorites'];
    
    const existingTables = [];
    const missingTables = [];
    
    for (const table of tables) {
      try {
        const { data, error } = await supabase
          .from(table)
          .select('count', { count: 'exact', head: true });
        
        if (error) {
          if (error.code === '42P01') {
            missingTables.push(table);
          } else {
            console.log(`⚠️  Error checking table ${table}:`, error.message);
          }
        } else {
          existingTables.push(table);
        }
      } catch (err) {
        missingTables.push(table);
      }
    }
    
    console.log('\n📊 Table Status:');
    if (existingTables.length > 0) {
      console.log('✅ Existing tables:', existingTables.join(', '));
    }
    
    if (missingTables.length > 0) {
      console.log('❌ Missing tables:', missingTables.join(', '));
      console.log('\n📋 To fix this issue:');
      console.log('1. Go to https://supabase.com/dashboard');
      console.log('2. Select your project: txtnvjycwjngtmqxjohj');
      console.log('3. Go to SQL Editor');
      console.log('4. Copy and paste the contents of setup_supabase_tables.sql');
      console.log('5. Execute the SQL script');
      console.log('\nAlternatively, you can copy this SQL and run it in the SQL Editor:');
      console.log('----------------------------------------');
      console.log(require('fs').readFileSync('./setup_supabase_tables.sql', 'utf8'));
      console.log('----------------------------------------');
    } else {
      console.log('🎉 All required tables exist!');
    }
    
  } catch (error) {
    console.error('❌ Error checking tables:', error);
  }
}

checkTables();