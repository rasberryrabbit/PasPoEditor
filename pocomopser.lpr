program pocomopser;

{$mode objfpc}{$H+}

uses
  //heaptrc,
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, rx, lazcontrols, pocomposer_main, uPoReader, uMSTRanAPI, udlgprop,
  udlgshowraw, udlgBingApiInfo, uGoogleTranApi;


{$R *.res}

begin
  Application.Title:='poEditor';
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

