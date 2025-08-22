-- rate_limiter.lua - Implementação de rate limiting

local RateLimiter = {}
RateLimiter.__index = RateLimiter

function RateLimiter.new(max_requests, time_window)
    local self = setmetatable({}, RateLimiter)
    self.max_requests = max_requests or 100
    self.time_window = time_window or 60  -- segundos
    self.requests = {}  -- { client_id: { timestamp1, timestamp2, ... } }
    return self
end

function RateLimiter:check_limit(client_id)
    local current_time = os.time()
    local client_requests = self.requests[client_id] or {}
    
    -- Limpar requests antigas
    local valid_requests = {}
    for _, timestamp in ipairs(client_requests) do
        if current_time - timestamp < self.time_window then
            table.insert(valid_requests, timestamp)
        end
    end
    
    -- Atualizar lista de requests
    self.requests[client_id] = valid_requests
    
    -- Verificar se excedeu o limite
    if #valid_requests >= self.max_requests then
        return false, {
            allowed = false,
            limit = self.max_requests,
            remaining = 0,
            reset_time = current_time + self.time_window,
            message = "Rate limit excedido"
        }
    end
    
    -- Adicionar request atual
    table.insert(self.requests[client_id], current_time)
    
    return true, {
        allowed = true,
        limit = self.max_requests,
        remaining = self.max_requests - #valid_requests - 1,
        reset_time = current_time + self.time_window,
        message = "Request permitido"
    }
end

function RateLimiter:get_stats(client_id)
    local current_time = os.time()
    local client_requests = self.requests[client_id] or {}
    
    local valid_count = 0
    for _, timestamp in ipairs(client_requests) do
        if current_time - timestamp < self.time_window then
            valid_count = valid_count + 1
        end
    end
    
    return {
        client_id = client_id,
        current_requests = valid_count,
        max_requests = self.max_requests,
        time_window = self.time_window,
        remaining = math.max(0, self.max_requests - valid_count)
    }
end

function RateLimiter:reset(client_id)
    if client_id then
        self.requests[client_id] = {}
    else
        self.requests = {}
    end
end

return RateLimiter
