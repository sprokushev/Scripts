program TestSoap;

uses
  ExceptionLog,
  Forms,
  Test in 'Test.pas' {Form1},
  DBClientSvc in 'DBClientSvc.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
