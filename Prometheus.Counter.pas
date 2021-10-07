unit Prometheus.Counter;

interface

uses
  Prometheus.Interfaces,
  System.Generics.Collections,
  System.SyncObjs;

type
  TPrometheusCounter = class(TInterfacedObject, IPrometheusCounter)
  protected
    FLock: TCriticalSection;
    FLabelNames: TList<string>;
    FHelpText: string;
    FMetricName: string;
    FMetricTypeName: string;

    FCounters: TDictionary<string, Double>;

    function ToMetricsString: string;
  public
    constructor Create(const MetricName: string; const HelpText: string; const LabelNames: TArray<string>);

    procedure Inc(const Value: Double); overload;
    procedure Inc(const Labels: TArray<string>; const Value: Double); overload;

    function ToString: string; override;
  end;

implementation

uses
  System.SysUtils,
  System.StrUtils,
  Prometheus.Utils;

{ TPrometheusClientCounter }

constructor TPrometheusCounter.Create(const MetricName: string; const HelpText: string; const LabelNames: TArray<string>);
begin
  FMetricName := MetricName;
  FHelpText := HelpText;
  FMetricTypeName := 'counter';

  FLabelNames := TList<string>.Create;
  FLabelNames.AddRange(LabelNames);

  FCounters := TDictionary<string, Double>.Create;

  FLock := TCriticalSection.Create;
end;

procedure TPrometheusCounter.Inc(const Labels: TArray<string>; const Value: Double);
var
  Key: string;
  CurrentValue: Double;
begin
  Key := TPrometheusUtils.GetLabelsString(FLabelNames, Labels);

  FLock.Acquire;
  try
    if FCounters.TryGetValue(Key, CurrentValue) then
      FCounters[Key] := CurrentValue + Value
    else
      FCounters.AddOrSetValue(Key, Value);
  finally
    FLock.Release;
  end;
end;

procedure TPrometheusCounter.Inc(const Value: Double);
begin
  Inc([], Value);
end;

function TPrometheusCounter.ToMetricsString: string;
var
  Counter: TPair<string, Double>;
begin
  Result := '';

  for Counter in FCounters do
  begin
    if Counter.Key = 'default' then
    begin
      Result := Result + FMetricName + ' ' + TPrometheusUtils.CountMetricToString(Counter.Value) + #10;
    end
    else
    begin
      Result := Result + FMetricName + Counter.Key + ' ' + TPrometheusUtils.CountMetricToString(Counter.Value) + #10;
    end;
  end;
end;

function TPrometheusCounter.ToString: string;
begin
  Result := Format('# HELP %s %s'#10, [FMetricName, FHelpText]);
  Result := Result + Format('# TYPE %s %s'#10, [FMetricName, FMetricTypeName]);
  Result := Result + ToMetricsString;
end;

end.
