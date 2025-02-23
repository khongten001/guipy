{
  ESS-Model
  Copyright (C) 2002  Eldean AB, Peter S�derman, Ville Krumlinde

  This program is free software; you can redistribute it and/or
  modify it under the terms of the GNU General Public License
  as published by the Free Software Foundation; either version 2
  of the License, or (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
}

unit UUMLForm;

// UMLForm -> MainModul -> Diagram -> RTFDiagram -> TessConnectPanel
//        |-> Model
// contextmenus in UDiagramFrame

interface

uses
  Windows, Messages, ToolWin, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, Vcl.Menus, SpTBXDkPanels, SpTBXSkins,
  UUMLModule, frmFile, SynEdit, System.ImageList, Vcl.ImgList, TB2Item,
  SpTBXItem;

type

  TFUMLForm = class(TFileForm)
    PDiagramPanel: TPanel;
    PDiagram: TPanel;
    PUMLPanel: TPanel;
    TBUMLToolbar: TToolBar;
    TBClose: TToolButton;
    TBShowConnections: TToolButton;
    TBNewLayout: TToolButton;
    TBClassDefinition: TToolButton;
    TBObjectDiagram: TToolButton;
    TBComment: TToolButton;
    TBZoomOut: TToolButton;
    TBZoomIn: TToolButton;
    TBView: TToolButton;
    TBClassOpen: TToolButton;
    TBRefresh: TToolButton;
    PInteractive: TPanel;
    TBInteractiveToolbar: TToolBar;
    TBExecute: TToolButton;
    TBDelete: TToolButton;
    SynEdit: TSynEdit;
    TBSynEditZoomMinus: TToolButton;
    TBSynEditZoomPlus: TToolButton;
    TBInteractive: TToolButton;
    TBInteractiveClose: TToolButton;
    TBReInitialize: TToolButton;
    TVFileStructure: TTreeView;
    PMInteractive: TSpTBXPopupMenu;
    MIFont: TSpTBXItem;
    SpTBXSeparatorItem1: TSpTBXSeparatorItem;
    MIDeleteAll: TSpTBXItem;
    MICopyAll: TSpTBXItem;
    SpTBXSeparatorItem2: TSpTBXSeparatorItem;
    MIDelete: TSpTBXItem;
    MICopy: TSpTBXItem;
    MIPaste: TSpTBXItem;
    SpTBXSeparatorItem3: TSpTBXSeparatorItem;
    MIClose: TSpTBXItem;
    EmptyPopupMenu: TPopupMenu;
    SpTBXSplitter1: TSpTBXSplitter;
    procedure FormCreate(Sender: TObject); override;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var aAction: TCloseAction); override;
    procedure FormDestroy(Sender: TObject); override;
    procedure SBCloseClick(Sender: TObject);
    procedure TBShowConnectionsClick(Sender: TObject);
    procedure TBNewLayoutClick(Sender: TObject);
    procedure TBDiagramFromOpenWindowsClick(Sender: TObject);
    procedure TBClassDefinitionClick(Sender: TObject);
    procedure TBRefreshClick(Sender: TObject);
    procedure PDiagramPanelResize(Sender: TObject);
    procedure TBObjectDiagramClick(Sender: TObject);
    procedure TBCommentClick(Sender: TObject);
    procedure TBZoomOutClick(Sender: TObject);
    procedure TBZoomInClick(Sender: TObject);
    procedure TBViewClick(Sender: TObject);
    procedure TBExecuteClick(Sender: TObject);
    procedure TBDeleteClick(Sender: TObject);
    procedure MIPasteClick(Sender: TObject);
    procedure MICopyClick(Sender: TObject);
    procedure MIDeleteClick(Sender: TObject);
    procedure MICopyAllClick(Sender: TObject);
    procedure MIDeleteAllClick(Sender: TObject);
    procedure MIFontClick(Sender: TObject);
    procedure TBSynEditZoomMinusClick(Sender: TObject);
    procedure TBSynEditZoomPlusClick(Sender: TObject);
    procedure MICloseClick(Sender: TObject);
    procedure TBInteractiveClick(Sender: TObject);
    procedure TBClassOpenClick(Sender: TObject);
    procedure SynEditChange(Sender: TObject);
    //procedure PDiagramPanelEnter(Sender: TObject);
    procedure TBReInitializeClick(Sender: TObject);
  private
    LockEnter: boolean;
    LockRefresh: boolean;
    LockCreateTV: boolean;
    AlreadySavedAs: boolean;
    procedure ChangeStyle;
  protected
    procedure Retranslate; override;
    function LoadFromFile(const FileName: string): boolean; override;
    //function OpenFile(const aFilename: String): boolean; virtual;
    // procedure DoActivateFile(Primary: boolean = True); override;
    function CanCopy: boolean; override;
    procedure CopyToClipboard; override;
    procedure SetFont(aFont: TFont); override;
    procedure SetFontSize(Delta: integer); override;
    procedure WMSpSkinChange(var Message: TMessage); message WM_SPSKINCHANGE;
    // IJvAppStorageHandler implementation
  public
    RememberedHeight: integer;
    MainModul: TDMUMLModule;
    procedure Open(const Filename: string; State: string);
    procedure ConfigureWindow(Sender: TObject);
    procedure Save(MitBackup: boolean);
    procedure Print; override;
    function  GetFont: TFont;
    procedure SetOptions;
    procedure Enter(Sender: TObject); override;
    procedure SetOnlyModified(aModified: boolean);
    procedure CollectClasses(SL: TStringList); override;
    procedure Refresh;
    procedure OnPanelModified(aValue: Boolean);
    procedure OnInteractiveModified(Sender: TObject);
    procedure AddToProject(const Filename: string);
    procedure CreateTVFileStructure;
    function getAsStringList: TStringList; override;
    procedure ExecCommand(cmd: integer); override;
    procedure ShowAll;
    procedure ClassEdit;
    procedure OnFormMouseDown(Sender: TObject);
  end;

