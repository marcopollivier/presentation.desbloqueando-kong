#!/bin/bash

echo "🧪 TESTE FINAL - Verificando se o dashboard está funcionando"
echo "=========================================================="

# Testar se métricas estão no Prometheus
echo "1️⃣  Testando métricas no Prometheus..."
KONG_METRICS=$(curl -s "http://localhost:9090/api/v1/query?query=kong_http_requests_total" | jq '.data.result | length')
if [ "$KONG_METRICS" -gt 0 ]; then
    echo "✅ Prometheus tem $KONG_METRICS séries de métricas Kong"
else
    echo "❌ Nenhuma métrica Kong encontrada no Prometheus"
    exit 1
fi

# Testar query específica
echo "2️⃣  Testando query de exemplo..."
QUERY_RESULT=$(curl -s "http://localhost:9090/api/v1/query?query=sum(increase(kong_http_requests_total%5B5m%5D))")
QUERY_VALUE=$(echo "$QUERY_RESULT" | jq -r '.data.result[0].value[1]' 2>/dev/null)
if [ "$QUERY_VALUE" != "null" ] && [ "$QUERY_VALUE" != "" ]; then
    echo "✅ Query funcionando! Total requests nos últimos 5min: $QUERY_VALUE"
else
    echo "❌ Query não retornou dados válidos"
    echo "Resposta: $QUERY_RESULT"
fi

# Testar conexão Grafana
echo "3️⃣  Testando conexão do Grafana com Prometheus..."
DATASOURCE_TEST=$(curl -s -u admin:admin123 "http://localhost:3000/api/datasources/proxy/1/api/v1/query?query=up")
if echo "$DATASOURCE_TEST" | grep -q '"status":"success"'; then
    echo "✅ Grafana consegue conectar com Prometheus"
else
    echo "❌ Grafana não consegue conectar com Prometheus"
    echo "Resposta: $DATASOURCE_TEST"
fi

# Verificar dashboards
echo "4️⃣  Verificando dashboards disponíveis..."
DASHBOARDS=$(curl -s -u admin:admin123 "http://localhost:3000/api/search?query=Kong" | jq '. | length')
echo "📊 Dashboards Kong encontrados: $DASHBOARDS"

echo ""
echo "🎯 RECOMENDAÇÃO:"
echo "   Acesse: http://localhost:3000"
echo "   Login: admin/admin123"
echo "   Procure por: 'Kong Gateway Metrics' (UID: kong-gateway-fixed)"
echo ""
echo "💡 Se ainda mostrar 'No Data':"
echo "   1. Verifique o time range (últimos 15min)"
echo "   2. Gere mais tráfego com: ./load-test.sh"
echo "   3. Aguarde alguns segundos para os dados aparecerem"
