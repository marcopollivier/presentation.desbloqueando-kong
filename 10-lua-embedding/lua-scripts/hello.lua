-- hello.lua - Script básico de exemplo

print("🌟 Hello from external Lua file!")

function greet_user(name, role)
    return "Olá, " .. name .. "! Você é um " .. (role or "usuário") .. " usando Lua 🚀"
end

-- Configurações locais
local config = {
    app_name = "Kong Workshop Demo",
    version = "1.0.0",
    debug = true
}

function get_config()
    return config
end

-- Retornar uma função para o host
return {
    greet = greet_user,
    config = get_config()
}
