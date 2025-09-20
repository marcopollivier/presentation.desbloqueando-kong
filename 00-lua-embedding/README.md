# Projeto 10: Por que Lua? - Embedding em Aplicações Go

Este projeto demonstra **por que Lua é a escolha ideal** para ser embarcado (embedded) em outras aplicações, como o Kong Gateway, Redis, nginx, WoW, e muitas outras soluções.

## 🎯 Objetivos do Projeto

- Entender as características técnicas que tornam Lua ideal para embedding
- Demonstrar integração prática entre Go e Lua
- Comparar Lua com outras linguagens de script
- Mostrar casos de uso reais onde Lua brilha

## 🔍 Por que Lua é Escolhido para Embedding?

### 1. **Leveza Extrema**
- **Interpretador**: ~247KB compiled
- **Footprint mínimo**: Ideal para sistemas com restrições de memória
- **Startup rápido**: Inicialização quase instantânea

### 2. **Simplicidade de Integração**
- **API C limpa**: Apenas ~30 funções principais na API
- **Stack-based**: Interface simples e consistente
- **Sem dependências externas**: Biblioteca autocontida

### 3. **Performance Excepcional**
- **Entre as linguagens de script mais rápidas**
- **LuaJIT**: Compilação JIT que compete com código nativo
- **Garbage Collector otimizado**: Paradas mínimas

### 4. **Sandbox Natural**
- **Isolamento por design**: Scripts não podem afetar o host por padrão
- **Controle granular**: Host define exatamente o que está disponível
- **Segurança**: Prevenção natural contra ataques

### 5. **Flexibilidade Extrema**
- **Sintaxe simples**: Fácil para usuários finais aprenderem
- **Metaprogramação poderosa**: Metatables e metamethods
- **Paradigmas múltiplos**: Funcional, OO, procedural

## 🏗️ Estrutura do Projeto

```
10-lua-embedding/
├── go-lua-host/          # Aplicação Go que executa Lua
├── lua-scripts/          # Scripts Lua de exemplo
├── examples/             # Casos de uso práticos
└── benchmarks/           # Comparação de performance
```

## 🚀 Executando os Exemplos

### 1. Exemplo Básico - Hello World
```bash
cd go-lua-host
go run main.go basic
```

### 2. Configuração Dinâmica
```bash
go run main.go config
```

### 3. Plugin System
```bash
go run main.go plugins
```

### 4. Sandbox e Segurança
```bash
go run main.go sandbox
```

### 5. Performance Benchmark
```bash
go run main.go benchmark
```

## 📊 Comparação com Outras Linguagens

| Característica | Lua | Python | JavaScript | Ruby |
|----------------|-----|--------|------------|------|
| **Tamanho Runtime** | ~247KB | ~15MB | ~20MB | ~12MB |
| **Startup Time** | <1ms | ~50ms | ~30ms | ~40ms |
| **Memory Usage** | Muito baixo | Alto | Médio | Alto |
| **API Complexity** | Simples | Complexa | Complexa | Complexa |
| **Embedding Ease** | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ | ⭐⭐ |

## 🌟 Casos de Uso Reais

### 1. **Kong Gateway**
- Plugins customizados em Lua
- Hot-reload de configurações
- Transformações de request/response

### 2. **Redis**
- Scripts EVAL/EVALSHA
- Operações atômicas complexas
- Lógica customizada server-side

### 3. **Nginx/OpenResty**
- Lógica de roteamento avançada
- Autenticação customizada
- Rate limiting inteligente

### 4. **World of Warcraft**
- Interface de usuário
- Addons da comunidade
- Customização do cliente

### 5. **Wireshark**
- Dissectores customizados
- Análise de protocolos
- Automação de análise

## 🔧 Implementação Técnica

O projeto demonstra:

1. **Integração Básica**: Como embeddar Lua em Go
2. **Comunicação Bidirecional**: Go ↔ Lua data exchange
3. **Controle de Sandbox**: Limitando funcionalidades disponíveis
4. **Plugin Architecture**: Sistema dinâmico de plugins
5. **Error Handling**: Tratamento robusto de erros
6. **Performance Monitoring**: Métricas e profiling

## 📚 Conceitos Demonstrados

- **Stack-based API**: Como funciona a pilha Lua-C
- **Userdata**: Expondo tipos Go para Lua
- **Metatables**: Criando APIs orientadas a objeto
- **Coroutines**: Concorrência cooperativa
- **Module System**: Carregamento dinâmico de módulos

## 🎓 Lições Aprendidas

Após executar este projeto, você entenderá:

1. Por que Lua é ubíquo em sistemas de alto desempenho
2. Como implementar um sistema de plugins eficiente
3. As vantagens técnicas do design minimalista do Lua
4. Como balancear flexibilidade com segurança
5. Por que "pequeno é belo" em software de sistema

## 🔗 Próximos Passos

- Experimente modificar os scripts Lua
- Implemente seus próprios plugins
- Compare a performance com outras soluções
- Explore a documentação do gopher-lua

---

**Nota**: Este projeto complementa perfeitamente os outros projetos Kong, mostrando a base tecnológica que torna o Kong tão poderoso e flexível.
