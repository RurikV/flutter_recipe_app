const http = require('http');

// Test CORS preflight request specifically
async function testCORSPreflight() {
  console.log('🔍 Testing CORS preflight request for Flutter web...\n');

  try {
    // Test OPTIONS request (preflight)
    console.log('1. Testing OPTIONS preflight request...');
    const optionsResponse = await makeRequest('OPTIONS', '/recipe/1', null, {
      'Origin': 'http://localhost:8080',
      'Access-Control-Request-Method': 'GET',
      'Access-Control-Request-Headers': 'Content-Type, Authorization'
    });

    console.log('OPTIONS Response Status:', optionsResponse.status);
    console.log('CORS Headers in OPTIONS response:');
    console.log('- Access-Control-Allow-Origin:', optionsResponse.headers['access-control-allow-origin'] || 'NOT SET');
    console.log('- Access-Control-Allow-Methods:', optionsResponse.headers['access-control-allow-methods'] || 'NOT SET');
    console.log('- Access-Control-Allow-Headers:', optionsResponse.headers['access-control-allow-headers'] || 'NOT SET');

    // Test actual GET request with CORS headers
    console.log('\n2. Testing GET request with CORS headers...');
    const getResponse = await makeRequest('GET', '/recipe/3', null, {
      'Origin': 'http://localhost:8080',
      'Content-Type': 'application/json'
    });

    console.log('GET Response Status:', getResponse.status);
    console.log('CORS Headers in GET response:');
    console.log('- Access-Control-Allow-Origin:', getResponse.headers['access-control-allow-origin'] || 'NOT SET');

    // Test recipe endpoint specifically for ingredients and steps
    console.log('\n3. Testing recipe data structure...');
    if (getResponse.status === 200 && getResponse.body) {
      console.log('Recipe data keys:', Object.keys(getResponse.body));
      console.log('Has recipeIngredients:', !!getResponse.body.recipeIngredients);
      console.log('Has recipeStepLinks:', !!getResponse.body.recipeStepLinks);

      if (getResponse.body.recipeIngredients) {
        console.log('Ingredients count:', getResponse.body.recipeIngredients.length);
      }

      if (getResponse.body.recipeStepLinks) {
        console.log('Steps count:', getResponse.body.recipeStepLinks.length);
      }
    }

    console.log('\n✅ CORS preflight test completed!');

  } catch (error) {
    console.log('❌ CORS test failed:', error.message);
  }
}

async function makeRequest(method, path, data, headers = {}) {
  return new Promise((resolve, reject) => {
    const postData = data ? JSON.stringify(data) : '';

    const options = {
      hostname: 'localhost',
      port: 3000,
      path: path,
      method: method,
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(postData),
        ...headers
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

// Run the CORS test
testCORSPreflight();
