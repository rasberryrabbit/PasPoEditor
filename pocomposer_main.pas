unit pocomposer_main;

{$mode objfpc}{$H+}

{ Simple PO Editor

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
}

{$define USE_TRANSLTR}


interface

uses
  Classes, SysUtils, FileUtil, MRUList, ExtendedNotebook, Forms, Controls,
  Graphics, Dialogs, Menus, ActnList, StdActns, ComCtrls, StdCtrls, ExtCtrls,
  types, contnrs;

type

  { TForm1 }

  TForm1 = class(TForm)
    EditGotoPrevFuzzy: TAction;
    EditGotoNextFuzzy: TAction;
    CheckBoxFuzzy: TCheckBox;
    MenuItem42: TMenuItem;
    MenuItem43: TMenuItem;
    MenuItem44: TMenuItem;
    MenuItem45: TMenuItem;
    TranslateSetup: TAction;
    MenuItem40: TMenuItem;
    MenuItem41: TMenuItem;
    OptionSortComment: TAction;
    EditSelAllUntran: TAction;
    EditSelAllTran: TAction;
    EditGotoPrevTran: TAction;
    EditGotoNextTran: TAction;
    EditGotoPrevUntran: TAction;
    EditGotoNextUnTran: TAction;
    EditShowRawItem: TAction;
    EditMemoRight: TAction;
    EditMemoLeft: TAction;
    EditStripUntran: TAction;
    MemoMsg: TMemo;
    MenuItem30: TMenuItem;
    MenuItem31: TMenuItem;
    MenuItem32: TMenuItem;
    MenuItem33: TMenuItem;
    MenuItem34: TMenuItem;
    MenuItem35: TMenuItem;
    MenuItem36: TMenuItem;
    MenuItem37: TMenuItem;
    MenuItem38: TMenuItem;
    MenuItem39: TMenuItem;
    NoteMsg: TExtendedNotebook;
    MenuItem29: TMenuItem;
    ReplaceDialog1: TReplaceDialog;
    AddPO: TAction;
    EditExportSel: TAction;
    ExportPO: TAction;
    EditPOFileProp: TAction;
    ImportPO: TAction;
    ComboBoxSrcLang: TComboBox;
    MenuItem22: TMenuItem;
    MenuItem23: TMenuItem;
    MenuItem24: TMenuItem;
    MenuItem25: TMenuItem;
    MenuItem26: TMenuItem;
    MenuItem27: TMenuItem;
    MenuItem28: TMenuItem;
    MenuItemRecent: TMenuItem;
    OpenDialogImport: TOpenDialog;
    SaveDialogExport: TSaveDialog;
    SheetMsg1: TTabSheet;
    TranslateMsg: TAction;
    MenuItem21: TMenuItem;
    TranslateCopy: TAction;
    Buttonclr: TButton;
    ComboBoxLang: TComboBox;
    MemoTran: TMemo;
    MenuItem19: TMenuItem;
    MenuItem20: TMenuItem;
    Panel2: TPanel;
    TranslateText1: TAction;
    ImageList1: TImageList;
    MenuItem15: TMenuItem;
    SearchNext: TAction;
    SearchFind: TAction;
    EditUp: TAction;
    EditDown: TAction;
    ActionList1: TActionList;
    EditCopy1: TEditCopy;
    EditCut1: TEditCut;
    EditDelete1: TEditDelete;
    EditPaste1: TEditPaste;
    EditSelectAll1: TEditSelectAll;
    EditUndo1: TEditUndo;
    FileExit1: TFileExit;
    FileOpen1: TFileOpen;
    FileSaveAs1: TFileSaveAs;
    ListBoxPO: TListBox;
    MainMenu1: TMainMenu;
    MemoId: TMemo;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem17: TMenuItem;
    MenuItem18: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem111: TMenuItem;
    MenuItemEdit: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    MRUManager1: TMRUManager;
    Panel1: TPanel;
    StatusBar1: TStatusBar;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    procedure ActionList1Update(AAction: TBasicAction; var Handled: Boolean);
    procedure AddPOExecute(Sender: TObject);
    procedure ButtonclrClick(Sender: TObject);
    procedure EditCopy1Execute(Sender: TObject);
    procedure EditCut1Execute(Sender: TObject);
    procedure EditDelete1Execute(Sender: TObject);
    procedure EditDownExecute(Sender: TObject);
    procedure EditExportSelExecute(Sender: TObject);
    procedure EditGotoNextFuzzyExecute(Sender: TObject);
    procedure EditGotoNextTranExecute(Sender: TObject);
    procedure EditGotoNextUnTranExecute(Sender: TObject);
    procedure EditGotoPrevFuzzyExecute(Sender: TObject);
    procedure EditGotoPrevTranExecute(Sender: TObject);
    procedure EditGotoPrevUntranExecute(Sender: TObject);
    procedure EditMemoLeftExecute(Sender: TObject);
    procedure EditMemoRightExecute(Sender: TObject);
    procedure EditPaste1Execute(Sender: TObject);
    procedure EditPOFilePropExecute(Sender: TObject);
    procedure EditSelAllTranExecute(Sender: TObject);
    procedure EditSelAllUntranExecute(Sender: TObject);
    procedure EditSelectAll1Execute(Sender: TObject);
    procedure EditShowRawItemExecute(Sender: TObject);
    procedure EditStripUntranExecute(Sender: TObject);
    procedure EditUndo1Execute(Sender: TObject);
    procedure EditUpExecute(Sender: TObject);
    procedure ExportPOExecute(Sender: TObject);
    procedure FileOpen1Accept(Sender: TObject);
    procedure FileOpen1BeforeExecute(Sender: TObject);
    procedure FileSaveAs1Accept(Sender: TObject);
    procedure FileSaveAs1BeforeExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ImportPOExecute(Sender: TObject);
    procedure ListBoxPOClick(Sender: TObject);
    procedure ListBoxPODblClick(Sender: TObject);
    procedure ListBoxPODrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
    procedure ListBoxPOKeyPress(Sender: TObject; var Key: char);
    procedure ListBoxPOMeasureItem(Control: TWinControl; Index: Integer;
      var AHeight: Integer);
    procedure MemoMsgExit(Sender: TObject);
    procedure MRUManager1Click(Sender: TObject; const RecentName,
      ACaption: string; UserData: PtrInt);
    procedure NoteMsgChange(Sender: TObject);
    procedure OptionSortCommentExecute(Sender: TObject);
    procedure ReplaceDialog1Close(Sender: TObject);
    procedure ReplaceDialog1Find(Sender: TObject);
    procedure ReplaceDialog1Replace(Sender: TObject);
    procedure ReplaceDialog1Show(Sender: TObject);
    procedure SearchFindExecute(Sender: TObject);
    procedure SearchNextExecute(Sender: TObject);
    procedure TranslateCopyExecute(Sender: TObject);
    procedure TranslateMsgExecute(Sender: TObject);
    procedure TranslateSetupExecute(Sender: TObject);
    procedure TranslateText1Execute(Sender: TObject);
    procedure TranslateText1Update(Sender: TObject);
  private
    { private declarations }
  public
    PoList:TStringList; // for measure item height
    mIsFind:Integer;

    procedure GotoItems(untran, up: Boolean; IsFuzzy: Boolean=False);
    procedure POUpdateMsg;
    function EnableTranslate:Boolean;
    procedure RefreshListBoxPO;
    procedure SelectAllItems(untran:Boolean);
    procedure SetupBingApi;
    { public declarations }
  end;

