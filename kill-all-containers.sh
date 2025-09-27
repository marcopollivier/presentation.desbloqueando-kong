#!/bin/bash

# Script simples para matar todos os containers Docker
# Uso rápido: ./kill-all-containers.sh

echo "💀 Matando TODOS os containers Docker..."

# Para todos os containers rodando
if [ "$(docker ps -q)" ]; then
    echo "🛑 Parando containers rodando..."
    docker stop $(docker ps -q)
    echo "✅ Containers parados"
else
    echo "ℹ️  Nenhum container rodando"
fi

# Remove todos os containers
if [ "$(docker ps -aq)" ]; then
    echo "🗑️  Removendo containers..."
    docker rm $(docker ps -aq)
    echo "✅ Containers removidos"
else
    echo "ℹ️  Nenhum container para remover"
fi

# Limpa volumes órfãos
echo "🧹 Limpando volumes órfãos..."
docker volume prune -f

# Limpa networks órfãs  
echo "🌐 Limpando networks órfãs..."
docker network prune -f

echo ""
echo "🎉 Limpeza TOTAL completa!"
echo "📊 Containers restantes:"
docker ps -a --format "table {{.Names}}\t{{.Status}}" 2>/dev/null || echo "Nenhum container encontrado"