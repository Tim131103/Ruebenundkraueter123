const bioProducts = require('../data/bioProducts');

class ProductService {
  
  // Get all bio products
  static getAllProducts() {
    return bioProducts;
  }
  
  // Get product by ID
  static getProductById(id) {
    return bioProducts.find(product => product.id === parseInt(id));
  }
  
  // Get products by category
  static getProductsByCategory(category) {
    return bioProducts.filter(product => 
      product.category.toLowerCase() === category.toLowerCase()
    );
  }
  
  // Search products by name
  static searchProducts(searchTerm) {
    const term = searchTerm.toLowerCase();
    return bioProducts.filter(product => 
      product.name.toLowerCase().includes(term)
    );
  }
  
  // Get products without specific allergens
  static getProductsWithoutAllergens(excludeAllergens) {
    if (!excludeAllergens || excludeAllergens.length === 0) {
      return bioProducts;
    }
    
    return bioProducts.filter(product => 
      !excludeAllergens.some(allergen => 
        product.allergens.includes(allergen)
      )
    );
  }
  
  // Get all available categories
  static getCategories() {
    const categoriesSet = new Set();
    bioProducts.forEach(product => {
      categoriesSet.add(product.category);
    });
    return Array.from(categoriesSet).sort();
  }
  
  // Get all allergens present in products
  static getAllergens() {
    const allergensSet = new Set();
    bioProducts.forEach(product => {
      product.allergens.forEach(allergen => {
        allergensSet.add(allergen);
      });
    });
    return Array.from(allergensSet).sort();
  }
  
  // Get product recommendations based on nutritional goals
  static getRecommendations(goals = []) {
    if (goals.includes('high-protein')) {
      return bioProducts.filter(product => 
        product.nutritionalInfo && 
        product.nutritionalInfo.protein && 
        product.nutritionalInfo.protein > 15
      );
    }
    
    if (goals.includes('low-carb')) {
      return bioProducts.filter(product => 
        product.nutritionalInfo && 
        product.nutritionalInfo.carbs && 
        product.nutritionalInfo.carbs < 20
      );
    }
    
    return bioProducts;
  }
}

module.exports = ProductService;