#!/bin/bash

echo "🕐 SINCRONIZAÇÃO FORÇADA DE TEMPO"
echo "================================="

# Subir containers
echo "1️⃣  Subindo containers..."
podman compose up -d

echo "2️⃣  Aguardando inicialização..."
sleep 15

echo "3️⃣  Tentando sincronizar tempo nos containers..."

# Tentar sincronizar Prometheus
echo "   📊 Sincronizando Prometheus..."
podman exec prometheus sh -c "date -s '$(date -u +%Y%m%d%H%M%S)'" 2>/dev/null || echo "      ⚠️  Não foi possível sincronizar Prometheus"

# Tentar sincronizar Kong
echo "   🦍 Sincronizando Kong..."
podman exec kong-basic sh -c "date -s '$(date -u +%Y%m%d%H%M%S)'" 2>/dev/null || echo "      ⚠️  Não foi possível sincronizar Kong"

# Tentar sincronizar Grafana
echo "   📈 Sincronizando Grafana..."
podman exec grafana sh -c "date -s '$(date -u +%Y%m%d%H%M%S)'" 2>/dev/null || echo "      ⚠️  Não foi possível sincronizar Grafana"

echo ""
echo "4️⃣  Verificando resultado:"
echo "   Host: $(date)"
echo "   Prometheus: $(podman exec prometheus date 2>/dev/null || echo 'N/A')"
echo "   Kong: $(podman exec kong-basic date 2>/dev/null || echo 'N/A')"
echo "   Grafana: $(podman exec grafana date 2>/dev/null || echo 'N/A')"

echo ""
echo "5️⃣  Aguardando estabilização..."
sleep 10

echo ""
echo "✅ Processo concluído!"
echo "💡 Se o problema persistir, é uma limitação do Podman no macOS"
echo "💡 As métricas funcionam normalmente mesmo com este warning"
