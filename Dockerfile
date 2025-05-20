FROM registry.gitlab.com/islandoftex/images/texlive:latest

# Install Python and pip
RUN apt-get update && \
    apt-get install -y python3 python3-pip && \
    apt-get clean

# Install FastAPI and Uvicorn
RUN pip3 install fastapi[standard] python-multipart

# Copy server code into image
COPY server.py /server.py

# Expose port 8080
EXPOSE 8080

# Run FastAPI app
CMD ["uvicorn", "server:app", "--host", "0.0.0.0", "--port", "8080"]
