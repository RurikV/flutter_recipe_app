const BaseModel = require('./BaseModel');

// Simple models using BaseModel
class MeasureUnit extends BaseModel {
  static async create(data) {
    return await BaseModel.create('measure_units', data);
  }
  
  static async findById(id) {
    return await BaseModel.findById('measure_units', id);
  }
  
  static async findAll(options) {
    return await BaseModel.findAll('measure_units', options);
  }
  
  static async update(id, data) {
    return await BaseModel.update('measure_units', id, data);
  }
  
  static async delete(id) {
    return await BaseModel.delete('measure_units', id);
  }
  
  static async exists(field, value, excludeId) {
    return await BaseModel.exists('measure_units', field, value, excludeId);
  }
}

class Ingredient extends BaseModel {
  static async create(data) {
    const supabase = require('../config/database').getDb();

    try {
      const { data: result, error } = await supabase
        .from('ingredients')
        .insert([data])
        .select(`
          id,
          name,
          caloriesForUnit,
          created_at,
          measureUnit:measure_units(id, one, few, many)
        `)
        .single();

      if (error) {
        throw error;
      }

      return result;
    } catch (error) {
      throw error;
    }
  }
  
  static async findById(id) {
    const supabase = require('../config/database').getDb();
    
    try {
      const { data, error } = await supabase
        .from('ingredients')
        .select(`
          id,
          name,
          caloriesForUnit,
          created_at,
          measureUnit:measure_units(id, one, few, many)
        `)
        .eq('id', id)
        .single();

      if (error) {
        if (error.code === 'PGRST116') { // No rows returned
          return null;
        }
        throw error;
      }

      return data;
    } catch (error) {
      throw error;
    }
  }
  
  static async findAll(options) {
    const supabase = require('../config/database').getDb();
    const { count = 50, offset = 0, sortBy = [], pageBy, pageAfter, pagePrior } = options;

    try {
      let query = supabase
        .from('ingredients')
        .select(`
          id,
          name,
          caloriesForUnit,
          created_at,
          measureUnit:measure_units(id, one, few, many)
        `);

      // Handle pagination
      if (pageBy && pageAfter) {
        query = query.gt(pageBy, pageAfter);
      }
      if (pageBy && pagePrior) {
        query = query.lt(pageBy, pagePrior);
      }

      // Handle sorting
      if (sortBy.length > 0) {
        for (const field of sortBy) {
          const cleanField = field.replace('-', '');
          const ascending = !field.startsWith('-');
          query = query.order(cleanField, { ascending });
        }
      } else {
        query = query.order('id', { ascending: false });
      }

      // Apply pagination
      query = query.range(offset, offset + count - 1);

      const { data, error } = await query;

      if (error) {
        throw error;
      }

      return data || [];
    } catch (error) {
      throw error;
    }
  }
  
  static async update(id, data) {
    const supabase = require('../config/database').getDb();

    try {
      const { data: result, error } = await supabase
        .from('ingredients')
        .update(data)
        .eq('id', id)
        .select(`
          id,
          name,
          caloriesForUnit,
          created_at,
          measureUnit:measure_units(id, one, few, many)
        `)
        .single();

      if (error) {
        throw error;
      }

      return result;
    } catch (error) {
      throw error;
    }
  }
  
  static async delete(id) {
    return await BaseModel.delete('ingredients', id);
  }
  
  static async exists(field, value, excludeId) {
    return await BaseModel.exists('ingredients', field, value, excludeId);
  }
}

class RecipeStep extends BaseModel {
  static async create(data) {
    return await BaseModel.create('recipe_steps', data);
  }
  
  static async findById(id) {
    return await BaseModel.findById('recipe_steps', id);
  }
  
  static async findAll(options) {
    return await BaseModel.findAll('recipe_steps', options);
  }
  
  static async update(id, data) {
    return await BaseModel.update('recipe_steps', id, data);
  }
  
  static async delete(id) {
    return await BaseModel.delete('recipe_steps', id);
  }
  
  static async exists(field, value, excludeId) {
    return await BaseModel.exists('recipe_steps', field, value, excludeId);
  }
}

class RecipeStepLink extends BaseModel {
  static async create(data) {
    const supabase = require('../config/database').getDb();

    try {
      const { data: result, error } = await supabase
        .from('recipe_step_links')
        .insert([data])
        .select(`
          id,
          number,
          created_at,
          recipe:recipes(id, name),
          step:recipe_steps(id, name)
        `)
        .single();

      if (error) {
        throw error;
      }

      return result;
    } catch (error) {
      throw error;
    }
  }
  