var
  Form1: TForm1;

const
  ConfigFile='poEdit.ini';

implementation

{$R *.lfm}

uses uPoReader, LCLType, {RegExpr,} BRRE, {$ifndef USE_TRANSLTR}uMSTRanAPI{$else}utransltrorg{$endif}, LazUTF8, udlgprop,
  DefaultTranslator, gettext, Translations, udlgshowraw, udlgBingApiInfo;

var
  mPo:TPoList=nil;
  lastIndex:Integer=-1;
  lastFindIndex:TPoint=(X:-1;Y:0);
  OldFindStr:string='';
  OldReplaceStr:string='';
  FindCase:Boolean=False;
  modified:Boolean=False;
  DisableTranslator:Boolean=False;
  bingapiid:string='';
  bingclient_id:string='';
  bingclient_secret:string='';


resourcestring
  TranslateError='Translator Error';
  rsNoMatchesFound = 'No Matches found.';
  rsAuto = 'Auto';
  rsAlreadyHaveTranslation = 'Already have translation, Do you overwrite all?';
  rsDMessagesImp = '%d messages imported.';
  rsDPatchedDAdd = '%d patched, %d added';
  rsItWillLostCh = 'It will lost changes. continue anyway?';
  rsReplace = 'Replace?';
  rsCannotBeUndo = 'Cannot be undo, are you sure?';

const
  strfuzzy = 'fuzzy';

function QueryDialog: Boolean;
begin
  with CreateMessageDialog(rsAlreadyHaveTranslation,
    mtWarning, mbYesNo) do begin
    try
      ActiveControl:=TWinControl(Controls[1]);
      Position:=poOwnerFormCenter;
      Result:=ShowModal=mrYes;
    finally
      Free;
    end;
  end;
end;

function QueryContinue: Boolean;
begin
  with CreateMessageDialog(rsItWillLostCh,
    mtWarning, mbYesNo) do begin
    try
      ActiveControl:=TWinControl(Controls[1]);
      Position:=poOwnerFormCenter;
      Result:=ShowModal=mrYes;
    finally
      Free;
    end;
  end;
end;

function QueryWork: Boolean;
begin
  with CreateMessageDialog(rsCannotBeUndo,
    mtWarning, mbYesNo) do begin
    try
      ActiveControl:=TWinControl(Controls[1]);
      Position:=poOwnerFormCenter;
      Result:=ShowModal=mrYes;
    finally
      Free;
    end;
  end;
end;

function QueryReplace: Integer;
begin
  with CreateMessageDialog(rsReplace,
    mtConfirmation, mbYesNoCancel) do begin
    try
      ActiveControl:=TWinControl(Controls[0]);
      Position:=poOwnerFormCenter;
      Result:=ShowModal;
    finally
      Free;
    end;
  end;
end;

function CheckConfigFile:Boolean;
var
  f:TStringList;
  fname,vstr:string;
  i:integer;
begin
  try
    fname:=ExtractFilePath(ParamStr(0))+ConfigFile;
    Result:=FileExists(fname);
    if Result then begin
      f:=TStringList.Create;
      try
        f.LoadFromFile(fname);
        DisableTranslator:=StrToIntDef(f.Values['skiptran'],0)<>0;
        bingapiid:=f.Values['bingid'];
        bingclient_id:=f.Values['bingclientid'];
        bingclient_secret:=f.Values['bingclientsecret'];
      finally
        f.Free;
      end;
    end;
  except
    Result:=False;
  end;
end;

function CustomComment(List: TStringList; Index1, Index2: Integer): Integer;
var
  itemp1, itemp2:TPoItem;
  cstr1,cstr2:string;
begin
  itemp1:=TPoItem(List.Objects[Index1]);
  itemp2:=TPoItem(List.Objects[Index2]);
  if itemp1<>nil then
    cstr1:=itemp1.GetNameStr('#:')
    else
      cstr1:='';
  if itemp2<>nil then
    cstr2:=itemp2.GetNameStr('#:')
    else
      cstr2:='';
  Result:=CompareStr(cstr1,cstr2);
end;

{ TForm1 }


procedure TForm1.SearchFindExecute(Sender: TObject);
begin
  ReplaceDialog1.FindText:=OldFindStr;
  ReplaceDialog1.ReplaceText:=OldReplaceStr;
  if FindCase then
    ReplaceDialog1.Options:=ReplaceDialog1.Options+[frMatchCase];
  ReplaceDialog1.Options:=ReplaceDialog1.Options-[frReplace,frReplaceAll];
  ReplaceDialog1.Execute;
end;

procedure TForm1.SearchNextExecute(Sender: TObject);
begin
  if ReplaceDialog1.FindText='' then begin
    ReplaceDialog1.Execute;
  end else begin
    if (frReplace in ReplaceDialog1.Options) or
       (frReplaceAll in ReplaceDialog1.Options) then
         ReplaceDialog1Replace(nil)
         else
           ReplaceDialog1Find(nil);
  end;
end;


procedure TForm1.TranslateCopyExecute(Sender: TObject);
var
  msg:string;
  memo:TMemo;
begin
  if MemoTran.Lines.Count>0 then begin
    msg:=MemoTran.Lines[MemoTran.Lines.Count-1];
    if msg<>'' then begin
      memo:=NoteMsg.Pages[NoteMsg.PageIndex].Controls[0] as TMemo;
      if memo.SelLength>0 then
        memo.SelText:=pchar(msg)
        else
          memo.Text:=pchar(msg);
    end;
  end;
end;

procedure TForm1.TranslateMsgExecute(Sender: TObject);
var
  msg,ret:string;
  memo,memoout:TMemo;
  spos : Integer;
