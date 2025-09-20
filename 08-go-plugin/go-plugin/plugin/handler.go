package plugin

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strings"
	"time"
)

// ValidateHandler processa requisições de validação
func (s *Server) ValidateHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	if r.Method != http.MethodPost {
		w.WriteHeader(http.StatusMethodNotAllowed)
		json.NewEncoder(w).Encode(ValidationResponse{
			Valid:      false,
			Error:      "Method not allowed",
			StatusCode: 405,
		})
		return
	}

	// Decodificar request
	var validationReq ValidationRequest
	if err := json.NewDecoder(r.Body).Decode(&validationReq); err != nil {
		log.Printf("Failed to decode validation request: %v", err)
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(ValidationResponse{
			Valid:      false,
			Error:      "Invalid request format",
			StatusCode: 400,
		})
		return
	}

	// Executar validações
	response := s.validateRequest(validationReq)

	// Retornar resposta
	if response.Valid {
		w.WriteHeader(http.StatusOK)
	} else {
		w.WriteHeader(http.StatusOK) // Sempre 200, o status real vai no body
	}

	json.NewEncoder(w).Encode(response)
}

// validateRequest executa todas as validações
func (s *Server) validateRequest(req ValidationRequest) ValidationResponse {
	// 1. Validar métodos permitidos
	if !contains(req.Config.AllowedMethods, req.Method) {
		return ValidationResponse{
			Valid:      false,
			Error:      "Method not allowed",
			Reason:     fmt.Sprintf("Method %s is not in allowed methods", req.Method),
			StatusCode: 405,
			Details: map[string]interface{}{
				"method":  req.Method,
				"allowed": req.Config.AllowedMethods,
			},
		}
	}

	// 2. Validar headers obrigatórios
	for _, requiredHeader := range req.Config.RequiredHeaders {
		if !hasHeader(req.Headers, requiredHeader) {
			return ValidationResponse{
				Valid:      false,
				Error:      "Missing required header",
				Reason:     fmt.Sprintf("Required header '%s' is missing", requiredHeader),
				StatusCode: 400,
				Details: map[string]interface{}{
					"missing_header":   requiredHeader,
					"required_headers": req.Config.RequiredHeaders,
				},
			}
		}
	}

	// 3. Rate limiting
	if req.Config.MaxRequestsPerMinute > 0 {
		if exceeded, details := s.checkRateLimit(req.ClientIP, req.Config.MaxRequestsPerMinute); exceeded {
			return ValidationResponse{
				Valid:      false,
				Error:      "Rate limit exceeded",
				Reason:     fmt.Sprintf("Too many requests from IP %s", req.ClientIP),
				StatusCode: 429,
				Details:    details,
			}
		}
	}

	// Se chegou até aqui, a validação passou
	debugInfo := map[string]interface{}{
		"validated_method": req.Method,
		"client_ip":        req.ClientIP,
		"path":             req.Path,
	}

	if req.Config.EnableDebugHeaders {
		debugInfo["timestamp"] = time.Now().Unix()
		debugInfo["validator"] = "go-service"
	}

	return ValidationResponse{
		Valid:     true,
		DebugInfo: debugInfo,
	}
}

// checkRateLimit verifica o rate limiting usando Redis
func (s *Server) checkRateLimit(clientIP string, maxRequests int) (bool, map[string]interface{}) {
	ctx := context.Background()
	key := fmt.Sprintf("rate_limit:%s", clientIP)

	// Obter contagem atual
	count, err := s.redisClient.Get(ctx, key).Int()
	if err != nil && err.Error() != "redis: nil" {
		log.Printf("Redis error: %v", err)
		// Em caso de erro no Redis, permitir a requisição
		return false, map[string]interface{}{
			"redis_error": err.Error(),
		}
	}

	// Verificar se excedeu o limite
	if count >= maxRequests {
		ttl, _ := s.redisClient.TTL(ctx, key).Result()
		return true, map[string]interface{}{
			"current_count": count,
			"max_requests":  maxRequests,
			"window":        "1 minute",
			"reset_in":      ttl.Seconds(),
		}
	}

	// Incrementar contador
	pipe := s.redisClient.TxPipeline()
	pipe.Incr(ctx, key)
	pipe.Expire(ctx, key, time.Minute)
	_, err = pipe.Exec(ctx)
	if err != nil {
		log.Printf("Failed to update rate limit counter: %v", err)
	}

	return false, map[string]interface{}{
		"current_count": count + 1,
		"max_requests":  maxRequests,
		"window":        "1 minute",
	}
}

// contains verifica se um slice contém um item específico
func contains(slice []string, item string) bool {
	for _, s := range slice {
		if strings.EqualFold(s, item) {
			return true
		}
	}
	return false
}

// hasHeader verifica se um header existe (case-insensitive)
func hasHeader(headers map[string]interface{}, headerName string) bool {
	for key, value := range headers {
		if strings.EqualFold(key, headerName) {
			// Verificar se o valor não está vazio
			if str, ok := value.(string); ok && str != "" {
				return true
			}
		}
	}
	return false
}
