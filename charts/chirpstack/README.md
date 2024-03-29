# Chirpstack Helm Chart

This directory contains a Kubernetes chart to deploy a [Chirpstack](https://chirpstack.io) cluster using deployments, services and istio if enabled.

## Prerequisites Details
* Kubernetes 1.15+
* Istio if enabled
* Prometheus-Operator if enabled
* Postgresql
* Redis
* MQTT Broker

## Chart Details
This chart will do the following:

* Deploy a network-server
* Deploy an application-server
* (Experimental) Deploy gateway-bridge

## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm repo add wobcom-public https://harbor.service.wobcom.de/chartrepo/public
$ helm repo update
$ helm install --name my-release wobcom-public/chirpstack -n chirpstack
```

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```console
$ helm install --name my-release wobcom-public/chirpstack -n chirpstack -f values.yaml
```

> **Tip**: You can use the default [values.yaml](values.yaml)

## Configuration

The following table lists the configurable parameters of the chirpstack chart and their default values.

### App-Server

|       Parameter                               |           Description                       |                         Default                     |
|-----------------------------------------------|---------------------------------------------|-----------------------------------------------------|
| `enabled`                                     | Enable app-server deployment                | `true`                                              |
| `name`                                        | Component name                              | `as`                                                |
| `replicas`                                    | Amount of pods to spawn                     | `1`                                                 |
| `image.repository`                            | The image to pull                           | `chirpstack/chirpstack-application-server`          |
| `image.tag`                                   | The version of the image to pull            | `3.10.0`                                            |
| `image.pullPolicy`                            | The pull policy                             | `IfNotPresent`                                      |
| `service.type`                                | The service type                            | `ClusterIP`                                         |
| `postgres.existingSecret`                     | Postgresql credentials (required)           | `""`                                                |
| `postgres.dbname`                             | Postgresql database name                    | `chirpas`                                           |
| `postgres.host`                               | Postgresql host                             | `chirpstack-postgres`                               |
| `postgres.port`                               | Postgresql port                             | `5432`                                              |
| `postgres.sslmode`                            | Postgresql sslmode                          | `require`                                           |
| `redis.existingSecret`                        | Redis credentials (optional)                | `""`                                                |
| `redis.servers`                               | Redis server list                           | `redis-chirpstack-redis`                            |
| `redis.cluster`                               | Enable only if redis-cluster                | `false`                                             |
| `redis.master`                                | Name of the master (sentinel)               | `mymaster`                                          |
| `integration.mqtt.enabled`                    | Enable MQTT integration                     | `true`                                              |
| `integration.mqtt.server`                     | MQTT broker address                         | `tcp://mqtt-mosquitto:1883`                         |
| `integration.mqtt.existingSecret`             | MQTT client credentials                     | `""`                                                |
| `integration.kafka.enabled`                   | Enable Kafka integration                    | `false`                                             |
| `integration.kafka.topic`                     | Kafka topic to publish                      | `"chirpstack_as"`                                   |
| `integration.kafka.tls`                       | Enable tls                                  | `false`                                             |
| `integration.kafka.mechanism`                 | SASL Mechanism (plain or scram)             | `"plain"`                                           |
| `integration.kafka.algorithm`                 | Algorithm to use with scram Mechanism       | `"SHA-512"`                                         |
| `integration.kafka.brokers`                   | List of brokers to connect                  | `["chirpstack-kafka-bootstrap:9092"]`               |
| `integration.kafka.username`                  | Kafka username                              | `""`                                                |
| `integration.kafka.existingSecret`            | Kafka client credentials                    | `""`                                                |
| `integration.kafka.existingSecretPasswordKey` | Key containing the secret value             | `"password"`                                        |
| `api.external.existingSecret`                 | JWT signing secret                          | `chirpstack-jwt-secret`                             |
| `istio.enabled`                               | Istio enabled                               | `false`                                             |
| `istio.gateway.selector`                      | Istio gateway selector                      | `ingressgateway`                                    |
| `istio.gateway.host`                          | Hostname                                    | `""`                                                |
| `istio.gateway.tls.enabled`                   | TLS enabled                                 | `false`                                             |
| `istio.gateway.tls.credentialName`            | Secret containing certificates              | `""`                                                |
| `istio.gateway.cors.enabled`                  | CORS enabled                                | `true`                                              |
| `istio.gateway.cors.additionalOrigins`        | Additional Origins to allow                 | `[]`                                                |
| `prometheus.enabled`                          | ServiceMonitor enabled                      | `false`                                             |
| `prometheus.namespace`                        | ServiceMonitor namespace                    | `monitoring`                                        |

#### Secrets

```yaml
---
apiVersion: v1
kind: Secret
metadata:
  name: chirpstack-as-postgresql # required
type: Opaque
data:
  username: #base64
  password: #base64

---
apiVersion: v1
kind: Secret
metadata:
  name: chirpstack-as-redis # optional
type: Opaque
data:
  password: #base64

---
apiVersion: v1
kind: Secret
metadata:
  name: chirpstack-as-mqtt # optional
type: Opaque
data:
  username: #base64
  password: #base64

---
apiVersion: v1
kind: Secret
metadata:
  name: kafka-credentials # optional
type: Opaque
data:
  password: #base64

---
apiVersion: v1
kind: Secret
metadata:
  name: chirpstack-as-signSecret # required
type: Opaque
data:
  signSecret: #base64

---
apiVersion: v1
kind: Secret
metadata:
  namespace: istio-system # Same namespace where the ingress-gateway is located
type: kubernetes.io/tls
data:
  ca.crt: ""
  tls.crt: ""
  tls.key: ""
```

### Network-Server

|       Parameter                           |           Description                       |                         Default                     |
|-------------------------------------------|---------------------------------------------|-----------------------------------------------------|
| `enabled`                                 | Enable network-server deployment            | `true`                                              |
| `name`                                    | Component name                              | `ns`                                                |
| `replicas`                                | Amount of pods to spawn                     | `1`                                                 |
| `image.repository`                        | The image to pull                           | `chirpstack/chirpstack-network-server`              |
| `image.tag`                               | The version of the image to pull            | `3.9.0`                                             |
| `image.pullPolicy`                        | The pull policy                             | `IfNotPresent`                                      |
| `service.type`                            | The service type                            | `ClusterIP`                                         |
| `postgres.existingSecret`                 | Postgresql credentials (required)           | `""`                                                |
| `postgres.dbname`                         | Postgresql database name                    | `chirpns`                                           |
| `postgres.host`                           | Postgresql host                             | `chirpstack-postgres`                               |
| `postgres.port`                           | Postgresql port                             | `5432`                                              |
| `postgres.sslmode`                        | Postgresql sslmode                          | `require`                                           |
| `redis.existingSecret`                    | Redis credentials (optional)                | `""`                                                |
| `redis.servers`                           | Redis server list                           | `redis-chirpstack-redis`                            |
| `redis.cluster`                           | Enable only if redis-cluster                | `false`                                             |
| `redis.master`                            | Name of the master (sentinel)               | `mymaster`                                          |
| `network.id`                              | Network Identifier                          | `"000000"`                                          |
| `network.band.name`                       | Network band name                           | `"EU868"`                                           |
| `network.settings.uplink_channels`        | Enable only a given sub-set of channels     | `[]` leave empty to enable all                      |
| `network.settings.extra_channels.enabled` | Enable extra channels                       | `false`                                             |
| `network.settings.extra_channels.channels`| Extra Channel list (RAW TOML String)        | Example configuration provided for EU868            |
| `gateway.backend.type`                    | Gateway backend type                        | `mqtt`                                              |
| `gateway.backend.mqtt.server`             | MQTT broker address                         | `tcp://mqtt-mosquitto:1883`                         |
| `gateway.backend.mqtt.existingSecret`     | MQTT client credentials                     | `""` secret and keys are optional                   |
| `join.default.server`                     | Join-server default address                 | `""` defaults to app-server(enabled) if empty       |
| `prometheus.enabled`                      | ServiceMonitor enabled                      | `false`                                             |
| `prometheus.namespace`                    | ServiceMonitor namespace                    | `monitoring`                                        |


#### Secrets

```yaml
---
apiVersion: v1
kind: Secret
metadata:
  name: chirpstack-ns-postgresql # required
type: Opaque
data:
  username: #base64
  password: #base64

---
apiVersion: v1
kind: Secret
metadata:
  name: chirpstack-ns-redis # optional
type: Opaque
data:
  password: #base64

---
apiVersion: v1
kind: Secret
metadata:
  name: chirpstack-ns-mqtt # optional
type: Opaque
data:
  username: #base64
  password: #base64

```

