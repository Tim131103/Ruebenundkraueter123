# 🥬 Rüben & Kräuter - Bio-Rezept-Service

Ein vollständiger Rezept-Service mit personalisierten Rezept-Boxen für Bio-Lebensmittel. Ermöglicht das Filtern von Rezepten nach Ernährungskategorien und Allergen-Einschränkungen.

## ✨ Funktionen

### 🍽️ Rezept-Management
- **Umfangreiche Rezept-Datenbank** mit Bio-Lebensmitteln
- **Intelligente Filterung** nach:
  - Ernährungskategorien (vegetarisch, vegan, glutenfrei, etc.)
  - Allergenen und Unverträglichkeiten
  - Zubereitungszeit
  - Portionsanzahl

### 📦 Rezept-Boxen
- **Automatische Box-Generierung** basierend auf Rezept-Zutaten
- **Mengenanpassung** je nach gewünschter Portionsanzahl
- **Preisberechnung** für komplette Rezept-Boxen
- **Bio-Produktportfolio** mit über 40 Produkten

### 🌱 Bio-Produkt-Portfolio
- Gemüse (Karotten, Zwiebeln, Tomaten, Paprika, etc.)
- Obst (Äpfel, Bananen, Avocados, etc.)
- Getreide & Hülsenfrüchte (Quinoa, Linsen, Kichererbsen, etc.)
- Nüsse & Samen (Mandeln, Walnüsse, Leinsamen, etc.)
- Gewürze & Kräuter (Basilikum, Kurkuma, Ingwer, etc.)
- Milchprodukte & Alternativen

## 🚀 Installation & Nutzung

### Voraussetzungen
- Node.js (Version 14 oder höher)
- npm oder yarn

### Installation
```bash
# Repository klonen
git clone https://github.com/Tim131103/R-ben-Kr-uter.git
cd R-ben-Kr-uter

# Abhängigkeiten installieren
npm install

# Server starten
npm start
```

### Server starten
```bash
# Produktionsserver
npm start

# Entwicklungsserver
npm run dev
```

Der Service ist dann unter http://localhost:3000 verfügbar.

## 📱 Web-Interface

Das Web-Interface bietet:
- **Responsive Design** für Desktop und Mobile
- **Filteroptionen** für personalisierte Rezeptsuche
- **Detailansichten** für Rezepte mit Zubereitungsschritten
- **Rezept-Box-Generator** mit Preisberechnung
- **Allergen-Kennzeichnung** für alle Produkte

## 🔌 API-Dokumentation

### Rezepte

#### Alle Rezepte abrufen
```
GET /api/recipes
```

**Query-Parameter:**
- `dietaryCategories`: Ernährungskategorien filtern (z.B. "vegan", "vegetarisch")
- `excludeAllergens`: Allergene ausschließen (z.B. "Nüsse", "Gluten")
- `maxCookingTime`: Maximale Zubereitungszeit in Minuten
- `servings`: Mindestanzahl Portionen

**Beispiel:**
```bash
curl "http://localhost:3000/api/recipes?dietaryCategories=vegan&excludeAllergens=Nüsse"
```

#### Einzelnes Rezept abrufen
```
GET /api/recipes/:id
```

#### Rezept-Box generieren
```
GET /api/recipes/:id/box?servings=2
```

### Produkte

#### Alle Bio-Produkte abrufen
```
GET /api/products
```

**Query-Parameter:**
- `category`: Nach Kategorie filtern
- `search`: Produktsuche nach Name
- `excludeAllergens`: Allergene ausschließen

#### Einzelnes Produkt abrufen
```
GET /api/products/:id
```

### Meta-Daten

```
GET /api/recipes/meta/dietary-categories  # Verfügbare Ernährungskategorien
GET /api/recipes/meta/allergens          # Alle Allergene
GET /api/products/meta/categories        # Produktkategorien
```

## 🏗️ Architektur

### Backend-Struktur
```
src/
├── data/           # Beispiel-Daten für Bio-Produkte und Rezepte
├── models/         # Datenmodelle (BioProduct, Recipe, RecipeBox)
├── services/       # Business-Logic (RecipeService, ProductService)
├── routes/         # API-Routen
└── server.js       # Express-Server
```

### Datenmodelle

#### BioProduct
- ID, Name, Kategorie
- Allergene und Nährwertinformationen
- Bio-Zertifizierung

#### Recipe
- Zutaten mit Mengenangaben
- Zubereitungsschritte
- Ernährungskategorien
- Allergen-Berechnung

#### RecipeBox
- Zusammenstellung aller benötigten Produkte
- Mengenanpassung
- Preisberechnung

## 🧪 Funktionale Highlights

### Intelligente Filterung
Das System unterstützt komplexe Filterkriterien:
```javascript
// Vegane Rezepte ohne Nüsse, max. 30 Min Zubereitungszeit
const filters = {
  dietaryCategories: ['vegan'],
  excludeAllergens: ['Nüsse'],
  maxCookingTime: 30
};
```

### Automatische Allergen-Erkennung
Allergene werden automatisch aus den verwendeten Zutaten berechnet:
```javascript
recipe.allergens = calculateRecipeAllergens(recipe);
```

### Dynamische Preisberechnung
Preise werden basierend auf Produktkategorie und Menge berechnet:
```javascript
const totalPrice = RecipeService.calculateBoxPrice(boxProducts);
```

## 🛡️ Sicherheit & Qualität

- **Input-Validierung** für alle API-Parameter
- **Error-Handling** mit aussagekräftigen Fehlermeldungen
- **CORS-Unterstützung** für sichere API-Nutzung
- **Bio-Qualitätssicherung** für alle Produkte

## 🔧 Erweiterungsmöglichkeiten

- **Benutzerkonten** und Favoriten
- **Bestellsystem** für Rezept-Boxen
- **Nährwert-Analyse** für Rezepte
- **Saison-Empfehlungen** für Produkte
- **KI-basierte Rezept-Vorschläge**

## 📄 Lizenz

MIT License - siehe [LICENSE](LICENSE) Datei.

---

**Entwickelt für nachhaltigen und gesunden Lebensstil mit Bio-Lebensmitteln** 🌱