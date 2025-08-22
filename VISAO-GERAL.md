# 🌟 Kong Gateway Workshop - Visão Geral Completa

## 🎯 Objetivo da Apresentação

Este workshop demonstra **Kong Gateway** de forma evolutiva, desde conceitos básicos até implementações avançadas com plugins multi-linguagem, concluindo com uma análise técnica sobre **por que Lua é escolhido** para embedding em sistemas como Kong.

## 📊 Estrutura do Workshop (10 Projetos)

### 🎢 Progressão de Aprendizado

```
Básico (1-4)     → Intermediário (5-6)     → Avançado (7-10)
     ↓                      ↓                       ↓
Proxy/Auth/Rate     Transforms/Observ.    Plugins/Teoria
```

### 📋 Projetos Detalhados

| # | Projeto | Conceito | Tecnologias | Duração |
|---|---------|----------|-------------|---------|
| **00** | **Arquitetura Kong** | Fundamentos e componentes | Diagramas + Teoria | 10min |
| **01** | **Proxy Básico** | Kong como reverse proxy | Kong + Nginx | 5min |
| **02** | **Autenticação** | Key Auth + JWT | Kong + Auth plugins | 8min |
| **03** | **Rate Limiting** | Controle de tráfego | Kong + Redis | 7min |
| **04** | **Load Balancing** | Distribuição de carga | Kong + multi-upstream | 10min |
| **05** | **Transformações** | Request/Response transform | Kong + transform plugins | 8min |
| **06** | **Observabilidade** | Logging + Monitoring | Kong + Prometheus | 10min |
| **07** | **Plugin Customizado** | Plugin Lua personalizado | Lua + Kong PDK | 15min |
| **08** | **Lua Deep Dive** | Recursos avançados Lua | OpenResty + LuaJIT | 12min |
| **09** | **Go Plugin** | Plugin Go com PDK | Go + Kong Go PDK | 18min |
| **10** | **Lua Embedding** | Por que Lua? Go+Lua | Go + gopher-lua | 15min |

**⏱️ Duração total estimada: ~2h25min**

## 🚀 Demonstração Rápida (Para Apresentação)

### Script de Demo Completo



```bash
# Executar demonstração de todos os projetos
./demo-all.sh
```

### Demo Manual Projeto por Projeto



#### 0️⃣ Arquitetura Kong (00-kong-architecture)

```bash
# Visualizar diagramas e documentação
cd 00-kong-architecture

cat README.md              # → Componentes principais  
cat DIAGRAMAS.md            # → Fluxos visuais


cat CONFIGURACOES.md        # → Exemplos práticos
```


**💡 Conceito:** Fundamentos antes da prática


#### 1️⃣ Proxy Básico (01-basic-proxy)

```bash

cd 01-basic-proxy

docker-compose up -d
curl http://localhost:8000/    # → Resposta do upstream
docker-compose down

```


**💡 Conceito:** Kong como gateway de entrada


#### 2️⃣ Autenticação (02-authentication)

```bash

cd 02-authentication  
docker-compose up -d

curl http://localhost:8000/              # → 401 Unauthorized

curl -H "apikey: minha-chave" http://localhost:8000/  # → 200 OK

docker-compose down
```

**💡 Conceito:** Segurança na API Gateway



#### 3️⃣ Rate Limiting (03-rate-limiting)

```bash


cd 03-rate-limiting
docker-compose up -d
for i in {1..5}; do curl http://localhost:8000/; done  # → Rate limit atingido
docker-compose down  
```



**💡 Conceito:** Proteção contra abuso


#### 4️⃣ Load Balancing (04-load-balancing)


```bash
cd 04-load-balancing
docker-compose up -d

for i in {1..5}; do curl -s http://localhost:8000/ | grep "Servidor"; done  # → Round-robin
docker-compose down


```

**💡 Conceito:** Alta disponibilidade


#### 5️⃣ Transformações (05-transformations)


```bash
cd 05-transformations

docker-compose up -d
curl -X POST http://localhost:8000/api -d '{"user":"test"}'  # → Headers/body modificados

docker-compose down
```



**💡 Conceito:** Adaptação de APIs legadas


#### 6️⃣ Observabilidade (06-observability)

```bash
cd 06-observability  

docker-compose up -d
curl http://localhost:8000/

curl http://localhost:9090/metrics  # → Prometheus metrics

docker-compose down

```

