FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV TEXLIVE_VERSION=2025

# Install dependencies
RUN apt-get update && apt-get install -y \
    perl \
    wget \
    xz-utils \
    fontconfig \
    && rm -rf /var/lib/apt/lists/*

# Install TeX Live
WORKDIR /tmp
RUN wget https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz \
    && tar -xzf install-tl-unx.tar.gz \
    && cd install-tl-* \
    && perl ./install-tl --no-interaction --scheme=small \
    && cd /tmp && rm -rf install-tl*

# Set working directory for document compilation
WORKDIR /workspace

# Copy your test file
COPY test.tex .

# Set entrypoint script to dynamically resolve arch and run pdflatex
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
