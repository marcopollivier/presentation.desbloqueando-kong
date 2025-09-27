package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"strconv"
	"sync/atomic"
	"time"

	"github.com/gorilla/mux"
)

// Estruturas de dados similar ao JSONPlaceholder
type Post struct {
	ID         int                    `json:"id"`
	Title      string                 `json:"title"`
	Body       string                 `json:"body"`
	UserID     int                    `json:"userId"`
	ServerInfo map[string]interface{} `json:"server_info"`
}

type User struct {
	ID         int                    `json:"id"`
	Name       string                 `json:"name"`
	Email      string                 `json:"email"`
	Username   string                 `json:"username"`
	ServerInfo map[string]interface{} `json:"server_info"`
}

type HealthStatus struct {
	Status    string    `json:"status"`
	Server    string    `json:"server"`
	Timestamp time.Time `json:"timestamp"`
	Uptime    string    `json:"uptime"`
}

var (
	serverName     string
	port           string
	startTime      = time.Now()
	requestCount   int64
	totalLatencyMs int64
)

// Mock data
var posts = []Post{
	{ID: 1, Title: "Post 1", Body: "This is post 1", UserID: 1},
	{ID: 2, Title: "Post 2", Body: "This is post 2", UserID: 1},
	{ID: 3, Title: "Post 3", Body: "This is post 3", UserID: 2},
}

var users = []User{
	{ID: 1, Name: "John Doe", Email: "john@example.com", Username: "johndoe"},
	{ID: 2, Name: "Jane Smith", Email: "jane@example.com", Username: "janesmith"},
}

func addServerInfo(data interface{}) interface{} {
	serverInfo := map[string]interface{}{
		"server":    serverName,
		"port":      port,
		"timestamp": time.Now(),
		"language":  "Go",
		"uptime":    time.Since(startTime).String(),
	}

	switch v := data.(type) {
	case Post:
		v.ServerInfo = serverInfo
		return v
	case User:
		v.ServerInfo = serverInfo
		return v
	case []Post:
		for i := range v {
			v[i].ServerInfo = serverInfo
		}
		return v
	case []User:
		for i := range v {
			v[i].ServerInfo = serverInfo
		}
		return v
	default:
		return data
	}
}

// CORS e logging middleware
func corsAndLoggingMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Headers CORS
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

		// Medir tempo de resposta
		startTime := time.Now()

		// Incrementar contador de requests (exceto OPTIONS e metrics)
		if r.Method != "OPTIONS" && r.URL.Path != "/metrics" {
			atomic.AddInt64(&requestCount, 1)
		}

		// Log da requisição
		log.Printf("[%s] %s %s from %s", serverName, r.Method, r.URL.Path, r.RemoteAddr)

		// Handle preflight requests
		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}

		next.ServeHTTP(w, r)

		// Calcular e adicionar latência (exceto OPTIONS e metrics)
		if r.Method != "OPTIONS" && r.URL.Path != "/metrics" {
			latencyMs := time.Since(startTime).Milliseconds()
			atomic.AddInt64(&totalLatencyMs, latencyMs)
		}
	})
}

// Health check endpoint
func healthHandler(w http.ResponseWriter, r *http.Request) {
	uptime := time.Since(startTime)
	health := HealthStatus{
		Status:    "healthy",
		Server:    serverName,
		Timestamp: time.Now(),
		Uptime:    uptime.String(),
	}

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(health)
}

// Posts endpoints
func getPostsHandler(w http.ResponseWriter, r *http.Request) {
	postsWithServerInfo := addServerInfo(posts)
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(postsWithServerInfo)
}

func getPostHandler(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	postID, err := strconv.Atoi(vars["id"])
	if err != nil {
		http.Error(w, "Invalid post ID", http.StatusBadRequest)
		return
	}

	for _, post := range posts {
		if post.ID == postID {
			postWithServerInfo := addServerInfo(post)
			w.WriteHeader(http.StatusOK)
			json.NewEncoder(w).Encode(postWithServerInfo)
			return
		}
	}

	http.Error(w, "Post not found", http.StatusNotFound)
}

// Users endpoints
func getUsersHandler(w http.ResponseWriter, r *http.Request) {
	usersWithServerInfo := addServerInfo(users)
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(usersWithServerInfo)
}

