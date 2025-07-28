# CI/CD Pipeline for OpenTelemetry Demo

This document describes the continuous integration setup for the Base14 fork of the OpenTelemetry Demo application.

## Overview

The CI pipeline runs comprehensive linting and testing for all services across multiple programming languages and includes Helm chart validation. The pipeline is optimized for efficiency by detecting changes and only running relevant tests.

## Workflow Structure

### Change Detection
The pipeline uses `dorny/paths-filter` to detect which services have been modified, ensuring only affected services are tested.

### Language-Specific Jobs

#### .NET Services (C#)
- **Services**: `accounting`, `cart`
- **Tools**: dotnet CLI, dotnet format
- **Tests**: XUnit tests (cart service has tests, accounting does not)
- **Linting**: `dotnet format --verify-no-changes`

#### Java Services
- **Services**: `ad`, `fraud-detection`
- **Tools**: Gradle, Spotless
- **Tests**: JUnit tests via Gradle
- **Linting**: Spotless code formatting with Google Java Format

#### Go Services
- **Services**: `checkout`, `product-catalog`
- **Tools**: Go toolchain, golangci-lint
- **Tests**: Go test with race detection and coverage
- **Linting**: golangci-lint with comprehensive rule set

#### Node.js/TypeScript Services
- **Services**: `frontend`, `payment`, `flagd-ui`
- **Tools**: npm, ESLint, TypeScript compiler
- **Tests**: Jest/Node.js test runner
- **Linting**: ESLint + TypeScript type checking

#### Python Services
- **Services**: `recommendation`, `load-generator`
- **Tools**: pip, flake8, black, pytest
- **Tests**: pytest with coverage
- **Linting**: flake8 + black formatting

#### PHP Service
- **Services**: `quote`
- **Tools**: Composer, PHP CS Fixer, PHPStan
- **Tests**: PHPUnit
- **Linting**: PHP CS Fixer + PHPStan static analysis

#### Ruby Service
- **Services**: `email`
- **Tools**: Bundle, RuboCop
- **Tests**: Minitest
- **Linting**: RuboCop

#### Rust Service
- **Services**: `shipping`
- **Tools**: Cargo, Clippy
- **Tests**: cargo test
- **Linting**: cargo clippy + cargo fmt

#### C++ Service
- **Services**: `currency`
- **Tools**: CMake, clang-format
- **Tests**: Custom test runner (if available)
- **Linting**: clang-format

### Helm Chart Validation
- **Tool**: Helm CLI
- **Actions**: 
  - `helm lint` for syntax validation
  - `helm template` for rendering validation
  - Test with Scout integration values

## Configuration Files Added

### Java Services
- `src/ad/build.gradle` - Added Spotless plugin
- `src/fraud-detection/build.gradle.kts` - Added Spotless plugin

### Go Services
- `src/checkout/.golangci.yml` - golangci-lint configuration
- `src/product-catalog/.golangci.yml` - golangci-lint configuration

### Python Services
- `src/recommendation/pyproject.toml` - Black/Flake8 configuration
- `src/load-generator/pyproject.toml` - Black/Flake8 configuration

### Ruby Service
- `src/email/.rubocop.yml` - RuboCop configuration

## Test Files Added

### Python Services
- `src/recommendation/test_recommendation.py` - Basic unit tests
- `src/load-generator/test_locustfile.py` - Basic unit tests

### Node.js Services
- `src/payment/test/payment.test.js` - Node.js test runner tests
- Updated `src/payment/package.json` with test script

### Ruby Service
- `src/email/test/email_test.rb` - Minitest tests
- Updated `src/email/Gemfile` with test dependencies

## Running Tests Locally

### Prerequisites
Install the required tools for each language:

```bash
# .NET
sudo apt-get install -y dotnet-sdk-8.0

# Java
sudo apt-get install -y openjdk-17-jdk

# Go
wget https://golang.org/dl/go1.24.2.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.24.2.linux-amd64.tar.gz

# Node.js
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Python
sudo apt-get install -y python3.11 python3-pip

# PHP
sudo apt-get install -y php8.1 php8.1-cli composer

# Ruby
sudo apt-get install -y ruby3.2 bundler

# Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# C++
sudo apt-get install -y cmake build-essential clang-format

# Helm
curl https://get.helm.sh/helm-v3.14.0-linux-amd64.tar.gz | tar -xz
sudo mv linux-amd64/helm /usr/local/bin/
```

### Running Individual Service Tests

```bash
# .NET services
cd src/cart && dotnet test
cd src/accounting && dotnet build

# Java services  
cd src/ad && ./gradlew test
cd src/fraud-detection && ./gradlew test

# Go services
cd src/checkout && go test ./...
cd src/product-catalog && go test ./...

# Node.js services
cd src/frontend && npm test
cd src/payment && npm test
cd src/flagd-ui && npm test

# Python services
cd src/recommendation && python -m pytest
cd src/load-generator && python -m pytest

# PHP service
cd src/quote && composer test  # (if configured)

# Ruby service
cd src/email && bundle exec rake test

# Rust service
cd src/shipping && cargo test

# C++ service
cd src/currency && mkdir build && cd build && cmake .. && make && ./test_currency
```

### Running Linting

```bash
# .NET
cd src/cart && dotnet format --verify-no-changes

# Java
cd src/ad && ./gradlew spotlessCheck

# Go  
cd src/checkout && golangci-lint run

# Node.js
cd src/frontend && npm run lint

# Python
cd src/recommendation && black --check . && flake8 .

# PHP
cd src/quote && vendor/bin/php-cs-fixer fix --dry-run

# Ruby
cd src/email && rubocop

# Rust  
cd src/shipping && cargo clippy && cargo fmt --check

# C++
cd src/currency && clang-format --dry-run src/*.cpp
```

## Helm Chart Testing

```bash
# Lint the chart
helm lint helm-chart/otel-demo

# Test template rendering
helm template test-release helm-chart/otel-demo --debug

# Test with Scout values
helm template test-release helm-chart/otel-demo-f helm-chart/otel-demo/values-scout.yaml --debug
```

## Pipeline Triggers

The CI pipeline runs on:
- Push to `main` or `develop` branches
- Pull requests targeting `main` or `develop` branches

## Performance Optimizations

1. **Change Detection**: Only runs jobs for modified services
2. **Parallel Execution**: All language-specific jobs run in parallel
3. **Dependency Caching**: Node.js and other package managers use caching
4. **Concurrency Control**: Cancels previous runs when new commits are pushed

## Adding New Services

To add a new service to the CI pipeline:

1. Add the service path to the `detect-changes` job filters
2. Add the service to the appropriate language matrix
3. Create language-specific configuration files (linting, formatting)
4. Add test files following the service's testing framework
5. Update this documentation

## Troubleshooting

### Common Issues

1. **Linting Failures**: Run the local linting commands to fix formatting issues
2. **Test Failures**: Check test output and fix failing tests locally first
3. **Dependency Issues**: Ensure all required dependencies are listed in package files
4. **Build Failures**: Verify that the service builds locally with the same toolchain versions

### Getting Help

- Check the GitHub Actions logs for detailed error messages
- Run the same commands locally to reproduce issues
- Ensure all configuration files are properly formatted
- Verify that all test dependencies are installed