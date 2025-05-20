FROM registry.gitlab.com/islandoftex/images/texlive:latest

# Install Python and pip
RUN apk add --no-cache python3 py3-pip

# Install FastAPI and Uvicorn
RUN pip install fastapi[standard] python-multipart

# Copy server code into image
COPY server.py /server.py

# Expose port 8080
EXPOSE 8080

# Run FastAPI app
CMD ["uvicorn", "server:app", "--host", "0.0.0.0", "--port", "8080"]
