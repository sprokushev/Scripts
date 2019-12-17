object Form1: TForm1
  Left = 192
  Top = 124
  Width = 870
  Height = 640
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 200
    Top = 232
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 0
    OnClick = Button1Click
  end
  object HTTPRIO1: THTTPRIO
    OnBeforeExecute = HTTPRIO1BeforeExecute
    WSDLLocation = 'http://kmiportal1.corp.lukoil.com/DBClient/DBClientSvc.asmx?WSDL'
    Service = 'DBClientSvc'
    Port = 'DBClientSvcSoap'
    HTTPWebNode.Agent = 'Borland SOAP 1.2'
    HTTPWebNode.UseUTF8InHeader = True
    HTTPWebNode.InvokeOptions = [soIgnoreInvalidCerts, soAutoCheckAccessPointViaUDDI]
    Converter.Options = [soSendUntyped, soSendMultiRefObj, soTryAllSchema, soRootRefNodesToBody, soUTF8InHeader, soCacheMimeResponse, soLiteralParams, soUTF8EncodeXML, soXXXXHdr]
    Converter.Encoding = 'utf-8'
    Left = 320
    Top = 120
  end
  object SoapConnection1: TSoapConnection
    SOAPServerIID = 'IAppServerSOAP - {C99F4735-D6D2-495C-8CA2-E53E5A439E61}'
    UseSOAPAdapter = True
    Left = 472
    Top = 192
  end
end