  static async findById(id) {
    const supabase = require('../config/database').getDb();
    
    try {
      const { data, error } = await supabase
        .from('recipe_step_links')
        .select(`
          id,
          number,
          created_at,
          recipe:recipes(id, name),
          step:recipe_steps(id, name)
        `)
        .eq('id', id)
        .single();

      if (error) {
        if (error.code === 'PGRST116') { // No rows returned
          return null;
        }
        throw error;
      }

      return data;
    } catch (error) {
      throw error;
    }
  }
  
  static async findAll(options) {
    const supabase = require('../config/database').getDb();
    const { count = 50, offset = 0, sortBy = [], pageBy, pageAfter, pagePrior } = options;

    try {
      let query = supabase
        .from('recipe_step_links')
        .select(`
          id,
          number,
          created_at,
          recipe:recipes(id, name),
          step:recipe_steps(id, name)
        `);

      // Handle pagination
      if (pageBy && pageAfter) {
        query = query.gt(pageBy, pageAfter);
      }
      if (pageBy && pagePrior) {
        query = query.lt(pageBy, pagePrior);
      }

      // Handle sorting
      if (sortBy.length > 0) {
        for (const field of sortBy) {
          const cleanField = field.replace('-', '');
          const ascending = !field.startsWith('-');
          query = query.order(cleanField, { ascending });
        }
      } else {
        query = query.order('id', { ascending: false });
      }

      // Apply pagination
      query = query.range(offset, offset + count - 1);

      const { data, error } = await query;

      if (error) {
        throw error;
      }

      return data || [];
    } catch (error) {
      throw error;
    }
  }
  
  static async update(id, data) {
    const supabase = require('../config/database').getDb();

    try {
      const { data: result, error } = await supabase
        .from('recipe_step_links')
        .update(data)
        .eq('id', id)
        .select(`
          id,
          number,
          created_at,
          recipe:recipes(id, name),
          step:recipe_steps(id, name)
        `)
        .single();

      if (error) {
        throw error;
      }

      return result;
    } catch (error) {
      throw error;
    }
  }
  
  static async delete(id) {
    return await BaseModel.delete('recipe_step_links', id);
  }
  
  static async exists(field, value, excludeId) {
    return await BaseModel.exists('recipe_step_links', field, value, excludeId);
  }
}

class RecipeIngredient extends BaseModel {
  static async create(data) {
    const supabase = require('../config/database').getDb();

    try {
      const { data: result, error } = await supabase
        .from('recipe_ingredients')
        .insert([data])
        .select(`
          id,
          count,
          created_at,
          ingredient:ingredients(id, name),
          recipe:recipes(id, name)
        `)
        .single();

      if (error) {
        throw error;
      }

      return result;
    } catch (error) {
      throw error;
    }
  }
  
  static async findById(id) {
    const supabase = require('../config/database').getDb();
    
    try {
      const { data, error } = await supabase
        .from('recipe_ingredients')
        .select(`
          id,
          count,
          created_at,
          ingredient:ingredients(id, name),
          recipe:recipes(id, name)
        `)
        .eq('id', id)
        .single();

      if (error) {
        if (error.code === 'PGRST116') { // No rows returned
          return null;
        }
        throw error;
      }

      return data;
    } catch (error) {
      throw error;
    }
  }
  
  static async findAll(options) {
    const supabase = require('../config/database').getDb();
    const { count = 50, offset = 0, sortBy = [], pageBy, pageAfter, pagePrior } = options;

    try {
      let query = supabase
        .from('recipe_ingredients')
        .select(`
          id,
          count,
          created_at,
          ingredient:ingredients(id, name),
          recipe:recipes(id, name)
        `);

      // Handle pagination
      if (pageBy && pageAfter) {
        query = query.gt(pageBy, pageAfter);
      }
      if (pageBy && pagePrior) {
        query = query.lt(pageBy, pagePrior);
      }

      // Handle sorting
      if (sortBy.length > 0) {
        for (const field of sortBy) {
          const cleanField = field.replace('-', '');
          const ascending = !field.startsWith('-');
          query = query.order(cleanField, { ascending });
        }
      } else {
        query = query.order('id', { ascending: false });
      }

      // Apply pagination
      query = query.range(offset, offset + count - 1);

      const { data, error } = await query;

      if (error) {
        throw error;
      }

      return data || [];
    } catch (error) {
      throw error;
    }
  }
  
