unit udlgprop;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TFormProp }

  TFormProp = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Memo1: TMemo;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  FormProp: TFormProp;

implementation


{$R *.lfm}

end.

