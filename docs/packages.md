# Package installation

`install-packages` installs CLI tools via Homebrew (macOS) or apt (Ubuntu/Debian).

Each tool has a definition file under `packages/`:

```sh
BREW=fd
APT=fd-find
CHECK=fd
APT_CHECK=fdfind   # optional: binary name differs from package name
```

## Usage

```sh
./install-packages          # install all packages
./install-packages fzf bat  # install specific packages
```

Already-installed packages are skipped.

## Adding a package

Create `packages/<name>` with the relevant vars:

```sh
# packages/jq
BREW=jq
APT=jq
CHECK=jq
```

`APT_CHECK` only needed when the apt package installs a differently-named binary (e.g. `fd-find` → `fdfind`).
