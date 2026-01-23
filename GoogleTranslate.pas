unit GoogleTranslate;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fphttpclient, fpjson, jsonparser, RegExpr, GToken;

type
  { TTranslated - 번역 결과 클래스 }
  TTranslated = class
  private
    FSrc: string;
    FDest: string;
    FOrigin: string;
    FText: string;
    FPronunciation: string;
  public
    constructor Create(ASrc, ADest, AOrigin, AText, APronunciation: string);
    property Src: string read FSrc;
    property Dest: string read FDest;
    property Origin: string read FOrigin;
    property Text: string read FText;
    property Pronunciation: string read FPronunciation;
    function ToString: string; override;
  end;

  { TDetected - 언어 감지 결과 클래스 }
  TDetected = class
  private
    FLang: string;
    FConfidence: Double;
  public
    constructor Create(ALang: string; AConfidence: Double);
    property Lang: string read FLang;
    property Confidence: Double read FConfidence;
    function ToString: string; override;
  end;

  { TGoogleTranslator - 번역기 클래스 }
  TGoogleTranslator = class
  private
    FServiceURL: string;
    FUserAgent: string;
    FTimeout: Integer;
    FHTTPClient: TFPHTTPClient;
    FTokenAcquirer: TTokenAcquirer;
    
    function ExtractTranslationFromJSON(const JSONStr: string; 
      const Src, Dest, Origin: string): TTranslated;
    function ExtractDetectionFromJSON(const JSONStr: string): TDetected;
    function BuildTranslateURL(const Text, Src, Dest: string): string;
    function BuildDetectURL(const Text: string): string;
    function URLEncode(const S: string): string;
  public
    constructor Create(const AServiceURL: string = 'https://translate.googleapis.com');
    destructor Destroy; override;
    
    { 텍스트 번역 메서드 }
    function Translate(const Text: string; const Dest: string = 'en'; 
      const Src: string = 'auto'): TTranslated;
    
    { 언어 감지 메서드 }
    function Detect(const Text: string): TDetected;
    
    { 일괄 번역 메서드 }
    function TranslateBatch(const Texts: array of string; const Dest: string = 'en'; 
      const Src: string = 'auto'): TList;
    
    property ServiceURL: string read FServiceURL write FServiceURL;
    property UserAgent: string read FUserAgent write FUserAgent;
    property Timeout: Integer read FTimeout write FTimeout;
  end;

  { 언어 코드 상수 }
const
  LANGUAGES: array[0..103] of array[0..1] of string = (
    ('af', 'afrikaans'),
    ('sq', 'albanian'),
    ('am', 'amharic'),
    ('ar', 'arabic'),
    ('hy', 'armenian'),
    ('az', 'azerbaijani'),
    ('eu', 'basque'),
    ('be', 'belarusian'),
    ('bn', 'bengali'),
    ('bs', 'bosnian'),
    ('bg', 'bulgarian'),
    ('ca', 'catalan'),
    ('ceb', 'cebuano'),
    ('ny', 'chichewa'),
    ('zh-cn', 'chinese (simplified)'),
    ('zh-tw', 'chinese (traditional)'),
    ('co', 'corsican'),
    ('hr', 'croatian'),
    ('cs', 'czech'),
    ('da', 'danish'),
    ('nl', 'dutch'),
    ('en', 'english'),
    ('eo', 'esperanto'),
    ('et', 'estonian'),
    ('tl', 'filipino'),
    ('fi', 'finnish'),
    ('fr', 'french'),
    ('fy', 'frisian'),
    ('gl', 'galician'),
    ('ka', 'georgian'),
    ('de', 'german'),
    ('el', 'greek'),
    ('gu', 'gujarati'),
    ('ht', 'haitian creole'),
    ('ha', 'hausa'),
    ('haw', 'hawaiian'),
    ('iw', 'hebrew'),
    ('hi', 'hindi'),
    ('hmn', 'hmong'),
    ('hu', 'hungarian'),
    ('is', 'icelandic'),
    ('ig', 'igbo'),
    ('id', 'indonesian'),
    ('ga', 'irish'),
    ('it', 'italian'),
    ('ja', 'japanese'),
    ('jw', 'javanese'),
    ('kn', 'kannada'),
    ('kk', 'kazakh'),
    ('km', 'khmer'),
    ('ko', 'korean'),
    ('ku', 'kurdish (kurmanji)'),
    ('ky', 'kyrgyz'),
    ('lo', 'lao'),
    ('la', 'latin'),
    ('lv', 'latvian'),
    ('lt', 'lithuanian'),
    ('lb', 'luxembourgish'),
    ('mk', 'macedonian'),
    ('mg', 'malagasy'),
    ('ms', 'malay'),
    ('ml', 'malayalam'),
    ('mt', 'maltese'),
    ('mi', 'maori'),
    ('mr', 'marathi'),
    ('mn', 'mongolian'),
    ('my', 'myanmar (burmese)'),
    ('ne', 'nepali'),
    ('no', 'norwegian'),
    ('ps', 'pashto'),
    ('fa', 'persian'),
    ('pl', 'polish'),
    ('pt', 'portuguese'),
    ('pa', 'punjabi'),
    ('ro', 'romanian'),
    ('ru', 'russian'),
    ('sm', 'samoan'),
    ('gd', 'scots gaelic'),
    ('sr', 'serbian'),
    ('st', 'sesotho'),
    ('sn', 'shona'),
    ('sd', 'sindhi'),
    ('si', 'sinhala'),
    ('sk', 'slovak'),
    ('sl', 'slovenian'),
    ('so', 'somali'),
    ('es', 'spanish'),
    ('su', 'sundanese'),
    ('sw', 'swahili'),
    ('sv', 'swedish'),
    ('tg', 'tajik'),
    ('ta', 'tamil'),
    ('te', 'telugu'),
    ('th', 'thai'),
    ('tr', 'turkish'),
    ('uk', 'ukrainian'),
    ('ur', 'urdu'),
    ('uz', 'uzbek'),
    ('vi', 'vietnamese'),
    ('cy', 'welsh'),
    ('xh', 'xhosa'),
    ('yi', 'yiddish'),
    ('yo', 'yoruba'),
    ('zu', 'zulu')
  );

