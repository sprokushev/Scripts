unit MyEDID;

interface

type
  TMonitorInfo=array [1..128] of record
    NETBIOS_NAME:string;
    ADAPTER_DEVICE_ID:string;
    ADAPTER_REGISTRY_KEY:string;
    ADAPTER_NAME:string;
    ADAPTER_MANUFACTURER:string;
    ADAPTER_ATTACHED:integer;
    ADAPTER_PRIMARY:integer;
    ADAPTER_DRIVER_DATE:string;
    ADAPTER_DRIVER_VERSION:string;
    ADAPTER_HARDWARE_VERSION:string;
    ADAPTER_HARDWARE_MEMORY:integer;
    MONITOR_DEVICE_ID:string;
    MONITOR_REGISTRY_KEY:string;
    MONITOR_NAME:string;
    MONITOR_MANUFACTURER:string;
    MONITOR_ATTACHED:integer;
    MONITOR_PRIMARY:integer;
    MONITOR_DRIVER_DATE:string;
    MONITOR_DRIVER_VERSION:string;
    MONITOR_SERIAL_NUMBER:string;
    MONITOR_HARDWARE_DATE:string;
    MONITOR_IMAGE_SIZE:string;
    MONITOR_RESOLUTION:string;
    MONITOR_EDID:string;
  end;

Procedure FillMonitorInfo;

var
  MonitorCount: integer;
  MonitorInfo: TMonitorInfo;
  resCount: integer;
  Res: array [1..50] of record
    EDID_Byte:integer;
    EDID_Bit:integer;
    HRes: integer;
    VRes: integer;
    Hz: integer;
  end;
  maxRes:double;
  maxI:integer;


implementation

uses Windows, MyWin, Registry, Classes, SysUtils, StrUtils, DateUtils, DateUtil;

Procedure FillMonitorInfo;
Var
  CntrAdapter     : Cardinal;
  CntrMonitor     : Cardinal;
  InfoAdapter     : TMyDisplayDevice;
  InfoMonitor     : TMyDisplayDevice;
  AdapterName : PChar;
  Reg:TRegistry;
  DRIVER_KEY:string;
  MasterKeys: TStringList;
  ChildKeys: TStringList;
  tmpStrings: TStringList;
  i,j,k,l: integer;
  EDID_Buffer: array [0..2000] of char;
  EDID_Size:integer;
  tmpBufferWC: array [0..2000] of WideChar;
  tmpBufferDW: DWORD;
  tmpC:char;
  CheckSum:byte;
  EDID_Version:integer;
  EDID_Revision:integer;
  Diagonal: integer;
  tmpS:string;
  NameFE,NameFC:string;
  PixelClock: integer;
  Hsm, Vsm:integer;


