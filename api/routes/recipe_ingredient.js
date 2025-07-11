const express = require('express');
const { body, validationResult } = require('express-validator');
const { RecipeIngredient } = require('../models');
const router = express.Router();

const validate = [
  body('count').isInt({ min: 1 }).withMessage('Count must be a positive integer'),
  body('ingredient.id').isInt({ min: 1 }).withMessage('Valid ingredient ID is required'),
  body('recipe.id').isInt({ min: 1 }).withMessage('Valid recipe ID is required'),
];

router.post('/', validate, async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ error: errors.array()[0].msg });
    }
    const { count, ingredient, recipe } = req.body;
    const data = { count, ingredient_id: ingredient.id, recipe_id: recipe.id };
    const item = await RecipeIngredient.create(data);
    res.json(item);
  } catch (error) {
    console.error('Error creating recipe ingredient:', error);
    if (error.code === 'SQLITE_CONSTRAINT') {
      res.status(409).json({ error: 'Recipe ingredient already exists' });
    } else {
      res.status(500).json({ error: 'Internal server error' });
    }
  }
});

router.get('/', async (req, res) => {
  try {
    const { count, offset, pageBy, pageAfter, pagePrior, sortBy } = req.query;
    const options = {
      count: count ? parseInt(count) : 50,
      offset: offset ? parseInt(offset) : 0,
      pageBy, pageAfter, pagePrior,
      sortBy: sortBy ? (Array.isArray(sortBy) ? sortBy : [sortBy]) : []
    };
    const items = await RecipeIngredient.findAll(options);
    res.json(items);
  } catch (error) {
    console.error('Error getting recipe ingredients:', error);
    res.status(400).json({ error: 'Invalid request parameters' });
  }
});

router.get('/:id', async (req, res) => {
  try {
    const item = await RecipeIngredient.findById(req.params.id);
    if (!item) {
      return res.status(404).json({ error: 'Recipe ingredient not found' });
    }
    res.json(item);
  } catch (error) {
    console.error('Error getting recipe ingredient:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

router.put('/:id', validate, async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ error: errors.array()[0].msg });
    }
    const existing = await RecipeIngredient.findById(req.params.id);
    if (!existing) {
      return res.status(404).json({ error: 'Recipe ingredient not found' });
    }
    const { count, ingredient, recipe } = req.body;
    const data = { count, ingredient_id: ingredient.id, recipe_id: recipe.id };
    const updated = await RecipeIngredient.update(req.params.id, data);
    res.json(updated);
  } catch (error) {
    console.error('Error updating recipe ingredient:', error);
    if (error.code === 'SQLITE_CONSTRAINT') {
      res.status(409).json({ error: 'Recipe ingredient already exists' });
    } else {
      res.status(500).json({ error: 'Internal server error' });
    }
  }
});

router.delete('/:id', async (req, res) => {
  try {
    const existing = await RecipeIngredient.findById(req.params.id);
    if (!existing) {
      return res.status(404).json({ error: 'Recipe ingredient not found' });
    }
    await RecipeIngredient.delete(req.params.id);
    res.json({ message: 'Recipe ingredient deleted successfully' });
  } catch (error) {
    console.error('Error deleting recipe ingredient:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;