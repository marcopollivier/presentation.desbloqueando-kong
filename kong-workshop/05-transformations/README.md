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
- **Request Transformer**: Modifica requests antes do upstream
- **Response Transformer**: Modifica responses antes do cliente
- **Correlation ID**: Rastreamento de requests
- **Header Manipulation**: Adicionar/remover/substituir headers

## 🚀 Como Executar

### 1. Subir o ambiente
```bash
docker-compose up -d
```

### 2. Testar transformações de request
```bash
# Request normal - observe headers adicionados
curl -v http://localhost:8000/api/posts/1

# Request com header personalizado - será transformado
curl -H "Client-Version: 1.0" -v http://localhost:8000/api/posts/1
```

### 3. Testar transformações de response
```bash
# Response será modificado com headers extras
curl -i http://localhost:8000/api/posts/1

# Testar com diferentes endpoints
curl -i http://localhost:8000/api/users/1
```

### 4. Ver logs para debugging
```bash
docker-compose logs kong | grep "correlation"
```

## 📚 Pontos de Discussão

1. **Use Cases Comuns**
   - API versioning através de headers
   - Correlation IDs para tracing
   - Sanitização de dados
   - Enriquecimento de requests

2. **Performance Considerations**
   - Transformações são executadas a cada request
   - Body transformations são mais custosas
   - Cache quando possível

## 🧹 Limpeza
```bash
docker-compose down -v
```
