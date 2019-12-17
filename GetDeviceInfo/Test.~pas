unit Test;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, InvokeRegistry, StdCtrls, Rio, SOAPHTTPClient, DB, DBClient,
  SOAPConn;

type
  TForm1 = class(TForm)
    HTTPRIO1: THTTPRIO;
    Button1: TButton;
    SoapConnection1: TSoapConnection;
    procedure Button1Click(Sender: TObject);
    procedure HTTPRIO1BeforeExecute(const MethodName: String;
      var SOAPRequest: WideString);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  s:string;

implementation

uses DBClientSvc;

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
  s:=(HTTPRIO1 as DBClientSvcSoap).SendMonitorInfo('PROKUSHEVSV', '', '', 'Test', '', 1, 1,'','', '',
                              0, '', '', 'Test', '', 1, 1, '', '',
                              '', '', '', '');
  Application. MessageBox(PChar(s),'Look', MB_OK);


end;

procedure TForm1.HTTPRIO1BeforeExecute(const MethodName: String;
  var SOAPRequest: WideString);
var s:WideString;
begin
  s:=
  '<?xml version="1.0" encoding="utf-8"?>'+
  '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">'+
  '<soap:Body>'+
  '<SendMonitorInfo xmlns="http://kmiportal1.corp.lukoil.com/DBClient">'+
  '<NETBIOS_NAME>PROKUSHEVSV</NETBIOS_NAME>'+
  '<ADAPTER_DEVICE_ID></ADAPTER_DEVICE_ID>'+
  '<ADAPTER_REGISTRY_KEY></ADAPTER_REGISTRY_KEY>'+
  '<ADAPTER_NAME>Test</ADAPTER_NAME>'+
  '<ADAPTER_MANUFACTURER></ADAPTER_MANUFACTURER>'+
  '<ADAPTER_ATTACHED>1</ADAPTER_ATTACHED>'+
  '<ADAPTER_PRIMARY>1</ADAPTER_PRIMARY>'+
  '<ADAPTER_DRIVER_DATE></ADAPTER_DRIVER_DATE>'+
  '<ADAPTER_DRIVER_VERSION></ADAPTER_DRIVER_VERSION>'+
  '<ADAPTER_HARDWARE_VERSION></ADAPTER_HARDWARE_VERSION>'+
  '<ADAPTER_HARDWARE_MEMORY>0</ADAPTER_HARDWARE_MEMORY>'+
  '<MONITOR_DEVICE_ID></MONITOR_DEVICE_ID>'+
  '<MONITOR_REGISTRY_KEY></MONITOR_REGISTRY_KEY>'+
  '<MONITOR_NAME>Test</MONITOR_NAME>'+
  '<MONITOR_MANUFACTURER></MONITOR_MANUFACTURER>'+
  '<MONITOR_ATTACHED>1</MONITOR_ATTACHED>'+
  '<MONITOR_PRIMARY>1</MONITOR_PRIMARY>'+
  '<MONITOR_DRIVER_DATE></MONITOR_DRIVER_DATE>'+
  '<MONITOR_DRIVER_VERSION></MONITOR_DRIVER_VERSION>'+
  '<MONITOR_SERIAL_NUMBER></MONITOR_SERIAL_NUMBER>'+
  '<MONITOR_HARDWARE_DATE></MONITOR_HARDWARE_DATE>'+
  '<MONITOR_IMAGE_SIZE></MONITOR_IMAGE_SIZE>'+
  '<MONITOR_RESOLUTION></MONITOR_RESOLUTION>'+
  '</SendMonitorInfo>'+
  '</soap:Body>'+
  '</soap:Envelope>';

  SOAPRequest:=s;

end;

end.
