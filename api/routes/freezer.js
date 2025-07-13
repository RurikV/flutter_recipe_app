const express = require('express');
const { body, validationResult } = require('express-validator');
const { Freezer } = require('../models');
const router = express.Router();

const validate = [
  body('count').isFloat({ min: 0 }).withMessage('Count must be a positive number'),
  body('user.id').isInt({ min: 1 }).withMessage('Valid user ID is required'),
  body('ingredient.id').isInt({ min: 1 }).withMessage('Valid ingredient ID is required'),
];

router.post('/', validate, async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ error: errors.array()[0].msg });
    }
    const { count, user, ingredient } = req.body;
    const data = { count, user_id: user.id, ingredient_id: ingredient.id };
    const item = await Freezer.create(data);
    res.json(item);
  } catch (error) {
    console.error('Error creating freezer item:', error);
    if (error.code === 'SQLITE_CONSTRAINT') {
      res.status(409).json({ error: 'Freezer item already exists' });
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
    const items = await Freezer.findAll(options);
    res.json(items);
  } catch (error) {
    console.error('Error getting freezer items:', error);
    res.status(400).json({ error: 'Invalid request parameters' });
  }
});

router.get('/:id', async (req, res) => {
  try {
    const item = await Freezer.findById(req.params.id);
    if (!item) {
      return res.status(404).json({ error: 'Freezer item not found' });
    }
    res.json(item);
  } catch (error) {
    console.error('Error getting freezer item:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

router.put('/:id', validate, async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ error: errors.array()[0].msg });
    }
    const existing = await Freezer.findById(req.params.id);
    if (!existing) {
      return res.status(404).json({ error: 'Freezer item not found' });
    }
    const { count, user, ingredient } = req.body;
    const data = { count, user_id: user.id, ingredient_id: ingredient.id };
    const updated = await Freezer.update(req.params.id, data);
    res.json(updated);
  } catch (error) {
    console.error('Error updating freezer item:', error);
    if (error.code === 'SQLITE_CONSTRAINT') {
      res.status(409).json({ error: 'Freezer item already exists' });
    } else {
      res.status(500).json({ error: 'Internal server error' });
    }
  }
});

router.delete('/:id', async (req, res) => {
  try {
    const existing = await Freezer.findById(req.params.id);
    if (!existing) {
      return res.status(404).json({ error: 'Freezer item not found' });
    }
    await Freezer.delete(req.params.id);
    res.json({ message: 'Freezer item deleted successfully' });
  } catch (error) {
    console.error('Error deleting freezer item:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;