Option Explicit
On Error Resume Next
Dim strSoapReq
Dim oHttp
strSoapReq = GenerateSoapBodyStart("DeleteMonitorInfo","kmiportal1.corp.lukoil.com")
strSoapReq = strSoapReq & "<NETBIOS_NAME>PROKUSHEVSV</NETBIOS_NAME>"
strSoapReq = strSoapReq & GenerateSoapBodyEnd("DeleteMonitorInfo")
Set oHttp = CreateObject("Msxml2.XMLHTTP")
oHttp.open "POST", "http://kmiportal1.corp.lukoil.com/DBClient/DBClientSvc.asmx", false
oHttp.setRequestHeader "Content-Type", "application/soap+xml; charset=utf-8"
oHttp.setRequestHeader "SOAPAction", "http://kmiportal1.corp.lukoil.com/DBClient/DBClientSvc.asmx/DeleteMonitorInfo"
oHttp.send strSoapReq
WScript.Quit

Function GenerateSoapBodyStart(byval strFunction, byval strServer)
  Dim strSoap
	strSoap = "<?xml version=""1.0"" encoding=""utf-8""?>"
	strSoap = strSoap & "<soap12:Envelope "
	strSoap = strSoap & "xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance"" "
	strSoap = strSoap & "xmlns:xsd=""http://www.w3.org/2001/XMLSchema"" "
	strSoap = strSoap & "xmlns:soap12=""http://www.w3.org/2003/05/soap-envelope""> "
	strSoap = strSoap & "<soap12:Body>"
	strSoap = strSoap & "<" & strFunction & " xmlns=""http://" & strServer & "/DBClient"">"
	GenerateSoapBodyStart = strSoap
End Function

Function GenerateSoapBodyEnd(byval strFunction)
	Dim strSoap
	strSoap = "</" & strFunction & "> </soap12:Body> </soap12:Envelope>"
	GenerateSoapBodyEnd = strSoap
End Function

