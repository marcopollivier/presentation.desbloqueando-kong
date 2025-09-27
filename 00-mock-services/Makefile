## Mock Services - Centralized mock APIs for Kong examples

.DEFAULT_GOAL := help

# Network name for external communication
NETWORK_NAME := mock-services-net

## Setup and Management
setup: network build ## Configura network e build dos serviços
	@echo "✅ Mock services configurados"

network: ## Cria network externa para comunicação
	@docker network create $(NETWORK_NAME) 2>/dev/null || true
	@echo "✅ Network $(NETWORK_NAME) criada/verificada"

build: ## Build das imagens dos mock services
	@docker compose build --no-cache
	@echo "✅ Imagens construídas"

up: network ## Sobe os mock services
	@docker compose up -d
	@echo "✅ Mock services iniciados"
	@echo "🌐 Go Mock API: http://localhost:3001"
	@echo "🌐 Node Mock API: http://localhost:3002"

down: ## Para os mock services
	@docker compose down
	@echo "✅ Mock services parados"

clean: down ## Remove containers, images e network
	@docker compose down --rmi all --volumes --remove-orphans
	@docker network rm $(NETWORK_NAME) 2>/dev/null || true
	@echo "✅ Limpeza concluída"

## Monitoring
logs: ## Mostra logs dos serviços
	@docker compose logs -f

status: ## Status dos serviços
	@docker compose ps

health: ## Health check dos serviços
	@echo "🔍 Verificando saúde dos serviços..."
	@curl -s http://localhost:3001/health | jq . || echo "❌ Go service não responde"
	@curl -s http://localhost:3002/health | jq . || echo "❌ Node service não responde"

## Testing
test: ## Testa endpoints básicos
	@echo "🧪 Testando Go Mock API..."
	@curl -s http://localhost:3001/users | jq .
	@echo "\n🧪 Testando Node Mock API..."
	@curl -s http://localhost:3002/users | jq .

help: ## Mostra esta ajuda
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

.PHONY: setup network build up down clean logs status health test help