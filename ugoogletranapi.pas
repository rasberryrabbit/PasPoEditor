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
  Classes, SysUtils, Forms;


function GoogleTranAPI_GetLangs(const langs:TStrings):Boolean;
function GoogleTranAPI_Translate(const fromlang,tolang,text:string):string;
procedure GoogleTranAPI_SetBaseURL(const Url:string);


var
  TranProxyHost:string='';
  TranProxyPort:string='';


implementation

uses
  fpjson, jsonparser, httpsend, synsock, synacode, ssl_openssl,
  RegExpr, GoogleTranslate;

type

  { TConnThread }

  TConnThread=class(TThread)
    procedure Execute; override;
  end;

var
  ConThread: TConnThread;
  ConnEnd: Boolean;
  uInternetConn : Boolean = False;
  badHit : Integer = 0;
  TranGoogle : TGoogleTranslator;


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
  langs.Clear;
  for i:=low(LANGUAGES) to High(LANGUAGES) do
    langs.Add(LANGUAGES[i][0]);
end;

// fromlang can be ''
function GoogleTranAPI_Translate(const fromlang,tolang,text:string):string;
var
  res: TTranslated;
begin
  Result:='';
  if not uInternetConn then
    exit;
  try
    res:=TranGoogle.Translate(text,tolang);
    Result:=res.Text;
    res.Free;
  except
    on e: exception do
       Result:=e.Message;
  end;
end;

procedure GoogleTranAPI_SetBaseURL(const Url: string);
begin
  // Do Nothing
end;

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
  TranGoogle:= TGoogleTranslator.Create();

finalization
  TranGoogle.Free;
  while not ConnEnd do
    Application.ProcessMessages;


end.

