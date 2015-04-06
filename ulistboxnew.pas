unit uListBoxNew;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, StdCtrls, LMessages, LazLogger;

type

  { TListBox }

  TListBox = class(Stdctrls.TListBox)
    procedure WndProc(var Message: TLMessage); override;
  end;

implementation

uses LCLType;

procedure TListBox.WndProc(var Message: TLMessage);
begin
  if Message.msg=LM_DRAWITEM then
    with TLMDrawItems(Message).DrawItemStruct^ do begin
      if CtlID=ODT_LISTBOX then
      if (itemAction and ODA_DRAWENTIRE)<>0 then
        debugln('t');
    end;
  inherited;
end;

end.

