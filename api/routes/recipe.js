const express = require('express');
const { body, validationResult } = require('express-validator');
const { Recipe } = require('../models');
const router = express.Router();

// Validation middleware
const validateRecipe = [
  body('name').notEmpty().withMessage('Name is required'),
  body('duration').isInt({ min: 0 }).withMessage('Duration must be a positive integer'),
];

// POST /recipe - Create new recipe
router.post('/', validateRecipe, async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ error: errors.array()[0].msg });
    }

    const { name, duration, photo } = req.body;

    // Check if recipe already exists
    const exists = await Recipe.existsByName(name);
    if (exists) {
      return res.status(409).json({ error: 'Recipe with this name already exists' });
    }

    // Create new recipe
    const recipe = await Recipe.create({ name, duration, photo });
    res.json(recipe.toJSON());
  } catch (error) {
    console.error('Error creating recipe:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /recipe - Get all recipes with pagination
router.get('/', async (req, res) => {
  try {
    const { count, offset, pageBy, pageAfter, pagePrior, sortBy } = req.query;
    
    const options = {
      count: count ? parseInt(count) : 50,
      offset: offset ? parseInt(offset) : 0,
      pageBy,
      pageAfter,
      pagePrior,
      sortBy: sortBy ? (Array.isArray(sortBy) ? sortBy : [sortBy]) : []
    };

    const recipes = await Recipe.findAll(options);
    res.json(recipes.map(recipe => recipe.toJSON()));
  } catch (error) {
    console.error('Error getting recipes:', error);
    res.status(400).json({ error: 'Invalid request parameters' });
  }
});

// GET /recipe/:id - Get single recipe
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    const recipe = await Recipe.findById(id);
    if (!recipe) {
      return res.status(404).json({ error: 'Recipe not found' });
    }

    res.json(recipe.toJSON());
  } catch (error) {
    console.error('Error getting recipe:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// PUT /recipe/:id - Update recipe
router.put('/:id', validateRecipe, async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ error: errors.array()[0].msg });
    }

    const { id } = req.params;
    const { name, duration, photo } = req.body;

    // Check if recipe exists
    const recipe = await Recipe.findById(id);
    if (!recipe) {
      return res.status(404).json({ error: 'Recipe not found' });
    }

    // Check if name conflicts with another recipe
    const nameExists = await Recipe.existsByName(name, id);
    if (nameExists) {
      return res.status(409).json({ error: 'Recipe with this name already exists' });
    }

    // Update recipe
    const updatedRecipe = await recipe.update({ name, duration, photo });
    res.json(updatedRecipe.toJSON());
  } catch (error) {
    console.error('Error updating recipe:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// DELETE /recipe/:id - Delete recipe
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    const recipe = await Recipe.findById(id);
    if (!recipe) {
      return res.status(404).json({ error: 'Recipe not found' });
    }

    await recipe.delete();
    res.json({ message: 'Recipe deleted successfully' });
  } catch (error) {
    console.error('Error deleting recipe:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;