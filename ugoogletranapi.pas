unit uGoogleTranApi;


{ Simple Google translator

  Copyright (c) 2017 rasberryrabbit

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
  Classes, SysUtils;


function GoogleTranAPI_GetLangs(const langs:TStrings):Boolean;
function GoogleTranAPI_Translate(const fromlang,tolang,text:string):string;


var
  TranProxyHost:string='';
  TranProxyPort:string='';


implementation

uses
  fpjson, jsonparser, httpsend, synsock, synacode, ssl_openssl,
  RegExpr;

const
 user_agent_browser = 'User-Agent: Mozilla/5.0 (Windows NT 6.1; Win64; x64)';

(*
  return json array
*)

  GoogleTranAPI_Base_url = 'https://translate.googleapis.com/translate_a/single?client=gtx';
  GoogleTranAPI_tranpost_url = 'sl=%s&tl=%s&dt=t&q=%s';

  // languages for nmt model support
  Google_Lang_array : array[0..30] of string =
                    ('af','ar','bg','zh-CN','zh-TW','hr','cs','da','nl','fr','de','el','iw','hi','is','id','it','ja',
                     'ko','no','pl','pt','ro','ru','sk','es','sv','th','tr','vi','en');


var
  uInternetConn : Boolean = False;
  badHit : Integer = 0;


procedure GetProxyServer;
const
  urlproxy = 'http://www.httptunnel.ge/ProxyListForFree.aspx';
  pattern = '<a\s+[^>]+>(\d+\.\d+\.\d+\.\d+\:\d+)</a>';
var
  plist:THTTPSend;
  st:TStringStream;
  reg:TRegExpr;
  pxlist:TStringList;
  i:Integer;
  sproxy:string;
begin
  Inc(badHit);
  if badHit<5 then
    exit;

  st:=TStringStream.Create;
  try
    plist:=THTTPSend.Create;
    try
      plist.HTTPMethod('GET',urlproxy);
      st.CopyFrom(plist.Document,plist.Document.Size);
    finally
      plist.Free;
    end;
    if plist.ResultCode=200 then
      sproxy:=st.DataString;
  finally
    st.Free;
  end;
  if sproxy<>'' then begin
    pxlist:=TStringList.Create;
    try
      // list proxy servers
      reg:=TRegExpr.Create(pattern);
      try
        i:=0;
        if reg.Exec(sproxy) then begin
          repeat
            pxlist.Add(reg.Match[1]);
            Inc(i);
          until (not reg.ExecNext) or (i>64);
        end;
      finally
        reg.Free;
      end;
      // select random one
      if pxlist.Count>0 then begin
        i:=Random(pxlist.Count-1);
        sproxy:=pxlist[i];
        i:=Pos(':',sproxy);
        if i<>0 then begin
          TranProxyHost:=Copy(sproxy,1,i-1);
          TranProxyPort:=Copy(sproxy,i+1);
          badHit:=0;
        end;
      end;
    finally
      pxlist.Free;
    end;
  end;
end;


function CheckInternetConn:Boolean;
var
  iplist:TStringList;
  i:Integer;
  s:string;
begin
  Result:=False;
  iplist:=TStringList.Create;
  try
    ResolveNameToIP('translate.googleapis.com',AF_INET,IPPROTO_TCP,SOCK_STREAM,iplist);
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


function GoogleTranAPI_GetLangs(const langs:TStrings):Boolean;
var
  i : integer;
begin
  Result:=False;
  if not uInternetConn then
    exit;
  langs.Clear;
  for i:=low(Google_Lang_array) to High(Google_Lang_array) do
    langs.Add(Google_Lang_array[i]);
end;


procedure GoogleTranAPI_ParseJsonText(Data:TJSONData; var ret:string; const stext:string);
var
  j:Integer;
  ditem, citem:TJSONData;
  s:string;
begin
  if Data.JSONType=jtArray then begin
    citem:=Data.Items[0];
    if citem.JSONType=jtArray then
      for j:=0 to citem.Count-1 do begin
        ditem:=citem.Items[j];
        if ditem.JSONType=jtArray then begin
          if ditem.Items[0].JSONType=jtString then begin
            ret:=pchar(UTF8Encode(ditem.Items[0].AsUnicodeString));
            break;
          end;
          {
          if ditem.Items[1].JSONType in [jtString,jtNull] then begin
            if ditem.Items[1].JSONType=jtString then begin
              s:=pchar(UTF8Encode(ditem.Items[1].AsUnicodeString));
              if (s<>ret) and (s<>stext) then
                ret:=ret+s;
            end;
            break;
          end;
          }
        end;
      end;
  end;
end;

// fromlang can be ''
function GoogleTranAPI_Translate(const fromlang,tolang,text:string):string;
var
  retData, DataRoot: TJSONData;
  jparser : TJSONParser;
  hget : THTTPSend;
  slang, s, surl: string;
  stemp: TStringStream;
begin
  Result:='';
  if not uInternetConn then
    exit;
  hget:=THTTPSend.Create;
  try
    hget.ProxyHost:=TranProxyHost;
    hget.ProxyPort:=TranProxyPort;
    hget.Headers.Add(user_agent_browser);
    hget.Headers.Add('Content-Type: charset=UTF-8');
    hget.Headers.Add('Accept: application/json; charset=UTF-8');
    slang:=fromlang;
    if slang='' then
      slang:='auto';
    surl:=Format(GoogleTranAPI_tranpost_url,[slang,tolang,EncodeURLElement(text)]);
    hget.Document.Write(surl[1],Length(surl));
    hget.MimeType := 'application/x-www-form-urlencoded';
    if hget.HTTPMethod('POST',GoogleTranAPI_Base_url) then begin
      stemp:=TStringStream.Create('');
      stemp.CopyFrom(hget.Document,0);
      s:=stemp.DataString;
      stemp.Free;
      if hget.ResultCode=200 then begin
        hget.Document.Position:=0;
        jparser:=TJSONParser.Create(hget.Document, True);
        try
          retData:=jparser.Parse;
        finally
          jparser.Free;
        end;
        DataRoot:=retData;
        try
          GoogleTranAPI_ParseJsonText(retData,Result,text);
          badHit:=0;
        except
          Result:=text;
        end;
        DataRoot.Free;
      end else begin
        Result:=IntToStr(hget.ResultCode)+' '+hget.ResultString;
        GetProxyServer;
      end;
    end;
  finally
    hget.Free;
  end;
end;


initialization
  uInternetConn:=CheckInternetConn;



end.

