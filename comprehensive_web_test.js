const http = require('http');

// Comprehensive test to simulate the entire Flutter web app flow
async function testCompleteWebFlow() {
  console.log('🔍 Testing Complete Web Flow...\n');
  
  try {
    // Step 1: Test API server health
    console.log('1. Testing API server health...');
    const healthResponse = await makeRequest('GET', '/health');
    console.log(`✅ API Health: ${healthResponse.status === 200 ? 'OK' : 'FAILED'}`);
    
    // Step 2: Test CORS preflight
    console.log('\n2. Testing CORS preflight (simulating browser)...');
    const corsResponse = await makeRequest('OPTIONS', '/recipe/3', null, {
      'Origin': 'http://localhost:8080',
      'Access-Control-Request-Method': 'GET',
      'Access-Control-Request-Headers': 'Content-Type'
    });
    console.log(`✅ CORS Preflight: ${corsResponse.status === 200 ? 'OK' : 'FAILED'}`);
    
    // Step 3: Test actual recipe endpoint
    console.log('\n3. Testing recipe endpoint...');
    const recipeResponse = await makeRequest('GET', '/recipe/3', null, {
      'Origin': 'http://localhost:8080'
    });
    
    if (recipeResponse.status === 200) {
      console.log('✅ Recipe endpoint: OK');
      console.log(`Recipe name: ${recipeResponse.body.name}`);
      console.log(`Has ingredients: ${!!recipeResponse.body.recipeIngredients}`);
      console.log(`Has steps: ${!!recipeResponse.body.recipeStepLinks}`);
      
      if (recipeResponse.body.recipeIngredients) {
        console.log(`Ingredients count: ${recipeResponse.body.recipeIngredients.length}`);
        
        // Test ingredient structure
        if (recipeResponse.body.recipeIngredients.length > 0) {
          const firstIngredient = recipeResponse.body.recipeIngredients[0];
          console.log('First ingredient structure:', JSON.stringify(firstIngredient, null, 2));
        }
      }
      
      if (recipeResponse.body.recipeStepLinks) {
        console.log(`Steps count: ${recipeResponse.body.recipeStepLinks.length}`);
        
        // Test step structure
        if (recipeResponse.body.recipeStepLinks.length > 0) {
          const firstStep = recipeResponse.body.recipeStepLinks[0];
          console.log('First step structure:', JSON.stringify(firstStep, null, 2));
        }
      }
      
      // Step 4: Simulate Flutter web app parsing
      console.log('\n4. Simulating Flutter Recipe.fromJson parsing...');
      const simulatedRecipe = simulateFlutterParsing(recipeResponse.body);
      console.log(`✅ Simulated parsing complete`);
      console.log(`Parsed ingredients: ${simulatedRecipe.ingredients.length}`);
      console.log(`Parsed steps: ${simulatedRecipe.steps.length}`);
      
      if (simulatedRecipe.ingredients.length === 0) {
        console.log('❌ ISSUE FOUND: Ingredients parsing resulted in empty array!');
      }
      
      if (simulatedRecipe.steps.length === 0) {
        console.log('❌ ISSUE FOUND: Steps parsing resulted in empty array!');
      }
      
    } else {
      console.log(`❌ Recipe endpoint failed: ${recipeResponse.status}`);
    }
    
    console.log('\n🎉 Complete web flow test finished!');
    
  } catch (error) {
    console.log(`❌ Web flow test failed: ${error.message}`);
  }
}

// Simulate Flutter Recipe.fromJson parsing logic
function simulateFlutterParsing(apiData) {
  const ingredients = [];
  const steps = [];
  
  // Simulate ingredient parsing
  if (apiData.recipeIngredients && Array.isArray(apiData.recipeIngredients)) {
    for (const item of apiData.recipeIngredients) {
      if (item.ingredient && item.count) {
        const ingredient = {
          name: item.ingredient.name || '',
          quantity: item.count.toString(),
          unit: getUnitForm(item.ingredient.measureUnit, item.count)
        };
        ingredients.push(ingredient);
      }
    }
  }
  
  // Simulate step parsing
  if (apiData.recipeStepLinks && Array.isArray(apiData.recipeStepLinks)) {
    for (const item of apiData.recipeStepLinks) {
      if (item.step) {
        const step = {
          name: item.step.name || '',
          duration: item.step.duration || 0
        };
        steps.push(step);
      }
    }
  }
  
  return { ingredients, steps };
}

// Simulate Flutter unit form selection logic
function getUnitForm(measureUnit, count) {
  if (!measureUnit) return '';
  
  const countNum = parseInt(count) || 0;
  
  if (countNum === 1) {
    return measureUnit.one || '';
  } else if (countNum >= 2 && countNum <= 4) {
    return measureUnit.few || '';
  } else {
    return measureUnit.many || '';
  }
}

// HTTP request helper
async function makeRequest(method, path, data = null, headers = {}) {
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

// Run the comprehensive test
testCompleteWebFlow();