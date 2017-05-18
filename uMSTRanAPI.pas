unit uMSTRanAPI;

(*
  Microsoft Transaltion API.
  original source from
    http://theroadtodelphi.wordpress.com/2011/05/30/using-the-microsoft-translator-v2-from-delphi/

  Modification
  - for fpc

  Need fpc, lazarus

  - 2015.04 New method Translator API

  - 2017.05 Add checking internet connection.


*)

interface

uses Classes;

var
  BingClientID : string = 'PoEdit_Translate';
  BingClientSecret : string = '2S6rh3cIsGD+/ky/C+BPAMXG+o3DnQC0s953aGc/2Wc=';
  BingAppID : string = '';


function DetectLanguage(const AText:string ):string;
function GetLanguagesForSpeak: TStringList;
function GetLanguagesForTranslate: TStringList;
function TranslateText(const AText:string; const SourceLng,DestLng:string):string;
procedure Speak(const FileName : string; const AText:string; const Lng:string);

implementation

uses SysUtils, httpsend, synautil, synacode, ssl_openssl, ssl_openssl_lib,
     DOM, fphttpclient, XmlRead, fpjson, synsock;


const
  MicrosoftTranslatorTranslateUri = 'http://api.microsofttranslator.com/v2/Http.svc/Translate?text=%s&from=%s&to=%s&appId=';
  MicrosoftTranslatorDetectUri = 'http://api.microsofttranslator.com/v2/Http.svc/Detect?text=%s&appId=';
  MicrosoftTranslatorGetLngUri = 'http://api.microsofttranslator.com/v2/Http.svc/GetLanguagesForTranslate?appId=';
  MicrosoftTranslatorGetSpkUri = 'http://api.microsofttranslator.com/v2/Http.svc/GetLanguagesForSpeak?appId=';
  MicrosoftTranslatorSpeakUri = 'http://api.microsofttranslator.com/v2/Http.svc/Speak?text=%s&language=%s&appId=';
  BingAuthUrl = 'https://datamarket.accesscontrol.windows.net/v2/OAuth2-13';
  BingTokenHeader = 'Authorization: Bearer ';
  ResultXMLArray = '<ArrayOfstring';
  ResultXMLStr = '<string';

var
  BingAccessToken : string = '';
  bInternetConn : Boolean = False;

function CheckInternetConn:Boolean;
var
  iplist:TStringList;
  i:Integer;
  s:string;
begin
  Result:=False;
  iplist:=TStringList.Create;
  try
    ResolveNameToIP('api.microsofttranslator.com',AF_INET,IPPROTO_TCP,SOCK_STREAM,iplist);
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

function HttpGetTranslate(const Url: string;Headers:array of string;Stream:TStream):Integer;
var
  hget : THTTPSend;
begin
  hget := THTTPSend.Create;
  try
    if Pos('https://',Url)<>0 then begin
       hget.Sock.CreateWithSSL(TSSLOpenSSL);
       hget.Sock.SSLDoConnect;
    end;
    if BingAccessToken<>'' then
      if length(Headers)>0 then
        hget.Headers.AddStrings(Headers);
    if bInternetConn then begin
      if hget.HTTPMethod('GET',Url) then
         Stream.CopyFrom(hget.Document,0);
      Result:=hget.ResultCode;
    end else
      Result:=404;
  finally
   hget.Free;
  end;
end;


function BingGetAccessToken(var aToken:string):Integer;
const
  postdata = 'grant_type=client_credentials&client_id=%s&client_secret=%s&scope=http://api.microsofttranslator.com';
var
  hget : THTTPSend;
  rstr : TStringStream;
  poststr : string;
begin
  aToken:='';
  Result:=500;
  hget := THTTPSend.Create;
  try
    hget.Sock.CreateWithSSL(TSSLOpenSSL);
    hget.Sock.SSLDoConnect;
    poststr:=Format(postdata,[EncodeURLElement(BingClientID),EncodeURLElement(BingClientSecret)]);
    WriteStrToStream(hget.Document,poststr);
    hget.MimeType:='application/x-www-form-urlencoded';
    if bInternetConn then begin
      if hget.HTTPMethod('POST',BingAuthUrl) then
        aToken:=GetJSON(hget.Document).FindPath('access_token').AsString;
      Result:=hget.ResultCode;
    end else
      Result:=404;
    if Result>=400 then
       aToken:='';
  finally
   hget.Free;
  end;
end;

function TranslateText(const AText:string; const SourceLng,DestLng:string):string;
var
   XmlDoc : TXMLDocument;
   Node   : TDOMNode;
   strbuf : TStringStream;
   RetCode: Integer;
begin
  Result:='';
  //Make the http request
  strbuf:=TStringStream.Create('');
  try
    if BingAccessToken='' then
       BingGetAccessToken(BingAccessToken);
    RetCode := HttpGetTranslate(Format(MicrosoftTranslatorTranslateUri,[EncodeURLElement(AText),SourceLng,DestLng]),[BingTokenHeader+BingAccessToken],strbuf);
    if RetCode>=400 then begin
       BingGetAccessToken(BingAccessToken);
       RetCode := HttpGetTranslate(Format(MicrosoftTranslatorTranslateUri,[EncodeURLElement(AText),SourceLng,DestLng]),[BingTokenHeader+BingAccessToken],strbuf);
    end;
    if RetCode<400 then begin
      //Create  a XML object o parse the result
      try
        strbuf.Position:=Pos(ResultXMLStr,strbuf.DataString)-1;
        ReadXMLFile(XmlDoc,strbuf);
        if XmlDoc.DocumentElement.ChildNodes.Length>0 then
          Result:=pchar(UTF8Encode(XmlDoc.DocumentElement.TextContent));
      finally
        XmlDoc.Free;
      end;
    end else
      BingAccessToken:='';
  finally
    strbuf.Free;
  end;
