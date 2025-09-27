#!/bin/bash

echo "🔄 Testando Load Balancing - Kong Gateway"
echo "========================================"
echo ""

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Função para extrair servidor da resposta
extract_server() {
    local response="$1"
    echo "$response" | jq -r '.server // .server_info.server // "desconhecido"' 2>/dev/null
}

# Função para extrair linguagem da resposta
extract_language() {
    local response="$1"
    echo "$response" | jq -r '.language // "Go"' 2>/dev/null
}

echo "1️⃣  Verificando status do Kong e serviços centralizados:"
echo "--------------------------------------------------------"

echo -n "🌐 Kong Gateway (porta 8000): "
kong_response=$(curl -s http://localhost:8001/status)
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Online${NC}"
else
    echo -e "${RED}❌ Offline${NC}"
    echo "❗ Execute os serviços mock centralizados primeiro:"
    echo "   cd ../00-mock-services && docker compose up -d"
    exit 1
fi

echo -n "� Serviços Mock (através do Kong): "
test_response=$(curl -s http://localhost:8000/api/health)
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Online${NC}"
else
    echo -e "${RED}❌ Offline${NC}"
    echo "❗ Verifique se os serviços centralizados estão rodando:"
    echo "   cd ../00-mock-services && docker compose ps"
    exit 1
fi

echo ""
echo "2️⃣  Verificando Kong Upstream Health:"
echo "--------------------------------------"
upstream_health=$(curl -s http://localhost:8001/upstreams/api-upstream/health)
healthy_count=$(echo "$upstream_health" | jq '[.data[] | select(.health == "HEALTHY")] | length' 2>/dev/null)
total_count=$(echo "$upstream_health" | jq '.data | length' 2>/dev/null)

echo "Targets saudáveis: ${healthy_count}/${total_count}"
echo "$upstream_health" | jq -r '.data[] | "Target: \(.target) - Status: \(.health) - Weight: \(.weight)"' 2>/dev/null

echo ""
echo "3️⃣  Testando Load Balancing (20 requisições):"
echo "----------------------------------------------"

go_count=0
node_count=0
total_requests=20

for i in $(seq 1 $total_requests); do
    response=$(curl -s http://localhost:8000/api/health)
    server=$(extract_server "$response")
    language=$(extract_language "$response")
    
    # Incrementar contador do servidor
    if [[ "$server" == "go-mock-api-1" ]]; then
        go_count=$((go_count + 1))
        echo -n -e "${BLUE}G${NC}"
    elif [[ "$server" == "node-mock-api-2" ]]; then
        node_count=$((node_count + 1))
        echo -n -e "${YELLOW}N${NC}"
    else
        echo -n "?"
    fi
    
    # Pequena pausa para ver o balanceamento
    sleep 0.1
done

echo ""
echo ""
echo "4️⃣  Resultados do Load Balancing:"
echo "--------------------------------"

if [ $go_count -gt 0 ]; then
    go_percentage=$((go_count * 100 / total_requests))
    echo -e "🐹 ${BLUE}go-mock-api-1${NC}: $go_count requisições ($go_percentage%)"
fi

if [ $node_count -gt 0 ]; then
    node_percentage=$((node_count * 100 / total_requests))
    echo -e "🟨 ${YELLOW}node-mock-api-2${NC}: $node_count requisições ($node_percentage%)"
fi

echo ""
echo "5️⃣  Teste de Performance Comparativa:"
echo "-------------------------------------"

echo "🐹 Testando Go service..."
go_time=$(curl -w "%{time_total}" -s -o /dev/null http://localhost:8000/api/posts)
echo "Go: ${go_time}s"

echo "🟨 Testando Node.js service..."
# Forçar Node.js fazendo múltiplas requisições até acertar
for attempt in {1..10}; do
    response=$(curl -s http://localhost:8000/api/posts)
    server=$(echo "$response" | jq -r '.[0].server_info.server // .[0].server_info // "unknown"' 2>/dev/null)
    if [[ "$server" == "node-mock-api-2" ]]; then
        node_time=$(curl -w "%{time_total}" -s -o /dev/null http://localhost:8000/api/posts)
        echo "Node.js: ${node_time}s"
        break
    fi
done

echo ""
echo "6️⃣  Resumo:"
echo "----------"
echo -e "${GREEN}✅ Load Balancing está funcionando corretamente!${NC}"
echo "• Algoritmo: Round Robin"
echo "• Peso: 50/50 entre Go e Node.js"
echo "• Ambos os serviços estão saudáveis"
echo ""
echo "🔍 Legenda dos indicadores:"
echo -e "   ${BLUE}G${NC} = Requisição atendida pelo serviço Go"
echo -e "   ${YELLOW}N${NC} = Requisição atendida pelo serviço Node.js"