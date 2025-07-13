require('dotenv').config();
const { init, getDb } = require('../config/database');

async function testDetailedSupabase() {
  try {
    console.log('🔍 Detailed Supabase connection test...');
    
    // Initialize the database connection
    await init();
    const supabase = getDb();
    
    console.log('✓ Supabase client initialized');
    
    // Test 1: Try to select from users table directly
    console.log('\n1. Testing direct users table access...');
    try {
      const { data, error, count } = await supabase
        .from('users')
        .select('*', { count: 'exact' });
      
      if (error) {
        console.log('❌ Direct users table error:', error);
      } else {
        console.log('✓ Direct users table access successful');
        console.log(`✓ Found ${count} users in the table`);
        if (data && data.length > 0) {
          console.log('✓ Sample user data:', data[0]);
        }
      }
    } catch (err) {
      console.log('❌ Exception accessing users table:', err);
    }
    
    // Test 2: Try to insert a test user
    console.log('\n2. Testing user insertion...');
    try {
      const testUser = {
        login: `test_${Date.now()}`,
        password: 'hashedpassword123',
        avatar: ''
      };
      
      const { data, error } = await supabase
        .from('users')
        .insert([testUser])
        .select()
        .single();
      
      if (error) {
        console.log('❌ User insertion error:', error);
      } else {
        console.log('✓ User insertion successful:', data);
        
        // Clean up - delete the test user
        await supabase.from('users').delete().eq('id', data.id);
        console.log('✓ Test user cleaned up');
      }
    } catch (err) {
      console.log('❌ Exception during user insertion:', err);
    }
    
    // Test 3: Check what tables are actually available
    console.log('\n3. Checking available tables...');
    try {
      // This might not work with Supabase, but let's try
      const { data, error } = await supabase.rpc('get_schema_tables');
      if (error) {
        console.log('⚠️  Cannot get schema info via RPC:', error.message);
      } else {
        console.log('✓ Available tables:', data);
      }
    } catch (err) {
      console.log('⚠️  Cannot get schema info:', err.message);
    }
    
    console.log('\n🎯 Test completed');
    
  } catch (error) {
    console.error('❌ Detailed test failed:', error);
  }
}

testDetailedSupabase();