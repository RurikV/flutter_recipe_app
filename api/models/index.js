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
    return await BaseModel.create('ingredients', data);
  }
  
  static async findById(id) {
    return await BaseModel.findById('ingredients', id);
  }
  
  static async findAll(options) {
    return await BaseModel.findAll('ingredients', options);
  }
  
  static async update(id, data) {
    return await BaseModel.update('ingredients', id, data);
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
    return await BaseModel.create('recipe_step_links', data);
  }
  
  static async findById(id) {
    return await BaseModel.findById('recipe_step_links', id);
  }
  
  static async findAll(options) {
    return await BaseModel.findAll('recipe_step_links', options);
  }
  
  static async update(id, data) {
    return await BaseModel.update('recipe_step_links', id, data);
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
    return await BaseModel.create('recipe_ingredients', data);
  }
  
  static async findById(id) {
    return await BaseModel.findById('recipe_ingredients', id);
  }
  
  static async findAll(options) {
    return await BaseModel.findAll('recipe_ingredients', options);
  }
  
  static async update(id, data) {
    return await BaseModel.update('recipe_ingredients', id, data);
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
    return await BaseModel.create('comments', data);
  }
  
  static async findById(id) {
    return await BaseModel.findById('comments', id);
  }
  
  static async findAll(options) {
    return await BaseModel.findAll('comments', options);
  }
  
  static async update(id, data) {
    return await BaseModel.update('comments', id, data);
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
    return await BaseModel.create('freezer', data);
  }
  
  static async findById(id) {
    return await BaseModel.findById('freezer', id);
  }
  
  static async findAll(options) {
    return await BaseModel.findAll('freezer', options);
  }
  
  static async update(id, data) {
    return await BaseModel.update('freezer', id, data);
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
    return await BaseModel.create('favorites', data);
  }
  
  static async findById(id) {
    return await BaseModel.findById('favorites', id);
  }
  
  static async findAll(options) {
    return await BaseModel.findAll('favorites', options);
  }
  
  static async update(id, data) {
    return await BaseModel.update('favorites', id, data);
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