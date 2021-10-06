unit Prometheus.Interfaces;

interface

uses
  System.Generics.Collections;

type
  IPrometheusCounter = interface
    ['{4956C817-A7A8-4ABC-A5CB-B34DC38F356C}']

    procedure Inc(const Value: Double); overload;
    procedure Inc(const Labels: TArray<string>; const Value: Double); overload;

    function ToString: string;
  end;

implementation

end.
