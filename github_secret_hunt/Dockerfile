# =============================================================================
# RedAmon GitHub Secret Hunter - Python Container
# =============================================================================
# This container runs the GitHub secret scanning tool, searching for
# exposed secrets, API keys, and credentials in GitHub repositories.
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
LABEL description="Python-based GitHub secret hunter for RedAmon"

# Set working directory
WORKDIR /app

# Install dependencies
COPY github_secret_hunt/requirements.txt /tmp/github_requirements.txt
RUN pip install --no-cache-dir -r /tmp/github_requirements.txt

# Copy project files (context is parent directory, so paths are relative to project root)
COPY github_secret_hunt/ ./github_secret_hunt/

# Copy graph_db module (for Neo4j integration)
COPY graph_db/ ./graph_db/

# Create output directories
RUN mkdir -p github_secret_hunt/output

# Set Python path and ensure unbuffered output for log streaming
ENV PYTHONPATH=/app
ENV PYTHONUNBUFFERED=1

# Default command
CMD ["python", "github_secret_hunt/main.py"]
