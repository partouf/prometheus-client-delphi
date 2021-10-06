unit Prometheus.Utils;

interface

uses
  System.Generics.Collections;

type
  TPrometheusUtils = class
  public
    class function EscapeLabelValue(const Value: string): string;
    class function LabelsToString(const Labels: TDictionary<string, string>): string;

    class function CountMetricToString(const Value: Double): string;
  end;

implementation

uses
  System.SysUtils;

{ TPrometheusUtils }

class function TPrometheusUtils.EscapeLabelValue(const Value: string): string;
begin
  Result := Value;
  Result := Result.Replace('\', '\\');
  Result := Result.Replace('"', '\"');
  Result := Result.Replace(#13#10, '\n');
  Result := Result.Replace(#10, '\n');
end;

class function TPrometheusUtils.LabelsToString(const Labels: TDictionary<string, string>): string;
var
  FirstLabel: Boolean;
  Lbl: TPair<string, string>;
begin
  Result := '';

  if Labels.Count <> 0 then
  begin
    Result := Result + '{';

    FirstLabel := True;
    for Lbl in Labels do
    begin
      if FirstLabel then
        FirstLabel := False
      else
        Result := Result + ',';

      Result := Result + Format('%s="%s"', [lbl.Key, EscapeLabelValue(lbl.Value)]);
    end;

    Result := Result + '}';
  end;
end;

class function TPrometheusUtils.CountMetricToString(const Value: Double): string;
var
  FormatSettings: TFormatSettings;
begin
  FormatSettings.DecimalSeparator := '.';
  FormatSettings.ThousandSeparator := #0;

  Result := Value.ToString(FormatSettings);
end;

end.
