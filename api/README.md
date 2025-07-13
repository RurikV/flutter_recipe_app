# Food API

A comprehensive REST API for the Flutter Recipe App, providing endpoints for managing recipes, ingredients, users, and more.

## Features

- **User Management**: Registration, authentication, and user profiles
- **Recipe Management**: CRUD operations for recipes with ingredients and steps
- **Ingredient Management**: Manage ingredients with nutritional information
- **Comments System**: User comments on recipes
- **Favorites**: User favorite recipes management
- **Freezer**: User ingredient inventory management
- **Pagination & Sorting**: Advanced query capabilities for all endpoints

## Tech Stack

- **Runtime**: Node.js
- **Framework**: Express.js
- **Database**: Supabase
- **Authentication**: JWT (JSON Web Tokens)
- **Validation**: Express Validator
- **Documentation**: Swagger/OpenAPI 3.0
- **Deployment**: Vercel

## API Endpoints

### Authentication
- `POST /user` - Register new user
- `PUT /user` - Login user
- `GET /user/{id}` - Get user profile

### Recipes
- `GET /recipe` - Get all recipes (with pagination)
- `POST /recipe` - Create new recipe
- `GET /recipe/{id}` - Get single recipe
- `PUT /recipe/{id}` - Update recipe
- `DELETE /recipe/{id}` - Delete recipe

### Ingredients
- `GET /ingredient` - Get all ingredients
- `POST /ingredient` - Create new ingredient
- `GET /ingredient/{id}` - Get single ingredient
- `PUT /ingredient/{id}` - Update ingredient
- `DELETE /ingredient/{id}` - Delete ingredient

### Recipe Steps
- `GET /recipe_step` - Get all recipe steps
- `POST /recipe_step` - Create new recipe step
- `GET /recipe_step/{id}` - Get single recipe step
- `PUT /recipe_step/{id}` - Update recipe step
- `DELETE /recipe_step/{id}` - Delete recipe step

### Recipe Step Links
- `GET /recipe_step_link` - Get all recipe step links
- `POST /recipe_step_link` - Create new recipe step link
- `GET /recipe_step_link/{id}` - Get single recipe step link
- `PUT /recipe_step_link/{id}` - Update recipe step link
- `DELETE /recipe_step_link/{id}` - Delete recipe step link

### Recipe Ingredients
- `GET /recipe_ingredient` - Get all recipe ingredients
- `POST /recipe_ingredient` - Create new recipe ingredient
- `GET /recipe_ingredient/{id}` - Get single recipe ingredient
- `PUT /recipe_ingredient/{id}` - Update recipe ingredient
- `DELETE /recipe_ingredient/{id}` - Delete recipe ingredient

### Measure Units
- `GET /measure_unit` - Get all measure units
- `POST /measure_unit` - Create new measure unit
- `GET /measure_unit/{id}` - Get single measure unit
- `PUT /measure_unit/{id}` - Update measure unit
- `DELETE /measure_unit/{id}` - Delete measure unit

### Comments
- `GET /comment` - Get all comments
- `POST /comment` - Create new comment
- `GET /comment/{id}` - Get single comment
- `PUT /comment/{id}` - Update comment
- `DELETE /comment/{id}` - Delete comment

### Freezer
- `GET /freezer` - Get all freezer items
- `POST /freezer` - Create new freezer item
- `GET /freezer/{id}` - Get single freezer item
- `PUT /freezer/{id}` - Update freezer item
- `DELETE /freezer/{id}` - Delete freezer item

### Favorites
- `GET /favorite` - Get all favorites
- `POST /favorite` - Create new favorite
- `GET /favorite/{id}` - Get single favorite
- `PUT /favorite/{id}` - Update favorite
- `DELETE /favorite/{id}` - Delete favorite

## Query Parameters

All GET endpoints support the following query parameters:

- `count` - Number of items to return (default: 50)
- `offset` - Number of items to skip (default: 0)
- `pageBy` - Field to use for cursor-based pagination
- `pageAfter` - Get items after this cursor value
- `pagePrior` - Get items before this cursor value
- `sortBy` - Array of fields to sort by (prefix with `-` for descending)

## Local Development

1. **Install dependencies**:
   ```bash
   npm install
   ```

2. **Set up environment**:
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

3. **Start development server**:
   ```bash
   npm run dev
   ```

4. **Access the API**:
   - API: http://localhost:3000
   - Documentation: http://localhost:3000/api-docs
   - Health check: http://localhost:3000/health

## Deployment

This API is configured for deployment on Vercel:

1. **Deploy to Vercel**:
   ```bash
   vercel --prod
   ```

2. **Set environment variables** in Vercel dashboard:
   - `JWT_SECRET`
   - `NODE_ENV=production`

## Documentation

- **Swagger UI**: Available at `/api-docs` endpoint
- **OpenAPI Spec**: Available in `swagger.yaml`

## Database Schema

The API uses SQLite with the following main tables:

- `users` - User accounts and authentication
- `recipes` - Recipe information
- `ingredients` - Ingredient catalog
- `recipe_ingredients` - Recipe-ingredient relationships
- `recipe_steps` - Individual recipe steps
- `recipe_step_links` - Recipe-step relationships
- `measure_units` - Units of measurement
- `comments` - User comments on recipes
- `favorites` - User favorite recipes
- `freezer` - User ingredient inventory

## Error Handling

The API returns consistent error responses:

```json
{
  "error": "Error message description"
}
```

Common HTTP status codes:
- `200` - Success
- `400` - Bad Request (validation errors)
- `403` - Forbidden (authentication errors)
- `404` - Not Found
- `409` - Conflict (duplicate resources)
- `500` - Internal Server Error

## Security

- Passwords are hashed using bcrypt
- JWT tokens for authentication
- Input validation on all endpoints
- CORS enabled for cross-origin requests
- Helmet.js for security headers

## License

MIT License
