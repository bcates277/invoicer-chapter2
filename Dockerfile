# Stage 1: Build the Go app
FROM golang:1.22 as builder

WORKDIR /app

# Copy Go module files and download dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy the source code
COPY . .

# Build the Go binary
RUN CGO_ENABLED=0 GOOS=linux go build -o invoicer ./cmd/invoicer

# Stage 2: Create minimal image
FROM gcr.io/distroless/static:nonroot

WORKDIR /app

# Copy only the compiled Go binary from builder
COPY --from=builder /app/invoicer .

# Static assets (if needed)
COPY --from=builder /app/statics ./statics

# Reports folder if needed
RUN mkdir /app/reports

USER nonroot

EXPOSE 8080
ENTRYPOINT ["/app/invoicer"]
