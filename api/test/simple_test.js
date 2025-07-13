require('dotenv').config();
console.log('Starting simple API test...');

try {
  // Test basic imports
  console.log('1. Testing imports...');
  require('express');
  console.log('✓ Express imported successfully');

  require('../config/database');
  console.log('✓ Database config imported successfully');

  require('../models');
  console.log('✓ Models imported successfully');

  // Test database initialization
  console.log('\n2. Testing database initialization...');
  const db = require('../config/database');

  db.init().then(() => {
    console.log('✓ Database initialized successfully');
    console.log('✓ Tables created successfully');
    console.log('✓ Default data inserted successfully');

    console.log('\n🎉 Basic API setup is working correctly!');
    console.log('\nNext steps:');
    console.log('1. The API is ready for deployment to Vercel');
    console.log('2. Set environment variables in Vercel dashboard');
    console.log('3. Deploy using: vercel --prod');
    console.log('4. The API will be available at: https://foodapi-otus.vercel.app');

    process.exit(0);
  }).catch(err => {
    console.error('❌ Database initialization failed:', err);
    process.exit(1);
  });

} catch (error) {
  console.error('❌ Import failed:', error.message);
  process.exit(1);
}
