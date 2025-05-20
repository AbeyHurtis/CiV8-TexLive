#!/bin/sh

# Detect platform-specific bin path
ARCH=$(uname -m)

case "$ARCH" in
    x86_64)
        BIN_PATH="/usr/local/texlive/2025/bin/x86_64-linux"
        ;;
    aarch64 | arm64)
        BIN_PATH="/usr/local/texlive/2025/bin/aarch64-linux"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

export PATH="$BIN_PATH:$PATH"

# Compile the LaTeX file
pdflatex test.tex && ls -lh *.pdf
