# Deno Hash Update Process

Determine the latest version series and updates SHA256 hashes in Deno package files when releases change.

## Files
- `pkgs/deno-2.x.x.nix`
- `pkgs/denort-2.x.x.nix`

## Steps

### 1. Get Latest Version
```bash
mcp_GitHub_get_latest_release --owner denoland --repo deno
```

Update version in both files:
```bash
sed -i 's/version = ".*";/version = "[NEW_VERSION_HERE]";/' pkgs/deno-2.x.x.nix
sed -i 's/version = ".*";/version = "NEW_VERSION_HERE";/' pkgs/denort-2.x.x.nix
```

### 2. Clear Hashes
```bash
sed -i 's/hash = "sha256-[^"]*";/hash = "";/g' pkgs/deno-2.x.x.nix
sed -i 's/hash = "sha256-[^"]*";/hash = "";/g' pkgs/denort-2.x.x.nix
```

### 3. Build All Architectures
```bash
for arch in aarch64-darwin x86_64-linux aarch64-linux; do
  for pkg in deno denort; do
    ./cli.sh fn_nix_build -L ".#packages.${arch}.${pkg}"
  done
done
```

### 4. Extract Hashes
From error output, extract hash from `got:` line:
```
error: hash mismatch in fixed-output derivation:
         specified: sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=
            got:    sha256-ACTUAL_HASH_HERE=
```

### 5. Update Files
Use `search_replace` tool to replace empty hashes with extracted values. Do NOT verify builds until user approves changes.

## Architectures
- `aarch64-darwin` (Apple Silicon)
- `x86_64-linux` (Intel/AMD Linux)
- `aarch64-linux` (ARM Linux)
