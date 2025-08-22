# ⚙️ Kong Gateway - Configurações Práticas

## 🎯 Exemplos de Configuração

### 1. Configuração Declarativa (kong.yml)

```yaml
_format_version: "3.0"
_transform: true

services:
  - name: example-service
    url: http://httpbin.org
    plugins:
      - name: key-auth
      - name: rate-limiting
        config:
          minute: 100
          policy: local

routes:
  - name: example-route
    service: example-service
    paths:
      - /api/v1

consumers:
  - username: example-user
    keyauth_credentials:
      - key: my-secret-key

plugins:
  - name: prometheus
    config:
      per_consumer: true
```

### 2. Configuração via Admin API

```bash
# Criar Service
curl -X POST http://localhost:8001/services \
  --data name=example-service \
  --data url=http://httpbin.org

# Criar Route  
curl -X POST http://localhost:8001/services/example-service/routes \
  --data name=example-route \
  --data paths[]=/api/v1

# Adicionar Plugin de Autenticação
curl -X POST http://localhost:8001/services/example-service/plugins \
  --data name=key-auth

# Criar Consumer
curl -X POST http://localhost:8001/consumers \
  --data username=example-user

# Criar Credencial
curl -X POST http://localhost:8001/consumers/example-user/key-auth \
  --data key=my-secret-key
```

## 🏗️ Configurações por Ambiente

### Development Environment
```yaml
_format_version: "3.0"

# Configurações menos restritivas para desenvolvimento
services:
  - name: dev-service
    url: http://localhost:3000
    connect_timeout: 60000
    write_timeout: 60000
    read_timeout: 60000

routes:
  - name: dev-route
    service: dev-service
    paths: ["/"]
    strip_path: false

plugins:
  # CORS permissivo para desenvolvimento
  - name: cors
    config:
      origins: ["*"]
      methods: ["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"]
      headers: ["Accept", "Content-Type", "Authorization"]
  
  # Rate limiting suave
  - name: rate-limiting
    config:
      minute: 1000
      policy: local
```

### Production Environment  
```yaml
_format_version: "3.0"

# Configurações seguras para produção
services:
  - name: prod-service
    url: https://api.example.com
    connect_timeout: 5000
    write_timeout: 5000
    read_timeout: 5000
    retries: 3

routes:
  - name: prod-route
    service: prod-service
    paths: ["/api/v1"]
    strip_path: true
    https_redirect_status_code: 308

plugins:
  # Segurança reforçada
  - name: cors
    config:
      origins: ["https://myapp.com"]
      credentials: true
  
  # Rate limiting restritivo
  - name: rate-limiting
    config:
      minute: 100
      hour: 1000
      policy: redis
      redis_host: redis-cluster.prod.local
  
  # IP restriction
  - name: ip-restriction
    config:
      allow: ["10.0.0.0/8", "172.16.0.0/12"]
  
  # Request size limiting
  - name: request-size-limiting
    config:
      allowed_payload_size: 1024
```

## 🔧 Configurações Avançadas

### High Availability Setup
```yaml
_format_version: "3.0"

upstreams:
  - name: backend-cluster
    algorithm: round-robin
    hash_on: none
    hash_fallback: none
    healthchecks:
      active:
        healthy:
          interval: 5
          successes: 3
        unhealthy:
          interval: 5
          http_failures: 3
          tcp_failures: 3
          timeouts: 3
        http_path: "/health"
        timeout: 3
      passive:
        healthy:
          successes: 3
        unhealthy:
          http_failures: 3
          tcp_failures: 3
          timeouts: 3
    targets:
      - target: backend-1.internal:8080
        weight: 100
      - target: backend-2.internal:8080
        weight: 100
      - target: backend-3.internal:8080
        weight: 100

services:
  - name: ha-service
    host: backend-cluster
    port: 80
    protocol: http
    connect_timeout: 5000
    write_timeout: 5000
    read_timeout: 5000
```

