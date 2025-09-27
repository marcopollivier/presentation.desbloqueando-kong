#!/bin/bash

# Script para limpar todos os containers Docker do projeto Kong
# Autor: DevOps/SRE Kong Gateway
# Data: $(date)

set -e

echo "🧹 Limpeza completa de containers Docker do projeto Kong"
echo "======================================================"

# Função para verificar se docker está rodando
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        echo "❌ Docker não está rodando. Inicie o Docker primeiro."
        exit 1
    fi
}

# Função para parar containers por projeto
stop_project_containers() {
    local project_dir=$1
    local project_name=$(basename "$project_dir")
    
    if [ -d "$project_dir" ] && [ -f "$project_dir/docker-compose.yml" ]; then
        echo "🛑 Parando containers do $project_name..."
        cd "$project_dir"
        docker compose down --remove-orphans >/dev/null 2>&1 || true
        cd - >/dev/null
        echo "✅ $project_name limpo"
    fi
}

# Função para remover containers relacionados ao Kong
cleanup_kong_containers() {
    echo "🔍 Procurando containers do Kong para remover..."
    
    # Para containers que contenham 'kong' no nome
    kong_containers=$(docker ps -a --filter "name=kong" --format "{{.Names}}" 2>/dev/null || true)
    if [ -n "$kong_containers" ]; then
        echo "🛑 Parando containers do Kong: $kong_containers"
        echo "$kong_containers" | xargs -r docker stop >/dev/null 2>&1 || true
        echo "$kong_containers" | xargs -r docker rm >/dev/null 2>&1 || true
        echo "✅ Containers do Kong removidos"
    else
        echo "ℹ️  Nenhum container do Kong encontrado"
    fi
    
    # Para containers que contenham 'desbloqueando-kong' no nome  
    project_containers=$(docker ps -a --filter "name=desbloqueando-kong" --format "{{.Names}}" 2>/dev/null || true)
    if [ -n "$project_containers" ]; then
        echo "🛑 Parando containers do projeto: $project_containers"
        echo "$project_containers" | xargs -r docker stop >/dev/null 2>&1 || true
        echo "$project_containers" | xargs -r docker rm >/dev/null 2>&1 || true
        echo "✅ Containers do projeto removidos"
    fi
}

# Função para limpar volumes órfãos
cleanup_volumes() {
    echo "🗑️  Removendo volumes órfãos..."
    docker volume prune -f >/dev/null 2>&1 || true
    echo "✅ Volumes órfãos removidos"
}

# Função para limpar networks órfãs
cleanup_networks() {
    echo "🌐 Removendo networks órfãs..."
    docker network prune -f >/dev/null 2>&1 || true
    echo "✅ Networks órfãs removidas"
}

# Função principal
main() {
    check_docker
    
    echo "🚀 Iniciando limpeza..."
    echo
    
    # Para cada projeto
    stop_project_containers "01-basic-proxy"
    stop_project_containers "02-load-balancing"  
    stop_project_containers "03-authentication"
    stop_project_containers "04-rate-limiting"
    stop_project_containers "05-transformations"
    stop_project_containers "06-custom-plugin"
    stop_project_containers "07-metrics"
    
    echo
    cleanup_kong_containers
    echo
    cleanup_volumes
    cleanup_networks
    
    echo
    echo "🎉 Limpeza completa finalizada!"
    echo "📊 Status atual dos containers:"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "Nenhum container rodando"
}

# Verificar se foi chamado com --help
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    echo "Uso: $0 [--force]"
    echo ""
    echo "Este script para e remove todos os containers Docker relacionados ao projeto Kong."
    echo ""
    echo "Opções:"
    echo "  --force    Executa sem confirmação"  
    echo "  --help     Mostra esta ajuda"
    echo ""
    echo "O script irá:"
    echo "  1. Parar todos os containers dos projetos Kong"
    echo "  2. Remover containers órfãos"
    echo "  3. Limpar volumes não utilizados"
    echo "  4. Limpar networks não utilizadas"
    exit 0
fi

# Confirmação antes de executar (exceto se --force)
if [[ "$1" != "--force" ]]; then
    echo "⚠️  Este script irá parar e remover TODOS os containers Docker do projeto Kong."
    echo "   Você tem certeza? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "❌ Operação cancelada."
        exit 0
    fi
fi

# Executar limpeza
main