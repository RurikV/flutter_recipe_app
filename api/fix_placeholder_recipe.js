const { init } = require('./config/database');
const Recipe = require('./models/Recipe');

async function fixPlaceholderRecipe() {
  console.log('🔧 Fixing recipe with placeholder URL...\n');

  try {
    // Initialize database
    await init();
    console.log('✅ Database initialized');

    // Find the recipe with placeholder URL
    const recipe = await Recipe.findById(1);
    if (recipe && recipe.photo.includes('example.com')) {
      console.log(`Found recipe: "${recipe.name}" with placeholder URL`);
      console.log(`Current photo: ${recipe.photo}`);
      
      // Update with a valid placeholder image
      await recipe.update({
        name: recipe.name,
        duration: recipe.duration,
        photo: 'https://placehold.co/400x300/png?text=Test+Recipe'
      });
      
      console.log('✅ Recipe updated with valid placeholder image');
      console.log(`New photo: https://placehold.co/400x300/png?text=Test+Recipe`);
    } else {
      console.log('No recipe with placeholder URL found');
    }

    console.log('\n🎉 Fix completed!');

  } catch (error) {
    console.error('❌ Fix failed with error:', error.message);
    console.error('Stack trace:', error.stack);
  }

  process.exit(0);
}

// Run the fix
fixPlaceholderRecipe();