# OpenTelemetry Demo - Base14 Fork
# Makefile for development, testing, and CI simulation

.PHONY: help install build test lint clean ci docker helm docker-generate-protobuf check-clean-work-tree
.DEFAULT_GOAL := help

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

# Service directories
DOTNET_SERVICES := src/accounting src/cart
JAVA_SERVICES := src/ad src/fraud-detection
GO_SERVICES := src/checkout src/product-catalog
NODEJS_SERVICES := src/frontend src/payment src/flagd-ui
PYTHON_SERVICES := src/recommendation src/load-generator
PHP_SERVICES := src/quote
RUBY_SERVICES := src/email
RUST_SERVICES := src/shipping
CPP_SERVICES := src/currency

# Helm chart path
HELM_CHART := helm-chart/otel-demo

##@ Help
help: ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make $(YELLOW)<target>$(NC)\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  $(BLUE)%-15s$(NC) %s\n", $$1, $$2 } /^##@/ { printf "\n$(GREEN)%s$(NC)\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Installation
install: ## Install all dependencies for all services
	@echo "$(GREEN)Installing dependencies for all services...$(NC)"
	@$(MAKE) install-dotnet install-java install-go install-nodejs install-python install-php install-ruby install-rust install-cpp

install-dotnet: ## Install .NET dependencies
	@echo "$(BLUE)Installing .NET dependencies...$(NC)"
	@for service in $(DOTNET_SERVICES); do \
		if [ -d "$$service" ]; then \
			echo "Installing dependencies for $$service"; \
			(cd $$service && dotnet restore) || exit 1; \
		fi \
	done

install-java: ## Install Java dependencies
	@echo "$(BLUE)Installing Java dependencies...$(NC)"
	@for service in $(JAVA_SERVICES); do \
		if [ -d "$$service" ]; then \
			echo "Installing dependencies for $$service"; \
			(cd $$service && ./gradlew build --refresh-dependencies) || exit 1; \
		fi \
	done

install-go: ## Install Go dependencies
	@echo "$(BLUE)Installing Go dependencies...$(NC)"
	@for service in $(GO_SERVICES); do \
		if [ -d "$$service" ]; then \
			echo "Installing dependencies for $$service"; \
			(cd $$service && go mod download) || exit 1; \
		fi \
	done

install-nodejs: ## Install Node.js dependencies
	@echo "$(BLUE)Installing Node.js dependencies...$(NC)"
	@for service in $(NODEJS_SERVICES); do \
		if [ -d "$$service" ]; then \
			echo "Installing dependencies for $$service"; \
			(cd $$service && npm ci) || exit 1; \
		fi \
	done

install-python: ## Install Python dependencies
	@echo "$(BLUE)Installing Python dependencies...$(NC)"
	@for service in $(PYTHON_SERVICES); do \
		if [ -d "$$service" ]; then \
			echo "Installing dependencies for $$service"; \
			(cd $$service && pip install -r requirements.txt && pip install flake8 black pytest pytest-cov) || exit 1; \
		fi \
	done

install-php: ## Install PHP dependencies
	@echo "$(BLUE)Installing PHP dependencies...$(NC)"
	@for service in $(PHP_SERVICES); do \
		if [ -d "$$service" ]; then \
			echo "Installing dependencies for $$service"; \
			(cd $$service && composer install --prefer-dist --no-progress) || exit 1; \
		fi \
	done

install-ruby: ## Install Ruby dependencies
	@echo "$(BLUE)Installing Ruby dependencies...$(NC)"
	@for service in $(RUBY_SERVICES); do \
		if [ -d "$$service" ]; then \
			echo "Installing dependencies for $$service"; \
			(cd $$service && bundle install) || exit 1; \
		fi \
	done

install-rust: ## Install Rust dependencies
	@echo "$(BLUE)Installing Rust dependencies...$(NC)"
	@for service in $(RUST_SERVICES); do \
		if [ -d "$$service" ]; then \
			echo "Installing dependencies for $$service"; \
			(cd $$service && cargo build) || exit 1; \
		fi \
	done

