unit uMSTRanAPI;

(*
  Microsoft Transaltion API.
  original source from
    http://theroadtodelphi.wordpress.com/2011/05/30/using-the-microsoft-translator-v2-from-delphi/

  Modification
  - for fpc

  Need fpc, lazarus

*)

interface

uses Classes;

var
  BingAppId :string = 'your key';

function DetectLanguage(const AText:string ):string;
function GetLanguagesForSpeak: TStringList;
function GetLanguagesForTranslate: TStringList;
function TranslateText(const AText:string; const SourceLng,DestLng:string):string;
procedure Speak(const FileName : string; const AText:string; const Lng:string);

implementation

uses Windows, SysUtils, WinINet, DOM, fphttpclient, XmlRead;


const
  MicrosoftTranslatorTranslateUri = 'http://api.microsofttranslator.com/v2/Http.svc/Translate?appId=%s&text=%s&from=%s&to=%s';
  MicrosoftTranslatorDetectUri = 'http://api.microsofttranslator.com/v2/Http.svc/Detect?appId=%s&text=%s';
  //this AppId if for demo only please be nice and use your own , it's easy get one from here http://msdn.microsoft.com/en-us/library/ff512386.aspx
  (*
     AppId¢¥http://msdn.microsoft.com/en-us/library/ff512386.aspx
     AppId.
  *)
  //===
  MicrosoftTranslatorGetLngUri = 'http://api.microsofttranslator.com/v2/Http.svc/GetLanguagesForTranslate?appId=%s';
  MicrosoftTranslatorGetSpkUri = 'http://api.microsofttranslator.com/v2/Http.svc/GetLanguagesForSpeak?appId=%s';
  MicrosoftTranslatorSpeakUri = 'http://api.microsofttranslator.com/v2/Http.svc/Speak?appId=%s&text=%s&language=%s';


procedure WinInet_HttpGet(const Url: string;Stream:TStream);overload;
const
BuffSize = 1024*1024;
var
  hInter   : HINTERNET;
  UrlHandle: HINTERNET;
  BytesRead: DWORD;
  Buffer   : Pointer;
begin
  hInter := InternetOpen('', INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
  if Assigned(hInter) then
    try
      Stream.Seek(0,0);
      GetMem(Buffer,BuffSize);
      try
          UrlHandle := InternetOpenUrl(hInter, PChar(Url), nil, 0, INTERNET_FLAG_RELOAD, 0);
          if Assigned(UrlHandle) then
          begin
            repeat
              InternetReadFile(UrlHandle, Buffer, BuffSize, BytesRead);
              if BytesRead>0 then
               Stream.WriteBuffer(Buffer^,BytesRead);
            until BytesRead = 0;
            InternetCloseHandle(UrlHandle);
          end;
      finally
        FreeMem(Buffer);
      end;
    finally
     InternetCloseHandle(hInter);
    end;
end;

function TranslateText(const AText:string; const SourceLng,DestLng:string):string;
var
   XmlDoc : TXMLDocument;
   Node   : TDOMNode;
   strbuf : TStringStream;
begin
  Result:='';
  //Make the http request
  strbuf:=TStringStream.Create('');
  try
    WinInet_HttpGet(Format(MicrosoftTranslatorTranslateUri,[BingAppId,EncodeURLElement(AText),SourceLng,DestLng]),strbuf);
    //Create  a XML object o parse the result
    try
      strbuf.Position:=0;
      ReadXMLFile(XmlDoc,strbuf);
      (*
      if (XmlDoc.parseError.errorCode <> 0) then
       raise Exception.CreateFmt('Error in Xml Data %s',[XmlDoc.parseError]);
      *)
      if XmlDoc.DocumentElement.ChildNodes.Length>0 then
        Result:=pchar(UTF8Encode(XmlDoc.DocumentElement.TextContent));
    finally
      XmlDoc.Free;
    end;
  finally
    strbuf.Free;
  end;
end;

function DetectLanguage(const AText:string ):string;
var
   XmlDoc : TXMLDocument;
   Node   : TDOMNode;
   strbuf : TStringStream;
begin
  Result:='';
  strbuf:=TStringStream.Create('');
  try
    //make the http request
    WinInet_HttpGet(Format(MicrosoftTranslatorDetectUri,[BingAppId,EncodeURLElement(AText)]),strbuf);
    //load the returned xml string
    try
      strbuf.Position:=0;
      ReadXMLFile(XmlDoc,strbuf);
      (*
      if (XmlDoc.parseError.errorCode <> 0) then
       raise Exception.CreateFmt('Error in Xml Data %s',[XmlDoc.parseError]);
      Node:= XmlDoc.documentElement;
      *)
      //get the detected language from the node
      if XmlDoc.DocumentElement.ChildNodes.Length>0 then
        Result:=pchar(UTF8Encode(XmlDoc.DocumentElement.TextContent));
    finally
      XmlDoc.Free;
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
   i      : Integer;
   strbuf : TStringStream;
begin
  Result:=TStringList.Create;
  //make the http request
  strbuf:=TStringStream.Create('');
  try
    WinInet_HttpGet(Format(MicrosoftTranslatorGetLngUri,[BingAppId]),strbuf);
    try
      strbuf.Position:=0;
      ReadXMLFile(XmlDoc,strbuf);
      (*
      if (XmlDoc.parseError.errorCode <> 0) then
       raise Exception.CreateFmt('Error in Xml Data %s',[XmlDoc.parseError]);
      *)
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
    WinInet_HttpGet(Format(MicrosoftTranslatorGetSpkUri,[BingAppId]),strbuf);
    try
      strbuf.Position:=0;
      ReadXMLFile(XmlDoc,strbuf);
      (*
      if (XmlDoc.parseError.errorCode <> 0) then
       raise Exception.CreateFmt('Error in Xml Data %s',[XmlDoc.parseError]);
      *)
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
  finally
    strbuf.Free;
  end;
end;

procedure Speak(const FileName:string; const AText:string; const Lng:string);
var
  Stream : TFileStream;
begin
  Stream:=TFileStream.Create(FileName,fmCreate);
  try
    WinInet_HttpGet(Format(MicrosoftTranslatorSpeakUri,[BingAppId,EncodeURLElement(AText),Lng]),Stream);
  finally
     Stream.Free;
  end;
end;

end.

(*

var
lng       : TList<string>;
s         : string;
FileName  : string;

begin
 try
    ReportMemoryLeaksOnShutdown:=True;
    CoInitialize(nil);
    try
      Writeln(TranslateText('Hello World','en','es'));
      Writeln(DetectLanguage('Hello World'));
      Writeln('Languages for translate supported');
      lng:=GetLanguagesForTranslate;
      try
        for s in lng do
         Writeln(s);
      finally
        lng.free;
      end;
      Writeln('Languages for speak supported');
      lng:=GetLanguagesForSpeak;
      try
        for s in lng do
         Writeln(s);
      finally
        lng.free;
      end;
	      FileName:=ExtractFilePath(ParamStr(0))+'Demo.wav';
      Speak(FileName,'This is a demo using the Microsoft Translator Api from delphi, enjoy','en');
      ShellExecute(0, 'open', PChar(FileName),nil,nil, SW_SHOWNORMAL) ;
	    finally
      CoUninitialize;
    end;
 except
    on E:Exception do
        Writeln(E.Classname, ':', E.Message);
 end;
 Writeln('Press Enter to exit');
 Readln;
end.

*)
