const express = require('express');
const { body, validationResult } = require('express-validator');
const { Comment } = require('../models');
const router = express.Router();

const validate = [
  body('text').notEmpty().withMessage('Text is required'),
  body('user.id').isInt({ min: 1 }).withMessage('Valid user ID is required'),
  body('recipe.id').isInt({ min: 1 }).withMessage('Valid recipe ID is required'),
];

router.post('/', validate, async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ error: errors.array()[0].msg });
    }
    const { text, photo = '', user, recipe } = req.body;
    const data = { text, photo, user_id: user.id, recipe_id: recipe.id };
    const item = await Comment.create(data);
    res.json(item);
  } catch (error) {
    console.error('Error creating comment:', error);
    if (error.code === 'SQLITE_CONSTRAINT') {
      res.status(409).json({ error: 'Comment already exists' });
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
    const items = await Comment.findAll(options);
    res.json(items);
  } catch (error) {
    console.error('Error getting comments:', error);
    res.status(400).json({ error: 'Invalid request parameters' });
  }
});

router.get('/:id', async (req, res) => {
  try {
    const item = await Comment.findById(req.params.id);
    if (!item) {
      return res.status(404).json({ error: 'Comment not found' });
    }
    res.json(item);
  } catch (error) {
    console.error('Error getting comment:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

router.put('/:id', validate, async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ error: errors.array()[0].msg });
    }
    const existing = await Comment.findById(req.params.id);
    if (!existing) {
      return res.status(404).json({ error: 'Comment not found' });
    }
    const { text, photo = '', user, recipe } = req.body;
    const data = { text, photo, user_id: user.id, recipe_id: recipe.id };
    const updated = await Comment.update(req.params.id, data);
    res.json(updated);
  } catch (error) {
    console.error('Error updating comment:', error);
    if (error.code === 'SQLITE_CONSTRAINT') {
      res.status(409).json({ error: 'Comment already exists' });
    } else {
      res.status(500).json({ error: 'Internal server error' });
    }
  }
});

router.delete('/:id', async (req, res) => {
  try {
    const existing = await Comment.findById(req.params.id);
    if (!existing) {
      return res.status(404).json({ error: 'Comment not found' });
    }
    await Comment.delete(req.params.id);
    res.json({ message: 'Comment deleted successfully' });
  } catch (error) {
    console.error('Error deleting comment:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;