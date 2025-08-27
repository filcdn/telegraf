#!/usr/bin/env bash

docker run -it --rm \
  -e CLOUDFLARE_ACCOUNT_ID \
  -e CLOUDFLARE_API_KEY \
  -e CLOUDFLARE_CALIBRATION_DB_ID\
  -e CLOUDFLARE_MAINNET_DB_ID\
  -e INFLUX_TOKEN\
  -v $(pwd)/telegraf.conf:/etc/telegraf/telegraf.conf:ro \
  -v $(pwd)/probes:/opt/probes:ro \
  filcdn/telegraf \
  /usr/bin/telegraf --test --debug
