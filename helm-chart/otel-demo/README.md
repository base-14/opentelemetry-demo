# OpenTelemetry Demo Helm Chart

This Helm chart deploys the OpenTelemetry Demo application - a microservices-based distributed system intended to illustrate the implementation of OpenTelemetry in a real-world application.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure (for Kafka and PostgreSQL)

## Installation

### Add Helm repository (if published)

```bash
helm repo add otel-demo https://open-telemetry.github.io/opentelemetry-demo
helm repo update
```

### Install from local directory

```bash
# From the helm-chart directory
helm install otel-demo ./otel-demo -n otel-demo --create-namespace
```

### Install with custom values

```bash
helm install otel-demo ./otel-demo -n otel-demo --create-namespace -f my-values.yaml
```

### Install with Scout Integration

For Scout integration, use the provided example values file:

```bash
# Copy the Scout example values
cp values-scout.yaml my-scout-values.yaml

# Edit my-scout-values.yaml with your Scout credentials:
# - scout.endpoint: Your Scout OTLP endpoint
# - scout.apiKey: Your Scout API key

# Install with Scout
helm install otel-demo ./otel-demo -n otel-demo --create-namespace -f my-scout-values.yaml
```

**Required Scout Configuration:**
- `scout.endpoint`: Your Scout project's OTLP endpoint (e.g., `https://otel.play.b14.dev/YOUR_PROJECT_ID/otlp`)
- `scout.apiKey`: Your Scout API key for authentication

## Configuration

The following table lists the configurable parameters and their default values.

### Global Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `global.imageRegistry` | Global Docker image registry | `ghcr.io` |
| `global.imagePullSecrets` | Global Docker registry secret names | `[]` |
| `global.storageClass` | Global StorageClass for persistent volumes | `""` |

### Demo Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `demo.version` | Version of the demo application | `2.0.2` |
| `demo.image.repository` | Demo image repository | `ghcr.io/open-telemetry/demo` |
| `demo.image.tag` | Demo image tag | `latest` |
| `demo.image.pullPolicy` | Image pull policy | `IfNotPresent` |

### Core Services

Each service (accounting, ad, cart, checkout, etc.) has the following configurable parameters:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `<service>.enabled` | Enable/disable the service | `true` |
| `<service>.name` | Service name | `<service-name>` |
| `<service>.image.repository` | Service image repository | `ghcr.io/open-telemetry/demo` |
| `<service>.image.tag` | Service image tag | `latest-<service>` |
| `<service>.port` | Service port | `<varies>` |
| `<service>.resources` | CPU/Memory resource requests/limits | `<varies>` |
| `<service>.env` | Additional environment variables | `[]` |

### Telemetry Configuration

The chart supports two telemetry options:
1. **Built-in telemetry stack** (default): Jaeger, Prometheus, Grafana, and OpenSearch
2. **Scout integration**: A comprehensive observability platform (replaces built-in stack)

#### Scout Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `scout.enabled` | Enable Scout integration (disables built-in telemetry) | `false` |
| `scout.endpoint` | Scout OTLP endpoint URL | `""` |
| `scout.appName` | Application name for Scout | `"otel-demo"` |
| `scout.apiKey` | Scout API key for authentication | `""` |
| `scout.tokenUrl` | OAuth2 token URL for Scout | `"https://id.b14.dev/realms/playground/protocol/openid-connect/token"` |
| `scout.audience` | OAuth2 audience for Scout | `"b14collector"` |
| `scout.environment` | Environment name (e.g., production, staging) | `"production"` |

#### Built-in Telemetry Components

| Parameter | Description | Default |
|-----------|-------------|---------|
| `otelCollector.enabled` | Enable OpenTelemetry Collector | `true` |
| `jaeger.enabled` | Enable Jaeger (set to false when using Scout) | `true` |
| `prometheus.enabled` | Enable Prometheus (set to false when using Scout) | `true` |
| `grafana.enabled` | Enable Grafana (set to false when using Scout) | `true` |
| `opensearch.enabled` | Enable OpenSearch (set to false when using Scout) | `true` |

### Ingress Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable ingress | `false` |
| `ingress.className` | Ingress class name | `nginx` |
| `ingress.hosts` | Ingress hosts | `[{host: otel-demo.local}]` |
| `ingress.tls` | TLS configuration | `[]` |

## Accessing the Application

### Frontend Application

The frontend is exposed via the frontend-proxy service:

