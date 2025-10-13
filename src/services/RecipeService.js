const { RecipeBox } = require('../models');
const bioProducts = require('../data/bioProducts');
const recipes = require('../data/recipes');

class RecipeService {
  
  // Get all recipes with optional filtering
  static getRecipes(filters = {}) {
    let filteredRecipes = [...recipes];
    
    // Filter by dietary categories
    if (filters.dietaryCategories && filters.dietaryCategories.length > 0) {
      filteredRecipes = filteredRecipes.filter(recipe => 
        filters.dietaryCategories.some(category => 
          recipe.dietaryCategories.includes(category)
        )
      );
    }
    
    // Filter by excluded allergens
    if (filters.excludeAllergens && filters.excludeAllergens.length > 0) {
      filteredRecipes = filteredRecipes.filter(recipe => 
        !filters.excludeAllergens.some(allergen => 
          recipe.allergens.includes(allergen)
        )
      );
    }
    
    // Filter by maximum cooking time
    if (filters.maxCookingTime) {
      filteredRecipes = filteredRecipes.filter(recipe => 
        recipe.cookingTime <= filters.maxCookingTime
      );
    }
    
    // Filter by servings
    if (filters.servings) {
      filteredRecipes = filteredRecipes.filter(recipe => 
        recipe.servings >= filters.servings
      );
    }
    
    return filteredRecipes;
  }
  
  // Get recipe by ID
  static getRecipeById(id) {
    return recipes.find(recipe => recipe.id === parseInt(id));
  }
  
  // Generate recipe box for a specific recipe
  static generateRecipeBox(recipeId, servingAdjustment = 1) {
    const recipe = this.getRecipeById(recipeId);
    if (!recipe) {
      throw new Error('Rezept nicht gefunden');
    }
    
    const boxProducts = recipe.ingredients.map(ingredient => {
      const product = bioProducts.find(p => p.id === ingredient.productId);
      if (!product) {
        throw new Error(`Produkt mit ID ${ingredient.productId} nicht gefunden`);
      }
      
      const adjustedQuantity = ingredient.quantity * servingAdjustment;
      
      return {
        product: product,
        quantity: adjustedQuantity,
        unit: ingredient.unit || product.unit,
        originalQuantity: ingredient.quantity
      };
    });
    
    // Calculate estimated price (mock calculation)
    const totalPrice = this.calculateBoxPrice(boxProducts);
    
    return new RecipeBox(
      recipe.id,
      recipe.name,
      boxProducts,
      totalPrice
    );
  }
  
  // Calculate estimated price for recipe box
  static calculateBoxPrice(products) {
    // Mock price calculation - in real app, this would use actual product prices
    let totalPrice = 0;
    
    products.forEach(item => {
      const basePrice = this.getBasePrice(item.product);
      const quantity = item.quantity;
      const unitPrice = basePrice * (quantity / 100); // Price per 100g/ml
      totalPrice += unitPrice;
    });
    
    return Math.round(totalPrice * 100) / 100; // Round to 2 decimal places
  }
  
  // Get base price for product (mock data)
  static getBasePrice(product) {
    const priceMap = {
      'Gemüse': 2.50,
      'Obst': 3.00,
      'Getreide': 4.00,
      'Hülsenfrüchte': 5.00,
      'Nüsse': 8.00,
      'Samen': 6.00,
      'Öl': 12.00,
      'Kräuter': 15.00,
      'Gewürze': 20.00,
      'Milchprodukte': 6.00,
      'Milchalternativen': 3.50,
      'Sauce': 4.50,
      'Essig': 5.00,
      'Süßungsmittel': 7.00,
      'Brühe': 3.00
    };
    
    return priceMap[product.category] || 5.00;
  }
  
  // Get available dietary categories
  static getDietaryCategories() {
    const categoriesSet = new Set();
    recipes.forEach(recipe => {
      recipe.dietaryCategories.forEach(category => {
        categoriesSet.add(category);
      });
    });
    return Array.from(categoriesSet);
  }
  
  // Get all allergens present in recipes
  static getAllergens() {
    const allergensSet = new Set();
    recipes.forEach(recipe => {
      recipe.allergens.forEach(allergen => {
        allergensSet.add(allergen);
      });
    });
    return Array.from(allergensSet);
  }
  
  // Get recipe suggestions based on available products
  static getRecipeSuggestions(availableProductIds) {
    return recipes.filter(recipe => {
      const requiredProductIds = recipe.ingredients.map(ing => ing.productId);
      return requiredProductIds.every(id => availableProductIds.includes(id));
    });
  }
}

module.exports = RecipeService;