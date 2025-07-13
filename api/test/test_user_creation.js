const { init } = require('../config/database');
const { User } = require('../models');

async function testUserCreation() {
  try {
    console.log('1. Initializing database...');
    await init();
    console.log('✅ Database initialized');

    console.log('\n2. Checking if test user exists...');
    const user = await User.findByLogin('user1');

    if (user) {
      console.log('✅ Test user found:', user.login);
      console.log('✅ User ID:', user.id);
      console.log('✅ Password hash:', user.password);

      console.log('\n3. Testing password comparison manually...');
      const bcrypt = require('bcryptjs');
      const isValidPassword = await bcrypt.compare('user1', user.password);
      console.log('✅ Manual password comparison result:', isValidPassword);

      console.log('\n4. Testing authentication...');
      try {
        const authenticatedUser = await User.authenticate('user1', 'user1');
        console.log('✅ Authentication successful for user:', authenticatedUser.login);
        console.log('✅ User ID:', authenticatedUser.id);
        console.log('✅ Token generated:', authenticatedUser.token ? 'Yes' : 'No');
      } catch (authError) {
        console.log('❌ Authentication failed:', authError.message);
      }
    } else {
      console.log('❌ Test user not found');
    }

  } catch (error) {
    console.error('❌ Error:', error);
  }
}

testUserCreation();