**💡 Conceito:** Monitoramento em produção

#### 7️⃣ Plugin Customizado (07-custom-plugin)



```bash
cd 07-custom-plugin

docker-compose up -d

curl -X POST http://localhost:8000/api -d '{"name":"test"}'  # → Validação customizada
docker-compose down  
```

**💡 Conceito:** Extensibilidade via Lua



#### 8️⃣ Lua Deep Dive (08-lua-deep-dive)

```bash


cd 08-lua-deep-dive
lua lua-examples/basic-lua.lua        # → Conceitos Lua
lua lua-examples/coroutine-demo.lua   # → Corrotinas
lua lua-examples/performance-demo.lua # → Performance
```



**💡 Conceito:** Poder do Lua no OpenResty

#### 9️⃣ Go Plugin (09-go-plugin)

```bash

cd 09-go-plugin

docker-compose up -d
curl http://localhost:8001/test       # → Plugin Go em ação
./performance-test.sh                 # → Comparação Go vs Lua
docker-compose down
```



**💡 Conceito:** Alternativas de linguagem

#### 🔟 Lua Embedding (10-lua-embedding)



```bash
cd 10-lua-embedding/go-lua-host
go run main.go basic      # → Hello World Go+Lua  
go run main.go plugins    # → Sistema de plugins

go run main.go benchmark  # → Performance Go vs Lua
```



**💡 Conceito:** Fundamentos teóricos - Por que Lua?

## 🎯 Pontos-Chave da Apresentação

### 🟢 **Básico (Projetos 0-4)**


- Projeto 0: Fundamentos da arquitetura Kong

- Kong resolve problemas reais de API Gateway
- Configuração declarativa vs Admin API
- Plugins nativos cobrem 80% dos casos

### 🟡 **Intermediário (Projetos 5-6)**

- Transformações permitem integração de APIs legadas

- Observabilidade é crucial para produção
- Kong se integra com ecosistema cloud-native

### 🔴 **Avançado (Projetos 7-10)**


- Lua permite extensões poderosas e performáticas
- Go PDK oferece alternativa tipada
- **Lua embedding explica WHY Kong escolheu Lua**


## 🧠 Insights Técnicos Importantes

### Por que Lua? (Projeto 10)


1. **Performance**: ~2x slower que Go, mas 50x+ mais rápido que Python/JS
2. **Memory**: Footprint mínimo (~150KB por VM)
3. **Embedding**: Integração natural com C/C++
4. **Safety**: Sandboxing seguro
5. **Simplicity**: Sintaxe clean, aprendizado rápido


### Comparações Práticas

- **Go Plugin**: Melhor performance, mais complexidade
- **Lua Plugin**: Balance perfeito performance/simplicidade  
- **JS/Python**: Flexibilidade, mas overhead significativo

## 🎤 Roteiro de Apresentação Sugerido

### Abertura (5min)

- Apresentação pessoal
- Por que API Gateways?
- Kong no mercado

### Demo Básico (25min) - Projetos 1-4

- Live coding: proxy → auth → rate limit → load balance
- Enfatizar simplicidade de configuração

### Demo Intermediário (15min) - Projetos 5-6  

- Transformações para integração
- Observabilidade para produção

### Demo Avançado (35min) - Projetos 7-10

- Plugin Lua customizado
- Deep dive Lua
- Plugin Go comparison
- **Clímax: Por que Lua embedding?**

### Fechamento (10min)

- Resumo da jornada
- Kong em produção
- Q&A

## 📁 Arquivos de Apoio

- `README.md` - Documentação principal  
- `APRESENTACAO.md` - Slides estruturados
- `PLUGIN-LANGUAGES.md` - Comparação de linguagens
- `WHY_LUA.md` - Análise técnica completa
- `demo-all.sh` - Script de demonstração completa

## 🌟 Diferencial Deste Workshop

1. **Evolutivo**: Do básico ao avançado naturalmente
2. **Prático**: Todos os projetos são executáveis  
3. **Multi-linguagem**: Lua, Go, teoria comparativa
4. **Fundamentado**: Explica WHY, não só HOW
5. **Completo**: 10 projetos cobrindo todo o espectro Kong

---

**🎉 Resultado:** Audiência sai dominando Kong desde proxy básico até os fundamentos teóricos de design de sistemas embarcados!
