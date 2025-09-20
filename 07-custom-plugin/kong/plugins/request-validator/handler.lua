-- handler.lua
local RequestValidator = {}

RequestValidator.PRIORITY = 1000 -- Define a prioridade do plugin
RequestValidator.VERSION = "1.0.0"

-- Cache para rate limiting local
local rate_limit_cache = {}

-- Função para limpar cache (garbage collection)
local function cleanup_rate_limit_cache()
  local current_time = ngx.time()
  for key, data in pairs(rate_limit_cache) do
    if current_time - data.window_start > 60 then
      rate_limit_cache[key] = nil
    end
  end
end

-- Função de rate limiting customizado por user-id
local function check_rate_limit(config, user_id)
  if not user_id or config.rate_limit_per_minute <= 0 then
    return false, 0
  end
  
  local current_time = os.time()
  local window_start = current_time - (current_time % 60) -- janela de 1 minuto
  local cache_key = user_id .. ":" .. window_start
  
  -- Limpar cache periodicamente
  if math.random(1, 100) == 1 then
    cleanup_rate_limit_cache()
  end
  
  local rate_data = rate_limit_cache[cache_key]
  if not rate_data then
    rate_data = {
      count = 0,
      window_start = window_start
    }
    rate_limit_cache[cache_key] = rate_data
  end
  
  rate_data.count = rate_data.count + 1
  
  return rate_data.count > config.rate_limit_per_minute, rate_data.count
end

-- Fase de access - executada antes do request chegar ao upstream
function RequestValidator:access(config)
  -- Marcar o tempo de início do request
  kong.ctx.shared.request_start_time = kong.table.new(0, 1)
  kong.ctx.shared.request_start_time = os.clock()
  
  local headers = kong.request.get_headers()
  local method = kong.request.get_method()
  
  kong.log.info("request-validator: Processing request - Method: " .. method)
  
  -- Validar headers obrigatórios
  for _, required_header in ipairs(config.required_headers) do
    if not headers[required_header] then
      kong.log.warn("request-validator: Missing required header: " .. required_header)
      return kong.response.exit(400, {
        error = "Missing required header: " .. required_header,
        code = "MISSING_HEADER"
      })
    end
  end
  
  -- Validar tamanho do payload para requests com body
  if method == "POST" or method == "PUT" or method == "PATCH" then
    local content_length = tonumber(headers["content-length"] or "0")
    if content_length > config.max_payload_size then
      kong.log.warn("request-validator: Payload too large: " .. content_length .. " bytes")
      return kong.response.exit(413, {
        error = "Payload too large. Maximum allowed: " .. config.max_payload_size .. " bytes",
        code = "PAYLOAD_TOO_LARGE"
      })
    end
  end
  
  -- Rate limiting customizado por user-id
  local user_id = headers["x-user-id"]
  if user_id and config.rate_limit_per_minute > 0 then
    local exceeded, current_count = check_rate_limit(config, user_id)
    if exceeded then
      kong.log.warn("request-validator: Rate limit exceeded for user: " .. user_id .. " (" .. current_count .. " requests)")
      return kong.response.exit(429, {
        error = "Rate limit exceeded for user: " .. user_id,
        code = "RATE_LIMIT_EXCEEDED",
        limit = config.rate_limit_per_minute,
        current = current_count
      })
    end
    
    -- Adicionar headers informativos
    kong.response.set_header("X-RateLimit-Limit", config.rate_limit_per_minute)
    kong.response.set_header("X-RateLimit-Remaining", config.rate_limit_per_minute - current_count)
    kong.response.set_header("X-RateLimit-User", user_id)
  end
  
  kong.log.info("request-validator: Request validation passed")
end

-- Fase de header_filter - executada ao processar headers da response
function RequestValidator:header_filter(config)
  -- Adicionar header indicando que o request foi processado pelo plugin
  kong.response.set_header("X-Validated-By", "request-validator-plugin")
  kong.response.set_header("X-Plugin-Version", RequestValidator.VERSION)
end

-- Fase de log - executada após enviar response para o client
function RequestValidator:log(config)
  local request_time = kong.ctx.shared.request_start_time or os.clock()
  local response_time = os.clock()
  local latency = math.floor((response_time - request_time) * 1000) -- em ms
  
  local user_id = kong.request.get_header("x-user-id") or "anonymous"
  local method = kong.request.get_method()
  local path = kong.request.get_path()
  local status = kong.response.get_status()
  
  kong.log.info("request-validator: Request completed", {
    user_id = user_id,
    method = method,
    path = path,
    status = status,
    latency_ms = latency,
    plugin_version = RequestValidator.VERSION
  })
end

return RequestValidator
