unit Prometheus.Server;

interface

uses
  IdHttpServer,
  IdCustomHTTPServer,
  IdContext;

type
  TPrometheusServer = class
  protected
    FHttpServer: TIdHTTPServer;

    procedure OnCommandGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
  public
    constructor Create(const Port: Integer);
    destructor Destroy; override;
  end;

implementation

uses
  System.Generics.Collections,
  Prometheus.Interfaces,
  Prometheus.Client;

{ TPrometheusServer }

constructor TPrometheusServer.Create(const Port: Integer);
begin
  FHttpServer := TIdHTTPServer.Create(nil);
  FHttpServer.DefaultPort := Port;
  FHttpServer.OnCommandGet := OnCommandGet;
  FHttpServer.Active := True;
end;

destructor TPrometheusServer.Destroy;
begin
  FHttpServer.Active := False;

  inherited;
end;

procedure TPrometheusServer.OnCommandGet(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  Metrics: TList<IPrometheusMetric>;
  Metric: IPrometheusMetric;
begin
  if (ARequestInfo.Command = 'GET') and (ARequestInfo.URI = '/metrics') then
  begin
    Metrics := TPrometheusClient.ListMetrics;

    AResponseInfo.ResponseNo := 200;
    AResponseInfo.ContentType := 'text/plain; version=0.0.4';
    AResponseInfo.ContentText := '';

    for Metric in Metrics do
    begin
      AResponseInfo.ContentText :=
        AResponseInfo.ContentText +
        Metric.ToString + #10;
    end;
  end
  else
  begin
    AResponseInfo.ResponseNo := 404;
  end;
end;

end.
