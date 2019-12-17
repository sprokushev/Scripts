// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : http://kmiportal1.corp.lukoil.com/DBClient/DBClientSvc.asmx?WSDL
// Encoding : utf-8
// Version  : 1.0
// (12.05.2011 9:23:34 - 1.33.2.5)
// ************************************************************************ //

unit DBClientSvc;

interface

uses InvokeRegistry, SOAPHTTPClient, Types, XSBuiltIns;

type

  // ************************************************************************ //
  // The following types, referred to in the WSDL document are not being represented
  // in this file. They are either aliases[@] of other types represented or were referred
  // to but never[!] declared in the document. The types from the latter category
  // typically map to predefined/known XML or Borland types; however, they could also 
  // indicate incorrect WSDL documents that failed to declare or import a schema type.
  // ************************************************************************ //
  // !:string          - "http://www.w3.org/2001/XMLSchema"
  // !:int             - "http://www.w3.org/2001/XMLSchema"



  // ************************************************************************ //
  // Namespace : http://kmiportal1.corp.lukoil.com/DBClient
  // soapAction: http://kmiportal1.corp.lukoil.com/DBClient/SendMonitorInfo
  // transport : http://schemas.xmlsoap.org/soap/http
  // binding   : DBClientSvcSoap
  // service   : DBClientSvc
  // port      : DBClientSvcSoap
  // URL       : http://kmiportal1.corp.lukoil.com/DBClient/DBClientSvc.asmx
  // ************************************************************************ //
  DBClientSvcSoap = interface(IInvokable)
  ['{77EDF850-C254-8693-B9B2-2E571CDF2E50}']
    function  SendMonitorInfo(const NETBIOS_NAME: WideString; const ADAPTER_DEVICE_ID: WideString; const ADAPTER_REGISTRY_KEY: WideString; const ADAPTER_NAME: WideString; const ADAPTER_MANUFACTURER: WideString; const ADAPTER_ATTACHED: Integer; const ADAPTER_PRIMARY: Integer; const ADAPTER_DRIVER_DATE: WideString; const ADAPTER_DRIVER_VERSION: WideString; const ADAPTER_HARDWARE_VERSION: WideString; 
                              const ADAPTER_HARDWARE_MEMORY: Integer; const MONITOR_DEVICE_ID: WideString; const MONITOR_REGISTRY_KEY: WideString; const MONITOR_NAME: WideString; const MONITOR_MANUFACTURER: WideString; const MONITOR_ATTACHED: Integer; const MONITOR_PRIMARY: Integer; const MONITOR_DRIVER_DATE: WideString; const MONITOR_DRIVER_VERSION: WideString; 
                              const MONITOR_SERIAL_NUMBER: WideString; const MONITOR_HARDWARE_DATE: WideString; const MONITOR_IMAGE_SIZE: WideString; const MONITOR_RESOLUTION: WideString): WideString; stdcall;
  end;

function GetDBClientSvcSoap(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): DBClientSvcSoap;


implementation

function GetDBClientSvcSoap(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): DBClientSvcSoap;
const
  defWSDL = 'http://kmiportal1.corp.lukoil.com/DBClient/DBClientSvc.asmx?WSDL';
  defURL  = 'http://kmiportal1.corp.lukoil.com/DBClient/DBClientSvc.asmx';
  defSvc  = 'DBClientSvc';
  defPrt  = 'DBClientSvcSoap';
var
  RIO: THTTPRIO;
begin
  Result := nil;
  if (Addr = '') then
  begin
    if UseWSDL then
      Addr := defWSDL
    else
      Addr := defURL;
  end;
  if HTTPRIO = nil then
    RIO := THTTPRIO.Create(nil)
  else
    RIO := HTTPRIO;
  try
    Result := (RIO as DBClientSvcSoap);
    if UseWSDL then
    begin
      RIO.WSDLLocation := Addr;
      RIO.Service := defSvc;
      RIO.Port := defPrt;
    end else
      RIO.URL := Addr;
  finally
    if (Result = nil) and (HTTPRIO = nil) then
      RIO.Free;
  end;
end;


initialization
  InvRegistry.RegisterInterface(TypeInfo(DBClientSvcSoap), 'http://kmiportal1.corp.lukoil.com/DBClient', 'utf-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(DBClientSvcSoap), 'http://kmiportal1.corp.lukoil.com/DBClient/SendMonitorInfo');

end. 