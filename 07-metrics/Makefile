## Kong Gateway - Metrics & Load Balancing Demo

.DEFAULT_GOAL := help

## Setup and Management
up: ## Sobe stack completa (requer mock services rodando)
	@echo "🚀 Subindo stack de métricas..."
	@docker compose up -d
	@echo "✅ Stack iniciada"

down: ## Para a stack de métricas
	@docker-compose down
	@echo "✅ Stack parada"

clean: ## Remove containers, volumes e imagens
	@docker compose down --rmi all --volumes --remove-orphans
	@echo "✅ Limpeza concluída"

restart: down up ## Reinicia a stack completa

## Mock Services Management
setup-mocks: ## Configura e sobe os mock services
	@echo "🔧 Configurando mock services..."
	@cd ../00-mock-services && make setup && make up
	@echo "✅ Mock services configurados e iniciados"

stop-mocks: ## Para os mock services
	@cd ../00-mock-services && make down

## Demo and Testing
demo: ## Executa demo completo
	@echo "🎬 Iniciando demo completo..."
	@./load-test.sh

load-test: ## Executa teste de carga interativo
	@./load-test.sh

## Monitoring
logs: ## Mostra logs da stack
	@docker compose logs -f

status: ## Verifica status dos serviços
	@echo "📊 Status da stack:"
	@docker compose ps
	@echo ""
	@echo "🔍 Health checks:"
	@curl -s http://localhost:8001/status | jq . 2>/dev/null || echo "❌ Kong não responde"

metrics: ## Mostra métricas atuais do Kong
	@echo "📈 Métricas atuais:"
	@curl -s http://localhost:8100/metrics | grep -E "(kong_http_requests_total|kong_request_latency)" | head -10

urls: ## Mostra URLs importantes
	@echo "🌐 URLs importantes:"
	@echo "  Kong Proxy:    http://localhost:8000"
	@echo "  Kong Admin:    http://localhost:8001"
	@echo "  Kong Metrics:  http://localhost:8100/metrics"
	@echo "  Prometheus:    http://localhost:9090"
	@echo "  Grafana:       http://localhost:3000 (admin/admin123)"
	@echo ""
	@echo "🧪 Teste rápido:"
	@echo "  curl http://localhost:8000/api/users"

help: ## Mostra esta ajuda
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

.PHONY: up down clean restart setup-mocks stop-mocks demo load-test logs status metrics urls help