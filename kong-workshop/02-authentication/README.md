# Projeto 2: Autenticação

## 🎯 Objetivos
- Implementar Key Authentication
- Configurar JWT Authentication
- Gerenciar consumers e credenciais
- Entender plugins de autenticação

## 🏗️ Arquitetura
```
Cliente → Kong (Auth) → Mock API
```

## 📋 Conceitos Apresentados
- **Consumer**: Representa um usuário/aplicação
- **Key Auth Plugin**: Autenticação por API Key
- **JWT Plugin**: Autenticação por JSON Web Token
- **Plugin Scope**: Global, Service, Route, Consumer

## 🚀 Como Executar

### 1. Subir o ambiente
```bash
docker-compose up -d
```

### 2. Testar sem autenticação (deve falhar)
```bash
# Tenta acessar endpoint protegido
curl -i http://localhost:8000/api/posts
# Resposta: 401 Unauthorized
```

### 3. Testar com API Key
```bash
# Usando API Key configurada
curl -H "apikey: my-secret-key-123" http://localhost:8000/api/posts

# Testando key inválida
curl -H "apikey: invalid-key" http://localhost:8000/api/posts
```

### 4. Testar com JWT
```bash
# Execute o script para gerar JWT
./generate-jwt.sh

# Use o JWT gerado
curl -H "Authorization: Bearer <JWT_TOKEN>" http://localhost:8000/jwt/posts
```

### 5. Gerenciar consumers via Admin API
```bash
# Listar consumers
curl -s http://localhost:8001/consumers | jq

# Adicionar novo consumer
curl -X POST http://localhost:8001/consumers \
  -d "username=new-user"

# Adicionar API key para consumer
curl -X POST http://localhost:8001/consumers/new-user/key-auth \
  -d "key=new-user-key-456"
```

## 📚 Pontos de Discussão

1. **Tipos de Autenticação**
   - API Key: Simples, mas menos segura
   - JWT: Stateless, mais informações no token
   - OAuth 2.0, Basic Auth, LDAP...

2. **Scope de Plugins**
   - Global: Todos os requests
   - Service: Todos os routes do service
   - Route: Apenas aquele route específico

3. **Gerenciamento de Credenciais**
   - Rotação de keys
   - Revogação de acesso
   - Auditoria

## 🧹 Limpeza
```bash
docker-compose down -v
```
