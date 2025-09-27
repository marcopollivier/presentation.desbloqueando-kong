# Mock Services - Serviços Centralizados

Esta pasta contém os serviços mock centralizados que podem ser reutilizados por todos os exemplos do projeto.

## Serviços Disponíveis

### Go Mock API (go-mock-api-1)
- **Porta**: 3001
- **URL**: http://localhost:3001
- **Características**: Alta performance, baixa latência
- **Endpoints**:
  - `GET /health` - Health check
  - `GET /api/users` - Lista usuários
  - `GET /api/users/:id` - Usuário específico
  - `POST /api/users` - Criar usuário

### Node.js Mock API (node-mock-api-2)
- **Porta**: 3002
- **URL**: http://localhost:3002
- **Características**: Rico ecossistema, flexibilidade
- **Endpoints**:
  - `GET /health` - Health check
  - `GET /api/users` - Lista usuários
  - `GET /api/users/:id` - Usuário específico
  - `POST /api/users` - Criar usuário

## Uso Rápido

```bash
# Configurar e subir os serviços
make setup && make up

# Verificar status
make status

# Testar endpoints
make test

# Parar serviços
make down
```

## Network Externa

Os serviços utilizam uma network externa `mock-services-net` que permite comunicação com outros containers Docker (como Kong) em diferentes docker-compose.yml.

## Integração com Outros Exemplos

Para usar estes serviços em outros exemplos:

1. Certifique-se que os mock services estão rodando:
   ```bash
   cd 00-mock-services && make up
   ```

2. No seu docker-compose.yml, adicione a network externa:
   ```yaml
   networks:
     mock-services-net:
       external: true
       name: mock-services-net
   ```

3. Configure seus serviços para usar a network:
   ```yaml
   services:
     your-service:
       networks:
         - mock-services-net
   ```

4. Referencie os serviços pelos nomes dos containers:
   - `go-mock-api-1:3001`
   - `node-mock-api-2:3002`

## Comandos Disponíveis

| Comando | Descrição |
|---------|-----------|
| `make setup` | Configura network e build dos serviços |
| `make up` | Sobe os mock services |
| `make down` | Para os mock services |
| `make clean` | Remove tudo (containers, images, network) |
| `make logs` | Mostra logs dos serviços |
| `make status` | Status dos serviços |
| `make health` | Health check dos serviços |
| `make test` | Testa endpoints básicos |
| `make help` | Mostra ajuda |