Option Explicit
On Error Resume Next
Dim strSoapReq
Dim oHttp
strSoapReq = GenerateSoapBodyStart("SendMonitorInfo","kmiportal1.corp.lukoil.com")
strSoapReq = strSoapReq & "<NETBIOS_NAME>UHT-SHESTAKOVDA</NETBIOS_NAME>"
strSoapReq = strSoapReq & "<ADAPTER_DEVICE_ID>PCI\VEN_10DE&amp;DEV_0A65&amp;SUBSYS_00000000&amp;REV_A2</ADAPTER_DEVICE_ID>"
strSoapReq = strSoapReq & "<ADAPTER_REGISTRY_KEY>SYSTEM\CURRENTCONTROLSET\CONTROL\VIDEO\{E096E5A5-2530-40E7-B7BE-C9C827A4962F}\0000</ADAPTER_REGISTRY_KEY>"
strSoapReq = strSoapReq & "<ADAPTER_NAME>GeForce 210</ADAPTER_NAME>"
strSoapReq = strSoapReq & "<ADAPTER_MANUFACTURER>NVIDIA</ADAPTER_MANUFACTURER>"
strSoapReq = strSoapReq & "<ADAPTER_ATTACHED>1</ADAPTER_ATTACHED>"
strSoapReq = strSoapReq & "<ADAPTER_PRIMARY>1</ADAPTER_PRIMARY>"
strSoapReq = strSoapReq & "<ADAPTER_DRIVER_DATE>07.06.2010</ADAPTER_DRIVER_DATE>"
strSoapReq = strSoapReq & "<ADAPTER_DRIVER_VERSION>8.17.12.5721</ADAPTER_DRIVER_VERSION>"
strSoapReq = strSoapReq & "<ADAPTER_HARDWARE_VERSION>Version 70.18.4f.0.0</ADAPTER_HARDWARE_VERSION>"
strSoapReq = strSoapReq & "<ADAPTER_HARDWARE_MEMORY>512</ADAPTER_HARDWARE_MEMORY>"
strSoapReq = strSoapReq & "<MONITOR_DEVICE_ID>MONITOR\HWP26F7\{4d36e96e-e325-11ce-bfc1-08002be10318}\0003</MONITOR_DEVICE_ID>"
strSoapReq = strSoapReq & "<MONITOR_REGISTRY_KEY>SYSTEM\CURRENTCONTROLSET\CONTROL\CLASS\{4D36E96E-E325-11CE-BFC1-08002BE10318}\0003</MONITOR_REGISTRY_KEY>"
strSoapReq = strSoapReq & "<MONITOR_NAME>HP LP2475w</MONITOR_NAME>"
strSoapReq = strSoapReq & "<MONITOR_MANUFACTURER>HP</MONITOR_MANUFACTURER>"
strSoapReq = strSoapReq & "<MONITOR_ATTACHED>1</MONITOR_ATTACHED>"
strSoapReq = strSoapReq & "<MONITOR_PRIMARY>0</MONITOR_PRIMARY>"
strSoapReq = strSoapReq & "<MONITOR_DRIVER_DATE>16.06.2009</MONITOR_DRIVER_DATE>"
strSoapReq = strSoapReq & "<MONITOR_DRIVER_VERSION>2.0.0.0</MONITOR_DRIVER_VERSION>"
strSoapReq = strSoapReq & "<MONITOR_SERIAL_NUMBER>PLC00901PZ</MONITOR_SERIAL_NUMBER>"
strSoapReq = strSoapReq & "<MONITOR_HARDWARE_DATE>08.03.2010</MONITOR_HARDWARE_DATE>"
strSoapReq = strSoapReq & "<MONITOR_IMAGE_SIZE>54 sm x 35 sm = 25 inch</MONITOR_IMAGE_SIZE>"
strSoapReq = strSoapReq & "<MONITOR_RESOLUTION>1920 x 1200</MONITOR_RESOLUTION>"
strSoapReq = strSoapReq & GenerateSoapBodyEnd("SendMonitorInfo")
Set oHttp = CreateObject("Msxml2.XMLHTTP")
oHttp.open "POST", "http://kmiportal1.corp.lukoil.com/DBClient/DBClientSvc.asmx", false
oHttp.setRequestHeader "Content-Type", "application/soap+xml; charset=utf-8"
oHttp.setRequestHeader "SOAPAction", "http://kmiportal1.corp.lukoil.com/DBClient/DBClientSvc.asmx/SendMonitorInfo"
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