implementation

uses SysUtils, Types, IniFiles, Math, Clipbrd, SynEditKeyCmds,
     frmPyIDEMain, dmCommands, uEditAppIntfs, uCommonFunctions,
     JvGnugettext, StringResources, cPyScripterSettings, UFileStructure,
     UConfiguration, UUtils, UModelEntity, UModel, URtfdDiagram, UViewIntegrator,
     UImages, frmPythonII, cPyControl, cFileTemplates, cParameters, frmEditor;

{$R *.DFM}

procedure TFUMLForm.FormCreate(Sender: TObject);
begin
  inherited;
  MainModul:= TDMUMLModule.Create(Self, PDiagramPanel);
  SetFont(GuiPyOptions.UMLFont);
  DefaultExtension:= 'uml';
  Modified:= false;
  // to avoid popup of PopupMenuWindow on Classes
  PDiagramPanel.PopupMenu:= EmptyPopupMenu;
  SynEdit.PopupMenu:= PMInteractive;
  SynEdit.Font.Assign(EditorOptions.Font);
  ChangeStyle;
  //TBInteractiveClick(Self);
end;

procedure TFUMLForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if Modified and not AlreadySavedAs then begin
    DoSaveFile;
    AlreadySavedAs:= true;
  end;
  FFileStructure.Clear;
  CanClose:= true;
end;

procedure TFUMLForm.FormClose(Sender: TObject; var aAction: TCloseAction);
begin
  inherited;
  LockEnter:= true;
  LockRefresh:= true;
  LockCreateTV:= true;
  aAction:= caFree;
  FFileStructure.Clear;
  for var i:= TVFileStructure.Items.Count - 1 downto 0 do
    FreeAndNil(TVFileStructure.Items[i].Data);
end;

procedure TFUMLForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(MainModul);
  inherited;
end;

procedure TFUMLForm.OnFormMouseDown(Sender: TObject);
begin
  PyIDEMainForm.ActiveTabControl := ParentTabControl;
  CreateTVFileStructure;
end;