install-cpp: ## Install C++ dependencies
	@echo "$(BLUE)Setting up C++ build environment...$(NC)"
	@for service in $(CPP_SERVICES); do \
		if [ -d "$$service" ]; then \
			echo "Setting up build for $$service"; \
			(cd $$service && mkdir -p build && cd build && cmake ..) || exit 1; \
		fi \
	done

##@ Building
build: ## Build all services
	@echo "$(GREEN)Building all services...$(NC)"
	@$(MAKE) build-dotnet build-java build-go build-nodejs build-python build-php build-ruby build-rust build-cpp

build-dotnet: ## Build .NET services
	@echo "$(BLUE)Building .NET services...$(NC)"
	@for service in $(DOTNET_SERVICES); do \
		if [ -d "$$service" ]; then \
			echo "Building $$service"; \
			(cd $$service && dotnet build --no-restore --configuration Release) || exit 1; \
		fi \
	done

build-java: ## Build Java services
	@echo "$(BLUE)Building Java services...$(NC)"
	@for service in $(JAVA_SERVICES); do \
		if [ -d "$$service" ]; then \
			echo "Building $$service"; \
			(cd $$service && ./gradlew build) || exit 1; \
		fi \
	done

build-go: ## Build Go services
	@echo "$(BLUE)Building Go services...$(NC)"
	@for service in $(GO_SERVICES); do \
		if [ -d "$$service" ]; then \
			echo "Building $$service"; \
			(cd $$service && go build -v ./...) || exit 1; \
		fi \
	done

build-nodejs: ## Build Node.js services
	@echo "$(BLUE)Building Node.js services...$(NC)"
	@for service in $(NODEJS_SERVICES); do \
		if [ -d "$$service" ] && [ -f "$$service/package.json" ]; then \
			echo "Building $$service"; \
			(cd $$service && \
			if grep -q '"build"' package.json; then \
				npm run build; \
			else \
				echo "No build script found for $$service, skipping"; \
			fi) || exit 1; \
		fi \
	done

build-python: ## Build Python services (validate syntax)
	@echo "$(BLUE)Validating Python services...$(NC)"
	@for service in $(PYTHON_SERVICES); do \
		if [ -d "$$service" ]; then \
			echo "Validating $$service"; \
			(cd $$service && python -m py_compile *.py) || exit 1; \
		fi \
	done

build-php: ## Build PHP services (validate syntax)
	@echo "$(BLUE)Validating PHP services...$(NC)"
	@for service in $(PHP_SERVICES); do \
		if [ -d "$$service" ]; then \
			echo "Validating $$service"; \
			(cd $$service && find . -name "*.php" -exec php -l {} \;) || exit 1; \
		fi \
	done

build-ruby: ## Build Ruby services (validate syntax)
	@echo "$(BLUE)Validating Ruby services...$(NC)"
	@for service in $(RUBY_SERVICES); do \
		if [ -d "$$service" ]; then \
			echo "Validating $$service"; \
			(cd $$service && find . -name "*.rb" -exec ruby -c {} \;) || exit 1; \
		fi \
	done

build-rust: ## Build Rust services
	@echo "$(BLUE)Building Rust services...$(NC)"
	@for service in $(RUST_SERVICES); do \
		if [ -d "$$service" ]; then \
			echo "Building $$service"; \
			(cd $$service && cargo build --verbose) || exit 1; \
		fi \
	done

build-cpp: ## Build C++ services
	@echo "$(BLUE)Building C++ services...$(NC)"
	@for service in $(CPP_SERVICES); do \
		if [ -d "$$service" ]; then \
			echo "Building $$service"; \
			(cd $$service/build && make) || exit 1; \
		fi \
	done

##@ Linting
lint: ## Run linting for all services
	@echo "$(GREEN)Running linting for all services...$(NC)"
	@$(MAKE) lint-dotnet lint-java lint-go lint-nodejs lint-python lint-php lint-ruby lint-rust lint-cpp

