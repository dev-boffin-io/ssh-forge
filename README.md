# easy-ssh — Simple SSH Manager

A lightweight, portable SSH management toolkit for Linux with both CLI and GTK GUI support. Written in Go (CLI tools) and Python (GUI).

---

## Features

- **Smart SSH connection manager** — auto-installs SSH key on first connect, caches hosts in `~/.ssh/sshx.json`
- **Auto key setup** — generates `ed25519` key if missing, auto-copies to remote via `ssh-copy-id`
- **IPv4 & IPv6 support** — `user@host:port` and `user@[::1]:port` formats
- **Interactive fuzzy menu** — `fzf`-powered host picker via `--menu`
- **Secure file transfer** — `scpx` push/pull with recursive SCP, supports IPv6
- **GitHub SSH wizard** — `git-auth` guides full key setup interactively
- **SSH environment cleanup** — `sshx-reset` safely removes junk, preserves identity keys
- **GTK3 GUI** — tabbed terminal interface, all tools accessible via toolbar
- **OS-aware installer** — supports Debian, Fedora, Arch, Alpine, Termux
- **Dry-run & CLI-only** build modes

---

## Project Structure

```
easy-ssh-dev/
│
├── 📁 bin/                        # Compiled binaries (build output)
│   ├── sshx                       # Main SSH manager — connect, list, doctor, menu
│   ├── sshx-key                   # SSH key generator (ed25519)
│   ├── sshx-cpy                   # Copies SSH public key to a remote host
│   ├── sshx-reset                 # Cleans ~/.ssh junk files, resets known_hosts
│   ├── git-auth                   # GitHub SSH authentication verifier & setup wizard
│   ├── scpx                       # Secure file transfer (push/pull over SSH)
│   └── ssh-terminal.png           # GUI icon asset
│
├── 📁 src/                        # Go source files
│   ├── main.go                    # sshx CLI — connect, list, menu, doctor, remove
│   ├── init.go                    # Initialization — key permissions, cache check
│   ├── sshx-key.go                # SSH key generation (ed25519 + ssh-agent)
│   ├── sshx-cpy.go                # SSH public key installer (injection-safe)
│   ├── sshx-reset.go              # SSH cleanup — removes *.old/*.tmp/*.bak, resets known_hosts
│   ├── git-auth.go                # GitHub auth check, key setup wizard, browser launcher
│   ├── scpx.go                    # SCP wrapper — recursive push/pull, IPv4/IPv6
│   └── go.mod                     # Go module definition
│
├── 📁 build/                      # Build scripts
│   ├── build-bin                  # Builds all binaries → bin/
│   ├── build-init                 # Builds: sshx-dev (installer runner)
│   └── build-gui                  # Builds GUI via PyInstaller → gui/sshx-gui
│
├── 📁 gui/                        # GTK GUI frontend
│   ├── easy-ssh-gui.py            # Python GTK3 + VTE GUI with tabbed terminal
│   ├── sshx-gui                   # Compiled GUI binary (PyInstaller output)
│   └── _internal/                 # PyInstaller bundled runtime files
│
├── 📁 installer/
│   └── install.sh                 # Dependency installer (OS-aware: apt/dnf/pacman/apk/pkg)
│
├── sshx-dev                       # Post-build installer runner (runs `sshx-dev install`)
├── app-build-install              # Master build + install script (supports --cli, --dry-run)
├── sshx.toml                      # Project config file
├── install.log                    # Auto-generated installation log
├── LICENSE                        # Project license
└── README.md                      # This file
```

### Component Overview

