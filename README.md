# 🌟 Kong Gateway Workshop - Projetos Evolutivos

Este workshop apresenta Kong Gateway através de projetos progressivos, desde conceitos fundamentais até plugins avançados multi-linguagem.

## 🎯 Visão Geral

Demonstração prática e evolutiva do Kong Gateway, explorando desde proxy básico até desenvolvimento de plugins customizados, culminando com uma análise técnica sobre **por que Lua é escolhido** para embedding em sistemas como Kong.

## 📊 Estrutura dos Projetos

### 🎢 Progressão de Aprendizado

```text
Fundamentos (00)    → Básico (01-04)      → Avançado (05-08)
      ↓                      ↓                      ↓
 Conceitos Lua      Proxy/Auth/Rate/LB    Plugins/Go/Teoria
```

### 📚 Projetos do Workshop

| # | Projeto | Conceito Principal | Tecnologias | Duração |
|---|---------|-------------------|-------------|---------|
| **00** | **[Lua Embedding](./00-lua-embedding/)** | Por que Lua? Fundamentos | Go + gopher-lua | 15min |
| **01** | **[Proxy Básico](./01-basic-proxy/)** | Kong como reverse proxy | Kong + nginx | 5min |
| **02** | **[Load Balancing](./02-load-balancing/)** | Distribuição de carga | Kong + multi-upstream | 10min |
| **03** | **[Autenticação](./03-authentication/)** | Key Auth + JWT | Kong + Auth plugins | 8min |
| **04** | **[Rate Limiting](./04-rate-limiting/)** | Controle de tráfego | Kong + Redis | 7min |
| **05** | **[Transformações](./05-transformations/)** | Request/Response transform | Kong + transform plugins | 8min |
| **06** | **[Plugin Customizado](./06-custom-plugin/)** | Plugin Lua personalizado | Lua + Kong PDK | 15min |
| **07** | **[Lua Deep Dive](./07-lua-deep-dive/)** | Recursos avançados Lua | OpenResty + LuaJIT | 12min |
| **08** | **[Go Plugin](./08-go-plugin/)** | Plugin Go com PDK | Go + Kong Go PDK | 18min |

> ⏱️ **Duração total estimada**: ~1h38min

## 🧪 Coleção de Testes - Bruno

O projeto inclui uma coleção organizada de requisições HTTP usando **Bruno** para facilitar os testes:

```text
_bruno/kong/
├── 01 - Base requests/     # Status, serviços, headers
├── 02 - Load balancer/     # Testes de distribuição de carga  
├── 03 - auth/              # Autenticação e tokens
├── 04 - rate limit/        # Limites de taxa
├── 05 - transformation/    # Transformações de dados
└── 06 - lua plugin/        # Plugins customizados
```

### Como usar a coleção Bruno

1. **Instalar Bruno**: [Download oficial](https://www.usebruno.com/)
2. **Abrir coleção**: File → Open Collection → `_bruno/kong`
3. **Executar projeto**: `docker-compose up -d` no diretório desejado
4. **Testar endpoints**: Usar as requisições organizadas por funcionalidade

## 🚀 Execução Rápida

### Demonstração Completa (Automática)

```bash
./demo-all.sh
```

### Projeto Individual

```bash
cd <projeto-desejado>
docker-compose up -d
# Seguir instruções do README.md
docker-compose down -v
```

## 📁 Estrutura dos Projetos

Cada projeto possui:

- `README.md` com explicação detalhada
- `docker-compose.yml` para ambiente isolado  
- `kong.yml` com configuração declarativa
- Scripts de demonstração quando aplicável
- Aplicações mock para teste

## 🚀 Pré-requisitos

- **Docker** e **Docker Compose**
- **Bruno** (opcional, para testes organizados)
- **curl** ou **Postman** (alternativa ao Bruno)
- Editor de código

## 🎯 Objetivos do Workshop

- Entender os conceitos fundamentais do Kong Gateway
- Aprender configurações declarativas vs Admin API  
- Implementar padrões comuns de API Gateway
- Desenvolver plugins customizados em Lua e Go
- Compreender por que Lua é ideal para embedding

## 🎯 Fluxo Sugerido para Apresentação

1. **Conceitos** (00): Comece com fundamentos do Lua e embedding
2. **Básico** (01-04): Proxy, load balancing, auth e rate limiting
3. **Avançado** (05-08): Transformações, plugins customizados e Go
4. **Teoria** (07-08): Lua deep dive e comparação Go vs Lua
5. **Q&A**: Discussão sobre casos de uso reais

## 📖 Documentação Complementar

- **[VISAO-GERAL.md](./VISAO-GERAL.md)** - Visão detalhada de todos os projetos
- **Coleção Bruno** - Requisições organizadas para teste em `_bruno/kong/`
- **READMEs individuais** - Documentação específica de cada projeto

## 🔗 Links Úteis

- [Kong Gateway Docs](https://docs.konghq.com/gateway/)
- [Kong Plugin Development](https://docs.konghq.com/gateway/latest/plugin-development/)
- [Bruno API Client](https://www.usebruno.com/)
- [Lua Programming Guide](https://www.lua.org/manual/5.1/)

---

**💡 Dica**: Comece pelo projeto `00-lua-embedding` para entender os fundamentos antes de partir para os exemplos práticos do Kong.