func getUserHandler(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	userID, err := strconv.Atoi(vars["id"])
	if err != nil {
		http.Error(w, "Invalid user ID", http.StatusBadRequest)
		return
	}

	for _, user := range users {
		if user.ID == userID {
			userWithServerInfo := addServerInfo(user)
			w.WriteHeader(http.StatusOK)
			json.NewEncoder(w).Encode(userWithServerInfo)
			return
		}
	}

	http.Error(w, "User not found", http.StatusNotFound)
}

// Performance endpoint para benchmarks
func performanceHandler(w http.ResponseWriter, r *http.Request) {
	startReq := time.Now()

	// Simular algum processamento
	sum := 0
	for i := 0; i < 10000; i++ {
		sum += i
	}

	response := map[string]interface{}{
		"server":          serverName,
		"language":        "Go",
		"processing_time": time.Since(startReq).Nanoseconds(),
		"result":          sum,
		"goroutines":      "available",
		"timestamp":       time.Now(),
	}

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(response)
}

// Metrics endpoint - formato Prometheus
func metricsHandler(w http.ResponseWriter, r *http.Request) {
	uptime := time.Since(startTime).Seconds()
	requests := atomic.LoadInt64(&requestCount)
	totalLatency := atomic.LoadInt64(&totalLatencyMs)

	// Calcular latência média
	var avgLatency float64
	if requests > 0 {
		avgLatency = float64(totalLatency) / float64(requests)
	}

	w.Header().Set("Content-Type", "text/plain")
	w.WriteHeader(http.StatusOK)

	// Formato Prometheus
	w.Write([]byte("# HELP go_mock_requests_total Total number of requests handled by Go mock service\n"))
	w.Write([]byte("# TYPE go_mock_requests_total counter\n"))
	w.Write([]byte(fmt.Sprintf("go_mock_requests_total{server=\"%s\",language=\"go\"} %d\n", serverName, requests)))

	w.Write([]byte("# HELP go_mock_uptime_seconds Uptime of the Go mock service in seconds\n"))
	w.Write([]byte("# TYPE go_mock_uptime_seconds gauge\n"))
	w.Write([]byte(fmt.Sprintf("go_mock_uptime_seconds{server=\"%s\",language=\"go\"} %.2f\n", serverName, uptime)))

	w.Write([]byte("# HELP go_mock_response_time_ms Average response time in milliseconds\n"))
	w.Write([]byte("# TYPE go_mock_response_time_ms gauge\n"))
	w.Write([]byte(fmt.Sprintf("go_mock_response_time_ms{server=\"%s\",language=\"go\"} %.2f\n", serverName, avgLatency)))
}

func main() {
	// Configurar variáveis de ambiente
	serverName = os.Getenv("SERVER_NAME")
	if serverName == "" {
		serverName = "go-mock-api"
	}

	port = os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	// Criar router
	r := mux.NewRouter()

	// Aplicar middleware
	r.Use(corsAndLoggingMiddleware)

	// Rotas
	r.HandleFunc("/health", healthHandler).Methods("GET")
	r.HandleFunc("/metrics", metricsHandler).Methods("GET")
	r.HandleFunc("/performance", performanceHandler).Methods("GET")
	r.HandleFunc("/posts", getPostsHandler).Methods("GET")
	r.HandleFunc("/posts/{id:[0-9]+}", getPostHandler).Methods("GET")
	r.HandleFunc("/users", getUsersHandler).Methods("GET")
	r.HandleFunc("/users/{id:[0-9]+}", getUserHandler).Methods("GET")

	// Servidor HTTP
	server := &http.Server{
		Addr:         ":" + port,
		Handler:      r,
		ReadTimeout:  10 * time.Second,
		WriteTimeout: 10 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	log.Printf("🚀 Go Mock API Server \"%s\" starting on port %s", serverName, port)
	log.Printf("Health check: http://localhost:%s/health", port)
	log.Printf("Performance test: http://localhost:%s/performance", port)

	// Graceful shutdown
	go func() {
		if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("Server failed to start: %v", err)
		}
	}()

	log.Printf("✅ Go Mock API Server \"%s\" is running on port %s", serverName, port)

	// Manter o servidor rodando
	select {}
}
