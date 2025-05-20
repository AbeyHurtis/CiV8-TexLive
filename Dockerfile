FROM debian:bullseye-slim

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV TEXLIVE_VERSION=2025
ENV PATH=/usr/local/texlive/${TEXLIVE_VERSION}/bin/x86_64-linux:$PATH

# Install dependencies
RUN apt-get update && apt-get install -y \
    perl \
    wget \
    xz-utils \
    fontconfig \
    && rm -rf /var/lib/apt/lists/*

# Download and install TeX Live
WORKDIR /tmp
RUN wget https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz \
    && tar -xzf install-tl-unx.tar.gz \
    && cd install-tl-* \
    && perl ./install-tl --no-interaction --scheme=small \
    && cd /tmp && rm -rf install-tl*

# Set working directory for LaTeX compilation
WORKDIR /workspace

# Simple test document
COPY test.tex .

# Command to compile LaTeX document to PDF
CMD ["sh", "-c", "pdflatex test.tex && ls -lh *.pdf"]
