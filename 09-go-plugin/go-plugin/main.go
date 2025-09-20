package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"advanced-validator-go/plugin"
)

const (
	Version = "1.0.0"
)

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8002"
	}

	// Criar servidor HTTP
	server := plugin.NewServer()

	// Configurar rotas
	http.HandleFunc("/validate", server.ValidateHandler)
	http.HandleFunc("/health", server.HealthHandler)
	http.HandleFunc("/status", server.StatusHandler)

	// Configurar servidor HTTP
	httpServer := &http.Server{
		Addr:         ":" + port,
		Handler:      nil,
		ReadTimeout:  10 * time.Second,
		WriteTimeout: 10 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	// Canal para sinais de shutdown
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)

	// Iniciar servidor em goroutine
	go func() {
		log.Printf("Go Validator Service starting on port %s (version %s)", port, Version)
		if err := httpServer.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("Failed to start server: %v", err)
		}
	}()

	// Aguardar sinal de shutdown
	<-quit
	log.Println("Shutting down server...")

	// Graceful shutdown
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	if err := httpServer.Shutdown(ctx); err != nil {
		log.Fatalf("Server forced to shutdown: %v", err)
	}

	log.Println("Server exited")
}