begin
  if ComboBoxLang.ItemIndex<>-1 then begin
    if ActiveControl is TMemo then
      memo:=TMemo(ActiveControl)
      else
        memo:=NoteMsg.Pages[NoteMsg.PageIndex].Controls[0] as TMemo;
    if memo.SelLength>0 then
      msg:=memo.SelText
      else
        msg:=memo.Text;
    if msg<>'' then begin
      try
        if ComboBoxSrcLang.ItemIndex>0 then
          ret:=ComboBoxSrcLang.Text
          else
            ret:={$ifndef USE_TRANSLTR}DetectLanguage(pchar(msg)){$else}''{$endif};
        ret:={$ifndef USE_TRANSLTR}TranslateText(pchar(msg),ret,pchar(ComboBoxLang.Text)){$else}
              Transltr_Translate(ret,pchar(ComboBoxLang.Text),pchar(msg)){$endif};
        memoout:=NoteMsg.Pages[NoteMsg.PageIndex].Controls[0] as TMemo;
        if memoout.SelLength>0 then
          memoout.SelText:=pchar(ret)
          else begin
            if memo.SelLength>0 then begin
              spos:=Pos(msg,memoout.Text);
              if spos>0 then begin
                memoout.SelStart:=spos-1;
                memoout.SelLength:=Length(msg);
              end else
                memoout.SelStart:=0;
              memoout.SelText:=pchar(ret);
            end else
              memoout.Text:=pchar(ret);
          end;
      except
        ret:=TranslateError;
        MemoTran.Append(ret);
      end;
    end;
  end;
end;

procedure TForm1.TranslateSetupExecute(Sender: TObject);
var
  bingdlg : TFormBingInfo;
begin
  bingdlg := TFormBingInfo.Create(self);
  try
    bingdlg.EditBingAppName.Text:=bingclient_id;
    bingdlg.EditBingAppSecret.Text:=bingclient_secret;
    if bingdlg.ShowModal = mrOK then begin
      bingclient_id:=bingdlg.EditBingAppName.Text;
      bingclient_secret:=bingdlg.EditBingAppSecret.Text;
      SetupBingApi;
    end;
  finally
    bingdlg.Free;
  end;
end;

procedure TForm1.TranslateText1Execute(Sender: TObject);
var
  ret, msg:string;
  memo:TMemo;
begin
  if ComboBoxLang.ItemIndex<>-1 then begin
    if ActiveControl is TMemo then
      memo:=TMemo(ActiveControl)
      else
        memo:=NoteMsg.Pages[NoteMsg.PageIndex].Controls[0] as TMemo;
    if memo.SelLength>0 then
      msg:=memo.SelText
      else
        msg:=memo.Text;
    if msg<>'' then begin
      try
        if ComboBoxSrcLang.ItemIndex>0 then
          ret:=ComboBoxSrcLang.Text
          else
            ret:={$ifndef USE_TRANSLTR}DetectLanguage(pchar(msg)){$else}''{$endif};
        ret:={$ifndef USE_TRANSLTR}TranslateText(pchar(msg),ret,pchar(ComboBoxLang.Text)){$else}
             Transltr_Translate(ret,pchar(ComboBoxLang.Text),pchar(msg)){$endif};
      except
        ret:=TranslateError;
      end;
      MemoTran.Append(pchar(ret));
    end;
  end;
end;

procedure TForm1.TranslateText1Update(Sender: TObject);
begin
  TAction(Sender).Enabled:=EnableTranslate;
end;

procedure TForm1.POUpdateMsg;
var
  itemp:TPoItem;
  i:integer;
  sfuzzy:string;
begin
  if lastIndex<>-1 then
    itemp:=TPoItem(ListBoxPO.Items.Objects[lastIndex])
    else
      itemp:=nil;
  i:=0;
  while i<NoteMsg.PageCount do begin
    // update last modified
    if (NoteMsg.Pages[i].Controls[0] as TMemo).Modified then begin
      if itemp<>nil then
        itemp.SetMsgstr(i,(NoteMsg.Pages[i].Controls[0] as TMemo).Text);
      modified:=True;
    end;
    (NoteMsg.Pages[i].Controls[0] as TMemo).Modified:=False;
    Inc(i);
  end;
  // fuzzy flag
  if itemp<>nil then
    if itemp.checkflag(strfuzzy)<>CheckBoxFuzzy.Checked then begin
      modified:=True;
      if not CheckBoxFuzzy.Checked then
        itemp.RemoveFlag(strfuzzy)
        else
          itemp.Addflag(strfuzzy);
    end;
  ListBoxPO.Invalidate;
end;

procedure TForm1.GotoItems(untran, up: Boolean; IsFuzzy:Boolean = False);
var
  IsNull: Boolean;
  itemp: TPoItem;
  k: integer;
  j: integer;
  i: integer;
begin
  i:=ListBoxPO.ItemIndex;
  if up then
    Dec(i)
    else
      Inc(i);
  while (i>-1) and (i<ListBoxPO.Count) do begin
    itemp:=TPoItem(ListBoxPO.Items.Objects[i]);
    if itemp<>nil then begin
      if not IsFuzzy then begin
        k:=itemp.GetMsgstrCount;
        j:=0;
        IsNull:=not untran;
        while j<k do begin
          if itemp.GetMsgstr(j)='' then begin
            IsNull:=untran;
            break;
          end;
          Inc(j);
        end;
      end else
        IsNull:=itemp.checkflag(strfuzzy);
      if IsNull then begin
        ListBoxPO.ItemIndex:=i;
        ListBoxPO.MakeCurrentVisible;
        ListBoxPO.Click;
        break;
      end;
    end;
    if not up then
      Inc(i)
      else
        Dec(i);
  end;
end;

function TForm1.EnableTranslate: Boolean;
begin
  Result:=(ActiveControl is TMemo) or (ActiveControl is TListBox);
end;

procedure TForm1.RefreshListBoxPO;
var
  stemp:string;
  i:Integer;
  sortcomm:Boolean;
begin
  sortcomm:=OptionSortComment.Checked;
  ListBoxPO.Clear;
  PoList.Clear;
  MemoId.Text:='';
  MemoMsg.Text:='';
  MemoMsg.Modified:=False;
  lastIndex:=-1;
  lastFindIndex:=Point(-1, 0);

  for i:=0 to mPo.Count-1 do begin
      stemp:=TPoItem(mPo.Items[i]).GetNameStr('msgid');
      if stemp<>'' then begin
        PoList.AddObject(stemp, TPoItem(mPo.Items[i]));
      end;
  end;
  if sortcomm then begin
    PoList.CustomSort(@CustomComment);
    end else
      PoList.Sort;
  ListBoxPO.Items.Assign(PoList);
end;

procedure TForm1.SelectAllItems(untran: Boolean);
var
  itemp: TPoItem;
  k: integer;
  j: integer;
  i: integer;
  IsFind:Boolean;
begin
  i:=0;
  while i<ListBoxPO.Count do begin
    itemp:=TPoItem(ListBoxPO.Items.Objects[i]);
    if itemp<>nil then begin
      j:=0;
      k:=itemp.GetMsgstrCount;
      IsFind:=not untran;
      while j<k do begin
        if itemp.GetMsgstr(j)='' then begin
          IsFind:=untran;
          break;
        end;
        Inc(j);
      end;
      if IsFind then
        ListBoxPO.Selected[i]:=True;
    end;
    Inc(i);
  end;
end;

procedure TForm1.SetupBingApi;
var
  i: Integer;
  lang: string;
  Langs: TStringList;
