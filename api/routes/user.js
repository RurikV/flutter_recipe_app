const express = require('express');
const { body, validationResult } = require('express-validator');
const { User } = require('../models');
const router = express.Router();

// Validation middleware
const validateUser = [
  body('login').notEmpty().withMessage('Login is required'),
  body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters long'),
];

// POST /user - Register new user
router.post('/', validateUser, async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ error: errors.array()[0].msg });
    }

    const { login, password, avatar } = req.body;

    // Check if user already exists
    const existingUser = await User.findByLogin(login);
    if (existingUser) {
      return res.status(409).json({ error: 'User already exists' });
    }

    // Create new user
    await User.create({ login, password, avatar });
    res.json({ status: 'User created successfully' });
  } catch (error) {
    console.error('Error creating user:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// PUT /user - Authenticate user (login)
router.put('/', validateUser, async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ error: errors.array()[0].msg });
    }

    const { login, password } = req.body;

    try {
      const user = await User.authenticate(login, password);
      res.json({ token: user.token });
    } catch (authError) {
      res.status(403).json({ 
        error: 'Invalid credentials. If you are trying to register a new user, use POST /user instead of PUT /user.' 
      });
    }
  } catch (error) {
    console.error('Error authenticating user:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /user/:id - Get user information
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const user = await User.findById(id);
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json(user.toPublicJSON());
  } catch (error) {
    console.error('Error getting user:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
