package main

import (
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"sync"
)

func createSymlink(srcPath, dstPath string, absolute bool) error {
	var target string
	if absolute {
		target = srcPath
	} else {
		relTarget, err := filepath.Rel(filepath.Dir(dstPath), srcPath)
		if err != nil {
			return err
		}
		target = relTarget
	}

	return os.Symlink(target, dstPath)
}

func symlinkCopy(srcDir, dstDir string, absolute bool) error {
	var wg sync.WaitGroup
	var walkErr error

	err := filepath.Walk(srcDir, func(srcPath string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}

		relPath, err := filepath.Rel(srcDir, srcPath)
		if err != nil {
			return err
		}

		dstPath := filepath.Join(dstDir, relPath)

		if info.IsDir() {
			err = os.MkdirAll(dstPath, info.Mode()|0200) // Ensure owner write permission
			if err != nil {
				return err
			}
		} else {
			wg.Add(1)
			go func() {
				defer wg.Done()
				if err := createSymlink(srcPath, dstPath, absolute); err != nil {
					walkErr = err
				}
			}()
		}

		return nil
	})

	wg.Wait()

	if walkErr != nil {
		return walkErr
	}

	return err
}

func main() {
	// Add the "absolute" flag
	absolute := flag.Bool("absolute", false, "Use absolute paths for symlinks")
	flag.Parse()

	// Verify the correct number of arguments
	if len(flag.Args()) != 2 {
		fmt.Println("Usage: symlink_copy [OPTIONS] <src> <dst>")
		flag.PrintDefaults()
		os.Exit(1)
	}

	// Get the source and destination directories
	srcDir := flag.Arg(0)
	dstDir := flag.Arg(1)

	// Run the symlinkCopy function
	err := symlinkCopy(srcDir, dstDir, *absolute)
	if err != nil {
		fmt.Printf("Error creating symlink copy: %v\n", err)
		os.Exit(1)
	}
}
