unit Prometheus.Client;

interface

uses
  Prometheus.Interfaces,
  System.Generics.Collections;

type
  TPrometheusClient = class
  public
    class function NewCounter(const MetricName: string; const HelpText: string; const LabelNames: TArray<string>): IPrometheusCounter;
    class function NewGauge(const MetricName: string; const HelpText: string; const LabelNames: TArray<string>): IPrometheusGauge;

    class function ListMetrics: TList<IPrometheusMetric>;
  end;

implementation

uses
  Prometheus.Counter,
  Prometheus.Gauge,
  System.SysUtils;

var
  _Metrics: TList<IPrometheusMetric>;

{ TPrometheusClient }

class function TPrometheusClient.NewCounter(const MetricName: string; const HelpText: string; const LabelNames: TArray<string>): IPrometheusCounter;
begin
  Result := TPrometheusCounter.Create(MetricName, HelpText, LabelNames);
  _Metrics.Add(Result);
end;

class function TPrometheusClient.NewGauge(const MetricName, HelpText: string; const LabelNames: TArray<string>): IPrometheusGauge;
begin
  Result := TPrometheusGauge.Create(MetricName, HelpText, LabelNames);
  _Metrics.Add(Result);
end;

class function TPrometheusClient.ListMetrics: TList<IPrometheusMetric>;
begin
  Result := _Metrics;
end;

initialization
  _Metrics := TList<IPrometheusMetric>.Create;

finalization
  FreeAndNil(_Metrics);

end.
