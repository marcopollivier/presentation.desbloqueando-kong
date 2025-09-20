#!/bin/bash

# Configurações
set -euo pipefail  # Fail fast em caso de erro

echo "🎯 Kong Gateway Workshop - Demonstração Completa"
echo "================================================="
echo ""
echo "Este script executa uma demonstração de todos os projetos."
echo "Pressione ENTER para continuar ou Ctrl+C para cancelar..."
read

# Obter diretório do script automaticamente
WORKSHOP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "📍 Diretório do workshop: $WORKSHOP_DIR"

# Verificar dependências
check_dependencies() {
    echo ""
    echo "🔍 Verificando dependências..."
    
    if ! command -v docker &> /dev/null; then
        echo "❌ Docker não encontrado. Por favor, instale o Docker primeiro."
        exit 1
    fi
    
    # Verificar qual versão do Docker Compose está disponível
    if command -v docker-compose &> /dev/null; then
        DOCKER_COMPOSE_CMD="docker-compose"
        echo "✅ Usando docker-compose (legado)"
    elif docker compose version &> /dev/null; then
        DOCKER_COMPOSE_CMD="docker compose"
        echo "✅ Usando docker compose (plugin)"
    else
        echo "❌ Docker Compose não encontrado. Por favor, instale o Docker Compose primeiro."
        exit 1
    fi
    
    # Verificar se Docker está rodando
    if ! docker info &> /dev/null; then
        echo "❌ Docker não está rodando. Por favor, inicie o Docker primeiro."
        exit 1
    fi
    
    # jq é opcional, mas útil
    if ! command -v jq &> /dev/null; then
        echo "⚠️  jq não encontrado (opcional). JSON será mostrado sem formatação."
        JQ_AVAILABLE=false
    else
        JQ_AVAILABLE=true
    fi
    
    echo "✅ Dependências verificadas com sucesso!"
}

# Executar verificações
check_dependencies

# Função para aguardar Kong estar pronto
wait_for_kong() {
    local max_attempts=30
    local attempt=1
    
    echo "⏳ Aguardando Kong estar pronto..."
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s http://localhost:8001/status >/dev/null 2>&1; then
            echo "✅ Kong está pronto!"
            return 0
        fi
        
        echo "   Tentativa $attempt/$max_attempts..."
        sleep 2
        ((attempt++))
    done
    
    echo "❌ Kong não respondeu após $max_attempts tentativas"
    return 1
}

# Função para verificar se porta está disponível
check_port() {
    local port=$1
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo "❌ Porta $port está em uso"
        return 1
    fi
    return 0
}

# Variável para controle de cleanup
CURRENT_PROJECT_DIR=""

# Função de cleanup
cleanup() {
    echo ""
    echo "🧹 Executando cleanup..."
    if [ -n "$CURRENT_PROJECT_DIR" ] && [ -d "$CURRENT_PROJECT_DIR" ]; then
        cd "$CURRENT_PROJECT_DIR"
        echo "   Parando containers do projeto..."
        $DOCKER_COMPOSE_CMD down -v >/dev/null 2>&1
    fi
    echo "✅ Cleanup concluído"
    exit 0
}

# Configurar trap para cleanup
trap cleanup SIGINT SIGTERM

