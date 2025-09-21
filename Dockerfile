ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:12.6.0
FROM ${BUILD_FROM}

LABEL maintainer="you@example.com"
ENV PYTHONUNBUFFERED=1

# Install runtime dependencies: python3, pip, su-exec, curl, yq, tini
RUN apk add --no-cache \
    python3 \
    py3-pip \
    su-exec \
    curl \
    jq \
    bash \
    yq \
    tini \
  && python3 -m ensurepip \
  && pip3 install --no-cache-dir --upgrade pip setuptools

# Create dedicated user
RUN addgroup -S searx && adduser -S -G searx searx

# Create paths
RUN mkdir -p /opt/searxng /etc/searxng /var/lib/searxng /share/searxng \
  && chown -R searx:searx /opt/searxng /etc/searxng /var/lib/searxng /share/searxng

# Copy files
COPY run.sh /run.sh
COPY default_searxng_settings.yml /etc/searxng/settings.yml
COPY entrypoint.sh /entrypoint.sh
COPY logo.png /logo.png

RUN chmod +x /run.sh /entrypoint.sh

# Preinstall recommended python wheels to speed startup (will install final searxng later)
# Note: final SearxNG version installed at runtime according to options to keep image small.
RUN pip3 install --no-cache-dir wheel

EXPOSE 8080

ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]
CMD ["/run.sh"]
