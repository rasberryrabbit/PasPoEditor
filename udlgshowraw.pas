unit udlgshowraw;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TFormShowRaw }

  TFormShowRaw = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    procedure Memo1KeyPress(Sender: TObject; var Key: char);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  FormShowRaw: TFormShowRaw;

implementation

{$R *.lfm}

{ TFormShowRaw }

procedure TFormShowRaw.Memo1KeyPress(Sender: TObject; var Key: char);
begin
  if Key=#13 then begin
    Key:=#0;
    Close;
  end;
end;

end.

