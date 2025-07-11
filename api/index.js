const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const path = require('path');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(helmet());
app.use(cors());
app.use(morgan('combined'));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Database initialization
const db = require('./config/database');

// Initialize database
db.init().then(() => {
  console.log('Database initialized successfully');
}).catch(err => {
  console.error('Database initialization failed:', err);
});

// Routes
app.use('/recipe', require('./routes/recipe'));
app.use('/recipe_step', require('./routes/recipe_step'));
app.use('/recipe_step_link', require('./routes/recipe_step_link'));
app.use('/comment', require('./routes/comment'));
app.use('/ingredient', require('./routes/ingredient'));
app.use('/recipe_ingredient', require('./routes/recipe_ingredient'));
app.use('/measure_unit', require('./routes/measure_unit'));
app.use('/freezer', require('./routes/freezer'));
app.use('/favorite', require('./routes/favorite'));
app.use('/user', require('./routes/user'));

// Swagger documentation
const swaggerUi = require('swagger-ui-express');
const YAML = require('yamljs');
const swaggerDocument = YAML.load(path.join(__dirname, 'swagger.yaml'));

app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDocument));

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    version: '0.2.0'
  });
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'Food API Server',
    version: '0.2.0',
    documentation: '/api-docs',
    health: '/health'
  });
});

// Error handling middleware
app.use((err, req, res, _next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Endpoint not found' });
});

// Start server
app.listen(PORT, () => {
  console.log(`Food API Server running on port ${PORT}`);
  console.log(`Documentation available at http://localhost:${PORT}/api-docs`);
});

module.exports = app;
