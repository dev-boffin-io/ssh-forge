# =========================================================
# easy-ssh-dev Makefile
# Author: Sumit
# =========================================================

.DEFAULT_GOAL := help

APP=sshx-dev
BUILD_SCRIPT=./app-build-install
DEPS_SCRIPT=./build/build-deps

.PHONY: help deps build cli install uninstall clean rebuild dry-run

# ---------------------------------------------------------
# NOTE:
# install target requires prebuilt binary:
#   ./sshx-dev
#
# Build first:
#   make build
# ---------------------------------------------------------

# ---------------- Help ----------------

help:
	@echo ""
	@echo "easy-ssh-dev Build System"
	@echo ""
	@echo "Targets:"
	@echo "  make deps        Install build dependencies"
	@echo "  make build       Build CLI + GUI"
	@echo "  make cli         Build CLI only"
	@echo "  make install     Install binaries (requires prebuilt sshx-dev)"
	@echo "  make uninstall   Remove installation"
	@echo "  make clean       Remove built artifacts"
	@echo "  make rebuild     Clean + Build"
	@echo "  make dry-run     Simulate build"
	@echo ""

# ---------------- Dependencies ----------------

deps:
	@echo "Installing build dependencies..."
	$(DEPS_SCRIPT)

# ---------------- Build ----------------

build:
	$(BUILD_SCRIPT)

cli:
	$(BUILD_SCRIPT) --cli

dry-run:
	$(BUILD_SCRIPT) --dry-run

# ---------------- Install ----------------

install:
	@if [ ! -f "./$(APP)" ]; then \
		echo "❌ $(APP) binary not found."; \
		echo "Run 'make build' first."; \
		exit 1; \
	fi
	./$(APP) install

uninstall:
	./$(APP) uninstall

# ---------------- Clean ----------------

clean:
	@echo "Cleaning build artifacts..."
	rm -f bin/sshx \
	      bin/sshx-key \
	      bin/scpx \
	      bin/git-auth \
	      bin/sshx-cpy \
	      bin/sshx-reset \
	      sshx-dev \
	      gui/sshx-gui
	rm -rf gui/_internal
	@echo "✔ Clean complete"

# ---------------- Rebuild ----------------

rebuild: clean build
