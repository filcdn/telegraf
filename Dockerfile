FROM telegraf:1.36

# Install additional dependencies
RUN apt-get update && apt-get install -y --no-install-recommends jq

# Copy our source code & config files
COPY telegraf.conf /etc/telegraf/telegraf.conf
COPY probes /opt/probes
