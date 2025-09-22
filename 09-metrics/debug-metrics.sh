#!/bin/bash

echo "🔍 KONG METRICS DEBUG - Investigando problema com queries"
echo "========================================================="
echo ""

# Testar métricas direto do Kong
echo "1️⃣  Métricas direto do Kong:"
echo "URL: http://localhost:8100/metrics"
KONG_DIRECT=$(curl -s http://localhost:8100/metrics | grep kong_http_requests_total | wc -l)
echo "   📊 Linhas de kong_http_requests_total encontradas: $KONG_DIRECT"

if [ "$KONG_DIRECT" -gt 0 ]; then
    echo "   ✅ Kong está expondo métricas"
    curl -s http://localhost:8100/metrics | grep kong_http_requests_total | head -3
else
    echo "   ❌ Kong NÃO está expondo métricas"
    exit 1
fi

echo ""

# Testar Prometheus direto
echo "2️⃣  Testando Prometheus direto:"
echo "URL: http://localhost:9090"
PROM_RESULT=$(curl -s "http://localhost:9090/api/v1/query?query=kong_http_requests_total" | jq '.data.result | length')
echo "   📊 Séries encontradas: $PROM_RESULT"

if [ "$PROM_RESULT" -gt 0 ]; then
    echo "   ✅ Prometheus tem dados Kong"
else
    echo "   ❌ Prometheus NÃO tem dados Kong"
    echo "   🔧 Verificando targets do Prometheus..."
    curl -s "http://localhost:9090/api/v1/targets" | jq '.data.activeTargets[] | select(.job=="kong") | {health: .health, lastError: .lastError}'
    exit 1
fi

echo ""

# Testar query problemática
echo "3️⃣  Testando query específica:"
echo "Query: sum(increase(kong_http_requests_total[5m]))"
QUERY_RESULT=$(curl -s "http://localhost:9090/api/v1/query?query=sum(increase(kong_http_requests_total%5B5m%5D))")
QUERY_VALUE=$(echo "$QUERY_RESULT" | jq -r '.data.result[0].value[1]' 2>/dev/null)

echo "   📊 Resultado da query: $QUERY_VALUE"
if [ "$QUERY_VALUE" != "null" ] && [ "$QUERY_VALUE" != "" ]; then
    echo "   ✅ Query funcionando! Valor: $QUERY_VALUE"
else
    echo "   ❌ Query não retornou dados"
    echo "   🔍 Resposta completa:"
    echo "$QUERY_RESULT" | jq .
fi

echo ""

# Testar via Grafana proxy
echo "4️⃣  Testando via Grafana proxy:"
echo "URL: http://localhost:3000 (proxy para Prometheus)"
GRAFANA_RESULT=$(curl -s -u admin:admin123 "http://localhost:3000/api/datasources/proxy/1/api/v1/query?query=sum(increase(kong_http_requests_total%5B5m%5D))")
GRAFANA_VALUE=$(echo "$GRAFANA_RESULT" | jq -r '.data.result[0].value[1]' 2>/dev/null)

echo "   📊 Resultado via Grafana: $GRAFANA_VALUE"
if [ "$GRAFANA_VALUE" != "null" ] && [ "$GRAFANA_VALUE" != "" ]; then
    echo "   ✅ Grafana proxy funcionando! Valor: $GRAFANA_VALUE"
else
    echo "   ❌ Grafana proxy com problema"
    echo "   🔍 Resposta completa:"
    echo "$GRAFANA_RESULT" | jq .
fi

echo ""

# Verificar datasources do Grafana
echo "5️⃣  Verificando datasources do Grafana:"
DATASOURCES=$(curl -s -u admin:admin123 "http://localhost:3000/api/datasources")
echo "   📊 Datasources configurados:"
echo "$DATASOURCES" | jq '.[] | {name: .name, type: .type, url: .url, uid: .uid}'

echo ""

# Queries alternativas para testar
echo "6️⃣  Testando queries alternativas:"

# Query 1: Valores absolutos
echo "   🔍 Query 1: kong_http_requests_total"
ALT1=$(curl -s "http://localhost:9090/api/v1/query?query=kong_http_requests_total" | jq '.data.result | length')
echo "      Séries encontradas: $ALT1"

# Query 2: Sum sem increase
echo "   🔍 Query 2: sum(kong_http_requests_total)"
ALT2=$(curl -s "http://localhost:9090/api/v1/query?query=sum(kong_http_requests_total)" | jq -r '.data.result[0].value[1]' 2>/dev/null)
echo "      Valor: $ALT2"

# Query 3: Rate
echo "   🔍 Query 3: sum(rate(kong_http_requests_total[5m]))"
ALT3=$(curl -s "http://localhost:9090/api/v1/query?query=sum(rate(kong_http_requests_total%5B5m%5D))" | jq -r '.data.result[0].value[1]' 2>/dev/null)
echo "      Valor: $ALT3"

echo ""
echo "🎯 DIAGNÓSTICO:"
echo "   - Se Kong e Prometheus estão OK mas Grafana não:"
echo "     1. Verifique o Time Range no Grafana (últimos 15min)"
echo "     2. Force refresh no dashboard (Ctrl+Shift+R)"
echo "     3. Verifique se o datasource UID está correto"
echo "     4. Restart do Grafana: podman compose restart grafana"
echo ""
echo "   - URLs para teste manual:"
echo "     • Prometheus: http://localhost:9090/graph"
echo "     • Grafana: http://localhost:3000 (admin/admin123)"
echo ""
echo "💡 DICA: No Grafana, vá em Explore e teste a query diretamente!"
