package main

import (
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"os/signal"
	"path/filepath"
	"regexp"
	"strings"
	"syscall"
	"time"
)

var basePathHeader string
var indexHtmlContent string
var immutableExts map[string]bool

var basePathRegex = regexp.MustCompile("^[a-zA-Z0-9/_-]+$")

func isValidBasePath(basePath string) bool {
	if strings.Contains(basePath, "..") {
		return false
	}
	return basePathRegex.MatchString(basePath)
}

func fallbackToIndexHtml(w http.ResponseWriter, req *http.Request) {
	var basePath string

	if basePathHeaderValue := req.Header.Get(basePathHeader); basePathHeaderValue != "" && isValidBasePath(basePathHeaderValue) {
		basePath = basePathHeaderValue
	} else {
		basePath = "/"
	}

	modifiedHtmlContent := indexHtmlContent
	baseTagRegex := regexp.MustCompile(`\<base.*href=.*?\>`)

	// Strip existing script that matches the following regex.
	// <script>window["baseHref"] = ...;</script>
	modifiedHtmlContent = regexp.MustCompile(`<script>window\["baseHref"\] = .*?</script>`).ReplaceAllString(modifiedHtmlContent, "")

	if baseTagRegex.MatchString(modifiedHtmlContent) {
		modifiedHtmlContent = baseTagRegex.ReplaceAllString(modifiedHtmlContent, fmt.Sprintf(`<base href="%s"><script>window["baseHref"] = "%s";</script>`, basePath, basePath))
	} else {
		modifiedHtmlContent = strings.Replace(modifiedHtmlContent, "<head>", fmt.Sprintf(`<head><base href="%s"><script>window["baseHref"] = "%s";</script>`, basePath, basePath), 1)
	}

	log.Printf("Fallback url=%s basePath=%s\n", req.URL, basePath)

	w.Header().Set("Content-Type", "text/html")
	w.Header().Set("Cache-Control", "no-cache, no-store, max-age=0, must-revalidate")
	w.Header().Set("Pragma", "no-cache")
	w.Header().Set("Expires", "0")

	fmt.Fprint(w, modifiedHtmlContent)
}

// logWriter struct for custom log output
type logWriter struct{}

// Write method for custom logWriter
func (lw *logWriter) Write(p []byte) (n int, err error) {
	return fmt.Printf("%s %s", time.Now().Format(time.RFC3339), p)
}

func main() {
	// Set log timestamp format to ISO format
	log.SetFlags(0)   // Disable default flags
	log.SetPrefix("") // Disable prefix
	log.SetOutput(&logWriter{})

	// Read command-line arguments
	host := flag.String("host", "0.0.0.0", "Set the host for the server")
	port := flag.Int("port", 8080, "Set the port for the server")
	dir := flag.String("dir", ".", "Set the root directory for serving files")
	immutableExtsFlag := flag.String("immutable-exts", "", "Comma-separated list of immutable file extensions")
	basePathHeaderFlag := flag.String("base-path-header", "X-App-Base-Path", "The header name that contains the base path")

	flag.Parse()

	basePathHeader = *basePathHeaderFlag
	immutableExts = make(map[string]bool)
	for _, ext := range strings.Split(*immutableExtsFlag, ",") {
		immutableExts[ext] = true
	}

	// Debugging: Print out all parsed command-line arguments
	fmt.Printf("Effective CLI Arguments:\n")
	fmt.Printf("  Host: %s\n", *host)
	fmt.Printf("  Port: %d\n", *port)
	fmt.Printf("  Dir: %s\n", *dir)
	fmt.Printf("  Immutable Extensions: %s\n", *immutableExtsFlag)
	fmt.Printf("  Base Path Header: %s\n", basePathHeader)

	absoluteDir, err := filepath.Abs(*dir)
	if err != nil {
		log.Fatalf("Failed to resolve absolute directory: %v\n", err)
	}

	// Check if directory exists
	if _, err := os.Stat(absoluteDir); os.IsNotExist(err) {
		log.Fatalf("Specified directory does not exist: %s\n", absoluteDir)
	}

	indexHtmlContentBytes, err := ioutil.ReadFile(filepath.Join(absoluteDir, "index.html"))
	if err != nil {
		log.Fatalf("Failed to read index.html: %v\n", err)
	}
	indexHtmlContent = string(indexHtmlContentBytes)

	mimeTypes := map[string]string{
		".html": "text/html",
		".css":  "text/css",
		".js":   "text/javascript",
		".json": "application/json",
		".png":  "image/png",
		".jpg":  "image/jpeg",
		".gif":  "image/gif",
		".svg":  "image/svg+xml",
		".wav":  "audio/wav",
		".mp4":  "video/mp4",
		".woff": "font/woff",
		".ttf":  "font/ttf",
		".ico":  "image/x-icon",
	}

	http.HandleFunc("/", func(w http.ResponseWriter, req *http.Request) {
		if req.URL.Path == "/healthz" {
			w.Header().Set("Content-Type", "text/plain")
			fmt.Fprint(w, "OK")
			return
		}

		filePath := filepath.Join(absoluteDir, req.URL.Path)

		if !strings.HasPrefix(filePath, absoluteDir) {
			fallbackToIndexHtml(w, req)
			return
		}

		fileInfo, err := os.Stat(filePath)
		if err != nil {
			fallbackToIndexHtml(w, req)
			return
		}

		if fileInfo.IsDir() {
			fallbackToIndexHtml(w, req)
			return
		}

		ext := filepath.Ext(filePath)
		contentType, exists := mimeTypes[ext]
		if !exists {
			contentType = "application/octet-stream"
		}

		if immutableExts[ext] {
			w.Header().Set("Cache-Control", "public, max-age=31536000, immutable")
		} else {
			w.Header().Set("Cache-Control", "no-cache, no-store, max-age=0, must-revalidate")
			w.Header().Set("Pragma", "no-cache")
			w.Header().Set("Expires", "0")
		}

		log.Printf("Serve url=%s filePath=%s contentType=%s\n", req.URL, filePath, contentType)

		w.Header().Set("Content-Type", contentType)
		http.ServeFile(w, req, filePath)
	})

	serverAddr := fmt.Sprintf("%s:%d", *host, *port)
	srv := &http.Server{
		Addr: serverAddr,
	}

	go func() {
		log.Printf("Server running at http://%s/\n", serverAddr)
		if err := srv.ListenAndServe(); err != nil {
			log.Fatal(err)
		}
	}()

	// Shutdown handling
	gracefulStop := make(chan os.Signal, 1)
	signal.Notify(gracefulStop, syscall.SIGTERM, syscall.SIGINT)

	sigReceived := <-gracefulStop
	log.Printf("Received signal: %+v. Shutting down gracefully...\n", sigReceived)

	srv.Shutdown(nil)

	log.Println("Closed out remaining connections.")
}
