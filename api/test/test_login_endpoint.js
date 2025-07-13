const express = require('express');
const cors = require('cors');
const { init } = require('../config/database');
const userRoutes = require('../routes/user');

async function testLoginEndpoint() {
  try {
    console.log('1. Initializing database...');
    await init();
    console.log('✅ Database initialized');

    console.log('\n2. Setting up Express server...');
    const app = express();

    // Middleware
    app.use(cors());
    app.use(express.json());

    // Routes
    app.use('/user', userRoutes);

    const server = app.listen(3001, () => {
      console.log('✅ Test server running on port 3001');
    });

    console.log('\n3. Testing login endpoint...');

    // Wait a moment for server to start
    await new Promise(resolve => setTimeout(resolve, 1000));

    // Make login request
    const response = await fetch('http://localhost:3001/user', {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        login: 'user1',
        password: 'password123'
      })
    });

    console.log('✅ Response status:', response.status);

    if (response.ok) {
      const data = await response.json();
      console.log('✅ Login successful!');
      console.log('✅ Response data:', data);
      console.log('✅ Token received:', data.token ? 'Yes' : 'No');
      console.log('✅ User ID:', data.id);
    } else {
      const errorData = await response.json();
      console.log('❌ Login failed!');
      console.log('❌ Error:', errorData);
    }

    server.close();
    console.log('\n✅ Test completed');

  } catch (error) {
    console.error('❌ Error:', error);
  }
}

testLoginEndpoint();
