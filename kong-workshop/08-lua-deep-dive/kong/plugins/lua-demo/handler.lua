-- handler.lua - Plugin de demonstração das capacidades do Lua
local LuaDemo = {}

LuaDemo.PRIORITY = 1000
LuaDemo.VERSION = "1.0.0"

-- FFI para demonstrar integração com C
local ffi = require("ffi")
local ok_ffi, _ = pcall(function() 
    ffi.cdef[[
        typedef struct {
            long tv_sec;
            long tv_usec;  
        } timeval;
        
        int gettimeofday(timeval *tv, void *tz);
    ]]
end)

-- Metatable para demonstrar extensibilidade
local RequestMetrics = {}
RequestMetrics.__index = RequestMetrics

function RequestMetrics.new()
    return setmetatable({
        start_time = 0,
        operations = {},
        memory_usage = 0
    }, RequestMetrics)
end

function RequestMetrics:start_timer()
    if ok_ffi then
        local tv = ffi.new("timeval")
        ffi.C.gettimeofday(tv, nil)
        self.start_time = tv.tv_sec + tv.tv_usec / 1000000
    else
        self.start_time = ngx.now()
    end
end

function RequestMetrics:add_operation(name, duration)
    table.insert(self.operations, {
        name = name,
        duration = duration,
        timestamp = ngx.now()
    })
end

function RequestMetrics:get_total_time()
    local current_time = ok_ffi and (function()
        local tv = ffi.new("timeval")
        ffi.C.gettimeofday(tv, nil)
        return tv.tv_sec + tv.tv_usec / 1000000
    end)() or ngx.now()
    
    return current_time - self.start_time
end

-- Demonstração de performance
local function performance_demo(config)
    local start_time = ngx.now()
    
    -- String operations
    local results = {}
    for i = 1, config.iterations do
        local key = "user_" .. i
        local value = "data_" .. math.random(1000, 9999)
        results[key] = value
    end
    
    -- Table operations
    local sum = 0
    for i = 1, config.iterations do
        sum = sum + i
    end
    
    -- Pattern matching
    local test_string = "Request: GET /api/users/123?format=json HTTP/1.1"
    local method, path, query = test_string:match("Request: (%w+) ([^%?]+)%?(.+) HTTP")
    
    local end_time = ngx.now()
    return {
        duration = (end_time - start_time) * 1000, -- ms
        operations = config.iterations,
        ops_per_sec = math.floor(config.iterations / (end_time - start_time)),
        parsed = { method = method, path = path, query = query }
    }
end

-- Demonstração de corrotinas  
local function coroutine_demo(config)
    local start_time = ngx.now()
    local results = {}
    
    -- Simular operações assíncronas
    local function async_operation(name, delay_ms)
        return coroutine.create(function()
            local op_start = ngx.now()
            -- Simular delay (em ambiente real seria ngx.sleep ou cosocket)
            local delay_sec = delay_ms / 1000
            local target = ngx.now() + delay_sec
            while ngx.now() < target do
                -- Busy wait para simulação
            end
            coroutine.yield({
                name = name,
                duration = (ngx.now() - op_start) * 1000,
                status = "completed"
            })
        end)
    end
    
    -- Criar múltiplas operações
    local operations = {
        async_operation("database_query", 2),
        async_operation("cache_lookup", 1),
        async_operation("external_api", 3)
    }
    
    -- Executar concorrentemente
    local completed = {}
    while #completed < #operations do
        for i, co in ipairs(operations) do
            if coroutine.status(co) ~= "dead" then
                local ok, result = coroutine.resume(co)
                if result and not completed[i] then
                    completed[i] = result
                    table.insert(results, result)
                end
            end
        end
    end
    
    local end_time = ngx.now()
    return {
        duration = (end_time - start_time) * 1000,
        operations = results,
        total_ops = #results
    }
end

