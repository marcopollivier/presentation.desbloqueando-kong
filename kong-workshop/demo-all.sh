#!/bin/bash

echo "🎯 Kong Gateway Workshop - Demonstração Completa"
echo "================================================="
echo ""
echo "Este script executa uma demonstração de todos os projetos."
echo "Pressione ENTER para continuar ou Ctrl+C para cancelar..."
read

WORKSHOP_DIR="/Users/U004334/dev/mpo/kong/kong-workshop"

# Função para executar demonstração de um projeto
demo_project() {
    local project_dir=$1
    local project_name=$2
    
    echo ""
    echo "🚀 Demonstrando: $project_name"
    echo "========================================"
    
    cd "$WORKSHOP_DIR/$project_dir" || exit 1
    
    echo "📍 Diretório atual: $(pwd)"
    echo "📋 Conteúdo do projeto:"
    ls -la
    
    echo ""
    echo "⚡ Subindo ambiente..."
    docker-compose up -d
    
    echo ""
    echo "⏳ Aguardando Kong estar pronto..."
    sleep 10
    
    echo ""
    echo "🔍 Status do Kong:"
    curl -s http://localhost:8001/status | jq 2>/dev/null || echo "Kong não está respondendo"
    
    echo ""
    echo "📖 Para continuar com este projeto:"
    echo "   cd $WORKSHOP_DIR/$project_dir"
    echo "   cat README.md"
    
    echo ""
    echo "Pressione ENTER para parar este projeto e continuar..."
    read
    
    docker-compose down -v
    echo "✅ Projeto $project_name finalizado"
}

# Executar demonstrações
demo_project "01-basic-proxy" "Kong Básico - Proxy Simples"
demo_project "02-authentication" "Autenticação (Key Auth & JWT)"
demo_project "03-rate-limiting" "Rate Limiting e Controle de Tráfego"
demo_project "04-load-balancing" "Load Balancing e Health Checks"
demo_project "05-transformations" "Transformações de Request/Response"
demo_project "06-observability" "Observabilidade - Logging e Monitoramento"

echo ""
echo "🎓 Projetos avançados requerem build de imagem:"
echo ""
echo "Plugin Customizado:"
echo "   cd $WORKSHOP_DIR/07-custom-plugin"
echo "   docker build -t kong-custom ."
echo "   docker-compose up -d"
echo ""
echo "Lua Deep Dive:"  
echo "   cd $WORKSHOP_DIR/08-lua-deep-dive"
echo "   docker build -t kong-lua ."
echo "   docker-compose up -d"
echo ""

echo "🎉 Demonstração completa!"
echo ""
echo "📚 Para usar individualmente:"
echo "   cd $WORKSHOP_DIR/<projeto>"
echo "   docker-compose up -d"
echo "   # Seguir instruções no README.md"
echo "   docker-compose down -v"
echo ""
echo "💡 Dicas para a palestra:"
echo "   - Cada projeto é independente"
echo "   - Demonstre conceitos de forma progressiva"  
echo "   - Use os scripts demo.sh quando disponíveis"
echo "   - Mostre tanto configuração declarativa quanto Admin API"
echo "   - Enfatize casos de uso reais"
