-- handler.lua
local http = require "resty.http"
local cjson = require "cjson"

local GoValidatorBridge = {}

GoValidatorBridge.PRIORITY = 1000
GoValidatorBridge.VERSION = "1.0.0"

-- Função para comunicar com o serviço Go
local function call_go_validator(config, request_data)
  local httpc = http.new()
  httpc:set_timeout(config.timeout or 5000) -- 5 segundos
  
  local go_service_url = string.format("http://%s:%d/validate", 
                                      config.go_service_host, 
                                      config.go_service_port)
  
  local body = cjson.encode(request_data)
  
  local res, err = httpc:request_uri(go_service_url, {
    method = "POST",
    body = body,
    headers = {
      ["Content-Type"] = "application/json",
    }
  })
  
  httpc:close()
  
  if not res then
    kong.log.err("go-validator-bridge: Failed to call Go service: " .. (err or "unknown error"))
    return nil, "Service unavailable"
  end
  
  if res.status ~= 200 then
    kong.log.warn("go-validator-bridge: Go service returned status: " .. res.status)
    local response_data = {}
    if res.body then
      local ok, decoded = pcall(cjson.decode, res.body)
      if ok then
        response_data = decoded
      end
    end
    return nil, response_data.error or "Validation failed"
  end
  
  local ok, response_data = pcall(cjson.decode, res.body)
  if not ok then
    kong.log.err("go-validator-bridge: Failed to decode response from Go service")
    return nil, "Invalid response format"
  end
  
  return response_data, nil
end

-- Fase de access
function GoValidatorBridge:access(config)
  -- Obter dados do request
  local headers = kong.request.get_headers()
  local method = kong.request.get_method()
  local path = kong.request.get_path()
  local query_params = kong.request.get_query()
  
  -- Obter IP do cliente
  local client_ip = kong.client.get_forwarded_ip()
  
  -- Obter body para métodos POST/PUT/PATCH (se houver)
  local body = nil
  if method == "POST" or method == "PUT" or method == "PATCH" then
    local raw_body = kong.request.get_raw_body()
    if raw_body then
      body = raw_body
    end
  end
  
  -- Preparar dados para enviar ao serviço Go
  local request_data = {
    method = method,
    path = path,
    headers = headers,
    query_params = query_params,
    client_ip = client_ip,
    body = body,
    config = config
  }
  
  kong.log.info("go-validator-bridge: Validating request with Go service")
  
  -- Chamar o serviço Go
  local validation_result, err = call_go_validator(config, request_data)
  
  if err then
    kong.log.warn("go-validator-bridge: Validation failed: " .. err)
    if config.fail_on_error then
      return kong.response.exit(500, {
        error = "Validation service error",
        message = err
      })
    else
      -- Se configurado para não falhar, apenas log e continua
      kong.log.warn("go-validator-bridge: Continuing despite validation error")
      return
    end
  end
  
  if not validation_result.valid then
    kong.log.info("go-validator-bridge: Request rejected by Go validator: " .. (validation_result.reason or "unknown"))
    return kong.response.exit(validation_result.status_code or 400, {
      error = validation_result.error or "Request validation failed",
      reason = validation_result.reason,
      details = validation_result.details
    })
  end
  
  -- Adicionar headers de debug se habilitado
  if config.add_debug_headers and validation_result.debug_info then
    for header_name, header_value in pairs(validation_result.debug_info) do
      kong.service.request.set_header("X-Go-Validator-" .. header_name, tostring(header_value))
    end
  end
  
  kong.log.info("go-validator-bridge: Request validated successfully")
end

-- Fase de header_filter
function GoValidatorBridge:header_filter(config)
  -- Adicionar header indicando que passou pela validação Go
  kong.response.set_header("X-Validated-By", "go-validator-bridge")
  kong.response.set_header("X-Bridge-Version", GoValidatorBridge.VERSION)
end

-- Fase de log
function GoValidatorBridge:log(config)
  local status = kong.response.get_status()
  local user_agent = kong.request.get_header("user-agent") or "unknown"
  local client_ip = kong.client.get_forwarded_ip()
  
  kong.log.info("go-validator-bridge: Request completed", {
    status = status,
    client_ip = client_ip,
    user_agent = user_agent,
    plugin_version = GoValidatorBridge.VERSION
  })
end

return GoValidatorBridge