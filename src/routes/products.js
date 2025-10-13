const express = require('express');
const router = express.Router();
const ProductService = require('../services/ProductService');

// GET /api/products - Get all bio products
router.get('/', (req, res) => {
  try {
    let products = ProductService.getAllProducts();
    
    // Filter by category if specified
    if (req.query.category) {
      products = ProductService.getProductsByCategory(req.query.category);
    }
    
    // Search by name if specified
    if (req.query.search) {
      products = ProductService.searchProducts(req.query.search);
    }
    
    // Filter by excluded allergens
    if (req.query.excludeAllergens) {
      const excludeAllergens = Array.isArray(req.query.excludeAllergens)
        ? req.query.excludeAllergens
        : [req.query.excludeAllergens];
      products = ProductService.getProductsWithoutAllergens(excludeAllergens);
    }
    
    res.json({
      success: true,
      count: products.length,
      data: products
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// GET /api/products/:id - Get product by ID
router.get('/:id', (req, res) => {
  try {
    const product = ProductService.getProductById(req.params.id);
    if (!product) {
      return res.status(404).json({
        success: false,
        error: 'Produkt nicht gefunden'
      });
    }
    
    res.json({
      success: true,
      data: product
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// GET /api/products/categories - Get all product categories
router.get('/meta/categories', (req, res) => {
  try {
    const categories = ProductService.getCategories();
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

// GET /api/products/allergens - Get all allergens
router.get('/meta/allergens', (req, res) => {
  try {
    const allergens = ProductService.getAllergens();
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

// GET /api/products/recommendations - Get product recommendations
router.get('/meta/recommendations', (req, res) => {
  try {
    const goals = req.query.goals 
      ? (Array.isArray(req.query.goals) ? req.query.goals : [req.query.goals])
      : [];
    
    const recommendations = ProductService.getRecommendations(goals);
    res.json({
      success: true,
      data: recommendations
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

module.exports = router;