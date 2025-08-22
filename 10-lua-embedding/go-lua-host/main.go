package main

import (
	"fmt"
	"log"
	"os"
	"strings"
	"time"

	lua "github.com/yuin/gopher-lua"
)

func main() {
	if len(os.Args) < 2 {
		printUsage()
		return
	}

	example := os.Args[1]

	switch example {
	case "basic":
		runBasicExample()
	case "config":
		runConfigExample()
	case "plugins":
		runPluginExample()
	case "sandbox":
		runSandboxExample()
	case "benchmark":
		runBenchmarkExample()
	default:
		fmt.Printf("Exemplo desconhecido: %s\n", example)
		printUsage()
	}
}

func printUsage() {
	fmt.Println("🚀 Exemplos Lua Embedding em Go")
	fmt.Println("")
	fmt.Println("Uso: go run main.go <exemplo>")
	fmt.Println("")
	fmt.Println("Exemplos disponíveis:")
	fmt.Println("  basic     - Hello World básico")
	fmt.Println("  config    - Configuração dinâmica")
	fmt.Println("  plugins   - Sistema de plugins")
	fmt.Println("  sandbox   - Sandbox e segurança")
	fmt.Println("  benchmark - Performance benchmark")
}

// Exemplo 1: Hello World Básico
func runBasicExample() {
	fmt.Println("🔹 Exemplo 1: Hello World Básico")
	fmt.Println(strings.Repeat("=", 50))

	L := lua.NewState()
	defer L.Close()

	// Script Lua simples
	luaScript := `
		print("🌟 Hello from Lua inside Go!")
		
		function greet(name)
			return "Olá, " .. name .. "! Lua está rodando dentro de Go 🚀"
		end
		
		-- Chamando a função
		local message = greet("Kong Developer")
		print(message)
		
		-- Retornando valores para Go
		return "Lua execution completed successfully!"
	`

	// Executar script Lua
	if err := L.DoString(luaScript); err != nil {
		log.Fatal("Erro executando Lua:", err)
	}

	// Pegar valor de retorno
	ret := L.Get(-1)
	if str, ok := ret.(lua.LString); ok {
		fmt.Printf("\n✅ Retorno do Lua: %s\n", string(str))
	}

	fmt.Println("\n💡 Este exemplo mostra:")
	fmt.Println("   - Lua executando dentro de Go")
	fmt.Println("   - Troca de dados entre Go e Lua")
	fmt.Println("   - Simplicidade da integração")
}

// Exemplo 2: Configuração Dinâmica
func runConfigExample() {
	fmt.Println("🔹 Exemplo 2: Configuração Dinâmica")
	fmt.Println(strings.Repeat("=", 50))

	L := lua.NewState()
	defer L.Close()

	// Configuração em Lua (similar ao Kong)
	configScript := `
		-- Configuração do servidor
		config = {
			server = {
				host = "localhost",
				port = 8080,
				timeout = 30
			},
			database = {
				driver = "postgres",
				host = "db.example.com",
				port = 5432,
				name = "kong_db"
			},
			features = {
				rate_limiting = true,
				auth = true,
				logging = "debug"
			}
		}
		
		-- Função para validar configuração
		function validate_config()
			if not config.server.host then
				error("Host do servidor é obrigatório")
			end
			
			if config.server.port < 1 or config.server.port > 65535 then
				error("Porta inválida")
			end
			
			return true
		end
		
		-- Função para aplicar configurações
		function apply_config()
			validate_config()
			print("✅ Configuração validada com sucesso!")
			
			return {
				server_url = config.server.host .. ":" .. config.server.port,
				db_url = config.database.driver .. "://" .. config.database.host,
				features_count = 3
			}
		end
		
		return apply_config()
	`

	// Executar configuração
	if err := L.DoString(configScript); err != nil {
		log.Fatal("Erro na configuração:", err)
	}

	// Pegar configuração processada
	result := L.Get(-1)
	if table, ok := result.(*lua.LTable); ok {
		fmt.Println("\n📋 Configuração processada:")
		table.ForEach(func(key, value lua.LValue) {
			fmt.Printf("   %s: %s\n", key.String(), value.String())
		})
	}

	fmt.Println("\n💡 Este exemplo mostra:")
	fmt.Println("   - Configuração flexível em Lua")
	fmt.Println("   - Validação de dados")
	fmt.Println("   - Processamento de configurações complexas")
	fmt.Println("   - Como Kong usa Lua para configurações")
}

