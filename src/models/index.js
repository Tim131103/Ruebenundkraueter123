// Data models for the recipe service

// Bio-Food Product Model
class BioProduct {
  constructor(id, name, category, unit, allergens = [], nutritionalInfo = {}) {
    this.id = id;
    this.name = name;
    this.category = category; // e.g., 'Gemüse', 'Obst', 'Getreide', 'Hülsenfrüchte'
    this.unit = unit; // e.g., 'g', 'ml', 'Stück'
    this.allergens = allergens; // Array of allergen types
    this.nutritionalInfo = nutritionalInfo;
    this.isBio = true;
  }
}

// Recipe Model
class Recipe {
  constructor(id, name, description, ingredients, instructions, servings, dietaryCategories = [], cookingTime = 0) {
    this.id = id;
    this.name = name;
    this.description = description;
    this.ingredients = ingredients; // Array of {productId, quantity, unit}
    this.instructions = instructions; // Array of cooking steps
    this.servings = servings;
    this.dietaryCategories = dietaryCategories; // e.g., ['vegetarian', 'gluten-free']
    this.cookingTime = cookingTime; // in minutes
    this.allergens = this.calculateAllergens();
  }

  calculateAllergens() {
    // This would calculate allergens based on ingredients
    // For now, we'll set it during recipe creation
    return [];
  }
}

// Recipe Box Model
class RecipeBox {
  constructor(recipeId, recipeName, products, totalPrice = 0) {
    this.recipeId = recipeId;
    this.recipeName = recipeName;
    this.products = products; // Array of {product, quantity, unit}
    this.totalPrice = totalPrice;
    this.createdAt = new Date();
  }
}

// Dietary Categories
const DIETARY_CATEGORIES = {
  VEGETARIAN: 'vegetarisch',
  VEGAN: 'vegan',
  GLUTEN_FREE: 'glutenfrei',
  LACTOSE_FREE: 'laktosefrei',
  LOW_CARB: 'kohlenhydratarm',
  KETO: 'ketogen',
  PALEO: 'paleo'
};

// Common Allergens
const ALLERGENS = {
  GLUTEN: 'Gluten',
  LACTOSE: 'Laktose',
  NUTS: 'Nüsse',
  SOY: 'Soja',
  EGGS: 'Eier',
  FISH: 'Fisch',
  SHELLFISH: 'Schalentiere',
  SESAME: 'Sesam'
};

module.exports = {
  BioProduct,
  Recipe,
  RecipeBox,
  DIETARY_CATEGORIES,
  ALLERGENS
};