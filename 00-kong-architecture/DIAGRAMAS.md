# 🌊 Kong Gateway - Fluxo de Dados Detalhado

## 📊 Diagrama de Fluxo Completo

```mermaid
graph TB
    subgraph "Client Side"
        A[Mobile App]
        B[Web App] 
        C[API Client]
    end
    
    subgraph "Kong Gateway"
        D[Load Balancer]
        E[Data Plane :8000]
        F[Admin API :8001]
        
        subgraph "Plugin Pipeline"
            G[Router]
            H[Auth Plugins]
            I[Rate Limit]
            J[Transform]
            K[Analytics]
        end
    end
    
    subgraph "Data Storage"
        L[(PostgreSQL)]
        M[(Redis)]
    end
    
    subgraph "Upstream Services"
        N[User Service]
        O[Order Service]
        P[Payment Service]
    end
    
    subgraph "Observability"
        Q[Prometheus]
        R[Grafana]
        S[Jaeger]
    end
    
    A --> D
    B --> D
    C --> D
    D --> E
    
    E --> G
    G --> H
    H --> I
    I --> J
    J --> N
    J --> O
    J --> P
    
    H --> M
    I --> M
    
    F --> L
    E --> L
    
    K --> Q
    K --> S
    Q --> R
    
    style E fill:#e1f5fe
    style F fill:#f3e5f5
    style L fill:#e8f5e8
    style M fill:#fff3e0
```

## 🔄 Lifecycle de uma Requisição

```mermaid
sequenceDiagram
    participant C as Client
    participant LB as Load Balancer
    participant K as Kong Gateway
    participant R as Router
    participant A as Auth Plugin
    participant RL as Rate Limit Plugin
    participant T as Transform Plugin
    participant U as Upstream Service
    participant DB as Database
    participant Cache as Redis
    
    C->>LB: HTTP Request
    LB->>K: Forward Request
    
    Note over K: Phase 1: INIT
    K->>R: Route Matching
    R-->>K: Route Found
    
    Note over K: Phase 2: REWRITE
    K->>K: URI Rewrite (if needed)
    
    Note over K: Phase 3: ACCESS
    K->>A: Check Authentication
    A->>DB: Validate API Key
    DB-->>A: Key Valid
    A-->>K: Access Granted
    
    K->>RL: Check Rate Limits
    RL->>Cache: Get Current Count
    Cache-->>RL: Count: 5/100
    RL-->>K: Request Allowed
    
    Note over K: Phase 4: HEADER_FILTER
    K->>T: Transform Request Headers
    T-->>K: Headers Modified
    
    Note over K: Forward to Upstream
    K->>U: Proxied Request
    U-->>K: Response
    
    Note over K: Phase 5: HEADER_FILTER (Response)
    K->>T: Transform Response Headers
    T-->>K: Response Headers Modified
    
    Note over K: Phase 6: BODY_FILTER
    K->>T: Transform Response Body
    T-->>K: Response Body Modified
    
    Note over K: Phase 7: LOG
    K->>K: Log Request/Response
    
    K-->>LB: Final Response
    LB-->>C: Response
```

## 📈 Arquitetura de Plugins

```mermaid
graph TD
    subgraph "Kong Core"
        A[Request Router]
        B[Plugin Manager]
        C[Load Balancer]
    end
    
    subgraph "Authentication Plugins"
        D[Key Auth]
        E[JWT]
        F[OAuth 2.0]
        G[LDAP]
    end
    
    subgraph "Security Plugins"
        H[Rate Limiting]
        I[IP Restriction]
        J[Bot Detection]
        K[CORS]
    end
    
    subgraph "Traffic Control"
        L[Request Size Limit]
        M[Response Rate Limit]
        N[Proxy Cache]
    end
    
    subgraph "Analytics & Monitoring"
        O[Prometheus]
        P[StatsD]
        Q[File Log]
        R[Datadog]
    end
    
    subgraph "Transformation"
        S[Request Transform]
        T[Response Transform]
        U[Correlation ID]
    end
    
    A --> B
    B --> D
    B --> E
    B --> F
    B --> G
    B --> H
    B --> I
    B --> J
    B --> K
    B --> L
    B --> M
    B --> N
    B --> O
    B --> P
    B --> Q
    B --> R
    B --> S
    B --> T
    B --> U
    B --> C
    
    style B fill:#e3f2fd
    style D fill:#f1f8e9
    style H fill:#fff3e0
    style O fill:#fce4ec
    style S fill:#e8eaf6
```

