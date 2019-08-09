unit uStringListPro;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type

  TStringListProgressCallback = procedure of object;

  { TStringListProgress }

  TStringListProgress = class(TStringList)
    private
      FCallBack:TStringListProgressCallback;
    public
      procedure Sort; override;

      property Callback:TStringListProgressCallback read FCallBack write FCallBack;
  end;

implementation

{ TStringListProgress }

procedure TStringListProgress.Sort;
begin
  inherited Sort;
  if Assigned(FCallBack) then
    FCallBack;
end;

end.

