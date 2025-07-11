const sqlite3 = require('sqlite3').verbose();
const path = require('path');

// Database file path
const DB_PATH = process.env.DB_PATH || path.join(__dirname, '../data/foodapi.db');

let db = null;

// Initialize database connection
const init = () => {
  return new Promise((resolve, reject) => {
    // Create data directory if it doesn't exist
    const fs = require('fs');
    const dataDir = path.dirname(DB_PATH);
    if (!fs.existsSync(dataDir)) {
      fs.mkdirSync(dataDir, { recursive: true });
    }

    db = new sqlite3.Database(DB_PATH, (err) => {
      if (err) {
        console.error('Error opening database:', err);
        reject(err);
      } else {
        console.log('Connected to SQLite database');
        createTables().then(resolve).catch(reject);
      }
    });
  });
};

// Create all necessary tables
const createTables = () => {
  return new Promise((resolve, reject) => {
    const tables = [
      // Users table
      `CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        login TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        token TEXT,
        avatar TEXT DEFAULT '',
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )`,

      // MeasureUnit table
      `CREATE TABLE IF NOT EXISTS measure_units (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        one TEXT NOT NULL,
        few TEXT NOT NULL,
        many TEXT NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )`,

      // Ingredients table
      `CREATE TABLE IF NOT EXISTS ingredients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        caloriesForUnit REAL NOT NULL DEFAULT 0,
        measureUnit_id INTEGER,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (measureUnit_id) REFERENCES measure_units(id)
      )`,

      // Recipes table
      `CREATE TABLE IF NOT EXISTS recipes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        duration INTEGER NOT NULL DEFAULT 0,
        photo TEXT DEFAULT '',
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )`,

      // RecipeSteps table
      `CREATE TABLE IF NOT EXISTS recipe_steps (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        duration INTEGER NOT NULL DEFAULT 0,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )`,

      // RecipeStepLinks table
      `CREATE TABLE IF NOT EXISTS recipe_step_links (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        number INTEGER NOT NULL,
        recipe_id INTEGER NOT NULL,
        step_id INTEGER NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE,
        FOREIGN KEY (step_id) REFERENCES recipe_steps(id) ON DELETE CASCADE
      )`,

      // RecipeIngredients table
      `CREATE TABLE IF NOT EXISTS recipe_ingredients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        count INTEGER NOT NULL,
        ingredient_id INTEGER NOT NULL,
        recipe_id INTEGER NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (ingredient_id) REFERENCES ingredients(id) ON DELETE CASCADE,
        FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE
      )`,

      // Comments table
      `CREATE TABLE IF NOT EXISTS comments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        text TEXT NOT NULL,
        photo TEXT DEFAULT '',
        datetime DATETIME DEFAULT CURRENT_TIMESTAMP,
        user_id INTEGER NOT NULL,
        recipe_id INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE
      )`,

      // Freezer table
      `CREATE TABLE IF NOT EXISTS freezer (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        count REAL NOT NULL,
        user_id INTEGER NOT NULL,
        ingredient_id INTEGER NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (ingredient_id) REFERENCES ingredients(id) ON DELETE CASCADE
      )`,

      // Favorites table
      `CREATE TABLE IF NOT EXISTS favorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        recipe_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        UNIQUE(recipe_id, user_id)
      )`
    ];

    let completed = 0;
    const total = tables.length;

    tables.forEach((sql, index) => {
      db.run(sql, (err) => {
        if (err) {
          console.error(`Error creating table ${index}:`, err);
          reject(err);
        } else {
          completed++;
          if (completed === total) {
            console.log('All tables created successfully');
            insertDefaultData().then(resolve).catch(reject);
          }
        }
      });
    });
  });
};

// Insert default data
const insertDefaultData = () => {
  return new Promise((resolve, reject) => {
    // Insert default measure units
    const defaultMeasureUnits = [
      { one: 'gram', few: 'grams', many: 'grams' },
      { one: 'kilogram', few: 'kilograms', many: 'kilograms' },
      { one: 'liter', few: 'liters', many: 'liters' },
      { one: 'milliliter', few: 'milliliters', many: 'milliliters' },
      { one: 'piece', few: 'pieces', many: 'pieces' },
      { one: 'cup', few: 'cups', many: 'cups' },
      { one: 'tablespoon', few: 'tablespoons', many: 'tablespoons' },
      { one: 'teaspoon', few: 'teaspoons', many: 'teaspoons' }
    ];

    // Check if measure units already exist
    db.get('SELECT COUNT(*) as count FROM measure_units', (err, row) => {
      if (err) {
        reject(err);
        return;
      }

      if (row.count === 0) {
        const stmt = db.prepare('INSERT INTO measure_units (one, few, many) VALUES (?, ?, ?)');
        defaultMeasureUnits.forEach(unit => {
          stmt.run(unit.one, unit.few, unit.many);
        });
        stmt.finalize((err) => {
          if (err) {
            reject(err);
          } else {
            console.log('Default measure units inserted');
            resolve();
          }
        });
      } else {
        resolve();
      }
    });
  });
};

// Get database instance
const getDb = () => {
  if (!db) {
    throw new Error('Database not initialized. Call init() first.');
  }
  return db;
};

// Close database connection
const close = () => {
  return new Promise((resolve, reject) => {
    if (db) {
      db.close((err) => {
        if (err) {
          reject(err);
        } else {
          console.log('Database connection closed');
          resolve();
        }
      });
    } else {
      resolve();
    }
  });
};

module.exports = {
  init,
  getDb,
  close
};