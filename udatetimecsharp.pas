unit uDateTimeCSharp;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, DateUtils;


Function DateTimeToUnix_us(const AValue: TDateTime; AInputIsUTC: Boolean = True): Int64;

implementation

uses
  SysConst;

const
  uSecsPerDay=MSecsPerDay*1000;
  LFAI = High(Word);

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


function DateTimeToTimeStamp(DateTime: TDateTime): TTimeStamp;
Var
  D : Double;
begin
  D:=DateTime * Single(uSecsPerDay);
  if D<0 then
    D:=D-0.5
  else
    D:=D+0.5;
  result.Time := Abs(Trunc(D)) Mod uSecsPerDay;
  result.Date := DateDelta + Trunc(D) div uSecsPerDay;
end;

procedure DecodeTime_us(Time: TDateTime; out Hour, Minute, Second, MilliSecond, MicroSecond: word);
Var
  l : cardinal;
begin
 l := DateTimeToTimeStamp(Time).Time;
 Hour   := l div 3600000000;
 l := l mod 3600000000;
 Minute := l div 60000000;
 l := l mod 60000000;
 Second := l div 1000000;
 l := l mod 1000000;
 MilliSecond := l div 1000;
 l := l mod 1000;
 MicroSecond:=l;
end;

Procedure DecodeDateTime_us(const AValue: TDateTime; out AYear, AMonth, ADay, AHour, AMinute, ASecond, AMilliSecond, AMicroSecond: Word);
begin
  DecodeTime_us(AValue,AHour,AMinute,ASecond,AMilliSecond,AMicroSecond);
  if AHour=24 then // can happen due rounding issues mantis 17123
    begin
      AHour:=0; // rest is already zero
      DecodeDate(round(AValue),AYear,AMonth,ADay);
    end
  else
    DecodeDate(AValue,AYear,AMonth,ADay);
end;

function TryEncodeTime_us(Hour, Min, Sec, MSec, USec:word; Out Time : TDateTime) : boolean;

begin
  Result:=((Hour<24) and (Min<60) and (Sec<60) and (MSec<1000) and (USec<1000)) or
    { allow leap second }
    ((Hour=23) and (Min=59) and (Sec=60) and (MSec<1000) and (USec<1000));
  If Result then
    Time:=TDateTime(cardinal(Hour)*3600000000+cardinal(Min)*60000000+cardinal(Sec)*1000000+MSec*1000+USec)/USecsPerDay;
end;

Function TryEncodeDateTime_us(const AYear, AMonth, ADay, AHour, AMinute, ASecond, AMilliSecond, AMicroSecond: Word; out AValue: TDateTime): Boolean;

Var
 tmp : TDateTime;

begin
  Result:=TryEncodeDate(AYear,AMonth,ADay,AValue);
  Result:=Result and TryEncodeTime_us(AHour,AMinute,ASecond,Amillisecond,AMicroSecond,Tmp);
  If Result then
    Avalue:=ComposeDateTime(AValue,Tmp);
end;

Function TryRecodeDateTime_us(const AValue: TDateTime; const AYear, AMonth, ADay, AHour, AMinute, ASecond, AMilliSecond, AMicroSecond: Word; out AResult: TDateTime): Boolean;

  Procedure FV (Var AV : Word; Arg : Word);

  begin
    If (Arg<>LFAI) then
      AV:=Arg;
  end;

Var
  Y,M,D,H,N,S,MS,US : Word;

begin
  DecodeDateTime_us(AValue,Y,M,D,H,N,S,MS,US);
  FV(Y,AYear);
  FV(M,AMonth);
  FV(D,ADay);
  FV(H,AHour);
  FV(N,AMinute);
  FV(S,ASecond);
  FV(MS,AMillisecond);
  FV(US,AMicroSecond);
  Result:=TryEncodeDateTime_us(Y,M,D,H,N,S,MS,US,AResult);
end;

Procedure InvalidDateTimeError_us(const AYear, AMonth, ADay, AHour, AMinute, ASecond, AMilliSecond, AMicroSecond: Word; const ABaseDate: TDateTime);

  Function DoField(Arg,Def : Word; Unknown: String) : String;

  begin
    If (Arg<>LFAI) then
      Result:=Format('%.*d',[Length(Unknown),Arg])
    else if (ABaseDate=0) then
      Result:=Unknown
    else
      Result:=Format('%.*d',[Length(Unknown),Arg]);
  end;

Var
  Y,M,D,H,N,S,MS,US : Word;
  Msg : String;

begin
  DecodeDateTime_us(ABasedate,Y,M,D,H,N,S,MS,US);
  Msg:=DoField(AYear,Y,'????');
  Msg:=Msg+DefaultFormatSettings.DateSeparator+DoField(AMonth,M,'??');
  Msg:=Msg+DefaultFormatSettings.DateSeparator+DoField(ADay,D,'??');
  Msg:=Msg+' '+DoField(AHour,H,'??');
  Msg:=Msg+DefaultFormatSettings.TimeSeparator+DoField(AMinute,N,'??');
  Msg:=Msg+DefaultFormatSettings.TimeSeparator+Dofield(ASecond,S,'??');
  Msg:=Msg+DefaultFormatSettings.DecimalSeparator+DoField(AMilliSecond,MS,'???');
  Msg:=Msg+DefaultFormatSettings.DecimalSeparator+DoField(AMicroSecond,US,'???');
  Raise EConvertError.CreateFmt(SErrInvalidTimeStamp,[Msg]);
end;

Function RecodeDateTime_us(const AValue: TDateTime; const AYear, AMonth, ADay, AHour, AMinute, ASecond, AMilliSecond, AMicroSecond: Word): TDateTime;
begin
  If Not TryRecodeDateTime_us(AValue,AYear,AMonth,ADay,AHour,AMinute,ASecond,AMilliSecond,AMicroSecond,Result) then
    InvalidDateTimeError_us(AYear,AMonth,ADay,AHour,AMinute,ASecond,AMilliSecond,AMicroSecond,AValue);
end;

Function RecodeMicroSecond(const AValue: TDateTime; const AMicroSecond: Word): TDateTime;
begin
  Result := RecodeDateTime_us(AValue,LFAI,LFAI,LFAI,LFAI,LFAI,LFAI,LFAI,AMicroSecond);
end;

Function DateTimeToUnix_us(const AValue: TDateTime; AInputIsUTC: Boolean = True): Int64;
Var
  T : TDateTime;
begin
  T:=aValue;
  if Not aInputisUTC then
    T:=IncMinute(T,GetLocalTimeOffset(AValue, AInputisUTC));
  Result:=Round(DateTimeDiff(RecodeMicroSecond(T,0),UnixEpoch)*SecsPerDay*1000);
end;


end.

