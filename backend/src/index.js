require('dotenv').config({ path: require('path').join(__dirname, '..', '..', '.env') });
const express = require('express');

const app = express();
app.use(express.json());

// Ruta de prueba del Sprint 1
app.get('/api/estado', (req, res) => {
  res.json({ ok: true });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Servidor escuchando en http://localhost:${PORT}`);
});