FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV TEXLIVE_VERSION=2025
ENV TEXLIVE_DIR=/usr/local/texlive
ENV TEXLIVE_BIN=$TEXLIVE_DIR/${TEXLIVE_VERSION}/bin/x86_64-linux

# Install required packages
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
    && ./install-tl --no-interaction --scheme=small \
    && cd /tmp && rm -rf install-tl*

# Create symlink to pdflatex in a standard path (OPTIONAL but useful)
RUN ln -s $TEXLIVE_BIN/pdflatex /usr/local/bin/pdflatex

# Copy the LaTeX document
WORKDIR /workspace
COPY test.tex .

# Compile LaTeX on container start, exporting path explicitly (if no symlink is used)
CMD ["sh", "-c", "export PATH=$TEXLIVE_BIN:$PATH && pdflatex test.tex && ls -lh *.pdf"]
