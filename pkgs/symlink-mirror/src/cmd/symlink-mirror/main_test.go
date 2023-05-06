package main

import (
	"io/ioutil"
	"os"
	"path/filepath"
	"testing"
)

func TestSymlinkCopyIntegration(t *testing.T) {
	// Create temporary source and destination directories.
	srcDir, err := ioutil.TempDir("", "srcDir")
	if err != nil {
		t.Fatalf("Error creating temporary source directory: %v", err)
	}
	defer os.RemoveAll(srcDir)

	dstDir, err := ioutil.TempDir("", "dstDir")
	if err != nil {
		t.Fatalf("Error creating temporary destination directory: %v", err)
	}
	defer os.RemoveAll(dstDir)

	// Create source directory structure and files.
	testFiles := []string{
		"file1.txt",
		"dir1/file2.txt",
		"dir1/dir2/file3.txt",
		"dir3/file4.txt",
	}

	for _, file := range testFiles {
		filePath := filepath.Join(srcDir, file)
		err := os.MkdirAll(filepath.Dir(filePath), 0755)
		if err != nil {
			t.Fatalf("Error creating test directory structure: %v", err)
		}

		err = ioutil.WriteFile(filePath, []byte("test content"), 0644)
		if err != nil {
			t.Fatalf("Error creating test file: %v", err)
		}
	}

	// Run symlinkCopy function.
	err = symlinkCopy(srcDir, dstDir)
	if err != nil {
		t.Fatalf("Error running symlinkCopy: %v", err)
	}

	// Verify that the destination directory has the correct symlinks.
	err = filepath.Walk(dstDir, func(dstPath string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}

		if dstPath == dstDir {
			return nil
		}

		relPath, err := filepath.Rel(dstDir, dstPath)
		if err != nil {
			return err
		}

		srcPath := filepath.Join(srcDir, relPath)

		if info.IsDir() {
			if _, err := os.Stat(srcPath); os.IsNotExist(err) {
				t.Errorf("Directory in destination does not exist in source: %s", dstPath)
			}
		} else if info.Mode()&os.ModeSymlink != 0 {
			linkTarget, err := os.Readlink(dstPath)
			if err != nil {
				return err
			}

			expectedTarget, err := filepath.Rel(filepath.Dir(dstPath), srcPath)
			if err != nil {
				return err
			}

			if linkTarget != expectedTarget {
				t.Errorf("Symlink target incorrect: expected %s, got %s", expectedTarget, linkTarget)
			}
		} else {
			t.Errorf("Non-symlink file found in destination directory: %s", dstPath)
		}

		return nil
	})

	if err != nil {
		t.Fatalf("Error verifying destination directory: %v", err)
	}
}
