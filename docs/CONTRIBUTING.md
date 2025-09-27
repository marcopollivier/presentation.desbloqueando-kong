# Guia de Contribuição - Kong Gateway Workshop

## 🎯 Visão Geral

Este documento estabelece as diretrizes para contribuir com o **Kong Gateway Workshop**, um projeto educacional que demonstra padrões de API Gateway através de exemplos progressivos.

## 🏗️ Filosofia de Desenvolvimento

### Princípios Core
- **Educacional primeiro**: Código deve ser claro e didático
- **Progressivo**: Cada projeto deve evoluir em complexidade
- **Produção-ready**: Demonstrar boas práticas do mundo real
- **Manutenível**: Código limpo, documentado e testável

### Padrões Arquiteturais
- **Clean Architecture**: Separação de responsabilidades
- **Vertical Slices**: Features independentes por pasta
- **Infrastructure as Code**: Configurações declarativas
- **Observabilidade**: Métricas e monitoramento sempre presentes

## 🌳 Estratégia de Branches

### Branch Principal
```
main (protected)
├── 📦 releases/v1.0.0
├── 🚀 feature/new-project-08
├── 🐛 bugfix/fix-metrics-dashboard
├── 📚 docs/update-architecture
└── 🔧 chore/update-dependencies
```

### Nomenclatura de Branches
- `feature/project-<numero>-<descricao>` - Novos projetos/funcionalidades
- `feature/<descricao-curta>` - Melhorias gerais
- `bugfix/<descricao-do-bug>` - Correções de bugs
- `docs/<tipo-documentacao>` - Atualizações de documentação
- `chore/<tipo-manutencao>` - Manutenção e refatoração
- `hotfix/<urgencia>` - Correções críticas

### Workflow GitFlow Simplificado
```bash
# 1. Criar branch da main
git checkout main
git pull origin main
git checkout -b feature/projeto-08-security

# 2. Desenvolver e commitar (conventional commits)
git add .
git commit -m "feat(project-08): add security plugins demo"

# 3. Push e Pull Request
git push origin feature/projeto-08-security
# Criar PR via GitHub/GitLab
```

## 📝 Convenções de Commits