procedure TFUMLForm.Open(const Filename: string; State: string);
begin
  MainModul.LoadUML(Filename);
  MainModul.Diagram.SetInteractive(OnInteractiveModified);
  MainModul.Diagram.SetFormMouseDown(OnFormMouseDown);
  Pathname:= Filename;
  Caption:= Filename;
  SetState(State);
  MainModul.Diagram.SetOnModified(OnPanelModified);
  DoActivate;
  LockEnter:= false;
  LockRefresh:= false;
  LockCreateTV:= false;
  MainModul.AddToProject(Filename);
  PyIDEMainForm.actRunExecute(Self);
  //setActiveControl(MainModul.Diagram.GetPanel);
end;

function TFUMLForm.LoadFromFile(const FileName: string): boolean;
begin
  Open(Filename, '');
  Result:= true;
end;

//function OpenFile(const aFilename: String): boolean; virtual;

procedure TFUMLForm.MICloseClick(Sender: TObject);
begin
  TBInteractiveClick(Self);
end;

procedure TFUMLForm.MICopyAllClick(Sender: TObject);
begin
  Clipboard.AsText:= SynEdit.Text;
end;

procedure TFUMLForm.MICopyClick(Sender: TObject);
begin
  Clipboard.AsText:= SynEdit.SelText;
end;

procedure TFUMLForm.MIDeleteAllClick(Sender: TObject);
begin
  SynEdit.Clear;
end;

procedure TFUMLForm.MIDeleteClick(Sender: TObject);
begin
  SynEdit.ClearSelection;
end;

procedure TFUMLForm.MIFontClick(Sender: TObject);
begin
  CommandsDataModule.dlgFontDialog.Font.Assign(SynEdit.Font);
  if CommandsDataModule.dlgFontDialog.Execute then
    SynEdit.Font.Assign(CommandsDataModule.dlgFontDialog.Font);
end;

procedure TFUMLForm.MIPasteClick(Sender: TObject);
begin
  Synedit.PasteFromClipboard;
end;

procedure TFUMLForm.Retranslate;
begin
  RetranslateComponent(Self);
  MainModul.Diagram.Retranslate;
end;

procedure TFUMLForm.Enter(Sender: TObject);
  var  aPanel: TCustomPanel;
begin
  if LockEnter then exit;
  LockEnter:= true;
  inherited;
  if Visible then begin  // due to bug, else ActiveForm doesn't change
    if PUMLPanel.Visible and PUMLPanel.CanFocus then
      PUMLPanel.SetFocus;
    if assigned(MainModul) and assigned(MainModul.Diagram) then begin
      aPanel:= MainModul.Diagram.GetPanel;
      if assigned(aPanel) and aPanel.CanFocus then
        aPanel.SetFocus;
    end;
  end;
  DoActivate;
  TThread.ForceQueue(nil, procedure
    begin
      Refresh;
    end);
  LockEnter:= false;
end;

procedure TFUMLForm.ConfigureWindow(Sender: TObject);
begin
  Align:= alClient;
  MainModul.Diagram.ShowIcons:= GuiPyOptions.DiShowIcons;
  MainModul.Diagram.VisibilityFilter:= TVisibility(0);
  MainModul.Diagram.ShowParameter:= GuiPyOptions.DiShowParameter;
  MainModul.Diagram.SortOrder:= GuiPyOptions.DiSortOrder;
end;

procedure TFUMLForm.SBCloseClick(Sender: TObject);
begin
  (fFile as IFileCommands).ExecClose;
end;

procedure TFUMLForm.TBShowConnectionsClick(Sender: TObject);
  var sa: integer;
begin
  if assigned(MainModul) and assigned(MainModul.Diagram) then begin
    sa:= (Mainmodul.Diagram.ShowConnections + 1) mod 3;
    MainModul.Diagram.ShowConnections:= sa;
    Modified:= true;
  end;
end;

procedure TFUMLForm.TBSynEditZoomMinusClick(Sender: TObject);
begin
  SynEdit.Font.Size:= max(SynEdit.Font.Size -1, 6);
end;

procedure TFUMLForm.TBSynEditZoomPlusClick(Sender: TObject);
begin
  SynEdit.Font.Size:= SynEdit.Font.Size + 1;
end;

