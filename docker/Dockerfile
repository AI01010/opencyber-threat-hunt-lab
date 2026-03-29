# docker/Dockerfile
#
# NOTE: This image is large (~2 GB) due to Splunk Enterprise.
# Students should pull the pre-built image from ghcr.io rather than building locally.
#
# Unlike the opencyber-splunk-lab, NO data is pre-loaded here.
# Uploading threat intelligence data into Splunk is a core learning objective of this lab.
#
FROM --platform=linux/amd64 ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# 1. Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends wget ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# 2. Download and install Splunk Enterprise
#    Splunk Enterprise has no arm64 package — amd64 runs under Rosetta 2 on Apple Silicon.
ARG SPLUNK_VERSION=9.0.4.1
ARG SPLUNK_BUILD=419ad9369127
RUN wget -qO /tmp/splunk.deb \
      "https://download.splunk.com/products/splunk/releases/${SPLUNK_VERSION}/linux/splunk-${SPLUNK_VERSION}-${SPLUNK_BUILD}-linux-2.6-amd64.deb" && \
    dpkg -i /tmp/splunk.deb && \
    rm /tmp/splunk.deb

# 3. Configure admin credentials and Free license.
#    Both are written to /opt/splunk/etc/system/local/ at build time so they
#    are baked into the image and apply on every container start without
#    requiring a runtime restart or a named-volume-persisted sentinel.
RUN printf '[user_info]\nUSERNAME = admin\nPASSWORD = codepath\n' \
      > /opt/splunk/etc/system/local/user-seed.conf && \
    printf '[license]\nactive_group = Free\n' \
      > /opt/splunk/etc/system/local/server.conf

EXPOSE 8000

COPY --chmod=755 docker/entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
