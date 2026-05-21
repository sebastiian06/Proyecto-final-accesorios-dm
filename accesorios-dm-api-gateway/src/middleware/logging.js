const morgan = require('morgan');
const logger = require('../utils/logger');

const morganFormat = ':remote-addr - :method :url :status :response-time ms - :res[content-length]';

const morganMiddleware = morgan(morganFormat, {
    stream: {
        write: (message) => {
            logger.info(message.trim());
        }
    }
});

const requestLogger = (req, res, next) => {
    const start = Date.now();
    
    logger.debug(`[REQUEST] ${req.method} ${req.url} - IP: ${req.ip}`);
    
    const originalSend = res.send;
    res.send = function(data) {
        const duration = Date.now() - start;
        logger.info(`[RESPONSE] ${req.method} ${req.url} - ${res.statusCode} - ${duration}ms`);
        
        if (res.statusCode >= 400) {
            logger.warn(`[ERROR] ${req.method} ${req.url} - ${res.statusCode}`);
        }
        
        originalSend.call(this, data);
    };
    
    next();
};

module.exports = { morganMiddleware, requestLogger };