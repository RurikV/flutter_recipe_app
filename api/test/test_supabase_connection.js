require('dotenv').config();
const { init, getDb } = require('../config/database');

async function testSupabaseConnection() {
  try {
    console.log('Testing Supabase connection...');
    
    // Initialize the database connection
    await init();
    console.log('✓ Database initialized successfully');
    
    // Get the Supabase client
    const supabase = getDb();
    console.log('✓ Supabase client obtained');
    
    // Test a simple query to check if we can connect to the database
    const { data, error } = await supabase
      .from('users')
      .select('count', { count: 'exact', head: true });
    
    if (error) {
      console.error('✗ Error querying users table:', error);
      return;
    }
    
    console.log('✓ Successfully connected to Supabase');
    console.log(`✓ Users table exists and contains ${data || 0} records`);
    
    // Test the User model
    const User = require('../models/User');
    console.log('✓ User model loaded successfully');
    
    console.log('\n🎉 All tests passed! Supabase integration is working correctly.');
    
  } catch (error) {
    console.error('✗ Test failed:', error.message);
    console.error('Full error:', error);
  }
}

testSupabaseConnection();