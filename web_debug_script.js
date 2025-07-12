// Web Debug Script for Flutter Recipe App
// Run this in browser console when the Flutter web app is running

console.log('🔍 Starting Web Debug Script for Flutter Recipe App...\n');

// Test 1: Check if API server is accessible from browser
async function testAPIConnectivity() {
  console.log('1. Testing API connectivity from browser...');
  
  try {
    const response = await fetch('http://localhost:3000/health');
    const data = await response.json();
    console.log('✅ API Health Check:', data);
    
    // Test CORS headers
    console.log('CORS Headers:');
    console.log('- Access-Control-Allow-Origin:', response.headers.get('Access-Control-Allow-Origin'));
    
  } catch (error) {
    console.log('❌ API connectivity failed:', error);
  }
}

// Test 2: Test recipe endpoint specifically
async function testRecipeEndpoint() {
  console.log('\n2. Testing recipe endpoint...');
  
  try {
    const response = await fetch('http://localhost:3000/recipe/3');
    const recipeData = await response.json();
    
    console.log('✅ Recipe data retrieved:');
    console.log('- Recipe name:', recipeData.name);
    console.log('- Has recipeIngredients:', !!recipeData.recipeIngredients);
    console.log('- Has recipeStepLinks:', !!recipeData.recipeStepLinks);
    
    if (recipeData.recipeIngredients) {
      console.log('- Ingredients count:', recipeData.recipeIngredients.length);
    }
    
    if (recipeData.recipeStepLinks) {
      console.log('- Steps count:', recipeData.recipeStepLinks.length);
    }
    
    return recipeData;
    
  } catch (error) {
    console.log('❌ Recipe endpoint failed:', error);
  }
}

// Test 3: Check browser network tab for any blocked requests
function checkNetworkRequests() {
  console.log('\n3. Network Request Analysis:');
  console.log('Please check the browser Network tab for:');
  console.log('- Any failed requests to localhost:3000');
  console.log('- CORS preflight OPTIONS requests');
  console.log('- Any 4xx or 5xx status codes');
  console.log('- Request/Response headers');
}

// Test 4: Check for Flutter web app errors
function checkFlutterErrors() {
  console.log('\n4. Flutter Web App Analysis:');
  console.log('Please check the browser Console for:');
  console.log('- Any [DEBUG_LOG] messages from Flutter app');
  console.log('- JavaScript errors or exceptions');
  console.log('- Network connection errors');
  console.log('- CORS-related error messages');
}

// Run all tests
async function runAllTests() {
  await testAPIConnectivity();
  await testRecipeEndpoint();
  checkNetworkRequests();
  checkFlutterErrors();
  
  console.log('\n🎉 Web debug script completed!');
  console.log('\nNext steps:');
  console.log('1. Run Flutter web app: flutter run -d chrome');
  console.log('2. Open browser developer tools');
  console.log('3. Navigate to a recipe detail page');
  console.log('4. Run this script in the browser console');
  console.log('5. Check Network tab for API requests');
}

// Auto-run the tests
runAllTests();