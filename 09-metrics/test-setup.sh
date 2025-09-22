#!/bin/bash

# Script para testar o provisionamento automático do dashboard

echo "🧪 Testando provisionamento automático do Grafana..."

# Limpar ambiente anterior
echo "🧹 Limpando ambiente anterior..."
docker-compose down -v 2>/dev/null

# Subir ambiente
echo "🚀 Subindo ambiente..."
docker-compose up -d

# Aguardar serviços
echo "⏳ Aguardando serviços ficarem prontos (60s)..."
sleep 60

# Testar Kong
echo "🔍 Testando Kong..."
if curl -s http://localhost:8001/status > /dev/null; then
    echo "✅ Kong OK"
else
    echo "❌ Kong FALHOU"
    exit 1
fi

# Testar Prometheus
echo "🔍 Testando Prometheus..."
if curl -s http://localhost:9090/-/healthy > /dev/null; then
    echo "✅ Prometheus OK"
else
    echo "❌ Prometheus FALHOU"
    exit 1
fi

# Testar Grafana
echo "🔍 Testando Grafana..."
if curl -s http://localhost:3000/api/health > /dev/null; then
    echo "✅ Grafana OK"
else
    echo "❌ Grafana FALHOU"
    exit 1
fi

# Verificar se o dashboard foi provisionado
echo "📊 Verificando dashboard..."
DASHBOARD_RESPONSE=$(curl -s -u admin:admin123 http://localhost:3000/api/search?query=Kong)

if echo "$DASHBOARD_RESPONSE" | grep -q "Kong Gateway Metrics"; then
    echo "✅ Dashboard 'Kong Gateway Metrics' provisionado com sucesso!"
else
    echo "❌ Dashboard não encontrado"
    echo "Resposta da API: $DASHBOARD_RESPONSE"
    exit 1
fi

# Gerar um pouco de tráfego para testar métricas
echo "📡 Gerando tráfego de teste..."
for i in {1..10}; do
    curl -s http://localhost:8000/api/posts > /dev/null &
done
wait

echo ""
echo "🎉 TESTE CONCLUÍDO COM SUCESSO!"
echo ""
echo "🌐 Acesse:"
echo "  📊 Grafana: http://localhost:3000 (admin/admin123)"
echo "  📈 Prometheus: http://localhost:9090"
echo "  🔧 Kong Admin: http://localhost:8001"
echo "  🔗 Kong Proxy: http://localhost:8000"
echo ""
echo "📊 Dashboard 'Kong Gateway Metrics' deve estar disponível no Grafana!"
