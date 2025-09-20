#!/bin/bash

echo "⚡ Kong Lua Performance Benchmark"
echo "================================="

# Verificar se Kong está rodando
if ! curl -s http://localhost:8001/status > /dev/null; then
    echo "❌ Kong não está rodando. Execute: docker-compose up -d"
    exit 1
fi

echo "📊 Executando testes de performance..."
echo ""

# Função para executar benchmark
run_benchmark() {
    local name="$1"
    local url="$2"
    local requests="$3"
    
    echo "🔥 Teste: $name"
    echo "URL: $url"
    echo "Requests: $requests"
    
    # Usar curl para medir performance
    local start_time=$(date +%s.%N)
    
    for i in $(seq 1 $requests); do
        curl -s -o /dev/null "$url"
    done
    
    local end_time=$(date +%s.%N)
    local duration=$(echo "$end_time - $start_time" | bc)
    local rps=$(echo "scale=2; $requests / $duration" | bc)
    
    echo "⏱️  Total time: ${duration}s"
    echo "🚀 Requests/sec: $rps"
    echo ""
}

# 1. Teste sem plugin (baseline)
echo "1️⃣  BASELINE - SEM PLUGIN"
echo "========================="
run_benchmark "Kong puro" "http://localhost:8000/no-plugin/posts/1" 50

# 2. Teste com plugin Lua - Performance mode
echo "2️⃣  PLUGIN LUA - PERFORMANCE MODE" 
echo "================================="
run_benchmark "Performance demo" "http://localhost:8000/demo/posts/1" 50

# 3. Teste com plugin Lua - Corrotine mode
echo "3️⃣  PLUGIN LUA - CORROTINE MODE"
echo "==============================="
run_benchmark "Corrotine demo" "http://localhost:8000/demo/posts/1?demo=corrotine" 30

# 4. Teste com plugin Lua - FFI mode
echo "4️⃣  PLUGIN LUA - FFI MODE"
echo "========================="
run_benchmark "FFI demo" "http://localhost:8000/demo/posts/1?demo=ffi" 50

# 5. Análise detalhada de uma request
echo "5️⃣  ANÁLISE DETALHADA"
echo "=====================" 
echo "Headers de performance da última request:"
curl -I http://localhost:8000/demo/posts/1 2>/dev/null | grep -E "(X-Lua-Demo|X-Kong)"

echo ""
echo "Response completa com timing:"
curl -w "
📊 Métricas da Request:
   DNS lookup:    %{time_namelookup}s
   Connect:       %{time_connect}s  
   App connect:   %{time_appconnect}s
   Pre-transfer:  %{time_pretransfer}s
   Start transfer:%{time_starttransfer}s
   Total:         %{time_total}s
   
🔍 Detalhes:
   HTTP Status:   %{http_code}
   Size download: %{size_download} bytes
   Speed download:%{speed_download} bytes/sec
" -s -o /dev/null http://localhost:8000/demo/posts/1

echo ""
echo "✅ Benchmark completo!"
echo ""
echo "💡 Conclusões esperadas:"
echo "   • Kong puro: ~0.1-0.2ms overhead"
echo "   • Plugin Lua: ~0.3-0.5ms overhead adicional"  
echo "   • Overhead total: <1ms para operações complexas"
echo "   • Performance excelente mesmo com lógica customizada"
echo ""
echo "🏆 Comparação com outras linguagens (estimativa):"
echo "   • Lua/LuaJIT:  1.0x (baseline - mais rápido)"
echo "   • Rust:        1.8x (rápido, mas precisa compilar)"
echo "   • Go:          2.5x (rápido, mas overhead de runtime)"
echo "   • Node.js:     5x (V8 JIT, mas single-thread)"
echo "   • Python:      12x (interpretado + GIL)"
echo "   • Java:        8x (JVM overhead + startup)"
