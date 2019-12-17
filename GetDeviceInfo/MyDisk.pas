unit MyDisk;

interface

uses
  Windows, SysUtils;

type
  TDiskInfo=array [1..30] of record
    NETBIOS_NAME:string; // ������� ��� ��
    DISK_NAME:string;
    DISK_TYPE:string;
    DISK_SIZE:integer;
    DISK_FREE:integer;
    DISK_EDID:string; // ��������� ������ (������ ��)
  end;

var
  DiskCount: integer;
  DiskInfo: TDiskInfo;


Procedure FillDiskInfo;

implementation

uses MyWin;

Procedure FillDiskInfo;
var
  i: integer;
  DriveName, DriveInfo: string;
  DType: integer;
  EMode: Word;
Begin
  // ---------------------------------------------
  // ����� �� ����� ��������� ���������
  WriteToTestLog('=== ���������� � ������');
  // ---------------------------------------------

  // ���������� �������� ���������
  DiskCount := 0;

  EMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    for i := ORD('A') to ORD('Z') do
    begin
      // Format a string to represent the root directory.
      DriveName := CHR(i) + ':\';
      { Call the GetDriveType() function which returns an integer
        value representing one of the types shown in the case statement
        below }
      DriveInfo:='';
      try
        DType := GetDriveType(PChar(DriveName));
      except
        DType := 0;
      end;
      { Based on the drive type returned, format a string to add to
        the listbox displaying the various drive types. }
      case DType of
        0: DriveInfo := 'Unknown';
        1: DriveInfo := 'Not exist';
        DRIVE_REMOVABLE: DriveInfo := 'Removable';
        DRIVE_FIXED: DriveInfo := 'Fixed';
        DRIVE_REMOTE: DriveInfo := 'Network';
        DRIVE_CDROM: DriveInfo := 'CD-ROM';
        DRIVE_RAMDISK: DriveInfo := 'RAM';
      end;
      // Only add drive types that can be determined.
      if not ((DType = 0) or (DType = 1)) then
      Begin
        inc(DiskCount);
        DiskInfo[DiskCount].NETBIOS_NAME:=Copy(ComputerName,1,100);
        DiskInfo[DiskCount].DISK_NAME:=CHR(i);
        DiskInfo[DiskCount].DISK_TYPE:=DriveInfo;
        try
          DiskInfo[DiskCount].DISK_SIZE:=DiskSize(i-ORD('A')+1) div 1024 div 1024 div 1024;
        except
          DiskInfo[DiskCount].DISK_SIZE:=0;
        end;
        try
          DiskInfo[DiskCount].DISK_FREE:=DiskFree(i-ORD('A')+1) div 1024 div 1024 div 1024;
        except
          DiskInfo[DiskCount].DISK_FREE:=0;
        end;
      end;
    end;
  finally
    SetErrorMode(EMode);
  end;
End;

end.