const express = require('express');
const { body, validationResult } = require('express-validator');
const { Favorite } = require('../models');
const router = express.Router();

const validate = [
  body('recipe.id').isInt({ min: 1 }).withMessage('Valid recipe ID is required'),
  body('user.id').isInt({ min: 1 }).withMessage('Valid user ID is required'),
];

router.post('/', validate, async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ error: errors.array()[0].msg });
    }
    const { recipe, user } = req.body;
    const data = { recipe_id: recipe.id, user_id: user.id };
    const item = await Favorite.create(data);
    res.json(item);
  } catch (error) {
    console.error('Error creating favorite:', error);
    if (error.code === 'SQLITE_CONSTRAINT') {
      res.status(409).json({ error: 'Favorite already exists' });
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
    const items = await Favorite.findAll(options);
    res.json(items);
  } catch (error) {
    console.error('Error getting favorites:', error);
    res.status(400).json({ error: 'Invalid request parameters' });
  }
});

router.get('/:id', async (req, res) => {
  try {
    const item = await Favorite.findById(req.params.id);
    if (!item) {
      return res.status(404).json({ error: 'Favorite not found' });
    }
    res.json(item);
  } catch (error) {
    console.error('Error getting favorite:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

router.put('/:id', validate, async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ error: errors.array()[0].msg });
    }
    const existing = await Favorite.findById(req.params.id);
    if (!existing) {
      return res.status(404).json({ error: 'Favorite not found' });
    }
    const { recipe, user } = req.body;
    const data = { recipe_id: recipe.id, user_id: user.id };
    const updated = await Favorite.update(req.params.id, data);
    res.json(updated);
  } catch (error) {
    console.error('Error updating favorite:', error);
    if (error.code === 'SQLITE_CONSTRAINT') {
      res.status(409).json({ error: 'Favorite already exists' });
    } else {
      res.status(500).json({ error: 'Internal server error' });
    }
  }
});

router.delete('/:id', async (req, res) => {
  try {
    const existing = await Favorite.findById(req.params.id);
    if (!existing) {
      return res.status(404).json({ error: 'Favorite not found' });
    }
    await Favorite.delete(req.params.id);
    res.json({ message: 'Favorite deleted successfully' });
  } catch (error) {
    console.error('Error deleting favorite:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;