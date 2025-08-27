# telegraf

Telegraf instance probing our systems and writing metrics to InfluxDB for monitoring in Grafana.

## Architecture

Our Telegraf instance runs probes against two environments:

- **Calibration**: Our testing/staging environment
- **Mainnet**: Our production environment

The same set of probes are executed for both environments, but the metrics are written to separate InfluxDB buckets:

- Calibration metrics → `telegraf-calibration` bucket
- Mainnet metrics → `telegraf-mainnet` bucket

This architecture allows us to:

- Monitor both environments with identical probe configurations
- Keep metrics isolated between environments
- Maintain separate retention policies and access controls per environment

The probes collect various system metrics and performance data, which are then visualized in Grafana dashboards that connect to the respective InfluxDB buckets.

## Development

Obtain the secrets and create a `.env` file with the following variables:

```
export CLOUDFLARE_ACCOUNT_ID="375...88f"
export CLOUDFLARE_API_KEY="secret-key"
export CLOUDFLARE_CALIBRATION_DB_ID="8cc9...f103"
export CLOUDFLARE_MAINNET_DB_ID="e8de...9a66"
```

Load the environment variables at the beginning of your terminal session:

```sh
source .env
```

Build the Docker image:

```sh
docker build -t filcdn/telegraf .
```

Run Telegraf in a Docker container in the dry-run mode:

```sh
./dry-run.sh
```

_Note: you don't have to rebuild the image after changing `telegraf.conf` or files in the `probes/` directory._

### Resources

- [Telegraf](https://www.influxdata.com/time-series-platform/telegraf/)
- [HTTP](https://github.com/influxdata/telegraf/tree/master/plugins/inputs/http)

## Deployment

We have a CI/CD pipeline that automatically deploys all commits to the `main` branch to Fly.io.