procedure TFUMLForm.TBViewClick(Sender: TObject);
  var sv: integer;
begin
  if assigned(MainModul) and assigned(MainModul.Diagram) then begin
    sv:= (Mainmodul.Diagram.ShowView + 1) mod 3;
    MainModul.Diagram.ShowView:= sv;
    Modified:= true;
  end;
end;

procedure TFUMLForm.TBZoomInClick(Sender: TObject);
begin
  SetFontSize(+1);
end;

procedure TFUMLForm.TBZoomOutClick(Sender: TObject);
begin
  SetFontSize(-1);
end;

procedure TFUMLForm.TBNewLayoutClick(Sender: TObject);
begin
  MainModul.DoLayout;
  Modified:= true;
end;

procedure TFUMLForm.TBDeleteClick(Sender: TObject);
begin
  if SynEdit.SelAvail
    then SynEdit.ClearSelection
    else SynEdit.Clear;
end;

procedure TFUMLForm.TBDiagramFromOpenWindowsClick(Sender: TObject);
begin
  MainModul.ShowAllOpenedFiles;
  Modified:= true;
end;

procedure TFUMLForm.TBExecuteClick(Sender: TObject);
  var Text: string; SL: TStringList;
begin
  if SynEdit.SelAvail
    then Text:= SynEdit.SelText
    else Text:= SynEdit.LineText;
  SynEdit.SelStart:= SynEdit.SelEnd;
  if Text = '' then Exit;
  Text:= StringReplace(Text, #9,
     StringOfChar(' ', SynEdit.TabWidth), [rfReplaceAll]);
  Text:= Dedent(Text);
  CollectClasses(nil);
  TBExecute.Enabled:= false;
  Screen.Cursor:= crHourglass;
  SL := TStringList.Create;
  try
    MainModul.Diagram.ExecutePython(Text);
    if GuiPyOptions.ShowAllNewObjects then
      MainModul.Diagram.ShowAllNewObjects(Self);
    MainModul.Diagram.ShowAll;
  finally
    SL.Free;
    Screen.Cursor:= crDefault;
    TBExecute.Enabled:= true;
  end;
end;

procedure TFUMLForm.TBInteractiveClick(Sender: TObject);
begin
  if PDiagram.Height < ClientHeight - 10 then begin
    RememberedHeight:= PDiagram.Height;
    PDiagram.Height:= ClientHeight - 4;
  end else
    PDiagram.Height:= min(RememberedHeight, ClientHeight - 100);
end;

procedure TFUMLForm.Refresh;
begin
  if LockRefresh then exit;
  LockRefresh:= true;
  if Pathname <> '' then begin
    LockWindow(Self.Handle);
    DoSave;
    MainModul.LoadUML(Pathname);
    MainModul.RefreshDiagram;
    CreateTVFileStructure;
    UnlockWindow;
  end;
  LockRefresh:= false;
end;

procedure TFUMLForm.TBRefreshClick(Sender: TObject);
begin
  PyIDEMainForm.actRunExecute(self);
end;

procedure TFUMLForm.TBClassDefinitionClick(Sender: TObject);
  var NewName: string; Editor: IEditor;
      FileTemplate : TFileTemplate;
begin
  NewName:= '';
  if CommandsDataModule.GetSaveFileName(NewName, CommandsDataModule.SynPythonSyn, 'py', true)
  then begin
    FileTemplate := FileTemplates.TemplateByName(SClassTemplateName);
    if FileTemplate = nil then begin
      FileTemplates.AddClassTemplate;
      FileTemplate:= FileTemplates.TemplateByName(SClassTemplateName);
    end;
    Editor:= PyIDEMainForm.NewFileFromTemplate(FileTemplate,
      PyIDEMainForm.TabControlIndex(PyIDEMainForm.ActiveTabControl), NewName);
    PyIDEMainForm.PrepareClassEdit(Editor, 'New', Self);
    ConfigureWindow(Self);
    Modified:= true;
  end;
end;

procedure TFUMLForm.Save(MitBackup: boolean);
begin
  MainModul.SaveUML(Pathname);
  SynEdit.Modified:= false;
  Modified:= false;
