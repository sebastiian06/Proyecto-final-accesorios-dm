require('dotenv').config();

const config = {
    port: process.env.PORT || 8000,
    env: process.env.NODE_ENV || 'production',
    
    services: {
        inventory: {
            host: process.env.INVENTORY_HOST || 'accesorios-dm-inventory-service-prod',
            port: process.env.INVENTORY_PORT || 8080,
            basePath: '/api/v1'
        },
        security: {
            host: process.env.SECURITY_HOST || 'accesorios-dm-security-prod',
            port: process.env.SECURITY_PORT || 8888,
            basePath: '/api/v1'
        },
        payment: {
            host: process.env.PAYMENT_HOST || 'accesorios-dm-payment-prod',
            port: process.env.PAYMENT_PORT || 9000,
            basePath: '/api/v1'
        }
    }
};

module.exports = config;