  static async update(id, data) {
    const supabase = require('../config/database').getDb();

    try {
      const { data: result, error } = await supabase
        .from('recipe_ingredients')
        .update(data)
        .eq('id', id)
        .select(`
          id,
          count,
          created_at,
          ingredient:ingredients(id, name),
          recipe:recipes(id, name)
        `)
        .single();

      if (error) {
        throw error;
      }

      return result;
    } catch (error) {
      throw error;
    }
  }
  
  static async delete(id) {
    return await BaseModel.delete('recipe_ingredients', id);
  }
  
  static async exists(field, value, excludeId) {
    return await BaseModel.exists('recipe_ingredients', field, value, excludeId);
  }
}

class Comment extends BaseModel {
  static async create(data) {
    const supabase = require('../config/database').getDb();

    try {
      const { data: result, error } = await supabase
        .from('comments')
        .insert([data])
        .select(`
          id,
          text,
          created_at,
          user:users(id, login),
          recipe:recipes(id, name)
        `)
        .single();

      if (error) {
        throw error;
      }

      return result;
    } catch (error) {
      throw error;
    }
  }
  
  static async findById(id) {
    const supabase = require('../config/database').getDb();
    
    try {
      const { data, error } = await supabase
        .from('comments')
        .select(`
          id,
          text,
          created_at,
          user:users(id, login),
          recipe:recipes(id, name)
        `)
        .eq('id', id)
        .single();

      if (error) {
        if (error.code === 'PGRST116') { // No rows returned
          return null;
        }
        throw error;
      }

      return data;
    } catch (error) {
      throw error;
    }
  }
  
  static async findAll(options) {
    const supabase = require('../config/database').getDb();
    const { count = 50, offset = 0, sortBy = [], pageBy, pageAfter, pagePrior } = options;

    try {
      let query = supabase
        .from('comments')
        .select(`
          id,
          text,
          created_at,
          user:users(id, login),
          recipe:recipes(id, name)
        `);

      // Handle pagination
      if (pageBy && pageAfter) {
        query = query.gt(pageBy, pageAfter);
      }
      if (pageBy && pagePrior) {
        query = query.lt(pageBy, pagePrior);
      }

      // Handle sorting
      if (sortBy.length > 0) {
        for (const field of sortBy) {
          const cleanField = field.replace('-', '');
          const ascending = !field.startsWith('-');
          query = query.order(cleanField, { ascending });
        }
      } else {
        query = query.order('id', { ascending: false });
      }

      // Apply pagination
      query = query.range(offset, offset + count - 1);

      const { data, error } = await query;

      if (error) {
        throw error;
      }

      return data || [];
    } catch (error) {
      throw error;
    }
  }
  
  static async update(id, data) {
    const supabase = require('../config/database').getDb();

    try {
      const { data: result, error } = await supabase
        .from('comments')
        .update(data)
        .eq('id', id)
        .select(`
          id,
          text,
          created_at,
          user:users(id, login),
          recipe:recipes(id, name)
        `)
        .single();

      if (error) {
        throw error;
      }

      return result;
    } catch (error) {
      throw error;
    }
  }
  
  static async delete(id) {
    return await BaseModel.delete('comments', id);
  }
  
  static async exists(field, value, excludeId) {
    return await BaseModel.exists('comments', field, value, excludeId);
  }
}

class Freezer extends BaseModel {
  static async create(data) {
    const supabase = require('../config/database').getDb();

    try {
      const { data: result, error } = await supabase
        .from('freezer')
        .insert([data])
        .select(`
          id,
          count,
          created_at,
          user:users(id, login),
          ingredient:ingredients(id, name)
        `)
        .single();

      if (error) {
        throw error;
      }

      return result;
    } catch (error) {
      throw error;
    }
  }
  
  static async findById(id) {
    const supabase = require('../config/database').getDb();
    
    try {
      const { data, error } = await supabase
        .from('freezer')
        .select(`
          id,
          count,
          created_at,
          user:users(id, login),
          ingredient:ingredients(id, name)
        `)
        .eq('id', id)
        .single();

      if (error) {
        if (error.code === 'PGRST116') { // No rows returned
          return null;
        }
        throw error;
      }

      return data;
    } catch (error) {
      throw error;
    }
  }
  
