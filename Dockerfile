FROM debian:bullseye-slim

# Install texlive + python
RUN apt-get update && \
    apt-get install -y texlive-latex-base texlive-latex-extra texlive-fonts-recommended \
    python3 python3-pip && \
    rm -rf /var/lib/apt/lists/*

# Install FastAPI & Uvicorn
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

COPY app.py .

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
