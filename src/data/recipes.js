const { Recipe, DIETARY_CATEGORIES, ALLERGENS } = require('../models');

// Sample Recipes using Bio-Products
const recipes = [
  new Recipe(
    1,
    'Quinoa-Gemüse-Bowl',
    'Eine nährstoffreiche Bowl mit buntem Gemüse und Quinoa',
    [
      { productId: 13, quantity: 200, unit: 'g' }, // Bio-Quinoa
      { productId: 1, quantity: 150, unit: 'g' },  // Bio-Karotten
      { productId: 6, quantity: 200, unit: 'g' },  // Bio-Brokkoli
      { productId: 12, quantity: 1, unit: 'Stück' }, // Bio-Avocado
      { productId: 23, quantity: 30, unit: 'ml' },  // Bio-Olivenöl
      { productId: 11, quantity: 0.5, unit: 'Stück' }, // Bio-Zitronen
      { productId: 19, quantity: 50, unit: 'g' }    // Bio-Mandeln
    ],
    [
      'Quinoa nach Packungsanweisung kochen',
      'Karotten und Brokkoli dämpfen',
      'Avocado in Würfel schneiden',
      'Mandeln rösten',
      'Alles in einer Bowl anrichten',
      'Mit Olivenöl und Zitrone beträufeln'
    ],
    2,
    [DIETARY_CATEGORIES.VEGETARIAN, DIETARY_CATEGORIES.VEGAN, DIETARY_CATEGORIES.GLUTEN_FREE],
    25
  ),

  new Recipe(
    2,
    'Rote Linsen-Curry',
    'Würziges Curry mit roten Linsen und Kokosmilch',
    [
      { productId: 16, quantity: 250, unit: 'g' }, // Bio-Linsen rot
      { productId: 34, quantity: 400, unit: 'ml' }, // Bio-Kokosmilch
      { productId: 2, quantity: 100, unit: 'g' },  // Bio-Zwiebeln
      { productId: 3, quantity: 300, unit: 'g' },  // Bio-Tomaten
      { productId: 27, quantity: 15, unit: 'g' },  // Bio-Knoblauch
      { productId: 28, quantity: 20, unit: 'g' },  // Bio-Ingwer
      { productId: 29, quantity: 5, unit: 'g' },   // Bio-Kurkuma
      { productId: 30, quantity: 5, unit: 'g' },   // Bio-Kreuzkümmel
      { productId: 23, quantity: 25, unit: 'ml' }, // Bio-Olivenöl
      { productId: 7, quantity: 100, unit: 'g' }   // Bio-Spinat
    ],
    [
      'Zwiebeln, Knoblauch und Ingwer fein hacken',
      'In Olivenöl anschwitzen',
      'Gewürze hinzufügen und kurz rösten',
      'Tomaten und Linsen dazugeben',
      'Mit Kokosmilch ablöschen',
      '20 Minuten köcheln lassen',
      'Spinat unterrühren'
    ],
    4,
    [DIETARY_CATEGORIES.VEGETARIAN, DIETARY_CATEGORIES.VEGAN, DIETARY_CATEGORIES.GLUTEN_FREE],
    30
  ),

  new Recipe(
    3,
    'Mediterraner Quinoa-Salat',
    'Frischer Salat mit Quinoa, Gemüse und Mozzarella',
    [
      { productId: 13, quantity: 150, unit: 'g' }, // Bio-Quinoa
      { productId: 3, quantity: 200, unit: 'g' },  // Bio-Tomaten
      { productId: 4, quantity: 150, unit: 'g' },  // Bio-Paprika
      { productId: 5, quantity: 200, unit: 'g' },  // Bio-Zucchini
      { productId: 31, quantity: 150, unit: 'g' }, // Bio-Mozzarella
      { productId: 25, quantity: 20, unit: 'g' },  // Bio-Basilikum
      { productId: 23, quantity: 40, unit: 'ml' }, // Bio-Olivenöl
      { productId: 37, quantity: 20, unit: 'ml' }, // Bio-Balsamico
      { productId: 21, quantity: 15, unit: 'g' }   // Bio-Sesam
    ],
    [
      'Quinoa kochen und abkühlen lassen',
      'Gemüse in kleine Würfel schneiden',
      'Mozzarella zerteilen',
      'Basilikum hacken',
      'Dressing aus Olivenöl und Balsamico mischen',
      'Alle Zutaten vermengen',
      'Mit Sesam bestreuen'
    ],
    3,
    [DIETARY_CATEGORIES.VEGETARIAN, DIETARY_CATEGORIES.GLUTEN_FREE],
    20
  ),

  new Recipe(
    4,
    'Vegane Buddha Bowl',
    'Ausgewogene Bowl mit Hülsenfrüchten und geröstetem Gemüse',
    [
      { productId: 17, quantity: 200, unit: 'g' }, // Bio-Kichererbsen
      { productId: 8, quantity: 300, unit: 'g' },  // Bio-Kartoffeln
      { productId: 1, quantity: 200, unit: 'g' },  // Bio-Karotten
      { productId: 6, quantity: 250, unit: 'g' },  // Bio-Brokkoli
      { productId: 12, quantity: 1, unit: 'Stück' }, // Bio-Avocado
      { productId: 20, quantity: 40, unit: 'g' },  // Bio-Walnüsse
      { productId: 23, quantity: 35, unit: 'ml' }, // Bio-Olivenöl
      { productId: 29, quantity: 8, unit: 'g' },   // Bio-Kurkuma
      { productId: 26, quantity: 15, unit: 'g' }   // Bio-Petersilie
    ],
    [
      'Kichererbsen über Nacht einweichen und kochen',
      'Kartoffeln und Karotten würfeln',
      'Gemüse mit Olivenöl und Kurkuma marinieren',
      'Im Ofen bei 200°C 25 Min rösten',
      'Brokkoli separat dämpfen',
      'Avocado schneiden, Walnüsse hacken',
      'Alles in Bowls anrichten',
      'Mit Petersilie garnieren'
    ],
    2,
    [DIETARY_CATEGORIES.VEGETARIAN, DIETARY_CATEGORIES.VEGAN, DIETARY_CATEGORIES.GLUTEN_FREE],
    45
  ),

  new Recipe(
    5,
    'Geröstetes Gemüse mit Quinoa',
    'Buntes Ofengemüse auf Quinoa-Bett',
    [
      { productId: 13, quantity: 180, unit: 'g' }, // Bio-Quinoa
      { productId: 4, quantity: 200, unit: 'g' },  // Bio-Paprika
      { productId: 5, quantity: 250, unit: 'g' },  // Bio-Zucchini
      { productId: 2, quantity: 150, unit: 'g' },  // Bio-Zwiebeln
      { productId: 32, quantity: 50, unit: 'g' },  // Bio-Parmesan
      { productId: 23, quantity: 30, unit: 'ml' }, // Bio-Olivenöl
      { productId: 25, quantity: 10, unit: 'g' },  // Bio-Basilikum
      { productId: 27, quantity: 10, unit: 'g' }   // Bio-Knoblauch
    ],
    [
      'Quinoa nach Anweisung zubereiten',
      'Gemüse in große Stücke schneiden',
      'Mit Olivenöl, Knoblauch und Gewürzen marinieren',
      'Bei 220°C 20-25 Min rösten',
      'Quinoa als Basis in Teller geben',
      'Geröstetes Gemüse darauf anrichten',
      'Mit Parmesan und Basilikum garnieren'
    ],
    3,
    [DIETARY_CATEGORIES.VEGETARIAN, DIETARY_CATEGORIES.GLUTEN_FREE],
    35
  ),

  new Recipe(
    6,
    'Grüner Smoothie-Bowl',
    'Nährstoffreiche Bowl mit grünem Gemüse und Früchten',
    [
      { productId: 7, quantity: 100, unit: 'g' },  // Bio-Spinat
      { productId: 10, quantity: 2, unit: 'Stück' }, // Bio-Bananen
      { productId: 12, quantity: 0.5, unit: 'Stück' }, // Bio-Avocado
      { productId: 35, quantity: 200, unit: 'ml' }, // Bio-Mandelmilch
      { productId: 14, quantity: 50, unit: 'g' },  // Bio-Haferflocken
      { productId: 22, quantity: 15, unit: 'g' },  // Bio-Leinsamen
      { productId: 19, quantity: 30, unit: 'g' },  // Bio-Mandeln
      { productId: 39, quantity: 15, unit: 'ml' }  // Bio-Agavendicksaft
    ],
    [
      'Spinat, Banane, Avocado und Mandelmilch mixen',
      'Agavendicksaft nach Geschmack hinzufügen',
      'In Bowl füllen',
      'Mit Haferflocken bestreuen',
      'Mandeln grob hacken und darüber geben',
      'Mit Leinsamen garnieren'
    ],
    1,
    [DIETARY_CATEGORIES.VEGETARIAN, DIETARY_CATEGORIES.VEGAN],
    10
  )
];

// Update allergens for each recipe based on ingredients
recipes.forEach(recipe => {
  recipe.allergens = calculateRecipeAllergens(recipe);
});

function calculateRecipeAllergens(recipe) {
  const bioProducts = require('./bioProducts');
  const allergens = new Set();
  
  recipe.ingredients.forEach(ingredient => {
    const product = bioProducts.find(p => p.id === ingredient.productId);
    if (product && product.allergens) {
      product.allergens.forEach(allergen => allergens.add(allergen));
    }
  });
  
  return Array.from(allergens);
}

module.exports = recipes;