const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3002;
const SERVER_NAME = process.env.SERVER_NAME || 'node-mock-api-2';

// Middleware
app.use(cors());
app.use(express.json());

// Request counter and latency middleware
app.use((req, res, next) => {
  const startTime = Date.now();
  
  if (req.method !== 'OPTIONS' && req.path !== '/metrics') {
    requestCount++;
  }
  console.log(`[${SERVER_NAME}] ${req.method} ${req.path} from ${req.ip}`);
  
  // Hook para medir latência após resposta
  res.on('finish', () => {
    if (req.method !== 'OPTIONS' && req.path !== '/metrics') {
      const latency = Date.now() - startTime;
      totalLatencyMs += latency;
    }
  });
  
  next();
});

// Server startup time for uptime calculation
const startTime = Date.now();
let requestCount = 0;
let totalLatencyMs = 0;

// Mock data
const posts = [
  { id: 1, title: 'Post 1', body: 'This is post 1', userId: 1 },
  { id: 2, title: 'Post 2', body: 'This is post 2', userId: 1 },
  { id: 3, title: 'Post 3', body: 'This is post 3', userId: 2 }
];

const users = [
  { id: 1, name: 'John Doe', email: 'john@example.com' },
  { id: 2, name: 'Jane Smith', email: 'jane@example.com' }
];

// Helper function to add server info
function addServerInfo(data) {
  return {
    ...data,
    server_info: {
      language: 'Node.js',
      server: SERVER_NAME,
      port: PORT,
      timestamp: new Date().toISOString(),
      uptime: `${Date.now() - startTime}ms`
    }
  };
}

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    language: 'Node.js',
    server: SERVER_NAME,
    port: PORT,
    timestamp: new Date().toISOString(),
    uptime: `${Date.now() - startTime}ms`,
    memory: process.memoryUsage(),
    nodeVersion: process.version
  });
});

// Posts endpoints
app.get('/posts', (req, res) => {
  const response = posts.map(post => addServerInfo(post));
  res.json(response);
});

app.get('/posts/:id', (req, res) => {
  const id = parseInt(req.params.id);
  const post = posts.find(p => p.id === id);
  
  if (!post) {
    return res.status(404).json({
      error: 'Post not found',
      server_info: {
        language: 'Node.js',
        server: SERVER_NAME,
        port: PORT,
        timestamp: new Date().toISOString()
      }
    });
  }
  
  res.json(addServerInfo(post));
});

// Users endpoints
app.get('/users', (req, res) => {
  const response = users.map(user => addServerInfo(user));
  res.json(response);
});

app.get('/users/:id', (req, res) => {
  const id = parseInt(req.params.id);
  const user = users.find(u => u.id === id);
  
  if (!user) {
    return res.status(404).json({
      error: 'User not found',
      server_info: {
        language: 'Node.js',
        server: SERVER_NAME,
        port: PORT,
        timestamp: new Date().toISOString()
      }
    });
  }
  
  res.json(addServerInfo(user));
});

// Performance benchmark endpoint
app.get('/performance', (req, res) => {
  const startTime = process.hrtime.bigint();
  
  // CPU-intensive task (calculating prime numbers)
  let result = 0;
  for (let i = 0; i < 100000; i++) {
    result += i;
  }
  
  const endTime = process.hrtime.bigint();
  const processingTime = Number(endTime - startTime) / 1000; // microseconds
  
  res.json({
    language: 'Node.js',
    server: SERVER_NAME,
    timestamp: new Date().toISOString(),
    result: result,
    processing_time: processingTime,
    event_loop: 'single-threaded',
    memory: process.memoryUsage()
  });
});

// Metrics endpoint - formato Prometheus
app.get('/metrics', (req, res) => {
  const uptime = (Date.now() - startTime) / 1000; // em segundos
  const avgLatency = requestCount > 0 ? (totalLatencyMs / requestCount).toFixed(2) : 0;
  
  const metrics = `# HELP node_mock_requests_total Total number of requests handled by Node mock service
# TYPE node_mock_requests_total counter
node_mock_requests_total{server="${SERVER_NAME}",language="nodejs"} ${requestCount}
# HELP node_mock_uptime_seconds Uptime of the Node mock service in seconds
# TYPE node_mock_uptime_seconds gauge
node_mock_uptime_seconds{server="${SERVER_NAME}",language="nodejs"} ${uptime.toFixed(2)}
# HELP node_mock_response_time_ms Average response time in milliseconds
# TYPE node_mock_response_time_ms gauge
node_mock_response_time_ms{server="${SERVER_NAME}",language="nodejs"} ${avgLatency}
`;
  
  res.set('Content-Type', 'text/plain');
  res.send(metrics);
});

// Catch-all route
app.get('*', (req, res) => {
  res.status(404).json({
    error: 'Route not found',
    server_info: {
      language: 'Node.js',
      server: SERVER_NAME,
      port: PORT,
      timestamp: new Date().toISOString()
    }
  });
});

// Error handling middleware
app.use((error, req, res, next) => {
  console.error('Error:', error);
  res.status(500).json({
    error: 'Internal server error',
    server_info: {
      language: 'Node.js',
      server: SERVER_NAME,
      port: PORT,
      timestamp: new Date().toISOString()
    }
  });
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Node.js Mock API Server (${SERVER_NAME}) running on port ${PORT}`);
  console.log(`📊 Performance endpoint: http://localhost:${PORT}/performance`);
  console.log(`💚 Health check: http://localhost:${PORT}/health`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('📴 Node.js server shutting down gracefully...');
  process.exit(0);
});

process.on('SIGINT', () => {
  console.log('📴 Node.js server shutting down gracefully...');
  process.exit(0);
});
