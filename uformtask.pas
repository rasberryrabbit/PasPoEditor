unit uFormTask;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  LMessages;

const
  LM_MSG_Progress = LM_USER + 2000;

type

  { TFormTaskProg }

  TFormTaskProg = class(TForm)
    ButtonCancel: TButton;
    Label1: TLabel;
    ProgressBar1: TProgressBar;
    procedure ButtonCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FLastTime:LongWord;
    FCancelPressed:Boolean;
    FWorker: TNotifyEvent;

    function GetCancelRes: Boolean;
    function GetPos: Integer;
    procedure SetPos(AValue: Integer);
    procedure SetWorker(AValue: TNotifyEvent);
  protected
    procedure IncMessage(var Msg); message LM_MSG_Progress;
  public
    function IncPos:Boolean;

    property Position:Integer read GetPos write SetPos;
    property CancelRes:Boolean read GetCancelRes;
  end;

var
  FormTaskProg: TFormTaskProg;

implementation

{$R *.lfm}

uses
  DefaultTranslator, LCLMessageGlue;


{ TFormTaskProg }

function TFormTaskProg.GetPos: Integer;
begin
  Result:=ProgressBar1.Position;
end;

procedure TFormTaskProg.ButtonCancelClick(Sender: TObject);
begin
  FCancelPressed:=True;
end;

procedure TFormTaskProg.FormCreate(Sender: TObject);
begin
end;

procedure TFormTaskProg.FormShow(Sender: TObject);
begin
  FLastTime:=GetTickCount;
  FCancelPressed:=False;
  ProgressBar1.Position:=0;
end;

function TFormTaskProg.GetCancelRes: Boolean;
begin
  Result:=FCancelPressed;
end;

procedure TFormTaskProg.SetPos(AValue: Integer);
begin
  ProgressBar1.Position:=AValue;
end;

procedure TFormTaskProg.SetWorker(AValue: TNotifyEvent);
begin
  if FWorker=AValue then Exit;
  FWorker:=AValue;
end;

procedure TFormTaskProg.IncMessage(var Msg);
begin
  if ProgressBar1.Position<ProgressBar1.Max then
    ProgressBar1.StepBy(1)
    else
      ProgressBar1.Position:=0;
  Label1.Caption:=StringOfChar('.',ProgressBar1.Position+1);
end;

function TFormTaskProg.IncPos: Boolean;
var
  CurTick, DiffTick:Integer;
begin
  Result:=False;
  CurTick:=GetTickCount;
  if FLastTime>CurTick then
    DiffTick:=longword(-1)-FLastTime+CurTick
    else
      DiffTick:=CurTick-FLastTime;
  if DiffTick>100 then begin
    FLastTime:=CurTick;
    Result:=True;
    SendSimpleMessage(self,LM_MSG_Progress);
    Application.ProcessMessages;
  end;
end;

end.

