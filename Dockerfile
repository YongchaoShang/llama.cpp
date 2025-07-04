# Use ARM64 Ubuntu base image
FROM ubuntu:22.04

# Install build tools and libcurl dev headers
RUN apt-get update && \
    apt-get install -y git build-essential cmake libcurl4-openssl-dev && \
    rm -rf /var/lib/apt/lists/*

# Define user and group IDs to match host user
ARG UID=1003
ARG GID=1008

# Create a non-root user with specific UID and GID
RUN addgroup --gid ${GID} appgroup && \
    adduser --uid ${UID} --gid ${GID} --disabled-password --gecos "" appuser

# Create working directory
WORKDIR /app

# Copy llama.cpp source code to the container
COPY . .

# Build llama.cpp using CMake and build the server binary
RUN cmake -B build && \
    cmake --build build --config Release -t llama-server -j 4 && \
    cp build/bin/llama-server /app/llama-server

# Fix ownership so the non-root user can access the files
RUN chown -R appuser:appgroup /app

# Expose the server port
EXPOSE 8080

# Switch to the non-root user
USER appuser

# Set default command: run the server binary
ENTRYPOINT ["./llama-server"]

