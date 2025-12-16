const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(express.static('public'));

// Health check endpoint
app.get('/health', (req, res) => {
    res.status(200).json({
        status: 'healthy',
        timestamp: new Date().toISOString(),
        uptime: process.uptime(),
        environment: process.env.NODE_ENV || 'development'
    });
});

// Ready check for Kubernetes
app.get('/ready', (req, res) => {
    res.status(200).json({ status: 'ready' });
});

// Main route
app.get('/', (req, res) => {
    res.json({
        message: 'DevOps Multi-Cloud Sample Application',
        version: '1.0.0',
        description: 'A sample Node.js application for CI/CD pipeline demonstration',
        endpoints: {
            health: '/health',
            ready: '/ready',
            api: '/api/info'
        }
    });
});

// API endpoint
app.get('/api/info', (req, res) => {
    res.json({
        application: 'DevOps Sample App',
        version: '1.0.0',
        nodejs: process.version,
        platform: process.platform,
        arch: process.arch,
        memory: {
            total: Math.round(process.memoryUsage().heapTotal / 1024 / 1024) + ' MB',
            used: Math.round(process.memoryUsage().heapUsed / 1024 / 1024) + ' MB'
        }
    });
});

// Error handling
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({
        error: 'Something went wrong!',
        message: err.message
    });
});

// Only start server if run directly (not imported by tests)
if (require.main === module) {
    const server = app.listen(port, () => {
        console.log(`Server is running on port ${port}`);
        console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
    });

    // Graceful shutdown
    process.on('SIGTERM', () => {
        console.log('SIGTERM signal received: closing HTTP server');
        server.close(() => {
            console.log('HTTP server closed');
            process.exit(0);
        });
    });
}

module.exports = app;
