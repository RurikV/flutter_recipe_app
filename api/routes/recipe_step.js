const express = require('express');
const { body, validationResult } = require('express-validator');
const { RecipeStep } = require('../models');
const router = express.Router();

const validate = [
  body('name').notEmpty().withMessage('Name is required'),
  body('duration').isInt({ min: 0 }).withMessage('Duration must be a positive integer'),
];

router.post('/', validate, async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ error: errors.array()[0].msg });
    }
    const item = await RecipeStep.create(req.body);
    res.json(item);
  } catch (error) {
    console.error('Error creating recipe step:', error);
    if (error.code === 'SQLITE_CONSTRAINT') {
      res.status(409).json({ error: 'Recipe step already exists' });
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
    const items = await RecipeStep.findAll(options);
    res.json(items);
  } catch (error) {
    console.error('Error getting recipe steps:', error);
    res.status(400).json({ error: 'Invalid request parameters' });
  }
});

router.get('/:id', async (req, res) => {
  try {
    const item = await RecipeStep.findById(req.params.id);
    if (!item) {
      return res.status(404).json({ error: 'Recipe step not found' });
    }
    res.json(item);
  } catch (error) {
    console.error('Error getting recipe step:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

router.put('/:id', validate, async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ error: errors.array()[0].msg });
    }
    const existing = await RecipeStep.findById(req.params.id);
    if (!existing) {
      return res.status(404).json({ error: 'Recipe step not found' });
    }
    const updated = await RecipeStep.update(req.params.id, req.body);
    res.json(updated);
  } catch (error) {
    console.error('Error updating recipe step:', error);
    if (error.code === 'SQLITE_CONSTRAINT') {
      res.status(409).json({ error: 'Recipe step already exists' });
    } else {
      res.status(500).json({ error: 'Internal server error' });
    }
  }
});

router.delete('/:id', async (req, res) => {
  try {
    const existing = await RecipeStep.findById(req.params.id);
    if (!existing) {
      return res.status(404).json({ error: 'Recipe step not found' });
    }
    await RecipeStep.delete(req.params.id);
    res.json({ message: 'Recipe step deleted successfully' });
  } catch (error) {
    console.error('Error deleting recipe step:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;