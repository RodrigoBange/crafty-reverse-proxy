# Dockerfile
# ─────────────────────────────────────────────────────
# 1) Build stage: compile the Go binary
FROM golang:1.24-alpine AS builder
WORKDIR /craftyproxy

# Fetch dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy source and build
COPY . .
ENV CGO_ENABLED=0 GOOS=linux
RUN go build -ldflags="-s -w" -o /craftyproxy/main cmd/reverse-proxy/main.go

# 2) Runtime stage: minimal Alpine image
FROM alpine:3.21
WORKDIR /craftyproxy

# Copy and install the custom certificate authority
COPY certs/commander.cert.pem /usr/local/share/ca-certificates/crafty.crt
RUN apk add --no-cache ca-certificates && update-ca-certificates

# Copy the compiled binary
COPY --from=builder /craftyproxy/main .

# Copy the configuration file into the image
COPY config/config.yaml ./config/config.yaml

# (Optional) document the ports the proxy listens on
# EXPOSE 25565 25566

# Run the proxy, pointing at the embedded config
ENTRYPOINT ["/craftyproxy/main", "-c", "/craftyproxy/config/config.yaml"]
