-- kong_simulation.lua - Simula como Kong executa plugins

-- Plugin Auth JWT
local JWTPlugin = {}
JWTPlugin.__index = JWTPlugin

function JWTPlugin.new(config)
    local self = setmetatable({}, JWTPlugin)
    self.name = "jwt-auth"
    self.secret = config.secret or "default-secret"
    self.algorithm = config.algorithm or "HS256"
    return self
end

function JWTPlugin:execute(request, context)
    local auth_header = request.headers["Authorization"]
    
    if not auth_header then
        return false, 401, "Token JWT obrigatório"
    end
    
    local token = auth_header:match("Bearer%s+(.+)")
    
    if not token then
        return false, 401, "Formato de token inválido"
    end
    
    -- Simulação de validação JWT
    if token == "valid-jwt-token" then
        context.user = {
            id = "user123",
            role = "admin",
            permissions = {"read", "write"}
        }
        return true
    else
        return false, 403, "Token inválido"
    end
end

-- Plugin Rate Limiting
local RateLimitPlugin = {}
RateLimitPlugin.__index = RateLimitPlugin

function RateLimitPlugin.new(config)
    local self = setmetatable({}, RateLimitPlugin)
    self.name = "rate-limiting"
    self.requests_per_minute = config.requests_per_minute or 60
    self.storage = {}
    return self
end

function RateLimitPlugin:execute(request, context)
    local client_ip = request.client_ip or "127.0.0.1"
    local current_minute = math.floor(os.time() / 60)
    local key = client_ip .. ":" .. current_minute
    
    local count = self.storage[key] or 0
    count = count + 1
    self.storage[key] = count
    
    if count > self.requests_per_minute then
        return false, 429, "Rate limit excedido"
    end
    
    -- Adicionar headers de rate limit
    request.headers["X-RateLimit-Limit"] = tostring(self.requests_per_minute)
    request.headers["X-RateLimit-Remaining"] = tostring(self.requests_per_minute - count)
    
    return true
end

-- Plugin Response Transformer
local TransformPlugin = {}
TransformPlugin.__index = TransformPlugin

function TransformPlugin.new(config)
    local self = setmetatable({}, TransformPlugin)
    self.name = "response-transformer"
    self.add_headers = config.add_headers or {}
    self.remove_headers = config.remove_headers or {}
    return self
end

function TransformPlugin:execute(request, context)
    -- Este plugin processaria a response, simulando aqui
    context.response_transforms = {
        add_headers = self.add_headers,
        remove_headers = self.remove_headers
    }
    return true
end

-- Kong Plugin Manager Simulation
local PluginManager = {}
PluginManager.__index = PluginManager

function PluginManager.new()
    local self = setmetatable({}, PluginManager)
    self.plugins = {}
    return self
end

function PluginManager:add_plugin(plugin)
    table.insert(self.plugins, plugin)
end

function PluginManager:execute_plugins(request)
    local context = {}
    
    for _, plugin in ipairs(self.plugins) do
        local success, status_or_nil, message = plugin:execute(request, context)
        
        if not success then
            return {
                success = false,
                status = status_or_nil or 500,
                message = message or "Plugin error",
                plugin = plugin.name
            }
        end
    end
    
    return {
        success = true,
        status = 200,
        message = "All plugins executed successfully",
        context = context
    }
end

-- Simulação de execução Kong
function simulate_kong_request()
    print("🔧 Simulando execução Kong Gateway")
    print("=" .. string.rep("=", 49))
    
    -- Criar plugins com configurações
    local jwt_plugin = JWTPlugin.new({
        secret = "my-jwt-secret",
        algorithm = "HS256"
    })
    
    local rate_limit_plugin = RateLimitPlugin.new({
        requests_per_minute = 100
    })
    
    local transform_plugin = TransformPlugin.new({
        add_headers = {
            ["X-Powered-By"] = "Kong-Lua-Simulation",
            ["X-Response-Time"] = "50ms"
        },
        remove_headers = {"Server"}
    })
    
    -- Criar plugin manager
    local manager = PluginManager.new()
    manager:add_plugin(jwt_plugin)
    manager:add_plugin(rate_limit_plugin)
    manager:add_plugin(transform_plugin)
    
    -- Request de teste
    local request = {
        method = "GET",
        path = "/api/users",
        headers = {
            ["Authorization"] = "Bearer valid-jwt-token",
            ["User-Agent"] = "Kong-Test/1.0"
        },
        client_ip = "192.168.1.100"
    }
    
    print("\n📥 Request recebido:")
    print("   Method: " .. request.method)
    print("   Path: " .. request.path)
    print("   Client IP: " .. request.client_ip)
    
    -- Executar pipeline de plugins
    local result = manager:execute_plugins(request)
    
    print("\n🎯 Resultado da execução:")
    print("   Success: " .. tostring(result.success))
    print("   Status: " .. result.status)
    print("   Message: " .. result.message)
    
    if result.context and result.context.user then
        print("\n👤 Usuário autenticado:")
        print("   ID: " .. result.context.user.id)
        print("   Role: " .. result.context.user.role)
    end
    
    return result
end

-- Executar simulação
return simulate_kong_request()
