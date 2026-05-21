const express = require('express');
const helmet = require('helmet');
const compression = require('compression');
const dotenv = require('dotenv');

const config = require('./config');
const apiRoutes = require('./routes');

// Middlewares
const corsMiddleware = require('./middleware/cors');
const { morganMiddleware, requestLogger } = require('./middleware/logging');
const { rateLimitMiddleware } = require('./middleware/rateLimit');
const { notFoundHandler, errorHandler } = require('./middleware/errorHandler');

dotenv.config();

const app = express();
const PORT = config.port;

// ============ MIDDLEWARES GLOBALES ============

// Seguridad - Helmet (configurado para permitir CORS en imágenes)
app.use(helmet({
    crossOriginResourcePolicy: { policy: "cross-origin" }
}));

// Compresión GZIP
app.use(compression());

// CORS
app.use(corsMiddleware);

// Logging con Morgan
app.use(morganMiddleware);
app.use(requestLogger);

// Rate limiting global
app.use(rateLimitMiddleware);

// Parseo de JSON (aumentar límite)
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// ============ HEALTH CHECK DEL GATEWAY ============

app.get('/api/v1/gateway/health', (req, res) => {
    res.json({
        status: 'UP',
        service: 'api-gateway',
        version: '1.0.0',
        environment: config.env,
        timestamp: new Date().toISOString(),
        services: {
            inventory: `http://${config.services.inventory.host}:${config.services.inventory.port}`,
            security: `http://${config.services.security.host}:${config.services.security.port}`,
            payment: `http://${config.services.payment.host}:${config.services.payment.port}`
        }
    });
});

// ============ RUTAS DE LA API ============

app.use('/api/v1', apiRoutes);

// ============ MANEJO DE ERRORES ============

// Ruta 404 - No encontrada
app.use(notFoundHandler);

// Manejador global de errores (debe ir al final)
app.use(errorHandler);

// ============ INICIAR SERVIDOR ============

app.listen(PORT, () => {
    console.log(`========================================`);
    console.log(`API Gateway running on port ${PORT}`);
    console.log(`Environment: ${config.env}`);
    console.log(`========================================`);
    console.log(`Services configured:`);
    console.log(`  Inventory: http://${config.services.inventory.host}:${config.services.inventory.port}`);
    console.log(`  Security: http://${config.services.security.host}:${config.services.security.port}`);
    console.log(`  Payment: http://${config.services.payment.host}:${config.services.payment.port}`);
    console.log(`========================================`);
    console.log(`Endpoints:`);
    console.log(`  Gateway Health: http://localhost:${PORT}/api/v1/gateway/health`);
    console.log(`  All Services Health: http://localhost:${PORT}/api/v1/health/all`);
    console.log(`  Inventory: http://localhost:${PORT}/api/v1/inventory/...`);
    console.log(`  Security: http://localhost:${PORT}/api/v1/security/...`);
    console.log(`  Payment: http://localhost:${PORT}/api/v1/payment/...`);
    console.log(`========================================`);
});