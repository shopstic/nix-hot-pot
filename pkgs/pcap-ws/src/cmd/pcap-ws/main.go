package main

import (
	"flag"
	"fmt"
	"log"
	"net/http"
	"os/exec"
	"strings"

	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{} // Use default options

func handleConnection(w http.ResponseWriter, r *http.Request, pcapCmd string, pcapArgs []string) {
	c, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Println("upgrade:", err)
		return
	}
	defer c.Close()

	clientAddr := c.RemoteAddr().String()
	log.Printf("New connection from %s", clientAddr)

	args := append(pcapArgs, "-w", "-")
	cmd := exec.Command(pcapCmd, args...)
	stdout, err := cmd.StdoutPipe()
	if err != nil {
		log.Printf("Error creating stdout pipe: %v", err)
		return
	}

	defer stdout.Close()

	log.Printf("Starting capture process for client %s with args: %v", clientAddr, args)
	if err := cmd.Start(); err != nil {
		log.Printf("Error starting command: %v", err)
		return
	}

	defer func() {
		log.Printf("Stopping capture process for client %s", clientAddr)
		cmd.Process.Kill()
		cmd.Wait()
	}()

	buff := make([]byte, 1024)
	for {
		n, err := stdout.Read(buff)
		if err != nil {
			log.Printf("Error reading from stdout: %v", err)
			break
		}

		if err := c.WriteMessage(websocket.BinaryMessage, buff[:n]); err != nil {
			log.Printf("Error writing to WebSocket: %v", err)
			break
		}
	}

	log.Printf("Connection from %s closed", clientAddr)
}

func main() {
	port := flag.String("port", "8080", "WebSocket server port")
	iface := flag.String("iface", "0.0.0.0", "Interface to listen on")
	pcapCmd := flag.String("pcap-cmd", "", "The packet capturing command")
	pcapExtraArgs := flag.String("pcap-args", "", "Extra arguments for the packet capturing command")
	flag.Parse()

	pcapArgs := strings.Split(*pcapExtraArgs, " ")
	if len(pcapArgs) == 1 && pcapArgs[0] == "" {
		pcapArgs = []string{}
	}

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		handleConnection(w, r, *pcapCmd, pcapArgs)
	})

	addr := fmt.Sprintf("%s:%s", *iface, *port)
	log.Printf("WebSocket server started at ws://%s", addr)

	err := http.ListenAndServe(addr, nil)
	if err != nil {
		log.Fatalf("Failed to start server: %s", err.Error())
	}
}
