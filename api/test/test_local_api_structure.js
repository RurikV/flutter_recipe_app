const { init } = require('../config/database');
const Recipe = require('../models/Recipe');

async function testLocalApiResponse() {
  console.log('🔍 Testing actual local API response structure...\n');
  
  try {
    await init();
    console.log('✅ Database initialized');
    
    // Get all recipes
    const recipes = await Recipe.findAll({ count: 5 });
    console.log(`Found ${recipes.length} recipes\n`);
    
    if (recipes.length > 0) {
      const firstRecipe = recipes[0];
      console.log('=== BASIC RECIPE DATA ===');
      console.log('ID:', firstRecipe.id);
      console.log('Name:', firstRecipe.name);
      console.log('Duration:', firstRecipe.duration);
      console.log('Photo:', firstRecipe.photo);
      
      // Get detailed recipe data
      console.log('\n=== DETAILED RECIPE DATA ===');
      const detailedRecipe = await Recipe.findById(firstRecipe.id);
      
      if (detailedRecipe) {
        console.log('Recipe ID:', detailedRecipe.id);
        console.log('Recipe Name:', detailedRecipe.name);
        console.log('Recipe Duration:', detailedRecipe.duration);
        
        console.log('\n--- INGREDIENTS ---');
        console.log('Ingredients count:', detailedRecipe.recipeIngredients?.length || 0);
        if (detailedRecipe.recipeIngredients && detailedRecipe.recipeIngredients.length > 0) {
          detailedRecipe.recipeIngredients.forEach((ing, index) => {
            console.log(`Ingredient ${index + 1}:`, JSON.stringify(ing, null, 2));
          });
        } else {
          console.log('❌ No ingredients found!');
        }
        
        console.log('\n--- STEPS ---');
        console.log('Steps count:', detailedRecipe.recipeStepLinks?.length || 0);
        if (detailedRecipe.recipeStepLinks && detailedRecipe.recipeStepLinks.length > 0) {
          detailedRecipe.recipeStepLinks.forEach((step, index) => {
            console.log(`Step ${index + 1}:`, JSON.stringify(step, null, 2));
          });
        } else {
          console.log('❌ No steps found!');
        }
        
        console.log('\n--- FULL JSON STRUCTURE ---');
        console.log(JSON.stringify(detailedRecipe.toJSON(), null, 2));
        
      } else {
        console.log('❌ Could not get detailed recipe data');
      }
    } else {
      console.log('❌ No recipes found in database');
    }
    
  } catch (error) {
    console.error('❌ Error:', error.message);
    console.error('Stack:', error.stack);
  }
  
  process.exit(0);
}

testLocalApiResponse();