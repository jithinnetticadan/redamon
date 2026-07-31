# =============================================================================
# RedAmon Vulnerability Scanner - Python Container
# =============================================================================
# This container runs the GVM Python scanner script, connecting to gvmd
# via Unix socket to create and execute vulnerability scans.
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
    SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
# corp-proxy-end

LABEL maintainer="RedAmon Project"
LABEL description="Python-based GVM vulnerability scanner for RedAmon"

# Set working directory
WORKDIR /app

# Install dependencies (python-gvm for scanner, neo4j for graph updates)
COPY gvm_scan/requirements.txt /tmp/gvm_requirements.txt
RUN pip install --no-cache-dir -r /tmp/gvm_requirements.txt && \
    pip install --no-cache-dir neo4j

# Copy project files (context is parent directory, so paths are relative to project root)
COPY gvm_scan/ ./gvm_scan/
COPY graph_db/ ./graph_db/

# Create output directories
RUN mkdir -p gvm_scan/output recon/output

# Set Python path and ensure unbuffered output for log streaming
ENV PYTHONPATH=/app
ENV PYTHONUNBUFFERED=1

# Default command
CMD ["python", "gvm_scan/main.py"]
