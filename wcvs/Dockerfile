# =============================================================================
# RedAmon - Web Cache Vulnerability Scanner (WCVS) image
# =============================================================================
# Builds Hackmanit's WCVS (https://github.com/Hackmanit/Web-Cache-Vulnerability-Scanner)
# from source. There is no official prebuilt image on a registry, so RedAmon
# builds a local image tagged `redamon-wcvs:latest` and runs it docker-in-docker
# from the recon container (see recon/cache_scan/wcvs_runner.py).
#
# Build:  docker compose --profile tools build wcvs
# Run:    docker run --rm --net=host redamon-wcvs /wcvs -u https://example.com -gr
#
# Pin WCVS_REF to a release tag/commit for reproducible builds.
# -----------------------------------------------------------------------------
FROM golang:1.23-bookworm AS builder
# corp-proxy-start
ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG NO_PROXY=localhost,127.0.0.1
ARG CORP_CERT_B64=""
RUN apt-get update -qq && apt-get install -y --no-install-recommends ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && if [ -n "${CORP_CERT_B64}" ]; then \
         printf '%s' "${CORP_CERT_B64}" | base64 -d \
           > /usr/local/share/ca-certificates/ZscalerRoot.crt; \
       fi \
    && update-ca-certificates
ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt \
    GIT_SSL_CAINFO=/etc/ssl/certs/ca-certificates.crt \
    GONOSUMDB=*
# corp-proxy-end

ARG WCVS_REF=master
RUN git clone https://github.com/Hackmanit/Web-Cache-Vulnerability-Scanner.git /src \
    && cd /src \
    && git checkout "${WCVS_REF}" \
    && CGO_ENABLED=0 go build -o /wcvs .

# -----------------------------------------------------------------------------
FROM debian:bookworm-slim
# corp-proxy-start
ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG NO_PROXY=localhost,127.0.0.1
ARG CORP_CERT_B64=""
RUN apt-get update -qq && apt-get install -y --no-install-recommends ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && if [ -n "${CORP_CERT_B64}" ]; then \
         printf '%s' "${CORP_CERT_B64}" | base64 -d \
           > /usr/local/share/ca-certificates/ZscalerRoot.crt; \
       fi \
    && update-ca-certificates
ENV CURL_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt \
    SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
# corp-proxy-end

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Binary at /wcvs (matches upstream), wordlists relative to WORKDIR so WCVS
# finds its default header/parameter lists without -hw/-pw flags.
COPY --from=builder /wcvs /wcvs
COPY --from=builder /src/wordlists /app/wordlists

ENTRYPOINT ["/wcvs"]
