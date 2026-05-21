const logger = require('../utils/logger');

class AppError extends Error {
    constructor(message, statusCode, errorCode = null) {
        super(message);
        this.statusCode = statusCode;
        this.errorCode = errorCode;
        this.isOperational = true;
    }
}

const notFoundHandler = (req, res, next) => {
    next(new AppError(`Ruta no encontrada: ${req.method} ${req.originalUrl}`, 404, 'ROUTE_NOT_FOUND'));
};

const errorHandler = (err, req, res, next) => {
    logger.error({
        message: err.message,
        stack: err.stack,
        url: req.url,
        method: req.method,
        ip: req.ip
    });

    const statusCode = err.statusCode || 500;
    const errorCode = err.errorCode || 'INTERNAL_SERVER_ERROR';

    res.status(statusCode).json({
        error: {
            message: err.isOperational ? err.message : 'Error interno del servidor',
            code: errorCode,
            status: statusCode,
            timestamp: new Date().toISOString(),
            path: req.url
        }
    });
};

module.exports = { AppError, notFoundHandler, errorHandler };