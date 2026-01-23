unit GToken;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fphttpclient, RegExpr, Math, DateUtils;

type
  TIntegerDynArray = array of Integer;
  { TTokenAcquirer - Google Translate API 토큰 생성기 }
  TTokenAcquirer = class
  private
    FHTTPClient: TFPHTTPClient;
    FTKK: string;
    FHost: string;
    
    { TKK 값을 추출하는 정규식 패턴 }
    function ExtractTKK(const HTML: string): string;
    
    { TKK 값을 업데이트 }
    procedure UpdateTKK;
    
    { 문자를 정수 배열로 변환 }
    function StringToIntArray(const S: string): TIntegerDynArray;
    
    { XOR 연산 함수 }
    function XR(a: Int64; b: string): Int64;
    
    { 비트 시프트 연산 함수 }
    function Shr32(a: Int64; b: Integer): Int64;
    function Shl32(a: Int64; b: Integer): Int64;
    
    { 토큰 획득 알고리즘 }
    function Acquire(const Text: string): string;
    
  public
    constructor Create(const ATKK: string = '0'; const AHost: string = 'translate.google.com');
    destructor Destroy; override;
    
    { 주어진 텍스트에 대한 토큰 생성 }
    function DoToken(const Text: string): string;
    
    property TKK: string read FTKK write FTKK;
    property Host: string read FHost write FHost;
  end;

implementation

uses
  opensslsockets;

{ TTokenAcquirer }

constructor TTokenAcquirer.Create(const ATKK: string; const AHost: string);
begin
  inherited Create;
  FTKK := ATKK;
  
  if Pos('http', AHost) > 0 then
    FHost := AHost
  else
    FHost := 'https://' + AHost;
    
  FHTTPClient := TFPHTTPClient.Create(nil);
  FHTTPClient.AddHeader('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)');
end;

destructor TTokenAcquirer.Destroy;
begin
  FHTTPClient.Free;
  inherited Destroy;
end;

function TTokenAcquirer.ExtractTKK(const HTML: string): string;
var
  RegEx: TRegExpr;
begin
  Result := '';
  RegEx := TRegExpr.Create;
  try
    // tkk:'xxxxxxx.xxxxxxx' 패턴 찾기
    RegEx.Expression := 'tkk:''(.+?)''';
    if RegEx.Exec(HTML) then
      Result := RegEx.Match[1];
  finally
    RegEx.Free;
  end;
end;

procedure TTokenAcquirer.UpdateTKK;
var
  Response: string;
  ExtractedTKK: string;
  CurrentTime: Int64;
  TKKTime: Int64;
begin
  // TKK는 1시간마다 업데이트되므로 아직 유효한지 확인
  if FTKK <> '0' then
  begin
    CurrentTime := Floor(DateTimeToUnix(Now,False) * 1000 / 3600000);
    TKKTime := StrToInt64Def(Copy(FTKK, 1, Pos('.', FTKK) - 1), 0);
    
    if CurrentTime = TKKTime then
      Exit; // TKK가 아직 유효함
  end;
  
  try
    Response := FHTTPClient.Get(FHost);
    ExtractedTKK := ExtractTKK(Response);
    
    if ExtractedTKK <> '' then
      FTKK := ExtractedTKK;
  except
    on E: Exception do
      ; // TKK 업데이트 실패시 기존 값 유지
  end;
end;

function TTokenAcquirer.StringToIntArray(const S: string): TIntegerDynArray;
var
  i: Integer;
  Bytes: TBytes;
begin
  Bytes := TEncoding.UTF8.GetBytes(S);
  SetLength(Result, Length(Bytes));
  
  for i := 0 to High(Bytes) do
    Result[i] := Bytes[i];
end;

function TTokenAcquirer.Shr32(a: Int64; b: Integer): Int64;
begin
  Result := (a and $FFFFFFFF) shr b;
end;

function TTokenAcquirer.Shl32(a: Int64; b: Integer): Int64;
begin
  Result := ((a and $FFFFFFFF) shl b) and $FFFFFFFF;
end;

function TTokenAcquirer.XR(a: Int64; b: string): Int64;
var
  c: Integer;
  d: Char;
begin
  Result := a;
  
  for c := 0 to Length(b) - 1 do
  begin
    d := b[c + 1];
    
    case d of
      '+': Result := Result + (Ord(b[c + 2]) - Ord('0'));
      '^': Result := Result xor (Ord(b[c + 2]) - Ord('0'));
      '&': Result := Result and $FFFFFFFF;
    else
      if d in ['a'..'z'] then
      begin
        case d of
          'a': Result := Shr32(Result, Ord(b[c + 2]) - Ord('0'));
          'b': Result := Shl32(Result, Ord(b[c + 2]) - Ord('0'));
        end;
      end;
    end;
    
    Result := Result and $FFFFFFFF;
  end;
end;

function TTokenAcquirer.Acquire(const Text: string): string;
var
  IntArray: TIntegerDynArray;
  a, b: Int64;
  i, j: Integer;
  TKKParts: TStringArray;
  d: Int64;
  e: array[0..1] of Int64;
  f, g: Int64;
begin
  // TKK를 파싱
  TKKParts := FTKK.Split('.');
  if Length(TKKParts) < 2 then
  begin
    Result := '';
    Exit;
  end;
  
  b := StrToInt64Def(TKKParts[0], 0);
  
  // 텍스트를 정수 배열로 변환
  IntArray := StringToIntArray(Text);
  
  a := b;
  
  // 메인 알고리즘
  for i := 0 to High(IntArray) do
  begin
    a := a + IntArray[i];
    a := XR(a, '+-a^+6');
  end;
  
  a := XR(a, '+-3^+b+-f');
  
  // TKK의 두 번째 부분 처리
  d := StrToInt64Def(TKKParts[1], 0);
  a := a xor d;
  
  if a < 0 then
    a := (a and $7FFFFFFF) + $80000000;
    
  a := a mod 1000000;
  
  Result := IntToStr(a) + '.' + IntToStr(a xor b);
end;

function TTokenAcquirer.DoToken(const Text: string): string;
begin
  UpdateTKK;
  Result := Acquire(Text);
end;

end.
