#!/bin/bash

# Script de limpeza completa do Docker
# ATENÇÃO: Este script remove TODOS os recursos Docker do sistema!

set -e

# Cores para output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para imprimir mensagens coloridas
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE} $1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

# Função para confirmar ação
confirm_action() {
    while true; do
        read -p "$(echo -e ${YELLOW}Você tem certeza? ${NC}[y/N]: )" yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* | "" ) return 1;;
            * ) echo "Por favor, responda y ou n.";;
        esac
    done
}

# Verificar se Docker está rodando
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        print_error "Docker não está rodando ou não está acessível!"
        exit 1
    fi
}

# Mostrar estatísticas atuais do Docker
show_docker_stats() {
    print_header "ESTATÍSTICAS ATUAIS DO DOCKER"
    
    echo -e "${BLUE}Containers:${NC}"
    docker ps -a --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Names}}" 2>/dev/null || echo "Nenhum container encontrado"
    
    echo -e "\n${BLUE}Imagens:${NC}"
    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}" 2>/dev/null || echo "Nenhuma imagem encontrada"
    
    echo -e "\n${BLUE}Volumes:${NC}"
    docker volume ls 2>/dev/null || echo "Nenhum volume encontrado"
    
    echo -e "\n${BLUE}Redes:${NC}"
    docker network ls 2>/dev/null || echo "Nenhuma rede encontrada"
    
    echo -e "\n${BLUE}Uso de espaço em disco:${NC}"
    docker system df 2>/dev/null || echo "Não foi possível obter informações de espaço"
}

# Parar todos os containers
stop_all_containers() {
    print_info "Parando todos os containers..."
    
    local running_containers=$(docker ps -q)
    if [ -n "$running_containers" ]; then
        docker stop $running_containers
        print_success "Containers parados com sucesso!"
    else
        print_info "Nenhum container em execução encontrado."
    fi
}

# Remover todos os containers
remove_all_containers() {
    print_info "Removendo todos os containers..."
    
    local all_containers=$(docker ps -aq)
    if [ -n "$all_containers" ]; then
        docker rm -f $all_containers
        print_success "Containers removidos com sucesso!"
    else
        print_info "Nenhum container encontrado para remoção."
    fi
}

# Remover todas as imagens
remove_all_images() {
    print_info "Removendo todas as imagens..."
    
    local all_images=$(docker images -aq)
    if [ -n "$all_images" ]; then
        docker rmi -f $all_images
        print_success "Imagens removidas com sucesso!"
    else
        print_info "Nenhuma imagem encontrada para remoção."
    fi
}

# Remover todos os volumes
remove_all_volumes() {
    print_info "Removendo todos os volumes..."
    
    local all_volumes=$(docker volume ls -q)
    if [ -n "$all_volumes" ]; then
        docker volume rm -f $all_volumes
        print_success "Volumes removidos com sucesso!"
    else
        print_info "Nenhum volume encontrado para remoção."
    fi
}

# Remover todas as redes customizadas
remove_all_networks() {
    print_info "Removendo todas as redes customizadas..."
    
    # Listar redes que não são as padrões (bridge, host, none)
    local custom_networks=$(docker network ls --filter type=custom -q)
    if [ -n "$custom_networks" ]; then
        docker network rm $custom_networks
        print_success "Redes customizadas removidas com sucesso!"
    else
        print_info "Nenhuma rede customizada encontrada para remoção."
    fi
}

# Limpeza completa do sistema
system_prune() {
    print_info "Executando limpeza completa do sistema Docker..."
    docker system prune -af --volumes
    print_success "Limpeza completa do sistema executada!"
}

# Função principal
main() {
    print_header "🐳 LIMPEZA COMPLETA DO DOCKER 🐳"
    
    print_warning "ATENÇÃO: Este script irá remover TODOS os recursos Docker do sistema:"
    echo "  • Todos os containers (parados e em execução)"
    echo "  • Todas as imagens Docker"
    echo "  • Todos os volumes"
    echo "  • Todas as redes customizadas"
    echo "  • Cache de build e recursos órfãos"
    echo ""
    print_warning "Esta ação é IRREVERSÍVEL!"
    echo ""
    
    if ! confirm_action; then
        print_info "Operação cancelada pelo usuário."
        exit 0
    fi
    
    # Verificar se Docker está funcionando
    check_docker
    
    # Mostrar estatísticas antes da limpeza
    show_docker_stats
    
    echo ""
    print_warning "Iniciando limpeza em 3 segundos... (Ctrl+C para cancelar)"
    sleep 3
    
    # Executar limpeza passo a passo
    print_header "INICIANDO LIMPEZA"
    
    stop_all_containers
    remove_all_containers
    remove_all_images
    remove_all_volumes
    remove_all_networks
    system_prune
    
    print_header "✨ LIMPEZA CONCLUÍDA ✨"
    print_success "Todos os recursos Docker foram removidos com sucesso!"
    
    # Mostrar estatísticas finais
    echo ""
    print_info "Estatísticas finais:"
    docker system df
}

# Verificar argumentos da linha de comando
case "${1:-}" in
    -h|--help)
        echo "Uso: $0 [opções]"
        echo ""
        echo "Opções:"
        echo "  -h, --help     Mostra esta mensagem de ajuda"
        echo "  -f, --force    Executa a limpeza sem confirmação (PERIGOSO!)"
        echo "  --stats-only   Mostra apenas as estatísticas atuais sem fazer limpeza"
        echo ""
        echo "Exemplos:"
        echo "  $0              # Execução interativa com confirmação"
        echo "  $0 --force      # Execução automática (sem confirmação)"
        echo "  $0 --stats-only # Apenas mostra estatísticas"
        exit 0
        ;;
    -f|--force)
        print_warning "Modo FORCE ativado - executando sem confirmação!"
        check_docker
        stop_all_containers
        remove_all_containers
        remove_all_images
        remove_all_volumes
        remove_all_networks
        system_prune
        print_success "Limpeza forçada concluída!"
        exit 0
        ;;
    --stats-only)
        check_docker
        show_docker_stats
        exit 0
        ;;
    "")
        main
        ;;
    *)
        print_error "Opção desconhecida: $1"
        echo "Use '$0 --help' para ver as opções disponíveis."
        exit 1
        ;;
esac