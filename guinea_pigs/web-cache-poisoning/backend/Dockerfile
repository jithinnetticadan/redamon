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

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py .

ENV PYTHONUNBUFFERED=1
EXPOSE 5000
# gunicorn would be more production-like, but Flask's dev server keeps the demo
# single-dependency and logs every request, which is what we want for tracing.
CMD ["python", "app.py"]