begin
  try
    Langs:=nil;
    if not DisableTranslator then begin
      (*
      if bingapiid<>'' then
        uMSTRanAPI.BingAppId:=bingapiid;
      *)
      {$ifndef USE_TRANSLTR}
      if bingclient_id<>'' then
        uMSTRanAPI.BingClientID:=bingclient_id;
      if bingclient_secret<>'' then
        uMSTRanAPI.BingClientSecret:=bingclient_secret;
      try
        Langs:=GetLanguagesForTranslate;
      except
      end;
      {$else}
      Langs:=TStringList.Create;
      try
        Transltr_GetLangs(Langs);
      except
      end;
      {$endif}
      ComboBoxLang.Items.Assign(Langs);
      ComboBoxSrcLang.Items.Assign(Langs);
      ComboBoxSrcLang.Items.Insert(0, rsAuto);
      ComboBoxSrcLang.ItemIndex:=0;
      LazGetShortLanguageID(lang);
      if ComboBoxLang.Items.Count>0 then
        for i:=0 to ComboBoxLang.Items.Count-1 do
          if ComboBoxLang.Items[i]=lang then begin
            ComboBoxLang.ItemIndex:=i;
            break;
        end;
    end else begin
      ComboBoxLang.ItemIndex:=-1;
      ComboBoxLang.Enabled:=False;
      ComboBoxSrcLang.ItemIndex:=-1;
      ComboBoxSrcLang.Enabled:=False;
    end;
  finally
    if Langs<>nil then
      Langs.Free;
  end;
end;

procedure TForm1.FileOpen1Accept(Sender: TObject);
var
  i:integer;
  stemp:string;
  sortcomm:Boolean;
begin
  if modified then
    if not QueryContinue then
      exit;
  sortcomm:=OptionSortComment.Checked;
  StatusBar1.Panels[2].Text:=ExtractFileName(FileOpen1.Dialog.FileName);
  ListBoxPO.Clear;
  PoList.Clear;
  MemoId.Text:='';
  MemoMsg.Text:='';
  MemoMsg.Modified:=False;
  modified:=False;
  lastIndex:=-1;
  lastFindIndex:=Point(-1,0);
  if Assigned(mPo) then
     FreeAndNil(mPo);
  mPo:=TPoList.Create;
  try
    mPo.Load(FileOpen1.Dialog.FileName);
    MRUManager1.Add(FileOpen1.Dialog.FileName,0);
    if mPo.Count>0 then begin
      for i:=0 to mPo.Count-1 do begin
          stemp:=TPoItem(mPo.Items[i]).GetNameStr('msgid');
          if stemp<>'' then begin
            PoList.AddObject(stemp,TPoItem(mPo.Items[i]));
          end;
      end;
      if sortcomm then begin
        PoList.CustomSort(@CustomComment);
        end else
          PoList.Sort;
      ListBoxPO.Items.Assign(PoList);
    end;
  except
    on e:Exception do ShowMessage(e.Message);
  end;
  StatusBar1.Panels[1].Text:=IntToStr(ListBoxPO.Count);
end;

procedure TForm1.FileOpen1BeforeExecute(Sender: TObject);
begin
end;

procedure TForm1.ActionList1Update(AAction: TBasicAction; var Handled: Boolean);
begin
  FileSaveAs1.Enabled:=Assigned(mPo);
end;

procedure TForm1.AddPOExecute(Sender: TObject);
var
  mPOimport:TPoList;
  ListImp : TFPDataHashTable;
  i, patched, j, added, l : integer;
  itemp,otemp:TPoItem;
  stemp,dtemp:string;
  DoOverwrite,WriteMsg,FirstMsg:Boolean;
begin
  if OpenDialogImport.Execute then begin
    FirstMsg:=True;
    ListImp:=TFPDataHashTable.Create;
    try
      Cursor:=crHourGlass;
      // make table
      if ListBoxPO.Count>0 then
      for i:=0 to ListBoxPO.Count-1 do begin
        itemp:=TPoItem(ListBoxPO.Items.Objects[i]);
        if itemp<>nil then begin
          stemp:=itemp.GetNameStr('msgid');
          if ListImp.Find(stemp)=nil then
            ListImp.Add(stemp,Pointer(itemp));
        end;
      end;
      // read po file
      mPOimport:=TPoList.Create;
      try
        try
          mPOimport.Load(OpenDialogImport.FileName);
          MRUManager1.Add(OpenDialogImport.FileName,0);
        except
          on e:exception do
          begin
            mPOimport.Clear;
            ShowMessage(e.Message);
          end;
        end;
        // add po item
        patched:=0;
        added:=0;
        FirstMsg:=True;
        DoOverwrite:=False;
        if mPOimport.Count>0 then
          for i:=0 to mPOimport.Count-1 do begin
            itemp:=TPoItem(mPOimport.Items[i]);
            if itemp<>nil then begin
              stemp:=itemp.GetNameStr('msgid');
              if stemp<>'' then begin
                otemp:=TPoItem(ListImp.Items[stemp]);
                if otemp<>nil then begin
                  // patch
                  l:=otemp.GetMsgstrCount;
                  if l=itemp.GetMsgstrCount then begin
                    j:=0;
                    while j<l do begin
                      dtemp:=itemp.GetMsgstr(j);
                      WriteMsg:=dtemp<>'';
                      if WriteMsg then begin
                        if FirstMsg then begin
                          FirstMsg:=False;
                          DoOverwrite:=QueryDialog;
                        end;
                        WriteMsg:=DoOverwrite;
                      end;
                      if WriteMsg then begin
                        otemp.SetMsgstr(j,dtemp);
                        Inc(patched);
                      end;
                      Inc(j);
                    end;
                  end else begin
                    // have more msgstr, add
                    if itemp.Count>0 then begin
                      otemp.Clear;
                      for j:=0 to itemp.Count-1 do begin
                        dtemp:=itemp.StrItem[j];
                        otemp.Add(dtemp);
                      end;
                      Inc(added);
                    end;
                  end;
                end else begin
                  // added new item
                  if itemp.Count>0 then begin
                    otemp:=mPo.AddItem;
                    for j:=0 to itemp.Count-1 do begin
                      dtemp:=itemp.StrItem[j];
                      otemp.Add(dtemp);
                    end;
                    Inc(added);
                  end;
                end;

              end;
            end;
          end;
      finally
        mPOimport.Free;
      end;
      // refresh listbox
      if added<>0 then begin
        RefreshListBoxPO;
      end;
    finally
      ListImp.Free;
      Cursor:=crDefault;
    end;
    ListBoxPO.Invalidate;
    if not modified then
      modified:=(patched<>0) or (added<>0);
    StatusBar1.Panels[1].Text:=IntToStr(ListBoxPO.Count);
    ShowMessage(Format(rsDPatchedDAdd, [patched, added]));
  end;
end;

procedure TForm1.ButtonclrClick(Sender: TObject);
begin
  MemoTran.Clear;
