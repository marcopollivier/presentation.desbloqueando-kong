-- plugin_template.lua - Template para plugins Kong-like

local PluginTemplate = {}
PluginTemplate.__index = PluginTemplate

-- Constructor
function PluginTemplate.new(config)
    local self = setmetatable({}, PluginTemplate)
    self.name = "template-plugin"
    self.version = "1.0.0"
    self.config = config or {}
    self.enabled = true
    return self
end

-- Método principal de execução
function PluginTemplate:execute(context)
    if not self.enabled then
        return true, "Plugin desabilitado"
    end
    
    -- Log da execução
    self:log("Executando plugin " .. self.name .. " v" .. self.version)
    
    -- Processar request
    if context.request then
        self:process_request(context.request)
    end
    
    -- Processar response
    if context.response then
        self:process_response(context.response)
    end
    
    return true, "Plugin executado com sucesso"
end

-- Processamento de request
function PluginTemplate:process_request(request)
    self:log("Processando request: " .. request.method .. " " .. request.path)
    
    -- Exemplo: adicionar header customizado
    request.headers = request.headers or {}
    request.headers["X-Plugin-Name"] = self.name
    request.headers["X-Plugin-Version"] = self.version
end

-- Processamento de response
function PluginTemplate:process_response(response)
    self:log("Processando response com status: " .. (response.status or "unknown"))
    
    -- Exemplo: adicionar header de response
    response.headers = response.headers or {}
    response.headers["X-Processed-By"] = self.name
end

-- Método de logging
function PluginTemplate:log(message)
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    print("[" .. timestamp .. "] [" .. self.name .. "] " .. message)
end

-- Método para habilitar/desabilitar
function PluginTemplate:toggle(enabled)
    self.enabled = enabled
    self:log("Plugin " .. (enabled and "habilitado" or "desabilitado"))
end

-- Método para atualizar configuração
function PluginTemplate:update_config(new_config)
    self.config = new_config or {}
    self:log("Configuração atualizada")
end

return PluginTemplate
