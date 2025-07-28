<!-- markdownlint-disable-next-line -->
# <img src="https://opentelemetry.io/img/logos/opentelemetry-logo-nav.png" alt="OTel logo" width="45"> OpenTelemetry Demo - Base14 Fork

> **Note: This is a Base14 fork of the official OpenTelemetry Demo**
>
> This fork extends the original [OpenTelemetry Demo](https://github.com/open-telemetry/opentelemetry-demo) with additional features, including a comprehensive Helm chart and Scout observability platform integration.
>
> **Added Features:**
> - **Production-ready Helm Chart** with full Kubernetes deployment support
> - **Scout Integration** - Alternative to built-in telemetry stack (Jaeger, Prometheus, Grafana)
> - **Enhanced Documentation** with deployment guides and troubleshooting

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg?color=red)](https://github.com/base-14/otel-demo/blob/main/LICENSE)
[![Original Repo](https://img.shields.io/badge/Original-OpenTelemetry%20Demo-blue)](https://github.com/open-telemetry/opentelemetry-demo)

## Welcome to the OpenTelemetry Astronomy Shop Demo

This repository contains the OpenTelemetry Astronomy Shop, a microservice-based
distributed system intended to illustrate the implementation of OpenTelemetry in
a near real-world environment.

**This Base14 fork enhances the original demo with:**
- **Kubernetes-native deployment** via comprehensive Helm chart
- **Scout observability integration** for centralized telemetry
- **Production-ready configurations** for enterprise deployment

Our goals are threefold:

- Provide a realistic example of a distributed system that can be used to
  demonstrate OpenTelemetry instrumentation and observability.
- Build a base for vendors, tooling authors, and others to extend and
  demonstrate their OpenTelemetry integrations.
- Create a living example for OpenTelemetry contributors to use for testing new
  versions of the API, SDK, and other components or enhancements.

We've already made [huge
progress](https://github.com/open-telemetry/opentelemetry-demo/blob/main/CHANGELOG.md),
and development is ongoing. We hope to represent the full feature set of
OpenTelemetry across its languages in the future.

If you'd like to help (**which we would love**), check out our [contributing
guidance](./CONTRIBUTING.md).

If you'd like to extend this demo or maintain a fork of it, read our
[fork guidance](https://opentelemetry.io/docs/demo/forking/).

## Quick start

You can be up and running with the demo in a few minutes. This Base14 fork provides multiple deployment options:

### Deployment Options

#### Helm Chart (Recommended - Base14 Addition)
Deploy with our production-ready Helm chart:

```bash
# Standard deployment
helm install otel-demo ./helm-chart/otel-demo -n otel-demo --create-namespace

# With Scout integration
helm install otel-demo ./helm-chart/otel-demo -n otel-demo --create-namespace -f helm-chart/otel-demo/values-scout.yaml
```

**Features:**
- Complete Kubernetes deployment with all services
- Built-in telemetry stack (Jaeger, Prometheus, Grafana) or Scout integration
- Production-ready configurations with resource limits and health checks
- Comprehensive documentation and troubleshooting guides

**[Complete Helm Chart Documentation](./helm-chart/otel-demo/README.md)**

#### Original Deployment Methods
- [Docker](https://opentelemetry.io/docs/demo/docker_deployment/)
- [Kubernetes (Original)](https://opentelemetry.io/docs/demo/kubernetes_deployment/)

## Documentation

For detailed documentation, see [Demo Documentation][docs]. If you're curious
about a specific feature, the [docs landing page][docs] can point you in the
right direction.

## Demos featuring the Astronomy Shop

We welcome any vendor to fork the project to demonstrate their services and
adding a link below. The community is committed to maintaining the project and
keeping it up to date for you.

|                           |                |                                  |
|---------------------------|----------------|----------------------------------|
| [AlibabaCloud LogService] | [Google Cloud] | [Parseable]                      |
| [Apache Doris]            | [Grafana Labs] | [Sentry]                         |
| [AppDynamics]             | [Guance]       | [ServiceNow Cloud Observability] |
| [Aspecto]                 | [Honeycomb.io] | [SigNoz]                         |
| [Axiom]                   | [Instana]      | [Splunk]                         |
| [Axoflow]                 | [Kloudfuse]    | [Sumo Logic]                     |
| [Azure Data Explorer]     | [Last9]        | [TelemetryHub]                   |
| [Causely]                 | [Liatrio]      | [Teletrace]                      |
| [ClickStack]              | [Logz.io]      | [Tinybird]                       |
| [Coralogix]               | [New Relic]    | [Tracetest]                      |
| [Dash0]                   | [Oodle]        | [Uptrace]                        |
| [Datadog]                 | [OpenObserve]  | [VictoriaMetrics]                |
| [Dynatrace]               | [OpenSearch]   |                                  |
| [Elastic]                 | [Oracle]       |                                  |

## Base14 Enhancements

### Scout Integration

This fork includes native integration with **Scout**, Base14's comprehensive observability platform. Scout provides:

- **Unified Observability**: Traces, metrics, and logs in a single platform
- **Advanced Analytics**: AI-powered insights and anomaly detection
- **Enterprise Features**: Multi-tenancy, RBAC, and compliance controls
- **Cost Optimization**: Intelligent sampling and data retention policies

#### Getting Started with Scout

1. **Get Scout Credentials**: Contact Base14 for your Scout endpoint and API key
2. **Deploy with Scout**: Use the provided `values-scout.yaml` configuration
3. **Access Dashboard**: View your telemetry data in the Scout platform

```bash
# Configure Scout values
cp helm-chart/otel-demo/values-scout.yaml my-scout-config.yaml
# Edit my-scout-config.yaml with your Scout credentials

# Deploy with Scout
helm install otel-demo ./helm-chart/otel-demo -n otel-demo --create-namespace -f my-scout-config.yaml
```

For more details, see the [Helm Chart Scout Integration Guide](./helm-chart/otel-demo/README.md#scout-integration).

### Production-Ready Helm Chart

Our Helm chart provides enterprise-grade deployment capabilities:

- **Scalable Architecture**: StatefulSets for stateful services, Deployments for stateless
- **Resource Management**: Configured limits and requests for all services
- **Health Monitoring**: Liveness and readiness probes
- **Security**: RBAC, service accounts, and network policies
- **Flexibility**: Enable/disable individual services as needed

## Contributing

### Contributing to Base14 Fork

This is a Base14 fork with additional features. For contributions to the Base14-specific enhancements (Helm chart, Scout integration):

- Open issues and PRs in this repository
- Follow the same contribution guidelines as the upstream project
- Ensure changes maintain compatibility with the original demo

### Contributing to Upstream OpenTelemetry Demo

To contribute to the original OpenTelemetry Demo project, see the [upstream CONTRIBUTING](https://github.com/open-telemetry/opentelemetry-demo/blob/main/CONTRIBUTING.md) documentation. The upstream project has [SIG Calls](https://github.com/open-telemetry/opentelemetry-demo/blob/main/CONTRIBUTING.md#join-a-sig-call) every other Wednesday at 8:30 AM PST.

### Maintainers

- [Juliano Costa](https://github.com/julianocosta89), Datadog
- [Mikko Viitanen](https://github.com/mviitane), Dynatrace
- [Pierre Tessier](https://github.com/puckpuck), Honeycomb
- [Roger Coll](https://github.com/rogercoll), Elastic

For more information about the maintainer role, see the [community repository](https://github.com/open-telemetry/community/blob/main/guides/contributor/membership.md#maintainer).

### Approvers

- [Cedric Ziel](https://github.com/cedricziel), Grafana Labs
- [Shenoy Pratik](https://github.com/ps48), AWS OpenSearch

For more information about the approver role, see the [community repository](https://github.com/open-telemetry/community/blob/main/guides/contributor/membership.md#approver).

### Emeritus

- [Austin Parker](https://github.com/austinlparker)
- [Carter Socha](https://github.com/cartersocha)
- [Michael Maxwell](https://github.com/mic-max)
- [Morgan McLean](https://github.com/mtwo)
- [Penghan Wang](https://github.com/wph95)
- [Reiley Yang](https://github.com/reyang)
- [Ziqi Zhao](https://github.com/fatsheep9146)

For more information about the emeritus role, see the [community repository](https://github.com/open-telemetry/community/blob/main/guides/contributor/membership.md#emeritus-maintainerapprovertriager).

### Thanks to all the people who have contributed

[![contributors](https://contributors-img.web.app/image?repo=open-telemetry/opentelemetry-demo)](https://github.com/open-telemetry/opentelemetry-demo/graphs/contributors)

[docs]: https://opentelemetry.io/docs/demo/

<!-- Links for Demos featuring the Astronomy Shop section -->

[AlibabaCloud LogService]: https://github.com/aliyun-sls/opentelemetry-demo
[AppDynamics]: https://community.splunk.com/t5/AppDynamics-Knowledge-Base/How-to-observe-Kubernetes-deployment-of-OpenTelemetry-demo-app/ta-p/741454
[Apache Doris]: https://github.com/apache/doris-opentelemetry-demo
[Aspecto]: https://github.com/aspecto-io/opentelemetry-demo
[Axiom]: https://play.axiom.co/axiom-play-qf1k/dashboards/otel.traces.otel-demo-traces
[Axoflow]: https://axoflow.com/opentelemetry-support-in-more-detail-in-axosyslog-and-syslog-ng/
[Azure Data Explorer]: https://github.com/Azure/Azure-kusto-opentelemetry-demo
[Causely]: https://github.com/causely-oss/otel-demo
[ClickStack]: https://github.com/ClickHouse/opentelemetry-demo
[Coralogix]: https://coralogix.com/blog/configure-otel-demo-send-telemetry-data-coralogix
[Dash0]: https://github.com/dash0hq/opentelemetry-demo
[Datadog]: https://docs.datadoghq.com/opentelemetry/guide/otel_demo_to_datadog
[Dynatrace]: https://www.dynatrace.com/news/blog/opentelemetry-demo-application-with-dynatrace/
[Elastic]: https://github.com/elastic/opentelemetry-demo
[Google Cloud]: https://github.com/GoogleCloudPlatform/opentelemetry-demo
[Grafana Labs]: https://github.com/grafana/opentelemetry-demo
[Guance]: https://github.com/GuanceCloud/opentelemetry-demo
[Honeycomb.io]: https://github.com/honeycombio/opentelemetry-demo
[Instana]: https://github.com/instana/opentelemetry-demo
[Kloudfuse]: https://github.com/kloudfuse/opentelemetry-demo
[Last9]: https://last9.io/docs/integrations-opentelemetry-demo/
[Liatrio]: https://github.com/liatrio/opentelemetry-demo
[Logz.io]: https://logz.io/learn/how-to-run-opentelemetry-demo-with-logz-io/
[New Relic]: https://github.com/newrelic/opentelemetry-demo
[Oodle]: https://blog.oodle.ai/meet-oodle-unified-and-ai-native-observability/
[OpenSearch]: https://github.com/opensearch-project/opentelemetry-demo
[OpenObserve]: https://openobserve.ai/blog/opentelemetry-astronomy-shop-demo/
[Oracle]: https://github.com/oracle-quickstart/oci-o11y-solutions/blob/main/knowledge-content/opentelemetry-demo
[Parseable]: https://www.parseable.com/blog/open-telemetry-demo-with-parseable-a-complete-observability-setup
[Sentry]: https://github.com/getsentry/opentelemetry-demo
[ServiceNow Cloud Observability]: https://docs.lightstep.com/otel/quick-start-operator#send-data-from-the-opentelemetry-demo
[SigNoz]: https://signoz.io/blog/opentelemetry-demo/
[Splunk]: https://github.com/signalfx/opentelemetry-demo
[Sumo Logic]: https://www.sumologic.com/blog/common-opentelemetry-demo-application/
[TelemetryHub]: https://github.com/TelemetryHub/opentelemetry-demo/tree/telemetryhub-backend
[Teletrace]: https://github.com/teletrace/opentelemetry-demo
[Tinybird]: https://github.com/tinybirdco/opentelemetry-demo
[Tracetest]: https://github.com/kubeshop/opentelemetry-demo
[Uptrace]: https://github.com/uptrace/uptrace/tree/master/example/opentelemetry-demo
[VictoriaMetrics]: https://github.com/VictoriaMetrics-Community/opentelemetry-demo
