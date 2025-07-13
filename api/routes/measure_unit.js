const express = require('express');
const { body, validationResult } = require('express-validator');
const { MeasureUnit } = require('../models');
const router = express.Router();

const validateMeasureUnit = [
  body('one').notEmpty().withMessage('One form is required'),
  body('few').notEmpty().withMessage('Few form is required'),
  body('many').notEmpty().withMessage('Many form is required'),
];

router.post('/', validateMeasureUnit, async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ error: errors.array()[0].msg });
    }

    const measureUnit = await MeasureUnit.create(req.body);
    res.json(measureUnit);
  } catch (error) {
    console.error('Error creating measure unit:', error);
    if (error.code === 'SQLITE_CONSTRAINT') {
      res.status(409).json({ error: 'Measure unit already exists' });
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

    const measureUnits = await MeasureUnit.findAll(options);
    res.json(measureUnits);
  } catch (error) {
    console.error('Error getting measure units:', error);
    res.status(400).json({ error: 'Invalid request parameters' });
  }
});

router.get('/:id', async (req, res) => {
  try {
    const measureUnit = await MeasureUnit.findById(req.params.id);
    if (!measureUnit) {
      return res.status(404).json({ error: 'Measure unit not found' });
    }
    res.json(measureUnit);
  } catch (error) {
    console.error('Error getting measure unit:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

router.put('/:id', validateMeasureUnit, async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ error: errors.array()[0].msg });
    }

    const existing = await MeasureUnit.findById(req.params.id);
    if (!existing) {
      return res.status(404).json({ error: 'Measure unit not found' });
    }

    const updated = await MeasureUnit.update(req.params.id, req.body);
    res.json(updated);
  } catch (error) {
    console.error('Error updating measure unit:', error);
    if (error.code === 'SQLITE_CONSTRAINT') {
      res.status(409).json({ error: 'Measure unit already exists' });
    } else {
      res.status(500).json({ error: 'Internal server error' });
    }
  }
});

router.delete('/:id', async (req, res) => {
  try {
    const existing = await MeasureUnit.findById(req.params.id);
    if (!existing) {
      return res.status(404).json({ error: 'Measure unit not found' });
    }

    await MeasureUnit.delete(req.params.id);
    res.json({ message: 'Measure unit deleted successfully' });
  } catch (error) {
    console.error('Error deleting measure unit:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;