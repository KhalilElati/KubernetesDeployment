const express = require('express');
const app = express();
const axios = require('axios');
const port = 3000;

app.use((req, res, next) => {
  res.setHeader('Connection', 'keep-alive');
  res.setHeader('Keep-Alive', 'timeout=30');
  next();
});
app.get('/', async (req, res) => {
  try {
    const response = await axios.get('http://backend:5000');
    res.send(`Frontend here! Message from backend: ${response.data}`);
  } catch (error) {
    res.send('Error connecting to backend');
  }
});

app.listen(port, () => {
  console.log(`Frontend app listening at http://localhost:${port}`);
});

app.keepAliveTimeout = 61 * 1000;
app.headersTimeout = 35 * 1000; 