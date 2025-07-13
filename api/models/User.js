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
    const supabase = getDb();
    const { login, password, avatar = '' } = userData;

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    try {
      const { data, error } = await supabase
        .from('users')
        .insert([{ login, password: hashedPassword, avatar }])
        .select()
        .single();

      if (error) {
        if (error.code === '23505') { // PostgreSQL unique constraint violation
          throw new Error('User already exists');
        } else {
          throw error;
        }
      }

      return new User(data);
    } catch (error) {
      throw error;
    }
  }

  // Find user by login
  static async findByLogin(login) {
    const supabase = getDb();

    try {
      const { data, error } = await supabase
        .from('users')
        .select('*')
        .eq('login', login)
        .single();

      if (error) {
        if (error.code === 'PGRST116') { // No rows returned
          return null;
        }
        throw error;
      }

      return new User(data);
    } catch (error) {
      throw error;
    }
  }

  // Find user by ID
  static async findById(id) {
    const supabase = getDb();

    try {
      // Get user data
      const { data: userData, error: userError } = await supabase
        .from('users')
        .select('*')
        .eq('id', id)
        .single();

      if (userError) {
        if (userError.code === 'PGRST116') { // No rows returned
          return null;
        }
        throw userError;
      }

      const user = new User(userData);

      // Get favorite recipes
      const { data: favorites, error: favError } = await supabase
        .from('favorites')
        .select('recipe_id')
        .eq('user_id', id);

      if (favError) throw favError;
      user.favoriteRecipes = favorites.map(f => ({ id: f.recipe_id }));

      // Get freezer items
      const { data: freezer, error: freezerError } = await supabase
        .from('freezer')
        .select('id')
        .eq('user_id', id);

      if (freezerError) throw freezerError;
      user.userFreezer = freezer.map(f => ({ id: f.id }));

      // Get comments
      const { data: comments, error: commentsError } = await supabase
        .from('comments')
        .select('id')
        .eq('user_id', id);

      if (commentsError) throw commentsError;
      user.comments = comments.map(c => ({ id: c.id }));

      return user;
    } catch (error) {
      throw error;
    }
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
    const supabase = getDb();

    try {
      const { error } = await supabase
        .from('users')
        .update({ token })
        .eq('id', this.id);

      if (error) {
        throw error;
      }
    } catch (error) {
      throw error;
    }
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