end;

procedure TForm1.EditCopy1Execute(Sender: TObject);
begin
  if ActiveControl is TMemo then
    TMemo(ActiveControl).CopyToClipboard;
end;

procedure TForm1.EditCut1Execute(Sender: TObject);
begin
  if ActiveControl is TMemo then
    TMemo(ActiveControl).CutToClipboard;
end;

procedure TForm1.EditDelete1Execute(Sender: TObject);
begin
  if ActiveControl is TMemo then
    if not (ActiveControl as TMemo).ReadOnly then
      (ActiveControl as TMemo).ClearSelection;
end;

procedure TForm1.EditDownExecute(Sender: TObject);
begin
  if ListBoxPO.ItemIndex<ListBoxPO.Count-1 then
    begin
      ListBoxPO.ItemIndex:=ListBoxPO.ItemIndex+1;
      ListBoxPO.Click;
    end;
end;

procedure TForm1.EditExportSelExecute(Sender: TObject);
var
  i,j: Integer;
  newPo : TPoList;
  itemp,etemp:TPoItem;
begin
  if Assigned(mPo) then begin
    //SaveDialogExport.FileName:=ExtractFileName(FileSaveAs1.Dialog.FileName);
    if SaveDialogExport.Execute then
      if ListBoxPO.Count>0 then begin
        newPo:=TPoList.Create;
        try
          with newPo.AddItem do begin
            Add('msgid ""');
            Add('msgstr ""');
            Add('"Export Selections from : '+ExtractFileName(FileOpen1.Dialog.FileName)+'"');
          end;

          for i:=0 to ListBoxPO.Count-1 do begin
            itemp:=TPoItem(ListBoxPO.Items.Objects[i]);
            if itemp<>nil then
              if ListBoxPO.Selected[i] then begin
                etemp:=newPo.AddItem;
                //try
                  if itemp.Count>0 then
                    for j:=0 to itemp.Count-1 do begin
                      etemp.Add(itemp.StrItem[j]);
                    end;
                (*
                except
                  newPo.Delete(newPo.IndexOf(etemp));
                end;
                *)
              end;
          end;
          try
            newPo.Save(SaveDialogExport.FileName);
            MRUManager1.Add(SaveDialogExport.FileName,0);
          except
            on e:exception do ShowMessage(e.Message);
          end;
        finally
          newPo.Free;
        end;
      end;
  end;
end;

procedure TForm1.EditGotoNextFuzzyExecute(Sender: TObject);
begin
  GotoItems(False,False,True);
end;

procedure TForm1.EditGotoNextTranExecute(Sender: TObject);
begin
  GotoItems(False,False);
end;

procedure TForm1.EditGotoNextUnTranExecute(Sender: TObject);
begin
  GotoItems(True,False);
end;

procedure TForm1.EditGotoPrevFuzzyExecute(Sender: TObject);
begin
  GotoItems(False,True,True);
end;

procedure TForm1.EditGotoPrevTranExecute(Sender: TObject);
begin
  GotoItems(False,True);
end;

procedure TForm1.EditGotoPrevUntranExecute(Sender: TObject);
begin
  GotoItems(True,True);
end;

procedure TForm1.EditMemoLeftExecute(Sender: TObject);
var
  i:integer;
begin
  i:=NoteMsg.PageIndex-1;
  if i<0 then
    i:=NoteMsg.PageCount-1;
  NoteMsg.PageIndex:=i;
end;

procedure TForm1.EditMemoRightExecute(Sender: TObject);
var
  i:integer;
begin
  i:=NoteMsg.PageIndex+1;
  if i>=NoteMsg.PageCount then
    i:=0;
  NoteMsg.PageIndex:=i;
end;

procedure TForm1.EditPaste1Execute(Sender: TObject);
begin
  if ActiveControl is TMemo then
    TMemo(ActiveControl).PasteFromClipboard;
end;

procedure TForm1.EditPOFilePropExecute(Sender: TObject);
var
  propform:TFormProp;
  i:integer;
  itemp:TPoItem;
  stemp:string;
  hasprop:boolean;
begin
  if Assigned(mPo) then begin
    propform:=TFormProp.Create(self);
    try
      hasprop:=False;
      if mPo.Count>0 then
        for i:=0 to mPo.Count-1 do begin
          itemp:=TPoItem(mPo[i]);
          if itemp<>nil then begin
            stemp:=itemp.GetNameStr('msgid');
            if stemp='' then begin
              propform.Memo1.Text:=itemp.GetNameStr('msgstr');
              hasprop:=True;
              break;
            end;
          end;
        end;
      if propform.ShowModal=mrOK then
        if hasprop then begin
          itemp.SetNameStr('msgstr',propform.Memo1.Text);
          modified:=True;
        end;
    finally
      propform.Free;
    end;
  end;
end;

procedure TForm1.EditSelAllTranExecute(Sender: TObject);
begin
  SelectAllItems(False);
end;

procedure TForm1.EditSelAllUntranExecute(Sender: TObject);
begin
  SelectAllItems(True);
end;

procedure TForm1.EditSelectAll1Execute(Sender: TObject);
begin
  if ActiveControl is TMemo then
    TMemo(ActiveControl).SelectAll;
end;

procedure TForm1.EditShowRawItemExecute(Sender: TObject);
var
  itemp:TPoItem;
  RawDlg:TFormShowRaw;
  i:integer;
begin
  if ListBoxPO.ItemIndex<>-1 then begin
    itemp:=TPoItem(ListBoxPO.Items.Objects[ListBoxPO.ItemIndex]);
    if itemp<>nil then begin
      RawDlg:=TFormShowRaw.Create(Self);
      try
        if itemp.Count>0 then
          for i:=0 to itemp.Count-1 do
            RawDlg.Memo1.Append(pchar(itemp.StrItem[i]));
        RawDlg.ShowModal;
      finally
        RawDlg.Free;
      end;
    end;
  end;
end;

procedure TForm1.EditStripUntranExecute(Sender: TObject);
var
  i,j,k,l:Integer;
  itemp:TPoItem;
  stemp,stemp1:string;
  IsUntran,sortcomm:Boolean;
begin
  if Assigned(mPo) then
    if mPo.Count>0 then
      if QueryWork then begin
        sortcomm:=OptionSortComment.Checked;
        ListBoxPO.Clear;
        PoList.Clear;
        i:=0;
        while i<mPo.Count do begin
          itemp:=TPoItem(mPo[i]);
          if itemp<>nil then begin
            stemp1:=itemp.GetNameStr('msgid');
            if stemp1<>'' then begin
              IsUntran:=True;
              k:=0;
              l:=itemp.GetMsgstrCount;
              while k<l do begin
                stemp:=itemp.GetMsgstr(k);
                if stemp<>'' then begin
                  IsUntran:=False;
                  break;
                end;
                Inc(k);
              end;
              if IsUntran then begin
                j:=mPo.IndexOf(Pointer(itemp));
                if j<>-1 then begin
                  mPo.Delete(j);
                  Continue;
                end;
              end else begin
                PoList.AddObject(stemp1,itemp);
              end;
            end;
          end;
          Inc(i);
        end;
        if sortcomm then begin
          PoList.CustomSort(@CustomComment);
          end else
            PoList.Sort;
        ListBoxPO.Items.Assign(PoList);
      end;
  StatusBar1.Panels[1].Text:=IntToStr(ListBoxPO.Count);