# Função para executar demonstração de um projeto
demo_project() {
    local project_dir=$1
    local project_name=$2
    
    echo ""
    echo "🚀 Demonstrando: $project_name"
    echo "========================================"
    
    local full_path="$WORKSHOP_DIR/$project_dir"
    
    if [ ! -d "$full_path" ]; then
        echo "❌ Diretório $full_path não encontrado"
        return 1
    fi
    
    cd "$full_path" || {
        echo "❌ Não foi possível acessar $full_path"
        return 1
    }
    
    CURRENT_PROJECT_DIR="$full_path"
    
    echo "📍 Diretório atual: $(pwd)"
    echo "📋 Conteúdo do projeto:"
    ls -la
    
    # Verificar se portas estão disponíveis
    echo ""
    echo "🔍 Verificando portas..."
    if ! check_port 8000 || ! check_port 8001; then
        echo "   Alguma porta do Kong está em uso. Deseja continuar? (y/N)"
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            echo "   Pulando projeto $project_name"
            return 0
        fi
    fi
    
    echo ""
    echo "⚡ Subindo ambiente..."
    if ! $DOCKER_COMPOSE_CMD up -d; then
        echo "❌ Falha ao subir ambiente do projeto $project_name"
        return 1
    fi
    
    echo ""
    if wait_for_kong; then
        echo "🔍 Status do Kong:"
        if [ "$JQ_AVAILABLE" = true ]; then
            curl -s http://localhost:8001/status | jq
        else
            curl -s http://localhost:8001/status
        fi
    else
        echo "⚠️  Kong não está respondendo, mas continuando..."
    fi
    
    echo ""
    echo "📖 Para continuar com este projeto:"
    echo "   cd $full_path"
    echo "   cat README.md"
    
    echo ""
    echo "Pressione ENTER para parar este projeto e continuar..."
    read
    
    echo "🛑 Parando ambiente..."
    $DOCKER_COMPOSE_CMD down -v
    CURRENT_PROJECT_DIR=""
    echo "✅ Projeto $project_name finalizado"
}

# Executar demonstrações
echo ""
echo "🎬 Iniciando demonstrações dos projetos básicos..."
echo "=================================================="

demo_project "01-basic-proxy" "Kong Básico - Proxy Simples"
demo_project "02-authentication" "Autenticação (Key Auth & JWT)"
demo_project "03-rate-limiting" "Rate Limiting e Controle de Tráfego"
demo_project "04-load-balancing" "Load Balancing e Health Checks"
demo_project "05-transformations" "Transformações de Request/Response"
demo_project "06-observability" "Observabilidade - Logging e Monitoramento"

echo ""
echo "🎓 Projetos avançados requerem configuração adicional:"
echo "========================================================"
echo ""
echo "🔧 Plugin Customizado:"
echo "   cd $WORKSHOP_DIR/07-custom-plugin"
echo "   docker build -t kong-custom ."
echo "   $DOCKER_COMPOSE_CMD up -d"
echo ""
echo "🐹 Lua Deep Dive:"  
echo "   cd $WORKSHOP_DIR/08-lua-deep-dive"
echo "   docker build -t kong-lua ."
echo "   $DOCKER_COMPOSE_CMD up -d"
echo ""
echo "🚀 Go Plugin:"
echo "   cd $WORKSHOP_DIR/09-go-plugin"
echo "   $DOCKER_COMPOSE_CMD up -d  # Build automático via docker-compose"
echo "   ./performance-test.sh  # Teste de performance"
echo ""
echo "🔗 Lua Embedding em Go:"
echo "   cd $WORKSHOP_DIR/10-lua-embedding/go-lua-host"
echo "   go run main.go basic     # Exemplo básico"
echo "   go run main.go config    # Configuração dinâmica"
echo "   go run main.go plugins   # Sistema de plugins"
echo "   go run main.go sandbox   # Sandbox e segurança"
echo "   go run main.go benchmark # Performance comparisons"
echo ""

echo "🎉 Demonstração completa!"
echo "========================="
echo ""
echo "📚 Para usar individualmente:"
echo "   cd $WORKSHOP_DIR/<projeto>"
echo "   $DOCKER_COMPOSE_CMD up -d"
echo "   # Seguir instruções no README.md"
echo "   $DOCKER_COMPOSE_CMD down -v"
echo ""
echo "💡 Dicas para a palestra:"
echo "   - Cada projeto é independente"
echo "   - Demonstre conceitos de forma progressiva"  
echo "   - Use os scripts demo.sh quando disponíveis"
echo "   - Mostre tanto configuração declarativa quanto Admin API"
echo "   - Enfatize casos de uso reais"
echo ""
echo "🆘 Em caso de problemas:"
echo "   - Verifique se Docker está rodando"
echo "   - Limpe containers: $DOCKER_COMPOSE_CMD down -v"
echo "   - Libere portas: docker ps para verificar containers ativos"
