package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
	"strconv"
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
	serverName string
	port       string
	startTime  = time.Now()
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

// Middleware para CORS e logging
func corsAndLoggingMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// CORS headers
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
		w.Header().Set("Content-Type", "application/json")
		w.Header().Set("X-Server-Name", serverName)
		w.Header().Set("X-Language", "Go")

		// Log request
		log.Printf("[%s] %s %s - Server: %s", time.Now().Format("2006-01-02 15:04:05"), r.Method, r.URL.Path, serverName)

		// Handle preflight requests
		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}

		next.ServeHTTP(w, r)
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
