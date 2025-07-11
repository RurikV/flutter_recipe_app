const { getDb } = require('../config/database');

class Recipe {
  constructor(data) {
    this.id = data.id;
    this.name = data.name;
    this.duration = data.duration;
    this.photo = data.photo || '';
    this.recipeIngredients = data.recipeIngredients || [];
    this.recipeStepLinks = data.recipeStepLinks || [];
    this.favoriteRecipes = data.favoriteRecipes || [];
    this.comments = data.comments || [];
  }

  // Create a new recipe
  static async create(recipeData) {
    const db = getDb();
    const { name, duration, photo = '' } = recipeData;

    return new Promise((resolve, reject) => {
      const sql = 'INSERT INTO recipes (name, duration, photo) VALUES (?, ?, ?)';
      db.run(sql, [name, duration, photo], function(err) {
        if (err) {
          reject(err);
        } else {
          resolve(new Recipe({
            id: this.lastID,
            name,
            duration,
            photo
          }));
        }
      });
    });
  }

  // Find recipe by ID with related data
  static async findById(id) {
    const db = getDb();
    return new Promise((resolve, reject) => {
      const sql = `
        SELECT r.*,
               GROUP_CONCAT(DISTINCT ri.id) as recipe_ingredient_ids,
               GROUP_CONCAT(DISTINCT rsl.id) as recipe_step_link_ids,
               GROUP_CONCAT(DISTINCT f.id) as favorite_ids,
               GROUP_CONCAT(DISTINCT c.id) as comment_ids
        FROM recipes r
        LEFT JOIN recipe_ingredients ri ON r.id = ri.recipe_id
        LEFT JOIN recipe_step_links rsl ON r.id = rsl.recipe_id
        LEFT JOIN favorites f ON r.id = f.recipe_id
        LEFT JOIN comments c ON r.id = c.recipe_id
        WHERE r.id = ?
        GROUP BY r.id
      `;
      db.get(sql, [id], (err, row) => {
        if (err) {
          reject(err);
        } else if (row) {
          const recipe = new Recipe(row);
          recipe.recipeIngredients = row.recipe_ingredient_ids ? 
            row.recipe_ingredient_ids.split(',').map(id => ({ id: parseInt(id) })) : [];
          recipe.recipeStepLinks = row.recipe_step_link_ids ? 
            row.recipe_step_link_ids.split(',').map(id => ({ id: parseInt(id) })) : [];
          recipe.favoriteRecipes = row.favorite_ids ? 
            row.favorite_ids.split(',').map(id => ({ id: parseInt(id) })) : [];
          recipe.comments = row.comment_ids ? 
            row.comment_ids.split(',').map(id => ({ id: parseInt(id) })) : [];
          resolve(recipe);
        } else {
          resolve(null);
        }
      });
    });
  }

  // Find all recipes with pagination and sorting
  static async findAll(options = {}) {
    const db = getDb();
    const { count = 50, offset = 0, sortBy = [], pageBy, pageAfter, pagePrior } = options;

    let sql = 'SELECT * FROM recipes';
    let params = [];
    let conditions = [];

    // Handle pagination
    if (pageBy && pageAfter) {
      conditions.push(`${pageBy} > ?`);
      params.push(pageAfter);
    }
    if (pageBy && pagePrior) {
      conditions.push(`${pageBy} < ?`);
      params.push(pagePrior);
    }

    if (conditions.length > 0) {
      sql += ' WHERE ' + conditions.join(' AND ');
    }

    // Handle sorting
    if (sortBy.length > 0) {
      const validSortFields = ['id', 'name', 'duration', 'created_at'];
      const sortClauses = sortBy
        .filter(field => validSortFields.includes(field.replace('-', '')))
        .map(field => {
          if (field.startsWith('-')) {
            return `${field.substring(1)} DESC`;
          }
          return `${field} ASC`;
        });
      
      if (sortClauses.length > 0) {
        sql += ' ORDER BY ' + sortClauses.join(', ');
      }
    } else {
      sql += ' ORDER BY created_at DESC';
    }

    sql += ' LIMIT ? OFFSET ?';
    params.push(count, offset);

    return new Promise((resolve, reject) => {
      db.all(sql, params, (err, rows) => {
        if (err) {
          reject(err);
        } else {
          const recipes = rows.map(row => new Recipe(row));
          resolve(recipes);
        }
      });
    });
  }

  // Update recipe
  async update(updateData) {
    const db = getDb();
    const { name, duration, photo } = updateData;
    
    return new Promise((resolve, reject) => {
      const sql = 'UPDATE recipes SET name = ?, duration = ?, photo = ? WHERE id = ?';
      db.run(sql, [name, duration, photo, this.id], (err) => {
        if (err) {
          reject(err);
        } else {
          this.name = name;
          this.duration = duration;
          this.photo = photo;
          resolve(this);
        }
      });
    });
  }

  // Delete recipe
  async delete() {
    const db = getDb();
    return new Promise((resolve, reject) => {
      const sql = 'DELETE FROM recipes WHERE id = ?';
      db.run(sql, [this.id], (err) => {
        if (err) {
          reject(err);
        } else {
          resolve();
        }
      });
    });
  }

  // Check if recipe exists by name
  static async existsByName(name, excludeId = null) {
    const db = getDb();
    return new Promise((resolve, reject) => {
      let sql = 'SELECT COUNT(*) as count FROM recipes WHERE name = ?';
      let params = [name];
      
      if (excludeId) {
        sql += ' AND id != ?';
        params.push(excludeId);
      }
      
      db.get(sql, params, (err, row) => {
        if (err) {
          reject(err);
        } else {
          resolve(row.count > 0);
        }
      });
    });
  }

  // Convert to JSON
  toJSON() {
    return {
      id: this.id,
      name: this.name,
      duration: this.duration,
      photo: this.photo,
      recipeIngredients: this.recipeIngredients,
      recipeStepLinks: this.recipeStepLinks,
      favoriteRecipes: this.favoriteRecipes,
      comments: this.comments
    };
  }
}

module.exports = Recipe;