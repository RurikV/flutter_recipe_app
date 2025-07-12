const Recipe = require('./models/Recipe');
const { init } = require('./config/database');

async function debugAPIResponse() {
  console.log('🔍 Debugging API Response Structure...\n');
  
  try {
    await init();
    console.log('✅ Database initialized');
    
    // Test with recipe ID 3 (from the logs)
    const recipe = await Recipe.findById(3);
    
    if (recipe) {
      console.log('=== RAW API RESPONSE ===');
      console.log(JSON.stringify(recipe, null, 2));
      
      console.log('\n=== INGREDIENTS ANALYSIS ===');
      console.log('recipeIngredients exists:', !!recipe.recipeIngredients);
      console.log('recipeIngredients is array:', Array.isArray(recipe.recipeIngredients));
      console.log('recipeIngredients length:', recipe.recipeIngredients ? recipe.recipeIngredients.length : 0);
      
      console.log('\n=== STEPS ANALYSIS ===');
      console.log('recipeStepLinks exists:', !!recipe.recipeStepLinks);
      console.log('recipeStepLinks is array:', Array.isArray(recipe.recipeStepLinks));
      console.log('recipeStepLinks length:', recipe.recipeStepLinks ? recipe.recipeStepLinks.length : 0);
      
    } else {
      console.log('❌ Recipe not found');
    }
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  }
  
  process.exit(0);
}

debugAPIResponse();