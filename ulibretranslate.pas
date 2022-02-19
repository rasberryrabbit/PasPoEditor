unit ulibretranslate;


{ Simple libretranslate translator

  Copyright (c) 2021 rasberryrabbit

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


function LibreTranAPI_GetLangs(const langs:TStrings):Boolean;
function LibreTranAPI_Translate(const fromlang,tolang,text:string):string;


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

  LibreTranAPI_Base = 'https://translate.argosopentech.com/'; // 'https://libretranslate.com/';
  LibreTranAPI_Detect = LibreTranAPI_Base+'detect';
  LibreTranAPI_Languages = LibreTranAPI_Base+'languages';
  LibreTranAPI_Tran = LibreTranAPI_Base+'translate';

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
    ResolveNameToIP('libretranslate.com',AF_INET,IPPROTO_TCP,SOCK_STREAM,iplist);
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


function LibreTranAPI_GetLangs(const langs:TStrings):Boolean;
var
  i: integer;
  hget: THTTPSend;
  st: TStringStream;
  buf: string;
  root: TJSONData;
  ls: TJSONArray;
  o: TJSONObject;
  it: TJSONString;
begin
  Result:=False;
  if not uInternetConn then
    exit;
  langs.Clear;
  hget:=THTTPSend.Create;
  try
    hget.ProxyHost:=TranProxyHost;
    hget.ProxyPort:=TranProxyPort;
    hget.Headers.Add(user_agent_browser);
    hget.Headers.Add('Accept: application/json');

    if hget.HTTPMethod('POST', LibreTranAPI_Languages) then begin
      if hget.ResultCode=200 then begin
        hget.Document.Position:=0;
        root:=GetJSON(hget.Document);
        try
          if root.JSONType=jtArray then begin
            ls:=TJSONArray(root);
            for i:=0 to ls.Count-1 do begin
              o:=TJSONObject(ls[i]);
              it:=TJSONString(o.Find('code',jtString));
              if it<>nil then
                langs.Add(it.AsString);
            end;
          end;
        finally
          root.Free;
        end;
      end;
    end;
  finally
    hget.Free;
  end;
end;


function LibreTranAPI_Translate(const fromlang, tolang, text: string): string;
var
  retData, DataRoot: TJSONData;
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
    slang:=fromlang;
    if slang='' then
      slang:='auto';
    DataRoot:=CreateJSONObject(['q',text,'source',slang,'target',tolang]);
    surl:=DataRoot.AsJSON;
    DataRoot.Free;
    //surl:=Format('{ "q": "%s", "source": "%s", "target": "%s" }',[text,slang,tolang]);

    hget.Headers.Add(user_agent_browser);
    hget.MimeType:='application/json';
    hget.Document.Write(surl[1],Length(surl));
    if hget.HTTPMethod('POST',LibreTranAPI_Tran) then begin
      stemp:=TStringStream.Create('');
      stemp.CopyFrom(hget.Document,0);
      s:=stemp.DataString;
      stemp.Free;
      if hget.ResultCode=200 then begin
        hget.Document.Position:=0;
        try
          DataRoot:=GetJSON(hget.Document);
          try
            retData:=DataRoot.FindPath('translatedText');
            Result:=UTF8Encode(retData.AsUnicodeString);
          finally
            DataRoot.Free;
          end;
        except
          Result:=text
        end;
      end else begin
        Result:=IntToStr(hget.ResultCode)+' '+hget.ResultString+' '+s;
        //GetProxyServer;
      end;
    end;
  finally
    hget.Free;
  end;
end;


initialization
  uInternetConn:=CheckInternetConn;


end.

