const { getDb } = require('../config/database');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

class User {
  constructor(data) {
    this.id = data.id;
    this.login = data.login;
    this.password = data.password;
    this.token = data.token;
    this.avatar = data.avatar || '';
    this.userFreezer = data.userFreezer || [];
    this.favoriteRecipes = data.favoriteRecipes || [];
    this.comments = data.comments || [];
  }

  // Create a new user
  static async create(userData) {
    const db = getDb();
    const { login, password, avatar = '' } = userData;

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    return new Promise((resolve, reject) => {
      const sql = 'INSERT INTO users (login, password, avatar) VALUES (?, ?, ?)';
      db.run(sql, [login, hashedPassword, avatar], function(err) {
        if (err) {
          if (err.code === 'SQLITE_CONSTRAINT_UNIQUE') {
            reject(new Error('User already exists'));
          } else {
            reject(err);
          }
        } else {
          resolve(new User({
            id: this.lastID,
            login,
            password: hashedPassword,
            avatar
          }));
        }
      });
    });
  }

  // Find user by login
  static async findByLogin(login) {
    const db = getDb();
    return new Promise((resolve, reject) => {
      const sql = 'SELECT * FROM users WHERE login = ?';
      db.get(sql, [login], (err, row) => {
        if (err) {
          reject(err);
        } else if (row) {
          resolve(new User(row));
        } else {
          resolve(null);
        }
      });
    });
  }

  // Find user by ID
  static async findById(id) {
    const db = getDb();
    return new Promise((resolve, reject) => {
      const sql = `
        SELECT u.*, 
               GROUP_CONCAT(DISTINCT f.recipe_id) as favorite_recipe_ids,
               GROUP_CONCAT(DISTINCT fr.id) as freezer_ids,
               GROUP_CONCAT(DISTINCT c.id) as comment_ids
        FROM users u
        LEFT JOIN favorites f ON u.id = f.user_id
        LEFT JOIN freezer fr ON u.id = fr.user_id
        LEFT JOIN comments c ON u.id = c.user_id
        WHERE u.id = ?
        GROUP BY u.id
      `;
      db.get(sql, [id], (err, row) => {
        if (err) {
          reject(err);
        } else if (row) {
          const user = new User(row);
          user.favoriteRecipes = row.favorite_recipe_ids ? row.favorite_recipe_ids.split(',').map(id => ({ id: parseInt(id) })) : [];
          user.userFreezer = row.freezer_ids ? row.freezer_ids.split(',').map(id => ({ id: parseInt(id) })) : [];
          user.comments = row.comment_ids ? row.comment_ids.split(',').map(id => ({ id: parseInt(id) })) : [];
          resolve(user);
        } else {
          resolve(null);
        }
      });
    });
  }

  // Authenticate user
  static async authenticate(login, password) {
    const user = await User.findByLogin(login);
    if (!user) {
      throw new Error('Invalid credentials');
    }

    const isValidPassword = await bcrypt.compare(password, user.password);
    if (!isValidPassword) {
      throw new Error('Invalid credentials');
    }

    // Generate JWT token
    const token = jwt.sign(
      { userId: user.id, login: user.login },
      process.env.JWT_SECRET || 'your-secret-key',
      { expiresIn: '24h' }
    );

    // Update user token in database
    await user.updateToken(token);
    user.token = token;

    return user;
  }

  // Update user token
  async updateToken(token) {
    const db = getDb();
    return new Promise((resolve, reject) => {
      const sql = 'UPDATE users SET token = ? WHERE id = ?';
      db.run(sql, [token, this.id], (err) => {
        if (err) {
          reject(err);
        } else {
          resolve();
        }
      });
    });
  }

  // Convert to JSON (excluding sensitive data)
  toJSON() {
    const { password, ...userWithoutPassword } = this;
    return userWithoutPassword;
  }

  // Convert to JSON for public display (excluding token and other sensitive data)
  toPublicJSON() {
    return {
      id: this.id,
      login: this.login,
      avatar: this.avatar,
      userFreezer: this.userFreezer,
      favoriteRecipes: this.favoriteRecipes,
      comments: this.comments
    };
  }
}

module.exports = User;