unit ulectotranslate;


{ Simple lecto translator API

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


function LectoTranAPI_GetLangs(const langs:TStrings):Boolean;
function LectoTranAPI_Detect(const text:string):string;
function LectoTranAPI_Translate(const fromlang,tolang,text:string):string;


var
  TranProxyHost:string='';
  TranProxyPort:string='';
  LectoAPIKey:string='';


implementation

uses
  fpjson, jsonparser, httpsend, synsock, synacode, ssl_openssl,
  RegExpr, ZStream;

const
 user_agent_browser = 'User-Agent: Mozilla/5.0 (Windows NT 6.1; Win64; x64)';
 LectoTran_Base = 'https://api.lecto.ai/v1';


var
  badHit : Integer = 0;
  uInternetConn : Boolean = False;
  langlistdone: Boolean = False;
  LangList: TStringList;

type

  { TConnThread }

  TConnThread=class(TThread)
    procedure Execute; override;
  end;

var
  ConThread: TConnThread;
  ConnEnd: Boolean;


function CheckInternetConn:Boolean;
var
  iplist:TStringList;
  i:Integer;
  s:string;
begin
  Result:=False;
  iplist:=TStringList.Create;
  try
    ResolveNameToIP('api.lecto.ai',AF_INET,IPPROTO_TCP,SOCK_STREAM,iplist);
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


function LectoTranAPI_GetLangs(const langs:TStrings):Boolean;
var
  DataRoot: TJSONData;
  retData: TJSONArray;
  i: Integer;
  hget : THTTPSend;
begin
  Result:=False;
  if not uInternetConn then
    exit;
  if not langlistdone then begin
    hget:=THTTPSend.Create;
    try
      hget.ProxyHost:=TranProxyHost;
      hget.ProxyPort:=TranProxyPort;
      // header
      hget.Headers.Add(user_agent_browser);
      hget.Headers.Add('X-API-Key: '+ LectoAPIKey);
      hget.Headers.Add('Content-Type: application/json');
      hget.Headers.Add('Accept: application/json');
      if hget.HTTPMethod('GET',LectoTran_Base+'/translate/languages') then begin
        if hget.ResultCode=200 then begin
          hget.Document.Position:=0;
          try
            DataRoot:=GetJSON(hget.Document);
            try
              retData:=TJSONArray(DataRoot.FindPath('languages'));
              for i:=0 to retData.Count-1 do begin
                if retData[i].FindPath('support_target').AsBoolean then
                  LangList.Add(retData[i].FindPath('language_code').AsString);
              end;
            finally
              DataRoot.Free;
            end;
            langs.Assign(LangList);
            Result:=True;
            langlistdone:=True;
          except
          end;
        end;
      end;
    finally
      hget.Free;
    end;
  end else begin
    langs.Assign(LangList);
    Result:=True;
  end;
end;


function LectoTranAPI_Detect(const text: string): string;
var
  DataRoot, DataItem: TJSONData;
  Data: TJSONObject;
  retData, txtData: TJSONArray;
  hget : THTTPSend;
  surl: string;
begin
  Result:='';
  if not uInternetConn then
    exit;
  hget:=THTTPSend.Create;
  try
    hget.ProxyHost:=TranProxyHost;
    hget.ProxyPort:=TranProxyPort;
    // build json
    Data:=CreateJSONObject([]);
    txtData:=TJSONArray.Create;
    txtData.Add(Copy(text,1,1000));
    Data.Add('texts',txtData);
    surl:=Data.AsJSON;
    Data.Free;
    // header
    hget.Headers.Add(user_agent_browser);
    hget.Headers.Add('X-API-Key: '+ LectoAPIKey);
    hget.Headers.Add('Content-Type: application/json');
    hget.Headers.Add('Accept: application/json');
    hget.Document.Write(surl[1],Length(surl));
    if hget.HTTPMethod('POST',LectoTran_Base+'/detect/text') then begin
      if hget.ResultCode=200 then begin
        hget.Document.Position:=0;
        try
          DataRoot:=GetJSON(hget.Document);
          try
            retData:=TJSONArray(DataRoot.FindPath('detected_languages'));
            DataItem:=retData[0];
            Result:=UTF8Encode(DataItem.AsUnicodeString);
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


function LectoTranAPI_Translate(const fromlang, tolang, text: string): string;
var
  DataRoot, DataItem: TJSONData;
  Data: TJSONObject;
  retData, txtData: TJSONArray;
  hget : THTTPSend;
  s, surl: string;
  stemp: TStringStream;
begin
  Result:='';
  if not uInternetConn then
    exit;
  hget:=THTTPSend.Create;
  try
    hget.ProxyHost:=TranProxyHost;
    hget.ProxyPort:=TranProxyPort;
    // build json
    Data:=CreateJSONObject([]);
    Data.Add('from',fromlang);
    txtData:=TJSONArray.Create;
    txtData.Add(Copy(text,1,1000));
    Data.Add('texts',txtData);
    Data.Add('to',CreateJSONArray([tolang]));
    surl:=Data.AsJSON;
    Data.Free;
    // header
    hget.Headers.Add(user_agent_browser);
    hget.Headers.Add('X-API-Key: '+ LectoAPIKey);
    hget.Headers.Add('Content-Type: application/json');
    hget.Headers.Add('Accept: application/json');
    hget.Document.Write(surl[1],Length(surl));
    if hget.HTTPMethod('POST',LectoTran_Base+'/translate/text') then begin
      stemp:=TStringStream.Create('');
      stemp.CopyFrom(hget.Document,0);
      s:=stemp.DataString;
      stemp.Free;
      if hget.ResultCode=200 then begin
        hget.Document.Position:=0;
        try
          DataRoot:=GetJSON(hget.Document);
          try
            retData:=TJSONArray(DataRoot.FindPath('translations'));
            DataItem:=TJSONArray(retData[0].FindPath('translated'))[0];
            Result:=UTF8Encode(DataItem.AsUnicodeString);
          finally
            DataRoot.Free;
          end;
        except
          Result:=text
        end;
      end else begin
        Result:=IntToStr(hget.ResultCode)+' '+hget.ResultString+' '+s;
      end;
    end;
  finally
    hget.Free;
  end;
end;

{ TConnThread }

procedure TConnThread.Execute;
begin
  FreeOnTerminate:=True;
  ConnEnd:=False;
  try
    uInternetConn:=CheckInternetConn;
  finally
    ConnEnd:=True;
  end;
end;


initialization
  ConThread:=TConnThread.Create(False);
  LangList:= TStringList.Create;

finalization
  LangList.Free;
  while not ConnEnd do
    Application.ProcessMessages;


end.

