# prometheus-client-delphi

A prometheus client for Delphi.

## Why use "prometheus"?

Prometheus is a monitoring system for metrics in a modular and language-independent manner. There are various clients for different languages, this repo is meant for Delphi. This repo is loosely based on the NodeJS version https://github.com/siimon/prom-client

Metrics that are added in your own software are kept internally and - instead of what other monitoring systems require - it doesn't actually send anything until a different system requests the data.

You can use this in combination with for example the Grafana Agent to scrape the metrics from your software regularly, and in turn the agent will make sure it is sent to the Grafana server.

This has the advantage of not having to write code to actively send the metrics to whatever service, you can leave that to someone else.


## Keeping metrics

To start keeping metrics, you can use the helper class functions in `Prometheus.Client.pas`

```
    var ClientGauge := TPrometheusClient.NewGauge(
      'cache_usage',
      'Total bytes of cache used',
      ['type', 'name']
    );

    var ClientCounter := TPrometheusClient.NewCounter(
      'cache_put_total',
      'Total number of cache puts',
      ['type', 'name']
    );

    ClientCounter.Inc(['type=memory', 'name=default'], 2);
    ClientCounter.Inc(['type=disk', 'name=pizza'], 3);
    ClientCounter.Inc(['type=disk', 'name=pizza'], 1);

    ClientGauge.SetTo(['type=disk', 'name=pizza'], 7);
```

These metrics are stored globally for your application, so make sure your metric names are unique.


## Serving the metrics

Using the `Prometheus.Server.pas` you can easily setup a simple http server to serve the metrics on.

```
    TPrometheusServer.Create(12401);
```

This will listen to the TCP port 12401 and create a simple HTTP service that offers the URL `/metrics` for scrapers (i.e. Grafana Agent)


## Adding a scraper to your Grafana configuration

To `agent-config.yaml` in the Grafana Agent directory, add a new config under `metrics.configs`.

```
metrics:
  ...
  global:
    scrape_interval: 1m
  configs:
    - name: agent
      scrape_configs:
        - job_name: mysoftware
          static_configs:
            - targets: [ 'localhost:12401' ]
              labels:
                agent_hostname: 'MyServerName'
      remote_write:
        - basic_auth:
            password: password
            username: username
          url: https://prometheus-prod-01-eu-west-0.grafana.net/api/prom/push
```

Change the scrape_interval to an appropriate value. You can change this to seconds even if for example your metrics fluctuate often and you want to see those in Grafana.
