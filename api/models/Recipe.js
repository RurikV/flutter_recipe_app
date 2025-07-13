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
    const supabase = getDb();
    const { name, duration, photo = '' } = recipeData;

    try {
      const { data, error } = await supabase
        .from('recipes')
        .insert([{ name, duration, photo }])
        .select()
        .single();

      if (error) {
        throw error;
      }

      return new Recipe(data);
    } catch (error) {
      throw error;
    }
  }

  // Find recipe by ID with related data
  static async findById(id) {
    const supabase = getDb();

    try {
      // First get the recipe
      const { data: recipe, error: recipeError } = await supabase
        .from('recipes')
        .select('*')
        .eq('id', id)
        .single();

      if (recipeError) {
        if (recipeError.code === 'PGRST116') { // No rows returned
          return null;
        }
        throw recipeError;
      }

      if (!recipe) {
        return null;
      }

      // Get ingredients with full data using joins
      const { data: ingredients, error: ingredientsError } = await supabase
        .from('recipe_ingredients')
        .select(`
          count,
          ingredients (
            name,
            measure_units (
              one,
              few,
              many
            )
          )
        `)
        .eq('recipe_id', id);

      if (ingredientsError) throw ingredientsError;

      // Get recipe steps with full data using joins
      const { data: steps, error: stepsError } = await supabase
        .from('recipe_step_links')
        .select(`
          number,
          recipe_steps (
            name,
            duration
          )
        `)
        .eq('recipe_id', id)
        .order('number');

      if (stepsError) throw stepsError;

      // Get comments with user info
      const { data: comments, error: commentsError } = await supabase
        .from('comments')
        .select(`
          id,
          text,
          datetime,
          users (
            login
          )
        `)
        .eq('recipe_id', id)
        .order('datetime', { ascending: false });

      if (commentsError) throw commentsError;

      // Create recipe object
      const recipeObj = new Recipe(recipe);

      // Add ingredients with proper structure
      recipeObj.recipeIngredients = (ingredients || []).map(ing => ({
        count: ing.count,
        ingredient: {
          name: ing.ingredients?.name || '',
          measureUnit: ing.ingredients?.measure_units ? {
            one: ing.ingredients.measure_units.one,
            few: ing.ingredients.measure_units.few,
            many: ing.ingredients.measure_units.many
          } : null
        }
      }));

      // Add steps with proper structure
      recipeObj.recipeStepLinks = (steps || []).map(step => ({
        step: {
          name: step.recipe_steps?.name || '',
          duration: step.recipe_steps?.duration || 0
        },
        number: step.number
      }));

      // Add comments
      recipeObj.comments = (comments || []).map(comment => ({
        id: comment.id,
        text: comment.text,
        authorName: comment.users?.login || 'Unknown',
        date: comment.datetime
      }));

      return recipeObj;
    } catch (error) {
      throw error;
    }
  }

  // Find all recipes with pagination and sorting
  static async findAll(options = {}) {
    const supabase = getDb();
    const { count = 50, offset = 0, sortBy = [], pageBy, pageAfter, pagePrior } = options;

    try {
      let query = supabase.from('recipes').select('*');

      // Handle pagination
      if (pageBy && pageAfter) {
        query = query.gt(pageBy, pageAfter);
      }
      if (pageBy && pagePrior) {
        query = query.lt(pageBy, pagePrior);
      }

      // Handle sorting
      if (sortBy.length > 0) {
        const validSortFields = ['id', 'name', 'duration', 'created_at'];
        for (const field of sortBy) {
          const cleanField = field.replace('-', '');
          if (validSortFields.includes(cleanField)) {
            const ascending = !field.startsWith('-');
            query = query.order(cleanField, { ascending });
          }
        }
      } else {
        query = query.order('created_at', { ascending: false });
      }

      // Apply pagination
      query = query.range(offset, offset + count - 1);

      const { data, error } = await query;

      if (error) {
        throw error;
      }

      const recipes = (data || []).map(row => new Recipe(row));
      return recipes;
    } catch (error) {
      throw error;
    }
  }

  // Update recipe
  async update(updateData) {
    const supabase = getDb();
    const { name, duration, photo } = updateData;

    try {
      const { data, error } = await supabase
        .from('recipes')
        .update({ name, duration, photo })
        .eq('id', this.id)
        .select()
        .single();

      if (error) {
        throw error;
      }

      this.name = name;
      this.duration = duration;
      this.photo = photo;
      return this;
    } catch (error) {
      throw error;
    }
  }

  // Delete recipe
  async delete() {
    const supabase = getDb();

    try {
      const { error } = await supabase
        .from('recipes')
        .delete()
        .eq('id', this.id);

      if (error) {
        throw error;
      }
    } catch (error) {
      throw error;
    }
  }

  // Check if recipe exists by name
  static async existsByName(name, excludeId = null) {
    const supabase = getDb();

    try {
      let query = supabase
        .from('recipes')
        .select('id', { count: 'exact', head: true })
        .eq('name', name);

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
