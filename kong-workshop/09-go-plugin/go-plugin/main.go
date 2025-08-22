package main

import (
	"advanced-validator-go/plugin"

	"github.com/Kong/go-pdk/server"
)

var (
	Version  = "1.0.0"
	Priority = 1000
)

func main() {
	server.StartServer(plugin.New, Version, Priority)
}
