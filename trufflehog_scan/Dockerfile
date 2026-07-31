# =============================================================================
# RedAmon TruffleHog Secret Scanner - Container
# =============================================================================
# This container runs TruffleHog deep secret scanning with 700+ detectors
# and optional credential verification against live APIs.
# =============================================================================

FROM python:3.12-slim

# corp-proxy-start — remove this block when building outside the corporate network
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
ENV PIP_CERT=/etc/ssl/certs/ca-certificates.crt \
    REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt \
    CURL_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt \
    SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt \
    GIT_SSL_CAINFO=/etc/ssl/certs/ca-certificates.crt
# corp-proxy-end

LABEL maintainer="RedAmon Project"
LABEL description="TruffleHog-based secret scanner for RedAmon"

# Set working directory
WORKDIR /app

# Install git (required by TruffleHog for repo scanning) + TruffleHog Go binary
RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates git && \
    curl -sSfL https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/scripts/install.sh | sh -s -- -b /usr/local/bin && \
    apt-get purge -y curl && apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY trufflehog_scan/requirements.txt /tmp/trufflehog_requirements.txt
RUN pip install --no-cache-dir -r /tmp/trufflehog_requirements.txt

# Copy project files (context is parent directory, so paths are relative to project root)
COPY trufflehog_scan/ ./trufflehog_scan/

# Copy graph_db module (for Neo4j integration)
COPY graph_db/ ./graph_db/

# Create output directories
RUN mkdir -p trufflehog_scan/output

# Set Python path and ensure unbuffered output for log streaming
ENV PYTHONPATH=/app
ENV PYTHONUNBUFFERED=1

# Default command
CMD ["python", "trufflehog_scan/main.py"]
