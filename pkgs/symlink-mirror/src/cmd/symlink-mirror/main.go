package main

import (
	"fmt"
	"os"
	"path/filepath"
	"sync"
)

func createSymlink(src, dst string) error {
	relPath, err := filepath.Rel(filepath.Dir(dst), filepath.Dir(src))
	if err != nil {
		return err
	}

	target := filepath.Join(relPath, filepath.Base(src))
	return os.Symlink(target, dst)
}

func symlinkCopy(srcDir, dstDir string) error {
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
			err = os.MkdirAll(dstPath, info.Mode())
			if err != nil {
				return err
			}
		} else {
			wg.Add(1)
			go func() {
				defer wg.Done()
				if err := createSymlink(srcPath, dstPath); err != nil {
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
	if len(os.Args) != 3 {
		fmt.Printf("Usage: %s <source_dir> <destination_dir>\n", os.Args[0])
		os.Exit(1)
	}

	srcDir, err := filepath.Abs(os.Args[1])
	if err != nil {
		fmt.Printf("Error: Cannot resolve source directory: %v\n", err)
		os.Exit(1)
	}

	dstDir, err := filepath.Abs(os.Args[2])
	if err != nil {
		fmt.Printf("Error: Cannot resolve destination directory: %v\n", err)
		os.Exit(1)
	}

	if _, err := os.Stat(srcDir); os.IsNotExist(err) {
		fmt.Println("Error: Source directory does not exist or is not a directory.")
		os.Exit(1)
	}

	if _, err := os.Stat(dstDir); os.IsNotExist(err) {
		fmt.Println("Error: Destination directory does not exist or is not a directory.")
		os.Exit(1)
	}

	err = symlinkCopy(srcDir, dstDir)
	if err != nil {
		fmt.Printf("Error: %v\n", err)
		os.Exit(1)
	}
}
