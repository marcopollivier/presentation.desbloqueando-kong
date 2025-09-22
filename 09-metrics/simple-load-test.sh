#!/bin/bash

echo "🚀 Gerando burst de tráfego para o Kong..."

# Verificar se Kong está ativo
if ! curl -s http://localhost:8001/status > /dev/null; then
    echo "❌ Kong não está rodando!"
    exit 1
fi

echo "✅ Kong está ativo! Gerando 100 requisições..."

# Gerar diferentes tipos de requests
for i in {1..100}; do
    # Requests que retornam 200
    curl -s "http://localhost:8000/api/posts/1" > /dev/null &
    curl -s "http://localhost:8000/api/posts/2" > /dev/null &
    curl -s "http://localhost:8000/api/users" > /dev/null &
    
    # POST requests que retornam 201
    curl -s -X POST "http://localhost:8000/api/posts" \
         -H "Content-Type: application/json" \
         -d '{"title":"Test","body":"Test body","userId":1}' > /dev/null &
    
    # Requests que retornam 404
    curl -s "http://localhost:8000/api/posts/999" > /dev/null &
    curl -s "http://localhost:8000/api/nonexistent" > /dev/null &
    
    if [ $((i % 10)) -eq 0 ]; then
        echo "  ⏳ Enviadas $((i * 6)) requisições..."
    fi
    
    sleep 0.1
done

wait # Aguarda todas as requisições em background terminarem

echo "✅ Tráfego gerado! Total: 600 requests"
echo "📊 100 GET /api/posts/1 (200)"
echo "📊 100 GET /api/posts/2 (200)" 
echo "📊 100 GET /api/users (200)"
echo "📊 100 POST /api/posts (201)"
echo "📊 100 GET /api/posts/999 (404)"
echo "📊 100 GET /api/nonexistent (404)"
