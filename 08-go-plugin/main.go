package main

import (
	"log"

	"github.com/Kong/go-pdk"
	"github.com/Kong/go-pdk/server"
)

type Plugin struct{}

func New() interface{} {
	return &Plugin{}
}

func (p *Plugin) Access(kong *pdk.PDK) {
	log.Println("Go plugin executado - adicionando header x-golang")
	kong.Response.SetHeader("x-golang", "true")
	kong.Response.SetHeader("x-go-time", "processed")
}

func main() {
	log.Println("Iniciando plugin Go...")
	server.StartServer(New, "1.0.0", 100)
}
