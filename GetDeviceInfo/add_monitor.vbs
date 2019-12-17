Option Explicit
On Error Resume Next
Dim strSoapReq
Dim oHttp
strSoapReq = GenerateSoapBodyStart("SendMonitorInfo","kmiportal1.corp.lukoil.com")
strSoapReq = strSoapReq & "<NETBIOS_NAME>PROKUSHEVSV</NETBIOS_NAME>"
strSoapReq = strSoapReq & "<ADAPTER_DEVICE_ID>PCI\VEN_10DE&amp;DEV_0400&amp;SUBSYS_00000000&amp;REV_A1</ADAPTER_DEVICE_ID>"
strSoapReq = strSoapReq & "<ADAPTER_REGISTRY_KEY>SYSTEM\CURRENTCONTROLSET\CONTROL\VIDEO\{6C6D1946-0F3D-46A9-A985-30FE32FE45BB}\0000</ADAPTER_REGISTRY_KEY>"
strSoapReq = strSoapReq & "<ADAPTER_NAME>GeForce 8600 GTS</ADAPTER_NAME>"
strSoapReq = strSoapReq & "<ADAPTER_MANUFACTURER>NVIDIA</ADAPTER_MANUFACTURER>"
strSoapReq = strSoapReq & "<ADAPTER_ATTACHED>1</ADAPTER_ATTACHED>"
strSoapReq = strSoapReq & "<ADAPTER_PRIMARY>1</ADAPTER_PRIMARY>"
strSoapReq = strSoapReq & "<ADAPTER_DRIVER_DATE>14.05.2009</ADAPTER_DRIVER_DATE>"
strSoapReq = strSoapReq & "<ADAPTER_DRIVER_VERSION>8.15.11.8593</ADAPTER_DRIVER_VERSION>"
strSoapReq = strSoapReq & "<ADAPTER_HARDWARE_VERSION>Version 60.84.32.0.0</ADAPTER_HARDWARE_VERSION>"
strSoapReq = strSoapReq & "<ADAPTER_HARDWARE_MEMORY>512</ADAPTER_HARDWARE_MEMORY>"
strSoapReq = strSoapReq & "<MONITOR_DEVICE_ID>MONITOR\HWP26E7\{4d36e96e-e325-11ce-bfc1-08002be10318}\0001</MONITOR_DEVICE_ID>"
strSoapReq = strSoapReq & "<MONITOR_REGISTRY_KEY>SYSTEM\CURRENTCONTROLSET\CONTROL\CLASS\{4D36E96E-E325-11CE-BFC1-08002BE10318}\0001</MONITOR_REGISTRY_KEY>"
strSoapReq = strSoapReq & "<MONITOR_NAME>HP L1950</MONITOR_NAME>"
strSoapReq = strSoapReq & "<MONITOR_MANUFACTURER>HWP</MONITOR_MANUFACTURER>"
strSoapReq = strSoapReq & "<MONITOR_ATTACHED>1</MONITOR_ATTACHED>"
strSoapReq = strSoapReq & "<MONITOR_PRIMARY>0</MONITOR_PRIMARY>"
strSoapReq = strSoapReq & "<MONITOR_DRIVER_DATE>21.06.2006</MONITOR_DRIVER_DATE>"
strSoapReq = strSoapReq & "<MONITOR_DRIVER_VERSION>6.1.7600.16385</MONITOR_DRIVER_VERSION>"
strSoapReq = strSoapReq & "<MONITOR_SERIAL_NUMBER>CNK8260JFG</MONITOR_SERIAL_NUMBER>"
strSoapReq = strSoapReq & "<MONITOR_HARDWARE_DATE>23.06.2008</MONITOR_HARDWARE_DATE>"
strSoapReq = strSoapReq & "<MONITOR_IMAGE_SIZE>38 sm x 30 sm = 19 inch</MONITOR_IMAGE_SIZE>"
strSoapReq = strSoapReq & "<MONITOR_RESOLUTION>1280 x 1024</MONITOR_RESOLUTION>"
strSoapReq = strSoapReq & "<MONITOR_EDID>������ "��&h&��TL�&PT��0* �Q *@0p |,     � 2MS 
         � HP L1950
       � CNK8260JFG
    </MONITOR_EDID>"
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