end;

procedure TForm1.EditUndo1Execute(Sender: TObject);
begin
  if ActiveControl is TMemo then
    TMemo(ActiveControl).Undo;
end;

procedure TForm1.EditUpExecute(Sender: TObject);
begin
  if ListBoxPO.ItemIndex>0 then
    begin
      ListBoxPO.ItemIndex:=ListBoxPO.ItemIndex-1;
      ListBoxPO.Click;
    end;
end;

procedure TForm1.ExportPOExecute(Sender: TObject);
var
  i,j,l: Integer;
  newPo : TPoList;
  itemp,etemp:TPoItem;
  IsUntran:Boolean;
begin
  if Assigned(mPo) then begin
    SaveDialogExport.FileName:=ExtractFileName(FileSaveAs1.Dialog.FileName);
    if SaveDialogExport.Execute then
      if ListBoxPO.Count>0 then begin
        newPo:=TPoList.Create;
        try
          with newPo.AddItem do begin
            Add('msgid ""');
            Add('msgstr ""');
            Add('"Export from : '+ExtractFileName(FileOpen1.Dialog.FileName)+'"');
          end;

          for i:=0 to ListBoxPO.Count-1 do begin
            itemp:=TPoItem(ListBoxPO.Items.Objects[i]);
            if itemp<>nil then begin
              l:=itemp.GetMsgstrCount;
              IsUntran:=True;
              j:=0;
              while j<l do begin
                if itemp.GetMsgstr(j)<>'' then begin
                  IsUntran:=False;
                  break;
                end;
                Inc(j);
              end;
              if not IsUntran then begin
                etemp:=newPo.AddItem;
                if itemp.Count>0 then
                  for j:=0 to itemp.Count-1 do begin
                    etemp.Add(itemp.StrItem[j]);
                  end;
              end;
            end;
          end;
          try
            newPo.Save(SaveDialogExport.FileName);
            MRUManager1.Add(SaveDialogExport.FileName,0);
          except
            on e:exception do ShowMessage(e.Message);
          end;
        finally
          newPo.Free;
        end;
      end;
  end;
end;

procedure TForm1.FileSaveAs1Accept(Sender: TObject);
begin
  if Assigned(mPo) then begin
    try
      mPo.Save(FileSaveAs1.Dialog.FileName);
      MRUManager1.Add(FileSaveAs1.Dialog.FileName,0);
      modified:=False;
      FileOpen1.Dialog.FileName:=FileSaveAs1.Dialog.FileName;
      StatusBar1.Panels[2].Text:=ExtractFileName(FileSaveAs1.Dialog.FileName);
    except
      on e:exception do ShowMessage(e.Message);
    end;
  end;
end;

procedure TForm1.FileSaveAs1BeforeExecute(Sender: TObject);
begin
  POUpdateMsg;
  FileSaveAs1.Dialog.FileName:=ExtractFileName(FileOpen1.Dialog.FileName);
end;


function ConvertHexCode(const str:string):string;
var
  i,l:Integer;
  ch:char;
begin
  Result:='';
  i:=1;
  l:=Length(str);
  while i<=l do begin
      ch:=str[i];
      if ch>#127 then
        Result:=Result+'\x{'+IntToHex(Ord(ch),2)+'}'
        else
          Result:=Result+ch;
      Inc(i);
  end;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  POUpdateMsg;
  CanClose:=True;
  if modified then
    CanClose:=QueryContinue;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  lng,lngf:string;
begin
  mIsFind:=0;
  PoList:=TStringList.Create;
  // translate LCL resource strings
  GetLanguageIDs(lng,lngf);
  Translations.TranslateUnitResourceStrings('LCLStrConsts', 'lclstrconsts.%s.po', lng, lngf);
  CheckConfigFile;
end;


procedure TForm1.FormDestroy(Sender: TObject);
begin
  ListBoxPO.Clear;
  PoList.Free;
  FreeAndNil(mPo);
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  SetupBingApi;
  if Paramcount>0 then begin
    FileOpen1.Dialog.FileName:=ParamStr(1);
    FileOpen1Accept(nil);
  end;
end;

procedure TForm1.ImportPOExecute(Sender: TObject);
var
  mPOimport:TPoList;
  ListImp : TFPDataHashTable;
  i, patched, j,l : integer;
  itemp,otemp:TPoItem;
  stemp,dtemp:string;
  DoOverwrite,WriteMsg,FirstMsg:Boolean;
begin
  if ListBoxPO.Count>0 then
  if OpenDialogImport.Execute then begin
    FirstMsg:=True;
    ListImp:=TFPDataHashTable.Create;
    try
      Cursor:=crHourGlass;
      mPOimport:=TPoList.Create;
      try
        try
          mPOimport.Load(OpenDialogImport.FileName);
          MRUManager1.Add(OpenDialogImport.FileName,0);
        except
          on e:exception do
          begin
            mPOimport.Clear;
            ShowMessage(e.Message);
          end;
        end;
        // make table
        if mPOimport.Count>0 then
          for i:=0 to mPOimport.Count-1 do begin
            itemp:=TPoItem(mPOimport.Items[i]);
            if itemp<>nil then
              stemp:=itemp.GetNameStr('msgid')
              else
                stemp:='';
            if stemp<>'' then
              if ListImp.Find(stemp)=nil then
                ListImp.Add(stemp,mPOimport.Items[i]);
          end;
        // patch strings
        patched:=0;
        DoOverwrite:=False;
        if ListBoxPO.Count>0 then
          for i:=0 to ListBoxPO.Count-1 do begin
            itemp:=TPoItem(ListBoxPO.Items.Objects[i]);
            if itemp<>nil then begin
              stemp:=itemp.GetNameStr('msgid');
              l:=itemp.GetMsgstrCount;
              end else begin
                stemp:='';
                l:=0;
              end;
            if stemp<>'' then begin
              otemp:=TPoItem(ListImp.Items[stemp]);
              j:=0;
              while j<l do begin
                if otemp<>nil then
                  dtemp:=otemp.GetMsgstr(j)
                  else
                    dtemp:='';
                if dtemp<>'' then begin
                  stemp:=itemp.GetMsgstr(j);
                  WriteMsg:=stemp='';
                  if not WriteMsg then begin
                    if FirstMsg then begin
                      FirstMsg:=False;
                      DoOverwrite:=QueryDialog;
                    end;
                    WriteMsg:=DoOverwrite;
                  end;
                  if WriteMsg then begin
                    itemp.SetMsgstr(j,dtemp);
                    Inc(patched);
                  end;
                end;
                Inc(j);
              end;
            end;
          end;
      finally
        mPOimport.Free;
      end;
    finally
      ListImp.Free;
      Cursor:=crDefault;
    end;
    ListBoxPO.Invalidate;
    if not modified then
      modified:=patched<>0;
    ShowMessage(Format(rsDMessagesImp, [patched]));
  end;
