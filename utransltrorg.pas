unit utransltrorg;


{ translt.org API

  Copyright (c) 2017 Do-wan Kim

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


function Transltr_GetLangs(const langs:TStrings):Boolean;
function Transltr_Translate(const fromlang,tolang,text:string):string;


implementation

uses
  fpjson, jsonparser, httpsend, synsock;

const
(*
  Accept: application/json

  [
    {
      "languageCode": "ar",
      "languageName": "Arabic"
    },
    {
      "languageCode": "bs",
      "languageName": "Bosnian"
    },
    ...
  ]
*)

  transltr_langget_url = 'http://www.transltr.org/api/getlanguagesfortranslate';

(*
  Accept: application/json
  Content-Type: application/json

  <input>
  {
    "text": "string",
    "from": "string",
    "to": "string"
  }

  <result>
  {
    "from": "string",     // if "nl", get twice translated text.
    "to": "string",
    "text": "string",
    "translationText": "string"
  }

*)

  transltr_tranpost_url = 'http://www.transltr.org/api/translate';
  queryform = '{ "text": "%s", "from": "%s", "to": "%s" }';


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
    ResolveNameToIP('www.transltr.org',AF_INET,IPPROTO_TCP,SOCK_STREAM,iplist);
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


procedure Transltr_ParseJsonLangs(const lang:TStrings; Data:TJSONData);
var
  i:Integer;
  ditem:TJSONData;
  s:string;
begin
  if assigned(Data) then begin
    case Data.JSONType of
    jtArray,
    jtObject:
      for i:=0 to Data.Count-1 do begin
        ditem:=Data.Items[i].FindPath('languageCode');
        if assigned(ditem) then begin
          s:=ditem.AsString;
          lang.Add(s);
        end;
      end;
    end;
  end;
end;

function Transltr_GetLangs(const langs:TStrings):Boolean;
var
  retData, DataRoot: TJSONData;
  jparser : TJSONParser;
  buf : TStringStream;
  hget : THTTPSend;
begin
  Result:=False;
  if not uInternetConn then
    exit;
  buf:=TStringStream.Create;
  try
    hget:=THTTPSend.Create;
    try
      hget.Headers.Add('Accept: application/json');
      if hget.HTTPMethod('GET',transltr_langget_url)  then begin
        hget.Document.Position:=0;
        jparser:=TJSONParser.Create(hget.Document);
        try
          retData:=jparser.Parse;
        finally
          jparser.Free;
        end;
        DataRoot:=retData;
        Transltr_ParseJsonLangs(langs,retData);
        Result:=DataRoot<>nil;
        DataRoot.Free;
      end;
    finally
      hget.Free;
    end;
  finally
    buf.Free;
  end;
end;


function Transltr_ParseJsonText(Data:TJSONData):string;
var
  i:Integer;
  ditem:TJSONData;
  s:string;
begin
  Result:='';
  if assigned(Data) then begin
    ditem:=Data.FindPath('translationText');
    if assigned(ditem) then
      Result:=UTF8Encode(ditem.AsUnicodeString);
  end;
end;

// fromlang can be ''
function Transltr_Translate(const fromlang,tolang,text:string):string;
var
  retData, DataRoot: TJSONData;
  jparser : TJSONParser;
  buf : TStringStream;
  hget : THTTPSend;
  s: string;
begin
  Result:='';
  if not uInternetConn then
    exit;
  s:=StringReplace(pchar(text),'"','%x22',[rfReplaceAll]);
  buf:=TStringStream.Create(Format(queryform,[pchar(s),pchar(fromlang),pchar(tolang)]));
  try
    retdata:=GetJSON(buf);
    try
      buf.Size:=0;
      buf.Write(retData.AsJSON[1],Length(retData.AsJSON));
    finally
      retData.Free;
    end;
    hget:=THTTPSend.Create;
    try
      hget.Headers.Add('Accept: application/json');
      hget.MimeType:='application/json';
      hget.Document.CopyFrom(buf,0);
      if hget.HTTPMethod('POST',transltr_tranpost_url) then begin
        hget.Document.Position:=0;
        if hget.ResultCode=200 then begin
          jparser:=TJSONParser.Create(hget.Document, True);
          try
            retData:=jparser.Parse;
          finally
            jparser.Free;
          end;
          DataRoot:=retData;
          Result:=Transltr_ParseJsonText(retData);
          DataRoot.Free;
        end;
      end;
    finally
      hget.Free;
    end;
  finally
    buf.Free;
  end;
end;



initialization
  uInternetConn:=CheckInternetConn;



end.

