[Code]
(**-----------------------
 * Customize functions
 *  - customize page, setting
 * ----------------------- *)

(**
 * define enumeration
 *   inno setup can not use "class".
 *)
type TCustomizeForms = record
    AutoInstallCheckBox:      TNewCheckBox;
    RemainInstallerCheckBox:  TNewCheckBox;
    RemainInstallerFileBox:   TNewEdit;
    RemainInstallerButton:    TNewButton;
    InstallExampleCheckBox:   TNewCheckBox;
    InstallExampleFileBox:    TNewEdit;
    InstallExampleButton:     TNewButton;
end;

(**
 * define global variables
 *   to provide form value to other method,
 *)
var
    CustomizePage  : TInputQueryWizardPage;
    CustomizeForms : TCustomizeForms;
    ExampleDirName : String;

(**
 * define hook method
 *)
procedure ShowSelectFolderDialog(ReturnTo: TNewEdit); forward;
procedure ShowRemainInstallerDialog(Sender: TObject); forward;
procedure ShowInstallExampleDialog(Sender: TObject); forward;

(**
 * CreateCustomizePage
 *   create customize page
 *)
procedure CreateCustomizePage(AfterID: Integer);
var
    Page  : TInputQueryWizardPage;
    Forms : TCustomizeForms;
    LineCount:        Integer;
    LineHeight:       Integer;
begin
    // create page
    Page  := CreateInputQueryPage(AfterID, CustomMessage('CustomizePageTitle'), CustomMessage('CustomizePageDesc'), '');

    ExampleDirName := 'vets-examples';

    // create forms
    LineCount := 0;
    LineHeight := 24;

    Forms.AutoInstallCheckBox := TNewCheckBox.Create(Page);
    with Forms.AutoInstallCheckBox do
    begin
        Parent   := Page.Surface;
        Checked  := True;
        Top      := ScaleY(16) + LineCount * LineHeight;
        Width    := Page.SurfaceWidth;
        Caption  := CustomMessage('CustomizeAutoInstall');
    end;

    LineCount := LineCount + 1;

    Forms.RemainInstallerCheckBox := TNewCheckBox.Create(Page);
    with Forms.RemainInstallerCheckBox do
    begin
        Parent   := Page.Surface;
        Checked  := True;
        Top      := ScaleY(16) + LineCount * LineHeight;
        Left     := 0;
        Width    := Page.SurfaceWidth
        Caption  := CustomMessage('CustomizeRemainInstaller');
    end;

    LineCount := LineCount + 1;

    Forms.RemainInstallerFileBox := TNewEdit.Create(Page);
    with Forms.RemainInstallerFileBox do
    begin
        Parent   := Page.Surface;
        Top      := ScaleY(16) + LineCount * LineHeight;
        Left     := ScaleX(16);
        Width    := Page.SurfaceWidth - ScaleX(16 + 96);
        Text     := GetSetupValue('Customize', 'InstallerPath', ExpandConstant('{%USERPROFILE}\Downloads'), True);
        ReadOnly := True;
    end;

    Forms.RemainInstallerButton := TNewButton.Create(Page);
    with Forms.RemainInstallerButton do
    begin
        Parent   := Page.Surface;
        Top      := ScaleY(16) + LineCount * LineHeight - ScaleY(2);
        Left     := Forms.RemainInstallerFileBox.Left + Forms.RemainInstallerFileBox.Width + ScaleX(4);
        Width    := ScaleX(72);
        Caption  := CustomMessage('Browse');
    end;

    LineCount := LineCount + 1;

    Forms.InstallExampleCheckBox := TNewCheckBox.Create(Page);
    with Forms.InstallExampleCheckBox do
    begin
        Parent   := Page.Surface;
        Checked  := False;
        Top      := ScaleY(16) + LineCount * LineHeight;
        Left     := 0;
        Width    := Page.SurfaceWidth
        Caption  := CustomMessage('CustomizeInstallExample');
    end;

    LineCount := LineCount + 1;

    Forms.InstallExampleFileBox := TNewEdit.Create(Page);
    with Forms.InstallExampleFileBox do
    begin
        Parent   := Page.Surface;
        Top      := ScaleY(16) + LineCount * LineHeight;
        Left     := ScaleX(16);
        Width    := Page.SurfaceWidth - ScaleX(16 + 96);
        Text     := GetSetupValue('Customize', 'ExamplePath', ExpandConstant('{userdesktop}\') + ExampleDirName, True);
        ReadOnly := True;
    end;

    Forms.InstallExampleButton := TNewButton.Create(Page);
    with Forms.InstallExampleButton do
    begin
        Parent   := Page.Surface;
        Top      := ScaleY(16) + LineCount * LineHeight - ScaleY(2);
        Left     := Forms.InstallExampleFileBox.Left + Forms.InstallExampleFileBox.Width + ScaleX(4);
        Width    := ScaleX(72);
        Caption  := CustomMessage('Browse');
    end;

    // check by current setting

    // return to global
    CustomizePage  := Page;
    CustomizeForms := Forms;

    // set onclick hook
    CustomizeForms.RemainInstallerButton.OnClick := @ShowRemainInstallerDialog;
    CustomizeForms.InstallExampleButton.OnClick  := @ShowInstallExampleDialog;
end;

(**
 * ShowRemainInstallerDialog
 *   show select folder dialog
 *)
procedure ShowSelectFolderDialog(ReturnTo: TNewEdit);
var
    SelectDir: String;
begin
    if DirExists(ReturnTo.Text) then
    begin
        SelectDir := ReturnTo.Text
    end;

    if BrowseForFolder(CustomMessage('SelectFolder'), SelectDir, True) then
    begin
        ReturnTo.Text := SelectDir;
    end;
end;

procedure ShowRemainInstallerDialog(Sender: TObject);
begin
    ShowSelectFolderDialog(CustomizeForms.RemainInstallerFileBox);
end;

procedure ShowInstallExampleDialog(Sender: TObject);
var
    FileBox: TNewEdit;
    BaseDir: String;
begin
    FileBox := CustomizeForms.InstallExampleFileBox;
    BaseDir := RegexReplace(FileBox.Text, '', '\\' + ExampleDirName + '$', True)
    FileBox.Text := BaseDir;

    ShowSelectFolderDialog(FileBox);

    if not RegexMatch(FileBox.Text, '\\' + ExampleDirName + '$', True) then
    begin
        FileBox.Text := FileBox.Text + '\' + ExampleDirName;
    end;
end;

