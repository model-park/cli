#!/bin/sh
set -e

# ModelPark CLI installer
# Usage: curl -fsSL https://raw.githubusercontent.com/modelpark/cli/master/install.sh | sh

REPO="modelpark/cli"
BINARY_NAME="modelpark"

# Detect OS
detect_os() {
  case "$(uname -s)" in
    Linux*)  echo "linux" ;;
    Darwin*) echo "darwin" ;;
    MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
    *) echo "unsupported" ;;
  esac
}

# Detect architecture
detect_arch() {
  case "$(uname -m)" in
    x86_64|amd64)  echo "amd64" ;;
    aarch64|arm64)  echo "arm64" ;;
    *) echo "unsupported" ;;
  esac
}

# Find install directory
find_install_dir() {
  if [ -w /usr/local/bin ]; then
    echo "/usr/local/bin"
  elif [ -d "$HOME/.local/bin" ]; then
    echo "$HOME/.local/bin"
  else
    mkdir -p "$HOME/.local/bin"
    echo "$HOME/.local/bin"
  fi
}

main() {
  OS=$(detect_os)
  ARCH=$(detect_arch)

  if [ "$OS" = "unsupported" ] || [ "$ARCH" = "unsupported" ]; then
    echo "Error: Unsupported platform: $(uname -s)/$(uname -m)"
    exit 1
  fi

  if [ "$OS" = "windows" ] && [ "$ARCH" = "arm64" ]; then
    echo "Error: Windows ARM64 is not supported"
    exit 1
  fi

  # Get latest release tag
  LATEST=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" | grep '"tag_name"' | sed -E 's/.*"tag_name": *"([^"]+)".*/\1/')
  if [ -z "$LATEST" ]; then
    echo "Error: Could not determine latest release"
    exit 1
  fi

  echo "Installing ${BINARY_NAME} ${LATEST} (${OS}/${ARCH})..."

  # Determine archive name and extension
  if [ "$OS" = "windows" ]; then
    ARCHIVE="${BINARY_NAME}-${OS}-${ARCH}.zip"
  else
    ARCHIVE="${BINARY_NAME}-${OS}-${ARCH}.tar.gz"
  fi

  DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${LATEST}/${ARCHIVE}"
  CHECKSUMS_URL="https://github.com/${REPO}/releases/download/${LATEST}/checksums.txt"

  TMPDIR=$(mktemp -d)
  trap 'rm -rf "$TMPDIR"' EXIT

  # Download archive and checksums
  echo "Downloading ${ARCHIVE}..."
  curl -fsSL -o "${TMPDIR}/${ARCHIVE}" "$DOWNLOAD_URL"
  curl -fsSL -o "${TMPDIR}/checksums.txt" "$CHECKSUMS_URL"

  # Verify checksum
  echo "Verifying checksum..."
  EXPECTED=$(grep "${ARCHIVE}" "${TMPDIR}/checksums.txt" | awk '{print $1}')
  if [ -z "$EXPECTED" ]; then
    echo "Error: Checksum not found for ${ARCHIVE}"
    exit 1
  fi

  if command -v sha256sum >/dev/null 2>&1; then
    ACTUAL=$(sha256sum "${TMPDIR}/${ARCHIVE}" | awk '{print $1}')
  elif command -v shasum >/dev/null 2>&1; then
    ACTUAL=$(shasum -a 256 "${TMPDIR}/${ARCHIVE}" | awk '{print $1}')
  else
    echo "Warning: No SHA256 tool found, skipping checksum verification"
    ACTUAL="$EXPECTED"
  fi

  if [ "$EXPECTED" != "$ACTUAL" ]; then
    echo "Error: Checksum mismatch"
    echo "  Expected: ${EXPECTED}"
    echo "  Actual:   ${ACTUAL}"
    exit 1
  fi

  # Extract binary
  if [ "$OS" = "windows" ]; then
    unzip -q "${TMPDIR}/${ARCHIVE}" -d "${TMPDIR}/extract"
  else
    mkdir -p "${TMPDIR}/extract"
    tar -xzf "${TMPDIR}/${ARCHIVE}" -C "${TMPDIR}/extract"
  fi

  INSTALL_DIR=$(find_install_dir)
  INSTALL_PATH="${INSTALL_DIR}/${BINARY_NAME}"

  cp "${TMPDIR}/extract/${BINARY_NAME}" "$INSTALL_PATH"
  chmod +x "$INSTALL_PATH"

  echo ""
  echo "${BINARY_NAME} ${LATEST} installed to ${INSTALL_PATH}"

  # Check if install dir is in PATH
  case ":$PATH:" in
    *":${INSTALL_DIR}:"*) ;;
    *)
      echo ""
      echo "NOTE: ${INSTALL_DIR} is not in your PATH."
      echo "Add it by running:"
      echo "  export PATH=\"${INSTALL_DIR}:\$PATH\""
      ;;
  esac

  echo ""
  echo "Run '${BINARY_NAME} --help' to get started."
}

main
