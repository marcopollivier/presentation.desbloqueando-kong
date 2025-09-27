# Projeto 5: Transformações de Request e Response

## 🎯 Objetivos
- Implementar Request/Response Transformer plugins
- Configurar correlação de requests
- Manipular headers, query params e body
- Demonstrar casos de uso comuns

## 🏗️ Arquitetura
```
Cliente → Kong (Transformers) → Mock API
```

## 📋 Conceitos Apresentados

- **Request Transformer**: Enriquece requests com correlation ID
- **Response Transformer**: Remove headers sensíveis das responses
- **Correlation ID**: Rastreamento simples de requests
- **Security Headers**: Limpeza de informações expostas

## 🚀 Como Executar

### 1. Subir o ambiente

```bash
docker-compose up -d
```

### 2. Testar as transformações

```bash
# Observe o Correlation ID adicionado e headers de segurança removidos
curl -v http://localhost:8000/api/posts/1

# Teste com diferentes endpoints
curl -i http://localhost:8000/api/users/1
```

## 📚 Pontos de Discussão

1. **Enriquecimento Simples**
   - Correlation ID automático para rastreamento
   - Header de identificação do gateway

2. **Segurança Básica**
   - Remoção de headers que expõem informações do backend
   - Limpeza automática de dados sensíveis

3. **Observabilidade**
   - Como correlation IDs ajudam no troubleshooting
   - Identificação de requests processados pelo Kong

## 🧹 Limpeza

```bash
docker-compose down -v
```
