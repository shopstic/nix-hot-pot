// monitor.go
package main

import (
	"context"
	"flag"
	"fmt"
	"io"
	"os"
	"os/exec"
	"sync"
	"time"

	"github.com/mattn/go-isatty"
	"github.com/mgutz/ansi"
	"github.com/sirupsen/logrus"
)

// CustomFormatter struct to implement logrus.Formatter
type CustomFormatter struct{}

// Format method implements the logrus.Formatter interface
func (f *CustomFormatter) Format(entry *logrus.Entry) ([]byte, error) {
	// Define the prefix without trailing space
	prefix := "[periodic-exec]"

	// Apply red color to the prefix if it's an error
	if entry.Level == logrus.ErrorLevel || entry.Level == logrus.FatalLevel || entry.Level == logrus.PanicLevel {
		prefix = ansi.Color(prefix, "red+b")
	}

	// Format the timestamp in ISO 8601 format
	timestamp := entry.Time.Format(time.RFC3339)

	// Construct the log message with proper spacing
	logMsg := fmt.Sprintf("%s %s %s\n", prefix, timestamp, entry.Message)

	return []byte(logMsg), nil
}

func main() {
	// Initialize logrus logger
	logger := logrus.New()

	// Set the custom formatter
	logger.SetFormatter(&CustomFormatter{})

	// Determine if colors should be enabled
	enableColors := true
	if os.Getenv("NO_COLOR") != "" || !isTerminal(os.Stdout.Fd()) {
		enableColors = false
	}

	if !enableColors {
		// Disable color by setting a formatter that doesn't use colors
		logger.SetFormatter(&CustomFormatter{})
	} else {
		// Colors are already handled in the CustomFormatter
	}

	// Set output to stderr
	logger.SetOutput(os.Stderr)

	// Define and parse the timeout and repeat interval flags
	timeout := flag.Int("timeout", 10, "Timeout in seconds for no output")
	repeatInterval := flag.Int("repeat-interval-seconds", 0, "Seconds to wait before re-running the command if it exits with 0")
	flag.Usage = func() {
		fmt.Fprintf(os.Stderr, "Usage: %s [options] -- command [args...]\n", os.Args[0])
		flag.PrintDefaults()
	}
	flag.Parse()

	// Find the position of "--"
	sepIndex := -1
	for i, arg := range os.Args {
		if arg == "--" {
			sepIndex = i
			break
		}
	}

	// Ensure that "--" is present and a command is provided after it
	if sepIndex == -1 || sepIndex == len(os.Args)-1 {
		logger.Error("Command to execute must be specified after '--'")
		flag.Usage()
		os.Exit(2)
	}

	// Extract the command and its arguments
	cmdArgs := os.Args[sepIndex+1:]
	cmdName := cmdArgs[0]
	cmdParams := cmdArgs[1:]

	for {
		exitCode := executeAndMonitor(logger, cmdName, cmdParams, *timeout)

		if exitCode != 0 {
			// If the process exited with non-zero, do not repeat
			os.Exit(exitCode)
		}

		if *repeatInterval <= 0 {
			// No repeat interval specified, exit
			os.Exit(0)
		}

		// Repeat interval specified and previous process exited with 0
		waitForRepeatInterval(logger, *repeatInterval)
	}
}

