unit udlgBingApiInfo;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TFormBingInfo }

  TFormBingInfo = class(TForm)
    ButtonOk: TButton;
    ButtonCancel: TButton;
    EditBingAppName: TEdit;
    EditBingAppSecret: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    procedure ButtonOkClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  FormBingInfo: TFormBingInfo;

implementation

uses pocomposer_main;

{$R *.lfm}

{ TFormBingInfo }

procedure TFormBingInfo.ButtonOkClick(Sender: TObject);
var
  infile : TStringList;
begin
  infile := TStringList.Create;
  try
    infile.Add('bingclientid='+EditBingAppName.Text);
    infile.Add('bingclientsecret='+EditBingAppSecret.Text);
    infile.SaveToFile(ExtractFilePath(ParamStr(0))+ConfigFile);
  finally
    infile.Free;
  end;
end;

end.

