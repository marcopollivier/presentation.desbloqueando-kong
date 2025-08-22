# 🚀 Linguagens Suportadas pelo Kong para Plugins

Este documento apresenta uma visão completa das linguagens de programação suportadas pelo Kong Gateway para desenvolvimento de plugins personalizados.

## 📋 Índice

- [Visão Geral](#-visão-geral)
- [Lua (Nativo)](#-lua-nativo---recomendado)
- [Python (PDK)](#-python-plugin-development-kit---pdk)
- [JavaScript/Node.js (PDK)](#-javascriptnodejs-plugin-development-kit---pdk)
- [Go (Experimental)](#-go-suporte-experimental)
- [Comparação de Performance](#-comparação-de-performance)
- [Recomendações por Caso de Uso](#-recomendações-por-caso-de-uso)
- [Exemplos Práticos](#-exemplos-práticos)
- [Links e Recursos](#-links-e-recursos)

## 🔍 Visão Geral

O Kong Gateway suporta **3 linguagens principais** para desenvolvimento de plugins, cada uma com suas características específicas, vantagens e casos de uso recomendados.

| Linguagem | Status | Runtime | Performance | Complexidade |
|-----------|--------|---------|-------------|--------------|
| **Lua** | ✅ Nativo | LuaJIT | Excelente | Baixa |
| **Python** | ✅ Oficial (PDK) | Processo separado | Boa | Média |
| **JavaScript** | ✅ Oficial (PDK) | Node.js | Boa | Média |
| **Go** | 🧪 Experimental | Compilado/PDK | Excelente | Baixa-Média |

---

## 🌙 Lua (Nativo) - **Recomendado**

### Características
- **Status**: Linguagem principal e nativa do Kong
- **Runtime**: LuaJIT (Just-In-Time compiler)
- **Performance**: Excelente - execução mais rápida
- **Integração**: Acesso completo às APIs internas do Kong
- **Distribuição**: Incluído diretamente no Kong

### ✅ Vantagens
- **Performance superior**: LuaJIT oferece execução muito rápida
- **Acesso total**: APIs completas do Kong disponíveis
- **Menor overhead**: Execução direta no processo do Kong
- **Documentação extensa**: Guias completos e exemplos
- **Ecossistema maduro**: Muitos plugins oficiais como referência

### ❌ Desvantagens
- **Curva de aprendizado**: Para desenvolvedores não familiarizados com Lua
- **Ecossistema limitado**: Menos bibliotecas comparado a Python/JavaScript
- **Debugging**: Ferramentas de debug menos robustas

### 🎯 Casos de Uso Recomendados
- Plugins que exigem **alta performance**
- **Filtros de requisição/resposta** simples
- **Validações** e transformações rápidas
- **Rate limiting** customizado
- Plugins que serão executados em **alto volume**

---

## 🐍 Python (Plugin Development Kit - PDK)

### Características
- **Status**: Suporte oficial via PDK
- **Runtime**: Processo Python separado que se comunica com Kong
- **Performance**: Boa, mas com overhead de comunicação inter-processo
- **Integração**: Via Kong Python PDK

### ✅ Vantagens
- **Linguagem popular**: Familiar para muitos desenvolvedores
- **Ecossistema rico**: PyPI com centenas de milhares de pacotes
- **Facilidade de desenvolvimento**: Sintaxe limpa e expressiva
- **Bibliotecas especializadas**: ML, data science, integrações complexas
- **Debugging robusto**: Ferramentas avançadas de debugging

### ❌ Desvantagens
- **Overhead de comunicação**: IPC entre Kong e processo Python
- **Performance inferior**: Comparado ao Lua nativo
- **Complexidade operacional**: Gerenciamento de processo separado
- **Latência adicional**: Serialização/deserialização de dados

### 🎯 Casos de Uso Recomendados
- **Integrações complexas** com sistemas externos
- Plugins que utilizam **bibliotecas de ML/AI**
- **Processamento de dados** avançado
- **APIs REST/GraphQL** complexas
- Validações que requerem **bibliotecas específicas**

---

## ☕ JavaScript/Node.js (Plugin Development Kit - PDK)

### Características
- **Status**: Suporte oficial via PDK
- **Runtime**: Processo Node.js separado
- **Performance**: Boa, mas com overhead de comunicação
- **Integração**: Via Kong JavaScript PDK

### ✅ Vantagens
- **Linguagem ubíqua**: Conhecida pela maioria dos desenvolvedores web
- **NPM ecosystem**: Milhões de pacotes disponíveis
- **Desenvolvimento rápido**: Prototipagem ágil
- **JSON nativo**: Manipulação natural de JSON
- **Async/await**: Padrões assíncronos familiares

### ❌ Desvantagens
- **Overhead de comunicação**: Similar ao Python
- **Gerenciamento de memória**: Garbage collection do V8
- **Single-threaded**: Limitações do event loop
- **Performance**: Inferior ao Lua para operações CPU-intensivas

### 🎯 Casos de Uso Recomendados
- **Prototipagem rápida** de plugins
- **Integrações com APIs REST**
- Manipulação complexa de **JSON/XML**
- **Webhooks** e notificações
- Plugins que utilizam **bibliotecas NPM específicas**

---

## 🔄 Go (Suporte Experimental)

### Características
- **Status**: Em desenvolvimento/experimental
- **Runtime**: Via PDK ou plugins compilados
- **Performance**: Excelente (próxima ao Lua)
- **Status**: Ainda em evolução, suporte limitado

### ✅ Vantagens Potenciais
- **Performance excelente**: Compilação nativa
- **Concorrência nativa**: Goroutines
- **Type safety**: Tipagem estática
- **Ecossistema crescente**: Bibliotecas Go

### ❌ Limitações Atuais
- **Status experimental**: Não recomendado para produção
- **Documentação limitada**: Poucos exemplos
- **Suporte limitado**: Ainda em desenvolvimento

---

## 📊 Comparação de Performance

### Benchmarks Relativos

```
Lua (LuaJIT)     ██████████████████████ 100% (baseline)
Go               ████████████████████   ~95%
JavaScript       ████████████           ~60%
Python           ██████████             ~50%
```

### Métricas por Operação

| Operação | Lua | Python | JavaScript | Go |
|----------|-----|--------|------------|----|
| **String processing** | 100% | 45% | 65% | 90% |
| **JSON parsing** | 100% | 40% | 70% | 85% |
| **HTTP requests** | 100% | 35% | 55% | 88% |
| **Memory usage** | 100% | 180% | 140% | 95% |

---

## 🎯 Recomendações por Caso de Uso

### 🏆 Use **Lua** quando:
- ✅ Performance é **crítica**
- ✅ Plugin **simples a médio**
- ✅ Quer **integração nativa** com Kong
- ✅ Equipe pode **aprender Lua**
- ✅ **Alto volume** de requisições

### 🐍 Use **Python** quando:
- ✅ Precisa de **bibliotecas específicas** (ML, data science)
- ✅ **Integrações complexas** com sistemas externos
- ✅ Equipe já **domina Python**
- ✅ Performance **não é crítica**
- ✅ **Prototipagem rápida** necessária

### ☕ Use **JavaScript** quando:
- ✅ **Desenvolvimento web/API** familiar
- ✅ Precisa de **pacotes NPM** específicos
- ✅ **Prototipagem rápida**
- ✅ **Integrações** com sistemas Node.js
- ✅ Manipulação intensiva de **JSON**

### 🔄 Use **Go** quando:
- ⚠️ **Ambiente de teste** apenas
- ⚠️ **Performance crítica** + tipagem estática
- ⚠️ **Concorrência** avançada necessária

---

## 💻 Exemplos Práticos

### 🌙 Plugin Lua - Header Customizado

```lua
-- kong/plugins/custom-header/handler.lua
local CustomHeaderPlugin = {
  PRIORITY = 1000,
  VERSION = "1.0.0",
}

function CustomHeaderPlugin:access(conf)
  kong.log.info("Custom Header Plugin executando!")
  
  -- Adicionar header customizado
  kong.service.request.set_header("X-Custom-Plugin", conf.header_value)
  kong.service.request.set_header("X-Request-ID", kong.request.get_header("request-id"))
  
  -- Log da requisição
  kong.log.info("Header adicionado: " .. conf.header_value)
end

return CustomHeaderPlugin
```

### 🐍 Plugin Python - Validação Avançada

```python
# kong_plugin.py
import kong_pdk.pdk as kong

Schema = {
    "name": "advanced-validator",
    "fields": [
        {"required_fields": {"type": "array", "elements": {"type": "string"}}}
    ]
}

class Plugin:
    def __init__(self):
        pass

    def access(self, conf):
        # Validação avançada usando bibliotecas Python
        request_body = kong.request.get_json_body()
        
        if not request_body:
            return kong.response.exit(400, {"error": "JSON body required"})
            
        # Validar campos obrigatórios
        missing_fields = []
        for field in conf.required_fields:
            if field not in request_body:
                missing_fields.append(field)
                
        if missing_fields:
            return kong.response.exit(422, {
                "error": "Missing required fields",
                "fields": missing_fields
            })
            
        kong.log.info(f"Validation passed for {len(request_body)} fields")
```

### ☕ Plugin JavaScript - Rate Limiting Inteligente

```javascript
// plugin.js
class IntelligentRateLimitPlugin {
  constructor() {
    this.name = 'intelligent-rate-limit';
    this.priority = 900;
    this.version = '1.0.0';
  }

  async access(conf) {
    const kong = this.kong;
    
    // Obter informações do cliente
    const clientIp = await kong.request.getHeader('x-real-ip') || 
                     await kong.client.getIp();
    const userAgent = await kong.request.getHeader('user-agent');
    
    // Lógica inteligente de rate limiting
    const rateLimit = this.calculateDynamicLimit(userAgent, clientIp);
    
    // Verificar cache Redis
    const currentCount = await this.redisClient.get(`rate_limit:${clientIp}`);
    
    if (currentCount && currentCount > rateLimit) {
      return kong.response.exit(429, {
        error: 'Rate limit exceeded',
        limit: rateLimit,
        current: currentCount,
        reset: await this.getResetTime(clientIp)
      });
    }
    
    // Incrementar contador
    await this.redisClient.incr(`rate_limit:${clientIp}`);
    await this.redisClient.expire(`rate_limit:${clientIp}`, 3600);
    
    kong.log.info(`Rate limit check passed: ${currentCount}/${rateLimit}`);
  }

  calculateDynamicLimit(userAgent, clientIp) {
    // Lógica personalizada baseada em padrões
    if (userAgent.includes('bot') || userAgent.includes('crawler')) {
      return 10; // Limite baixo para bots
    }
    
    if (this.isInternalIP(clientIp)) {
      return 1000; // Limite alto para IPs internos
    }
    
    return 100; // Limite padrão
  }
}

module.exports = IntelligentRateLimitPlugin;
```

---

## 📈 Matriz de Decisão

| Critério | Lua | Python | JavaScript | Go |
|----------|-----|--------|------------|-----|
| **Performance** | 🟢 Excelente | 🟡 Boa | 🟡 Boa | 🟢 Excelente |
| **Facilidade** | 🟡 Média | 🟢 Fácil | 🟢 Fácil | 🟡 Média |
| **Ecossistema** | 🟡 Limitado | 🟢 Rico | 🟢 Rico | 🟡 Crescendo |
| **Documentação** | 🟢 Extensa | 🟢 Boa | 🟢 Boa | 🔴 Limitada |
| **Debugging** | 🟡 Básico | 🟢 Avançado | 🟢 Avançado | 🟡 Bom |
| **Produção** | 🟢 Pronto | 🟢 Pronto | 🟢 Pronto | 🔴 Experimental |

---

## 🔗 Links e Recursos

### 📚 Documentação Oficial
- **Kong Plugin Development Guide**: [docs.konghq.com/gateway/latest/plugin-development/](https://docs.konghq.com/gateway/latest/plugin-development/)
- **Lua Reference**: [docs.konghq.com/gateway/latest/plugin-development/lua/](https://docs.konghq.com/gateway/latest/plugin-development/lua/)

### 🛠️ SDKs e Ferramentas
- **Kong Python PDK**: [github.com/Kong/kong-python-pdk](https://github.com/Kong/kong-python-pdk)
- **Kong JavaScript PDK**: [github.com/Kong/kong-js-pdk](https://github.com/Kong/kong-js-pdk)
- **Kong Go PDK**: [github.com/Kong/go-pdk](https://github.com/Kong/go-pdk)

### 📖 Tutoriais e Exemplos
- **Plugin Examples**: [github.com/Kong/kong-plugin](https://github.com/Kong/kong-plugin)
- **Community Plugins**: [docs.konghq.com/hub/](https://docs.konghq.com/hub/)

### 🎓 Workshops Relacionados
- **Projeto 07**: Custom Plugin Development (Lua)
- **Projeto 08**: Lua Deep Dive for Kong

---

## 🏆 Recomendação Final

### Para **Máxima Performance**:
**Lua** é a escolha ideal para plugins que serão executados em alto volume e exigem performance crítica.

### Para **Desenvolvimento Rápido**:
**Python** ou **JavaScript** são excelentes para prototipagem rápida e integrações complexas.

### Para **Casos Específicos**:
Escolha a linguagem baseada no ecossistema de bibliotecas necessárias e expertise da equipe.

---

**💡 Dica**: Comece sempre com **Lua** para entender os conceitos fundamentais do Kong, depois migre para outras linguagens conforme a necessidade específica do seu caso de uso.

---

*Documento criado como parte do Workshop "Desbloqueando Kong Gateway"*  
*Repositório: [github.com/marcopollivier/desbloqueando-kong](https://github.com/marcopollivier/desbloqueando-kong)*
