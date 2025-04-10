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
)

type logger struct {
	enableColors bool
}

func newLogger() *logger {
	return &logger{
		enableColors: os.Getenv("NO_COLOR") == "" && isatty.IsTerminal(os.Stderr.Fd()),
	}
}

func (l *logger) log(isError bool, format string, args ...interface{}) {
	prefix := "[periodic-exec]"
	if isError && l.enableColors {
		prefix = "\033[31m" + prefix + "\033[0m"
	} else if l.enableColors {
		prefix = "\033[90m" + prefix + "\033[0m"
	}
	fmt.Fprintf(os.Stderr, "%s %s %s\n", prefix, time.Now().Format(time.RFC3339), fmt.Sprintf(format, args...))
}

func (l *logger) info(format string, args ...interface{})  { l.log(false, format, args...) }
func (l *logger) error(format string, args ...interface{}) { l.log(true, format, args...) }

func main() {
	timeout := flag.Int("timeout", 10, "Timeout in seconds for no output")
	repeatInterval := flag.Int("repeat-interval-seconds", 0, "Seconds to wait before re-running the command if it exits with 0")
	flag.Usage = func() {
		fmt.Fprintf(os.Stderr, "Usage: %s [options] -- command [args...]\n", os.Args[0])
		flag.PrintDefaults()
	}
	flag.Parse()

	cmdArgs := parseCmdArgs()
	if len(cmdArgs) == 0 {
		flag.Usage()
		os.Exit(2)
	}

	l := newLogger()
	for {
		if exitCode := run(l, cmdArgs[0], cmdArgs[1:], *timeout); exitCode != 0 {
			os.Exit(exitCode)
		}
		if *repeatInterval <= 0 {
			os.Exit(0)
		}
		waitAndLog(l, *repeatInterval)
	}
}

func parseCmdArgs() []string {
	for i, arg := range os.Args {
		if arg == "--" && i < len(os.Args)-1 {
			return os.Args[i+1:]
		}
	}
	return nil
}

func run(l *logger, name string, args []string, timeout int) int {
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	cmd := exec.CommandContext(ctx, name, args...)
	stdout, err := cmd.StdoutPipe()
	if err != nil {
		l.error("Failed to create stdout pipe: %v", err)
		return 2
	}
	stderr, err := cmd.StderrPipe()
	if err != nil {
		l.error("Failed to create stderr pipe: %v", err)
		return 2
	}

	if err := cmd.Start(); err != nil {
		l.error("Failed to start command: %v", err)
		return 2
	}

	outputCh := make(chan struct{}, 1)
	var wg sync.WaitGroup
	wg.Add(2)

	pipe := func(r io.ReadCloser, w io.Writer) {
		defer wg.Done()
		buf := make([]byte, 4096)
		for {
			n, err := r.Read(buf)
			if n > 0 {
				if _, err := w.Write(buf[:n]); err != nil {
					l.error("Failed to write output: %v", err)
					return
				}
				select {
				case outputCh <- struct{}{}:
				default:
				}
			}
			if err != nil {
				return
			}
		}
	}

	go pipe(stdout, os.Stdout)
	go pipe(stderr, os.Stderr)

	timer := time.NewTimer(time.Duration(timeout) * time.Second)
	defer timer.Stop()

	done := make(chan error, 1)
	go func() { done <- cmd.Wait() }()

	for {
		select {
		case <-outputCh:
			if !timer.Stop() {
				<-timer.C
			}
			timer.Reset(time.Duration(timeout) * time.Second)

		case <-timer.C:
			l.error("No output received in the last %d seconds", timeout)
			_ = cmd.Process.Kill()
			wg.Wait()
			return 1

		case err := <-done:
			wg.Wait()
			if err != nil {
				if exitErr, ok := err.(*exec.ExitError); ok {
					if status, ok := exitErr.Sys().(interface{ ExitStatus() int }); ok {
						return status.ExitStatus()
					}
				}
				return 1
			}
			return 0

		case <-ctx.Done():
			if cmd.Process != nil {
				_ = cmd.Process.Kill()
			}
			wg.Wait()
			return 0
		}
	}
}

func waitAndLog(l *logger, seconds int) {
	for i := seconds; i > 0; i-- {
		if i%60 == 0 || i == seconds {
			l.info("Waiting %d second(s) before re-running the command...", i)
		}
		time.Sleep(time.Second)
	}
}
