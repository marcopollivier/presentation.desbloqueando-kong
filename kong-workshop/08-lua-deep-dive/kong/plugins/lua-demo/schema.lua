-- schema.lua - Configuração do plugin
local schema = {
  name = "lua-demo",
  fields = {
    { config = {
        type = "record",
        fields = {
          { demo_mode = {
              type = "string",
              default = "performance",
              one_of = { "performance", "coroutine", "ffi", "metatable" },
              description = "Type of Lua demonstration to run"
            }
          },
          
          { iterations = {
              type = "number",
              default = 1000,
              gt = 0,
              description = "Number of iterations for performance tests"
            }
          },
          
          { enable_detailed_logs = {
              type = "boolean", 
              default = false,
              description = "Enable detailed logging of Lua operations"
            }
          },
          
          { add_performance_headers = {
              type = "boolean",
              default = true,
              description = "Add performance metrics to response headers"
            }
          }
        }
      }
    }
  }
}

return schema
