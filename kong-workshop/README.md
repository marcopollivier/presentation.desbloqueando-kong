# Kong Gateway Workshop - Projetos Evolutivos

Este workshop apresenta Kong Gateway através de projetos progressivos, do básico até plugins customizados.

## Estrutura dos Projetos

### 📚 Ordem Recomendada de Apresentação

1. **[Projeto 1: Kong Básico](./01-basic-proxy/)** - Proxy simples e conceitos fundamentais
2. **[Projeto 2: Autenticação](./02-authentication/)** - Key Auth e JWT
3. **[Projeto 3: Rate Limiting](./03-rate-limiting/)** - Controle de tráfego
4. **[Projeto 4: Load Balancing](./04-load-balancing/)** - Distribuição de carga
5. **[Projeto 5: Transformações](./05-transformations/)** - Manipulação de request/response
6. **[Projeto 6: Observabilidade](./06-observability/)** - Logging e monitoramento
7. **[Projeto 7: Plugin Customizado](./07-custom-plugin/)** - Plugin em Lua
8. **[Projeto 8: Lua Deep Dive](./08-lua-deep-dive/)** - Por que Lua + Arquitetura Kong

## 🚀 Pré-requisitos

- Docker e Docker Compose
- curl ou Postman
- Editor de código

## 🎯 Objetivos da Palestra

- Entender os conceitos fundamentais do Kong Gateway
- Aprender configurações declarativas vs Admin API
- Implementar padrões comuns de API Gateway
- Desenvolver plugins customizados em Lua

## 📖 Como Usar

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
- Scripts de demonstração
- Aplicações mock para teste

## 🎯 Fluxo Sugerido para Palestra

1. **Conceitos**: Comece explicando API Gateway e Kong
2. **Hands-on**: Execute projetos em ordem
3. **Evolução**: Mostre como cada projeto adiciona complexidade
4. **Customização**: Termine com plugin em Lua
5. **Q&A**: Discussão sobre casos de uso reais
