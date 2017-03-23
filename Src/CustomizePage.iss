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
    RemainInstallerTextBox:   TNewEdit;
    RemainInstallerButton:    TNewButton;
    InstallExampleCheckBox:   TNewCheckBox;
    installExampleTextBox:    TNewEdit;
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
    LineCount  : Integer;
    LineHeight : Integer;
    i: Integer;
begin
    // create page
    Page := CreateInputQueryPage(AfterID, CustomMessage('CustomizePageTitle'), CustomMessage('CustomizePageDesc'), '');

    ExampleDirName := 'vets-examples';

    // create forms
    LineCount  := 0;
    LineHeight := 24;

    Forms.AutoInstallCheckBox := TNewCheckBox.Create(Page);
    with Forms.AutoInstallCheckBox do
    begin
        Parent   := Page.Surface;
        Checked  := StrToBool(GetSetupIniValue('Customize', 'AutoInstall', 'True', True));
        Top      := LineCount * LineHeight;
        Width    := Page.SurfaceWidth;
        Caption  := CustomMessage('CustomizeAutoInstall');
    end;

    LineCount := LineCount + 1;

    Forms.RemainInstallerCheckBox := TNewCheckBox.Create(Page);
    with Forms.RemainInstallerCheckBox do
    begin
        Parent   := Page.Surface;
        Checked  := StrToBool(GetSetupIniValue('Customize', 'RemainInstaller', 'True', True));
        Top      := LineCount * LineHeight;
        Left     := 0;
        Width    := Page.SurfaceWidth
        Caption  := CustomMessage('CustomizeRemainInstaller');
    end;

    LineCount := LineCount + 1;

    Forms.RemainInstallerTextBox := TNewEdit.Create(Page);
    with Forms.RemainInstallerTextBox do
    begin
        Parent   := Page.Surface;
        Top      := LineCount * LineHeight;
        Left     := ScaleX(16);
        Width    := Page.SurfaceWidth - ScaleX(16 + 96);
        Text     := ExpandConstant( GetSetupIniValue('Customize', 'RemainInstallerPath', '{%USERPROFILE}\Downloads', True) );
        ReadOnly := True;
    end;

    Forms.RemainInstallerButton := TNewButton.Create(Page);
    with Forms.RemainInstallerButton do
    begin
        Parent   := Page.Surface;
        Top      := LineCount * LineHeight - ScaleY(2);
        Left     := Forms.RemainInstallerTextBox.Left + Forms.RemainInstallerTextBox.Width + ScaleX(4);
        Width    := ScaleX(72);
        Caption  := CustomMessage('Browse');
    end;

    LineCount := LineCount + 1;

    Forms.InstallExampleCheckBox := TNewCheckBox.Create(Page);
    with Forms.InstallExampleCheckBox do
    begin
        Parent   := Page.Surface;
        Checked  := StrToBool(GetSetupIniValue('Customize', 'InstallExample', 'False', True));
        Top      := LineCount * LineHeight;
        Left     := 0;
        Width    := Page.SurfaceWidth
        Caption  := CustomMessage('CustomizeInstallExample');
    end;

    LineCount := LineCount + 1;

    Forms.InstallExampleTextBox := TNewEdit.Create(Page);
    with Forms.InstallExampleTextBox do
    begin
        Parent   := Page.Surface;
        Top      := LineCount * LineHeight;
        Left     := ScaleX(16);
        Width    := Page.SurfaceWidth - ScaleX(16 + 96);
        Text     := ExpandConstant( GetSetupIniValue('Customize', 'ExamplePath', '{userdesktop}\' + ExampleDirName, True) );
        ReadOnly := True;
    end;

    Forms.InstallExampleButton := TNewButton.Create(Page);
    with Forms.InstallExampleButton do
    begin
        Parent   := Page.Surface;
        Top      := LineCount * LineHeight - ScaleY(2);
        Left     := Forms.InstallExampleTextBox.Left + Forms.InstallExampleTextBox.Width + ScaleX(4);
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
    ShowSelectFolderDialog(CustomizeForms.RemainInstallerTextBox);
end;

procedure ShowInstallExampleDialog(Sender: TObject);
var
    TextBox: TNewEdit;
    BaseDir: String;
begin
    TextBox := CustomizeForms.InstallExampleTextBox;
    BaseDir := RegexReplace(TextBox.Text, '', '\\' + ExampleDirName + '$', True)
    TextBox.Text := BaseDir;

    ShowSelectFolderDialog(TextBox);

    if not RegexMatch(TextBox.Text, '\\' + ExampleDirName + '$', True) then
    begin
        TextBox.Text := TextBox.Text + '\' + ExampleDirName;
    end;
end;

(**
 * SaveCustomizePage
 *   save values in customize page to setup.ini
 *)
procedure SaveCustomizePage;
begin
    SetSetupIniValue('Customize', 'AutoInstall',         BoolToStr(CustomizeForms.AutoInstallCheckBox.Checked));
    SetSetupIniValue('Customize', 'RemainInstaller',     BoolToStr(CustomizeForms.RemainInstallerCheckBox.Checked));
    SetSetupIniValue('Customize', 'RemainInstallerPath', CustomizeForms.RemainInstallerTextBox.Text);
    SetSetupIniValue('Customize', 'InstallExample',      BoolToStr(CustomizeForms.InstallExampleCheckBox.Checked));
    SetSetupIniValue('Customize', 'ExamplePath',         CustomizeForms.InstallExampleTextBox.Text);
end;
