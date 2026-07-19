FROM golang:1.21-alpine AS api
WORKDIR /app
COPY api/server.go .
RUN go build -o server_bin server.go

FROM gcc:latest AS engine
WORKDIR /app
COPY Makefile .
COPY engine/ engine/
RUN make otter-engine

FROM alpine:latest
RUN apk add --no-cache python3 bash curl
COPY --from=api /app/server_bin /usr/local/bin/otter-api
COPY --from=engine /app/otter-engine /usr/local/bin/
COPY scripts/install.sh /app/
COPY assets/logo.png /app/
CMD ["/usr/local/bin/otter-api"]