implementation

uses
  opensslsockets;

{ TTranslated }

constructor TTranslated.Create(ASrc, ADest, AOrigin, AText, APronunciation: string);
begin
  inherited Create;
  FSrc := ASrc;
  FDest := ADest;
  FOrigin := AOrigin;
  FText := AText;
  FPronunciation := APronunciation;
end;

function TTranslated.ToString: string;
begin
  Result := Format('Translated(src=%s, dest=%s, text=%s, pronunciation=%s)', 
    [FSrc, FDest, FText, FPronunciation]);
end;

{ TDetected }

constructor TDetected.Create(ALang: string; AConfidence: Double);
begin
  inherited Create;
  FLang := ALang;
  FConfidence := AConfidence;
end;

function TDetected.ToString: string;
begin
  Result := Format('Detected(lang=%s, confidence=%f)', [FLang, FConfidence]);
end;

{ TGoogleTranslator }

constructor TGoogleTranslator.Create(const AServiceURL: string);
begin
  inherited Create;
  FServiceURL := AServiceURL;
  FUserAgent := 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36';
  FTimeout := 30000;
  
  FHTTPClient := TFPHTTPClient.Create(nil);
  FHTTPClient.AddHeader('User-Agent', FUserAgent);
  
  FTokenAcquirer := TTokenAcquirer.Create('0', 'translate.google.com');
end;

destructor TGoogleTranslator.Destroy;
begin
  FTokenAcquirer.Free;
  FHTTPClient.Free;
  inherited Destroy;
end;

function TGoogleTranslator.URLEncode(const S: string): string;
var
  i: Integer;
  Ch: Char;
begin
  Result := '';
  for i := 1 to Length(S) do
  begin
    Ch := S[i];
    if Ch in ['A'..'Z', 'a'..'z', '0'..'9', '-', '_', '.', '~'] then
      Result := Result + Ch
    else
      Result := Result + '%' + IntToHex(Ord(Ch), 2);
  end;
end;

function TGoogleTranslator.BuildTranslateURL(const Text, Src, Dest: string): string;
var
  Token: string;
begin
  Token := FTokenAcquirer.DoToken(Text);
  
  Result := FServiceURL + '/translate_a/single?client=gtx' +
    '&sl=' + Src +
    '&tl=' + Dest +
    '&dt=t&dt=bd&dt=qc&dt=rm&dt=ex' +
    '&q=' + URLEncode(Text) +
    '&tk=' + Token;
end;

function TGoogleTranslator.BuildDetectURL(const Text: string): string;
var
  Token: string;
begin
  Token := FTokenAcquirer.DoToken(Text);
  
  Result := FServiceURL + '/translate_a/single?client=gtx' +
    '&sl=auto&tl=en&dt=t' +
    '&q=' + URLEncode(Text) +
    '&tk=' + Token;