| Binary | Source | Location | Role |
|--------|--------|----------|------|
| `sshx` | `src/main.go` | `bin/` | Core SSH manager — connect, list, menu, doctor |
| `sshx-key` | `src/sshx-key.go` | `bin/` | SSH ed25519 key generator |
| `scpx` | `src/scpx.go` | `bin/` | Recursive push/pull file transfer over SSH |
| `git-auth` | `src/git-auth.go` | `bin/` | GitHub SSH auth verifier + interactive setup wizard |
| `sshx-cpy` | `src/sshx-cpy.go` | `bin/` | Injection-safe SSH public key installer |
| `sshx-reset` | `src/sshx-reset.go` | `bin/` | SSH dir cleanup & known_hosts reset |
| `sshx-gui` | `gui/easy-ssh-gui.py` | `gui/` | GTK3+VTE tabbed GUI terminal |
| `install.sh` | `installer/install.sh` | — | OS-aware dependency installer |
| `app-build-install` | `app-build-install` | root | Full build + install orchestrator (supports `--cli`, `--dry-run`) |

---

## Requirements

### Core (required)

| Tool    | Minimum Version | Purpose |
|---------|----------------|---------|
| Go      | 1.20+          | Build all CLI tools |
| openssh | any            | `ssh`, `ssh-keygen`, `ssh-copy-id`, `scp` |
| jq      | any            | JSON processing |

### Optional

| Tool   | Purpose |
|--------|---------|
| `fzf`  | Interactive host picker (`sshx --menu`) |

### GUI (optional)

| Dependency | Package |
|-----------|---------|
| Python 3.8+ | `python3` |
| GTK 3.0 | `libgtk-3-0` / `gtk3` |
| VTE 2.91 | `libvte-2.91-0` / `vte291` |
| Python GObject | `python3-gi` / `python3-gobject` |

---

## Installation

### 1. Install Dependencies

```bash
# Install core + GUI dependencies
bash installer/install.sh --gui

# Install core only (no GUI)
bash installer/install.sh

# Install CLI tools only (minimal)
bash installer/install.sh --cli

# Install build tools
bash installer/install.sh --build

# Preview changes without applying (dry run)
bash installer/install.sh --dry-run

# Auto-confirm all prompts
bash installer/install.sh -y
```

**Supported OS:** Debian/Ubuntu, Fedora, Arch, Alpine, Termux

---

### 2. Build & Install

```bash
# Full build (CLI + GUI)
./app-build-install

# CLI only build (skip GUI)
./app-build-install --cli

# Dry run (preview only)
./app-build-install --dry-run
```

---

## Usage

### `sshx` — SSH Manager

```bash
# Connect to a host (IPv4)
sshx user@ip:port

# Connect to a host (IPv6)
sshx user@[::1]:port

# Remove a saved host from cache + known_hosts
sshx user@ip:port --remove

# List all saved hosts
sshx --list

# Interactive fuzzy menu (requires fzf)
sshx --menu

# Run diagnostics (checks ssh, fzf, key)
sshx --doctor

# Version info
sshx --version

# Help
sshx --help
```

**How `sshx` works on first connect:**

1. Checks if the host already exists in `~/.ssh/sshx.json`
2. If new — tests key-based auth with a 5-second timeout
3. If key not installed — runs `ssh-copy-id` automatically (prompts for password once)
4. Saves the host to cache on success
5. Connects via `ssh` using `syscall.Exec` (replaces the current process — zero subprocess overhead)

**Cache file:** `~/.ssh/sshx.json` — stores `user`, `host`, `port` per entry.

**On `--remove`:** deletes the entry from cache and cleans the host from `known_hosts` via `ssh-keygen -R`.

---

### `scpx` — Secure File Transfer

```bash
# Push local file/folder to remote
scpx push user@host:port /local/path /remote/dir

# Pull file/folder from remote
scpx pull user@host:port /remote/path /local/dir

# IPv6 support
scpx push user@[::1]:port /local/file /remote/dir
scpx pull user@[::1]:port /remote/file /local/dir
```

**Notes:**
- Wraps `scp -r` (recursive) under the hood
- Auto-creates local destination directory on `pull`
- Validates port range (1–65535) and host format before connecting
- Supports both IPv4 (`user@host:port`) and IPv6 (`user@[::1]:port`) targets

---

### `sshx-key` — Key Generation

```bash
sshx-key your@email.com
```

---

### `git-auth` — GitHub SSH Auth Wizard

```bash
git-auth
```