lint-dotnet: ## Lint .NET services
	@echo "$(BLUE)Linting .NET services...$(NC)"
	@for service in $(DOTNET_SERVICES); do \
		if [ -d "$$service" ]; then \
			echo "Linting $$service"; \
			(cd $$service && dotnet format --verify-no-changes --verbosity minimal) || exit 1; \
		fi \
	done

lint-java: ## Lint Java services
	@echo "$(BLUE)Linting Java services...$(NC)"
	@for service in $(JAVA_SERVICES); do \
		if [ -d "$$service" ]; then \
			echo "Linting $$service"; \
			(cd $$service && ./gradlew spotlessCheck) || exit 1; \
		fi \
	done

lint-go: ## Lint Go services
	@echo "$(BLUE)Linting Go services...$(NC)"
	@for service in $(GO_SERVICES); do \
		if [ -d "$$service" ]; then \
			echo "Linting $$service"; \
			(cd $$service && golangci-lint run) || exit 1; \
		fi \
	done

lint-nodejs: ## Lint Node.js services
	@echo "$(BLUE)Linting Node.js services...$(NC)"
	@for service in $(NODEJS_SERVICES); do \
		if [ -d "$$service" ] && [ -f "$$service/package.json" ]; then \
			echo "Linting $$service"; \
			(cd $$service && \
			if grep -q '"lint"' package.json; then \
				npm run lint; \
			else \
				echo "No lint script found for $$service, skipping"; \
			fi && \
			if [ -f "tsconfig.json" ]; then \
				npx tsc --noEmit; \
			fi) || exit 1; \
		fi \
	done

lint-python: ## Lint Python services
	@echo "$(BLUE)Linting Python services...$(NC)"
	@for service in $(PYTHON_SERVICES); do \
		if [ -d "$$service" ]; then \
			echo "Linting $$service"; \
			(cd $$service && \
			flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics && \
			flake8 . --count --exit-zero --max-complexity=10 --max-line-length=127 --statistics && \
			black --check .) || exit 1; \
		fi \
	done

lint-php: ## Lint PHP services
	@echo "$(BLUE)Linting PHP services...$(NC)"
	@for service in $(PHP_SERVICES); do \
		if [ -d "$$service" ]; then \
			echo "Linting $$service"; \
			(cd $$service && \
			composer require --dev friendsofphp/php-cs-fixer --no-interaction && \
			vendor/bin/php-cs-fixer fix --dry-run --diff && \
			composer require --dev phpstan/phpstan --no-interaction && \
			vendor/bin/phpstan analyse src --level=1) || exit 1; \
		fi \
	done

lint-ruby: ## Lint Ruby services
	@echo "$(BLUE)Linting Ruby services...$(NC)"
	@for service in $(RUBY_SERVICES); do \
		if [ -d "$$service" ]; then \
			echo "Linting $$service"; \
			(cd $$service && rubocop --format progress --display-cop-names) || exit 1; \
		fi \
	done

lint-rust: ## Lint Rust services
	@echo "$(BLUE)Linting Rust services...$(NC)"
	@for service in $(RUST_SERVICES); do \
		if [ -d "$$service" ]; then \
			echo "Linting $$service"; \
			(cd $$service && \
			cargo clippy -- -D warnings && \
			cargo fmt --all -- --check) || exit 1; \
		fi \
	done

lint-cpp: ## Lint C++ services
	@echo "$(BLUE)Linting C++ services...$(NC)"
	@for service in $(CPP_SERVICES); do \
		if [ -d "$$service" ]; then \
			echo "Linting $$service"; \
			(cd $$service && find src -name '*.cpp' -o -name '*.h' | xargs clang-format --dry-run -Werror) || exit 1; \
		fi \
	done

##@ Testing
test: ## Run tests for all services
	@echo "$(GREEN)Running tests for all services...$(NC)"
	@$(MAKE) test-dotnet test-java test-go test-nodejs test-python test-php test-ruby test-rust test-cpp

