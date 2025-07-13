const express = require('express');
const { body, validationResult } = require('express-validator');
const { RecipeStepLink } = require('../models');
const router = express.Router();

const validate = [
  body('number').isInt({ min: 1 }).withMessage('Number must be a positive integer'),
  body('recipe.id').isInt({ min: 1 }).withMessage('Valid recipe ID is required'),
  body('step.id').isInt({ min: 1 }).withMessage('Valid step ID is required'),
];

router.post('/', validate, async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ error: errors.array()[0].msg });
    }
    const { number, recipe, step } = req.body;
    const data = { number, recipe_id: recipe.id, step_id: step.id };
    const item = await RecipeStepLink.create(data);
    res.json(item);
  } catch (error) {
    console.error('Error creating recipe step link:', error);
    if (error.code === 'SQLITE_CONSTRAINT') {
      res.status(409).json({ error: 'Recipe step link already exists' });
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
    const items = await RecipeStepLink.findAll(options);
    res.json(items);
  } catch (error) {
    console.error('Error getting recipe step links:', error);
    res.status(400).json({ error: 'Invalid request parameters' });
  }
});

router.get('/:id', async (req, res) => {
  try {
    const item = await RecipeStepLink.findById(req.params.id);
    if (!item) {
      return res.status(404).json({ error: 'Recipe step link not found' });
    }
    res.json(item);
  } catch (error) {
    console.error('Error getting recipe step link:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

router.put('/:id', validate, async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ error: errors.array()[0].msg });
    }
    const existing = await RecipeStepLink.findById(req.params.id);
    if (!existing) {
      return res.status(404).json({ error: 'Recipe step link not found' });
    }
    const { number, recipe, step } = req.body;
    const data = { number, recipe_id: recipe.id, step_id: step.id };
    const updated = await RecipeStepLink.update(req.params.id, data);
    res.json(updated);
  } catch (error) {
    console.error('Error updating recipe step link:', error);
    if (error.code === 'SQLITE_CONSTRAINT') {
      res.status(409).json({ error: 'Recipe step link already exists' });
    } else {
      res.status(500).json({ error: 'Internal server error' });
    }
  }
});

router.delete('/:id', async (req, res) => {
  try {
    const existing = await RecipeStepLink.findById(req.params.id);
    if (!existing) {
      return res.status(404).json({ error: 'Recipe step link not found' });
    }
    await RecipeStepLink.delete(req.params.id);
    res.json({ message: 'Recipe step link deleted successfully' });
  } catch (error) {
    console.error('Error deleting recipe step link:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;