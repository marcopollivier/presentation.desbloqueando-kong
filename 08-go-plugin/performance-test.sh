#!/bin/bash

# Kong Go Plugin Performance Test Script
# This script performs various load tests to compare Go plugin performance

set -e

BASE_URL="http://localhost:8000"
ADMIN_URL="http://localhost:8001"
HOST_HEADER="api.local"

echo "🚀 Kong Go Plugin Performance Test Suite"
echo "========================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if services are running
check_services() {
    echo -e "${BLUE}📋 Checking services...${NC}"
    
    if ! curl -s "$ADMIN_URL/status" > /dev/null; then
        echo -e "${RED}❌ Kong Admin API not accessible${NC}"
        exit 1
    fi
    
    if ! curl -s "$BASE_URL" -H "Host: $HOST_HEADER" > /dev/null; then
        echo -e "${RED}❌ Kong Proxy not accessible${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Services are running${NC}"
}

# Warm up test
warmup_test() {
    echo -e "${BLUE}🔥 Warming up...${NC}"
    
    for i in {1..10}; do
        curl -s "$BASE_URL/api/anything" \
            -H "Host: $HOST_HEADER" \
            -H "Content-Type: application/json" \
            -d '{"warmup": true}' > /dev/null
    done
    
    echo -e "${GREEN}✅ Warm-up completed${NC}"
}

# Basic functionality test
functionality_test() {
    echo -e "${BLUE}🧪 Testing basic functionality...${NC}"
    
    # Test 1: Valid request
    echo "Test 1: Valid request"
    response=$(curl -s -w "%{http_code}" "$BASE_URL/api/anything" \
        -H "Host: $HOST_HEADER" \
        -H "Content-Type: application/json" \
        -d '{"test": "valid"}')
    
    if [[ "$response" =~ 200$ ]]; then
        echo -e "${GREEN}✅ Valid request passed${NC}"
    else
        echo -e "${RED}❌ Valid request failed: $response${NC}"
    fi
    
    # Test 2: Missing header
    echo "Test 2: Missing required header"
    response=$(curl -s -w "%{http_code}" -o /dev/null "$BASE_URL/api/anything" \
        -H "Host: $HOST_HEADER" \
        -d '{"test": "no header"}')
    
    if [[ "$response" =~ 400$ ]]; then
        echo -e "${GREEN}✅ Missing header validation passed${NC}"
    else
        echo -e "${RED}❌ Missing header validation failed: $response${NC}"
    fi
    
    # Test 3: Invalid method
    echo "Test 3: Invalid HTTP method"
    response=$(curl -s -w "%{http_code}" -o /dev/null -X DELETE "$BASE_URL/api/anything" \
        -H "Host: $HOST_HEADER" \
        -H "Content-Type: application/json")
    
    if [[ "$response" =~ 405$ ]]; then
        echo -e "${GREEN}✅ Method validation passed${NC}"
    else
        echo -e "${RED}❌ Method validation failed: $response${NC}"
    fi
}

# Load test using curl
curl_load_test() {
    echo -e "${BLUE}🔄 Running curl load test (100 requests)...${NC}"
    
    start_time=$(date +%s.%N)
    success_count=0
    
    for i in {1..100}; do
        response=$(curl -s -w "%{http_code}" -o /dev/null "$BASE_URL/api/anything" \
            -H "Host: $HOST_HEADER" \
            -H "Content-Type: application/json" \
            -d "{\"request_id\": $i}")
        
        if [[ "$response" =~ 200$ ]]; then
            ((success_count++))
        fi
        
        if (( i % 20 == 0 )); then
            echo "  Progress: $i/100 requests"
        fi
    done
    
    end_time=$(date +%s.%N)
    duration=$(echo "$end_time - $start_time" | bc)
    rps=$(echo "scale=2; 100 / $duration" | bc)
    
    echo -e "${GREEN}📊 Curl Load Test Results:${NC}"
    echo "  Duration: ${duration}s"
    echo "  Success: $success_count/100"
    echo "  RPS: $rps"
}

# Rate limiting test
rate_limit_test() {
    echo -e "${BLUE}⏱️  Testing rate limiting (105 requests)...${NC}"
    
    success_count=0
    rate_limited_count=0
    
    for i in {1..105}; do
        response=$(curl -s -w "%{http_code}" -o /dev/null "$BASE_URL/api/anything" \
            -H "Host: $HOST_HEADER" \
            -H "Content-Type: application/json" \
            -d "{\"rate_test\": $i}")
        
        if [[ "$response" =~ 200$ ]]; then
            ((success_count++))
        elif [[ "$response" =~ 429$ ]]; then
            ((rate_limited_count++))
        fi
        
        # Small delay to avoid overwhelming
        sleep 0.01
    done
    
    echo -e "${GREEN}📊 Rate Limiting Test Results:${NC}"
    echo "  Successful requests: $success_count"
    echo "  Rate limited requests: $rate_limited_count"
    
    if (( rate_limited_count > 0 )); then
        echo -e "${GREEN}✅ Rate limiting working correctly${NC}"
    else
        echo -e "${YELLOW}⚠️  Rate limiting might not be working${NC}"
    fi
}

