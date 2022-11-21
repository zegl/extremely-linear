FROM golang:1.19 AS builder
RUN apt-get update && apt-get install -y git
RUN git clone https://github.com/zegl/githashcrash.git /src/githashcrash
WORKDIR /src/githashcrash
RUN CGO_ENABLED=0 go build -o "githashcrash" "./cmd/githashcrash"

FROM debian:latest AS runner
RUN apt-get update && apt-get install -y git
COPY --from=builder "/src/githashcrash/githashcrash" "/githashcrash"
WORKDIR /repo
ENTRYPOINT [ "/githashcrash" ]
