const cors = require('cors');

const corsMiddleware = cors({
    origin: true,  // Permite CUALQUIER origen
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
    exposedHeaders: ['X-Total-Count'],
    credentials: true,
    maxAge: 86400
});

module.exports = corsMiddleware;