# Concurrent test using background processes
concurrent_test() {
    echo -e "${BLUE}🔀 Running concurrent test (50 parallel requests)...${NC}"
    
    start_time=$(date +%s.%N)
    temp_file="/tmp/go_plugin_concurrent_test"
    
    # Clear temp file
    > "$temp_file"
    
    # Run 50 concurrent requests
    for i in {1..50}; do
        (
            response=$(curl -s -w "%{http_code}" -o /dev/null "$BASE_URL/api/anything" \
                -H "Host: $HOST_HEADER" \
                -H "Content-Type: application/json" \
                -d "{\"concurrent_id\": $i}")
            echo "$response" >> "$temp_file"
        ) &
    done
    
    # Wait for all background jobs
    wait
    
    end_time=$(date +%s.%N)
    duration=$(echo "$end_time - $start_time" | bc)
    
    # Count results
    success_count=$(grep -c "200" "$temp_file" || echo "0")
    total_requests=$(wc -l < "$temp_file")
    
    echo -e "${GREEN}📊 Concurrent Test Results:${NC}"
    echo "  Duration: ${duration}s"
    echo "  Total requests: $total_requests"
    echo "  Successful: $success_count"
    echo "  Success rate: $(echo "scale=2; $success_count * 100 / $total_requests" | bc)%"
    
    # Cleanup
    rm -f "$temp_file"
}

# Memory usage check
memory_check() {
    echo -e "${BLUE}💾 Checking memory usage...${NC}"
    
    # Get memory stats for Go plugin container
    go_plugin_mem=$(docker stats go-plugin --no-stream --format "{{.MemUsage}}" 2>/dev/null || echo "N/A")
    kong_mem=$(docker stats kong-gateway --no-stream --format "{{.MemUsage}}" 2>/dev/null || echo "N/A")
    redis_mem=$(docker stats kong-redis --no-stream --format "{{.MemUsage}}" 2>/dev/null || echo "N/A")
    
    echo -e "${GREEN}📊 Memory Usage:${NC}"
    echo "  Go Plugin: $go_plugin_mem"
    echo "  Kong Gateway: $kong_mem"
    echo "  Redis: $redis_mem"
}

# Plugin metrics
plugin_metrics() {
    echo -e "${BLUE}📈 Gathering plugin metrics...${NC}"
    
    # Get plugin info from Kong Admin API
    plugin_info=$(curl -s "$ADMIN_URL/services/test-service/plugins" | jq -r '.data[0] | {id: .id, name: .name, enabled: .enabled}' 2>/dev/null || echo "Unable to get plugin info")
    
    echo -e "${GREEN}📊 Plugin Information:${NC}"
    echo "  $plugin_info"
    
    # Check Redis keys (rate limiting data)
    redis_keys=$(docker exec kong-redis redis-cli KEYS "rate_limit:*" 2>/dev/null | wc -l || echo "0")
    echo "  Redis rate limit keys: $redis_keys"
}

# Cleanup function
cleanup() {
    echo -e "${BLUE}🧹 Cleaning up...${NC}"
    
    # Clear Redis rate limiting data
    docker exec kong-redis redis-cli FLUSHDB > /dev/null 2>&1 || echo "Could not clear Redis"
    
    echo -e "${GREEN}✅ Cleanup completed${NC}"
}

# Main execution
main() {
    echo "Starting performance tests..."
    echo "Timestamp: $(date)"
    echo ""
    
    check_services
    echo ""
    
    warmup_test
    echo ""
    
    functionality_test
    echo ""
    
    curl_load_test
    echo ""
    
    rate_limit_test
    echo ""
    
    concurrent_test
    echo ""
    
    memory_check
    echo ""
    
    plugin_metrics
    echo ""
    
    cleanup
    
    echo -e "${GREEN}🎉 All tests completed!${NC}"
    echo "========================================"
}

# Check if required tools are available
command -v curl >/dev/null 2>&1 || { echo -e "${RED}❌ curl is required but not installed${NC}" >&2; exit 1; }
command -v bc >/dev/null 2>&1 || { echo -e "${RED}❌ bc is required but not installed${NC}" >&2; exit 1; }
command -v docker >/dev/null 2>&1 || { echo -e "${RED}❌ docker is required but not installed${NC}" >&2; exit 1; }

# Run main function
main