// Exemplo 3: Sistema de Plugins
func runPluginExample() {
	fmt.Println("🔹 Exemplo 3: Sistema de Plugins")
	fmt.Println(strings.Repeat("=", 50))

	L := lua.NewState()
	defer L.Close()

	// Registrar função Go para Lua
	L.SetGlobal("go_log", L.NewFunction(goLogFunction))
	L.SetGlobal("go_get_time", L.NewFunction(goGetTimeFunction))

	// Plugin de autenticação
	authPluginScript := `
		-- Plugin de Autenticação
		AuthPlugin = {}
		AuthPlugin.__index = AuthPlugin
		
		function AuthPlugin.new()
			local self = setmetatable({}, AuthPlugin)
			self.name = "auth-plugin"
			return self
		end
		
		function AuthPlugin:execute(request)
			go_log("🔐 Executando plugin de autenticação")
			
			-- Simular validação de token
			if request.headers["Authorization"] then
				go_log("✅ Token encontrado, usuário autenticado")
				request.user = "authenticated_user"
				return true
			else
				go_log("❌ Token não encontrado, acesso negado")
				return false, "Token de autorização obrigatório"
			end
		end
		
		-- Plugin de Rate Limiting
		RateLimitPlugin = {}
		RateLimitPlugin.__index = RateLimitPlugin
		
		function RateLimitPlugin.new(max_requests)
			local self = setmetatable({}, RateLimitPlugin)
			self.name = "rate-limit-plugin"
			self.max_requests = max_requests or 100
			self.requests = {}
			return self
		end
		
		function RateLimitPlugin:execute(request)
			go_log("⏱️  Executando plugin de rate limiting")
			
			local client_ip = request.client_ip or "unknown"
			local current_time = go_get_time()
			
			-- Inicializar contador para o IP
			if not self.requests[client_ip] then
				self.requests[client_ip] = {}
			end
			
			-- Contar requests na última hora (simulado)
			local count = #self.requests[client_ip] + 1
			table.insert(self.requests[client_ip], current_time)
			
			if count > self.max_requests then
				go_log("🚫 Rate limit excedido para " .. client_ip)
				return false, "Rate limit excedido"
			else
				go_log("✅ Request permitido (" .. count .. "/" .. self.max_requests .. ")")
				return true
			end
		end
		
		-- Sistema de execução de plugins
		function execute_plugins(request, plugins)
			go_log("🔧 Executando " .. #plugins .. " plugins")
			
			for i, plugin in ipairs(plugins) do
				local success, error_msg = plugin:execute(request)
				
				if not success then
					return false, "Plugin " .. plugin.name .. " falhou: " .. (error_msg or "erro desconhecido")
				end
			end
			
			return true, "Todos os plugins executados com sucesso"
		end
		
		-- Criar plugins
		local auth_plugin = AuthPlugin.new()
		local rate_limit_plugin = RateLimitPlugin.new(5)
		
		-- Request simulado
		local request = {
			path = "/api/users",
			method = "GET",
			headers = {
				["Authorization"] = "Bearer token123",
				["User-Agent"] = "Go-Lua-Example/1.0"
			},
			client_ip = "192.168.1.100"
		}
		
		-- Executar pipeline de plugins
		local plugins = {auth_plugin, rate_limit_plugin}
		local success, message = execute_plugins(request, plugins)
		
		go_log("🏁 Resultado final: " .. (success and "SUCESSO" or "FALHOU"))
		go_log("📝 Mensagem: " .. message)
		
		return success
	`

	// Executar sistema de plugins
	if err := L.DoString(authPluginScript); err != nil {
		log.Fatal("Erro no sistema de plugins:", err)
	}

	// Verificar resultado
	result := L.Get(-1)
	fmt.Printf("\n🎯 Resultado da execução: %v\n", result)

	fmt.Println("\n💡 Este exemplo mostra:")
	fmt.Println("   - Sistema de plugins modular")
	fmt.Println("   - Comunicação Go ↔ Lua")
	fmt.Println("   - Pipeline de processamento")
	fmt.Println("   - Como Kong executa plugins")
}

