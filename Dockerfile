FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV TEXLIVE_VERSION=2025
ENV TEXLIVE_INSTALL_PATH=/usr/local/texlive
ENV PATH=$TEXLIVE_INSTALL_PATH/${TEXLIVE_VERSION}/bin/x86_64-linux:$PATH

# Install required packages
RUN apt-get update && apt-get install -y \
    perl \
    wget \
    xz-utils \
    fontconfig \
    && rm -rf /var/lib/apt/lists/*

# Download and install TeX Live (small scheme)
WORKDIR /tmp
RUN wget https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz \
    && tar -xzf install-tl-unx.tar.gz \
    && cd install-tl-* \
    && ./install-tl --no-interaction --scheme=small \
    && cd /tmp \
    && rm -rf install-tl* install-tl-unx.tar.gz

# Copy test document and set working directory
WORKDIR /workspace
COPY test.tex .

# Compile LaTeX on container start
CMD ["sh", "-c", "pdflatex test.tex && ls -lh *.pdf"]