-- Demonstração de FFI
local function ffi_demo(config)
    if not ok_ffi then
        return {error = "FFI not available"}
    end
    
    local start_time = ngx.now()
    local results = {}
    
    -- Usar FFI para operações de alta performance
    for i = 1, math.min(config.iterations, 1000) do
        local tv = ffi.new("timeval")
        ffi.C.gettimeofday(tv, nil)
        local timestamp = tv.tv_sec + tv.tv_usec / 1000000
        table.insert(results, timestamp)
    end
    
    local end_time = ngx.now()
    return {
        duration = (end_time - start_time) * 1000,
        samples = #results,
        first_timestamp = results[1],
        last_timestamp = results[#results]
    }
end

-- Demonstração de metatables
local function metatable_demo(config)
    local start_time = ngx.now()
    
    -- Criar objeto com metatable customizado
    local RequestCounter = {}
    RequestCounter.__index = RequestCounter
    RequestCounter.__tostring = function(self)
        return string.format("RequestCounter(total=%d, rate=%.2f/sec)", 
            self.total, self.rate or 0)
    end
    
    function RequestCounter.new()
        return setmetatable({
            total = 0,
            start_time = ngx.now(),
            rate = 0
        }, RequestCounter)
    end
    
    function RequestCounter:increment()
        self.total = self.total + 1
        local elapsed = ngx.now() - self.start_time
        if elapsed > 0 then
            self.rate = self.total / elapsed
        end
    end
    
    -- Usar o objeto
    local counter = RequestCounter.new()
    for i = 1, config.iterations do
        counter:increment()
    end
    
    local end_time = ngx.now()
    return {
        duration = (end_time - start_time) * 1000,
        counter_info = tostring(counter),
        final_rate = counter.rate
    }
end

function LuaDemo:access(config)
    local metrics = RequestMetrics.new()
    metrics:start_timer()
    
    -- Adicionar contexto para outras fases
    kong.ctx.shared.lua_demo_metrics = metrics
    kong.ctx.shared.lua_demo_config = config
    
    local demo_mode = kong.request.get_header("X-Demo") or config.demo_mode
    local demo_result
    
    kong.log.info("lua-demo: Starting " .. demo_mode .. " demonstration")
    
    -- Executar demonstração baseada no modo
    if demo_mode == "performance" then
        demo_result = performance_demo(config)
    elseif demo_mode == "coroutine" then
        demo_result = coroutine_demo(config)
    elseif demo_mode == "ffi" then
        demo_result = ffi_demo(config)
    elseif demo_mode == "metatable" then
        demo_result = metatable_demo(config)
    else
        demo_result = {error = "Unknown demo mode: " .. demo_mode}
    end
    
    metrics:add_operation(demo_mode, demo_result.duration or 0)
    kong.ctx.shared.lua_demo_result = demo_result
    
    if config.enable_detailed_logs then
        kong.log.info("lua-demo: " .. demo_mode .. " result", demo_result)
    end
end

function LuaDemo:header_filter(config)
    local metrics = kong.ctx.shared.lua_demo_metrics
    local demo_result = kong.ctx.shared.lua_demo_result
    
    if not metrics or not demo_result then
        return
    end
    
    if config.add_performance_headers then
        kong.response.set_header("X-Lua-Demo-Mode", 
            kong.request.get_header("X-Demo") or config.demo_mode)
        kong.response.set_header("X-Lua-Demo-Duration", 
            string.format("%.2fms", demo_result.duration or 0))
        kong.response.set_header("X-Lua-Demo-Version", LuaDemo.VERSION)
        
        if demo_result.ops_per_sec then
            kong.response.set_header("X-Lua-Demo-OPS", tostring(demo_result.ops_per_sec))
        end
        
        if demo_result.operations then
            kong.response.set_header("X-Lua-Demo-Operations", tostring(demo_result.operations))
        end
    end
end

function LuaDemo:log(config)
    local metrics = kong.ctx.shared.lua_demo_metrics
    local demo_result = kong.ctx.shared.lua_demo_result
    
    if not metrics or not demo_result then
        return
    end
    
    local total_time = metrics:get_total_time() * 1000 -- ms
    local demo_mode = kong.request.get_header("X-Demo") or config.demo_mode
    
    kong.log.info("lua-demo: Request completed", {
        demo_mode = demo_mode,
        plugin_duration = demo_result.duration,
        total_request_time = total_time,
        overhead_percent = (demo_result.duration / total_time) * 100,
        operations_count = demo_result.operations or demo_result.samples or 0,
        plugin_version = LuaDemo.VERSION
    })
end

return LuaDemo