end;

function DetectLanguage(const AText:string ):string;
var
   XmlDoc : TXMLDocument;
   Node   : TDOMNode;
   strbuf : TStringStream;
   RetCode: Integer;
begin
  Result:='';
  strbuf:=TStringStream.Create('');
  try
    //make the http request
    if BingAccessToken='' then
       BingGetAccessToken(BingAccessToken);
    RetCode:=HttpGetTranslate(Format(MicrosoftTranslatorDetectUri,[EncodeURLElement(AText)]),[BingTokenHeader+BingAccessToken],strbuf);
    if RetCode>=400 then begin
       BingGetAccessToken(BingAccessToken);
       RetCode:=HttpGetTranslate(Format(MicrosoftTranslatorDetectUri,[EncodeURLElement(AText)]),[BingTokenHeader+BingAccessToken],strbuf);
    end;
    if RetCode<400 then begin
      //load the returned xml string
      try
        strbuf.Position:=Pos(ResultXMLStr,strbuf.DataString)-1;
        ReadXMLFile(XmlDoc,strbuf);
        //get the detected language from the node
        if XmlDoc.DocumentElement.ChildNodes.Length>0 then
          Result:=pchar(UTF8Encode(XmlDoc.DocumentElement.TextContent));
      finally
        XmlDoc.Free;
      end;
    end;
  finally
    strbuf.Free;
  end;
end;

function GetLanguagesForTranslate: TStringList;
var
   XmlDoc : TXMLDocument;
   Node   : TDOMElement;
   Nodes  : TDOMNodeList;
   lNodes : Integer;
   i,l    : Integer;
   strbuf : TStringStream;
   xstr : string;
begin
  Result:=TStringList.Create;
  //make the http request
  strbuf:=TStringStream.Create('');
  try
    if BingAccessToken='' then
       BingGetAccessToken(BingAccessToken);
    i:=HttpGetTranslate(MicrosoftTranslatorGetLngUri,[BingTokenHeader+BingAccessToken],strbuf);
    if i>=400 then begin
      BingGetAccessToken(BingAccessToken);
      i:=HttpGetTranslate(MicrosoftTranslatorGetLngUri,[BingTokenHeader+BingAccessToken],strbuf);
    end;
    if i<400 then begin
      try
        // skip http header
        strbuf.Position:=Pos(ResultXMLArray,strbuf.DataString)-1;
        ReadXMLFile(XmlDoc,strbuf);
        Node:= XmlDoc.DocumentElement;
        if Node.ChildNodes.Length>0 then
        begin
          //get the nodes
          Nodes := Node.childNodes;
           if Nodes.Length>0 then
           begin
             lNodes:= Nodes.Length;
               for i:=0 to lNodes-1 do
                Result.Add(pchar(UTF8Encode(Nodes.Item[i].TextContent)));
           end;
        end;
      finally
        XmlDoc.Free;
      end;
    end;
  finally
    strbuf.Free;
  end;
end;

function GetLanguagesForSpeak: TStringList;
var
   XmlDoc : TXMLDocument;
   Node   : TDOMElement;
   Nodes  : TDOMNodeList;
   lNodes : Integer;
   i      : Integer;
   strbuf : TStringStream;
begin
  Result:=TStringList.Create;
  strbuf:=TStringStream.Create('');
  try
    if BingAccessToken='' then
       BingGetAccessToken(BingAccessToken);
    i:=HttpGetTranslate(MicrosoftTranslatorGetSpkUri,[BingTokenHeader+BingAccessToken],strbuf);
    if i>=400 then begin
      BingGetAccessToken(BingAccessToken);
      i:=HttpGetTranslate(MicrosoftTranslatorGetSpkUri,[BingTokenHeader+BingAccessToken],strbuf);
    end;
    if i<400 then begin
      try
        strbuf.Position:=Pos(ResultXMLArray,strbuf.DataString)-1;
        ReadXMLFile(XmlDoc,strbuf);
        Node:= XmlDoc.documentElement;
        if Node.ChildNodes.Length>0 then
        begin
          Nodes := Node.childNodes;
           if Nodes.Length>0 then
           begin
             lNodes:= Nodes.Length;
               for i:=0 to lNodes-1 do
                Result.Add(pchar(UTF8Encode(Nodes.Item[i].TextContent)));
           end;
        end;
      finally
        XmlDoc.Free;
      end;
    end;
  finally
    strbuf.Free;
  end;
end;

procedure Speak(const FileName:string; const AText:string; const Lng:string);
var
  Stream : TFileStream;
  i : Integer;
begin
  Stream:=TFileStream.Create(FileName,fmCreate);
  try
    if BingAccessToken='' then
       BingGetAccessToken(BingAccessToken);
    i:=HttpGetTranslate(Format(MicrosoftTranslatorSpeakUri,[EncodeURLElement(AText),Lng]),[BingTokenHeader+BingAccessToken],Stream);
    if i>=400 then begin
      BingGetAccessToken(BingAccessToken);
      i:=HttpGetTranslate(Format(MicrosoftTranslatorSpeakUri,[EncodeURLElement(AText),Lng]),[BingTokenHeader+BingAccessToken],Stream);
    end;
  finally
     Stream.Free;
  end;
end;

initialization
  bInternetConn:=CheckInternetConn;

end.

