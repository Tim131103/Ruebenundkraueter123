const express = require('express');
const cors = require('cors');
const path = require('path');

const recipeRoutes = require('./routes/recipes');
const productRoutes = require('./routes/products');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, '../public')));

// Routes
app.use('/api/recipes', recipeRoutes);
app.use('/api/products', productRoutes);

// Serve index page
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, '../public/index.html'));
});

app.listen(PORT, () => {
  console.log(`Recipe Service Server läuft auf Port ${PORT}`);
  console.log(`Öffne http://localhost:${PORT} für die Web-Oberfläche`);
});

module.exports = app;