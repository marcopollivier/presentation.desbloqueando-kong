package plugin

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"os"

	"github.com/go-redis/redis/v8"
)

// Config representa a configuração do validador
type ValidationConfig struct {
	MaxRequestsPerMinute int      `json:"max_requests_per_minute"`
	RequiredHeaders      []string `json:"required_headers"`
	AllowedMethods       []string `json:"allowed_methods"`
	EnableDebugHeaders   bool     `json:"enable_debug_headers"`
}

// ValidationRequest representa uma requisição de validação
type ValidationRequest struct {
	Method      string                 `json:"method"`
	Path        string                 `json:"path"`
	Headers     map[string]interface{} `json:"headers"`
	QueryParams map[string]interface{} `json:"query_params"`
	ClientIP    string                 `json:"client_ip"`
	Body        string                 `json:"body,omitempty"`
	Config      ValidationConfig       `json:"config"`
}

// ValidationResponse representa a resposta da validação
type ValidationResponse struct {
	Valid      bool                   `json:"valid"`
	Error      string                 `json:"error,omitempty"`
	Reason     string                 `json:"reason,omitempty"`
	StatusCode int                    `json:"status_code,omitempty"`
	Details    map[string]interface{} `json:"details,omitempty"`
	DebugInfo  map[string]interface{} `json:"debug_info,omitempty"`
}

// Server representa o servidor de validação
type Server struct {
	redisClient *redis.Client
}

// NewServer cria uma nova instância do servidor
func NewServer() *Server {
	redisHost := os.Getenv("REDIS_HOST")
	if redisHost == "" {
		redisHost = "redis"
	}

	redisPort := os.Getenv("REDIS_PORT")
	if redisPort == "" {
		redisPort = "6379"
	}

	rdb := redis.NewClient(&redis.Options{
		Addr: fmt.Sprintf("%s:%s", redisHost, redisPort),
		DB:   0,
	})

	return &Server{
		redisClient: rdb,
	}
}

// HealthHandler endpoint de health check
func (s *Server) HealthHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	// Testar conexão com Redis
	ctx := context.Background()
	_, err := s.redisClient.Ping(ctx).Result()
	if err != nil {
		w.WriteHeader(http.StatusServiceUnavailable)
		json.NewEncoder(w).Encode(map[string]interface{}{
			"status": "unhealthy",
			"redis":  "disconnected",
			"error":  err.Error(),
		})
		return
	}

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]interface{}{
		"status":  "healthy",
		"redis":   "connected",
		"version": "1.0.0",
	})
}

// StatusHandler endpoint de status
func (s *Server) StatusHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]interface{}{
		"service": "go-validator",
		"version": "1.0.0",
		"status":  "running",
	})
}
