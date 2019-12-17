program GetDeviceInfo;

{$APPTYPE CONSOLE}

uses
  ExceptionLog,
  Windows,
  SysUtils,
  Classes,
  Registry,
  StrUtils,
  DateUtils,
  DateUtil,
  ShellApi,
  ActiveX,
  MyWin in 'MyWin.pas',
  MyEDID in 'MyEDID.pas',
  MyPrinter in 'MyPrinter.pas',
  MyDisk in 'MyDisk.pas',
  ActiveDs_TLB in 'C:\Program Files\Borland\Delphi7\Imports\ActiveDs_TLB.pas',
  WbemScripting_TLB in 'C:\Program Files\Borland\Delphi7\Imports\WbemScripting_TLB.pas';

const
  APPLICATION_VERSION='1.01d 01.06.2011';

var
  i: Integer;
  AddrServer: string;
  vbsF:TextFile;
  FName:string;

Function GenerateSoapParameter(strParam: string; strValue: string): string;
var strSoap: string;
begin
	strSoap:='<' + strParam + '>' + AnsiReplaceStr(AnsiReplaceStr(strValue,'"',''),'&','&amp;') + '</' + strParam + '>';
	Result:=strSoap;
End;

{ Запустить приложение }
function ExecVBSAndWait(const FileName, Params: ShortString; const WinState: Word;IsWait:boolean): boolean;
var
  StartInfo: TStartupInfo;
  ProcInfo: TProcessInformation;
  CmdLine: String;
  sExt:string;
  vExitCode:dword;
