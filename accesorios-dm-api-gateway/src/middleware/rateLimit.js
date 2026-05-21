const rateLimit = require('express-rate-limit');

const getConfig = () => {
    const env = process.env.NODE_ENV || 'development';
    
    if (env === 'production') {
        // PROD: límite estricto
        return { windowMs: 15 * 60 * 1000, max: 100 }; // 100 peticiones cada 15 min
    }
    if (env === 'qa') {
        return { windowMs: 5 * 60 * 1000, max: 50 };
    }
    // development
    return { windowMs: 60 * 1000, max: 1000 };
};

const rateLimitMiddleware = rateLimit({
    ...getConfig(),
    message: { error: 'Demasiadas peticiones, intenta más tarde' },
    standardHeaders: true,
    legacyHeaders: false,
    skip: (req) => req.url.includes('/health')
});

const authRateLimit = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutos para PROD
    max: 10, // máximo 10 intentos de login
    message: { error: 'Demasiados intentos de login, espera 15 minutos' },
    standardHeaders: true,
    skipSuccessfulRequests: true
});

module.exports = { rateLimitMiddleware, authRateLimit };