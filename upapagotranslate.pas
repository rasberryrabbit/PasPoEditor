unit upapagotranslate;


{ Simple papago translator API

  Copyright (c) 2023 rasberryrabbit

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to
  deal in the Software without restriction, including without limitation the
  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
  sell copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
  IN THE SOFTWARE.
}


{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms;


function PapagoTranAPI_GetLangs(const langs:TStrings):Boolean;
function PapagoTranAPI_Detect(const text:string):string;
function PapagoTranAPI_Translate(const fromlang,tolang,text:string):string;
//function PapagoTranAPI_Translate_API(const fromlang,tolang,text:string):string;


var
  TranProxyHost:string='';
  TranProxyPort:string='';
  PapagoClientID:string='';
  PapagoClientSecret:string='';
  debugtxt:string='';


implementation

uses
  fpjson, jsonparser, httpsend, synsock, synacode, ssl_openssl,
  RegExpr, ZStream,HMAC, base64, uDateTimeCSharp;

const
 user_agent_browser = 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.100 Safari/537.36';
 Papago_Base = 'https://papago.naver.com';
 Papago_n2mt = '/apis/n2mt/translate';
 Papago_nsmt = '/apis/nsmt/translate';
 Papago_url = Papago_Base+Papago_nsmt;
 Papago_dtLang = 'https://openapi.naver.com/v1/papago/detectLangs';
 Papago_params = 'deviceId=%s&locale=en&dict=false&honorific=false&instant=true&source=%s&target=%s&text=%s';
 Papago_json = '{ ''source'':''%s'', ''target'':''%s'', ''text'':''%s'' }';
 pattern_src = '/vendors~main[^"]+';
 pattern_version = 'v\d\.\d\.\d_[^"]+';


var
  badHit : Integer = 0;
  LangList: TStringList;
  uid: TGuid;
  sysid : string;
  _version : string;
  _source : string;
  _trancount : Integer = 0;
  _resetafter : Integer = 0;


function CheckInternetConn:Boolean;
var
  iplist:TStringList;
  i:Integer;
  s:string;
begin
  Result:=False;
  iplist:=TStringList.Create;
  try
    ResolveNameToIP(Papago_Base,AF_INET,IPPROTO_TCP,SOCK_STREAM,iplist);
    for i:=0 to iplist.Count-1 do begin
      s:=iplist[i];
      if (s<>cAnyHost) and (s<>'10.0.0.1') then begin
        Result:=True;
        break;
      end;
    end;
  finally
    iplist.Free
  end;
end;

function CheckGZip(const st:TStringList):Boolean;
var
  i: Integer;
  s: string;
begin
  Result:=False;
  for i:=0 to st.Count-1 do begin
    s:=st[i];
    if (Pos('Content-Encoding:',s)>0) and (Pos('gzip',s)>0) then begin
      Result:=True;
      break;
    end;
  end;
end;

function PapagoTranAPI_GetLangs(const langs:TStrings):Boolean;
begin
  Result:=False;
  LangList.DelimitedText:='ko,en,ja,zh-CN,zh-TW,vi,id,th,de,ru,es,it,fr';
  langs.Assign(LangList);
end;


function PapagoTranAPI_Detect(const text: string): string;
var
  DataRoot, DataItem: TJSONData;
  Data: TJSONObject;
  retData, txtData: TJSONArray;
  hget : THTTPSend;
  s, surl: string;
  stemp: TStringStream;
  gzrecv: TGZipDecompressionStream;
begin
  Result:='';
  hget:=THTTPSend.Create;
  try
    hget.ProxyHost:=TranProxyHost;
    hget.ProxyPort:=TranProxyPort;
    surl:='query='+text;
    // header
    hget.Headers.Add('User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:124.0) Gecko/20100101 Firefox/124.0');
    hget.Headers.Add('Content-Type: application/x-www-form-urlencoded; charset=UTF-8');
    hget.Headers.Add('X-Naver-Client-Id: '+PapagoClientID);
    hget.Headers.Add('X-Naver-Client-Secret: '+PapagoClientSecret);
    hget.Headers.Add('Accept-Encoding: gzip');
    hget.Document.Write(surl[1],Length(surl));
    if hget.HTTPMethod('POST',Papago_dtLang) then begin
      if hget.ResultCode=200 then begin
        stemp:=TStringStream.Create('');
        try
          if CheckGZip(hget.Headers) then begin
            gzrecv:=TGZipDecompressionStream.Create(hget.Document);
            stemp.CopyFrom(gzrecv,0);
            gzrecv.Free;
            s:=stemp.DataString;
          end else begin
            stemp.CopyFrom(hget.Document,0);
            s:=stemp.DataString;
          end;
        finally
          stemp.Free;
        end;
        try
          DataRoot:=GetJSON(s);
          try
            retData:=TJSONArray(DataRoot.FindPath('langCode'));
            Result:=UTF8Encode(retData.AsUnicodeString);
          finally
            DataRoot.Free;
          end;
        except
          Result:='';
        end;
      end else begin
        Result:=IntToStr(hget.ResultCode)+' '+hget.ResultString;
      end;
    end;
  finally
    hget.Free;
  end;
end;

procedure Add_Header(Headers:TStrings);
begin
  Headers.Clear;
  Headers.Add('Accept: application/json');
  Headers.Add('User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:133.0) Gecko/20100101 Firefox/133.0');
  Headers.Add('Content-Type: application/x-www-form-urlencoded; charset=UTF-8');
  Headers.Add('Accept-Encoding: gzip, deflate, br, zstd');
end;

function GetHMACMD5(const key, data: string):string;
var
  dgst:THMACMD5Digest;
  dgststr: string;
  i: Integer;
begin
  SetLength(dgststr,16);
  dgst:=HMACMD5Digest(key,data);
  for i:=0 to 15 do
    byte(dgststr[i+1]):=dgst[i];
  Result:=EncodeStringBase64(dgststr);
end;

procedure SetupVersion;
var
  hget: THTTPSend;
  stemp: TStringStream;
  s: string;
  r: TRegExpr;
begin
  hget:=THTTPSend.Create;
  try
    Add_Header(hget.Headers);
    hget.HTTPMethod('GET',Papago_Base);
    stemp:=TStringStream.Create;
    try
      hget.Document.Position:=0;
      stemp.CopyFrom(hget.Document,hget.Document.Size);
      s:=stemp.DataString;
    finally
      stemp.Free;
    end;
    r:=TRegExpr.Create(pattern_src);
    try
      r.Compile;
      if r.Exec(s) then
        _source:=r.Match[0];
    finally
      r.Free;
    end;

    hget.Document.Clear;
    Add_Header(hget.Headers);

    hget.HTTPMethod('GET',Papago_Base+_source);
    stemp:=TStringStream.Create;
    try
      hget.Document.Position:=0;
      stemp.CopyFrom(hget.Document,hget.Document.Size);
      s:=stemp.DataString;
    finally
      stemp.Free;
    end;
    r:=TRegExpr.Create(pattern_version);
    try
      r.Compile;
      if r.Exec(s) then
        _version:=r.Match[0];
    finally
      r.Free;
    end;
  finally
    hget.Free;
  end;
end;

function DateTimeToNumber(ADateTime: TDateTime): Double;
begin
  if ADateTime >= 0  then
    Result := ADateTime
  else
    Result := int(ADateTime) - frac(ADateTime);
end;

function NumberToDateTime(AValue: Double): TDateTime;
begin
  if AValue >= 0 then
    Result := AValue
  else
    Result := int(AValue) + frac(AValue);
end;

Function DateTimeDiff(const ANow, AThen: TDateTime): TDateTime;
begin
  Result := NumberToDateTime(DateTimeToNumber(ANow) - DateTimeToNumber(AThen));
end;

function PapagoTranAPI_Translate(const fromlang, tolang, text: string): string;
var
  hget: THTTPSend;
  s, surl, key, data, token, timestamp: string;
  d: TDateTime;
  stemp: TStringStream;
begin
  Result:='';

  hget:=THTTPSend.Create;
  try
    s:=Format(Papago_params,[sysid,fromlang,tolang,text]);
    hget.Document.Write(s[1],Length(s));
    Add_Header(hget.Headers);

    d:=NowUTC;
    timestamp:=IntToStr(DateTimeToUnix_us(d));
    key:=_version;
    data:=sysid+#$a+Papago_url+#$a+timestamp;
    token:=GetHMACMD5(key,data);

    hget.Headers.Add('Authorization: PPG '+sysid+':'+token);
    hget.Headers.Add('Timestamp: '+timestamp);

    hget.HTTPMethod('POST',Papago_url);
    stemp:=TStringStream.Create('');
    try
      hget.Document.Position:=0;
      stemp.CopyFrom(hget.Document,hget.Document.Size);
      s:=stemp.DataString;
      Result:=s;
    finally
      stemp.Free;
    end;
  finally
    hget.Free;
  end;
end;


initialization
  Randomize;
  CreateGUID(uid);
  sysid:=GUIDToString(uid);
  sysid:=copy(sysid,2,36);
  LangList:= TStringList.Create;
  SetupVersion;

  // 1736396471279
  //debugtxt:=IntToStr(DateTimeToUnix_us(Now));

finalization
  LangList.Free;

end.

