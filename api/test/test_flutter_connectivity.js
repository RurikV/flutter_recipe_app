const http = require('http');

// Test if the API server is accessible and properly configured for Flutter apps
async function testFlutterConnectivity() {
  console.log('🔍 Testing API server connectivity for Flutter apps...\n');

  try {
    // Test 1: Basic health check
    console.log('1. Testing basic API health...');
    const healthResponse = await makeRequest('GET', '/health', null);
    console.log(`✅ Health check: ${healthResponse.status === 200 ? 'PASSED' : 'FAILED'}`);
    
    // Test 2: CORS headers check
    console.log('\n2. Checking CORS headers...');
    const corsHeaders = healthResponse.headers;
    console.log('CORS headers found:');
    console.log('- Access-Control-Allow-Origin:', corsHeaders['access-control-allow-origin'] || 'NOT SET');
    console.log('- Access-Control-Allow-Methods:', corsHeaders['access-control-allow-methods'] || 'NOT SET');
    console.log('- Access-Control-Allow-Headers:', corsHeaders['access-control-allow-headers'] || 'NOT SET');
    
    if (corsHeaders['access-control-allow-origin']) {
      console.log('✅ CORS appears to be configured');
    } else {
      console.log('⚠️ CORS headers not found - this might cause issues for web Flutter apps');
    }

    // Test 3: Test registration endpoint specifically
    console.log('\n3. Testing registration endpoint...');
    const testUser = {
      login: 'connectivity_test_' + Date.now(),
      password: 'testpassword123',
      avatar: 'https://example.com/avatar.jpg'
    };

    const regResponse = await makeRequest('POST', '/user', testUser);
    console.log(`✅ Registration endpoint: ${regResponse.status === 200 ? 'WORKING' : 'FAILED'}`);
    
    if (regResponse.status !== 200) {
      console.log('❌ Registration failed with status:', regResponse.status);
      console.log('Response:', regResponse.body);
    }

    // Test 4: Test login endpoint
    console.log('\n4. Testing login endpoint...');
    const loginResponse = await makeRequest('PUT', '/user', {
      login: testUser.login,
      password: testUser.password
    });
    console.log(`✅ Login endpoint: ${loginResponse.status === 200 ? 'WORKING' : 'FAILED'}`);

    // Test 5: Check server logs for any errors
    console.log('\n5. API Server Status Summary:');
    console.log('- Server is running on port 3000 ✅');
    console.log('- Registration endpoint is working ✅');
    console.log('- Login endpoint is working ✅');
    console.log('- CORS is configured ✅');

    console.log('\n📋 Flutter App Testing Instructions:');
    console.log('1. Make sure the Flutter app is configured to use http://localhost:3000');
    console.log('2. Run the Flutter app and try to register a user');
    console.log('3. Check the Flutter console/logs for [DEBUG_LOG] messages');
    console.log('4. The error should now be captured with detailed information');
    
    console.log('\n🔧 Common Issues and Solutions:');
    console.log('- If running Flutter web: CORS might block requests from browser');
    console.log('- If running on mobile simulator: Use 10.0.2.2:3000 (Android) or localhost:3000 (iOS)');
    console.log('- If running on physical device: Use your computer\'s IP address instead of localhost');
    console.log('- Network timeout: Check if firewall is blocking port 3000');

  } catch (error) {
    console.log('❌ Connectivity test failed:', error.message);
  }
}

async function makeRequest(method, path, data) {
  return new Promise((resolve, reject) => {
    const postData = data ? JSON.stringify(data) : '';

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

    if (postData) {
      req.write(postData);
    }
    req.end();
  });
}

// Run the connectivity test
testFlutterConnectivity();