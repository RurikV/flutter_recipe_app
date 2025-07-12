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
    return new Promise(async (resolve, reject) => {
      try {
        // First get the recipe
        const recipeQuery = 'SELECT * FROM recipes WHERE id = ?';
        const recipe = await new Promise((res, rej) => {
          db.get(recipeQuery, [id], (err, row) => {
            if (err) rej(err);
            else res(row);
          });
        });

        if (!recipe) {
          resolve(null);
          return;
        }

        // Get ingredients with full data
        const ingredientsQuery = `
          SELECT ri.count, i.name, mu.one, mu.few, mu.many
          FROM recipe_ingredients ri
          JOIN ingredients i ON ri.ingredient_id = i.id
          LEFT JOIN measure_units mu ON i.measureUnit_id = mu.id
          WHERE ri.recipe_id = ?
        `;
        const ingredients = await new Promise((res, rej) => {
          db.all(ingredientsQuery, [id], (err, rows) => {
            if (err) rej(err);
            else res(rows || []);
          });
        });

        // Get recipe steps with full data
        const stepsQuery = `
          SELECT rs.name, rs.duration, rsl.number
          FROM recipe_step_links rsl
          JOIN recipe_steps rs ON rsl.step_id = rs.id
          WHERE rsl.recipe_id = ?
          ORDER BY rsl.number
        `;
        const steps = await new Promise((res, rej) => {
          db.all(stepsQuery, [id], (err, rows) => {
            if (err) rej(err);
            else res(rows || []);
          });
        });

        // Get comments
        const commentsQuery = `
          SELECT c.*, u.login as author_name
          FROM comments c
          LEFT JOIN users u ON c.user_id = u.id
          WHERE c.recipe_id = ?
          ORDER BY c.datetime DESC
        `;
        const comments = await new Promise((res, rej) => {
          db.all(commentsQuery, [id], (err, rows) => {
            if (err) rej(err);
            else res(rows || []);
          });
        });

        // Create recipe object
        const recipeObj = new Recipe(recipe);

        // Add ingredients with proper structure
        recipeObj.recipeIngredients = ingredients.map(ing => ({
          count: ing.count,
          ingredient: {
            name: ing.name,
            measureUnit: ing.one ? {
              one: ing.one,
              few: ing.few,
              many: ing.many
            } : null
          }
        }));

        // Add steps with proper structure
        recipeObj.recipeStepLinks = steps.map(step => ({
          step: {
            name: step.name,
            duration: step.duration
          },
          number: step.number
        }));

        // Add comments
        recipeObj.comments = comments.map(comment => ({
          id: comment.id,
          text: comment.text,
          authorName: comment.author_name || 'Unknown',
          date: comment.datetime
        }));

        resolve(recipeObj);
      } catch (error) {
        reject(error);
      }
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