begin
  { Помещаем имя файла между кавычками, с соблюдением всех пробелов в именах Win9x }
  CmdLine := 'cscript.exe "' + Filename + '" ' + Params;
  FillChar(StartInfo, SizeOf(StartInfo), #0);
  with StartInfo do
  begin
    cb := SizeOf(StartInfo);
    dwFlags := STARTF_USESHOWWINDOW;
    wShowWindow := WinState;
  end;
  sExt:=UpperCase(Copy(Trim(FileName),length(FileName)-3,4));
  If (sExt='.VBS') Then
  Begin

    // ---------------------------------------------
    // вывод на экран тестового сообщения
    WriteToTestLog('=== запуск '+CmdLine);
    // ---------------------------------------------

    Result := CreateProcess(nil, PChar( String( CmdLine ) ), nil, nil, false,
                          CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, nil,
                          PChar(ExtractFilePath(Filename)),StartInfo,ProcInfo);
    { Ожидаем завершения приложения }
    if Result AND IsWait then
    begin
      WaitForSingleObject(ProcInfo.hProcess, INFINITE);
      GetExitCodeProcess(ProcInfo.hProcess,vExitCode);
      Result:=(vExitCode=0);

      // ---------------------------------------------
      // вывод на экран тестового сообщения
      WriteToTestLog('=== результат запуска '+IntToStr(vExitCode));
      // ---------------------------------------------

      { Free the Handles }
      CloseHandle(ProcInfo.hProcess);
      CloseHandle(ProcInfo.hThread);
    end;
  End;
end;




begin
  CoInitialize(nil);

  if ParamExist('help') or ParamExist('?') then
  Begin
    WriteLn(ConvertAnsiToOem('GetDeviceInfo.exe (v.' + APPLICATION_VERSION+') - сбор данных о мониторах, принтерах, дисках'+
    CHR(10)+'   /help или /? - помощь'+
    CHR(10)+'   /test - вывод на экран диагностических сообщений (для отладки)'+
    CHR(10)+'   /monitor - вывод данных о мониторах (игнорируется, если указан ключ /soap)'+
    CHR(10)+'   /printer - вывод данных о принтерах (игнорируется, если указан ключ /soap)'+
    CHR(10)+'   /disk - вывод данных о дисках'+
    CHR(10)+'   /scv - вывод в формате CSV'+
    CHR(10)+'   /log - вывод в формате LOG'+
    CHR(10)+'   /soap[=сервер] - передача на сервер используя SOAP'+
    CHR(10)+'                    сервер по умолчанию KMIPORTAL1.CORP.LUKOIL.COM'+
    ''));
    Halt(0);
  end;

  TestLog:=ParamExist('test');
  FileLog:=ExtractFileName(ParamStr(0));
  FileLog:=Copy(FileLog,1,length(FileLOg)-4);
  FileLog:=FillFilePath(GetEnvironmentVariable('TEMP'),true)+FileLog+'.log';

  // ---------------------------------------------
  // вывод на экран тестового сообщения
  WriteToTestLog('=== Создаем '+FileLog);
  // ---------------------------------------------

  OpenTestLog;

  if not FileLogOpen then
  Begin
    // ---------------------------------------------
    // вывод на экран тестового сообщения
    WriteToTestLog('=== НЕ создан '+FileLog);
    // ---------------------------------------------
  end;

  // Определяем сетевое имя компьютера
  ComputerName:=AnsiUpperCase(GetTerminalName(True));

  // ---------------------------------------------
  // вывод на экран тестового сообщения
  WriteToTestLog('=== версия '+ExtractFileName(ParamStr(0))+'='+APPLICATION_VERSION);
  // ---------------------------------------------

  // ---------------------------------------------
  // вывод на экран тестового сообщения
  WriteToTestLog('=== рабочий каталог = '+ExtractFilePath(ParamStr(0)));
  // ---------------------------------------------


  if ParamExist('printer') or ParamExist('soap') then FillPrinterInfo;

  for i := 1 to PrinterCount do
  with PrinterInfo[i] do
  Begin
    PRINTER_EDID:=Trim(PRINTER_EDID+' '+ExtractFileName(ParamStr(0))+'='+APPLICATION_VERSION);
    WriteToTestLog('NETBIOS_NAME='+NETBIOS_NAME);
    WriteToTestLog('PRINTER_DEVICE_ID='+PRINTER_DEVICE_ID);
    WriteToTestLog('PRINTER_NAME='+PRINTER_NAME);
    WriteToTestLog('PRINTER_SHARE_NAME='+PRINTER_SHARE_NAME);
    WriteToTestLog('PRINTER_MANUFACTURER='+PRINTER_MANUFACTURER);
    WriteToTestLog('PRINTER_ATTACHED='+IntToStr(PRINTER_ATTACHED));
    WriteToTestLog('PRINTER_PRIMARY='+IntToStr(PRINTER_PRIMARY));
    WriteToTestLog('PRINTER_LOCAL='+IntToStr(PRINTER_LOCAL));
    WriteToTestLog('PRINTER_ATTRIBUTE='+PRINTER_ATTRIBUTE);
    WriteToTestLog('PRINTER_COLOR='+IntToStr(PRINTER_COLOR));
    WriteToTestLog('PRINTER_DUPLEX='+IntToStr(PRINTER_DUPLEX));
    WriteToTestLog('PRINTER_FAX='+IntToStr(PRINTER_FAX));
    WriteToTestLog('PRINTER_PORT='+PRINTER_PORT);
    WriteToTestLog('PRINTER_SERIAL_NUMBER='+PRINTER_SERIAL_NUMBER);
    WriteToTestLog('PRINTER_HARDWARE_DATE='+PRINTER_HARDWARE_DATE);
    WriteToTestLog('PRINTER_LOCATION='+PRINTER_LOCATION);
    WriteToTestLog('PRINTER_ORIENTATION='+PRINTER_ORIENTATION);
    WriteToTestLog('PRINTER_PAPER_SIZE='+PRINTER_PAPER_SIZE);
    WriteToTestLog('PRINTER_RESOLUTION='+PRINTER_RESOLUTION);
    WriteToTestLog('PRINTER_STATUS='+PRINTER_STATUS);
    WriteToTestLog('PRINTER_JOBS='+IntToStr(PRINTER_JOBS));
    WriteToTestLog('PRINTER_AVERAGE='+IntToStr(PRINTER_AVERAGE));
    WriteToTestLog('PRINTER_DRIVER_NAME='+PRINTER_DRIVER_NAME);
    WriteToTestLog('PRINTER_DRIVER_DATE='+PRINTER_DRIVER_DATE);
    WriteToTestLog('PRINTER_DRIVER_VERSION='+PRINTER_DRIVER_VERSION);
    WriteToTestLog('PRINTER_EDID='+PRINTER_EDID);
    WriteToTestLog('-----------------------------------------------');
  end;


  if ParamExist('monitor') or ParamExist('soap') then FillMonitorInfo;

  for i := 1 to MonitorCount do
  with MonitorInfo[i] do
  Begin
    MONITOR_EDID:=Trim(MONITOR_EDID+' '+ExtractFileName(ParamStr(0))+'='+APPLICATION_VERSION);
    WriteToTestLog('NETBIOS_NAME='+NETBIOS_NAME);
    WriteToTestLog('ADAPTER_DEVICE_ID='+ADAPTER_DEVICE_ID);
    WriteToTestLog('ADAPTER_REGISTRY_KEY='+ADAPTER_REGISTRY_KEY);
    WriteToTestLog('ADAPTER_NAME='+ADAPTER_NAME);
    WriteToTestLog('ADAPTER_MANUFACTURER='+ADAPTER_MANUFACTURER);
    WriteToTestLog('ADAPTER_ATTACHED='+IntToStr(ADAPTER_ATTACHED));
    WriteToTestLog('ADAPTER_PRIMARY='+IntToStr(ADAPTER_PRIMARY));
    WriteToTestLog('ADAPTER_DRIVER_DATE='+ADAPTER_DRIVER_DATE);
    WriteToTestLog('ADAPTER_DRIVER_VERSION='+ADAPTER_DRIVER_VERSION);
    WriteToTestLog('ADAPTER_HARDWARE_VERSION='+ADAPTER_HARDWARE_VERSION);
    WriteToTestLog('ADAPTER_HARDWARE_MEMORY='+IntToStr(ADAPTER_HARDWARE_MEMORY));
    WriteToTestLog('MONITOR_DEVICE_ID='+MONITOR_DEVICE_ID);
    WriteToTestLog('MONITOR_REGISTRY_KEY='+MONITOR_REGISTRY_KEY);
    WriteToTestLog('MONITOR_NAME='+MONITOR_NAME);
    WriteToTestLog('MONITOR_MANUFACTURER='+MONITOR_MANUFACTURER);
    WriteToTestLog('MONITOR_ATTACHED='+IntToStr(MONITOR_ATTACHED));
    WriteToTestLog('MONITOR_PRIMARY='+IntToStr(MONITOR_PRIMARY));
    WriteToTestLog('MONITOR_DRIVER_DATE='+MONITOR_DRIVER_DATE);
    WriteToTestLog('MONITOR_DRIVER_VERSION='+MONITOR_DRIVER_VERSION);
    WriteToTestLog('MONITOR_SERIAL_NUMBER='+MONITOR_SERIAL_NUMBER);
    WriteToTestLog('MONITOR_HARDWARE_DATE='+MONITOR_HARDWARE_DATE);
    WriteToTestLog('MONITOR_IMAGE_SIZE='+MONITOR_IMAGE_SIZE);
    WriteToTestLog('MONITOR_RESOLUTION='+MONITOR_RESOLUTION);
    WriteToTestLog('MONITOR_EDID='+MONITOR_EDID);
    WriteToTestLog('-----------------------------------------------');
  end;

  if ParamExist('disk') then FillDiskInfo;

  for i := 1 to DiskCount do
  with DiskInfo[i] do
  Begin
    DISK_EDID:=Trim(DISK_EDID+' '+ExtractFileName(ParamStr(0))+'='+APPLICATION_VERSION);
    WriteToTestLog('NETBIOS_NAME='+NETBIOS_NAME);
    WriteToTestLog('DISK_NAME='+DISK_NAME);
    WriteToTestLog('DISK_TYPE='+DISK_TYPE);
    WriteToTestLog('DISK_SIZE='+IntToStr(DISK_SIZE));
    WriteToTestLog('DISK_FREE='+IntToStr(DISK_FREE));
    WriteToTestLog('DISK_EDID='+DISK_EDID);
    WriteToTestLog('-----------------------------------------------');
  end;

  if ParamExist('csv') And (MonitorCount>0) then
  Begin
    Write('NETBIOS_NAME',';','ADAPTER_DEVICE_ID',';','ADAPTER_REGISTRY_KEY',';','ADAPTER_NAME',';',
       'ADAPTER_MANUFACTURER',';','ADAPTER_ATTACHED',';',
       'ADAPTER_PRIMARY',';','ADAPTER_DRIVER_DATE',';','ADAPTER_DRIVER_VERSION',';','ADAPTER_HARDWARE_VERSION',';',
       'ADAPTER_HARDWARE_MEMORY',';','MONITOR_DEVICE_ID',';','MONITOR_REGISTRY_KEY',';','MONITOR_NAME',';',
       'MONITOR_MANUFACTURER',';','MONITOR_ATTACHED',';',
       'MONITOR_PRIMARY',';','MONITOR_DRIVER_DATE',';','MONITOR_DRIVER_VERSION',';','MONITOR_SERIAL_NUMBER',';',
       'MONITOR_HARDWARE_DATE',';','MONITOR_IMAGE_SIZE',';','MONITOR_RESOLUTION',';','MONITOR_EDID');
    WriteLn;
    for i := 1 to MonitorCount do
    with MonitorInfo[i] do
    Begin
      Write(NETBIOS_NAME,';',ADAPTER_DEVICE_ID,';',ADAPTER_REGISTRY_KEY,';',ADAPTER_NAME,';',
         ADAPTER_MANUFACTURER,';',ADAPTER_ATTACHED,';',
         ADAPTER_PRIMARY,';',ADAPTER_DRIVER_DATE,';',ADAPTER_DRIVER_VERSION,';',ADAPTER_HARDWARE_VERSION,';',
         ADAPTER_HARDWARE_MEMORY,';',MONITOR_DEVICE_ID,';',MONITOR_REGISTRY_KEY,';',MONITOR_NAME,';',
         MONITOR_MANUFACTURER,';',MONITOR_ATTACHED,';',
         MONITOR_PRIMARY,';',MONITOR_DRIVER_DATE,';',MONITOR_DRIVER_VERSION,';',MONITOR_SERIAL_NUMBER,';',
         MONITOR_HARDWARE_DATE,';',MONITOR_IMAGE_SIZE,';',MONITOR_RESOLUTION,';',MONITOR_EDID);
      WriteLn;
    end;
  end;

  if ParamExist('csv') and (PrinterCount>0) then
  Begin
    Write('NETBIOS_NAME',';','PRINTER_DEVICE_ID',';','PRINTER_NAME',';','PRINTER_SHARE_NAME',';','PRINTER_MANUFACTURER',';',
          'PRINTER_ATTACHED',';','PRINTER_PRIMARY',';','PRINTER_LOCAL',';','PRINTER_ATTRIBUTE',';','PRINTER_COLOR',';','PRINTER_DUPLEX',';',
          'PRINTER_FAX',';','PRINTER_PORT',';','PRINTER_SERIAL_NUMBER',';','PRINTER_HARDWARE_DATE',';','PRINTER_LOCATION',';','PRINTER_ORIENTATION',';',
          'PRINTER_PAPER_SIZE',';','PRINTER_RESOLUTION',';','PRINTER_STATUS',';','PRINTER_JOBS',';','PRINTER_AVERAGE',';','PRINTER_DRIVER_NAME',';',
          'PRINTER_DRIVER_DATE',';','PRINTER_DRIVER_VERSION',';','PRINTER_EDID');
    WriteLn;
    for i := 1 to PrinterCount do
    with PrinterInfo[i] do
    Begin
      Write(NETBIOS_NAME,';',PRINTER_DEVICE_ID,';',PRINTER_NAME,';',PRINTER_SHARE_NAME,';',PRINTER_MANUFACTURER,';',
            PRINTER_ATTACHED,';',PRINTER_PRIMARY,';',PRINTER_LOCAL,';',PRINTER_ATTRIBUTE,';',PRINTER_COLOR,';',PRINTER_DUPLEX,';',
            PRINTER_FAX,';',PRINTER_PORT,';',PRINTER_SERIAL_NUMBER,';',PRINTER_HARDWARE_DATE,';',PRINTER_LOCATION,';',PRINTER_ORIENTATION,';',
            PRINTER_PAPER_SIZE,';',PRINTER_RESOLUTION,';',PRINTER_STATUS,';',PRINTER_JOBS,';',PRINTER_AVERAGE,';',PRINTER_DRIVER_NAME,';',
            PRINTER_DRIVER_DATE,';',PRINTER_DRIVER_VERSION,';',PRINTER_EDID);
      WriteLn;
    end;
  end;

  if ParamExist('csv') And (DiskCount>0) then
  Begin
    Write('NETBIOS_NAME',';','DISK_NAME',';','DISK_TYPE',';','DISK_SIZE',';','DISK_FREE',';','DISK_EDID');
    WriteLn;
    for i := 1 to DiskCount do
    with DiskInfo[i] do
    Begin
      Write(NETBIOS_NAME,';',DISK_NAME,';',DISK_TYPE,';',DISK_SIZE,';',DISK_FREE,';',DISK_EDID);
      WriteLn;
    end;
  end;

  if ParamExist('log') And (MonitorCount>0) then
  Begin
    WriteLn('[MONITOR_INFO]');
    WriteLn('NETBIOS_NAME=', ComputerName);
    for i := 1 to MonitorCount do
    with MonitorInfo[i] do
    Begin
      WriteLn('ADAPTER_DEVICE_ID=',ADAPTER_DEVICE_ID);
      WriteLn('ADAPTER_REGISTRY_KEY=',ADAPTER_REGISTRY_KEY);
      WriteLn('ADAPTER_NAME=',ADAPTER_NAME);
      WriteLn('ADAPTER_MANUFACTURER=',ADAPTER_MANUFACTURER);
      WriteLn('ADAPTER_ATTACHED=',ADAPTER_ATTACHED);
      WriteLn('ADAPTER_PRIMARY=',ADAPTER_PRIMARY);
      WriteLn('ADAPTER_DRIVER_DATE=',ADAPTER_DRIVER_DATE);
      WriteLn('ADAPTER_DRIVER_VERSION=',ADAPTER_DRIVER_VERSION);
      WriteLn('ADAPTER_HARDWARE_VERSION=',ADAPTER_HARDWARE_VERSION);
      WriteLn('ADAPTER_HARDWARE_MEMORY=',ADAPTER_HARDWARE_MEMORY);
      WriteLn('MONITOR_DEVICE_ID=',MONITOR_DEVICE_ID);
      WriteLn('MONITOR_REGISTRY_KEY=',MONITOR_REGISTRY_KEY);
      WriteLn('MONITOR_NAME=',MONITOR_NAME);
      WriteLn('MONITOR_MANUFACTURER=',MONITOR_MANUFACTURER);
      WriteLn('MONITOR_ATTACHED=',MONITOR_ATTACHED);
      WriteLn('MONITOR_PRIMARY=',MONITOR_PRIMARY);
      WriteLn('MONITOR_DRIVER_DATE=',MONITOR_DRIVER_DATE);
      WriteLn('MONITOR_DRIVER_VERSION=',MONITOR_DRIVER_VERSION);
      WriteLn('MONITOR_SERIAL_NUMBER=',MONITOR_SERIAL_NUMBER);
      WriteLn('MONITOR_HARDWARE_DATE=',MONITOR_HARDWARE_DATE);
      WriteLn('MONITOR_IMAGE_SIZE=',MONITOR_IMAGE_SIZE);
      WriteLn('MONITOR_RESOLUTION=',MONITOR_RESOLUTION);
      WriteLn('MONITOR_EDID=',MONITOR_EDID);
      WriteLn;
    end;
  end;

  if ParamExist('log') And (PrinterCount>0) then
  Begin
    WriteLn('[PRINTER_INFO]');
    WriteLn('NETBIOS_NAME=', ComputerName);
    for i := 1 to PrinterCount do
    with PrinterInfo[i] do
    Begin
      WriteLn('PRINTER_DEVICE_ID=', PRINTER_DEVICE_ID);
      WriteLn('PRINTER_NAME=', PRINTER_NAME);
      WriteLn('PRINTER_SHARE_NAME=', PRINTER_SHARE_NAME);
      WriteLn('PRINTER_MANUFACTURER=', PRINTER_MANUFACTURER);
      WriteLn('PRINTER_ATTACHED=', PRINTER_ATTACHED);
      WriteLn('PRINTER_PRIMARY=', PRINTER_PRIMARY);
      WriteLn('PRINTER_LOCAL=', PRINTER_LOCAL);
      WriteLn('PRINTER_ATTRIBUTE=', PRINTER_ATTRIBUTE);
      WriteLn('PRINTER_COLOR=', PRINTER_COLOR);
      WriteLn('PRINTER_DUPLEX=', PRINTER_DUPLEX);
      WriteLn('PRINTER_FAX=', PRINTER_FAX);
      WriteLn('PRINTER_PORT=', PRINTER_PORT);
      WriteLn('PRINTER_SERIAL_NUMBER=', PRINTER_SERIAL_NUMBER);
      WriteLn('PRINTER_HARDWARE_DATE=', PRINTER_HARDWARE_DATE);
      WriteLn('PRINTER_LOCATION=', PRINTER_LOCATION);
      WriteLn('PRINTER_ORIENTATION=', PRINTER_ORIENTATION);
      WriteLn('PRINTER_PAPER_SIZE=', PRINTER_PAPER_SIZE);
      WriteLn('PRINTER_RESOLUTION=', PRINTER_RESOLUTION);
      WriteLn('PRINTER_STATUS=', PRINTER_STATUS);
      WriteLn('PRINTER_JOBS=', PRINTER_JOBS);
      WriteLn('PRINTER_AVERAGE=', PRINTER_AVERAGE);
      WriteLn('PRINTER_DRIVER_NAME=', PRINTER_DRIVER_NAME);
      WriteLn('PRINTER_DRIVER_DATE=', PRINTER_DRIVER_DATE);
      WriteLn('PRINTER_DRIVER_VERSION=', PRINTER_DRIVER_VERSION);
      WriteLn('PRINTER_EDID=', PRINTER_EDID);
      WriteLn;
    end;
  end;

  if ParamExist('log') And (DiskCount>0) then
  Begin
    WriteLn('[DISK_INFO]');
    WriteLn('NETBIOS_NAME=', ComputerName);
    for i := 1 to DiskCount do
    with DiskInfo[i] do
    Begin
      WriteLn('Disk '+DISK_NAME+': total space (Gb): ',DISK_SIZE);
      WriteLn('Disk '+DISK_NAME+': free space (Gb): ',DISK_FREE);
      WriteLn('Disk '+DISK_NAME+': type: ',DISK_TYPE);
    end;
  end;

  if ParamExist('soap') then
  Begin
    AddrServer:=ParamStrByName('soap');
    if AddrServer='' then AddrServer:='kmiportal1.corp.lukoil.com';

    FName:=FillFilePath(GetEnvironmentVariable('TEMP'),true)+'del_monitor.vbs';
    // ---------------------------------------------
    // вывод на экран тестового сообщения
    WriteToTestLog('=== создаем '+FName);
    // ---------------------------------------------

    {$I-}
    AssignFile(vbsF,FName);
    FileMode := 2;
    Rewrite(vbsF);
    {$I+}
    if (IOResult = 0) then
    Begin
      WriteLn(vbsF,'Option Explicit');
      WriteLn(vbsF,'On Error Resume Next');
      WriteLn(vbsF,'Dim strSoapReq');
      WriteLn(vbsF,'Dim oHttp');
      WriteLn(vbsF,'strSoapReq = GenerateSoapBodyStart("DeleteMonitorInfo","'+AddrServer+'")');
      WriteLn(vbsF,'strSoapReq = strSoapReq & "'+GenerateSoapParameter('NETBIOS_NAME',ComputerName)+'"');
      WriteLn(vbsF,'strSoapReq = strSoapReq & GenerateSoapBodyEnd("DeleteMonitorInfo")');
      WriteLn(vbsF,'Set oHttp = CreateObject("Msxml2.XMLHTTP")');
      WriteLn(vbsF,'oHttp.open "POST", "http://'+AddrServer+'/DBClient/DBClientSvc.asmx", false');
      WriteLn(vbsF,'oHttp.setRequestHeader "Content-Type", "application/soap+xml; charset=utf-8"');
      WriteLn(vbsF,'oHttp.setRequestHeader "SOAPAction", "http://'+AddrServer+'/DBClient/DBClientSvc.asmx/DeleteMonitorInfo"');
      WriteLn(vbsF,'oHttp.send strSoapReq');
      WriteLn(vbsF,'WScript.Quit(oHttp.Status)');
      WriteLn(vbsF);
      WriteLn(vbsF,'Function GenerateSoapBodyStart(byval strFunction, byval strServer)');
      WriteLn(vbsF,'  Dim strSoap');
      WriteLn(vbsF,'	strSoap = "<?xml version=""1.0"" encoding=""utf-8""?>"');
      WriteLn(vbsF,'	strSoap = strSoap & "<soap12:Envelope "');
      WriteLn(vbsF,'	strSoap = strSoap & "xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance"" "');
      WriteLn(vbsF,'	strSoap = strSoap & "xmlns:xsd=""http://www.w3.org/2001/XMLSchema"" "');
      WriteLn(vbsF,'	strSoap = strSoap & "xmlns:soap12=""http://www.w3.org/2003/05/soap-envelope""> "');
      WriteLn(vbsF,'	strSoap = strSoap & "<soap12:Body>"');
      WriteLn(vbsF,'	strSoap = strSoap & "<" & strFunction & " xmlns=""http://" & strServer & "/DBClient"">"');
      WriteLn(vbsF,'	GenerateSoapBodyStart = strSoap');
      WriteLn(vbsF,'End Function');
      WriteLn(vbsF);
      WriteLn(vbsF,'Function GenerateSoapBodyEnd(byval strFunction)');
      WriteLn(vbsF,'	Dim strSoap');
      WriteLn(vbsF,'	strSoap = "</" & strFunction & "> </soap12:Body> </soap12:Envelope>"');
      WriteLn(vbsF,'	GenerateSoapBodyEnd = strSoap');
      WriteLn(vbsF,'End Function');
      WriteLn(vbsF);
      CloseFile(vbsF);

      // ---------------------------------------------
      // вывод на экран тестового сообщения
      WriteToTestLog('=== создан '+FName);
      // ---------------------------------------------

      ExecVBSAndWait(FName,'',SW_SHOWMINIMIZED,true);
    end;


    FName:=FillFilePath(GetEnvironmentVariable('TEMP'),true)+'del_printer.vbs';
    // ---------------------------------------------
    // вывод на экран тестового сообщения
    WriteToTestLog('=== создаем '+FName);
    // ---------------------------------------------

    {$I-}
    AssignFile(vbsF,FName);
    FileMode := 2;
    Rewrite(vbsF);
    {$I+}
    if (IOResult = 0) then
    Begin
      WriteLn(vbsF,'Option Explicit');
      WriteLn(vbsF,'On Error Resume Next');
      WriteLn(vbsF,'Dim strSoapReq');
      WriteLn(vbsF,'Dim oHttp');
      WriteLn(vbsF,'strSoapReq = GenerateSoapBodyStart("DeletePrinterInfo","'+AddrServer+'")');
      WriteLn(vbsF,'strSoapReq = strSoapReq & "'+GenerateSoapParameter('NETBIOS_NAME',ComputerName)+'"');
      WriteLn(vbsF,'strSoapReq = strSoapReq & GenerateSoapBodyEnd("DeletePrinterInfo")');
      WriteLn(vbsF,'Set oHttp = CreateObject("Msxml2.XMLHTTP")');
      WriteLn(vbsF,'oHttp.open "POST", "http://'+AddrServer+'/DBClient/DBClientSvc.asmx", false');
      WriteLn(vbsF,'oHttp.setRequestHeader "Content-Type", "application/soap+xml; charset=utf-8"');
      WriteLn(vbsF,'oHttp.setRequestHeader "SOAPAction", "http://'+AddrServer+'/DBClient/DBClientSvc.asmx/DeletePrinterInfo"');
      WriteLn(vbsF,'oHttp.send strSoapReq');
      WriteLn(vbsF,'WScript.Quit(oHttp.Status)');
      WriteLn(vbsF);
      WriteLn(vbsF,'Function GenerateSoapBodyStart(byval strFunction, byval strServer)');
      WriteLn(vbsF,'  Dim strSoap');
      WriteLn(vbsF,'	strSoap = "<?xml version=""1.0"" encoding=""utf-8""?>"');
      WriteLn(vbsF,'	strSoap = strSoap & "<soap12:Envelope "');
      WriteLn(vbsF,'	strSoap = strSoap & "xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance"" "');
      WriteLn(vbsF,'	strSoap = strSoap & "xmlns:xsd=""http://www.w3.org/2001/XMLSchema"" "');
      WriteLn(vbsF,'	strSoap = strSoap & "xmlns:soap12=""http://www.w3.org/2003/05/soap-envelope""> "');
      WriteLn(vbsF,'	strSoap = strSoap & "<soap12:Body>"');
      WriteLn(vbsF,'	strSoap = strSoap & "<" & strFunction & " xmlns=""http://" & strServer & "/DBClient"">"');
      WriteLn(vbsF,'	GenerateSoapBodyStart = strSoap');
      WriteLn(vbsF,'End Function');
      WriteLn(vbsF);
      WriteLn(vbsF,'Function GenerateSoapBodyEnd(byval strFunction)');
      WriteLn(vbsF,'	Dim strSoap');
      WriteLn(vbsF,'	strSoap = "</" & strFunction & "> </soap12:Body> </soap12:Envelope>"');
      WriteLn(vbsF,'	GenerateSoapBodyEnd = strSoap');
      WriteLn(vbsF,'End Function');
      WriteLn(vbsF);
      CloseFile(vbsF);

      // ---------------------------------------------
      // вывод на экран тестового сообщения
      WriteToTestLog('=== создан '+FName);
      // ---------------------------------------------

      ExecVBSAndWait(FName,'',SW_SHOWMINIMIZED,true);
    end;


    for i := 1 to MonitorCount do
    with MonitorInfo[i] do
    Begin
      FName:=FillFilePath(GetEnvironmentVariable('TEMP'),true)+'add_monitor.vbs';
      // ---------------------------------------------
      // вывод на экран тестового сообщения
      WriteToTestLog('=== создаем '+FName);
      // ---------------------------------------------

      {$I-}
      AssignFile(vbsF,FName);
      FileMode := 2;
      Rewrite(vbsF);
      {$I+}
      if (IOResult = 0) then
      Begin
        WriteLn(vbsF,'Option Explicit');
        WriteLn(vbsF,'On Error Resume Next');
        WriteLn(vbsF,'Dim strSoapReq');
        WriteLn(vbsF,'Dim oHttp');
        WriteLn(vbsF,'strSoapReq = GenerateSoapBodyStart("SendMonitorInfo","'+AddrServer+'")');
        WriteLn(vbsF,'strSoapReq = strSoapReq & "'+GenerateSoapParameter('NETBIOS_NAME',NETBIOS_NAME)+'"');
        WriteLn(vbsF,'strSoapReq = strSoapReq & "'+GenerateSoapParameter('ADAPTER_DEVICE_ID',ADAPTER_DEVICE_ID)+'"');
        WriteLn(vbsF,'strSoapReq = strSoapReq & "'+GenerateSoapParameter('ADAPTER_REGISTRY_KEY',ADAPTER_REGISTRY_KEY)+'"');
        WriteLn(vbsF,'strSoapReq = strSoapReq & "'+GenerateSoapParameter('ADAPTER_NAME',ADAPTER_NAME)+'"');
        WriteLn(vbsF,'strSoapReq = strSoapReq & "'+GenerateSoapParameter('ADAPTER_MANUFACTURER',ADAPTER_MANUFACTURER)+'"');
        WriteLn(vbsF,'strSoapReq = strSoapReq & "'+GenerateSoapParameter('ADAPTER_ATTACHED',IntToStr(ADAPTER_ATTACHED))+'"');
        WriteLn(vbsF,'strSoapReq = strSoapReq & "'+GenerateSoapParameter('ADAPTER_PRIMARY',IntToStr(ADAPTER_PRIMARY))+'"');
        WriteLn(vbsF,'strSoapReq = strSoapReq & "'+GenerateSoapParameter('ADAPTER_DRIVER_DATE',ADAPTER_DRIVER_DATE)+'"');
        WriteLn(vbsF,'strSoapReq = strSoapReq & "'+GenerateSoapParameter('ADAPTER_DRIVER_VERSION',ADAPTER_DRIVER_VERSION)+'"');
        WriteLn(vbsF,'strSoapReq = strSoapReq & "'+GenerateSoapParameter('ADAPTER_HARDWARE_VERSION',ADAPTER_HARDWARE_VERSION)+'"');
        WriteLn(vbsF,'strSoapReq = strSoapReq & "'+GenerateSoapParameter('ADAPTER_HARDWARE_MEMORY',IntToStr(ADAPTER_HARDWARE_MEMORY))+'"');
        WriteLn(vbsF,'strSoapReq = strSoapReq & "'+GenerateSoapParameter('MONITOR_DEVICE_ID',MONITOR_DEVICE_ID)+'"');
        WriteLn(vbsF,'strSoapReq = strSoapReq & "'+GenerateSoapParameter('MONITOR_REGISTRY_KEY',MONITOR_REGISTRY_KEY)+'"');
        WriteLn(vbsF,'strSoapReq = strSoapReq & "'+GenerateSoapParameter('MONITOR_NAME',MONITOR_NAME)+'"');
        WriteLn(vbsF,'strSoapReq = strSoapReq & "'+GenerateSoapParameter('MONITOR_MANUFACTURER',MONITOR_MANUFACTURER)+'"');
        WriteLn(vbsF,'strSoapReq = strSoapReq & "'+GenerateSoapParameter('MONITOR_ATTACHED',IntToStr(MONITOR_ATTACHED))+'"');
        WriteLn(vbsF,'strSoapReq = strSoapReq & "'+GenerateSoapParameter('MONITOR_PRIMARY',IntToStr(MONITOR_PRIMARY))+'"');
        WriteLn(vbsF,'strSoapReq = strSoapReq & "'+GenerateSoapParameter('MONITOR_DRIVER_DATE',MONITOR_DRIVER_DATE)+'"');
        WriteLn(vbsF,'strSoapReq = strSoapReq & "'+GenerateSoapParameter('MONITOR_DRIVER_VERSION',MONITOR_DRIVER_VERSION)+'"');
        WriteLn(vbsF,'strSoapReq = strSoapReq & "'+GenerateSoapParameter('MONITOR_SERIAL_NUMBER',MONITOR_SERIAL_NUMBER)+'"');
        WriteLn(vbsF,'strSoapReq = strSoapReq & "'+GenerateSoapParameter('MONITOR_HARDWARE_DATE',MONITOR_HARDWARE_DATE)+'"');
        WriteLn(vbsF,'strSoapReq = strSoapReq & "'+GenerateSoapParameter('MONITOR_IMAGE_SIZE',MONITOR_IMAGE_SIZE)+'"');
        WriteLn(vbsF,'strSoapReq = strSoapReq & "'+GenerateSoapParameter('MONITOR_RESOLUTION',MONITOR_RESOLUTION)+'"');
        WriteLn(vbsF,'strSoapReq = strSoapReq & "'+GenerateSoapParameter('MONITOR_EDID',MONITOR_EDID)+'"');
        WriteLn(vbsF,'strSoapReq = strSoapReq & GenerateSoapBodyEnd("SendMonitorInfo")');
        WriteLn(vbsF,'Set oHttp = CreateObject("Msxml2.XMLHTTP")');
        WriteLn(vbsF,'oHttp.open "POST", "http://'+AddrServer+'/DBClient/DBClientSvc.asmx", false');
        WriteLn(vbsF,'oHttp.setRequestHeader "Content-Type", "application/soap+xml; charset=utf-8"');
        WriteLn(vbsF,'oHttp.setRequestHeader "SOAPAction", "http://'+AddrServer+'/DBClient/DBClientSvc.asmx/SendMonitorInfo"');
        WriteLn(vbsF,'oHttp.send strSoapReq');
        WriteLn(vbsF,'WScript.Quit(oHttp.Status)');
        WriteLn(vbsF);
        WriteLn(vbsF,'Function GenerateSoapBodyStart(byval strFunction, byval strServer)');
        WriteLn(vbsF,'  Dim strSoap');
        WriteLn(vbsF,'	strSoap = "<?xml version=""1.0"" encoding=""utf-8""?>"');
        WriteLn(vbsF,'	strSoap = strSoap & "<soap12:Envelope "');
        WriteLn(vbsF,'	strSoap = strSoap & "xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance"" "');
        WriteLn(vbsF,'	strSoap = strSoap & "xmlns:xsd=""http://www.w3.org/2001/XMLSchema"" "');
        WriteLn(vbsF,'	strSoap = strSoap & "xmlns:soap12=""http://www.w3.org/2003/05/soap-envelope""> "');
        WriteLn(vbsF,'	strSoap = strSoap & "<soap12:Body>"');
        WriteLn(vbsF,'	strSoap = strSoap & "<" & strFunction & " xmlns=""http://" & strServer & "/DBClient"">"');
        WriteLn(vbsF,'	GenerateSoapBodyStart = strSoap');
        WriteLn(vbsF,'End Function');
        WriteLn(vbsF);
        WriteLn(vbsF,'Function GenerateSoapBodyEnd(byval strFunction)');
        WriteLn(vbsF,'	Dim strSoap');
        WriteLn(vbsF,'	strSoap = "</" & strFunction & "> </soap12:Body> </soap12:Envelope>"');
        WriteLn(vbsF,'	GenerateSoapBodyEnd = strSoap');
        WriteLn(vbsF,'End Function');
        WriteLn(vbsF);
        CloseFile(vbsF);

        // ---------------------------------------------
        // вывод на экран тестового сообщения
        WriteToTestLog('=== создан '+FName);
        // ---------------------------------------------

        ExecVBSAndWait(FName,'',SW_SHOWMINIMIZED,true);
      end;
    end;

    for i := 1 to PrinterCount do
    with PrinterInfo[i] do
    Begin
      FName:=FillFilePath(GetEnvironmentVariable('TEMP'),true)+'add_printer.vbs';
      // ---------------------------------------------
      // вывод на экран тестового сообщения
      WriteToTestLog('=== создаем '+FName);
      // ---------------------------------------------

      {$I-}
      AssignFile(vbsF,FName);
      FileMode := 2;
      Rewrite(vbsF);
      {$I+}
      if (IOResult = 0) then
      Begin
        WriteLn(vbsF,'Option Explicit');
        WriteLn(vbsF,'On Error Resume Next');
        WriteLn(vbsF,'Dim strSoapReq');
        WriteLn(vbsF,'Dim oHttp');
        WriteLn(vbsF,'strSoapReq = GenerateSoapBodyStart("SendPrinterInfo","'+AddrServer+'")');
        WriteLn(vbsF,'strSoapReq = strSoapReq & "'+GenerateSoapParameter('NETBIOS_NAME', NETBIOS_NAME)+'"');
        WriteLn(vbsF,'strSoapReq = strSoapReq & "'+GenerateSoapParameter('PRINTER_DEVICE_ID', PRINTER_DEVICE_ID)+'"');
        WriteLn(vbsF,'strSoapReq = strSoapReq & "'+GenerateSoapParameter('PRINTER_NAME', PRINTER_NAME)+'"');
        WriteLn(vbsF,'strSoapReq = strSoapReq & "'+GenerateSoapParameter('PRINTER_SHARE_NAME', PRINTER_SHARE_NAME)+'"');
        WriteLn(vbsF,'strSoapReq = strSoapReq & "'+GenerateSoapParameter('PRINTER_MANUFACTURER', PRINTER_MANUFACTURER)+'"');
        WriteLn(vbsF,'strSoapReq = strSoapReq & "'+GenerateSoapParameter('PRINTER_ATTACHED', IntToStr(PRINTER_ATTACHED))+'"');
        WriteLn(vbsF,'strSoapReq = strSoapReq & "'+GenerateSoapParameter('PRINTER_PRIMARY', IntToStr(PRINTER_PRIMARY))+'"');
        WriteLn(vbsF,'strSoapReq = strSoapReq & "'+GenerateSoapParameter('PRINTER_LOCAL', IntToStr(PRINTER_LOCAL))+'"');
        WriteLn(vbsF,'strSoapReq = strSoapReq & "'+GenerateSoapParameter('PRINTER_ATTRIBUTE', PRINTER_ATTRIBUTE)+'"');
        WriteLn(vbsF,'strSoapReq = strSoapReq & "'+GenerateSoapParameter('PRINTER_COLOR', IntToStr(PRINTER_COLOR))+'"');
        WriteLn(vbsF,'strSoapReq = strSoapReq & "'+GenerateSoapParameter('PRINTER_DUPLEX', IntToStr(PRINTER_DUPLEX))+'"');
        WriteLn(vbsF,'strSoapReq = strSoapReq & "'+GenerateSoapParameter('PRINTER_FAX', IntToStr(PRINTER_FAX))+'"');
        WriteLn(vbsF,'strSoapReq = strSoapReq & "'+GenerateSoapParameter('PRINTER_PORT', PRINTER_PORT)+'"');
        WriteLn(vbsF,'strSoapReq = strSoapReq & "'+GenerateSoapParameter('PRINTER_SERIAL_NUMBER', PRINTER_SERIAL_NUMBER)+'"');
        WriteLn(vbsF,'strSoapReq = strSoapReq & "'+GenerateSoapParameter('PRINTER_HARDWARE_DATE', PRINTER_HARDWARE_DATE)+'"');
        WriteLn(vbsF,'strSoapReq = strSoapReq & "'+GenerateSoapParameter('PRINTER_LOCATION', PRINTER_LOCATION)+'"');
        WriteLn(vbsF,'strSoapReq = strSoapReq & "'+GenerateSoapParameter('PRINTER_ORIENTATION', PRINTER_ORIENTATION)+'"');
        WriteLn(vbsF,'strSoapReq = strSoapReq & "'+GenerateSoapParameter('PRINTER_PAPER_SIZE', PRINTER_PAPER_SIZE)+'"');
        WriteLn(vbsF,'strSoapReq = strSoapReq & "'+GenerateSoapParameter('PRINTER_RESOLUTION', PRINTER_RESOLUTION)+'"');
        WriteLn(vbsF,'strSoapReq = strSoapReq & "'+GenerateSoapParameter('PRINTER_STATUS', PRINTER_STATUS)+'"');
        WriteLn(vbsF,'strSoapReq = strSoapReq & "'+GenerateSoapParameter('PRINTER_JOBS', IntToStr(PRINTER_JOBS))+'"');
        WriteLn(vbsF,'strSoapReq = strSoapReq & "'+GenerateSoapParameter('PRINTER_AVERAGE', IntToStr(PRINTER_AVERAGE))+'"');
        WriteLn(vbsF,'strSoapReq = strSoapReq & "'+GenerateSoapParameter('PRINTER_DRIVER_NAME', PRINTER_DRIVER_NAME)+'"');
        WriteLn(vbsF,'strSoapReq = strSoapReq & "'+GenerateSoapParameter('PRINTER_DRIVER_DATE', PRINTER_DRIVER_DATE)+'"');
        WriteLn(vbsF,'strSoapReq = strSoapReq & "'+GenerateSoapParameter('PRINTER_DRIVER_VERSION', PRINTER_DRIVER_VERSION)+'"');
        WriteLn(vbsF,'strSoapReq = strSoapReq & "'+GenerateSoapParameter('PRINTER_EDID', PRINTER_EDID)+'"');
        WriteLn(vbsF,'strSoapReq = strSoapReq & GenerateSoapBodyEnd("SendPrinterInfo")');
        WriteLn(vbsF,'Set oHttp = CreateObject("Msxml2.XMLHTTP")');
        WriteLn(vbsF,'oHttp.open "POST", "http://'+AddrServer+'/DBClient/DBClientSvc.asmx", false');
        WriteLn(vbsF,'oHttp.setRequestHeader "Content-Type", "application/soap+xml; charset=utf-8"');
        WriteLn(vbsF,'oHttp.setRequestHeader "SOAPAction", "http://'+AddrServer+'/DBClient/DBClientSvc.asmx/SendPrinterInfo"');
        WriteLn(vbsF,'oHttp.send strSoapReq');
        WriteLn(vbsF,'WScript.Quit(oHttp.Status)');
        WriteLn(vbsF);
        WriteLn(vbsF,'Function GenerateSoapBodyStart(byval strFunction, byval strServer)');
        WriteLn(vbsF,'  Dim strSoap');
        WriteLn(vbsF,'	strSoap = "<?xml version=""1.0"" encoding=""utf-8""?>"');
        WriteLn(vbsF,'	strSoap = strSoap & "<soap12:Envelope "');
        WriteLn(vbsF,'	strSoap = strSoap & "xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance"" "');
        WriteLn(vbsF,'	strSoap = strSoap & "xmlns:xsd=""http://www.w3.org/2001/XMLSchema"" "');
        WriteLn(vbsF,'	strSoap = strSoap & "xmlns:soap12=""http://www.w3.org/2003/05/soap-envelope""> "');
        WriteLn(vbsF,'	strSoap = strSoap & "<soap12:Body>"');
        WriteLn(vbsF,'	strSoap = strSoap & "<" & strFunction & " xmlns=""http://" & strServer & "/DBClient"">"');
        WriteLn(vbsF,'	GenerateSoapBodyStart = strSoap');
        WriteLn(vbsF,'End Function');
        WriteLn(vbsF);
        WriteLn(vbsF,'Function GenerateSoapBodyEnd(byval strFunction)');
        WriteLn(vbsF,'	Dim strSoap');
        WriteLn(vbsF,'	strSoap = "</" & strFunction & "> </soap12:Body> </soap12:Envelope>"');
        WriteLn(vbsF,'	GenerateSoapBodyEnd = strSoap');
        WriteLn(vbsF,'End Function');
        WriteLn(vbsF);
        CloseFile(vbsF);

        // ---------------------------------------------
        // вывод на экран тестового сообщения
        WriteToTestLog('=== создан '+FName);
        // ---------------------------------------------

        ExecVBSAndWait(FName,'',SW_SHOWMINIMIZED,true);
      end;
    end;


  end;


  CloseTestLog;

  CoUninitialize;

end.