```bash
# NodePort (default)
kubectl get svc frontend-proxy -n otel-demo
# Access via http://<NODE_IP>:30080

# Port-forward
kubectl port-forward -n otel-demo svc/frontend-proxy 8080:8080
# Access via http://localhost:8080
```

### Observability Tools

#### When using Scout Integration
If Scout is enabled (`scout.enabled: true`), all telemetry data (traces, metrics, and logs) is sent to your Scout instance. Access your Scout dashboard using the URL provided by your Scout account.

#### When using Built-in Telemetry Stack

##### Jaeger UI
```bash
kubectl port-forward -n otel-demo svc/jaeger 16686:16686
# Access via http://localhost:16686
```

##### Grafana
```bash
kubectl port-forward -n otel-demo svc/grafana 3000:3000
# Access via http://localhost:3000
# Default credentials: admin/admin
```

##### Prometheus
```bash
kubectl port-forward -n otel-demo svc/prometheus 9090:9090
# Access via http://localhost:9090
```

### Load Generator (Locust)
```bash
kubectl port-forward -n otel-demo svc/load-generator 8089:8089
# Access via http://localhost:8089
```

## Customization Examples

### Disable specific services
```yaml
# values-custom.yaml
accounting:
  enabled: false
fraudDetection:
  enabled: false
```

### Configure resource limits
```yaml
# values-custom.yaml
frontend:
  resources:
    limits:
      memory: 512Mi
      cpu: 500m
    requests:
      memory: 256Mi
      cpu: 250m
```

### Enable ingress
```yaml
# values-custom.yaml
ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
  hosts:
    - host: demo.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: otel-demo-tls
      hosts:
        - demo.example.com
```

### Use external telemetry backends

#### Option 1: Use Scout as telemetry backend
Scout is a comprehensive observability platform that can replace the built-in telemetry stack.

```yaml
# values-scout.yaml
# Enable Scout integration
scout:
  enabled: true
  endpoint: "https://otel.play.b14.dev/YOUR_PROJECT_ID/otlp"
  appName: "otel-demo"
  apiKey: "YOUR_SCOUT_API_KEY"
  environment: "production"

# Disable built-in telemetry components
jaeger:
  enabled: false
prometheus:
  enabled: false
grafana:
  enabled: false
opensearch:
  enabled: false
```

Deploy with Scout:
```bash
helm install otel-demo ./otel-demo -n otel-demo --create-namespace -f values-scout.yaml
```

#### Option 2: Use Scout Collector as a dependency
Uncomment the Scout dependency in Chart.yaml and run:
```bash
helm dependency update ./otel-demo
helm install otel-demo ./otel-demo -n otel-demo --create-namespace -f values-scout.yaml
```

#### Option 3: Use other external backends
```yaml
# values-custom.yaml
# Disable built-in telemetry components
jaeger:
  enabled: false
prometheus:
  enabled: false

# Configure OTel Collector to use external backends
otelCollector:
  config:
    exporters:
      otlp/external:
        endpoint: "external-collector.example.com:4317"
        tls:
          insecure: false
```

## Uninstallation

```bash
helm uninstall otel-demo -n otel-demo
```

## Troubleshooting

### Check pod status
```bash
kubectl get pods -n otel-demo
kubectl describe pod <pod-name> -n otel-demo
```

### View logs
```bash
kubectl logs -n otel-demo <pod-name>
kubectl logs -n otel-demo -l app.kubernetes.io/component=frontend
```

### Common Issues

1. **Pods stuck in Pending state**: Check PVC status and ensure storage provisioner is available
2. **Services not communicating**: Verify service names and ports in environment variables
3. **High memory usage**: Adjust resource limits in values.yaml
4. **Traces not appearing**: Check OTel Collector logs and ensure all services are configured with correct endpoints

#### Scout-specific Issues

5. **Scout authentication failed**: 
   - Verify `scout.apiKey` is correct
   - Check `scout.endpoint` matches your Scout project
   - Ensure `scout.tokenUrl` is accessible from the cluster

6. **Data not appearing in Scout**:
   - Check OTel Collector logs: `kubectl logs -n otel-demo -l app.kubernetes.io/component=otel-collector`
   - Verify Scout endpoint is reachable from the cluster
   - Check Scout project configuration

7. **OAuth2 token issues**:
   - Ensure the cluster can reach `scout.tokenUrl`
   - Verify `scout.audience` matches your Scout configuration

## Contributing

Please refer to the [OpenTelemetry Demo repository](https://github.com/open-telemetry/opentelemetry-demo) for contribution guidelines.

## License

Apache 2.0 License