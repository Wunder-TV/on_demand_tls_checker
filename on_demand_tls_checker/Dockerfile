FROM golang:latest AS builder

WORKDIR /app

# copy all your .go source files
# (or use a .dockerignore and COPY . .)
COPY *.go .

# remove any previously initialized go.mod and go.sum files
# (this is in case the container data wasn't destroyed)
RUN rm -f go.mod rm go.sum

# initialize Go modules
RUN go mod init app

# fetch dependencies
RUN go mod tidy

# Build the binary
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o on_demand_tls_checker .

# Stage 2: Create a minimal container
FROM scratch

# Expose port 8080
EXPOSE 8080

# Copy the binary from the builder stage
COPY --from=builder /app/on_demand_tls_checker /on_demand_tls_checker

# Command to run the server
CMD ["/on_demand_tls_checker"]