// Exemplo 4: Sandbox e Segurança
func runSandboxExample() {
	fmt.Println("🔹 Exemplo 4: Sandbox e Segurança")
	fmt.Println(strings.Repeat("=", 50))

	// Lua state com sandbox
	L := lua.NewState()
	defer L.Close()

	// Remover funções perigosas (sandbox)
	L.SetGlobal("os", lua.LNil)     // Sem acesso ao sistema
	L.SetGlobal("io", lua.LNil)     // Sem I/O
	L.SetGlobal("dofile", lua.LNil) // Sem carregamento de arquivos
	L.SetGlobal("loadfile", lua.LNil)
	L.SetGlobal("require", lua.LNil) // Sem require

	// Adicionar funções seguras customizadas
	L.SetGlobal("safe_print", L.NewFunction(safePrintFunction))

	fmt.Println("🔒 Testando sandbox seguro...")

	// Script malicioso (que deve falhar)
	maliciousScript := `
		safe_print("Tentando acessar sistema operacional...")
		
		-- Estas operações devem falhar
		if os then
			safe_print("PERIGO: Acesso ao OS disponível!")
			-- os.execute("rm -rf /") -- Isso seria perigoso!
		else
			safe_print("✅ OS bloqueado com sucesso")
		end
		
		if io then
			safe_print("PERIGO: Acesso ao IO disponível!")
		else
			safe_print("✅ IO bloqueado com sucesso")
		end
		
		if dofile then
			safe_print("PERIGO: dofile disponível!")
		else
			safe_print("✅ dofile bloqueado com sucesso")
		end
		
		-- Operações permitidas
		local x = 10
		local y = 20
		local result = x + y
		
		safe_print("✅ Operações matemáticas permitidas: " .. result)
		
		-- Função customizada permitida
		function safe_operation(a, b)
			return a * b + 100
		end
		
		local calc_result = safe_operation(5, 3)
		safe_print("✅ Funções customizadas permitidas: " .. calc_result)
		
		return "Sandbox test completed"
	`

	// Executar no sandbox
	if err := L.DoString(maliciousScript); err != nil {
		log.Fatal("Erro no sandbox:", err)
	}

	result := L.Get(-1)
	fmt.Printf("\n🛡️  Resultado do sandbox: %v\n", result)

	fmt.Println("\n💡 Este exemplo mostra:")
	fmt.Println("   - Como criar um ambiente seguro")
	fmt.Println("   - Bloqueio de funções perigosas")
	fmt.Println("   - Controle granular de acesso")
	fmt.Println("   - Segurança por design")
}

// Exemplo 5: Performance Benchmark
func runBenchmarkExample() {
	fmt.Println("🔹 Exemplo 5: Performance Benchmark")
	fmt.Println(strings.Repeat("=", 50))

	// Benchmark: Execução pura Go
	fmt.Println("⚡ Benchmark 1: Cálculo em Go puro")
	startTime := time.Now()

	sum := 0
	for i := 0; i < 1000000; i++ {
		sum += i * 2
	}

	goDuration := time.Since(startTime)
	fmt.Printf("   Resultado Go: %d (tempo: %v)\n", sum, goDuration)

	// Benchmark: Execução via Lua
	fmt.Println("\n⚡ Benchmark 2: Cálculo via Lua")
	L := lua.NewState()
	defer L.Close()

	luaBenchScript := `
		local sum = 0
		for i = 0, 999999 do
			sum = sum + (i * 2)
		end
		return sum
	`

	startTime = time.Now()

	if err := L.DoString(luaBenchScript); err != nil {
		log.Fatal("Erro no benchmark Lua:", err)
	}

	luaDuration := time.Since(startTime)
	result := L.Get(-1)
	fmt.Printf("   Resultado Lua: %v (tempo: %v)\n", result, luaDuration)

	// Benchmark: Overhead de comunicação
	fmt.Println("\n⚡ Benchmark 3: Overhead de comunicação")

	// Registrar função Go
	L.SetGlobal("go_multiply", L.NewFunction(goMultiplyFunction))

	commScript := `
		local result = 0
		for i = 1, 10000 do
			result = result + go_multiply(i, 2)
		end
		return result
	`

	startTime = time.Now()

	if err := L.DoString(commScript); err != nil {
		log.Fatal("Erro no benchmark comunicação:", err)
	}

	commDuration := time.Since(startTime)
	result = L.Get(-1)
	fmt.Printf("   Resultado Comunicação: %v (tempo: %v)\n", result, commDuration)

	// Comparação de performance
	fmt.Println("\n📊 Comparação de Performance:")
	fmt.Printf("   Go puro:      %v (baseline)\n", goDuration)
	fmt.Printf("   Lua:          %v (%.1fx mais lento)\n", luaDuration, float64(luaDuration)/float64(goDuration))
	fmt.Printf("   Comunicação:  %v (%.1fx mais lento)\n", commDuration, float64(commDuration)/float64(goDuration))

	fmt.Println("\n💡 Este exemplo mostra:")
	fmt.Println("   - Performance relativa Lua vs Go")
	fmt.Println("   - Overhead de comunicação")
	fmt.Println("   - Quando usar cada abordagem")
	fmt.Println("   - Trade-offs de flexibilidade vs performance")
}

// Funções auxiliares para Lua

func goLogFunction(L *lua.LState) int {
	message := L.ToString(1)
	fmt.Printf("   [LUA LOG] %s\n", message)
	return 0
}

func goGetTimeFunction(L *lua.LState) int {
	L.Push(lua.LNumber(time.Now().Unix()))
	return 1
}

func safePrintFunction(L *lua.LState) int {
	message := L.ToString(1)
	fmt.Printf("   [SANDBOX] %s\n", message)
	return 0
}

func goMultiplyFunction(L *lua.LState) int {
	a := L.ToNumber(1)
	b := L.ToNumber(2)
	result := a * b
	L.Push(lua.LNumber(result))
	return 1
}
