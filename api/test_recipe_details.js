const { init } = require('./config/database');
const Recipe = require('./models/Recipe');

async function testRecipeDetails() {
  console.log('🧪 Testing Recipe.findById with ingredients and steps...\n');

  try {
    // Initialize database
    console.log('1. Initializing database...');
    await init();
    console.log('✅ Database initialized');

    // First, let's see if there are any recipes in the database
    console.log('\n2. Checking for existing recipes...');
    const allRecipes = await Recipe.findAll({ count: 5 });
    console.log(`Found ${allRecipes.length} recipes in database`);

    if (allRecipes.length === 0) {
      console.log('⚠️  No recipes found in database. Creating test data...');

      // Create a test recipe with ingredients and steps
      const testRecipe = await Recipe.create({
        name: 'Test Recipe with Ingredients',
        duration: 30,
        photo: 'https://example.com/test.jpg'
      });

      console.log(`✅ Created test recipe with ID: ${testRecipe.id}`);

      // Note: In a real scenario, you would also need to create ingredients and steps
      // For now, let's test with an existing recipe if available
    }

    // Test findById with the first available recipe
    if (allRecipes.length > 0) {
      const recipeId = allRecipes[0].id;
      console.log(`\n3. Testing Recipe.findById(${recipeId})...`);

      const recipe = await Recipe.findById(recipeId);

      if (recipe) {
        console.log('✅ Recipe found!');
        console.log('Recipe details:');
        console.log(`- ID: ${recipe.id}`);
        console.log(`- Name: ${recipe.name}`);
        console.log(`- Duration: ${recipe.duration}`);
        console.log(`- Photo: ${recipe.photo}`);

        console.log('\nIngredients data structure:');
        console.log('- recipeIngredients:', JSON.stringify(recipe.recipeIngredients, null, 2));

        console.log('\nSteps data structure:');
        console.log('- recipeStepLinks:', JSON.stringify(recipe.recipeStepLinks, null, 2));

        console.log('\nComments data structure:');
        console.log('- comments:', JSON.stringify(recipe.comments, null, 2));

        // Check if the data structure matches what Flutter expects
        if (recipe.recipeIngredients && Array.isArray(recipe.recipeIngredients)) {
          console.log(`\n✅ Ingredients: Found ${recipe.recipeIngredients.length} ingredients`);
          if (recipe.recipeIngredients.length > 0) {
            const firstIngredient = recipe.recipeIngredients[0];
            console.log('First ingredient structure:', JSON.stringify(firstIngredient, null, 2));
          }
        } else {
          console.log('\n⚠️  Ingredients: No ingredients found or wrong structure');
        }

        if (recipe.recipeStepLinks && Array.isArray(recipe.recipeStepLinks)) {
          console.log(`\n✅ Steps: Found ${recipe.recipeStepLinks.length} steps`);
          if (recipe.recipeStepLinks.length > 0) {
            const firstStep = recipe.recipeStepLinks[0];
            console.log('First step structure:', JSON.stringify(firstStep, null, 2));
          }
        } else {
          console.log('\n⚠️  Steps: No steps found or wrong structure');
        }

      } else {
        console.log('❌ Recipe not found');
      }
    }

    console.log('\n🎉 Recipe details test completed!');

  } catch (error) {
    console.error('❌ Test failed with error:', error.message);
    console.error('Stack trace:', error.stack);
  }

  process.exit(0);
}

// Run the test
testRecipeDetails();
