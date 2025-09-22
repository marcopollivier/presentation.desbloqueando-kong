#!/bin/bash

# Script para forçar reimportação do dashboard via API do Grafana

echo "🔄 Forçando reimportação do dashboard..."

# Aguardar Grafana ficar disponível
echo "⏳ Aguardando Grafana..."
sleep 10

until curl -s http://localhost:3000/api/health > /dev/null; do
    echo "  🔄 Aguardando Grafana..."
    sleep 2
done

echo "✅ Grafana disponível!"

# Ler o dashboard
DASHBOARD_JSON=$(cat ./grafana/dashboards/kong-dashboard.json)

# Criar payload de importação (sem inputs, usando UID fixo)
IMPORT_PAYLOAD=$(cat <<EOF
{
  "dashboard": $DASHBOARD_JSON,
  "overwrite": true,
  "folderId": 0
}
EOF
)

echo "📤 Importando dashboard via API..."

# Importar dashboard
RESPONSE=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  -u "admin:admin123" \
  -d "$IMPORT_PAYLOAD" \
  "http://localhost:3000/api/dashboards/import")

# Verificar resultado
if echo "$RESPONSE" | grep -q '"status":"success"'; then
    echo "✅ Dashboard importado com sucesso!"
    DASHBOARD_URL=$(echo "$RESPONSE" | grep -o '"url":"[^"]*"' | cut -d'"' -f4)
    echo "🔗 Dashboard disponível em: http://localhost:3000$DASHBOARD_URL"
elif echo "$RESPONSE" | grep -q "Cannot save provisioned dashboard"; then
    echo "⚠️  Dashboard já existe via provisionamento. Reiniciando Grafana..."
    docker compose restart grafana
    sleep 20
    echo "✅ Grafana reiniciado! Dashboard deve estar funcionando agora."
else
    echo "❌ Erro ao importar dashboard:"
    echo "$RESPONSE" | jq '.' 2>/dev/null || echo "$RESPONSE"
fi

echo ""
echo "🎯 Acesse: http://localhost:3000 (admin/admin123)"
echo "📊 Procure pelo dashboard 'Kong Gateway Metrics'"
