#!/usr/bin/env lua

print("🔥 Lua Básico - Demonstração")
print("============================")

-- 1. Sintaxe limpa e intuitiva
print("\n1. SINTAXE LIMPA")
local greeting = "Hello from Lua!"
local numbers = {1, 2, 3, 4, 5}

print("Greeting:", greeting)
print("Numbers:", table.concat(numbers, ", "))

-- 2. Funções são first-class citizens
print("\n2. FUNÇÕES AVANÇADAS")
local function map(tbl, func)
    local result = {}
    for i, v in ipairs(tbl) do
        result[i] = func(v)
    end
    return result
end

local squared = map(numbers, function(x) return x * x end)
print("Squared:", table.concat(squared, ", "))

-- 3. Tables são tudo (arrays, maps, objects)
print("\n3. TABLES VERSÁTEIS")
local user = {
    id = 123,
    name = "João",
    permissions = {"read", "write"},
    is_active = true,
    
    -- Métodos
    can_access = function(self, resource)
        for _, perm in ipairs(self.permissions) do
            if perm == resource then
                return true
            end
        end
        return false
    end
}

print("User:", user.name)
print("Can read?", user:can_access("read"))
print("Can admin?", user:can_access("admin"))

-- 4. Metatables (similar a operators overloading)
print("\n4. METATABLES")
local Vector = {}
Vector.__index = Vector

function Vector.new(x, y)
    return setmetatable({x = x or 0, y = y or 0}, Vector)
end

function Vector.__add(a, b)
    return Vector.new(a.x + b.x, a.y + b.y)
end

function Vector.__tostring(v)
    return string.format("Vector(%.2f, %.2f)", v.x, v.y)
end

local v1 = Vector.new(3, 4)
local v2 = Vector.new(1, 2)
local v3 = v1 + v2  -- Usa __add metamethod

print("v1:", tostring(v1))
print("v2:", tostring(v2))
print("v1 + v2:", tostring(v3))

-- 5. Closures e contexto
print("\n5. CLOSURES")
local function create_counter(initial)
    local count = initial or 0
    return function()
        count = count + 1
        return count
    end
end

local counter1 = create_counter(10)
local counter2 = create_counter(100)

print("Counter1:", counter1(), counter1(), counter1())
print("Counter2:", counter2(), counter2())

-- 6. Pattern matching (não regex!)
print("\n6. PATTERN MATCHING")
local text = "User ID: abc123, Score: 85.5"
local user_id = text:match("User ID: (%w+)")
local score = tonumber(text:match("Score: ([%d%.]+)"))

print("Extracted User ID:", user_id)
print("Extracted Score:", score)

-- 7. Iterators customizados
print("\n7. ITERATORS")
local function fibonacci(n)
    local function fib_iter(a, b, i)
        if i >= n then return nil end
        return i + 1, b, a + b
    end
    return fib_iter, 0, 1, 0
end

print("Fibonacci sequence (10 numbers):")
local fib_numbers = {}
for i, value in fibonacci(10) do
    table.insert(fib_numbers, value)
end
print(table.concat(fib_numbers, ", "))

-- 8. Error handling
print("\n8. ERROR HANDLING")
local function safe_divide(a, b)
    if b == 0 then
        error("Division by zero!")
    end
    return a / b
end

local success, result = pcall(safe_divide, 10, 2)
if success then
    print("10 / 2 =", result)
else
    print("Error:", result)
end

local success, result = pcall(safe_divide, 10, 0)
if success then
    print("10 / 0 =", result)
else
    print("Caught error:", result)
end

print("\n✅ Lua básico demonstrado!")
print("\n💡 Por que Lua é perfeito para Kong:")
print("   • Sintaxe simples e clara")
print("   • Performance nativa (LuaJIT)")
print("   • Flexibilidade total")
print("   • Footprint mínimo")
print("   • Integração perfeita com C/Nginx")
