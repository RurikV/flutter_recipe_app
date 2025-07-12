const { init } = require('../config/database');
const Recipe = require('../models/Recipe');

async function checkRecipeImages() {
  console.log('🔍 Checking all recipe images for placeholder URLs...\n');

  try {
    // Initialize database
    await init();
    console.log('✅ Database initialized');

    // Get all recipes
    const allRecipes = await Recipe.findAll({ count: 100 });
    console.log(`Found ${allRecipes.length} recipes in database\n`);

    for (const recipe of allRecipes) {
      console.log(`Recipe ID: ${recipe.id}, Name: "${recipe.name}"`);
      console.log(`Photo: ${recipe.photo}`);

      // Check if photo contains example.com or other placeholder URLs
      if (recipe.photo && recipe.photo.includes('example.com')) {
        console.log('⚠️  WARNING: Contains placeholder URL!');
      }

      // Check if photo is a valid URL
      if (recipe.photo && (recipe.photo.startsWith('http://') || recipe.photo.startsWith('https://'))) {
        console.log('🌐 Network URL detected');
      } else if (recipe.photo && recipe.photo.startsWith('[')) {
        console.log('📱 Local image data detected');
      } else if (recipe.photo) {
        console.log('❓ Unknown photo format');
      } else {
        console.log('📷 No photo');
      }

      console.log('---');
    }

    console.log('\n🎉 Recipe image check completed!');

  } catch (error) {
    console.error('❌ Check failed with error:', error.message);
    console.error('Stack trace:', error.stack);
  }

  process.exit(0);
}

// Run the check
checkRecipeImages();
