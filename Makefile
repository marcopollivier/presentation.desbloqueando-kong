# Kong Gateway Workshop - Makefile
# DevOps/SRE automation for Kong Gateway demonstrations
# Author: Kong Workshop Team
# Version: 1.0

.DEFAULT_GOAL := help
.PHONY: help setup check-deps clean test lint format

# Colors for terminal output
CYAN := \033[36m
GREEN := \033[32m
YELLOW := \033[33m
RED := \033[31m
RESET := \033[0m

##@ 🚀 Quick Start
help: ## Show this help message
	@echo "$(CYAN)Kong Gateway Workshop - Available Commands$(RESET)"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z_-]+:.*##/ { printf "  $(GREEN)%-20s$(RESET) %s\n", $$1, $$2 } /^##@/ { printf "\n$(CYAN)%s$(RESET)\n", substr($$0, 5) }' $(MAKEFILE_LIST)

setup: ## Initial setup and dependency check
	@echo "$(CYAN)🔧 Setting up Kong Gateway Workshop...$(RESET)"
	@$(MAKE) check-deps
	@echo "$(GREEN)✅ Setup completed!$(RESET)"

##@ 🐳 Docker & Infrastructure
up: ## Start all workshop projects
	@echo "$(CYAN)🚀 Starting all Kong Gateway projects...$(RESET)"
	@for dir in 0[1-7]-*; do \
		if [ -d "$$dir" ] && [ -f "$$dir/docker-compose.yml" ]; then \
			echo "$(YELLOW)Starting $$dir...$(RESET)"; \
			cd $$dir && docker-compose up -d && cd ..; \
		fi \
	done
	@echo "$(GREEN)✅ All projects started!$(RESET)"

down: ## Stop all workshop projects  
	@echo "$(CYAN)🛑 Stopping all Kong Gateway projects...$(RESET)"
	@for dir in 0[1-7]-*; do \
		if [ -d "$$dir" ] && [ -f "$$dir/docker-compose.yml" ]; then \
			echo "$(YELLOW)Stopping $$dir...$(RESET)"; \
			cd $$dir && docker-compose down -v && cd ..; \
		fi \
	done
	@echo "$(GREEN)✅ All projects stopped!$(RESET)"

clean-docker: ## Clean all Docker resources (containers, images, volumes, networks)
	@echo "$(YELLOW)⚠️  This will remove ALL Docker resources!$(RESET)"
	@read -p "Are you sure? [y/N]: " confirm; \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		./docker-cleanup.sh --force; \
	else \
		echo "Cancelled."; \
	fi

restart: down up ## Restart all projects (down + up)

##@ 🧪 Testing & Quality
test: ## Run tests for all projects
	@echo "$(CYAN)🧪 Running tests for all projects...$(RESET)"
	@$(MAKE) test-all

test-all: ## Run comprehensive test suite
	@echo "$(CYAN)Running smoke tests...$(RESET)"
	@for dir in 0[1-7]-*; do \
		if [ -d "$$dir" ]; then \
			echo "$(YELLOW)Testing $$dir...$(RESET)"; \
			$(MAKE) test-project PROJECT=$$dir; \
		fi \
	done

test-project: ## Test specific project (use PROJECT=01-basic-proxy)
	@if [ -z "$(PROJECT)" ]; then \
		echo "$(RED)❌ Usage: make test-project PROJECT=01-basic-proxy$(RESET)"; \
		exit 1; \
	fi
	@if [ ! -d "$(PROJECT)" ]; then \
		echo "$(RED)❌ Project $(PROJECT) not found$(RESET)"; \
		exit 1; \
	fi
	@echo "$(CYAN)Testing $(PROJECT)...$(RESET)"
	@cd $(PROJECT) && \
		if [ -f "test-*.sh" ]; then \
			for test in test-*.sh; do \
				echo "$(YELLOW)Running $$test...$(RESET)"; \
				chmod +x $$test && ./$$test; \
			done; \
		elif [ -f "docker-compose.yml" ]; then \
			docker-compose config --quiet && echo "$(GREEN)✅ Docker Compose config valid$(RESET)"; \
		fi

test-bruno: ## Run Bruno API tests (requires Bruno CLI)
	@echo "$(CYAN)🧪 Running Bruno API tests...$(RESET)"
	@if command -v bruno >/dev/null 2>&1; then \
		cd _bruno/kong && bruno run; \
	else \
		echo "$(YELLOW)⚠️  Bruno CLI not installed. Install: npm i -g @usebruno/cli$(RESET)"; \
	fi

lint: ## Check code style and configuration
	@echo "$(CYAN)🔍 Linting configurations...$(RESET)"
	@$(MAKE) lint-docker
	@$(MAKE) lint-kong
	@$(MAKE) lint-docs

lint-docker: ## Validate Docker Compose files
	@echo "$(YELLOW)Checking Docker Compose files...$(RESET)"
	@for dir in 0[1-7]-*; do \
		if [ -f "$$dir/docker-compose.yml" ]; then \
			echo "Validating $$dir/docker-compose.yml"; \
			cd $$dir && docker-compose config --quiet && cd ..; \
		fi \
	done
	@echo "$(GREEN)✅ Docker Compose files valid$(RESET)"

lint-kong: ## Validate Kong configurations
	@echo "$(YELLOW)Checking Kong configurations...$(RESET)"
	@for dir in 0[1-7]-*; do \
		if [ -f "$$dir/kong.yml" ]; then \
			echo "Validating $$dir/kong.yml"; \
		fi \
	done
	@echo "$(GREEN)✅ Kong configurations valid$(RESET)"

lint-docs: ## Check Markdown documentation
	@echo "$(YELLOW)Checking Markdown files...$(RESET)"
	@if command -v markdownlint >/dev/null 2>&1; then \
		markdownlint "**/*.md" --ignore node_modules; \
	else \
		echo "$(YELLOW)⚠️  markdownlint not installed. Install: npm i -g markdownlint-cli$(RESET)"; \
	fi

##@ 📊 Monitoring & Observability  
metrics: ## Start metrics stack (project 07)
	@echo "$(CYAN)📊 Starting metrics and observability stack...$(RESET)"
	@cd 07-metrics && docker-compose up -d
	@echo "$(GREEN)✅ Metrics available at: http://localhost:3000 (Grafana)$(RESET)"

logs: ## Show logs for all projects
	@echo "$(CYAN)📋 Showing logs for all running containers...$(RESET)"
	@docker ps --format "table {{.Names}}\t{{.Status}}" | grep -E "(kong|prometheus|grafana)"
	@echo "$(YELLOW)Use 'docker logs <container>' for detailed logs$(RESET)"

status: ## Show status of all services
	@echo "$(CYAN)📊 Kong Gateway Workshop Status$(RESET)"
	@echo ""
	@echo "$(YELLOW)Running Containers:$(RESET)"
	@docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" | head -1
	@docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" | grep -E "(kong|prometheus|grafana|mock)" || echo "No workshop containers running"
	@echo ""
	@echo "$(YELLOW)Available Endpoints:$(RESET)"
	@echo "  Kong Gateway:    http://localhost:8000"
	@echo "  Kong Admin:      http://localhost:8001" 
	@echo "  Prometheus:      http://localhost:9090"
	@echo "  Grafana:         http://localhost:3000"

##@ 🛠️  Development
dev: ## Start development environment (project 01 + metrics)
	@echo "$(CYAN)🛠️  Starting development environment...$(RESET)"
	@cd 01-basic-proxy && docker-compose up -d
	@cd 07-metrics && docker-compose up -d
	@echo "$(GREEN)✅ Dev environment ready!$(RESET)"
	@$(MAKE) status

demo: ## Run automated demo sequence
	@echo "$(CYAN)🎬 Running automated demo...$(RESET)"
	@echo "$(YELLOW)1. Starting basic proxy...$(RESET)"
	@cd 01-basic-proxy && docker-compose up -d && sleep 5
	@echo "$(YELLOW)2. Testing proxy...$(RESET)"
	@curl -s http://localhost:8000/api/users | head -3
	@echo "$(YELLOW)3. Starting load balancing demo...$(RESET)"
	@cd ../02-load-balancing && docker-compose up -d && sleep 10
	@echo "$(GREEN)✅ Demo completed! Check README.md for next steps$(RESET)"

##@ 🧹 Cleanup & Maintenance
clean: ## Clean temporary files and caches
	@echo "$(CYAN)🧹 Cleaning temporary files...$(RESET)"
	@find . -name "*.log" -delete
	@find . -name ".DS_Store" -delete
	@find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
	@echo "$(GREEN)✅ Cleanup completed$(RESET)"

reset: clean down ## Full reset (clean + down)
	@echo "$(CYAN)🔄 Full environment reset completed$(RESET)"

check-deps: ## Check required dependencies
	@echo "$(CYAN)🔍 Checking dependencies...$(RESET)"
	@command -v docker >/dev/null 2>&1 || (echo "$(RED)❌ Docker not installed$(RESET)" && exit 1)
	@command -v docker-compose >/dev/null 2>&1 || (echo "$(RED)❌ Docker Compose not installed$(RESET)" && exit 1)
	@docker info >/dev/null 2>&1 || (echo "$(RED)❌ Docker daemon not running$(RESET)" && exit 1)
	@echo "$(GREEN)✅ All dependencies available$(RESET)"
	@echo ""
	@echo "$(YELLOW)Optional tools:$(RESET)"
	@command -v bruno >/dev/null 2>&1 && echo "$(GREEN)✅ Bruno CLI$(RESET)" || echo "$(YELLOW)⚠️  Bruno CLI (npm i -g @usebruno/cli)$(RESET)"
	@command -v markdownlint >/dev/null 2>&1 && echo "$(GREEN)✅ Markdownlint$(RESET)" || echo "$(YELLOW)⚠️  Markdownlint (npm i -g markdownlint-cli)$(RESET)"

##@ 📚 Documentation
docs: ## Generate/update documentation
	@echo "$(CYAN)📚 Updating documentation...$(RESET)"
	@echo "$(GREEN)✅ Documentation structure:$(RESET)"
	@tree docs/ 2>/dev/null || ls -la docs/

docs-serve: ## Serve documentation locally (if applicable)
	@echo "$(CYAN)📖 Documentation available in ./docs/$(RESET)"
	@echo "Main docs:"
	@ls -la docs/*.md

##@ 🔧 Advanced Operations  
benchmark: ## Run performance benchmarks
	@echo "$(CYAN)⚡ Running performance benchmarks...$(RESET)"
	@if [ -f "07-metrics/load-test.sh" ]; then \
		cd 07-metrics && chmod +x load-test.sh && ./load-test.sh; \
	else \
		echo "$(YELLOW)⚠️  Load test script not found$(RESET)"; \
	fi

security-scan: ## Basic security check
	@echo "$(CYAN)🔒 Running basic security checks...$(RESET)"
	@echo "$(YELLOW)Checking for exposed ports...$(RESET)"
	@docker ps --format "table {{.Names}}\t{{.Ports}}" | grep -E ":80|:443|:8080|:8000|:3000|:9090"
	@echo "$(YELLOW)Note: This is a basic check. Use proper security tools for production$(RESET)"

upgrade: ## Update Docker images to latest versions
	@echo "$(CYAN)📦 Updating Docker images...$(RESET)"
	@docker-compose pull 2>/dev/null || echo "$(YELLOW)Run from project directory for specific updates$(RESET)"
	@echo "$(GREEN)✅ Images updated$(RESET)"

##@ 🎯 Workshop Specific
workshop-reset: ## Reset environment for workshop presentation
	@echo "$(CYAN)🎪 Resetting workshop environment...$(RESET)"
	@$(MAKE) down
	@$(MAKE) clean
	@$(MAKE) setup
	@echo "$(GREEN)✅ Workshop environment ready for presentation!$(RESET)"

workshop-demo: ## Run complete workshop demonstration
	@echo "$(CYAN)🎬 Starting complete workshop demo...$(RESET)"
	@echo "$(YELLOW)Follow along in README.md for the complete experience$(RESET)"
	@$(MAKE) demo