## 🏗️ Deployment Patterns

### Pattern 1: Single Region
```mermaid
graph TB
    subgraph "Production Environment"
        subgraph "Load Balancer"
            LB[HAProxy/nginx]
        end
        
        subgraph "Kong Cluster"
            K1[Kong Node 1]
            K2[Kong Node 2]
            K3[Kong Node 3]
        end
        
        subgraph "Database Cluster"
            DB1[(PostgreSQL Primary)]
            DB2[(PostgreSQL Replica)]
        end
        
        subgraph "Cache Layer"
            R1[(Redis Primary)]
            R2[(Redis Replica)]
        end
        
        subgraph "Upstream Services"
            S1[Service A]
            S2[Service B]
            S3[Service C]
        end
    end
    
    LB --> K1
    LB --> K2
    LB --> K3
    
    K1 --> DB1
    K2 --> DB1
    K3 --> DB1
    
    K1 --> R1
    K2 --> R1
    K3 --> R1
    
    DB1 --> DB2
    R1 --> R2
    
    K1 --> S1
    K1 --> S2
    K1 --> S3
    K2 --> S1
    K2 --> S2
    K2 --> S3
    K3 --> S1
    K3 --> S2
    K3 --> S3
```

### Pattern 2: Multi-Region (Hybrid)
```mermaid
graph TB
    subgraph "Control Plane Region"
        CP[Kong Control Plane]
        DB[(PostgreSQL)]
        ADMIN[Admin Dashboard]
    end
    
    subgraph "Data Plane Region 1 (US-East)"
        DP1[Kong Data Plane 1]
        DP2[Kong Data Plane 2]
    end
    
    subgraph "Data Plane Region 2 (EU-West)"
        DP3[Kong Data Plane 3]
        DP4[Kong Data Plane 4]
    end
    
    subgraph "Data Plane Region 3 (APAC)"
        DP5[Kong Data Plane 5]
        DP6[Kong Data Plane 6]
    end
    
    CP --> DB
    ADMIN --> CP
    
    CP -.->|Config Sync| DP1
    CP -.->|Config Sync| DP2
    CP -.->|Config Sync| DP3
    CP -.->|Config Sync| DP4
    CP -.->|Config Sync| DP5
    CP -.->|Config Sync| DP6
    
    style CP fill:#e3f2fd
    style DP1 fill:#f1f8e9
    style DP3 fill:#fff3e0
    style DP5 fill:#fce4ec
```

## 📊 Performance Characteristics

```mermaid
graph LR
    subgraph "Request Processing Time"
        A[Client Request] 
        B[Kong Processing: 1-5ms]
        C[Upstream Service: 10-100ms]
        D[Total Response Time]
    end
    
    A --> B
    B --> C
    C --> D
    
    subgraph "Kong Processing Breakdown"
        E[Route Matching: 0.1ms]
        F[Plugin Execution: 0.5-4ms]
        G[Proxy Forward: 0.1ms]
        H[Response Process: 0.3ms]
    end
    
    B --> E
    E --> F
    F --> G
    G --> H
    
    style B fill:#e8f5e8
    style F fill:#fff3e0
```

## 🔧 Configuration Management

```mermaid
graph TD
    subgraph "Configuration Sources"
        A[Admin API]
        B[Declarative Config]
        C[Kong Manager]
        D[Infrastructure as Code]
    end
    
    subgraph "Kong Core"
        E[Configuration Loader]
        F[Schema Validator]
        G[Plugin Registry]
    end
    
    subgraph "Runtime Engine"
        H[Route Engine]
        I[Plugin Executor]
        J[Load Balancer]
    end
    
    subgraph "Storage Layer"
        K[(PostgreSQL)]
        L[Memory Cache]
        M[Config Files]
    end
    
    A --> E
    B --> E
    C --> A
    D --> B
    
    E --> F
    F --> G
    
    E --> K
    E --> L
    E --> M
    
    G --> H
    G --> I
    G --> J
    
    H --> I
    I --> J
    
    style E fill:#e3f2fd
    style F fill:#f1f8e9
    style G fill:#fff3e0
```

---

**💡 Use estes diagramas como referência visual durante o workshop!**
