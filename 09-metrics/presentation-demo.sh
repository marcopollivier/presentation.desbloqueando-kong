#!/bin/bash

echo "🎯 KONG OBSERVABILITY DEMO - PRESENTATION READY"
echo "=============================================="
echo ""

# Verificar se está tudo rodando
echo "🔍 Verificando infraestrutura..."
if ! curl -s http://localhost:8001/status > /dev/null; then
    echo "❌ Kong não está rodando. Execute 'podman compose up -d' primeiro."
    exit 1
fi

if ! curl -s http://localhost:9090/api/v1/query?query=up > /dev/null; then
    echo "❌ Prometheus não está acessível."
    exit 1
fi

if ! curl -s http://localhost:3000 > /dev/null; then
    echo "❌ Grafana não está acessível."
    exit 1
fi

echo "✅ Toda infraestrutura está funcionando!"
echo ""

# URLs importantes
echo "📋 LINKS PARA A APRESENTAÇÃO:"
echo "   🌐 Grafana Dashboard: http://localhost:3000"
echo "   📊 Prometheus: http://localhost:9090"  
echo "   🔧 Kong Admin API: http://localhost:8001"
echo "   🚀 Kong Proxy: http://localhost:8000"
echo "   📈 Kong Metrics: http://localhost:8100/metrics"
echo ""
echo "🔐 LOGIN GRAFANA:"
echo "   Usuário: admin"
echo "   Senha: admin123"
echo ""

# Mostrar métricas atuais
echo "📊 STATUS ATUAL DAS MÉTRICAS:"
KONG_METRICS=$(curl -s "http://localhost:9090/api/v1/query?query=kong_http_requests_total" | jq '.data.result | length')
TOTAL_REQUESTS=$(curl -s "http://localhost:9090/api/v1/query?query=sum(increase(kong_http_requests_total%5B5m%5D))" | jq -r '.data.result[0].value[1]' 2>/dev/null)

echo "   ⚡ Séries de métricas Kong: $KONG_METRICS"
echo "   📈 Total requests (5min): ${TOTAL_REQUESTS:-0}"
echo ""

# Menu para apresentação
while true; do
    echo "🎬 OPÇÕES PARA APRESENTAÇÃO:"
    echo "1) 🚀 Gerar tráfego intenso (600 requests)"
    echo "2) 📊 Verificar métricas atuais"
    echo "3) 🌐 Abrir Grafana (http://localhost:3000)"
    echo "4) 📈 Abrir Prometheus (http://localhost:9090)"
    echo "5) 🔄 Gerar tráfego contínuo (para demo)"
    echo "0) ✅ Sair"
    echo ""
    read -p "Escolha uma opção: " choice

    case $choice in
        1)
            echo "🚀 Gerando tráfego intenso para demonstração..."
            ./simple-load-test.sh
            echo ""
            echo "✅ Tráfego gerado! Aguarde ~30s e verifique o Grafana."
            ;;
        2)
            echo "📊 Verificando métricas atuais..."
            ./verify-setup.sh
            ;;
        3)
            echo "🌐 Abrindo Grafana..."
            open "http://localhost:3000" 2>/dev/null || echo "   Manual: http://localhost:3000"
            ;;
        4)
            echo "📈 Abrindo Prometheus..."
            open "http://localhost:9090" 2>/dev/null || echo "   Manual: http://localhost:9090"
            ;;
        5)
            echo "🔄 Iniciando tráfego contínuo. Pressione Ctrl+C para parar."
            while true; do
                curl -s "http://localhost:8000/api/posts" > /dev/null &
                curl -s "http://localhost:8000/api/users" > /dev/null &
                curl -s "http://localhost:8000/api/posts/999" > /dev/null &
                sleep 2
            done
            ;;
        0)
            echo "👋 Demo finalizada! Boa apresentação!"
            break
            ;;
        *)
            echo "❌ Opção inválida!"
            ;;
    esac
    echo ""
done

echo ""
echo "🎯 DICAS PARA A APRESENTAÇÃO:"
echo "   1. Acesse o Grafana: http://localhost:3000"
echo "   2. Login: admin/admin123"
echo "   3. Procure por 'Kong Gateway Metrics'"
echo "   4. Gere tráfego com opção 1 ou 5"
echo "   5. Mostre métricas em tempo real!"
echo ""
echo "📋 DASHBOARDS DISPONÍVEIS:"
echo "   • Kong Gateway Metrics (Principal)"
echo "   • Request Rate & Response Time"
echo "   • Error Rate Analysis"
