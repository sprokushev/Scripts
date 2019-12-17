unit MyWin;

interface

uses Windows,
  SysUtils,
  Classes;

type
  PMyDisplayDevice = ^TMyDisplayDevice;
  _MY_DISPLAY_DEVICE = packed record
    cb: DWORD;
    DeviceName: array[0..31] of AnsiChar;
    DeviceString: array[0..127] of AnsiChar;
    StateFlags: DWORD;
    DeviceID: array[0..127] of AnsiChar;
    DeviceKey: array[0..127] of AnsiChar;
  end;
  TMyDisplayDevice = _MY_DISPLAY_DEVICE;

var
  TestLog: boolean;
  FileLog:string;
  FLog:TextFile;
  FileLogOpen: boolean;
  ComputerName: string;

function MyEnumDisplayDevices(Unused: Pointer; iDevNum: DWORD;
  var lpDisplayDevice: TMyDisplayDevice; dwFlags: DWORD): BOOL; stdcall;

function ByteToBin(btValue: Byte): string;
function WordToBin(btValue: integer): string;

// значение параметра
function ParamStrByName(ParamName:string):string;
function ParamExist(ParamName:string):boolean;


// Вернуть имя компьютера
function GetTerminalName(Upper:Boolean):String;

{ Дополнить маршрут к файлу }
function FillFilePath(f_name:string; IsCheck:boolean):string;


procedure OpenTestLog;
procedure WriteToTestLog(pText:string);
procedure CloseTestLog;


function ConvertOemToAnsi(const S : string) : string;
function ConvertAnsiToOem(const S : string) : string;

implementation

function MyEnumDisplayDevices; external 'user32.dll' name 'EnumDisplayDevicesA';

function ConvertOemToAnsi(const S : string) : string;
{ ConvertOemToAnsi translates a string from the OEM-defined
  character set into either an ANSI or a wide-character string }
{$IFNDEF WIN32}
var
  Source, Dest : array[0..255] of Char;
{$ENDIF}
begin
{$IFDEF WIN32}
  SetLength(Result, Length(S));
  if Length(Result) > 0 then
    OemToAnsi(PChar(S), PChar(Result));
{$ELSE}
  if Length(Result) > 0 then
  begin
    OemToAnsi(StrPCopy(Source, S), Dest);
    Result := StrPas(Dest);
  end;
{$ENDIF}
end; { ConvertOemToAnsi }

function ConvertAnsiToOem(const S : string) : string;
{ ConvertAnsiToOem translates a string into the OEM-defined character set }
{$IFNDEF WIN32}
var
  Source, Dest : array[0..255] of Char;
{$ENDIF}
begin
{$IFDEF WIN32}
  SetLength(Result, Length(S));
  if Length(Result) > 0 then
    AnsiToOem(PChar(S), PChar(Result));
{$ELSE}
  if Length(Result) > 0 then
  begin
    AnsiToOem(StrPCopy(Source, S), Dest);
    Result := StrPas(Dest);
  end;
{$ENDIF}
end; { ConvertAnsiToOem }


procedure OpenTestLog;
Begin
  {$I-}
  AssignFile(FLog,FileLog);
  FileMode := 2;
  Rewrite(FLog);
  {$I+}
  FileLogOpen:=(IOResult = 0)
End;

procedure CloseTestLog;
Begin
  if FileLogOpen then
  Close(Flog);
End;

procedure WriteToTestLog(pText:string);
var F:TextFile;
Begin
  if TestLog then
  Begin
    WriteLn(pText);
  End;
  if FileLogOpen then
  Begin
    WriteLn(FLog,pText);
  end;
End;


function ByteToBin(btValue: Byte): string;
     function Next(btJ: Byte): string;
     begin
       if btValue and btJ = 0 then
         Result := '0'
       else
         Result := '1';
     end;
begin
  Result := Next(128) + Next(64) + Next(32) + Next(16) + Next(8) + Next(4) + Next(2) + Next(1);
end;

function WordToBin(btValue: integer): string;
     function Next(btJ: integer): string;
     begin
       if btValue and btJ = 0 then
         Result := '0'
       else
         Result := '1';
     end;
begin
  Result := Next($8000) + Next($4000) + Next($2000) + Next($1000) + Next($800) + Next($400) + Next($200) + Next($100)+
            Next($80) + Next($40) + Next($20) + Next($10) + Next($8) + Next($4) + Next($2) + Next($1);
end;


// Вернуть имя компьютера
function GetTerminalName(Upper:Boolean):String;
var
  TermName:String[150];
  Len:DWord;
begin
  FillChar(TermName,150,0);
  Len:=100;
  Windows.GetComputerNameA(@TermName[1],Len);
  TermName[0]:=Chr(Len);
  Result:=TermName;
  if Upper then
    Result:=ANSIUpperCase(TermName);
end;

// значение параметра
function ParamStrByName(ParamName:string):string;
var
  i,j: Integer;
  s: string;
Begin
  Result:='';
  for i := 1 to ParamCount do
  begin
    s:=LowerCase(ParamStr(i));
    if length(s)>0 then
    Begin
      if (s[1]='/') or (s[1]='\') then s:=System.copy(s,2,999);
      if Pos(LowerCase(ParamName)+'=',s) =  1 then
      Begin
        j:=Length(ParamName)+2;
        Result:=Copy(s,j,999);
        exit;
      End;
    end;
  end;
End;


function ParamExist(ParamName:string):boolean;
var
  i,j: Integer;
  s: string;
Begin
  Result:=false;
  for i := 1 to ParamCount do
  begin
    s:=LowerCase(ParamStr(i));
    if length(s)>0 then
    Begin
      if (s[1]='/') or (s[1]='\') then s:=System.copy(s,2,999);
      j:=Pos('=',s);
      if j>0 then s:=Copy(s,1,j-1);
      if s=LowerCase(ParamName) then
      begin
        Result:=true;
        exit;
      End;
    end;
  end;
End;

{ Дополнить маршрут к файлу }
function FillFilePath(f_name:string; IsCheck:boolean):string;
var i:integer;
Begin
  if f_name='' then
    Result:=''
  else
  Begin
    if f_name[Length(f_name)]<>'\' then f_name:=f_name+'\';
    If IsCheck Then
    Begin
      {Проверить наличие и создать каталог}
      CreateDir(f_name);
    End;
    Result:=f_name;
  end;
End;


end.
