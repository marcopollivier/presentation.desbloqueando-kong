package main

import (
	"fmt"

	"github.com/Kong/go-pdk"
	"github.com/Kong/go-pdk/server"
)

// Config representa a configuração do plugin
type Config struct {
	RequiredHeaders []string `json:"required_headers"`
	AllowedMethods  []string `json:"allowed_methods"`
	Message         string   `json:"message"`
}

// Plugin representa nosso plugin simples
type Plugin struct{}

// New cria uma nova instância do plugin
func New() interface{} {
	return &Plugin{}
}

// Access é executado na fase de acesso da requisição
func (p *Plugin) Access(kong *pdk.PDK) {
	// Headers obrigatórios fixos (simplificando)
	requiredHeaders := []string{"Content-Type", "X-Client-ID"}
	allowedMethods := []string{"GET", "POST", "PUT", "DELETE"}

	// Obter método da requisição
	method, err := kong.Request.GetMethod()
	if err != nil {
		kong.Log.Err("Erro ao obter método da requisição:", err.Error())
		return
	}

	// Validar método permitido
	methodAllowed := false
	for _, allowedMethod := range allowedMethods {
		if method == allowedMethod {
			methodAllowed = true
			break
		}
	}

	if !methodAllowed {
		kong.Log.Info("Método não permitido:", method)
		errorMsg := fmt.Sprintf(`{"error": "Method %s not allowed", "allowed_methods": %v}`, method, allowedMethods)
		kong.Response.Exit(405, []byte(errorMsg), map[string][]string{
			"Content-Type": {"application/json"},
		})
		return
	}

	// Validar headers obrigatórios
	for _, requiredHeader := range requiredHeaders {
		headerValue, err := kong.Request.GetHeader(requiredHeader)
		if err != nil || headerValue == "" {
			kong.Log.Info("Header obrigatório ausente:", requiredHeader)
			errorMsg := fmt.Sprintf(`{"error": "Required header '%s' is missing"}`, requiredHeader)
			kong.Response.Exit(400, []byte(errorMsg), map[string][]string{
				"Content-Type": {"application/json"},
			})
			return
		}
	}

	// Adicionar header de debug se passou na validação
	kong.Response.SetHeader("X-Validated-By", "kong-go-plugin")
	kong.Response.SetHeader("X-Plugin-Message", "Request validado pelo plugin Go!")

	kong.Log.Info("Requisição validada com sucesso")
}

func main() {
	server.StartServer(New, "1.0.0", 100)
}
