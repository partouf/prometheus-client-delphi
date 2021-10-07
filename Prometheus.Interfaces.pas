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

implementation

end.
