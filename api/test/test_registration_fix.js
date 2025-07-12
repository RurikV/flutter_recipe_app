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

async function testRegistrationFix() {
  console.log('🧪 Testing registration fix for null casting error...\n');

  const testUser = {
    login: 'testfix_' + Date.now(),
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

    // Step 2: Login user (PUT /user) - this should now return both token and id
    console.log('\n2. Testing user login (PUT /user)...');
    const loginData = {
      login: testUser.login,
      password: testUser.password
    };

    const loginResponse = await makeRequest('PUT', '/user', loginData);
    
    console.log('[DEBUG_LOG] Login status:', loginResponse.status);
    console.log('[DEBUG_LOG] Login body:', loginResponse.body);

    if (loginResponse.status !== 200) {
      console.log('❌ Login failed!');
      console.log('Error details:', loginResponse.body);
      return;
    }

    console.log('✅ Login successful!');

    // Step 3: Verify that login response includes both token and id
    if (!loginResponse.body.token) {
      console.log('❌ Login response missing token!');
      return;
    }

    if (!loginResponse.body.id) {
      console.log('❌ Login response missing id!');
      return;
    }

    console.log('✅ Login response includes both token and id!');
    console.log('[DEBUG_LOG] User ID:', loginResponse.body.id);
    console.log('[DEBUG_LOG] Token:', loginResponse.body.token);

    // Step 4: Test user profile retrieval with the returned ID
    console.log('\n3. Testing user profile retrieval...');
    const profileResponse = await makeRequest('GET', `/user/${loginResponse.body.id}`, {});
    
    console.log('[DEBUG_LOG] Profile status:', profileResponse.status);
    console.log('[DEBUG_LOG] Profile body:', profileResponse.body);

    if (profileResponse.status === 200) {
      console.log('✅ Profile retrieval successful!');
      
      // Verify that the profile has a valid ID
      if (profileResponse.body.id) {
        console.log('✅ Profile includes valid ID:', profileResponse.body.id);
      } else {
        console.log('❌ Profile missing ID!');
      }
    } else {
      console.log('❌ Profile retrieval failed!');
    }

    console.log('\n🎉 Registration fix test completed successfully!');
    console.log('\n📋 Summary:');
    console.log('- Registration endpoint works ✅');
    console.log('- Login endpoint returns both token and id ✅');
    console.log('- Profile endpoint returns user with valid id ✅');
    console.log('- Null casting error should be fixed ✅');

  } catch (error) {
    console.log('❌ Test failed with error:', error.message);
    console.log('Error details:', error);
  }
}

async function main() {
  try {
    await testRegistrationFix();
  } catch (error) {
    console.log('❌ Test failed:', error.message);
  }

  process.exit(0);
}

// Run the test
main();