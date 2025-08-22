const http = require('http');
const url = require('url');

const PORT = process.env.PORT || 3001;
const SERVER_NAME = process.env.SERVER_NAME || 'mock-api';

// Mock data similar to JSONPlaceholder
const posts = [
  { id: 1, title: 'Post 1', body: 'This is post 1', userId: 1 },
  { id: 2, title: 'Post 2', body: 'This is post 2', userId: 1 },
  { id: 3, title: 'Post 3', body: 'This is post 3', userId: 2 }
];

const users = [
  { id: 1, name: 'John Doe', email: 'john@example.com', username: 'johndoe' },
  { id: 2, name: 'Jane Smith', email: 'jane@example.com', username: 'janesmith' }
];

const server = http.createServer((req, res) => {
  const parsedUrl = url.parse(req.url, true);
  const path = parsedUrl.pathname;
  const method = req.method;
  
  // Add CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  res.setHeader('Content-Type', 'application/json');
  
  // Add server identification
  res.setHeader('X-Server-Name', SERVER_NAME);
  
  console.log(`[${new Date().toISOString()}] ${method} ${path} - Server: ${SERVER_NAME}`);
  
  // Handle preflight requests
  if (method === 'OPTIONS') {
    res.writeHead(200);
    res.end();
    return;
  }
  
  // Health check endpoint
  if (path === '/health') {
    res.writeHead(200);
    res.end(JSON.stringify({ 
      status: 'healthy', 
      server: SERVER_NAME,
      timestamp: new Date().toISOString()
    }));
    return;
  }
  
  // Posts endpoints
  if (path === '/posts' && method === 'GET') {
    res.writeHead(200);
    res.end(JSON.stringify(posts.map(post => ({ 
      ...post, 
      server_info: { 
        server: SERVER_NAME, 
        port: PORT,
        timestamp: new Date().toISOString()
      }
    }))));
    return;
  }
  
  if (path.match(/^\/posts\/\d+$/) && method === 'GET') {
    const postId = parseInt(path.split('/')[2]);
    const post = posts.find(p => p.id === postId);
    
    if (post) {
      res.writeHead(200);
      res.end(JSON.stringify({ 
        ...post, 
        server_info: { 
          server: SERVER_NAME, 
          port: PORT,
          timestamp: new Date().toISOString()
        }
      }));
    } else {
      res.writeHead(404);
      res.end(JSON.stringify({ error: 'Post not found' }));
    }
    return;
  }
  
  // Users endpoints  
  if (path === '/users' && method === 'GET') {
    res.writeHead(200);
    res.end(JSON.stringify(users.map(user => ({ 
      ...user, 
      server_info: { 
        server: SERVER_NAME, 
        port: PORT,
        timestamp: new Date().toISOString()
      }
    }))));
    return;
  }
  
  if (path.match(/^\/users\/\d+$/) && method === 'GET') {
    const userId = parseInt(path.split('/')[2]);
    const user = users.find(u => u.id === userId);
    
    if (user) {
      res.writeHead(200);
      res.end(JSON.stringify({ 
        ...user, 
        server_info: { 
          server: SERVER_NAME, 
          port: PORT,
          timestamp: new Date().toISOString()
        }
      }));
    } else {
      res.writeHead(404);
      res.end(JSON.stringify({ error: 'User not found' }));
    }
    return;
  }
  
  // Default 404
  res.writeHead(404);
  res.end(JSON.stringify({ 
    error: 'Not found',
    path: path,
    server: SERVER_NAME
  }));
});

server.listen(PORT, () => {
  console.log(`🚀 Mock API Server "${SERVER_NAME}" running on port ${PORT}`);
  console.log(`Health check: http://localhost:${PORT}/health`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log(`📴 Mock API Server "${SERVER_NAME}" shutting down...`);
  server.close();
});

process.on('SIGINT', () => {
  console.log(`📴 Mock API Server "${SERVER_NAME}" shutting down...`);
  server.close();
});