  static async findAll(options) {
    const supabase = require('../config/database').getDb();
    const { count = 50, offset = 0, sortBy = [], pageBy, pageAfter, pagePrior } = options;

    try {
      let query = supabase
        .from('freezer')
        .select(`
          id,
          count,
          created_at,
          user:users(id, login),
          ingredient:ingredients(id, name)
        `);

      // Handle pagination
      if (pageBy && pageAfter) {
        query = query.gt(pageBy, pageAfter);
      }
      if (pageBy && pagePrior) {
        query = query.lt(pageBy, pagePrior);
      }

      // Handle sorting
      if (sortBy.length > 0) {
        for (const field of sortBy) {
          const cleanField = field.replace('-', '');
          const ascending = !field.startsWith('-');
          query = query.order(cleanField, { ascending });
        }
      } else {
        query = query.order('id', { ascending: false });
      }

      // Apply pagination
      query = query.range(offset, offset + count - 1);

      const { data, error } = await query;

      if (error) {
        throw error;
      }

      return data || [];
    } catch (error) {
      throw error;
    }
  }
  
  static async update(id, data) {
    const supabase = require('../config/database').getDb();

    try {
      const { data: result, error } = await supabase
        .from('freezer')
        .update(data)
        .eq('id', id)
        .select(`
          id,
          count,
          created_at,
          user:users(id, login),
          ingredient:ingredients(id, name)
        `)
        .single();

      if (error) {
        throw error;
      }

      return result;
    } catch (error) {
      throw error;
    }
  }
  
  static async delete(id) {
    return await BaseModel.delete('freezer', id);
  }
  
  static async exists(field, value, excludeId) {
    return await BaseModel.exists('freezer', field, value, excludeId);
  }
}

class Favorite extends BaseModel {
  static async create(data) {
    const supabase = require('../config/database').getDb();

    try {
      const { data: result, error } = await supabase
        .from('favorites')
        .insert([data])
        .select(`
          id,
          created_at,
          recipe:recipes(id, name),
          user:users(id, login)
        `)
        .single();

      if (error) {
        throw error;
      }

      return result;
    } catch (error) {
      throw error;
    }
  }
  
  static async findById(id) {
    const supabase = require('../config/database').getDb();
    
    try {
      const { data, error } = await supabase
        .from('favorites')
        .select(`
          id,
          created_at,
          recipe:recipes(id, name),
          user:users(id, login)
        `)
        .eq('id', id)
        .single();

      if (error) {
        if (error.code === 'PGRST116') { // No rows returned
          return null;
        }
        throw error;
      }

      return data;
    } catch (error) {
      throw error;
    }
  }
  
  static async findAll(options) {
    const supabase = require('../config/database').getDb();
    const { count = 50, offset = 0, sortBy = [], pageBy, pageAfter, pagePrior } = options;

    try {
      let query = supabase
        .from('favorites')
        .select(`
          id,
          created_at,
          recipe:recipes(id, name),
          user:users(id, login)
        `);

      // Handle pagination
      if (pageBy && pageAfter) {
        query = query.gt(pageBy, pageAfter);
      }
      if (pageBy && pagePrior) {
        query = query.lt(pageBy, pagePrior);
      }

      // Handle sorting
      if (sortBy.length > 0) {
        for (const field of sortBy) {
          const cleanField = field.replace('-', '');
          const ascending = !field.startsWith('-');
          query = query.order(cleanField, { ascending });
        }
      } else {
        query = query.order('id', { ascending: false });
      }

      // Apply pagination
      query = query.range(offset, offset + count - 1);

      const { data, error } = await query;

      if (error) {
        throw error;
      }

      return data || [];
    } catch (error) {
      throw error;
    }
  }
  
  static async update(id, data) {
    const supabase = require('../config/database').getDb();

    try {
      const { data: result, error } = await supabase
        .from('favorites')
        .update(data)
        .eq('id', id)
        .select(`
          id,
          created_at,
          recipe:recipes(id, name),
          user:users(id, login)
        `)
        .single();

      if (error) {
        throw error;
      }

      return result;
    } catch (error) {
      throw error;
    }
  }
  
  static async delete(id) {
    return await BaseModel.delete('favorites', id);
  }
  
  static async exists(field, value, excludeId) {
    return await BaseModel.exists('favorites', field, value, excludeId);
  }
}

module.exports = {
  User: require('./User'),
  Recipe: require('./Recipe'),
  MeasureUnit,
  Ingredient,
  RecipeStep,
  RecipeStepLink,
  RecipeIngredient,
  Comment,
  Freezer,
  Favorite,
  BaseModel
};