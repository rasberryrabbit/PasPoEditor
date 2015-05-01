unit uPoReader;

{ Simple PO file reader/writer class

  Copyright (c) 2013-2015 Do-wan Kim

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

  0.11 - some fixes in parser.
  0.12 - more strict loader.
  0.14 - ngettext support functions
  0.15 - fix multi-msgstr support
  0.16 - add flag functions, fix comment line position
}


{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type

  { TPoItem }

  TPoItem = class(TList)
    private
      function GetHeader(const str:string):string;
      function GetStrItem(Index:Integer):string;
      procedure SetStrItem(Index:Integer;const str:string);
    protected
      procedure Notify(Ptr: Pointer; Action: TListNotification); override;
    public

      constructor Create;
      destructor Destroy; override;

      function Add(const str:string):pchar; overload;
      function Insert(Index: Integer; const str: string): pchar; overload;
      function GetNameStr(const Name:string):string;
      function GetMsgstr(Idx:Integer):string;
      function GetMsgstrs:TPoItem;
      procedure SetMsgstr(Idx:Integer;str:string);
      procedure SetNameStr(const Name,str:string);
      procedure GetNameValue(Idx:Integer;var Name,Value:string);
      //
      function checkflag(const flag: string): boolean;
      procedure Addflag(const flag:string);
      procedure RemoveFlag(const flag:string);

      function GetMsgstrCount:Integer;

      property StrItem[Index:Integer]:string read GetStrItem write SetStrItem;
  end;

  { TPoList }

  TPoList = class(TList)
    private
      FStream:TFileStream;
      FStrBuf:PChar;
      FLastRead,
      FBufIdx:Integer;

      function PeekChar: char;
      function Eof:Boolean;
      function ReadLine:string;
      function ReadHeader:string;
      function SkipSpace:boolean;
    protected
      procedure Notify(Ptr: Pointer; Action: TListNotification); override;
    public

      constructor Create;

      function AddItem:TPoItem;

      function Load(const FileName:string):Boolean;
      function Save(const FileName:string):Boolean;

  end;

  function StripQuote(const str: string): string;
  function AddQuote(const str:string):string;

implementation

const
  _BufSize = 4096;
  _PO_Flag = '#,';

{ TPoItem }

function TPoItem.GetHeader(const str: string): string;
var
  i,l:Integer;
  ch :char;
begin
  Result:='';
  l:=Length(str);
  i:=1;
  // remove space
  while i<=l do begin
    if str[i]>#32 then
      break;
    Inc(i);
  end;
  while i<=l do begin
    ch:=str[i];
    if ch>#32 then begin
       Result:=Result+ch;
       Inc(i);
    end else
      break;
  end;
end;

function TPoItem.GetStrItem(Index: Integer): string;
begin
  Result:=pchar(Items[Index]);
end;

procedure TPoItem.SetStrItem(Index: Integer; const str: string);
var
  NewStr:pchar;
begin
  NewStr:=StrAlloc(Length(str)+1);
  try
    system.Move(str[1],NewStr^,Length(str));
    NewStr[Length(str)]:=#0;
    Items[Index]:=NewStr;
  except
    StrDispose(NewStr);
  end;
end;

procedure TPoItem.Notify(Ptr: Pointer; Action: TListNotification);
begin
  if Action<>lnAdded then
     StrDispose(Ptr);
  inherited Notify(Ptr, Action);
end;

constructor TPoItem.Create;
begin
  inherited;
end;

destructor TPoItem.Destroy;
begin
  inherited Destroy;
end;

function TPoItem.Add(const str: string): pchar;
begin
  Result:=StrAlloc(Length(str)+1);
  try
    system.Move(str[1],Result^,Length(str));
    Result[Length(str)]:=#0;
    inherited Add(Result);
  except
    StrDispose(Result);
  end;
end;

function TPoItem.Insert(Index: Integer; const str: string): pchar;
begin
  Result:=StrAlloc(Length(str)+1);
  try
    system.Move(str[1],Result^,Length(str));
    Result[Length(str)]:=#0;
    inherited Insert(Index,Result);
  except
    StrDispose(Result);
  end;
end;

function TPoItem.GetNameStr(const Name: string): string;
var
  i:Integer;
begin
  Result:='';
  if Count>0 then
    for i:=0 to Count-1 do begin
      if CompareText(GetHeader(StrItem[i]),Name)=0 then begin
         Result:=StripQuote(Copy(StrItem[i],Length(Name)+2,4096));
         break;
      end;
    end;
end;

function TPoItem.GetMsgstr(Idx: Integer): string;
var
  i,j:integer;
  stemp:string;
begin
  Result:='';
  j:=0;
  if Count>0 then
    for i:=Idx to Count-1 do begin
      stemp:=GetHeader(StrItem[i]);
      if CompareText(Copy(stemp,1,6),'msgstr')=0 then begin
        if j=Idx then begin
          Result:=StripQuote(Copy(StrItem[i],Length(stemp)+2,4096));
          break;
        end;
        Inc(j);
      end;
    end;
end;

function TPoItem.GetMsgstrs: TPoItem;
var
  i,j:integer;
  stemp:string;
begin
  Result:=TPoItem.Create;
  if Count>0 then
    for i:=0 to Count-1 do begin
      stemp:=GetHeader(StrItem[i]);
      if CompareText(Copy(stemp,1,6),'msgstr')=0 then
        Result.Add(StrItem[i]);
    end;
end;

procedure TPoItem.SetMsgstr(Idx: Integer; str: string);
var
  i,j:Integer;
  stemp,ntemp:string;
begin
  j:=0;
  if Count>0 then
    for i:=Idx to Count-1 do begin
      stemp:=GetHeader(StrItem[i]);
      if CompareText(Copy(stemp,1,6),'msgstr')=0 then begin
        if j=idx then begin
         StrItem[i]:=stemp+' '+AddQuote(str);
         exit;
        end;
        Inc(j);
      end;
    end;
  if j=0 then
    ntemp:='msgstr'
    else
      ntemp:='msgstr['+IntToStr(Idx)+']';
  Add(ntemp+' '+AddQuote(str));
end;

procedure TPoItem.SetNameStr(const Name, str: string);
var
  i:Integer;
begin
  if Count>0 then
    for i:=0 to Count-1 do begin
      if CompareText(GetHeader(StrItem[i]),Name)=0 then begin
        if (str='') and (Name=_PO_Flag) then
          Delete(i)
          else
            StrItem[i]:=Name+' '+AddQuote(str);
        exit;
      end;
    end;
  if (Name<>'') and (Name[1]='#') then begin
    if Count>0 then
      for i:=0 to Count-1 do
        if Pos('#',GetHeader(StrItem[i]))<>1 then begin
          if (str<>'') or (GetHeader(StrItem[i])<>_PO_Flag) then
            Insert(i,Name+' '+AddQuote(str));
          break;
        end;
  end else
    if (str<>'') or (Name<>_PO_Flag) then
      Add(Name+' '+AddQuote(str));
end;

procedure TPoItem.GetNameValue(Idx: Integer; var Name, Value: string);
begin
  Name:=GetHeader(StrItem[Idx]);
  Value:=Copy(StrItem[Idx],Length(Name)+2,4096);
end;

function TPoItem.checkflag(const flag: string): boolean;
var
  s : string;
  st : TStringList;
  idx : Integer;
begin
  Result:=False;
  st := TStringList.Create;
  try
    s:=GetNameStr(_PO_Flag);
    st.CaseSensitive:=False;
    st.Delimiter:=',';
    st.DelimitedText:=s;
    Result:= st.Find(flag,idx);
  finally
    st.Free;
  end;
end;

procedure TPoItem.Addflag(const flag: string);
var
  s : string;
  st : TStringList;
  idx : Integer;
begin
  st := TStringList.Create;
  try
    s:=GetNameStr(_PO_Flag);
    st.CaseSensitive:=False;
    st.Delimiter:=',';
    st.DelimitedText:=s;
    if not st.Find(flag,idx) then begin
      st.Add(flag);
      s:=st.DelimitedText;
      SetNameStr(_PO_Flag,s);
    end;
  finally
    st.Free;
  end;
end;

procedure TPoItem.RemoveFlag(const flag: string);
var
  s : string;
  st : TStringList;
  idx : Integer;
begin
  st := TStringList.Create;
  try
    s:=GetNameStr(_PO_Flag);
    st.CaseSensitive:=False;
    st.Delimiter:=',';
    st.DelimitedText:=s;
    if st.Find(flag,idx) then begin
      st.Delete(idx);
      s:=st.DelimitedText;
      SetNameStr(_PO_Flag,s);
    end;
  finally
    st.Free;
  end;
end;

function TPoItem.GetMsgstrCount: Integer;
var
  i:integer;
begin
  Result:=0;
  if Count>0 then
    for i:=0 to Count-1 do begin
      if CompareText(Copy(GetHeader(StrItem[i]),1,6),'msgstr')=0 then
        Inc(Result);
    end;
end;


{ TPoList }

function TPoList.PeekChar: char;
begin
  if FBufIdx>=FLastRead then begin
    if FLastRead<_BufSize then
       FLastRead:=0
       else
         FLastRead:=FStream.Read(FStrBuf^,_BufSize);
    if FLastRead>0 then
       FBufIdx:=0
       else begin
         Result:=#0;
         exit;
       end;
  end;
  Result:=FStrBuf[FBufIdx];
end;

function TPoList.Eof: Boolean;
begin
  Result:=FLastRead=0;
end;

function TPoList.ReadLine: string;
var
  ch : char;
begin
  Result:='';
  while not Eof do begin
    ch:=PeekChar;
    if ch in [#13,#10] then begin
      SkipSpace;
      break;
    end else begin
      Result:=Result+ch;
      Inc(FBufIdx);
    end;
  end;
end;

function TPoList.ReadHeader: string;
var
  ch:char;
  InQ:Boolean;
  IsEscape:Boolean;
begin
  Result:='';
  InQ:=False;
  IsEscape:=False;
  while not Eof do begin
    ch:=PeekChar;
    if (ch>#32) or InQ then begin
       Result:=Result+ch;
       Inc(FBufIdx);
       if (not IsEscape) then begin
         if ch='"' then
           InQ:=not InQ
         else if ch='\' then
           IsEscape:=True;
       end else
         IsEscape:=False;
    end else
      break;
  end;
end;

// return true, if there is space char.
function TPoList.SkipSpace: boolean;
var
  ch,ch1:char;
begin
  Result:=False;
  while not Eof do begin
    ch:=PeekChar;
    // ignore one linebreak
    if ch in [#13,#10] then begin
      Inc(FBufIdx);
      ch1:=PeekChar;
      if (not Eof) and (ch1<>ch) then
         Inc(FBufIdx);
      PeekChar;
      break;
    end else
    if ch>#32 then
       break
    else begin
         Result:=True;
         if not Eof then
            Inc(FBufIdx);
    end;
  end;
end;

procedure TPoList.Notify(Ptr: Pointer; Action: TListNotification);
begin
  if Action<>lnAdded then
     TPoItem(Ptr).Destroy;
  inherited Notify(Ptr, Action);
end;

constructor TPoList.Create;
begin
  inherited;
end;

function TPoList.AddItem: TPoItem;
begin
  Result:=TPoItem.Create;
  try
    inherited Add(Pointer(Result));
  except
    Result.Free;
  end;
end;

function TPoList.Load(const FileName: string): Boolean;
var
  stemp,shead:string;
  itemp:TPoItem;
  IsFirst,LastItem:Boolean;
begin
  Result:=False;
  Getmem(FStrBuf,_BufSize);
  try
    // for read buffer
    FLastRead:=_BufSize;
    FBufIdx:=_BufSize;
    FStream:=TFileStream.Create(FileName,fmOpenRead or fmShareDenyWrite);
    try
      while not Eof do begin
        IsFirst:=True;
        LastItem:=False;
        itemp:=AddItem;
        while not Eof do begin
          shead:=ReadHeader;
          if SkipSpace then begin
             if not IsFirst then
               itemp.Add(stemp)
               else
                 IsFirst:=False;
             stemp:=shead+' '+ReadLine;
             if LastItem then begin
               // new item
               if (Length(shead)>0) and
                  ((shead[1]='#') or (CompareText(Copy(shead,1,6),'msgstr')<>0)) then begin
                 itemp:=AddItem;
                 IsFirst:=False;
                 LastItem:=False;
               end;
             end else
               LastItem:=CompareText(Copy(shead,1,6),'msgstr')=0;
          end else
               if shead='' then begin
                 itemp.Add(stemp);
                 break;
                 end else
                   stemp:=stemp+sLineBreak+shead;
          if Eof then
            itemp.Add(stemp);
        end;
      end;
      Result:=True;
    finally
      FStream.Free;
    end;
  finally
    Freemem(FStrBuf);
  end;
end;

function TPoList.Save(const FileName: string): Boolean;
var
  i,j: Integer;
  itemp:TPoItem;
  stemp,stemp1:string;
begin
  Result:=False;
  FStream:=TFileStream.Create(FileName,fmCreate or fmOpenWrite or fmShareDenyWrite);
  try
    for i:=0 to Count-1 do
    begin
      itemp:=TPoItem(Items[i]);
      if itemp.Count>0 then
      for j:=0 to itemp.Count-1 do begin
        itemp.GetNameValue(j,stemp,stemp1);
        if stemp<>'' then
          stemp:=stemp+' '+stemp1
          else
            stemp:=stemp1;
        FStream.Write(stemp[1],Length(stemp));
        FStream.Write(sLineBreak[1],Length(sLineBreak));
      end;
      if stemp<>'' then
        Fstream.Write(sLineBreak[1],Length(sLineBreak));
    end;
    Result:=True;
  finally
    FStream.Free;
  end;
end;

function StripQuote(const str: string): string;
var
  ch,ch1:char;
  l,i:integer;
  IsFirstLine:Boolean;
  IsEscape:Boolean;
begin
  Result:='';
  l:=Length(str);
  i:=1;
  ch1:=#0;
  IsFirstLine:=True;
  IsEscape:=False;
  while i<=l do begin
    ch:=str[i];
    if (not IsEscape) and (ch='\') then begin
      Result:=Result+ch;
      IsEscape:=True;
    end else
    begin
      // ignore first line null string
      if IsFirstLine and (ch in [#13,#10]) then begin
        IsFirstLine:=False;
        Inc(i);
        ch1:=ch;
        if i<=l then begin
          ch:=str[i];
          if ch1=ch then
            Dec(i);
        end;
        if Result<>'' then
           Result:=Result+sLineBreak;
      end else
      if IsEscape or (ch<>'"') then begin
        if IsEscape and ((ch<#33) or (ch>#127)) then
          Result:=Result+'\';
        Result:=Result+ch;
      end;
      IsEscape:=False;
    end;
    ch1:=ch;
    inc(i);
  end;
end;

function AddQuote(const str: string): string;
var
  ch,ch1:char;
  l,i:integer;
  IsMultiLine:Boolean;
  IsEscape:Boolean;
begin
  Result:='"';
  l:=Length(str);
  i:=1;
  ch1:=#0;
  IsMultiLine:=False;
  IsEscape:=False;
  while i<=l do begin
    ch:=str[i];
    if (not IsEscape) and (ch='\') then
      IsEscape:=True
    else
    // split multi line with quote char
    if ch in [#13,#10] then begin
      IsMultiLine:=True;
      if IsEscape then begin
         Result:=Result+'\';
         IsEscape:=False;
      end;
      Result:=Result+'"';
      Result:=Result+ch;
      ch1:=ch;
      inc(i);
      if i<=l then begin
        ch:=str[i];
        if ch<>ch1 then
          Result:=Result+ch
          else
          Dec(i);
      end;
      Result:=Result+'"';
      Inc(i);
      Continue;
    end else begin
      if (not IsEscape) and (ch='"') then
        Result:=Result+'\';
      if IsEscape and ((ch<#33) or (ch>#127)) then
        Result:=Result+'\';
      IsEscape:=False;
    end;
    Result:=Result+ch;
    ch1:=ch;
    inc(i);
  end;
  if IsEscape then
    Result:=Result+'\';
  if IsMultiLine then
    Result:='""'+sLineBreak+Result;
  Result:=Result+'"';
end;

end.

