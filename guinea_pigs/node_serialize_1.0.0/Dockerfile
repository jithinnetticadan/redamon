# Vulnerable Node.js server with node-serialize for CVE-2017-5941 testing
# WARNING: This is intentionally vulnerable - DO NOT use in production!

FROM node:8.17.0-slim

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
ENV NODE_EXTRA_CA_CERTS=/etc/ssl/certs/ca-certificates.crt \
    NPM_CONFIG_CAFILE=/etc/ssl/certs/ca-certificates.crt \
    NPM_CONFIG_PROXY=${HTTP_PROXY} \
    NPM_CONFIG_HTTPS_PROXY=${HTTPS_PROXY}
# corp-proxy-end

# Set unbuffered output for logging
ENV PYTHONUNBUFFERED=1
ENV NODE_ENV=production

WORKDIR /app

# Copy package files first for layer caching
COPY package.json ./

# Install dependencies (including vulnerable node-serialize 0.0.4)
RUN npm install --production 2>&1

# Copy application code
COPY server.js ./
COPY www/ ./www/

# Run as root so RCE gives root shell
# This is intentionally insecure for testing purposes

EXPOSE 3000

CMD ["node", "server.js"]