// executeAndMonitor runs the command, monitors its output, and returns its exit code
func executeAndMonitor(logger *logrus.Logger, cmdName string, cmdArgs []string, timeout int) int {
	// Create a context to manage cancellation
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	// Create the command
	cmd := exec.CommandContext(ctx, cmdName, cmdArgs...)

	// Create pipes for stdout and stderr
	stdoutPipe, err := cmd.StdoutPipe()
	if err != nil {
		logger.Errorf("Error obtaining stdout pipe: %v", err)
		return 2
	}

	stderrPipe, err := cmd.StderrPipe()
	if err != nil {
		logger.Errorf("Error obtaining stderr pipe: %v", err)
		return 2
	}

	// Start the command
	if err := cmd.Start(); err != nil {
		logger.Errorf("Error starting command: %v", err)
		return 2
	}

	// Channel to signal when data is received
	outputCh := make(chan struct{}, 2) // Buffer size 2 to prevent blocking

	// WaitGroup to wait for both stdout and stderr to be processed
	var wg sync.WaitGroup
	wg.Add(2)

	// Flag to indicate if the process was killed due to timeout
	var killedDueToTimeout bool
	var mu sync.Mutex

	// Function to read from a pipe and write to the corresponding os.Stdout or os.Stderr
	readPipe := func(pipe io.ReadCloser, writer io.Writer) {
		defer wg.Done()
		buf := make([]byte, 1024)
		for {
			n, err := pipe.Read(buf)
			if n > 0 {
				// Write to the appropriate writer
				_, writeErr := writer.Write(buf[:n])
				if writeErr != nil {
					logger.Errorf("Error writing to output: %v", writeErr)
					return
				}
				// Signal that output was received
				select {
				case outputCh <- struct{}{}:
				default:
					// If the channel is full, do not block
				}
			}
			if err != nil {
				if err != io.EOF {
					// Check if the process was killed due to timeout
					mu.Lock()
					shouldSuppress := killedDueToTimeout
					mu.Unlock()

					if !shouldSuppress {
						logger.Errorf("Error reading pipe: %v", err)
					}
				}
				return
			}
		}
	}

	// Start goroutines to read stdout and stderr
	go readPipe(stdoutPipe, os.Stdout)
	go readPipe(stderrPipe, os.Stderr)

	// Timer to track the timeout
	timer := time.NewTimer(time.Duration(timeout) * time.Second)
	defer timer.Stop()

	// Channel to signal when the command exits
	doneCh := make(chan error, 1)
	go func() {
		doneCh <- cmd.Wait()
	}()

	for {
		select {
		case <-outputCh:
			// Reset the timer whenever output is received
			if !timer.Stop() {
				select {
				case <-timer.C:
				default:
				}
			}
			timer.Reset(time.Duration(timeout) * time.Second)
		case <-timer.C:
			// Timeout reached without new output
			logger.Error(fmt.Sprintf("No output received in the last %d seconds. Exiting.", timeout))
			// Attempt to kill the process
			if err := cmd.Process.Kill(); err != nil {
				logger.Errorf("Failed to kill process: %v", err)
			} else {
				// Indicate that the process was killed due to timeout
				mu.Lock()
				killedDueToTimeout = true
				mu.Unlock()
			}
			// Wait for the command to exit
			wg.Wait()
			return 1
		case err := <-doneCh:
			// Command has exited
			// Stop the timer
			if !timer.Stop() {
				select {
				case <-timer.C:
				default:
				}
			}
			// Indicate that the process was not killed due to timeout
			mu.Lock()
			killedDueToTimeout = false
			mu.Unlock()
			// Wait for the output processing goroutines to finish
			wg.Wait()
			if err != nil {
				// If the command exited with an error, retrieve the exit code
				if exitErr, ok := err.(*exec.ExitError); ok {
					if status, ok := exitErr.Sys().(interface{ ExitStatus() int }); ok {
						return status.ExitStatus()
					}
				}
				// If unable to get exit status, return 1
				return 1
			}
			// Successful execution
			return 0
		case <-ctx.Done():
			// Context was canceled, likely due to monitor shutdown
			// Attempt to kill the process if it's still running
			if cmd.Process != nil {
				_ = cmd.Process.Kill()
			}
			// Wait for the command to exit
			wg.Wait()
			return 0
		}
	}
}

// waitForRepeatInterval waits for the specified number of seconds, logging remaining time every second
func waitForRepeatInterval(logger *logrus.Logger, seconds int) {
	for i := seconds; i > 0; i-- {
		logger.Infof("Waiting %d second(s) before re-running the command...", i)
		time.Sleep(1 * time.Second)
	}
}

// isTerminal checks if the given file descriptor is a terminal
func isTerminal(fd uintptr) bool {
	return isatty.IsTerminal(fd) || isatty.IsCygwinTerminal(fd)
}
