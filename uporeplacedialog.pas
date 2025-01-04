unit upoReplaceDialog;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Dialogs;

type
  TReplaceDialog = class(Dialogs.TReplaceDialog)
    property
      FindForm: TForm read FFindForm;
  end;

implementation

end.

