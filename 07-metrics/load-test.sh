#!/bin/bash

# Script para gerar tráfego no Kong e demonstrar métricas
# Balanceamento entre Go Mock API (3001) e Node Mock API (3002)
# Uso: ./load-test.sh

echo "🚀 Gerando tráfego para demonstrar métricas do Kong..."
echo "⚖️  Balanceamento entre Go Mock API e Node Mock API"
echo "📊 Acesse o Grafana em: http://localhost:3000 (admin/admin123)"
echo "📈 Acesse o Prometheus em: http://localhost:9090"
echo ""

# Função para fazer requisições variadas
generate_traffic() {
    local requests=$1
    local delay=$2
    
    echo "📡 Gerando $requests requisições com delay de ${delay}s..."
    
    for i in $(seq 1 $requests); do
        # Requisições de sucesso (200) - balanceadas entre Go e Node
        curl -s -o /dev/null "http://localhost:8000/api/users" &
        curl -s -o /dev/null "http://localhost:8000/api/users/1" &
        curl -s -o /dev/null "http://localhost:8000/api/health" &
        curl -s -o /dev/null "http://localhost:8000/api/posts" &
        
        # Algumas requisições que podem gerar 404
        curl -s -o /dev/null "http://localhost:8000/api/users/99999" &
        curl -s -o /dev/null "http://localhost:8000/api/nonexistent" &
        
        # POST requests (não suportado pelos mocks, mas gerará métricas)
        curl -s -o /dev/null -X POST \
            -H "Content-Type: application/json" \
            -d '{"name":"Test User","email":"test@example.com"}' \
            "http://localhost:8000/api/users" &
        
        if [ $((i % 10)) -eq 0 ]; then
            echo "  ⏳ Enviadas $i requisições..."
        fi
        
        sleep $delay
    done
    
    wait # Aguarda todas as requisições em background terminarem
    echo "  ✅ Concluídas $requests requisições"
}

# Verificar se o Kong está rodando
echo "🔍 Verificando se o Kong está ativo..."
if ! curl -s http://localhost:8001/status > /dev/null; then
    echo "❌ Kong não está rodando. Execute 'docker-compose up -d' primeiro."
    exit 1
fi

echo "✅ Kong está ativo!"
echo ""

# Menu interativo
while true; do
    echo "📋 Opções de geração de tráfego:"
    echo "1) Tráfego leve (10 req/min por 2 minutos)"
    echo "2) Tráfego moderado (30 req/min por 5 minutos)"
    echo "3) Tráfego intenso (60 req/min por 3 minutos)"
    echo "4) Burst de tráfego (100 requisições rápidas)"
    echo "5) Tráfego contínuo (até ser interrompido)"
    echo "6) Verificar métricas atuais"
    echo "0) Sair"
    echo ""
    read -p "Escolha uma opção: " choice

    case $choice in
        1)
            generate_traffic 20 6
            ;;
        2)
            generate_traffic 150 2
            ;;
        3)
            generate_traffic 180 1
            ;;
        4)
            echo "💥 Burst de 100 requisições..."
            generate_traffic 100 0.1
            ;;
        5)
            echo "🔄 Tráfego contínuo iniciado. Pressione Ctrl+C para parar."
            while true; do
                generate_traffic 10 0.1
            done
            ;;
        6)
            echo "📊 Métricas atuais do Kong:"
            echo ""
            echo "🔗 Status geral:"
            curl -s http://localhost:8001/status | jq .
            echo ""
            echo "📈 Métricas Prometheus:"
            curl -s http://localhost:8100/metrics | grep -E "(kong_http_requests_total|kong_request_latency)" | head -10
            echo ""
            ;;
        0)
            echo "👋 Saindo..."
            break
            ;;
        *)
            echo "❌ Opção inválida!"
            ;;
    esac
    echo ""
done

echo "🎯 Dicas para apresentação:"
echo "  - Grafana: http://localhost:3000 (admin/admin123)"
echo "  - Prometheus: http://localhost:9090"
echo "  - Kong Admin: http://localhost:8001"
echo "  - Kong Proxy: http://localhost:8000"
echo "  - Métricas: http://localhost:8100/metrics"
