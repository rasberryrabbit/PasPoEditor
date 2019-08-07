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


implementation

uses
  fpjson, jsonparser, httpsend, synsock, synacode, ssl_openssl;

const
 user_agent_browser = 'User-Agent: Mozilla/5.0 (Windows NT 6.1; Win64; x64)';

(*
  return json array
*)

  GoogleTranAPI_tranpost_url = 'https://translate.googleapis.com/translate_a/single?client=gtx&sl=%s&tl=%s&dt=t&q=%s';

  // languages for nmt model support
  Google_Lang_array : array[0..30] of string =
                    ('af','ar','bg','zh-CN','zh-TW','hr','cs','da','nl','fr','de','el','iw','hi','is','id','it','ja',
                     'ko','no','pl','pt','ro','ru','sk','es','sv','th','tr','vi','en');


var
  uInternetConn : Boolean = False;


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
    hget.Headers.Add(user_agent_browser);
    hget.Headers.Add('Content-Type: charset=utf-8');
    slang:=fromlang;
    if slang='' then
      slang:='auto';
    surl:=Format(GoogleTranAPI_tranpost_url,[slang,tolang,EncodeURLElement(text)]);
    if hget.HTTPMethod('GET',surl) then begin
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
        except
          Result:=text;
        end;
        DataRoot.Free;
      end else
        Result:=hget.ResultString;
    end;
  finally
    hget.Free;
  end;
end;



initialization
  uInternetConn:=CheckInternetConn;



end.

