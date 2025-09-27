# 📁 Estrutura de Documentação - Kong Gateway Workshop

## 🎯 Visão Geral

A pasta `/docs` centraliza toda a documentação técnica do projeto, fornecendo uma base sólida para desenvolvimento, contribuição e manutenção do Kong Gateway Workshop.

## 📚 Índice da Documentação

### 🔧 Documentação de Desenvolvimento
- **[copilot-instructions.md](./copilot-instructions.md)** - Instruções para o agente AI do projeto
- **[ARCHITECTURE.md](./ARCHITECTURE.md)** - Arquitetura e padrões de design
- **[DEPENDENCIES.md](./DEPENDENCIES.md)** - Stack tecnológico e dependências

### 🤝 Documentação de Colaboração  
- **[CONTRIBUTING.md](./CONTRIBUTING.md)** - Guia de contribuição e padrões
- **[TESTING.md](./TESTING.md)** - Estratégias e convenções de testes

### 📖 Documentação do Projeto
- **[VISAO-GERAL.md](./VISAO-GERAL.md)** - Visão detalhada de todos os projetos
- **[DOCKER-CLEANUP.md](./DOCKER-CLEANUP.md)** - Guia de limpeza do Docker

### 📊 Documentação de Observabilidade
- **[observability-basic-proxy.md](./observability-basic-proxy.md)** - Monitoramento do projeto básico
- **[observability-metrics.md](./observability-metrics.md)** - Métricas e dashboards avançados

## 🎭 Como Usar Esta Documentação

### Para Desenvolvedores
1. **Início**: Leia `ARCHITECTURE.md` para entender a estrutura
2. **Setup**: Execute `make setup` (conforme `Makefile`)
3. **Desenvolvimento**: Siga `CONTRIBUTING.md` para padrões
4. **Testes**: Implemente seguindo `TESTING.md`

### Para Contribuidores
1. **Fork**: Clone o repositório
2. **Leia**: `CONTRIBUTING.md` para workflow
3. **Desenvolva**: Seguindo padrões arquiteturais
4. **Teste**: Execute `make test` antes do PR

### Para DevOps/SRE
1. **Dependências**: Consulte `DEPENDENCIES.md`
2. **Observabilidade**: Use documentos de monitoramento
3. **Automação**: Explore `Makefile` para comandos
4. **Troubleshooting**: Logs e debugging guidelines

## 🔄 Manutenção da Documentação

### Quando Atualizar
- ✅ **Novos projetos**: Atualizar `VISAO-GERAL.md`
- ✅ **Mudanças arquiteturais**: Revisar `ARCHITECTURE.md`
- ✅ **Novas dependências**: Atualizar `DEPENDENCIES.md`
- ✅ **Novos testes**: Documentar em `TESTING.md`
- ✅ **Mudanças no workflow**: Atualizar `CONTRIBUTING.md`

### Revisão Regular
```bash
# Verificar documentação mensalmente
make docs-check

# Atualizar links quebrados
make docs-validate

# Lint markdown
make lint-docs
```

## 📊 Métricas de Documentação

### Critérios de Qualidade
- **Completude**: Todos os aspectos cobertos
- **Atualidade**: Sincronizada com o código  
- **Clareza**: Linguagem clara e objetiva
- **Exemplos**: Código e comandos funcionais

### KPIs de Documentação
- 📈 **Coverage**: 100% dos projetos documentados
- 📈 **Freshness**: Atualizada há < 30 dias
- 📈 **Usability**: Links funcionais, exemplos válidos
- 📈 **Consistency**: Padrões uniformes entre docs

---

**🎯 Objetivo**: Manter documentação viva, útil e sempre atualizada para uma experiência de desenvolvimento excepcional!