# Docker Cleanup Script

Este script oferece uma limpeza completa e segura do Docker, removendo todos os recursos do sistema.

## ⚠️ Aviso Importante

**Este script remove TODOS os recursos Docker do sistema, não apenas os do projeto atual!**

Serão removidos:

- 🐳 Todos os containers (parados e em execução)
- 🖼️ Todas as imagens Docker
- 💾 Todos os volumes
- 🌐 Todas as redes customizadas
- 🗑️ Cache de build e recursos órfãos

## 📋 Uso

### Execução Interativa (Recomendado)

```bash
./docker-cleanup.sh
```

- Mostra estatísticas atuais
- Solicita confirmação antes de executar
- Executa limpeza passo a passo com feedback

### Execução Automática (Perigoso!)

```bash
./docker-cleanup.sh --force
```

- Executa limpeza sem confirmação
- Use apenas em scripts automatizados onde você tem certeza

### Apenas Visualizar Estatísticas

```bash
./docker-cleanup.sh --stats-only
```

- Mostra apenas as estatísticas atuais do Docker
- Não executa nenhuma limpeza

### Ajuda

```bash
./docker-cleanup.sh --help
```

## 🚀 Exemplos de Uso

### Limpeza completa com confirmação

```bash
./docker-cleanup.sh
# Mostra estatísticas, pede confirmação e executa limpeza
```

### Verificar o que seria removido

```bash
./docker-cleanup.sh --stats-only
# Apenas visualiza o estado atual sem remover nada
```

### Limpeza em CI/CD (automática)

```bash
./docker-cleanup.sh --force
# Executa imediatamente sem confirmação
```

## 🛡️ Segurança

- ✅ Solicita confirmação por padrão
- ✅ Verifica se Docker está rodando
- ✅ Mostra estatísticas antes e depois
- ✅ Feedback colorido e detalhado
- ✅ Opção de cancelar a qualquer momento (Ctrl+C)
- ⚠️ Modo `--force` bypassa confirmações

## 📊 Saída do Script

O script fornece:

- 📈 Estatísticas detalhadas do Docker
- 🎨 Output colorido e organizado
- ✅ Confirmação de cada etapa executada
- 📝 Resumo final do espaço liberado

## 🔧 Requisitos

- Docker instalado e rodando
- Bash shell
- Permissões para executar comandos Docker

## 🚨 Recuperação

Após executar este script, você precisará:

1. Recriar suas imagens (`docker build` ou `docker pull`)
2. Recriar seus volumes (se continham dados importantes)
3. Recriar suas redes customizadas
4. Reiniciar seus containers

## 💡 Dicas

- 🔍 Use `--stats-only` primeiro para ver o que seria removido
- 💾 Faça backup de volumes importantes antes da limpeza
- 🐳 Consider usar `docker compose down -v` para projetos específicos
- 📦 Para limpeza menos agressiva, use `docker system prune`
