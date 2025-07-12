const http = require('http');

async function testUserRegistration() {
  console.log('🧪 Testing user registration to reproduce the error...\n');

  const testUser = {
    login: 'testuser_' + Date.now(),
    password: 'testpassword123',
    avatar: 'https://example.com/avatar.jpg'
  };

  console.log('[DEBUG_LOG] Attempting to register user:', testUser.login);

  return new Promise((resolve, reject) => {
    const postData = JSON.stringify(testUser);

    const options = {
      hostname: 'localhost',
      port: 3000,
      path: '/user',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(postData)
      }
    };

    const req = http.request(options, (res) => {
      let responseData = '';

      res.on('data', (chunk) => {
        responseData += chunk;
      });

      res.on('end', () => {
        console.log('[DEBUG_LOG] Registration response status:', res.statusCode);
        console.log('[DEBUG_LOG] Registration response headers:', res.headers);
        console.log('[DEBUG_LOG] Registration response body:', responseData);

        try {
          const body = responseData ? JSON.parse(responseData) : {};
          resolve({ status: res.statusCode, body, headers: res.headers });
        } catch (e) {
          console.log('[DEBUG_LOG] Failed to parse response as JSON:', e.message);
          resolve({ status: res.statusCode, body: { raw: responseData }, headers: res.headers });
        }
      });
    });

    req.on('error', (err) => {
      console.log('[DEBUG_LOG] Request error occurred:', err.message);
      console.log('[DEBUG_LOG] Error type:', err.code);
      reject(err);
    });

    req.write(postData);
    req.end();
  });
}

async function main() {
  try {
    // Test API health first
    console.log('1. Testing API health...');
    const healthResponse = await testApiHealth();
    console.log('✅ API Health Status:', healthResponse.status === 200 ? 'OK' : 'FAILED');

    // Test user registration
    console.log('\n2. Testing user registration...');
    const registrationResponse = await testUserRegistration();
    
    if (registrationResponse.status === 200) {
      console.log('✅ Registration successful!');
    } else {
      console.log('❌ Registration failed with status:', registrationResponse.status);
      console.log('Error details:', registrationResponse.body);
    }

  } catch (error) {
    console.log('❌ Test failed with error:', error.message);
    console.log('Error details:', error);
  }

  process.exit(0);
}

async function testApiHealth() {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'localhost',
      port: 3000,
      path: '/health',
      method: 'GET'
    };

    const req = http.request(options, (res) => {
      let responseData = '';
      res.on('data', (chunk) => {
        responseData += chunk;
      });
      res.on('end', () => {
        try {
          const body = responseData ? JSON.parse(responseData) : {};
          resolve({ status: res.statusCode, body });
        } catch (e) {
          resolve({ status: res.statusCode, body: { raw: responseData } });
        }
      });
    });

    req.on('error', (err) => {
      reject(err);
    });

    req.end();
  });
}

// Run the test
main();