end;

procedure TForm1.ListBoxPOClick(Sender: TObject);
var
  itemp:TPoItem;
  stemp:string;
  i,j:integer;
  sht:TTabSheet;
begin
  POUpdateMsg;
  // get new item
  if ListBoxPO.ItemIndex<>-1 then begin
    while NoteMsg.PageCount>1 do
      NoteMsg.Pages[1].Free;
    itemp:=TPoItem(ListBoxPO.Items.Objects[ListBoxPO.ItemIndex]);
    if itemp<>nil then begin
      MemoId.Text:=itemp.GetNameStr('msgid');

      i:=itemp.GetMsgstrCount;
      j:=0;
      repeat
        stemp:=itemp.GetMsgstr(j);
        if stemp='' then
           stemp:=itemp.GetNameStr('msgid');
        (NoteMsg.Pages[j].Controls[0] as TMemo).Text:=stemp;
        (NoteMsg.Pages[j].Controls[0] as TMemo).Modified:=False;
        Inc(j);
        if j<i then begin
          sht:=NoteMsg.AddTabSheet;
          sht.Name:='MemoSheet'+IntToStr(j);
          sht.Caption:=IntToStr(j);
          with TMemo.Create(sht) do begin
            Name:='MemoMsg'+IntToStr(j);
            Align:=alClient;
            Parent:=sht;
            WordWrap:=False;
            ScrollBars:=ssAutoBoth;
            OnExit:=@MemoMsgExit;
          end;
        end;
      until j>=i;
      CheckBoxFuzzy.Checked:=itemp.checkflag(strfuzzy);
    end;
  end;
  lastIndex:=ListBoxPO.ItemIndex;
end;

procedure TForm1.ListBoxPODblClick(Sender: TObject);
begin
  (NoteMsg.Pages[NoteMsg.PageIndex].Controls[0] as TMemo).SetFocus;
end;

procedure TForm1.ListBoxPODrawItem(Control: TWinControl; Index: Integer;
  ARect: TRect; State: TOwnerDrawState);
var
  itemp:TPoItem;
  scmt, sid, smsg, sdisp : string;
  nHeight,iHeight,i,j:Integer;
  iCanvas:TCanvas;
  HasValue:Boolean;
const
  NextLine = #$E2#$86#$98;
begin
  itemp := TPoItem(TListBox(Control).Items.Objects[Index]);
  // disp text
  if itemp<>nil then begin
    sdisp:=itemp.GetNameStr('msgctxt');
    if sdisp<>'' then
      scmt:='msgctxt '+sdisp
      else begin
        sdisp:=itemp.GetNameStr('#.');
        if sdisp<>'' then
          scmt:='#. '+sdisp
          else begin
            sdisp:=itemp.GetNameStr('#:');
            if sdisp<>'' then
              scmt:='#: '+sdisp
              else
                scmt:=itemp.StrItem[0];
          end;
      end;
    sid:=itemp.GetNameStr('msgid');
    sid:=StringReplace(sid,sLineBreak,NextLine,[]);
    i:=itemp.GetMsgstrCount;
  end else begin
    scmt:='#:';
    sid:='id';
    smsg:='msg';
    i:=1;
  end;

  iCanvas:=TListBox(Control).Canvas;

  nHeight:=iCanvas.TextHeight('Qj');
  if (Index and 1)=0 then
    iCanvas.Brush.Color:=$00EEEEEE
    else
      iCanvas.Brush.Color:=$00DDDDDD;
  if odSelected in State then
    if (Index and 1)=0 then
     iCanvas.Brush.Color:=$00CC8888
     else
       iCanvas.Brush.Color:=$00BBAA88;
  iCanvas.FillRect(ARect);

  j:=0;
  iHeight:=ARect.Top+7+(nHeight+2)*2;
  HasValue:=False;
  while j<i do begin
    if itemp<>nil then begin
      smsg:=itemp.GetMsgstr(j);
      smsg:=StringReplace(smsg,sLineBreak,NextLine,[]);
      end else
        smsg:='';
    if not HasValue then begin
      HasValue:=smsg<>'';
      if not HasValue then
        iCanvas.Font.Color:=clRed
        else
          iCanvas.Font.Color:=clBlack;
    end;
    iCanvas.TextRect(ARect,ARect.Left+10,iHeight-1,smsg);
    Inc(j);
    Inc(iHeight,nHeight+2)
  end;
  iCanvas.TextRect(ARect,ARect.Left+10,ARect.Top+7+(nHeight+2),sid);
  iCanvas.Font.Color:=clGreen;
  iCanvas.TextRect(ARect,ARect.Left+3,ARect.Top+7,scmt);
end;


procedure TForm1.ListBoxPOKeyPress(Sender: TObject; var Key: char);
begin
  if Key=#13 then
    begin
      Key:=#0;
      (NoteMsg.Pages[NoteMsg.PageIndex].Controls[0] as TMemo).SetFocus;
    end;
end;

procedure TForm1.ListBoxPOMeasureItem(Control: TWinControl; Index: Integer;
  var AHeight: Integer);
var
  itemp:TPoItem;
  i:integer;
begin
  if Index<PoList.Count then
    itemp:=TPoItem(PoList.Objects[Index])
    //itemp:=TPoItem(ListBoxPO.Items.Objects[Index])
    else
      itemp:=nil;
  if itemp<>nil then
    i:=itemp.GetMsgstrCount+2
  else
    i:=3;
  AHeight:=TListBox(Control).Canvas.TextHeight('Qj')*i+16;
end;

procedure TForm1.MemoMsgExit(Sender: TObject);
begin
  POUpdateMsg;
end;

procedure TForm1.MRUManager1Click(Sender: TObject; const RecentName,
  ACaption: string; UserData: PtrInt);
begin
  FileOpen1.Dialog.FileName:=RecentName;
  FileOpen1Accept(nil);
end;

procedure TForm1.NoteMsgChange(Sender: TObject);
begin
  //lastFindIndex.y:=NoteMsg.PageIndex;
end;

procedure TForm1.OptionSortCommentExecute(Sender: TObject);
begin
  TAction(Sender).Checked:=not TAction(Sender).Checked;
  RefreshListBoxPO;
end;

procedure TForm1.ReplaceDialog1Close(Sender: TObject);
begin
  //lastFindIndex:=-1;
  OldFindStr:=ReplaceDialog1.FindText;
  if (frReplace in ReplaceDialog1.Options) or
     (frReplaceAll in ReplaceDialog1.Options) then
  OldReplaceStr:=ReplaceDialog1.ReplaceText;
