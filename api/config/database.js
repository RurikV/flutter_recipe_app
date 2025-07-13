const { createClient } = require('@supabase/supabase-js');

let supabase = null;

// Initialize Supabase client
const init = () => {
  return new Promise((resolve, reject) => {
    try {
      const supabaseUrl = process.env.SUPABASE_URL;
      const supabaseKey = process.env.SUPABASE_ANON_KEY;

      if (!supabaseUrl || !supabaseKey) {
        throw new Error('Supabase URL and key must be provided in environment variables');
      }

      supabase = createClient(supabaseUrl, supabaseKey);
      console.log('Connected to Supabase database');
      resolve();
    } catch (error) {
      console.error('Error connecting to Supabase:', error);
      reject(error);
    }
  });
};

// Get Supabase client instance
const getDb = () => {
  if (!supabase) {
    throw new Error('Supabase client not initialized. Call init() first.');
  }
  return supabase;
};

// Close database connection (no-op for Supabase)
const close = () => {
  return new Promise((resolve) => {
    console.log('Supabase connection closed');
    resolve();
  });
};

module.exports = {
  init,
  getDb,
  close
};
