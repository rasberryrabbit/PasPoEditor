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
      procedure CustomSort(CompareFn: TStringListSortCompare); override;
      function AddObject(const S: string; AObject: TObject): Integer; override;
        overload;

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

procedure TStringListProgress.CustomSort(CompareFn: TStringListSortCompare);
begin
  inherited CustomSort(CompareFn);
  if Assigned(FCallBack) then
    FCallBack;
end;

function TStringListProgress.AddObject(const S: string; AObject: TObject
  ): Integer;
begin
  Result:=inherited AddObject(S, AObject);
  if Assigned(FCallBack) then
    FCallBack;
end;

end.