end;

procedure TForm1.ReplaceDialog1Find(Sender: TObject);
var
  i,j,k,l:Integer;
  itemp:TPoItem;
  stemp:string;
  sFound,sUp:Boolean;
  pcre:TBRRERegExp;
  flag:longint;
begin
  mIsFind:=0;
  if Sender<>nil then begin
    lastFindIndex:=Point(-1,0);
    FindCase:=frMatchCase in ReplaceDialog1.Options;
  end;
  sFound:=False;
  stemp:=ReplaceDialog1.FindText;
  if Length(stemp)=0 then begin
    ReplaceDialog1.CloseDialog;
    exit;
  end;
  if ListBoxPO.Count>0 then begin
    flag:=brrefUTF8 or brrefSINGLELINE;
    if not FindCase then
      flag:=flag or brrefIGNORECASE;
    pcre:=TBRRERegExp.Create(stemp,flag);
    try
      i:=ListBoxPO.ItemIndex;
      k:=NoteMsg.PageIndex+1;
      if (k>=NoteMsg.PageCount) or (NoteMsg.PageCount=1) then
        Inc(i);
      if i<0 then
        i:=0;
      if i>=ListBoxPO.Count then
        i:=0;
      j:=i;
      sUp:=False;
      while i<ListBoxPO.Count do begin
        itemp:=TPoItem(ListBoxPO.Items.Objects[i]);
        if itemp<>nil then begin
          stemp:=itemp.GetNameStr('msgid');
          if Length(stemp)>0 then
            if pcre.Find(pchar(stemp),brresuPOSSIBLEUTF8)<>-1 then begin
              sFound:=True;
              break;
            end;
          l:=itemp.GetMsgstrCount;
          while k<l do begin
            stemp:=itemp.GetMsgstr(k);
            if Length(stemp)>0 then
              if pcre.Find(pchar(stemp),brresuPOSSIBLEUTF8)<>-1 then begin
                sFound:=True;
                break;
              end;
            Inc(k);
          end;
          if sFound then
            break;
          k:=0;
        end;
        Inc(i);
        if sUp and (i>j) then
          break;
        if i>=ListBoxPO.Count then begin
          if j=0 then
            break
            else begin
              i:=0;
              sUp:=True;
            end;
        end;
      end;
    finally
      pcre.Free;
    end;
    ReplaceDialog1.CloseDialog;
    if sFound then begin
      lastFindIndex:=Point(i,k);
      ListBoxPO.ItemIndex:=i;
      ListBoxPO.MakeCurrentVisible;
      ListBoxPO.Click;
      NoteMsg.PageIndex:=k;
    end else begin
      lastFindIndex:=Point(-1,0);
      ShowMessage(rsNoMatchesFound);
    end;
  end;
  ReplaceDialog1.CloseDialog;
  OldFindStr:=ReplaceDialog1.FindText;
end;

procedure TForm1.ReplaceDialog1Replace(Sender: TObject);
var
  i,j,r,k,l:Integer;
  itemp:TPoItem;
  stemp:string;
  sFound,sUp,DoReplace:Boolean;
  pcre:TBRRERegExp;
  flag:longint;
begin
  mIsFind:=1;
  if frReplaceAll in ReplaceDialog1.Options then
    Inc(mIsFind);
  if Sender<>nil then begin
    lastFindIndex:=Point(-1,0);
    FindCase:=frMatchCase in ReplaceDialog1.Options;
  end;
  sFound:=False;
  stemp:=ReplaceDialog1.FindText;
  ReplaceDialog1.CloseDialog;
  if Length(stemp)=0 then
    exit;
  if ListBoxPO.Count>0 then begin
    flag:=brrefUTF8 or brrefSINGLELINE;
    if not FindCase then
      flag:=flag or brrefIGNORECASE;
    pcre:=TBRRERegExp.Create(stemp,flag);
    try
      i:=ListBoxPO.ItemIndex;
      k:=NoteMsg.PageIndex+1;
      if (k>=NoteMsg.PageCount) or (NoteMsg.PageCount=1) then
        Inc(i);
      if i<0 then
        i:=0;
      if i>=ListBoxPO.Count then
        i:=0;
      j:=i;
      sUp:=False;
      while i<ListBoxPO.Count do begin
        itemp:=TPoItem(ListBoxPO.Items.Objects[i]);
        if itemp<>nil then begin
          l:=itemp.GetMsgstrCount;
          while k<l do begin
            stemp:=itemp.GetMsgstr(k);
            if Length(stemp)=0 then
              stemp:=itemp.GetNameStr('msgid');
            if Length(stemp)>0 then begin
              if pcre.Find(pchar(stemp),brresuPOSSIBLEUTF8)<>-1 then begin
                lastFindIndex:=Point(i,k);
                ListBoxPO.ItemIndex:=i;
                ListBoxPO.MakeCurrentVisible;
                ListBoxPO.Click;
                NoteMsg.PageIndex:=k;
                sFound:=True;
                if frPromptOnReplace in ReplaceDialog1.Options then begin
                  r:=QueryReplace;
                  DoReplace:=r=mrYes;
                  if r=mrCancel then
                    break;
                end else
                  DoReplace:=True;
                if DoReplace then begin
                  stemp:=pcre.Replace(pchar(stemp),pchar(ReplaceDialog1.ReplaceText),brresuPOSSIBLEUTF8);
                  itemp.SetMsgstr(k,stemp);
                  modified:=True;
                end;
                if not (frReplaceAll in ReplaceDialog1.Options) then
                  break;
              end;
            end;
            Inc(k);
          end;
          if sFound then
            break;
          k:=0;
        end;
        Inc(i);
        if sUp and (i>j) then
          break;
        if i>=ListBoxPO.Count then begin
          if j=0 then
            break
            else begin
              i:=0;
              sUp:=True;
            end;
        end;
      end;
    finally
      pcre.Free;
    end;
    if not sFound then begin
      lastFindIndex:=Point(-1,0);
      ShowMessage(rsNoMatchesFound);
    end;
  end;
  ReplaceDialog1.CloseDialog;
  OldFindStr:=ReplaceDialog1.FindText;
  OldReplaceStr:=ReplaceDialog1.ReplaceText;
end;

procedure TForm1.ReplaceDialog1Show(Sender: TObject);
var
  i, bidx:Integer;
  aForm : TForm;
  aBtn : TButton;
begin
  bidx:=0;
  aForm:=ReplaceDialog1.Components[0] as TForm;
  for i:=0 to aForm.ComponentCount-1 do begin
    if aForm.Components[i] is TButton then begin
      aBtn:=aForm.Components[i] as TButton;
      if aBtn.Visible then
        aBtn.Default:=True;
      if mIsFind = bidx then
        break;
      Inc(bidx);
    end;
  end;
end;


end.

