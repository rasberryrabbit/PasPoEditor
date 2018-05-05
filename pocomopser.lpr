program pocomopser;

{$mode objfpc}{$H+}

uses
  //heaptrc,
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, lazcontrols, pocomposer_main, uPoReader, uMSTRanAPI, udlgprop,
  udlgshowraw, udlgBingApiInfo, uGoogleTranApi;


{$R *.res}

begin
  Application.Title:='poEditor';
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TFormPoEditor, FormPoEditor);
  Application.Run;
end.

