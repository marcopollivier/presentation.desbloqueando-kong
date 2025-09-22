#!/bin/bash

# Demo Script para apresentação Kong + Observabilidade
# Execute este script para uma demonstração completa

set -e

echo "🎬 DEMO: Kong Gateway + Prometheus + Grafana"
echo "=============================================="
echo ""

# Função para aguardar entrada do usuário
wait_for_user() {
    echo "⏸️  Pressione ENTER para continuar..."
    read -r
}

echo "📋 Esta demonstração irá mostrar:"
echo "  1. Kong Gateway com plugin Prometheus"
echo "  2. Coleta de métricas em tempo real"
echo "  3. Visualização no Grafana"
echo "  4. Diferentes cenários de tráfego"
echo ""

wait_for_user

echo "🚀 Passo 1: Subindo o ambiente..."
docker-compose up -d

echo "⏳ Aguardando serviços ficarem prontos..."
sleep 30

# Verificar se os serviços estão rodando
echo "🔍 Verificando serviços..."
if curl -s http://localhost:8001/status > /dev/null; then
    echo "✅ Kong está rodando"
else
    echo "❌ Kong não está respondendo"
    exit 1
fi

if curl -s http://localhost:9090/-/healthy > /dev/null; then
    echo "✅ Prometheus está rodando"
else
    echo "❌ Prometheus não está respondendo"
fi

if curl -s http://localhost:3000/api/health > /dev/null; then
    echo "✅ Grafana está rodando"
else
    echo "❌ Grafana não está respondendo"
fi

echo ""
echo "🌐 URLs disponíveis:"
echo "  📊 Grafana:    http://localhost:3000 (admin/admin123)"
echo "  📈 Prometheus: http://localhost:9090"
echo "  🔧 Kong Admin: http://localhost:8001"
echo "  🔗 Kong Proxy: http://localhost:8000"
echo ""

wait_for_user

echo "📊 Passo 2: Abrindo interfaces de monitoramento..."

# Tentar abrir os browsers (funciona no macOS)
if command -v open &> /dev/null; then
    echo "🖥️  Abrindo Grafana..."
    open "http://localhost:3000" 2>/dev/null || true
    sleep 3
    echo "🖥️  Abrindo Prometheus..."
    open "http://localhost:9090" 2>/dev/null || true
fi

echo ""
echo "📝 INSTRUÇÕES:"
echo "  1. No Grafana, faça login com admin/admin123"
echo "  2. Vá para Dashboards > Kong Gateway Metrics"
echo "  3. Observe que todas as métricas estão zeradas"
echo ""

wait_for_user

echo "🔥 Passo 3: Gerando tráfego inicial..."
echo "📡 Enviando 50 requisições básicas..."

for i in {1..50}; do
    curl -s -o /dev/null "http://localhost:8000/api/posts" &
    curl -s -o /dev/null "http://localhost:8000/api/users" &
    if [ $((i % 10)) -eq 0 ]; then
        echo "  ✅ $i requisições enviadas..."
    fi
    sleep 0.2
done

wait
echo "✅ Tráfego inicial concluído!"
echo ""
echo "📊 Volte ao Grafana e observe as métricas aparecendo..."
echo ""

wait_for_user

echo "💥 Passo 4: Simulando pico de tráfego..."
echo "🚀 Burst de 100 requisições rápidas..."

for i in {1..100}; do
    curl -s -o /dev/null "http://localhost:8000/api/posts" &
    curl -s -o /dev/null "http://localhost:8000/api/posts/1" &
    curl -s -o /dev/null "http://localhost:8000/api/users" &
    
    # Algumas que vão dar 404
    curl -s -o /dev/null "http://localhost:8000/api/nonexistent" &
    
    if [ $((i % 20)) -eq 0 ]; then
        echo "  🔥 $i bursts enviados..."
    fi
    sleep 0.05
done

wait
echo "✅ Pico de tráfego concluído!"
echo ""
echo "📈 No Grafana, observe:"
echo "  - Aumento na taxa de requests"
echo "  - Pico no gráfico de Request Rate"
echo "  - Possível aumento na latência"
echo "  - Algumas requisições 404"
echo ""

wait_for_user

echo "📊 Passo 5: Explorando métricas no Prometheus..."
echo ""
echo "🔍 Queries úteis no Prometheus:"
echo "  - kong_http_requests_total"
echo "  - rate(kong_http_requests_total[5m])"
echo "  - kong_request_latency_ms"
echo "  - kong_bandwidth_bytes"
echo ""
echo "💡 Vá ao Prometheus e teste essas queries!"
echo ""

wait_for_user

echo "🔄 Passo 6: Tráfego contínuo para apresentação..."
echo "▶️  Iniciando tráfego contínuo (Ctrl+C para parar)..."
echo ""

# Função para tráfego contínuo
continuous_traffic() {
    while true; do
        # Requests normais
        curl -s -o /dev/null "http://localhost:8000/api/posts" &
        curl -s -o /dev/null "http://localhost:8000/api/users" &
        curl -s -o /dev/null "http://localhost:8000/api/posts/1" &
        
        # POST request
        curl -s -o /dev/null -X POST \
            -H "Content-Type: application/json" \
            -d '{"title":"Demo","body":"Demo body"}' \
            "http://localhost:8000/api/posts" &
        
        # Algumas que podem dar erro
        if [ $((RANDOM % 10)) -eq 0 ]; then
            curl -s -o /dev/null "http://localhost:8000/api/invalid" &
        fi
        
        sleep 1
    done
}

# Trap para capturar Ctrl+C
trap 'echo -e "\n🛑 Parando tráfego contínuo..."; exit 0' INT

continuous_traffic &
TRAFFIC_PID=$!

echo "📊 Agora você pode:"
echo "  - Mostrar métricas em tempo real no Grafana"
echo "  - Demonstrar diferentes visualizações"
echo "  - Explicar os conceitos de observabilidade"
echo ""
echo "⏹️  Pressione Ctrl+C quando terminar a apresentação"

wait $TRAFFIC_PID

echo ""
echo "🎬 Demo concluída!"
echo ""
echo "🧹 Para limpar o ambiente:"
echo "  docker-compose down -v"
echo ""
echo "📚 Para mais informações, consulte o README.md"
