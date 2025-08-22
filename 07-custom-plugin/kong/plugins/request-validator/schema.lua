-- schema.lua
local typedefs = require "kong.db.schema.typedefs"

local schema = {
  name = "request-validator",
  fields = {
    -- Configurações específicas do plugin
    { config = {
        type = "record",
        fields = {
          -- Headers obrigatórios
          { required_headers = {
              type = "array",
              elements = { type = "string" },
              default = { "X-User-ID" },
              description = "List of required headers that must be present in requests"
            }
          },
          
          -- Tamanho máximo do payload
          { max_payload_size = {
              type = "number",
              default = 1048576, -- 1MB
              gt = 0,
              description = "Maximum allowed payload size in bytes"
            }
          },
          
          -- Rate limiting por minuto
          { rate_limit_per_minute = {
              type = "number", 
              default = 5,
              ge = 0,
              description = "Number of requests allowed per minute per user (0 = unlimited)"
            }
          },
          
          -- Headers adicionais para log
          { log_request_headers = {
              type = "array",
              elements = { type = "string" },
              default = { "User-Agent", "X-Forwarded-For", "X-Client-Version" },
              description = "Additional headers to include in logs"
            }
          },
          
          -- Habilitar/desabilitar validações específicas
          { enable_payload_validation = {
              type = "boolean",
              default = true,
              description = "Enable or disable payload size validation"
            }
          },
          
          { enable_rate_limiting = {
              type = "boolean", 
              default = true,
              description = "Enable or disable rate limiting"
            }
          },
          
          -- Método de rate limiting
          { rate_limit_by = {
              type = "string",
              default = "header",
              one_of = { "header", "ip", "consumer" },
              description = "Method for rate limiting: header (X-User-ID), ip, or consumer"
            }
          },
          
          -- Nome do header para rate limiting quando rate_limit_by = "header"
          { rate_limit_header = {
              type = "string",
              default = "X-User-ID", 
              description = "Header name to use for rate limiting when rate_limit_by=header"
            }
          }
        }
      }
    }
  }
}

return schema
