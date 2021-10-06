program example;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Generics.Collections,
  System.Generics.Defaults,
  Prometheus.Interfaces in '..\Prometheus.Interfaces.pas',
  Prometheus.Client in '..\Prometheus.Client.pas',
  Prometheus.Utils in '..\Prometheus.Utils.pas';

begin
  try
    var ClientCounter := TPrometheusClient.NewCounter(
      'cache_put_total',
      'Total number of cache puts',
      ['type', 'name']
    );

    ClientCounter.Inc(['type=memory', 'name=default'], 2);
    ClientCounter.Inc(['type=disk', 'name=pizza'], 3);

    Writeln(ClientCounter.ToString);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