### Conventional Commits
Seguimos o padrão [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Tipos de Commit
- `feat`: Nova funcionalidade ou projeto
- `fix`: Correção de bug
- `docs`: Alterações na documentação
- `style`: Formatação (não afeta funcionalidade)
- `refactor`: Refatoração de código
- `test`: Adição ou correção de testes
- `chore`: Manutenção (deps, build, etc.)
- `perf`: Melhorias de performance

### Exemplos de Commits
```bash
# Novo projeto
feat(project-08): add security plugins demonstration
feat(load-balancing): implement health checks

# Bug fixes
fix(metrics): correct Prometheus configuration path
fix(docker): resolve container startup race condition

# Documentação
docs(architecture): add hexagonal pattern explanation
docs(readme): update project structure after reorganization

# Manutenção
chore(deps): update Kong Gateway to 3.4.1
chore(docker): optimize image build process
```

### Escopo Sugerido por Projeto
- `project-01` - Proxy básico
- `project-02` - Load balancing
- `project-03` - Authentication
- `project-04` - Rate limiting
- `project-05` - Transformations
- `project-06` - Custom plugins
- `project-07` - Metrics & observability
- `docs` - Documentação
- `ci` - Integração contínua
- `docker` - Configurações Docker

## 🔄 Processo de Pull Request

### Checklist do PR
- [ ] **Título descritivo** seguindo conventional commits
- [ ] **Descrição clara** do que foi implementado/corrigido
- [ ] **Testes executados** e funcionando
- [ ] **Documentação atualizada** (README, docs específicos)
- [ ] **Docker Compose** funcional no projeto
- [ ] **Bruno collection** atualizada se aplicável
- [ ] **Makefile targets** testados
- [ ] **Screenshots/demos** se for feature visual

### Template de PR
```markdown
## 🎯 Objetivo
Breve descrição do que foi implementado/corrigido.

## 📋 Checklist Técnico
- [ ] Docker Compose up/down funcional
- [ ] Kong configuration válida
- [ ] Scripts de demo executando
- [ ] Bruno requests testadas
- [ ] Documentação atualizada

## 🧪 Como Testar
```bash
cd projeto-XX
make up     # ou docker-compose up -d
make test   # ou script de teste específico
make down   # ou docker-compose down -v
```

## 📊 Impacto
- **Projetos afetados**: XX
- **Breaking changes**: Sim/Não
- **Documentação necessária**: Sim/Não

## 📸 Screenshots/Demo
(Se aplicável)
```

### Revisão de Código
- **Mínimo 1 reviewer** para mudanças não-críticas
- **Mínimo 2 reviewers** para mudanças em infraestrutura
- **Auto-merge** após aprovação e CI verde
- **Squash and merge** preferencial para manter histórico limpo

## 🧪 Padrões de Teste

### Níveis de Teste
1. **Smoke Tests**: `make test` deve passar em todos os projetos
2. **Integration Tests**: Docker containers sobem corretamente
3. **E2E Tests**: Bruno collections executam sem erro
4. **Load Tests**: Scripts de carga quando aplicável

### Comandos de Teste
```bash
# Teste individual por projeto
cd 01-basic-proxy
make test

# Teste de todo o workshop
make test-all

# Teste de linting/formatting
make lint

# Teste de documentação
make docs-check
```

## 📊 Quality Gates

### Obrigatórios
- ✅ **Builds passando** em todos os ambientes
- ✅ **Testes automatizados** executando
- ✅ **Documentação atualizada**
- ✅ **Docker Compose funcional**
- ✅ **Zero vulnerabilidades críticas**

### Recomendados
- 🎯 **Coverage de testes** > 80% em plugins customizados
- 🎯 **Performance** mantida ou melhorada
- 🎯 **Métricas** coletadas e dashboards funcionais
- 🎯 **Logs estruturados** quando aplicável

## 🔧 Setup de Desenvolvimento

### Pré-requisitos
```bash
# Verificar dependências
make check-deps

# Setup inicial
make setup

# Ambiente de desenvolvimento
make dev-setup
```

### Ferramentas Recomendadas
- **Docker Desktop** ou **Podman** para containers
- **Bruno** para teste de APIs
- **VS Code** com extensões Kong/Docker
- **Make** para automação de comandos

## 🚀 Release Process

### Versionamento Semântico
- `MAJOR.MINOR.PATCH` (ex: 1.2.3)
- **MAJOR**: Breaking changes ou reestruturação
- **MINOR**: Novos projetos ou funcionalidades
- **PATCH**: Bug fixes e melhorias pequenas

### Pipeline de Release
```bash
# 1. Tag de release
git tag -a v1.2.0 -m "Release v1.2.0: Add security project"

# 2. Push da tag
git push origin v1.2.0

# 3. GitHub Actions cria release automaticamente
# 4. Documentação é atualizada automaticamente
```

## 📞 Suporte e Comunicação

### Canais
- **Issues**: Bug reports e feature requests
- **Discussions**: Dúvidas e ideias gerais
- **Wiki**: Documentação técnica avançada
- **README**: Documentação principal

### Labels de Issues
- `bug` - Bugs confirmados
- `enhancement` - Melhorias e novas features
- `documentation` - Melhorias na documentação
- `good first issue` - Boas para iniciantes
- `help wanted` - Precisa de ajuda da comunidade
- `project-XX` - Específico de um projeto

---

## 📚 Recursos Adicionais

- [Conventional Commits](https://www.conventionalcommits.org/)
- [GitFlow Workflow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow)
- [Kong Gateway Docs](https://docs.konghq.com/)
- [Clean Architecture Principles](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

**Obrigado por contribuir! 🚀**