end;

function TGoogleTranslator.ExtractTranslationFromJSON(const JSONStr: string; 
  const Src, Dest, Origin: string): TTranslated;
var
  JSONData: TJSONData;
  JSONArray: TJSONArray;
  TranslatedText: string;
  Pronunciation: string;
  i: Integer;
  SrcLang: string;
begin
  TranslatedText := '';
  Pronunciation := '';
  SrcLang := Src;
  
  try
    JSONData := GetJSON(JSONStr);
    try
      if JSONData is TJSONArray then
      begin
        JSONArray := TJSONArray(JSONData);
        
        // 번역된 텍스트 추출
        if (JSONArray.Count > 0) and (JSONArray[0] is TJSONArray) then
        begin
          for i := 0 to TJSONArray(JSONArray[0]).Count - 1 do
          begin
            if TJSONArray(JSONArray[0])[i] is TJSONArray then
            begin
              if TJSONArray(TJSONArray(JSONArray[0])[i]).Count > 0 then
                if not TJSONArray(TJSONArray(JSONArray[0])[i]).Nulls[0] then
                TranslatedText := TranslatedText + 
                  TJSONArray(TJSONArray(JSONArray[0])[i]).Strings[0];
            end;
          end;
        end;
        
        // 소스 언어 추출
        if (JSONArray.Count > 2) and (JSONArray[2] <> nil) then
          SrcLang := JSONArray[2].AsString;
          
        // 발음 추출 (선택적)
        if (JSONArray.Count > 0) and (JSONArray[0] is TJSONArray) then
        begin
          if (TJSONArray(JSONArray[0]).Count > 0) and 
             (TJSONArray(JSONArray[0])[0] is TJSONArray) then
          begin
            if TJSONArray(TJSONArray(JSONArray[0])[0]).Count > 1 then
              Pronunciation := TJSONArray(TJSONArray(JSONArray[0])[0]).Strings[1];
          end;
        end;
      end;
    finally
      JSONData.Free;
    end;
  except
    on E: Exception do
      raise Exception.Create('JSON Parsing error: ' + E.Message);
  end;
  
  Result := TTranslated.Create(SrcLang, Dest, Origin, TranslatedText, Pronunciation);
end;

function TGoogleTranslator.ExtractDetectionFromJSON(const JSONStr: string): TDetected;
var
  JSONData: TJSONData;
  JSONArray: TJSONArray;
  Lang: string;
  Confidence: Double;
begin
  Lang := 'unknown';
  Confidence := 0.0;
  
  try
    JSONData := GetJSON(JSONStr);
    try
      if JSONData is TJSONArray then
      begin
        JSONArray := TJSONArray(JSONData);
        if (JSONArray.Count > 2) and (JSONArray[2] <> nil) then
        begin
          Lang := JSONArray[2].AsString;
          Confidence := 1.0;
        end;
      end;
    finally
      JSONData.Free;
    end;
  except
    on E: Exception do
      raise Exception.Create('JSON Parsing error: ' + E.Message);
  end;
  
  Result := TDetected.Create(Lang, Confidence);
end;

function TGoogleTranslator.Translate(const Text: string; const Dest: string; 
  const Src: string): TTranslated;
var
  URL: string;
  Response: string;
begin
  if Text = '' then
    raise Exception.Create('Translation Text is empty!');
    
  URL := BuildTranslateURL(Text, Src, Dest);
  
  try
    Response := FHTTPClient.Get(URL);
    Result := ExtractTranslationFromJSON(UTF8Decode(Response), Src, Dest, Text);
  except
    on E: Exception do
      raise Exception.Create('Translation error: ' + E.Message);
  end;
end;

function TGoogleTranslator.Detect(const Text: string): TDetected;
var
  URL: string;
  Response: string;
begin
  if Text = '' then
    raise Exception.Create('Detection Text is empty!');
    
  URL := BuildDetectURL(Text);
  
  try
    Response := FHTTPClient.Get(URL);
    Result := ExtractDetectionFromJSON(UTF8Decode(Response));
  except
    on E: Exception do
      raise Exception.Create('Language detection error: ' + E.Message);
  end;
end;

function TGoogleTranslator.TranslateBatch(const Texts: array of string; 
  const Dest: string; const Src: string): TList;
var
  i: Integer;
  Translated: TTranslated;
begin
  Result := TList.Create;
  
  for i := Low(Texts) to High(Texts) do
  begin
    Translated := Translate(Texts[i], Dest, Src);
    Result.Add(Translated);
  end;
end;

end.
