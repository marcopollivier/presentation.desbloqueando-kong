#!/bin/bash

# Performance test para o Go Validator Bridge Plugin
echo "🚀 Iniciando testes de performance do Go Validator Bridge Plugin"

# Verificar se os serviços estão rodando
echo "🔍 Verificando serviços..."
if ! curl -s http://localhost:8001/status > /dev/null; then
    echo "❌ Kong não está disponível"
    exit 1
fi

if ! curl -s http://localhost:8002/health > /dev/null; then
    echo "❌ Go service não está disponível"
    exit 1
fi

echo "✅ Serviços disponíveis"

# Teste 1: Requests válidos
echo "🧪 Teste 1: Requests válidos (100 requests)"
time for i in {1..100}; do
    curl -s -H "Content-Type: application/json" -H "X-Client-ID: test-$i" \
        http://localhost:8000/api/get > /dev/null &
    if [ $((i % 10)) -eq 0 ]; then wait; fi
done
wait
echo "✅ Teste 1 concluído"

# Teste 2: Rate limiting
echo "🧪 Teste 2: Rate limiting"
for i in {1..15}; do
    response=$(curl -s -o /dev/null -w "%{http_code}" \
        -H "Content-Type: application/json" \
        -H "X-Client-ID: rate-test" \
        http://localhost:8000/api/get)
    echo "Request $i: HTTP $response"
    if [ "$response" = "429" ]; then
        echo "🛑 Rate limit atingido!"
        break
    fi
done

echo "✅ Testes concluídos!"