end;

procedure TFUMLForm.Print;
begin
  MainModul.Print;
end;

procedure TFUMLForm.TBObjectDiagramClick(Sender: TObject);
  var b: boolean;
begin
  if assigned(MainModul) and assigned(MainModul.Diagram) then begin
    b:= not Mainmodul.Diagram.ShowObjectDiagram;
    Mainmodul.Diagram.ShowObjectDiagram:= b;
    Modified:= true;
    TBObjectDiagram.Down:= b;
  end;
end;

procedure TFUMLForm.TBCommentClick(Sender: TObject);
begin
  if assigned(MainModul) and assigned(MainModul.Diagram) then 
    Mainmodul.Diagram.AddCommentBoxTo(nil);
end;

procedure TFUMLForm.TBClassOpenClick(Sender: TObject);
begin
  if Mainmodul.Diagram.ShowObjectDiagram then begin
    Mainmodul.Diagram.ShowObjectDiagram:= false;
    TBObjectDiagram.Down:= false;
  end;
  PyIDEMainForm.actUMLOpenClassExecute(Self);
  Modified:= true;
end;

procedure TFUMLForm.PDiagramPanelResize(Sender: TObject);
begin
  inherited;
  if Assigned(MainModul) then
    MainModul.Diagram.RecalcPanelSize;
end;

function TFUMLForm.CanCopy: boolean;
begin
  Result:= true;
end;

procedure TFUMLForm.CopyToClipboard;
begin
  MainModul.CopyDiagramClipboardActionExecute(Self);
end;

procedure TFUMLForm.SetFont(aFont: TFont);
begin
  MainModul.Diagram.SetFont(aFont);
  MainModul.RefreshDiagram;
  SynEdit.Font.Size:= 12;
end;

function TFUMLForm.GetFont: TFont;
begin
  Result:= MainModul.Diagram.Font;
end;

procedure TFUMLForm.SetFontSize(Delta: integer);
  var aFont: TFont;
begin
  aFont:= GetFont;
  aFont.Size:= aFont.Size + Delta;
  if aFont.Size < 6 then aFont.Size:= 6;
  SetFont(aFont);
end;

procedure TFUMLForm.SetOptions;
begin
  Refresh;
end;

procedure TFUMLForm.SetOnlyModified(aModified: boolean);
begin
  inherited SetModified(aModified);
end;

procedure TFUMLForm.OnPanelModified(aValue: Boolean);
begin
  setModified(aValue);
end;

procedure TFUMLForm.TBReInitializeClick(Sender: TObject);
begin
  pyIDEMainform.actPythonReinitializeExecute(Sender);
end;

procedure TFUMLForm.AddToProject(const Filename: string);
begin
  FConfiguration.ShowAlways:= false;
  if Filename <> '' then
    MainModul.AddToProject(Filename);
  FConfiguration.ShowAlways:= true;
end;

procedure TFUMLForm.OnInteractiveModified(Sender: TObject);
begin
  Modified:= true;
end;

procedure TFUMLForm.CollectClasses(SL: TStringList);
begin
  (MainModul.Diagram as TRtfdDiagram).CollectClasses;
end;

procedure TFUMLForm.CreateTVFileStructure;
  var
    Ci, it: IModelIterator;
    cent: TClassifier;
    Attribut: TAttribute;
    Methode: TOperation;
    PictureNr, i, Indent, IndentOld: Integer;
    CName: string;
    Node: TTreeNode;
    ClassNode: TTreeNode;
    aInteger: TInteger;

  function CalculateIndentation(const Klassenname: string): integer;
    var i: integer;
  begin
    Result:= 0;
    for i:= 1 to length(Klassenname) do
      if Klassenname[i] = '.' then inc(Result);
  end;

