# Exemplos Práticos - Lua Embedding

Este diretório contém exemplos práticos de como diferentes sistemas usam Lua como linguagem embarcada.

## 📁 Estrutura dos Exemplos

- `kong_like/` - Simulação de como Kong usa Lua
- `nginx_like/` - Exemplo similar ao OpenResty/nginx
- `redis_like/` - Exemplo de scripts como Redis EVAL
- `game_like/` - Exemplo de scripting em jogos

## 🎯 Objetivos

Cada exemplo demonstra:
- **Por que** Lua foi escolhido para aquele caso de uso
- **Como** a integração é implementada
- **Quais** benefícios isso traz
- **Quando** usar essa abordagem

## 🚀 Como Executar

Cada subdiretório tem suas próprias instruções específicas.

Para ver todos os exemplos:
```bash
cd ../go-lua-host
go run main.go basic
go run main.go config  
go run main.go plugins
go run main.go sandbox
go run main.go benchmark
```

## 💡 Conceitos Demonstrados

1. **Leveza**: Lua vs outras linguagens de script
2. **Integração**: API simples e consistente
3. **Performance**: Velocidade comparativa
4. **Sandbox**: Segurança e isolamento
5. **Flexibilidade**: Adaptabilidade a diferentes contextos
