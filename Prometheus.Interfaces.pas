unit Prometheus.Interfaces;

interface

uses
  System.Generics.Collections;

type
  IPrometheusMetric = interface
    ['{00B96708-170E-49E1-8264-38FDB86AF659}']

    function ToString: string;
  end;

  IPrometheusCounter = interface(IPrometheusMetric)
    ['{4956C817-A7A8-4ABC-A5CB-B34DC38F356C}']

    procedure Inc(const Value: Double); overload;
    procedure Inc(const Labels: TArray<string>; const Value: Double); overload;
  end;

  IPrometheusGauge = interface(IPrometheusCounter)
    ['{3761F3E6-E7C3-4186-9C07-F434C884305B}']

    procedure SetTo(const Value: Double); overload;
    procedure SetTo(const Labels: TArray<string>; const Value: Double); overload;

    procedure Dec(const Value: Double); overload;
    procedure Dec(const Labels: TArray<string>; const Value: Double); overload;
  end;

implementation

end.