Interactive GitHub SSH authentication tool. It:

1. Checks if your SSH key is authenticated with GitHub
2. Detects existing local SSH keys (`~/.ssh/id_rsa`, `~/.ssh/id_ed25519`)
3. Detects if SSH agent is running
4. If auth fails — prompts to generate a new key via `sshx-key`
5. Shows step-by-step instructions to add the key to GitHub
6. Optionally opens `https://github.com/settings/keys` in your browser
7. Re-verifies the connection after you add the key

---

### `sshx-cpy` — Copy SSH Key to Remote Host

```bash
# Standard usage
sshx-cpy user@host:port

# Default port (22) — port optional
sshx-cpy user@host

# IPv6
sshx-cpy user@[::1]:port
```

Installs your local SSH public key on a remote host for passwordless login. **More robust than `ssh-copy-id`** — uses injection-safe key installation.

**How it works:**

1. Detects your private key automatically (`~/.ssh/id_ed25519` → `~/.ssh/id_rsa`)
2. Reads the matching `.pub` file (or extracts it via `ssh-keygen -y` if missing)
3. Connects via SSH and runs a safe remote script that:
   - Creates `~/.ssh/` with correct permissions (`700`)
   - Creates `authorized_keys` with correct permissions (`600`)
   - Appends your key **only if not already present** (no duplicates)
4. Verifies passwordless login with `BatchMode=yes` after installation
5. Prints the exact `ssh` command to use on success

**Key detection order:** `id_ed25519` → `id_rsa`

---

### `sshx-reset` — SSH Environment Cleanup

```bash
sshx-reset
```

Safely cleans your `~/.ssh` directory:

- Removes junk files matching: `*.old`, `*.tmp`, `*.bak`, `known_hosts`
- **Preserves** protected keys: `id_ed25519`, `id_ed25519.pub`, `authorized_keys`
- Resets `known_hosts` to an empty file (permissions `600`)
- Prints a full report of what was removed and what was preserved

---

## GUI

Launch the GTK GUI:

```bash
sshx-gui
# or directly:
python3 gui/easy-ssh-gui.py
```

**Toolbar buttons:**

| Button           | Action                          |
|------------------|---------------------------------|
| Connect          | SSH connect via popup input     |
| List             | List saved hosts                |
| Doctor           | Run diagnostics                 |
| Version          | Show version info               |
| Help             | Show CLI help                   |
| Gen Key          | Generate SSH key (by email)     |
| Copy Fingerprint | Show public key fingerprint     |
| Git Auth         | Verify GitHub SSH auth          |
| SSHX Copy        | Copy SSH config to remote host  |
| SSHX Reset       | Reset configuration             |
| SCPX             | File transfer dialog (push/pull)|
| Close Tab        | Close current terminal tab      |

Each action opens in a **new terminal tab** inside the GUI.

**Keyboard shortcuts (inside terminal tabs):**

| Shortcut       | Action     |
|----------------|------------|
| `Ctrl+Shift+C` | Copy       |
| `Ctrl+Shift+V` | Paste      |
| `Ctrl+Shift+A` | Select All |

Right-click menu also supports Copy, Paste, and Select All.

---

## Configuration

### `~/.ssh/sshx.json` — Host Cache (auto-managed)

Stores all registered SSH hosts. Created automatically on first use. Format:

```json
{
  "user@192.168.1.10:22": {
    "user": "user",
    "host": "192.168.1.10",
    "port": 22
  }
}
```

Managed entirely by `sshx` — do not edit manually unless necessary.

### `sshx.toml` — Project Config

Located in the project root. Used during build and installation.

### `~/.ssh/` — SSH Directory

| File | Role |
|------|------|
| `id_ed25519` | Private key (auto-generated if missing) |
| `id_ed25519.pub` | Public key (copied to remotes on first connect) |
| `known_hosts` | Remote host fingerprints (cleared by `sshx-reset`) |
| `sshx.json` | Host cache used by `sshx` |

---

## License

See [LICENSE](LICENSE) for details.

---

## Author

**Sumit**
