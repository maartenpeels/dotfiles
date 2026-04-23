# Package installation

`install-packages` installs CLI tools via Homebrew (macOS) or apt (Ubuntu/Debian).

Each tool has a definition file under `packages/`. Two formats are supported.

## Variable-based (simple packages)

Source-able file with vars:

```sh
BREW=fd
APT=fd-find
CHECK=fd
APT_CHECK=fdfind   # optional: binary name differs from package name
```

`APT_CHECK` only needed when the apt package installs a differently-named binary (e.g. `fd-find` → `fdfind`).

## Bash script (complex packages)

Make the file executable. The script handles its own install logic and skip detection:

```sh
#!/usr/bin/env bash
set -euo pipefail

command -v mytool >/dev/null 2>&1 && { echo "  [skip] mytool (already installed)"; exit 0; }

# install logic here...
```

Use this when the package isn't in Homebrew/apt, needs custom download logic, or differs significantly by OS/arch (see `packages/lazygit` for an example).

## Usage

```sh
./install-packages          # install all packages
./install-packages fzf bat  # install specific packages
```

Already-installed packages are skipped.

## Adding a package

**Simple:** Create `packages/<name>` with the relevant vars (variable-based format above).

**Complex:** Create `packages/<name>` as an executable bash script that handles its own skip check and install.
