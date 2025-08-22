package plugin

import (
	"context"
	"fmt"
	"strings"
	"time"

	"github.com/Kong/go-pdk"
	"github.com/go-redis/redis/v8"
)

var (
	Version  = "1.0.0"
	Priority = 1000
)

// Access is called for every request that enters Kong
func (conf Config) Access(kong *pdk.PDK) {
	// Get request method
	method, err := kong.Request.GetMethod()
	if err != nil {
		kong.Log.Err("Failed to get request method: " + err.Error())
		return
	}

	// Validate allowed methods
	if !contains(conf.AllowedMethods, method) {
		kong.Log.Info(fmt.Sprintf("Method %s not allowed", method))
		kong.Response.Exit(405, map[string]interface{}{
			"error":   "Method not allowed",
			"method":  method,
			"allowed": conf.AllowedMethods,
		}, nil)
		return
	}

	// Validate required headers
	for _, headerName := range conf.RequiredHeaders {
		headerValue, err := kong.Request.GetHeader(headerName)
		if err != nil || headerValue == "" {
			kong.Log.Info(fmt.Sprintf("Missing required header: %s", headerName))
			kong.Response.Exit(400, map[string]interface{}{
				"error":  "Missing required header",
				"header": headerName,
			}, nil)
			return
		}
	}

	// Rate limiting check
	clientIP, err := kong.Client.GetIp()
	if err != nil {
		kong.Log.Err("Failed to get client IP: " + err.Error())
		clientIP = "unknown"
	}

	if !conf.checkRateLimit(kong, clientIP) {
		kong.Log.Info(fmt.Sprintf("Rate limit exceeded for IP: %s", clientIP))
		kong.Response.Exit(429, map[string]interface{}{
			"error":  "Too many requests",
			"limit":  conf.MaxRequestsPerMinute,
			"window": "1 minute",
		}, nil)
		return
	}

	// Add debug headers if enabled
	if conf.EnableDebugHeaders {
		kong.ServiceRequest.SetHeader("X-Plugin-Lang", "Go")
		kong.ServiceRequest.SetHeader("X-Plugin-Version", Version)
		kong.ServiceRequest.SetHeader("X-Validated-By", "advanced-validator-go")
		kong.ServiceRequest.SetHeader("X-Client-IP", clientIP)
		kong.ServiceRequest.SetHeader("X-Request-Method", method)
	}

	kong.Log.Info("Request validated successfully by Go plugin")
}

// checkRateLimit implements rate limiting using Redis
func (conf Config) checkRateLimit(kong *pdk.PDK, clientIP string) bool {
	// Connect to Redis
	rdb := redis.NewClient(&redis.Options{
		Addr: fmt.Sprintf("%s:%d", conf.RedisHost, conf.RedisPort),
		DB:   0,
	})
	defer rdb.Close()

	ctx := context.Background()
	key := fmt.Sprintf("rate_limit:%s", clientIP)

	// Get current count
	count, err := rdb.Get(ctx, key).Int()
	if err != nil && err != redis.Nil {
		kong.Log.Err("Redis error: " + err.Error())
		// Allow request if Redis is unavailable
		return true
	}

	// Check if limit exceeded
	if count >= conf.MaxRequestsPerMinute {
		return false
	}

	// Increment counter
	pipe := rdb.TxPipeline()
	pipe.Incr(ctx, key)
	pipe.Expire(ctx, key, time.Minute)
	_, err = pipe.Exec(ctx)

	if err != nil {
		kong.Log.Err("Failed to update rate limit counter: " + err.Error())
		// Allow request if Redis operation fails
		return true
	}

	return true
}

// contains checks if a slice contains a specific string
func contains(slice []string, item string) bool {
	for _, s := range slice {
		if strings.EqualFold(s, item) {
			return true
		}
	}
	return false
}
