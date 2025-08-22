package plugin

// Config represents the plugin configuration
type Config struct {
	MaxRequestsPerMinute int      `json:"max_requests_per_minute"`
	RequiredHeaders      []string `json:"required_headers"`
	AllowedMethods       []string `json:"allowed_methods"`
	EnableDebugHeaders   bool     `json:"enable_debug_headers"`
	RedisHost            string   `json:"redis_host,omitempty"`
	RedisPort            int      `json:"redis_port,omitempty"`
}

// New creates a new instance of the plugin configuration
func New() interface{} {
	return &Config{
		MaxRequestsPerMinute: 60,
		RequiredHeaders:      []string{},
		AllowedMethods:       []string{"GET", "POST", "PUT", "DELETE"},
		EnableDebugHeaders:   true,
		RedisHost:            "redis",
		RedisPort:            6379,
	}
}
