const { getDb } = require('../config/database');

class BaseModel {
  constructor(tableName, data = {}) {
    this.tableName = tableName;
    Object.assign(this, data);
  }

  // Generic create method
  static async create(tableName, data) {
    const supabase = getDb();

    try {
      const { data: result, error } = await supabase
        .from(tableName)
        .insert([data])
        .select()
        .single();

      if (error) {
        throw error;
      }

      return result;
    } catch (error) {
      throw error;
    }
  }

  // Generic find by ID method
  static async findById(tableName, id) {
    const supabase = getDb();

    try {
      const { data, error } = await supabase
        .from(tableName)
        .select('*')
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

  // Generic find all method with pagination
  static async findAll(tableName, options = {}) {
    const supabase = getDb();
    const { count = 50, offset = 0, sortBy = [], pageBy, pageAfter, pagePrior } = options;

    try {
      let query = supabase.from(tableName).select('*');

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

  // Generic update method
  static async update(tableName, id, data) {
    const supabase = getDb();

    try {
      const { data: result, error } = await supabase
        .from(tableName)
        .update(data)
        .eq('id', id)
        .select()
        .single();

      if (error) {
        throw error;
      }

      return result;
    } catch (error) {
      throw error;
    }
  }

  // Generic delete method
  static async delete(tableName, id) {
    const supabase = getDb();

    try {
      const { error } = await supabase
        .from(tableName)
        .delete()
        .eq('id', id);

      if (error) {
        throw error;
      }
    } catch (error) {
      throw error;
    }
  }

  // Generic exists check
  static async exists(tableName, field, value, excludeId = null) {
    const supabase = getDb();

    try {
      let query = supabase
        .from(tableName)
        .select('id', { count: 'exact', head: true })
        .eq(field, value);

      if (excludeId) {
        query = query.neq('id', excludeId);
      }

      const { count, error } = await query;

      if (error) {
        throw error;
      }

      return count > 0;
    } catch (error) {
      throw error;
    }
  }
}

module.exports = BaseModel;
