const express = require('express');
const { body, validationResult } = require('express-validator');
const { Ingredient } = require('../models');
const router = express.Router();

// Validation middleware
const validateIngredient = [
  body('name').notEmpty().withMessage('Name is required'),
  body('caloriesForUnit').isFloat({ min: 0 }).withMessage('Calories must be a positive number'),
  body('measureUnit.id').isInt({ min: 1 }).withMessage('Valid measure unit ID is required'),
];

// POST /ingredient - Create new ingredient
router.post('/', validateIngredient, async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ error: errors.array()[0].msg });
    }

    const { name, caloriesForUnit, measureUnit } = req.body;
    const data = {
      name,
      caloriesForUnit,
      measureUnit_id: measureUnit.id
    };

    const ingredient = await Ingredient.create(data);
    res.json(ingredient);
  } catch (error) {
    console.error('Error creating ingredient:', error);
    if (error.code === 'SQLITE_CONSTRAINT') {
      res.status(409).json({ error: 'Ingredient already exists' });
    } else {
      res.status(500).json({ error: 'Internal server error' });
    }
  }
});

// GET /ingredient - Get all ingredients
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

    const ingredients = await Ingredient.findAll(options);
    res.json(ingredients);
  } catch (error) {
    console.error('Error getting ingredients:', error);
    res.status(400).json({ error: 'Invalid request parameters' });
  }
});

// GET /ingredient/:id - Get single ingredient
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    const ingredient = await Ingredient.findById(id);
    if (!ingredient) {
      return res.status(404).json({ error: 'Ingredient not found' });
    }

    res.json(ingredient);
  } catch (error) {
    console.error('Error getting ingredient:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// PUT /ingredient/:id - Update ingredient
router.put('/:id', validateIngredient, async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ error: errors.array()[0].msg });
    }

    const { id } = req.params;
    const { name, caloriesForUnit, measureUnit } = req.body;

    const existing = await Ingredient.findById(id);
    if (!existing) {
      return res.status(404).json({ error: 'Ingredient not found' });
    }

    const data = {
      name,
      caloriesForUnit,
      measureUnit_id: measureUnit.id
    };

    const updated = await Ingredient.update(id, data);
    res.json(updated);
  } catch (error) {
    console.error('Error updating ingredient:', error);
    if (error.code === 'SQLITE_CONSTRAINT') {
      res.status(409).json({ error: 'Ingredient already exists' });
    } else {
      res.status(500).json({ error: 'Internal server error' });
    }
  }
});

// DELETE /ingredient/:id - Delete ingredient
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    const existing = await Ingredient.findById(id);
    if (!existing) {
      return res.status(404).json({ error: 'Ingredient not found' });
    }

    await Ingredient.delete(id);
    res.json({ message: 'Ingredient deleted successfully' });
  } catch (error) {
    console.error('Error deleting ingredient:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;