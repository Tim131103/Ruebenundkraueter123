const { BioProduct, ALLERGENS } = require('../models');

// Sample Bio-Products Portfolio
const bioProducts = [
  // Gemüse
  new BioProduct(1, 'Bio-Karotten', 'Gemüse', 'g'),
  new BioProduct(2, 'Bio-Zwiebeln', 'Gemüse', 'g'),
  new BioProduct(3, 'Bio-Tomaten', 'Gemüse', 'g'),
  new BioProduct(4, 'Bio-Paprika', 'Gemüse', 'g'),
  new BioProduct(5, 'Bio-Zucchini', 'Gemüse', 'g'),
  new BioProduct(6, 'Bio-Brokkoli', 'Gemüse', 'g'),
  new BioProduct(7, 'Bio-Spinat', 'Gemüse', 'g'),
  new BioProduct(8, 'Bio-Kartoffeln', 'Gemüse', 'g'),

  // Obst
  new BioProduct(9, 'Bio-Äpfel', 'Obst', 'g'),
  new BioProduct(10, 'Bio-Bananen', 'Obst', 'g'),
  new BioProduct(11, 'Bio-Zitronen', 'Obst', 'Stück'),
  new BioProduct(12, 'Bio-Avocado', 'Obst', 'Stück'),

  // Getreide & Hülsenfrüchte
  new BioProduct(13, 'Bio-Quinoa', 'Getreide', 'g', [], { protein: 14.1, carbs: 58.5 }),
  new BioProduct(14, 'Bio-Haferflocken', 'Getreide', 'g', [ALLERGENS.GLUTEN]),
  new BioProduct(15, 'Bio-Vollkornreis', 'Getreide', 'g'),
  new BioProduct(16, 'Bio-Linsen rot', 'Hülsenfrüchte', 'g', [], { protein: 23.5 }),
  new BioProduct(17, 'Bio-Kichererbsen', 'Hülsenfrüchte', 'g', [], { protein: 19.3 }),
  new BioProduct(18, 'Bio-Kidneybohnen', 'Hülsenfrüchte', 'g', [], { protein: 22.5 }),

  // Nüsse & Samen
  new BioProduct(19, 'Bio-Mandeln', 'Nüsse', 'g', [ALLERGENS.NUTS]),
  new BioProduct(20, 'Bio-Walnüsse', 'Nüsse', 'g', [ALLERGENS.NUTS]),
  new BioProduct(21, 'Bio-Sesam', 'Samen', 'g', [ALLERGENS.SESAME]),
  new BioProduct(22, 'Bio-Leinsamen', 'Samen', 'g'),

  // Gewürze & Kräuter
  new BioProduct(23, 'Bio-Olivenöl', 'Öl', 'ml'),
  new BioProduct(24, 'Bio-Kokosnussöl', 'Öl', 'ml'),
  new BioProduct(25, 'Bio-Basilikum', 'Kräuter', 'g'),
  new BioProduct(26, 'Bio-Petersilie', 'Kräuter', 'g'),
  new BioProduct(27, 'Bio-Knoblauch', 'Gewürze', 'g'),
  new BioProduct(28, 'Bio-Ingwer', 'Gewürze', 'g'),
  new BioProduct(29, 'Bio-Kurkuma', 'Gewürze', 'g'),
  new BioProduct(30, 'Bio-Kreuzkümmel', 'Gewürze', 'g'),

  // Milchprodukte (Bio)
  new BioProduct(31, 'Bio-Mozzarella', 'Milchprodukte', 'g', [ALLERGENS.LACTOSE]),
  new BioProduct(32, 'Bio-Parmesan', 'Milchprodukte', 'g', [ALLERGENS.LACTOSE]),
  new BioProduct(33, 'Bio-Sahne', 'Milchprodukte', 'ml', [ALLERGENS.LACTOSE]),

  // Weitere
  new BioProduct(34, 'Bio-Kokosmilch', 'Milchalternativen', 'ml'),
  new BioProduct(35, 'Bio-Mandelmilch', 'Milchalternativen', 'ml', [ALLERGENS.NUTS]),
  new BioProduct(36, 'Bio-Sojasauce', 'Sauce', 'ml', [ALLERGENS.SOY, ALLERGENS.GLUTEN]),
  new BioProduct(37, 'Bio-Balsamico', 'Essig', 'ml'),
  new BioProduct(38, 'Bio-Honig', 'Süßungsmittel', 'ml'),
  new BioProduct(39, 'Bio-Agavendicksaft', 'Süßungsmittel', 'ml'),
  new BioProduct(40, 'Bio-Gemüsebrühe', 'Brühe', 'ml')
];

module.exports = bioProducts;