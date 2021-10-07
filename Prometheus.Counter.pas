unit Prometheus.Counter;

interface

uses
  Prometheus.Interfaces,
  System.Generics.Collections,
  System.SyncObjs;

type
  TPrometheusCounter = class(TInterfacedObject, IPrometheusCounter)
  private
    FLock: TCriticalSection;
    FLabelNames: TList<string>;
    FHelpText: string;
    FMetricName: string;

    FCounters: TDictionary<string, Double>;

    function GetLabelsString(const Labels: TArray<string>): string;
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

  FLabelNames := TList<string>.Create;
  FLabelNames.AddRange(LabelNames);

  FCounters := TDictionary<string, Double>.Create;

  FLock := TCriticalSection.Create;
end;

function TPrometheusCounter.GetLabelsString(const Labels: TArray<string>): string;
var
  DicLabels: TDictionary<string, string>;
  Key: string;
  KeyVal: string;
  EqualsSign: Integer;
begin
  if Length(Labels) = 0 then
  begin
    Result := 'default';
    Exit;
  end;

  DicLabels := TDictionary<string, string>.Create;
  try
    for Key in FLabelNames do
      DicLabels.Add(Key, '');

    for KeyVal in Labels do
    begin
      EqualsSign := Pos('=', KeyVal);
      Key := Copy(KeyVal, 1, EqualsSign - 1);
      if DicLabels.ContainsKey(Key) then
        DicLabels[Key] := Copy(KeyVal, EqualsSign + 1);
    end;

    Result := TPrometheusUtils.LabelsToString(DicLabels);
  finally
    DicLabels.Free;
  end;
end;

procedure TPrometheusCounter.Inc(const Labels: TArray<string>; const Value: Double);
var
  Key: string;
  CurrentValue: Double;
begin
  Key := GetLabelsString(Labels);

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
  Result := Result + Format('# TYPE %s %s'#10, [FMetricName, 'counter']);
  Result := Result + ToMetricsString;
end;

end.
