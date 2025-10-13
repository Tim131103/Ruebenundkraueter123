const express = require('express');
const router = express.Router();
const RecipeService = require('../services/RecipeService');

// GET /api/recipes - Get all recipes with optional filtering
router.get('/', (req, res) => {
  try {
    const filters = {};
    
    // Parse query parameters
    if (req.query.dietaryCategories) {
      filters.dietaryCategories = Array.isArray(req.query.dietaryCategories) 
        ? req.query.dietaryCategories 
        : [req.query.dietaryCategories];
    }
    
    if (req.query.excludeAllergens) {
      filters.excludeAllergens = Array.isArray(req.query.excludeAllergens)
        ? req.query.excludeAllergens
        : [req.query.excludeAllergens];
    }
    
    if (req.query.maxCookingTime) {
      filters.maxCookingTime = parseInt(req.query.maxCookingTime);
    }
    
    if (req.query.servings) {
      filters.servings = parseInt(req.query.servings);
    }
    
    const recipes = RecipeService.getRecipes(filters);
    res.json({
      success: true,
      count: recipes.length,
      data: recipes
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// GET /api/recipes/:id - Get recipe by ID
router.get('/:id', (req, res) => {
  try {
    const recipe = RecipeService.getRecipeById(req.params.id);
    if (!recipe) {
      return res.status(404).json({
        success: false,
        error: 'Rezept nicht gefunden'
      });
    }
    
    res.json({
      success: true,
      data: recipe
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// GET /api/recipes/:id/box - Generate recipe box for recipe
router.get('/:id/box', (req, res) => {
  try {
    const servingAdjustment = req.query.servings ? 
      parseFloat(req.query.servings) : 1;
    
    const recipeBox = RecipeService.generateRecipeBox(
      req.params.id, 
      servingAdjustment
    );
    
    res.json({
      success: true,
      data: recipeBox
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      error: error.message
    });
  }
});

// GET /api/recipes/dietary-categories - Get available dietary categories
router.get('/meta/dietary-categories', (req, res) => {
  try {
    const categories = RecipeService.getDietaryCategories();
    res.json({
      success: true,
      data: categories
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// GET /api/recipes/allergens - Get all allergens
router.get('/meta/allergens', (req, res) => {
  try {
    const allergens = RecipeService.getAllergens();
    res.json({
      success: true,
      data: allergens
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// GET /api/recipes/suggestions - Get recipe suggestions based on available products
router.get('/meta/suggestions', (req, res) => {
  try {
    const productIds = req.query.products 
      ? req.query.products.split(',').map(id => parseInt(id))
      : [];
    
    const suggestions = RecipeService.getRecipeSuggestions(productIds);
    res.json({
      success: true,
      data: suggestions
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

module.exports = router;