begin
  if LockCreateTV then exit;
  LockCreateTV:= true;
  Indent:= 0;
  Classnode:= nil;
  TVFileStructure.Items.BeginUpdate;
  for i:= TVFileStructure.Items.Count - 1 downto 0 do begin
    aInteger:= TInteger(TVFileStructure.Items[i].Data);
    FreeAndNil(aInteger);
  end;
  TVFileStructure.Items.Clear;
  Ci:= MainModul.Model.ModelRoot.GetAllClassifiers;
  while Ci.HasNext do begin
    cent := TClassifier(Ci.Next);
    if (MainModul.Model.ModelRoot.Files.Indexof(Cent.Pathname) = -1) or
       not Cent.IsVisible or endsWith(Cent.Name, '[]') then
      continue;

    CName:= cent.ShortName;
    IndentOld:= Indent;
    Indent:= CalculateIndentation(CName);
    while Pos('.', CName) > 0 do
      delete(CName, 1, Pos('.', CName));

    if (cent is TClass)
      then PictureNr:= 1
      else PictureNr:= 11;

    if Indent = 0 then
      ClassNode:= TVFileStructure.Items.AddObject(nil, CName, TInteger.create(cent.LineS))
    else if Indent > IndentOld then
      ClassNode:= TVFileStructure.Items.AddChildObject(ClassNode, CName, TInteger.create(cent.LineS))
    else begin
      while Indent < IndentOld do begin
        dec(IndentOld);
        ClassNode:= ClassNode.Parent;
      end;
      ClassNode:= TVFileStructure.Items.AddChildObject(ClassNode, CName, TInteger.create(cent.LineS));
    end;

    ClassNode.ImageIndex:= PictureNr;
    ClassNode.SelectedIndex:= PictureNr;
    ClassNode.HasChildren:= true;

    it:= cent.GetAttributes;
    while It.HasNext do begin
      Attribut:= It.Next as TAttribute;
      PictureNr:= Integer(Attribut.Visibility) + 2;
      Node:= TVFileStructure.Items.AddChildObject(ClassNode, Attribut.toShortStringNode, TInteger.create(Attribut.LineS));
      Node.ImageIndex:= PictureNr;
      Node.SelectedIndex:= PictureNr;
      Node.HasChildren:= false;
    end;
    It:= cent.GetOperations;
    while It.HasNext do begin
      Methode:= It.Next as TOperation;
      if Methode.OperationType = otConstructor
        then PictureNr:= 6
        else PictureNr:= Integer(Methode.Visibility) + 7;
      Node:= TVFileStructure.Items.AddChildObject(ClassNode, Methode.toShortStringNode, TInteger.create(Methode.LineS));
      Node.ImageIndex:= PictureNr;
      Node.SelectedIndex:= PictureNr;
      Node.HasChildren:= false;
    end;
  end;
  TVFileStructure.Items.EndUpdate;
  FFileStructure.init(TVFileStructure.Items, Self);
  LockCreateTV:= false;
end;

procedure TFUMLForm.WMSpSkinChange(var Message: TMessage);
begin
  inherited;
  ChangeStyle;
end;

procedure TFUMLForm.ChangeStyle;
begin
  if IsStyledWindowsColorDark then begin
    TBUMLToolbar.Images:= DMImages.ILUMLToolbarDark;
    TBInteractiveToolbar.Images:= DMImages.ILInteractiveDark;
    PMInteractive.Images:= DMImages.ILInteractiveDark;
  end else begin
    TBUMLToolbar.Images:= DMImages.ILUMLToolbarLight;
    TBInteractiveToolbar.Images:= DMImages.ILInteractive;
    PMInteractive.Images:= DMImages.ILInteractive
  end;
  MainModul.Diagram.ChangeStyle;
end;

function TFUMLForm.getAsStringList: TStringList;
begin
  Save(false);
  Result:= TStringList.Create;
  Result.LoadFromFile(Pathname);
end;

procedure TFUMLForm.ExecCommand(cmd: integer);
begin
  (MainModul.Diagram as TRtfdDiagram).ExecCommand(cmd);
end;

procedure TFUMLForm.ShowAll;
begin
  (MainModul.Diagram as TRtfdDiagram).ShowAll;
end;

procedure TFUMLForm.SynEditChange(Sender: TObject);
begin
  Modified:= true;
end;

procedure TFUMLForm.ClassEdit;
begin
  MainModul.EditSelectedElement;
  Modified:= true;
end;

end.

