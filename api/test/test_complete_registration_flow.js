const http = require('http');

async function makeRequest(method, path, data) {
  return new Promise((resolve, reject) => {
    const postData = JSON.stringify(data);

    const options = {
      hostname: 'localhost',
      port: 3000,
      path: path,
      method: method,
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
        try {
          const body = responseData ? JSON.parse(responseData) : {};
          resolve({ status: res.statusCode, body, headers: res.headers });
        } catch (e) {
          resolve({ status: res.statusCode, body: { raw: responseData }, headers: res.headers });
        }
      });
    });

    req.on('error', (err) => {
      reject(err);
    });

    req.write(postData);
    req.end();
  });
}

async function testCompleteRegistrationFlow() {
  console.log('🧪 Testing complete registration flow (registration + login)...\n');

  const testUser = {
    login: 'testuser_' + Date.now(),
    password: 'testpassword123',
    avatar: 'https://example.com/avatar.jpg'
  };

  console.log('[DEBUG_LOG] Testing user:', testUser.login);

  try {
    // Step 1: Register user (POST /user)
    console.log('\n1. Testing user registration (POST /user)...');
    const registrationResponse = await makeRequest('POST', '/user', testUser);
    
    console.log('[DEBUG_LOG] Registration status:', registrationResponse.status);
    console.log('[DEBUG_LOG] Registration body:', registrationResponse.body);

    if (registrationResponse.status !== 200) {
      console.log('❌ Registration failed!');
      return;
    }

    console.log('✅ Registration successful!');

    // Step 2: Login user (PUT /user) - this is what the Flutter app does after registration
    console.log('\n2. Testing user login (PUT /user)...');
    const loginData = {
      login: testUser.login,
      password: testUser.password
    };

    const loginResponse = await makeRequest('PUT', '/user', loginData);
    
    console.log('[DEBUG_LOG] Login status:', loginResponse.status);
    console.log('[DEBUG_LOG] Login body:', loginResponse.body);

    if (loginResponse.status !== 200) {
      console.log('❌ Login failed! This might be the source of the error.');
      console.log('Error details:', loginResponse.body);
      return;
    }

    console.log('✅ Login successful!');

    // Step 3: Get user profile (GET /user/{id}) - this is what happens after login
    if (loginResponse.body.token) {
      console.log('\n3. Testing user profile retrieval...');
      // We need to extract user ID from somewhere - let's try to get user 1 for testing
      const profileResponse = await makeRequest('GET', '/user/1', {});
      
      console.log('[DEBUG_LOG] Profile status:', profileResponse.status);
      console.log('[DEBUG_LOG] Profile body:', profileResponse.body);

      if (profileResponse.status === 200) {
        console.log('✅ Profile retrieval successful!');
      } else {
        console.log('❌ Profile retrieval failed!');
      }
    }

    console.log('\n🎉 Complete registration flow test completed!');

  } catch (error) {
    console.log('❌ Test failed with error:', error.message);
    console.log('Error details:', error);
  }
}

async function main() {
  try {
    await testCompleteRegistrationFlow();
  } catch (error) {
    console.log('❌ Test failed:', error.message);
  }

  process.exit(0);
}

// Run the test
main();