test-dotnet: ## Test .NET services
	@echo "$(BLUE)Testing .NET services...$(NC)"
	@for service in $(DOTNET_SERVICES); do \
		if [ -d "$$service" ]; then \
			echo "Testing $$service"; \
			(cd $$service && \
			if [ -d "tests" ] || find . -name "*.tests.csproj" | grep -q .; then \
				dotnet test --no-build --configuration Release --logger trx; \
			else \
				echo "No tests found for $$service, skipping"; \
			fi) || exit 1; \
		fi \
	done

test-java: ## Test Java services
	@echo "$(BLUE)Testing Java services...$(NC)"
	@for service in $(JAVA_SERVICES); do \
		if [ -d "$$service" ]; then \
			echo "Testing $$service"; \
			(cd $$service && ./gradlew test) || exit 1; \
		fi \
	done

test-go: ## Test Go services
	@echo "$(BLUE)Testing Go services...$(NC)"
	@for service in $(GO_SERVICES); do \
		if [ -d "$$service" ]; then \
			echo "Testing $$service"; \
			(cd $$service && go test -v -race -coverprofile=coverage.out ./...) || exit 1; \
		fi \
	done

test-nodejs: ## Test Node.js services
	@echo "$(BLUE)Testing Node.js services...$(NC)"
	@for service in $(NODEJS_SERVICES); do \
		if [ -d "$$service" ] && [ -f "$$service/package.json" ]; then \
			echo "Testing $$service"; \
			(cd $$service && \
			if grep -q '"test"' package.json; then \
				npm test; \
			else \
				echo "No test script found for $$service, skipping"; \
			fi) || exit 1; \
		fi \
	done

test-python: ## Test Python services
	@echo "$(BLUE)Testing Python services...$(NC)"
	@for service in $(PYTHON_SERVICES); do \
		if [ -d "$$service" ]; then \
			echo "Testing $$service"; \
			(cd $$service && \
			if [ -d "tests" ] || find . -name "*test*.py" -not -path "./venv/*" | grep -q .; then \
				python -m pytest --cov=. --cov-report=xml; \
			else \
				echo "No tests found for $$service, skipping"; \
			fi) || exit 1; \
		fi \
	done

test-php: ## Test PHP services
	@echo "$(BLUE)Testing PHP services...$(NC)"
	@for service in $(PHP_SERVICES); do \
		if [ -d "$$service" ]; then \
			echo "Testing $$service"; \
			(cd $$service && \
			if [ -d "tests" ]; then \
				composer require --dev phpunit/phpunit --no-interaction && \
				vendor/bin/phpunit; \
			else \
				echo "No tests found for $$service, skipping"; \
			fi) || exit 1; \
		fi \
	done

