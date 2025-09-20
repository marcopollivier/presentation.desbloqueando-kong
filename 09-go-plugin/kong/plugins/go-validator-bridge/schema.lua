-- schema.lua
local typedefs = require "kong.db.schema.typedefs"

local schema = {
  name = "go-validator-bridge",
  fields = {
    { config = {
        type = "record",
        fields = {
          -- Configuração do serviço Go
          { go_service_host = {
              type = "string",
              default = "go-validator",
              description = "Hostname or IP of the Go validation service"
            }
          },
          
          { go_service_port = {
              type = "number",
              default = 8002,
              gt = 0,
              le = 65535,
              description = "Port of the Go validation service"
            }
          },
          
          -- Timeout para chamadas HTTP
          { timeout = {
              type = "number",
              default = 5000,
              gt = 0,
              description = "Timeout in milliseconds for Go service calls"
            }
          },
          
          -- Comportamento em caso de erro
          { fail_on_error = {
              type = "boolean",
              default = true,
              description = "Whether to fail the request if Go service is unavailable"
            }
          },
          
          -- Headers de debug
          { add_debug_headers = {
              type = "boolean",
              default = false,
              description = "Add debug headers from Go service response"
            }
          },
          
          -- Configurações específicas do validador Go
          { max_requests_per_minute = {
              type = "number",
              default = 100,
              ge = 0,
              description = "Maximum requests per minute per IP (0 = unlimited)"
            }
          },
          
          { required_headers = {
              type = "array",
              elements = { type = "string" },
              default = {},
              description = "List of required headers"
            }
          },
          
          { allowed_methods = {
              type = "array",
              elements = { type = "string" },
              default = { "GET", "POST", "PUT", "DELETE" },
              description = "List of allowed HTTP methods"
            }
          },
          
          { enable_debug_headers = {
              type = "boolean",
              default = true,
              description = "Enable debug headers in the Go service response"
            }
          }
        }
      }
    }
  }
}

return schema