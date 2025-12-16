const request = require('supertest');
const app = require('./app');

describe('Sample Application Tests', () => {

    describe('GET /', () => {
        it('should return application info', async () => {
            const res = await request(app).get('/');
            expect(res.statusCode).toBe(200);
            expect(res.body).toHaveProperty('message');
            expect(res.body.message).toContain('DevOps');
        });
    });

    describe('GET /health', () => {
        it('should return health status', async () => {
            const res = await request(app).get('/health');
            expect(res.statusCode).toBe(200);
            expect(res.body).toHaveProperty('status');
            expect(res.body.status).toBe('healthy');
        });

        it('should include timestamp', async () => {
            const res = await request(app).get('/health');
            expect(res.body).toHaveProperty('timestamp');
        });
    });

    describe('GET /ready', () => {
        it('should return ready status', async () => {
            const res = await request(app).get('/ready');
            expect(res.statusCode).toBe(200);
            expect(res.body.status).toBe('ready');
        });
    });

    describe('GET /api/info', () => {
        it('should return system information', async () => {
            const res = await request(app).get('/api/info');
            expect(res.statusCode).toBe(200);
            expect(res.body).toHaveProperty('nodejs');
            expect(res.body).toHaveProperty('platform');
            expect(res.body).toHaveProperty('memory');
        });
    });

    describe('Error handling', () => {
        it('should return 404 for unknown routes', async () => {
            const res = await request(app).get('/unknown-route');
            expect(res.statusCode).toBe(404);
        });
    });

});