test-ruby: ## Test Ruby services
	@echo "$(BLUE)Testing Ruby services...$(NC)"
	@for service in $(RUBY_SERVICES); do \
		if [ -d "$$service" ]; then \
			echo "Testing $$service"; \
			(cd $$service && \
			if [ -d "test" ]; then \
				for t in test/*_test.rb; do bundle exec ruby -Itest "$$t" || exit 1; done; \
			elif [ -d "spec" ]; then \
				bundle exec rspec; \
			else \
				echo "No tests found for $$service, skipping"; \
			fi) || exit 1; \
		fi \
	done

test-rust: ## Test Rust services
	@echo "$(BLUE)Testing Rust services...$(NC)"
	@for service in $(RUST_SERVICES); do \
		if [ -d "$$service" ]; then \
			echo "Testing $$service"; \
			(cd $$service && cargo test --verbose) || exit 1; \
		fi \
	done

test-cpp: ## Test C++ services
	@echo "$(BLUE)Testing C++ services...$(NC)"
	@for service in $(CPP_SERVICES); do \
		if [ -d "$$service" ]; then \
			echo "Testing $$service"; \
			(cd $$service/build && \
			if [ -f "test_currency" ]; then \
				./test_currency; \
			else \
				echo "No tests found for $$service, skipping"; \
			fi) || exit 1; \
		fi \
	done

##@ Docker
# Docker targets delegate to the upstream Makefile, which owns the layered
# compose.*.yaml files and the .env/.env.override env-file handling.
UPSTREAM_MAKE := $(MAKE) -f Makefile.original

docker-build: ## Build all Docker images
	@echo "$(GREEN)Building all Docker images...$(NC)"
	@$(UPSTREAM_MAKE) build

docker-up: ## Start all services with Docker Compose
	@echo "$(GREEN)Starting all services...$(NC)"
	@$(UPSTREAM_MAKE) start

docker-down: ## Stop all services
	@echo "$(YELLOW)Stopping all services...$(NC)"
	@$(UPSTREAM_MAKE) stop

docker-logs: ## Show logs from all services
	@touch .env.override
	@docker compose --env-file .env --env-file .env.override -f compose.yaml -f compose.full.yaml -f compose.observability.yaml -f compose.extras.yaml logs -f

##@ Helm
helm-lint: ## Lint Helm chart
	@echo "$(BLUE)Linting Helm chart...$(NC)"
	@helm lint $(HELM_CHART)

helm-template: ## Test Helm chart template rendering
	@echo "$(BLUE)Testing Helm chart template...$(NC)"
	@helm template test-release $(HELM_CHART) --debug

helm-template-scout: ## Test Helm chart with Scout values
	@echo "$(BLUE)Testing Helm chart with Scout integration...$(NC)"
	@helm template test-release $(HELM_CHART) -f $(HELM_CHART)/values-scout.yaml --debug

helm-install: ## Install Helm chart locally
	@echo "$(GREEN)Installing Helm chart...$(NC)"
	@helm install otel-demo $(HELM_CHART) -n otel-demo --create-namespace

helm-upgrade: ## Upgrade Helm chart
	@echo "$(YELLOW)Upgrading Helm chart...$(NC)"
	@helm upgrade otel-demo $(HELM_CHART) -n otel-demo

helm-uninstall: ## Uninstall Helm chart
	@echo "$(RED)Uninstalling Helm chart...$(NC)"
	@helm uninstall otel-demo -n otel-demo

##@ CI Simulation
ci: ## Run full CI pipeline locally (lint + test + build)
	@echo "$(GREEN)🚀 Running full CI pipeline locally...$(NC)"
	@echo "$(YELLOW)This will run linting, testing, and building for all services$(NC)"
	@echo "$(YELLOW)Duration: ~5-10 minutes depending on your machine$(NC)"
	@echo ""
	@$(MAKE) ci-prereq-check
	@echo "$(GREEN)✅ Prerequisites check passed$(NC)"
	@echo ""
	@$(MAKE) ci-lint
	@echo "$(GREEN)✅ Linting completed$(NC)"
	@echo ""
	@$(MAKE) ci-test  
	@echo "$(GREEN)✅ Testing completed$(NC)"
	@echo ""
	@$(MAKE) ci-build
	@echo "$(GREEN)✅ Building completed$(NC)"
	@echo ""
	@$(MAKE) ci-helm
	@echo "$(GREEN)✅ Helm validation completed$(NC)"
	@echo ""
	@echo "$(GREEN)🎉 CI pipeline completed successfully!$(NC)"
	@echo "$(BLUE)Your code is ready for push/PR$(NC)"

ci-prereq-check: ## Check CI prerequisites
	@echo "$(BLUE)Checking CI prerequisites...$(NC)"
	@which dotnet > /dev/null || (echo "$(RED)❌ dotnet not found$(NC)" && exit 1)
	@which java > /dev/null || (echo "$(RED)❌ java not found$(NC)" && exit 1)
	@which go > /dev/null || (echo "$(RED)❌ go not found$(NC)" && exit 1)
	@which node > /dev/null || (echo "$(RED)❌ node not found$(NC)" && exit 1)
	@which python3 > /dev/null || (echo "$(RED)❌ python3 not found$(NC)" && exit 1)
	@which php > /dev/null || (echo "$(RED)❌ php not found$(NC)" && exit 1)
	@which ruby > /dev/null || (echo "$(RED)❌ ruby not found$(NC)" && exit 1)
	@which cargo > /dev/null || (echo "$(RED)❌ cargo not found$(NC)" && exit 1)
	@which cmake > /dev/null || (echo "$(RED)❌ cmake not found$(NC)" && exit 1)
	@which helm > /dev/null || (echo "$(RED)❌ helm not found$(NC)" && exit 1)
	@which golangci-lint > /dev/null || (echo "$(RED)❌ golangci-lint not found$(NC)" && exit 1)
	@which rubocop > /dev/null || (echo "$(RED)❌ rubocop not found$(NC)" && exit 1)
	@which clang-format > /dev/null || (echo "$(RED)❌ clang-format not found$(NC)" && exit 1)

ci-lint: ## Run linting (CI simulation)
	@echo "$(BLUE)Running linting (CI mode)...$(NC)"
	@$(MAKE) lint || (echo "$(RED)❌ Linting failed$(NC)" && exit 1)

ci-test: ## Run testing (CI simulation)  
	@echo "$(BLUE)Running tests (CI mode)...$(NC)"
	@$(MAKE) test || (echo "$(RED)❌ Tests failed$(NC)" && exit 1)

ci-build: ## Run building (CI simulation)
	@echo "$(BLUE)Running build (CI mode)...$(NC)"
	@$(MAKE) build || (echo "$(RED)❌ Build failed$(NC)" && exit 1)

ci-helm: ## Run Helm validation (CI simulation)
	@echo "$(BLUE)Running Helm validation (CI mode)...$(NC)"
	@$(MAKE) helm-lint helm-template helm-template-scout || (echo "$(RED)❌ Helm validation failed$(NC)" && exit 1)

##@ CI Without .NET
ci-no-dotnet: ## Run CI pipeline without .NET services (for users without dotnet)
	@echo "$(GREEN)🚀 Running CI pipeline (excluding .NET services)...$(NC)"
	@echo "$(YELLOW)This will run linting, testing, and building for all non-.NET services$(NC)"
	@echo "$(YELLOW)Skipping: accounting, cart services$(NC)"
	@echo ""
	@$(MAKE) ci-prereq-check-no-dotnet
	@echo "$(GREEN)✅ Prerequisites check passed$(NC)"
	@echo ""
	@$(MAKE) ci-lint-no-dotnet
	@echo "$(GREEN)✅ Linting completed$(NC)"
	@echo ""
	@$(MAKE) ci-test-no-dotnet
	@echo "$(GREEN)✅ Testing completed$(NC)"
	@echo ""
	@$(MAKE) ci-build-no-dotnet
	@echo "$(GREEN)✅ Building completed$(NC)"
	@echo ""
	@$(MAKE) ci-helm
	@echo "$(GREEN)✅ Helm validation completed$(NC)"
	@echo ""
	@echo "$(GREEN)🎉 CI pipeline completed successfully!$(NC)"
	@echo "$(BLUE)Your code is ready for push/PR$(NC)"

ci-prereq-check-no-dotnet: ## Check CI prerequisites (excluding .NET)
	@echo "$(BLUE)Checking CI prerequisites (no .NET)...$(NC)"
	@which java > /dev/null || (echo "$(RED)❌ java not found$(NC)" && exit 1)
	@which go > /dev/null || (echo "$(RED)❌ go not found$(NC)" && exit 1)
	@which node > /dev/null || (echo "$(RED)❌ node not found$(NC)" && exit 1)
	@which python3 > /dev/null || (echo "$(RED)❌ python3 not found$(NC)" && exit 1)
	@which php > /dev/null || (echo "$(RED)❌ php not found$(NC)" && exit 1)
	@which ruby > /dev/null || (echo "$(RED)❌ ruby not found$(NC)" && exit 1)
	@which cargo > /dev/null || (echo "$(RED)❌ cargo not found$(NC)" && exit 1)
	@which cmake > /dev/null || (echo "$(RED)❌ cmake not found$(NC)" && exit 1)
	@which helm > /dev/null || (echo "$(RED)❌ helm not found$(NC)" && exit 1)
	@which golangci-lint > /dev/null || (echo "$(RED)❌ golangci-lint not found$(NC)" && exit 1)
	@which rubocop > /dev/null || (echo "$(RED)❌ rubocop not found$(NC)" && exit 1)
	@which clang-format > /dev/null || (echo "$(RED)❌ clang-format not found$(NC)" && exit 1)

ci-lint-no-dotnet: ## Run linting without .NET services
	@echo "$(BLUE)Running linting (excluding .NET)...$(NC)"
	@$(MAKE) lint-java lint-go lint-nodejs lint-python lint-php lint-ruby lint-rust lint-cpp || (echo "$(RED)❌ Linting failed$(NC)" && exit 1)

ci-test-no-dotnet: ## Run tests without .NET services
	@echo "$(BLUE)Running tests (excluding .NET)...$(NC)"
	@$(MAKE) test-java test-go test-nodejs test-python test-php test-ruby test-rust test-cpp || (echo "$(RED)❌ Tests failed$(NC)" && exit 1)

ci-build-no-dotnet: ## Run build without .NET services
	@echo "$(BLUE)Running build (excluding .NET)...$(NC)"
	@$(MAKE) build-java build-go build-nodejs build-python build-php build-ruby build-rust build-cpp || (echo "$(RED)❌ Build failed$(NC)" && exit 1)

##@ Linting Tools
install-tools: ## Install development tools
	@echo "$(BLUE)Installing development tools...$(NC)"
	@go install github.com/client9/misspell/cmd/misspell@latest

install-yamllint: ## Install yamllint
	@echo "$(BLUE)Installing yamllint...$(NC)"
	@pip3 install yamllint

markdownlint: ## Run markdown linting
	@echo "$(BLUE)Running markdown linting...$(NC)"
	@if command -v markdownlint >/dev/null 2>&1; then \
		markdownlint *.md; \
	else \
		echo "$(YELLOW)markdownlint not installed, skipping$(NC)"; \
	fi

checklicense: ## Check license headers
	@echo "$(BLUE)Checking license headers...$(NC)"
	@if command -v addlicense >/dev/null 2>&1; then \
		addlicense -check .; \
	else \
		echo "$(YELLOW)addlicense not installed, skipping$(NC)"; \
	fi

misspell: ## Check for misspellings
	@echo "$(BLUE)Checking for misspellings...$(NC)"
	@if command -v misspell >/dev/null 2>&1; then \
		misspell -error .; \
	else \
		echo "$(YELLOW)misspell not installed, skipping$(NC)"; \
	fi

docker-generate-protobuf: ## Generate protobuf files using Docker
	@echo "$(BLUE)Generating protobuf files...$(NC)"
	@./docker-gen-proto.sh

check-clean-work-tree: ## Check if git working tree is clean
	@echo "$(BLUE)Checking git working tree...$(NC)"
	@if ! git diff --quiet; then \
		echo ""; \
		echo "$(RED)Working tree is not clean, did you forget to run 'make docker-generate-protobuf'?$(NC)"; \
		echo ""; \
		git status; \
		exit 1; \
	fi
	@echo "$(GREEN)✅ Working tree is clean$(NC)"

##@ Utilities
clean: ## Clean all build artifacts and generated protobuf files
	@echo "$(YELLOW)Cleaning build artifacts...$(NC)"
	rm -rf ./src/{checkout,product-catalog}/genproto/oteldemo/
	rm -rf ./src/recommendation/{demo_pb2,demo_pb2_grpc}.py
	rm -rf ./src/frontend/protos/demo.ts
	@for service in $(DOTNET_SERVICES); do \
		if [ -d "$$service" ]; then \
			(cd $$service && dotnet clean) || exit 1; \
		fi \
	done
	@for service in $(JAVA_SERVICES); do \
		if [ -d "$$service" ]; then \
			(cd $$service && ./gradlew clean) || exit 1; \
		fi \
	done
	@for service in $(GO_SERVICES); do \
		if [ -d "$$service" ]; then \
			(cd $$service && go clean) || exit 1; \
		fi \
	done
	@for service in $(NODEJS_SERVICES); do \
		if [ -d "$$service" ]; then \
			(cd $$service && rm -rf .next dist build) || exit 1; \
		fi \
	done
	@for service in $(RUST_SERVICES); do \
		if [ -d "$$service" ]; then \
			(cd $$service && cargo clean) || exit 1; \
		fi \
	done
	@for service in $(CPP_SERVICES); do \
		if [ -d "$$service/build" ]; then \
			rm -rf $$service/build; \
		fi \
	done

format: ## Format code for all services
	@echo "$(GREEN)Formatting code for all services...$(NC)"
	@for service in $(DOTNET_SERVICES); do \
		if [ -d "$$service" ]; then \
			echo "Formatting $$service"; \
			(cd $$service && dotnet format) || exit 1; \
		fi \
	done
	@for service in $(JAVA_SERVICES); do \
		if [ -d "$$service" ]; then \
			echo "Formatting $$service"; \
			(cd $$service && ./gradlew spotlessApply) || exit 1; \
		fi \
	done
	@for service in $(GO_SERVICES); do \
		if [ -d "$$service" ]; then \
			echo "Formatting $$service"; \
			(cd $$service && go fmt ./...) || exit 1; \
		fi \
	done
	@for service in $(PYTHON_SERVICES); do \
		if [ -d "$$service" ]; then \
			echo "Formatting $$service"; \
			(cd $$service && black .) || exit 1; \
		fi \
	done
	@for service in $(RUST_SERVICES); do \
		if [ -d "$$service" ]; then \
			echo "Formatting $$service"; \
			(cd $$service && cargo fmt) || exit 1; \
		fi \
	done

dev-setup: ## Set up development environment
	@echo "$(GREEN)Setting up development environment...$(NC)"
	@echo "$(BLUE)This will install all dependencies and set up the project$(NC)"
	@$(MAKE) install
	@echo "$(GREEN)✅ Development environment ready!$(NC)"

status: ## Show status of all services
	@echo "$(GREEN)Service Status Overview:$(NC)"
	@echo "$(BLUE)========================$(NC)"
	@echo ""
	@echo "$(YELLOW).NET Services:$(NC)"
	@for service in $(DOTNET_SERVICES); do \
		if [ -d "$$service" ]; then \
			echo "  ✅ $$service"; \
		else \
			echo "  ❌ $$service (missing)"; \
		fi \
	done
	@echo ""
	@echo "$(YELLOW)Java Services:$(NC)"
	@for service in $(JAVA_SERVICES); do \
		if [ -d "$$service" ]; then \
			echo "  ✅ $$service"; \
		else \
			echo "  ❌ $$service (missing)"; \
		fi \
	done
	@echo ""
	@echo "$(YELLOW)Go Services:$(NC)"
	@for service in $(GO_SERVICES); do \
		if [ -d "$$service" ]; then \
			echo "  ✅ $$service"; \
		else \
			echo "  ❌ $$service (missing)"; \
		fi \
	done
	@echo ""
	@echo "$(YELLOW)Node.js Services:$(NC)"
	@for service in $(NODEJS_SERVICES); do \
		if [ -d "$$service" ]; then \
			echo "  ✅ $$service"; \
		else \
			echo "  ❌ $$service (missing)"; \
		fi \
	done
	@echo ""
	@echo "$(YELLOW)Python Services:$(NC)"
	@for service in $(PYTHON_SERVICES); do \
		if [ -d "$$service" ]; then \
			echo "  ✅ $$service"; \
		else \
			echo "  ❌ $$service (missing)"; \
		fi \
	done
	@echo ""
	@echo "$(YELLOW)Other Services:$(NC)"
	@for service in $(PHP_SERVICES) $(RUBY_SERVICES) $(RUST_SERVICES) $(CPP_SERVICES); do \
		if [ -d "$$service" ]; then \
			echo "  ✅ $$service"; \
		else \
			echo "  ❌ $$service (missing)"; \
		fi \
	done