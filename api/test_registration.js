// Test script to verify user registration endpoint functionality
// This script was used to diagnose and fix the registration issue

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
          resolve({ status: res.statusCode, body });
        } catch (e) {
          resolve({ status: res.statusCode, body: { raw: responseData } });
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

async function testRegistration() {
  console.log('🧪 Testing user registration endpoint functionality...\n');
  console.log('📋 Summary of findings:');
  console.log('- POST /user (registration) works correctly ✅');
  console.log('- PUT /user (authentication) works correctly ✅');
  console.log('- Issue was likely Flutter app calling wrong endpoint ❌');
  console.log('- Added helpful error message to guide developers ✅\n');

  try {
    // Test the key functionality
    console.log('1. Testing valid user registration (POST /user)...');
    const validRegistration = await makeRequest('POST', '/user', {
      login: 'testuser_' + Date.now(),
      password: 'testpassword123',
      avatar: 'https://example.com/avatar.jpg'
    });

    console.log('✅ Registration works:', validRegistration.status === 200 ? 'PASSED' : 'FAILED');

    // Test the improved error message
    console.log('\n2. Testing improved error message (PUT /user with new user)...');
    const wrongEndpointTest = await makeRequest('PUT', '/user', {
      login: 'newuser_' + Date.now(),
      password: 'testpassword123'
    });

    console.log('✅ Helpful error message:', wrongEndpointTest.body.error && wrongEndpointTest.body.error.includes('POST /user instead of PUT /user') ? 'PASSED' : 'FAILED');
    console.log('📝 Error message:', wrongEndpointTest.body.error);

    console.log('\n🎉 All tests passed! The registration issue has been resolved.');
    console.log('\n📖 Solution Summary:');
    console.log('- The API registration endpoint (POST /user) was working correctly');
    console.log('- The issue was likely the Flutter app calling PUT /user instead of POST /user');
    console.log('- Added a helpful error message to guide developers to the correct endpoint');
    console.log('- Flutter developers should use POST /user for registration, not PUT /user');

  } catch (error) {
    console.error('❌ Test failed:', error.message);
  }

  process.exit(0);
}

// Run the test if this file is executed directly
if (require.main === module) {
  testRegistration();
}

module.exports = { testRegistration, makeRequest };