Begin

  // ---------------------------------------------
  // вывод на экран тестового сообщения
  WriteToTestLog('=== Информация о мониторах');
  // ---------------------------------------------

  Res[1].Hres:=720;
  Res[1].Vres:=400;
  Res[1].Hz:=70;
  Res[1].EDID_Byte:=$23;
  Res[1].EDID_Bit:=128;

  Res[2].Hres:=720;
  Res[2].Vres:=400;
  Res[2].Hz:=88;
  Res[2].EDID_Byte:=$23;
  Res[2].EDID_Bit:=64;

  Res[3].Hres:=640;
  Res[3].Vres:=480;
  Res[3].Hz:=60;
  Res[3].EDID_Byte:=$23;
  Res[3].EDID_Bit:=32;

  Res[4].Hres:=640;
  Res[4].Vres:=480;
  Res[4].Hz:=67;
  Res[4].EDID_Byte:=$23;
  Res[4].EDID_Bit:=16;

  Res[5].Hres:=640;
  Res[5].Vres:=480;
  Res[5].Hz:=72;
  Res[5].EDID_Byte:=$23;
  Res[5].EDID_Bit:=8;

  Res[6].Hres:=640;
  Res[6].Vres:=480;
  Res[6].Hz:=75;
  Res[6].EDID_Byte:=$23;
  Res[6].EDID_Bit:=4;

  Res[7].Hres:=800;
  Res[7].Vres:=600;
  Res[7].Hz:=56;
  Res[7].EDID_Byte:=$23;
  Res[7].EDID_Bit:=2;

  Res[8].Hres:=800;
  Res[8].Vres:=600;
  Res[8].Hz:=60;
  Res[8].EDID_Byte:=$23;
  Res[8].EDID_Bit:=1;


  Res[9].Hres:=800;
  Res[9].Vres:=600;
  Res[9].Hz:=72;
  Res[9].EDID_Byte:=$24;
  Res[9].EDID_Bit:=128;

  Res[10].Hres:=800;
  Res[10].Vres:=600;
  Res[10].Hz:=75;
  Res[10].EDID_Byte:=$24;
  Res[10].EDID_Bit:=64;

  Res[11].Hres:=832;
  Res[11].Vres:=624;
  Res[11].Hz:=75;
  Res[11].EDID_Byte:=$24;
  Res[11].EDID_Bit:=32;

  Res[12].Hres:=1024;
  Res[12].Vres:=768;
  Res[12].Hz:=87;
  Res[12].EDID_Byte:=$24;
  Res[12].EDID_Bit:=16;

  Res[13].Hres:=1024;
  Res[13].Vres:=768;
  Res[13].Hz:=60;
  Res[13].EDID_Byte:=$24;
  Res[13].EDID_Bit:=8;

  Res[14].Hres:=1024;
  Res[14].Vres:=768;
  Res[14].Hz:=70;
  Res[14].EDID_Byte:=$24;
  Res[14].EDID_Bit:=4;

  Res[15].Hres:=1024;
  Res[15].Vres:=768;
  Res[15].Hz:=75;
  Res[15].EDID_Byte:=$24;
  Res[15].EDID_Bit:=2;

  Res[16].Hres:=1280;
  Res[16].Vres:=1024;
  Res[16].Hz:=75;
  Res[16].EDID_Byte:=$24;
  Res[16].EDID_Bit:=1;

  Res[17].Hres:=1152;
  Res[17].Vres:=870;
  Res[17].Hz:=75;
  Res[17].EDID_Byte:=$25;
  Res[17].EDID_Bit:=128;

  ResCount:=17;

  // Открываем реестр
  Reg:=TRegistry.Create(KEY_READ);
  MasterKeys:=TStringList.Create;
  ChildKeys:=TStringList.Create;
  tmpStrings:=TStringList.Create;

  // Определяем перечень адаптеров и мониторов
  MonitorCount:=0;
  CntrAdapter := 0;
  InfoAdapter.cb := SizeOf(InfoAdapter);
  While MyEnumDisplayDevices(Nil, CntrAdapter, InfoAdapter, 0) Do
  Begin

    // ---------------------------------------------
    // вывод на экран тестового сообщения
    WriteToTestLog('=== Adapter.DeviceName='+InfoAdapter.DeviceName);
    if (( InfoAdapter.StateFlags And DISPLAY_DEVICE_MIRRORING_DRIVER ) = DISPLAY_DEVICE_MIRRORING_DRIVER) then WriteToTestLog('=== MIRRORING DRIVER');
    // ---------------------------------------------

    If (( InfoAdapter.StateFlags And DISPLAY_DEVICE_MIRRORING_DRIVER ) <> DISPLAY_DEVICE_MIRRORING_DRIVER) or TestLog Then
    Begin
      CntrMonitor := 0;
      InfoMonitor.cb := SizeOf(InfoMonitor);
      AdapterName := StrAlloc(SizeOf(InfoAdapter.DeviceName));
      StrCopy(AdapterName, InfoAdapter.DeviceName);

      While MyEnumDisplayDevices(AdapterName, CntrMonitor, InfoMonitor, 0) Do
      Begin

        // ---------------------------------------------
        // вывод на экран тестового сообщения
        WriteToTestLog('=== Monitor.DeviceName='+InfoMonitor.DeviceName);
        if (( InfoMonitor.StateFlags And DISPLAY_DEVICE_MIRRORING_DRIVER ) = DISPLAY_DEVICE_MIRRORING_DRIVER) then WriteToTestLog('=== MIRRORING DRIVER');
        // ---------------------------------------------

        If (( InfoMonitor.StateFlags And DISPLAY_DEVICE_MIRRORING_DRIVER ) <> DISPLAY_DEVICE_MIRRORING_DRIVER)) or TestLog Then
        Begin
          DRIVER_KEY:='';
          EDID_Size:=0;
          tmpBufferDW:=0;
          CheckSum:=0;
          EDID_Version:=0;
          EDID_Revision:=0;
          Diagonal:=0;
          tmpS:='';


          inc(MonitorCount);
          MonitorInfo[MonitorCount].NETBIOS_NAME:=Copy(ComputerName,1,100);

          // информация о видеоадаптере
          MonitorInfo[MonitorCount].ADAPTER_DEVICE_ID:=Copy(InfoAdapter.DeviceID,1,100);
          MonitorInfo[MonitorCount].ADAPTER_NAME:=Copy(InfoAdapter.DeviceName,1,100);
          tmpS:=InfoAdapter.DeviceKey;

          // ---------------------------------------------
          // вывод на экран тестового сообщения
          WriteToTestLog('=== Adapter.DeviceKey='+InfoAdapter.DeviceKey);
          // ---------------------------------------------

          if tmpS<>'' then
          Begin
            tmpS:=StrUtils.AnsiReplaceStr(AnsiUpperCase(tmpS),'\REGISTRY\MACHINE\','');
            MonitorInfo[MonitorCount].ADAPTER_REGISTRY_KEY:=Copy(tmpS,1,150);

            // ---------------------------------------------
            // вывод на экран тестового сообщения
            WriteToTestLog('=== Открываем реестр с описанием адаптера '+tmpS);
            // ---------------------------------------------

            Reg.RootKey:=HKEY_LOCAL_MACHINE;
            if Reg.OpenKeyReadOnly(tmpS) then
            Begin

              // ---------------------------------------------
              // вывод на экран тестового сообщения
              WriteToTestLog('=== Открыт реестр '+tmpS);
              Reg.GetKeyNames(tmpStrings);
              WriteToTestLog('=== Keys:');
              WriteToTestLog(tmpStrings.Text);
{                Reg.GetValueNames(tmpStrings);
              WriteToTestLog('=== Values:');
              WriteToTestLog(tmpStrings.Text);}
              // ---------------------------------------------

              if Reg.GetDataType('HardwareInformation.AdapterString')=rdString then
                MonitorInfo[MonitorCount].ADAPTER_NAME:=Copy(Reg.ReadString('HardwareInformation.AdapterString'),1,100);
              if Reg.GetDataType('HardwareInformation.AdapterString')=rdBinary then
              try
                Reg.ReadBinaryData('HardwareInformation.AdapterString',tmpBufferWC,SizeOf(tmpBufferWC));
                tmpS:=Trim(WideCharToString(tmpBufferWC));
                if tmpS<>'' then MonitorInfo[MonitorCount].ADAPTER_NAME:=Copy(tmpS,1,100);
              except
              end;
              MonitorInfo[MonitorCount].ADAPTER_MANUFACTURER:=Copy(Reg.ReadString('ProviderName'),1,50);

              // ---------------------------------------------
              // вывод на экран тестового сообщения
              WriteToTestLog('=== Adapter.DriverDate='+Reg.ReadString('DriverDate'));
              // ---------------------------------------------

              tmpS:=Trim(Reg.ReadString('DriverDate'));

              if tmpS<>'' then
              try
                tmpS:=FormatDateTime('dd.mm.yyyy',StrToDateFmt('mm-dd-yyyy',tmpS));
              except
                try
                  tmpS:=FormatDateTime('dd.mm.yyyy',StrToDateFmt('m-dd-yyyy',tmpS));
                except
                  try
                    tmpS:=FormatDateTime('dd.mm.yyyy',StrToDateFmt('mm-d-yyyy',tmpS));
                  except
                    try
                      tmpS:=FormatDateTime('dd.mm.yyyy',StrToDateFmt('m-d-yyyy',tmpS));
                    except
                      tmpS:='';
                    end;
                  end;
                end;
              end;

              MonitorInfo[MonitorCount].ADAPTER_DRIVER_DATE:=Copy(tmpS,1,20);
              MonitorInfo[MonitorCount].ADAPTER_DRIVER_VERSION:=Copy(Reg.ReadString('DriverVersion'),1,50);
              if Reg.GetDataType('HardwareInformation.BiosString')=rdString then
                MonitorInfo[MonitorCount].ADAPTER_HARDWARE_VERSION:=Copy(Reg.ReadString('HardwareInformation.BiosString'),1,50);
              if Reg.GetDataType('HardwareInformation.BiosString')=rdBinary then
              try
                Reg.ReadBinaryData('HardwareInformation.BiosString',tmpBufferWC,SizeOf(tmpBufferWC));
                MonitorInfo[MonitorCount].ADAPTER_HARDWARE_VERSION:=Copy(WideCharToString(tmpBufferWC),1,50);
              except
                MonitorInfo[MonitorCount].ADAPTER_HARDWARE_VERSION:='';
              end;
              if Reg.GetDataType('HardwareInformation.MemorySize')=rdInteger then
                MonitorInfo[MonitorCount].ADAPTER_HARDWARE_MEMORY:=Reg.ReadInteger('HardwareInformation.MemorySize') div 1024 div 1024;
              if Reg.GetDataType('HardwareInformation.MemorySize')=rdBinary then
              try
                Reg.ReadBinaryData('HardwareInformation.MemorySize',tmpBufferDW,4);
                MonitorInfo[MonitorCount].ADAPTER_HARDWARE_MEMORY:=tmpBufferDW div 1024 div 1024;
              except
                MonitorInfo[MonitorCount].ADAPTER_HARDWARE_MEMORY:=0;
              end;

            End;
            Reg.CloseKey;
          end;
          If ( InfoAdapter.StateFlags And DISPLAY_DEVICE_ATTACHED_TO_DESKTOP ) = DISPLAY_DEVICE_ATTACHED_TO_DESKTOP Then
          Begin
            MonitorInfo[MonitorCount].ADAPTER_ATTACHED:=1;
          end
          else
          Begin
            MonitorInfo[MonitorCount].ADAPTER_ATTACHED:=0;
          end;
          If ( InfoAdapter.StateFlags And DISPLAY_DEVICE_PRIMARY_DEVICE ) = DISPLAY_DEVICE_PRIMARY_DEVICE Then
          Begin
            MonitorInfo[MonitorCount].ADAPTER_PRIMARY:=1;
          end
          else
          Begin
            MonitorInfo[MonitorCount].ADAPTER_PRIMARY:=0;
          end;

          // информация о мониторе
          MonitorInfo[MonitorCount].MONITOR_DEVICE_ID:=Copy(InfoMonitor.DeviceID,1,100);
          MonitorInfo[MonitorCount].MONITOR_NAME:=Copy(InfoMonitor.DeviceName,1,100);
          DRIVER_KEY:=InfoMonitor.DeviceKey;

          // ---------------------------------------------
          // вывод на экран тестового сообщения
          WriteToTestLog('=== Monitor.DeviceKey='+InfoMonitor.DeviceKey);
          // ---------------------------------------------

          if DRIVER_KEY<>'' then
          Begin
            DRIVER_KEY:=StrUtils.AnsiReplaceStr(AnsiUpperCase(DRIVER_KEY),'\REGISTRY\MACHINE\','');
            MonitorInfo[MonitorCount].MONITOR_REGISTRY_KEY:=Copy(DRIVER_KEY,1,150);

            // ---------------------------------------------
            // вывод на экран тестового сообщения
            WriteToTestLog('=== Открываем реестр '+DRIVER_KEY);
            // ---------------------------------------------

            Reg.RootKey:=HKEY_LOCAL_MACHINE;
            if Reg.OpenKeyReadOnly(DRIVER_KEY) then
            Begin
              // ---------------------------------------------
              // вывод на экран тестового сообщения
              WriteToTestLog('=== Открыт реестр '+DRIVER_KEY);
              Reg.GetKeyNames(tmpStrings);
              WriteToTestLog('=== Keys:');
              WriteToTestLog(tmpStrings.Text);
{                Reg.GetValueNames(tmpStrings);
              WriteToTestLog('=== Values:');
              WriteToTestLog(tmpStrings.Text);}
              // ---------------------------------------------

              MonitorInfo[MonitorCount].MONITOR_MANUFACTURER:=Copy(Reg.ReadString('ProviderName'),1,50);

              // ---------------------------------------------
              // вывод на экран тестового сообщения
              WriteToTestLog('=== Monitor.DriverDate='+Reg.ReadString('DriverDate'));
              // ---------------------------------------------

              tmpS:=Trim(Reg.ReadString('DriverDate'));

              if tmpS<>'' then
              try
                tmpS:=FormatDateTime('dd.mm.yyyy',StrToDateFmt('mm-dd-yyyy',tmpS));
              except
                try
                  tmpS:=FormatDateTime('dd.mm.yyyy',StrToDateFmt('m-dd-yyyy',tmpS));
                except
                  try
                    tmpS:=FormatDateTime('dd.mm.yyyy',StrToDateFmt('mm-d-yyyy',tmpS));
                  except
                    try
                      tmpS:=FormatDateTime('dd.mm.yyyy',StrToDateFmt('m-d-yyyy',tmpS));
                    except
                      tmpS:='';
                    end;
                  end;
                end;
              end;

              MonitorInfo[MonitorCount].MONITOR_DRIVER_DATE:=Copy(tmpS,1,20);
              MonitorInfo[MonitorCount].MONITOR_DRIVER_VERSION:=Copy(Reg.ReadString('DriverVersion'),1,50);
              DRIVER_KEY:=StrUtils.AnsiReplaceStr(AnsiUpperCase(DRIVER_KEY),'SYSTEM\CURRENTCONTROLSET\CONTROL\CLASS\','');
            End;
            Reg.CloseKey;
            Reg.RootKey:=HKEY_LOCAL_MACHINE;


            // ---------------------------------------------
            // вывод на экран тестового сообщения
            WriteToTestLog('=== Ищем драйвер '+DRIVER_KEY+' для монитора '+MonitorInfo[MonitorCount].MONITOR_NAME);
            // ---------------------------------------------

            // ---------------------------------------------
            // вывод на экран тестового сообщения
            WriteToTestLog('=== Открываем реестр System\CurrentControlSet\Enum\DISPLAY');
            // ---------------------------------------------

            if Reg.OpenKeyReadOnly('System\CurrentControlSet\Enum\DISPLAY') then
            Begin

              // ---------------------------------------------
              // вывод на экран тестового сообщения
              WriteToTestLog('=== Открыт реестр System\CurrentControlSet\Enum\DISPLAY');
              Reg.GetKeyNames(tmpStrings);
              WriteToTestLog('=== Keys:');
              WriteToTestLog(tmpStrings.Text);
{                Reg.GetValueNames(tmpStrings);
              WriteToTestLog('=== Values:');
              WriteToTestLog(tmpStrings.Text);}
              // ---------------------------------------------

              Reg.GetKeyNames(MasterKeys);
              Reg.CloseKey;
              EDID_Size:=0;

              for i:=0 to MasterKeys.Count-1 do
              Begin
                if EDID_Size>0 then break;
                Reg.RootKey:=HKEY_LOCAL_MACHINE;

                // ---------------------------------------------
                // вывод на экран тестового сообщения
                WriteToTestLog('=== Открываем реестр System\CurrentControlSet\Enum\DISPLAY\'+MasterKeys[i]);
                // ---------------------------------------------

                if Reg.OpenKeyReadOnly('System\CurrentControlSet\Enum\DISPLAY\'+MasterKeys[i]) then
                Begin


                  // ---------------------------------------------
                  // вывод на экран тестового сообщения
                  WriteToTestLog('=== Открыт реестр System\CurrentControlSet\Enum\DISPLAY\'+MasterKeys[i]);
                  Reg.GetKeyNames(tmpStrings);
                  WriteToTestLog('=== Keys:');
                  WriteToTestLog(tmpStrings.Text);
{                    Reg.GetValueNames(tmpStrings);
                  WriteToTestLog('=== Values:');
                  WriteToTestLog(tmpStrings.Text);}
                  // ---------------------------------------------

                  Reg.GetKeyNames(ChildKeys);
                  Reg.CloseKey;

                  for j:=0 to ChildKeys.Count-1 do
                  Begin
                    if EDID_Size>0 then break;
                    Reg.RootKey:=HKEY_LOCAL_MACHINE;

                    // ---------------------------------------------
                    // вывод на экран тестового сообщения
                    WriteToTestLog('=== Открываем реестр System\CurrentControlSet\Enum\DISPLAY\'+MasterKeys[i]+'\'+ChildKeys[j]);
                    // ---------------------------------------------

                    if Reg.OpenKeyReadOnly('System\CurrentControlSet\Enum\DISPLAY\'+MasterKeys[i]+'\'+ChildKeys[j]) then
                    Begin

                      // ---------------------------------------------
                      // вывод на экран тестового сообщения
                      WriteToTestLog('=== Открыт реестр System\CurrentControlSet\Enum\DISPLAY\'+MasterKeys[i]+'\'+ChildKeys[j]);
                      Reg.GetKeyNames(tmpStrings);
                      WriteToTestLog('=== Keys:');
                      WriteToTestLog(tmpStrings.Text);
{                        Reg.GetValueNames(tmpStrings);
                      WriteToTestLog('=== Values:');
                      WriteToTestLog(tmpStrings.Text);}
                      // ---------------------------------------------

                      if AnsiUpperCase(DRIVER_KEY)=AnsiUpperCase(Reg.ReadString('Driver')) then
                      begin

                        // ---------------------------------------------
                        // вывод на экран тестового сообщения
                        WriteToTestLog('=== Драйвер '+DRIVER_KEY+' найден в реестре System\CurrentControlSet\Enum\DISPLAY\'+MasterKeys[i]+'\'+ChildKeys[j]);
                        // ---------------------------------------------

                        if Reg.OpenKeyReadOnly('Device Parameters') then
                        Begin

                          // Прочитаем EDID
                          EDID_Size:=Reg.ReadBinaryData('EDID',EDID_Buffer,2000);

                          // ---------------------------------------------
                          // вывод на экран тестового сообщения
                          if (EDID_Size>0) then
                          Begin
                            WriteToTestLog('=== обнаружен EDID: ');
                            for k:=1 to 128 do WriteToTestLog('=== Hex '+IntToHex(k,2)+' Dec '+IntToStr(k)+CHR(9)+' = Bin '+ByteToBin(ORD(EDID_Buffer[k]))+' Hex '+IntToHex(ORD(EDID_Buffer[k]),2)+' CHR '+EDID_Buffer[k]+' Dec '+IntToStr(ORD(EDID_Buffer[k])));
                          end;
                          // ---------------------------------------------


                          // Проверим контрольную сумму
                          CheckSum:=0;
                          for k:=0 TO EDID_Size-1 do CheckSum:=CheckSum + ORD(EDID_Buffer[k]);


                          IF (EDID_Size>0) AND (CheckSum=0) then
                          Begin
                            if (ORD(EDID_Buffer[$0])=$00) and
                               (ORD(EDID_Buffer[$1])=$FF) and
                               (ORD(EDID_Buffer[$2])=$FF) and
                               (ORD(EDID_Buffer[$3])=$FF) and
                               (ORD(EDID_Buffer[$4])=$FF) and
                               (ORD(EDID_Buffer[$5])=$FF) and
                               (ORD(EDID_Buffer[$6])=$FF) and
                               (ORD(EDID_Buffer[$7])=$00) and
                               (ORD(EDID_Buffer[$12])=$01) then
                            Begin

                              // ---------------------------------------------
                              // вывод на экран тестового сообщения
                              WriteToTestLog('=== EDID корректный');
                              // ---------------------------------------------

                              EDID_Version:=ORD(EDID_Buffer[$12]);
                              EDID_Revision:=ORD(EDID_Buffer[$13]);

//                              tmpS:='';
//                              for k:=1 to EDID_Size do tmpS:=tmpS+EDID_Buffer[k];

                              MonitorInfo[MonitorCount].MONITOR_EDID:='EDID='+IntToStr(EDID_Version)+'.'+IntToStr(EDID_Revision);

                              // ---------------------------------------------
                              // вывод на экран тестового сообщения
                              WriteToTestLog('=== версия EDID='+IntToStr(EDID_Version)+'.'+IntToStr(EDID_Revision));
                              // ---------------------------------------------

                              try
                                MonitorInfo[MonitorCount].MONITOR_HARDWARE_DATE:=FormatDateTime('dd.mm.yyyy',EncodeDateWeek(1990+ORD(EDID_Buffer[$11]),ORD(EDID_Buffer[$10])));
                              except
                                MonitorInfo[MonitorCount].MONITOR_HARDWARE_DATE:='';
                              end;

//                              MonitorInfo[MonitorCount].MONITOR_PRODUCT_ID:=IntToStr(ORD(EDID_Buffer[$B])*256+ORD(EDID_Buffer[$A]));
//                              MonitorInfo[MonitorCount].MONITOR_MANUFACTURER_ID:=IntToStr(ORD(EDID_Buffer[$9])*256+ORD(EDID_Buffer[$8]));
                              tmpS:='   ';
                              tmpS[1]:=CHR((ORD(EDID_Buffer[$8]) AND 124) DIV 4+ORD('A')-1);
                              tmpS[2]:=CHR((ORD(EDID_Buffer[$8]) AND 3)*8+(ORD(EDID_Buffer[$9]) AND 224) DIV 32+ORD('A')-1);
                              tmpS[3]:=CHR((ORD(EDID_Buffer[$9]) AND 31)+ORD('A')-1);
                              if MonitorInfo[MonitorCount].MONITOR_MANUFACTURER='Microsoft' then
                                 MonitorInfo[MonitorCount].MONITOR_MANUFACTURER:=tmpS;


                              PixelClock:=(ORD(EDID_Buffer[$37])*256+ORD(EDID_Buffer[$36]))*10 div 1000;
                              Hsm:=((ORD(EDID_Buffer[$44]) shr 4)*256+ORD(EDID_Buffer[$42])) div 10;
                              Vsm:=((ORD(EDID_Buffer[$44]) and 15)*256+ORD(EDID_Buffer[$43])) div 10;
                              // ---------------------------------------------
                              // вывод на экран тестового сообщения
                              WriteToTestLog('=== PixelClock='+IntToStr(PixelClock)+' MHz');
                              WriteToTestLog('=== Hsm='+IntToStr(Hsm));
                              WriteToTestLog('=== Vsm='+IntToStr(Vsm));
                              // ---------------------------------------------

                              if (ORD(EDID_Buffer[$15])<>$00) and
                                 (ORD(EDID_Buffer[$16])<>$00) and
                                 (ORD(EDID_Buffer[$15])<>$FF) and
                                 (ORD(EDID_Buffer[$16])<>$FF) then
                              Begin
                                Hsm:=ORD(EDID_Buffer[$15]);
                                Vsm:=ORD(EDID_Buffer[$16]);
                                WriteToTestLog('=== MAX Hsm='+IntToStr(Hsm));
                                WriteToTestLog('=== MAX Vsm='+IntToStr(Vsm));
                              End;
                              Diagonal:=Round(sqrt(Hsm*Hsm+Vsm*Vsm) / 2.54);

                              if Diagonal>0 then
                                MonitorInfo[MonitorCount].MONITOR_IMAGE_SIZE:=IntToStr(Hsm)+' sm x '+IntToStr(Vsm) + ' sm = ' + FloatToStr(Diagonal)+' inch'
                              else
                                MonitorInfo[MonitorCount].MONITOR_IMAGE_SIZE:='unknown';

                              // Определяем максимальное разрешение
                              maxRes:=0;
                              maxI:=0;
                              for k:=1 to resCount do
                              Begin
                                if (ORD(EDID_Buffer[Res[k].EDID_Byte]) AND Res[k].EDID_Bit) = Res[k].EDID_Bit then
                                Begin
                                  // ---------------------------------------------
                                  // вывод на экран тестового сообщения
                                  WriteToTestLog('=== поддерживается разрешение '+IntToStr(Res[k].HRes)+' x '+IntToStr(Res[k].VRes));
                                  // ---------------------------------------------
                                  if (Res[k].Hres*Res[k].Vres)>maxRes then
                                  Begin
                                    maxRes:=Res[k].Hres*Res[k].Vres;
                                    maxI:=k;
                                  end;
                                  // ---------------------------------------------
                                  // вывод на экран тестового сообщения
                                  WriteToTestLog('=== Максимальное разрешение '+IntToStr(Res[maxI].HRes)+' x '+IntToStr(Res[maxI].VRes));
                                  // ---------------------------------------------
                                End
                                Else
                                Begin
                                  // разрешение не поддерживается
                                  Res[k].HRes:=0;
                                  Res[k].VRes:=0;
                                End;
                              end;

                              for k:=0 to 7 do
                              Begin
                                // ---------------------------------------------
                                // вывод на экран тестового сообщения
                                WriteToTestLog('=== EDID Timings= '+IntToStr(ORD(EDID_Buffer[$26+2*k]))+' '+IntToStr(ORD(EDID_Buffer[$27+2*k])));
                                // ---------------------------------------------
                                if (ORD(EDID_Buffer[$26+2*k])<>$00) and
                                   (ORD(EDID_Buffer[$26+2*k])<>$01) and
                                   (ORD(EDID_Buffer[$26+2*k])<>$20) then
                                Begin
                                  inc(resCount);
                                  Res[resCount].Hres:=ORD(EDID_Buffer[$26+2*k])*8+248;
                                  Res[resCount].VRes:=Res[resCount].HRes;
                                  if ((ORD(EDID_Buffer[$27+2*k]) AND 192)=0) and (EDID_Revision>=3) then Res[resCount].VRes:=(Res[resCount].Hres div 16)*10;
                                  if (ORD(EDID_Buffer[$27+2*k]) AND 192)=64 then Res[resCount].Vres:=(Res[resCount].Hres div 4)*3;
                                  if (ORD(EDID_Buffer[$27+2*k]) AND 192)=128 then Res[resCount].Vres:=(Res[resCount].Hres div 5)*4;
                                  if (ORD(EDID_Buffer[$27+2*k]) AND 192)=192 then Res[resCount].Vres:=(Res[resCount].Hres div 16)*9;

                                  // ---------------------------------------------
                                  // вывод на экран тестового сообщения
                                  WriteToTestLog('=== поддерживается разрешение '+IntToStr(Res[resCount].HRes)+' x '+IntToStr(Res[resCount].VRes));
                                  // ---------------------------------------------

                                  if (Res[resCount].Hres*Res[resCount].Vres)>maxRes then
                                  Begin
                                    maxRes:=Res[resCount].Hres*Res[resCount].Vres;
                                    maxI:=resCount;
                                  end;
                                  // ---------------------------------------------
                                  // вывод на экран тестового сообщения
                                  WriteToTestLog('=== Максимальное разрешение '+IntToStr(Res[maxI].HRes)+' x '+IntToStr(Res[maxI].VRes));
                                  // ---------------------------------------------
                                end;
                              end;

                              if MaxI>0 then
                                MonitorInfo[MonitorCount].MONITOR_RESOLUTION:=IntToStr(Res[maxI].Hres)+' x '+IntToStr(Res[maxI].Vres)
                              else
                                MonitorInfo[MonitorCount].MONITOR_RESOLUTION:='unknown';

                              NameFC:='';
                              NameFE:='';

                              for k:=0 to 3 do
                              Begin
                                if (ORD(EDID_Buffer[$36+k*18])=$00) and
                                   (ORD(EDID_Buffer[$36+k*18+1])=$00) and
                                   (ORD(EDID_Buffer[$36+k*18+2])=$00) and
                                   (ORD(EDID_Buffer[$36+k*18+4])=$00) then
                                begin
                                  tmpS:='';
                                  for l:=5 to 17 do
                                  Begin
                                    tmpC:=EDID_Buffer[$36+k*18+l];
                                    if (ORD(tmpC)=$0A) then break;
                                    tmpS:=tmpS+tmpC;
                                  end;
                                  tmpS:=Trim(tmpS);
                                  if (ORD(EDID_Buffer[$36+k*18+3])=$FC) and (tmpS<>'') then
                                  Begin
                                    NameFC:=Trim(NameFC+' '+tmpS);
                                    // ---------------------------------------------
                                    // вывод на экран тестового сообщения
                                    WriteToTestLog('=== EDID MONITOR NAME='+NameFC);
                                    // ---------------------------------------------
                                  end;
                                  if (ORD(EDID_Buffer[$36+k*18+3])=$FE) and (tmpS<>'') then
                                  Begin
                                    NameFE:=Trim(NameFE+' '+tmpS);
                                    // ---------------------------------------------
                                    // вывод на экран тестового сообщения
                                    WriteToTestLog('=== EDID ASCII String='+NameFE);
                                    // ---------------------------------------------
                                  end;
                                  if (ORD(EDID_Buffer[$36+k*18+3])=$FF) then
                                  Begin
                                    MonitorInfo[MonitorCount].MONITOR_SERIAL_NUMBER:=Copy(Trim(tmpS),1,50);
                                  end;
                                end;
                              End;
                              IF NameFC<>'' then
                                MonitorInfo[MonitorCount].MONITOR_NAME:=Copy(NameFC,1,100)
                              else if NameFE<>'' then
                                MonitorInfo[MonitorCount].MONITOR_NAME:=Copy(NameFE,1,100);
                            end;
                          End;
                        end;
                      End;
                    End;
                    Reg.CloseKey;
                  End;
                End;
              End;
            End;

          end;
          If ( InfoMonitor.StateFlags And DISPLAY_DEVICE_ATTACHED_TO_DESKTOP ) = DISPLAY_DEVICE_ATTACHED_TO_DESKTOP Then
          Begin
            MonitorInfo[MonitorCount].MONITOR_ATTACHED:=1;
          end
          else
          Begin
            MonitorInfo[MonitorCount].MONITOR_ATTACHED:=0;
          end;
          If ( InfoMonitor.StateFlags And DISPLAY_DEVICE_PRIMARY_DEVICE ) = DISPLAY_DEVICE_PRIMARY_DEVICE Then
          Begin
            MonitorInfo[MonitorCount].MONITOR_PRIMARY:=1;
          end
          else
          Begin
            MonitorInfo[MonitorCount].MONITOR_PRIMARY:=0;
          end;

        end;
        Inc(CntrMonitor);
      end;

      StrDispose(AdapterName);
    end;
    Inc(CntrAdapter);
  End;

  Reg.Free;
  MasterKeys.Clear;
  MasterKeys.Free;
  ChildKeys.Clear;
  ChildKeys.Free;
  tmpStrings.Clear;
  tmpStrings.Free;
End;


end.
