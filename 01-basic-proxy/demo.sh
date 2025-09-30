#!/bin/bash

echo "🚀 Demonstração Kong Básico"
echo "=========================="

echo ""
echo "1. Verificando status do Kong..."
curl -s http://localhost:8001/status | jq

echo ""
echo "2. Listando services configurados..."
curl -s http://localhost:8001/services | jq '.data[] | {name, url, protocol}'

echo ""
echo "3. Listando routes configurados..."
curl -s http://localhost:8001/routes | jq '.data[] | {name, paths, methods}'

echo ""
echo "4. Testando proxy - GET /api/posts..."
curl -s http://localhost:8000/api/posts | jq '.[0:2]'

echo ""
echo "5. Testando proxy - GET /api/posts/1..."
curl -s http://localhost:8000/api/posts/1 | jq

echo ""
echo "6. Testando proxy com headers personalizados..."
curl -H "X-Custom-Header: demo" -s http://localhost:8000/api/users/1 | jq

echo ""
echo "✅ Demonstração completa!"
echo ""
echo "💡 Pontos para discussão:"
echo "   - Kong funcionou como proxy reverso"
echo "   echo "   - Request /api/posts foi roteado para localhost:3001/posts (Go Mock API)""
echo "   - strip_path=true removeu /api do caminho upstream"
echo "   - Configuração declarativa vs Admin API"
