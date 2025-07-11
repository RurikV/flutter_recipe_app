const { getDb } = require('../config/database');

class BaseModel {
  constructor(tableName, data = {}) {
    this.tableName = tableName;
    Object.assign(this, data);
  }

  // Generic create method
  static async create(tableName, data) {
    const db = getDb();
    const fields = Object.keys(data);
    const values = Object.values(data);
    const placeholders = fields.map(() => '?').join(', ');
    
    const sql = `INSERT INTO ${tableName} (${fields.join(', ')}) VALUES (${placeholders})`;
    
    return new Promise((resolve, reject) => {
      db.run(sql, values, function(err) {
        if (err) {
          reject(err);
        } else {
          resolve({ id: this.lastID, ...data });
        }
      });
    });
  }

  // Generic find by ID method
  static async findById(tableName, id) {
    const db = getDb();
    return new Promise((resolve, reject) => {
      const sql = `SELECT * FROM ${tableName} WHERE id = ?`;
      db.get(sql, [id], (err, row) => {
        if (err) {
          reject(err);
        } else {
          resolve(row);
        }
      });
    });
  }

  // Generic find all method with pagination
  static async findAll(tableName, options = {}) {
    const db = getDb();
    const { count = 50, offset = 0, sortBy = [], pageBy, pageAfter, pagePrior } = options;

    let sql = `SELECT * FROM ${tableName}`;
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
      const sortClauses = sortBy.map(field => {
        if (field.startsWith('-')) {
          return `${field.substring(1)} DESC`;
        }
        return `${field} ASC`;
      });
      sql += ' ORDER BY ' + sortClauses.join(', ');
    } else {
      sql += ' ORDER BY id DESC';
    }

    sql += ' LIMIT ? OFFSET ?';
    params.push(count, offset);

    return new Promise((resolve, reject) => {
      db.all(sql, params, (err, rows) => {
        if (err) {
          reject(err);
        } else {
          resolve(rows);
        }
      });
    });
  }

  // Generic update method
  static async update(tableName, id, data) {
    const db = getDb();
    const fields = Object.keys(data);
    const values = Object.values(data);
    const setClause = fields.map(field => `${field} = ?`).join(', ');
    
    const sql = `UPDATE ${tableName} SET ${setClause} WHERE id = ?`;
    values.push(id);
    
    return new Promise((resolve, reject) => {
      db.run(sql, values, function(err) {
        if (err) {
          reject(err);
        } else {
          resolve({ id, ...data });
        }
      });
    });
  }

  // Generic delete method
  static async delete(tableName, id) {
    const db = getDb();
    return new Promise((resolve, reject) => {
      const sql = `DELETE FROM ${tableName} WHERE id = ?`;
      db.run(sql, [id], (err) => {
        if (err) {
          reject(err);
        } else {
          resolve();
        }
      });
    });
  }

  // Generic exists check
  static async exists(tableName, field, value, excludeId = null) {
    const db = getDb();
    return new Promise((resolve, reject) => {
      let sql = `SELECT COUNT(*) as count FROM ${tableName} WHERE ${field} = ?`;
      let params = [value];
      
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
}

module.exports = BaseModel;