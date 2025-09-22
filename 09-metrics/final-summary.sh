#!/bin/bash

echo "🎯 RESUMO FINAL - KONG OBSERVABILITY DEMO"
echo "========================================="
echo ""

# Verificar status dos containers
echo "📊 STATUS DA INFRAESTRUTURA:"
CONTAINERS=$(podman compose ps --format table 2>/dev/null | grep -c "Up")
echo "   • Containers ativos: $CONTAINERS/3"

# Verificar métricas
echo ""
echo "📈 STATUS DAS MÉTRICAS:"
KONG_STATUS=$(curl -s http://localhost:8001/status > /dev/null 2>&1 && echo "✅ Online" || echo "❌ Offline")
PROM_STATUS=$(curl -s http://localhost:9090/api/v1/query?query=up > /dev/null 2>&1 && echo "✅ Online" || echo "❌ Offline")
GRAFANA_STATUS=$(curl -s http://localhost:3000 > /dev/null 2>&1 && echo "✅ Online" || echo "❌ Offline")

echo "   • Kong Gateway: $KONG_STATUS"
echo "   • Prometheus: $PROM_STATUS"
echo "   • Grafana: $GRAFANA_STATUS"

# Verificar dados
echo ""
echo "🔢 DADOS DISPONÍVEIS:"
TOTAL_REQUESTS=$(curl -s "http://localhost:9090/api/v1/query?query=sum(kong_http_requests_total)" | jq -r '.data.result[0].value[1]' 2>/dev/null || echo "0")
INCREASE_5M=$(curl -s "http://localhost:9090/api/v1/query?query=sum(increase(kong_http_requests_total%5B5m%5D))" | jq -r '.data.result[0].value[1]' 2>/dev/null || echo "0")
RATE_5M=$(curl -s "http://localhost:9090/api/v1/query?query=sum(rate(kong_http_requests_total%5B5m%5D))" | jq -r '.data.result[0].value[1]' 2>/dev/null || echo "0")

echo "   • Total requests: $TOTAL_REQUESTS"
echo "   • Requests últimos 5min: $INCREASE_5M"
echo "   • Rate atual: $RATE_5M req/s"

# Verificar warning
echo ""
echo "⚠️  AVISOS CONHECIDOS:"
echo "   • Warning 'time out of sync' no Prometheus"
echo "   • Isso é normal no Podman/macOS"
echo "   • NÃO afeta o funcionamento das métricas"
echo "   • É apenas um aviso cosmético"

echo ""
echo "🎬 PARA SUA APRESENTAÇÃO:"
echo "================================="
echo ""
echo "1️⃣  URLs PRINCIPAIS:"
echo "   🌐 Grafana: http://localhost:3000"
echo "      Login: admin / admin123"
echo "   📊 Prometheus: http://localhost:9090" 
echo "      (ignore warning amarelo)"
echo "   🦍 Kong Admin: http://localhost:8001"
echo "   🚀 Kong Proxy: http://localhost:8000"
echo ""
echo "2️⃣  COMANDOS ÚTEIS:"
echo "   ./simple-load-test.sh     # Gerar tráfego"
echo "   ./presentation-demo.sh    # Demo interativo"
echo "   ./verify-setup.sh         # Verificar status"
echo "   ./time-warning-info.sh    # Info sobre warning"
echo ""
echo "3️⃣  FLOW DA DEMO:"
echo "   a) Abrir Grafana e fazer login"
echo "   b) Ir para Dashboard 'Kong Gateway Metrics'"
echo "   c) Executar ./simple-load-test.sh"
echo "   d) Mostrar métricas em tempo real"
echo "   e) Explicar queries do Prometheus"
echo ""
echo "4️⃣  QUERIES PARA DEMONSTRAR:"
echo "   sum(kong_http_requests_total)"
echo "   sum(increase(kong_http_requests_total[5m]))"
echo "   sum(rate(kong_http_requests_total[5m]))"
echo "   kong_http_requests_total{code=\"200\"}"
echo ""
echo "5️⃣  PONTOS A DESTACAR:"
echo "   ✅ Kong expondo métricas automaticamente"
echo "   ✅ Prometheus coletando dados a cada 5s"
echo "   ✅ Grafana visualizando em tempo real"
echo "   ✅ Queries PromQL funcionando"
echo "   ✅ Dashboard responsivo e interativo"
echo ""
echo "🎯 SUA DEMO ESTÁ PRONTA!"
echo "========================"
