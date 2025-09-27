# Projeto 3: Autenticação JWT

## 🎯 Objetivos
- Configurar JWT Authentication
- Gerenciar consumers e credenciais JWT
- Entender plugins de autenticação no Kong

## 🏗️ Arquitetura
```
Cliente → Kong (JWT Auth) → JSONPlaceholder API
```

## 📋 Conceitos Apresentados
- **Consumer**: Representa um usuário/aplicação
- **JWT Plugin**: Autenticação por JSON Web Token
- **JWT Secrets**: Chaves secretas para validação de tokens
- **Plugin Scope**: Aplicado no nível do service

## 🚀 Como Executar

### 1. Subir o ambiente
```bash
docker-compose up -d
```

### 2. Testar sem autenticação (deve falhar)

```bash
# Tenta acessar endpoint protegido
curl -i http://localhost:8000/posts
# Resposta: 401 Unauthorized {"message":"Unauthorized"}
```

### 3. Testar com JWT

```bash
# Execute o script para gerar JWT
./generate-jwt.sh

# Use o JWT gerado (exemplo)
curl -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." http://localhost:8000/posts

# Outros endpoints disponíveis
curl -H "Authorization: Bearer <JWT_TOKEN>" http://localhost:8000/users
curl -H "Authorization: Bearer <JWT_TOKEN>" http://localhost:8000/comments
```

### 4. Verificar consumers configurados

```bash
# Listar consumers
curl -s http://localhost:8001/consumers | jq
```

## 📚 Pontos de Discussão

1. **JWT vs outras autenticações**
   - JWT: Stateless, informações no token, mais seguro
   - Não precisa consultar base de dados para validar
   - Expiration time integrado

2. **Configuração DB-less**
   - Credenciais definidas no arquivo kong.yml
   - Não permite alterações via Admin API
   - Ideal para ambientes imutáveis

3. **Segurança JWT**
   - Secret key com mínimo 256 bits
   - Algoritmo HMAC SHA256
   - Claims obrigatórios: iss, exp

## 🧹 Limpeza

```bash
