const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const config = require('../config');

const router = express.Router();

// Configuración común para todos los proxies
const proxyOptions = {
  changeOrigin: true,
  followRedirects: true,
  proxyTimeout: 60000,
  timeout: 60000,

  onError: (err, req, res) => {
    console.error('[Proxy Error]', err.message);

    res.status(503).json({
      error: 'Servicio no disponible'
    });
  },

  onProxyReq: (proxyReq, req, res) => {
    console.log(`[Proxy] ${req.method} ${req.url}`);
  }
};


// Proxy para inventory
const inventoryProxy = createProxyMiddleware({
  ...proxyOptions,
  target: `http://${config.services.inventory.host}:${config.services.inventory.port}`,
  pathRewrite: { '^/api/v1/inventory': '/api/v1' }
});

// Proxy para security
const securityProxy = createProxyMiddleware({
  ...proxyOptions,
  target: `http://${config.services.security.host}:${config.services.security.port}`,
  pathRewrite: { '^/api/v1/security': '/api/v1' }
});

// Proxy para payment
const paymentProxy = createProxyMiddleware({
  ...proxyOptions,
  target: `http://${config.services.payment.host}:${config.services.payment.port}`,
  pathRewrite: { '^/api/v1/payment': '/api/v1' }
});

// Proxy para promociones con manejo de body
const promocionesProxy = createProxyMiddleware({
    target: `http://${config.services.inventory.host}:${config.services.inventory.port}`,
    changeOrigin: true,
    pathRewrite: {
        '^/api/v1/promociones': '/api/v1/promociones'
    },
    onProxyReq: (proxyReq, req, res) => {
        console.log(`[PROXY] ${req.method} ${req.url} -> promociones`);
        
        // Manejar el body para POST y PUT
        if (req.body && Object.keys(req.body).length) {
            const bodyData = JSON.stringify(req.body);
            proxyReq.setHeader('Content-Type', 'application/json');
            proxyReq.setHeader('Content-Length', Buffer.byteLength(bodyData));
            proxyReq.write(bodyData);
        }
    },
    onError: (err, req, res) => {
        console.error('Error en promociones:', err.message);
        res.status(503).json({ error: 'Promociones Service no disponible' });
    }
});

// Proxy para uploads de imágenes
const uploadsProxy = createProxyMiddleware({
  target: `http://${config.services.inventory.host}:${config.services.inventory.port}`,
  changeOrigin: true
});

// Aplicar proxies
router.use('/inventory', inventoryProxy);
router.use('/security', securityProxy);
router.use('/payment', paymentProxy);
router.use('/promociones', promocionesProxy);
router.use('/uploads', uploadsProxy);

// Health checks directos
router.get('/health/inventory', async (req, res) => {
  try {
    const url = `http://${config.services.inventory.host}:${config.services.inventory.port}/api/v1/health`;
    const response = await fetch(url);
    const data = await response.json();
    res.json({ ...data, service: 'inventory' });
  } catch (error) {
    res.status(503).json({ status: 'DOWN', service: 'inventory', error: error.message });
  }
});

router.get('/health/security', async (req, res) => {
  try {
    const url = `http://${config.services.security.host}:${config.services.security.port}/api/v1/health`;
    const response = await fetch(url);
    const data = await response.json();
    res.json({ ...data, service: 'security' });
  } catch (error) {
    res.status(503).json({ status: 'DOWN', service: 'security', error: error.message });
  }
});

router.get('/health/payment', async (req, res) => {
  try {
    const url = `http://${config.services.payment.host}:${config.services.payment.port}/api/v1/health`;
    const response = await fetch(url);
    const data = await response.json();
    res.json({ ...data, service: 'payment' });
  } catch (error) {
    res.status(503).json({ status: 'DOWN', service: 'payment', error: error.message });
  }
});

router.get('/health/all', async (req, res) => {
  const services = ['inventory', 'security', 'payment'];
  const results = {};
  
  for (const service of services) {
    try {
      const url = `http://${config.services[service].host}:${config.services[service].port}/api/v1/health`;
      const response = await fetch(url);
      results[service] = await response.json();
    } catch (error) {
      results[service] = { status: 'DOWN', error: error.message };
    }
  }
  
  res.json({
    timestamp: new Date().toISOString(),
    services: results
  });
});

module.exports = router;