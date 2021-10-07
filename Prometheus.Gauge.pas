unit Prometheus.Gauge;

interface

uses
  Prometheus.Interfaces,
  Prometheus.Counter;

type
  TPrometheusGauge = class(TPrometheusCounter, IPrometheusGauge)
  public
    constructor Create(const MetricName: string; const HelpText: string; const LabelNames: TArray<string>);

    procedure SetTo(const Value: Double); overload;
    procedure SetTo(const Labels: TArray<string>; const Value: Double); overload;

    procedure Dec(const Value: Double); overload;
    procedure Dec(const Labels: TArray<string>; const Value: Double); overload;
  end;

implementation

uses
  Prometheus.Utils;

{ TPrometheusGauge }

constructor TPrometheusGauge.Create(const MetricName, HelpText: string; const LabelNames: TArray<string>);
begin
  inherited Create(MetricName, HelpText, LabelNames);

  FMetricTypeName := 'gauge';
end;

procedure TPrometheusGauge.Dec(const Value: Double);
begin
  Dec([], Value);
end;

procedure TPrometheusGauge.Dec(const Labels: TArray<string>; const Value: Double);
var
  Key: string;
  CurrentValue: Double;
begin
  Key := TPrometheusUtils.GetLabelsString(FLabelNames, Labels);

  FLock.Acquire;
  try
    if FCounters.TryGetValue(Key, CurrentValue) then
      FCounters[Key] := CurrentValue - Value
    else
      FCounters.AddOrSetValue(Key, -Value);
  finally
    FLock.Release;
  end;
end;

procedure TPrometheusGauge.SetTo(const Value: Double);
begin
  SetTo([], Value);
end;

procedure TPrometheusGauge.SetTo(const Labels: TArray<string>; const Value: Double);
var
  Key: string;
  CurrentValue: Double;
begin
  Key := TPrometheusUtils.GetLabelsString(FLabelNames, Labels);

  FLock.Acquire;
  try
    if FCounters.TryGetValue(Key, CurrentValue) then
      FCounters[Key] := Value
    else
      FCounters.AddOrSetValue(Key, Value);
  finally
    FLock.Release;
  end;
end;

end.
