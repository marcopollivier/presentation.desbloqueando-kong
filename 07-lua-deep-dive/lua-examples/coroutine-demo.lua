#!/usr/bin/env lua

print("🔄 Coroutines Demo - Concorrência Elegante")
print("==========================================")

-- Coroutines são uma das features mais poderosas do Lua
-- No contexto do Kong/OpenResty, permitem operações não-bloqueantes

print("\n1. COROUTINES BÁSICAS")
print("====================")

-- Criar uma corrotina simples
local function worker_task(name, steps)
    for i = 1, steps do
        print(string.format("Worker %s: Step %d", name, i))
        coroutine.yield(i) -- Pausa e retorna controle
    end
    return "Worker " .. name .. " completed!"
end

-- Criar corrotinas
local worker1 = coroutine.create(function() 
    return worker_task("A", 3) 
end)

local worker2 = coroutine.create(function() 
    return worker_task("B", 4) 
end)

-- Executar intercaladamente (simula non-blocking)
print("Executing workers intercaladamente:")
while coroutine.status(worker1) ~= "dead" or coroutine.status(worker2) ~= "dead" do
    -- Execute worker1
    if coroutine.status(worker1) ~= "dead" then
        local ok, result = coroutine.resume(worker1)
        if not ok and coroutine.status(worker1) == "dead" then
            print("Worker A result:", result)
        end
    end
    
    -- Execute worker2  
    if coroutine.status(worker2) ~= "dead" then
        local ok, result = coroutine.resume(worker2)
        if not ok and coroutine.status(worker2) == "dead" then
            print("Worker B result:", result)
        end
    end
end

print("\n2. SIMULATING ASYNC I/O (Kong style)")
print("=====================================")

-- Simular operações assíncronas típicas no Kong
local function simulate_database_call(query, delay)
    print(string.format("🔍 Executing query: %s", query))
    
    -- Em Kong real, isso seria uma operação não-bloqueante
    -- ngx.sleep() ou cosocket operation
    local start_time = os.clock()
    while os.clock() - start_time < (delay or 0.001) do
        -- Simulate work
    end
    
    coroutine.yield("Database operation in progress...")
    
    return {
        rows = math.random(1, 10),
        query = query,
        duration_ms = (delay or 0.001) * 1000
    }
end

local function simulate_http_call(url, delay)
    print(string.format("🌐 HTTP request to: %s", url))
    
    local start_time = os.clock()
    while os.clock() - start_time < (delay or 0.001) do
        -- Simulate network latency
    end
    
    coroutine.yield("HTTP request in progress...")
    
    return {
        status = 200,
        body = '{"success": true}',
        url = url,
        duration_ms = (delay or 0.001) * 1000
    }
end

-- Plugin que faz múltiplas operações assíncronas
local function kong_plugin_simulation(user_id)
    print(string.format("\n🎯 Processing request for user: %s", user_id))
    
    -- Operação 1: Verificar usuário no banco
    local db_co = coroutine.create(function()
        return simulate_database_call("SELECT * FROM users WHERE id = " .. user_id, 0.002)
    end)
    
    -- Operação 2: Verificar rate limit em cache externo  
    local cache_co = coroutine.create(function()
        return simulate_http_call("http://redis:6379/get/rate_limit_" .. user_id, 0.001)
    end)
    
    -- Operação 3: Log de auditoria
    local log_co = coroutine.create(function()
        return simulate_http_call("http://log-service:8080/audit", 0.001)
    end)
    
    local results = {}
    local pending = {db_co, cache_co, log_co}
    local names = {"database", "cache", "logging"}
    
    -- Event loop simulation (isso seria feito pelo OpenResty)
    while #pending > 0 do
        for i = #pending, 1, -1 do
            local co = pending[i]
            local ok, result = coroutine.resume(co)
            
            if coroutine.status(co) == "dead" then
                results[names[i]] = result
                print(string.format("✅ %s completed", names[i]))
                table.remove(pending, i)
                table.remove(names, i)
            else
                print(string.format("⏳ %s: %s", names[i], result))
            end
        end
        
        -- Pequena pausa para simular event loop
        os.execute("sleep 0.001")
    end
    
    return results
end

-- Executar simulação
local plugin_results = kong_plugin_simulation("user123")

print("\n📊 Results:")
for operation, result in pairs(plugin_results) do
    if type(result) == "table" then
        print(string.format("• %s: %s (%.1fms)", 
            operation, 
            result.status or result.rows or "success",
            result.duration_ms))
    else
        print(string.format("• %s: %s", operation, tostring(result)))
    end
end

print("\n3. PRODUCER/CONSUMER PATTERN")
print("============================")

-- Simular buffer de requests
local request_buffer = {}

local function request_producer(count)
    for i = 1, count do
        local request = {
            id = "req_" .. i,
            method = (i % 2 == 0) and "GET" or "POST",
            path = "/api/endpoint_" .. i,
            timestamp = os.time()
        }
        table.insert(request_buffer, request)
        print(string.format("📥 Produced request: %s %s", request.method, request.path))
        coroutine.yield(request)
    end
    return "Producer finished"
end

local function request_consumer(name)
    local processed = 0
    while true do
        if #request_buffer > 0 then
            local request = table.remove(request_buffer, 1)
            processed = processed + 1
            print(string.format("📤 Consumer %s processed: %s", name, request.id))
            coroutine.yield(processed)
        else
            coroutine.yield("waiting")
        end
    end
end

-- Executar producer/consumer
local producer = coroutine.create(function() return request_producer(5) end)
local consumer1 = coroutine.create(function() return request_consumer("Worker-1") end)
local consumer2 = coroutine.create(function() return request_consumer("Worker-2") end)

print("Starting producer/consumer simulation:")
for step = 1, 10 do
    -- Producer step
    if coroutine.status(producer) ~= "dead" then
        coroutine.resume(producer)
    end
    
    -- Consumer steps
    coroutine.resume(consumer1)
    coroutine.resume(consumer2)
    
    if #request_buffer == 0 and coroutine.status(producer) == "dead" then
        break
    end
end

print("\n✨ VANTAGENS DAS CORROTINAS NO KONG:")
print("====================================")
print("• 🚀 Concorrência sem threads (mais leve)")
print("• 🔄 Non-blocking I/O nativo")
print("• 🎯 Controle fino do flow")
print("• 💾 Baixo overhead de memória")
print("• 🔧 Integração perfeita com Nginx event loop")

print("\n🏗️ NO KONG/OPENRESTY:")
print("======================")
print("• ngx.thread.spawn() - criar corrotinas")
print("• ngx.thread.wait() - aguardar múltiplas")
print("• cosocket - sockets não-bloqueantes")  
print("• ngx.timer - tarefas agendadas")
print("• Tudo roda no mesmo thread, sem locks!")

print("\n💡 Por isso é perfeito para API Gateway:")
print("   ✓ Milhares de requests simultâneos")
print("   ✓ I/O bound operations (database, HTTP)")
print("   ✓ Zero overhead de context switching")
print("   ✓ Escalabilidade linear")
