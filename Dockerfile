# syntax=docker/dockerfile:1

# Step 1: Build the Go binary
FROM golang:1.22 AS builder

# Set working directory inside builder container
WORKDIR /app

# Copy go mod files and download dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of your app source code
COPY . .

# Build the Go app
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o invoicer

# Step 2: Create a minimal final image
FROM gcr.io/distroless/static:nonroot

# Set working directory inside final image
WORKDIR /tmp

# Copy the binary from the builder stage
# --chown makes sure the file is owned by nonroot user
COPY --chown=nonroot:nonroot --from=builder /app/invoicer /tmp/invoicer

# Expose the port the app will listen on (e.g., 8080)
EXPOSE 8080

# Health check to ensure the app is running
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD curl --fail http://localhost:8080/health || exit 1

# Set the user to nonroot (optional, because static:nonroot expects it)
USER nonroot

# Run the binary
ENTRYPOINT ["/tmp/invoicer"]