### Plugin Chain Configuration
```yaml
services:
  - name: secure-api
    url: http://backend.internal
    plugins:
      # 1. Request validation
      - name: request-validator
        config:
          body_schema: |
            {
              "type": "object",
              "required": ["user_id", "action"],
              "properties": {
                "user_id": {"type": "string"},
                "action": {"type": "string"}
              }
            }
      
      # 2. Authentication
      - name: jwt
        config:
          secret_is_base64: false
          key_claim_name: iss
          
      # 3. Authorization  
      - name: acl
        config:
          allow: ["admin", "user"]
      
      # 4. Rate limiting per user
      - name: rate-limiting
        config:
          minute: 100
          policy: redis
          redis_host: redis.internal
          identifier: consumer
      
      # 5. Request transformation
      - name: request-transformer
        config:
          add:
            headers:
              - "X-Timestamp:$(date +%s)"
              - "X-Request-ID:$(uuidgen)"
      
      # 6. Response transformation
      - name: response-transformer
        config:
          add:
            headers:
              - "X-Kong-Gateway:true"
          remove:
            headers:
              - "X-Internal-Header"
      
      # 7. Logging
      - name: file-log
        config:
          path: "/var/log/kong/access.log"
          reopen: true
```

## 📊 Configurações de Observabilidade

### Prometheus Monitoring
```yaml
plugins:
  - name: prometheus
    config:
      per_consumer: true
      status_code_metrics: true
      latency_metrics: true
      bandwidth_metrics: true
      upstream_health_metrics: true
```

### Structured Logging
```yaml
plugins:
  - name: file-log
    config:
      path: "/var/log/kong/access.log"
      config:
        successful_severity: info
        client_errors_severity: notice
        server_errors_severity: error
      custom_fields_by_lua:
        request_id: "return kong.ctx.shared.request_id"
        user_agent: "return kong.request.get_header('user-agent')"
```

### Distributed Tracing
```yaml
plugins:
  - name: zipkin
    config:
      http_endpoint: http://zipkin:9411/api/v2/spans
      sample_ratio: 0.001
      include_credential: true
      traceid_byte_count: 16
      spanid_byte_count: 8
      default_service_name: kong-gateway
```

## 🔒 Configurações de Segurança

### OAuth 2.0 Setup
```yaml
plugins:
  - name: oauth2
    config:
      scopes:
        - read
        - write
        - admin
      token_expiration: 3600
      enable_authorization_code: true
      enable_client_credentials: true
      enable_implicit_grant: true
      enable_password_grant: false
      hide_credentials: true
      accept_http_if_already_terminated: false

oauth2_credentials:
  - name: my-app
    client_id: my-app-client-id
    client_secret: my-app-client-secret
    redirect_uris:
      - https://myapp.com/callback
```

### LDAP Authentication
```yaml
plugins:
  - name: ldap-auth
    config:
      ldap_host: ldap.company.com
      ldap_port: 389
      start_tls: false
      ldaps: false
      base_dn: dc=company,dc=com
      verify_ldap_host: false
      attribute: uid
      hide_credentials: true
      timeout: 10000
      keepalive: 60000
      anonymous: ""
      header_type: ldap
```

## ⚡ Performance Tuning

### Worker Configuration
```bash
# nginx.conf (Kong configuration)
worker_processes auto;
worker_rlimit_nofile 65535;
worker_connections 4096;

# Kong-specific
lua_shared_dict kong 5m;
lua_shared_dict kong_db_cache 128m;
lua_shared_dict kong_db_cache_miss 12m;
lua_shared_dict kong_locks 100k;
lua_shared_dict kong_process_events 5m;
lua_shared_dict kong_cluster_events 5m;
lua_shared_dict kong_healthchecks 5m;
lua_shared_dict kong_rate_limiting_counters 12m;
```

### Database Optimization
```yaml
# kong.conf
database = postgres
pg_host = postgres.internal
pg_port = 5432  
pg_database = kong
pg_user = kong
pg_password = kong_password

# Connection pooling
pg_max_concurrent_queries = 0
pg_semaphore_timeout = 60000

# Cache settings
db_update_frequency = 1
db_update_propagation = 0
db_cache_ttl = 0
db_cache_neg_ttl = 0
```

---

## 🎯 Quick Start Commands

```bash
# Start Kong with declarative config
export KONG_DATABASE=off
export KONG_DECLARATIVE_CONFIG=/path/to/kong.yml
kong start

# Start Kong with database
export KONG_DATABASE=postgres  
export KONG_PG_HOST=localhost
export KONG_PG_USER=kong
export KONG_PG_PASSWORD=kong
kong migrations bootstrap
kong start

# Reload configuration
kong reload

# Check configuration
kong config -c /etc/kong/kong.conf parse

# Health check
curl -i http://localhost:8001/status
```

**💡 Use estas configurações como base para seus próprios deployments Kong!**
