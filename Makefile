.DEFAULT_GOAL := help
.PHONY: help 01 02 03 04 05 06 07 down

help: ## Mostra os comandos disponíveis
	@echo "Kong Gateway Workshop - Comandos Disponíveis:"
	@echo ""
	@echo "  make 01    Roda o projeto 01-basic-proxy"
	@echo "  make 02    Roda o projeto 02-load-balancing"
	@echo "  make 03    Roda o projeto 03-authentication"
	@echo "  make 04    Roda o projeto 04-rate-limiting"
	@echo "  make 05    Roda o projeto 05-transformations"
	@echo "  make 06    Roda o projeto 06-custom-plugin"
	@echo "  make 07    Roda o projeto 07-metrics"
	@echo "  make down  Para todos os projetos"
	@echo ""

00: ## Inicia os mock services
	@echo "Criando rede kong-shared se não existir..."
	@docker network create kong-shared 2>/dev/null || true
	@echo "Subindo mock services..."
	cd 00-mock-services && docker compose up -d
	@echo "Conectando mocks à rede kong-shared..."
	@docker network connect kong-shared go-mock-api-1 2>/dev/null || true
	@docker network connect kong-shared node-mock-api-2 2>/dev/null || true
	@echo "✅ Mock services prontos!"

01: ## Roda o projeto 01-basic-proxy
	cd 01-basic-proxy && docker compose up

02: ## Roda o projeto 02-load-balancing
	cd 02-load-balancing && docker compose up

03: ## Roda o projeto 03-authentication
	cd 03-authentication && docker compose up

04: ## Roda o projeto 04-rate-limiting
	cd 04-rate-limiting && docker compose up

05: ## Roda o projeto 05-transformations
	cd 05-transformations && docker compose up

06: ## Roda o projeto 06-custom-plugin
	cd 06-custom-plugin && docker compose up

07: ## Roda o projeto 07-metrics
	cd 07-metrics && docker compose up

down: ## Para todos os projetos
	@for dir in 0[1-7]-*; do \
		if [ -d "$$dir" ] && [ -f "$$dir/docker-compose.yml" ]; then \
			echo "Parando $$dir..."; \
			cd $$dir && docker compose down && cd ..; \
		fi \
	done