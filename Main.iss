; Installer of Virtual Environment Softwares 
;
; Install 
;   - VirtualBox
;   - Vagrant
;   - ChefDK
;   - Cygwin
; Set
;   - Registery Proxy
;   - Path
;

; Registry Position
#define HKLM_EnvKey "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
#define HKCU_NetKey "Software\Microsoft\Windows\CurrentVersion\Internet Settings"

; Define MyApp Info
#define MyPublisher  "ClickMaker"
#define MyAppName    "Virtual Environment Installer Pack"
#define MyAppVersion "0.1.1"
#define MyOutputFile  StringChange(MyAppName, " ", "_") + "." + StringChange(MyAppVersion, ".", "_")

#define SetupIni     "..\Files\setup.ini"

; Include Inno-Setup Download Plugin
#include <idp.iss>

[Setup]
AppName={#MyAppName}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyPublisher}
VersionInfoVersion={#MyAppVersion}
OutputBaseFilename={#MyOutputFile}

; Enable Logging
SetupLogging=yes

; Require Admin Execution 
PrivilegesRequired=admin

; ------------- Inno-Setup Default Pages Setup 
; Select Language Dialog 
ShowLanguageDialog=no

; Show Welcome Page
DisableWelcomePage=yes
; * no use.

; Show License Page
;LicenseFile=""
; * refer to each softwares.

; Show Password Page
;Password=
; * no use.

; Show Infomation Page
;InfoBeforeFile=""
; * set in [Languages] section.

; Show UserInfo Page
UserInfoPage=no
; * no use.

; Show Install Dir Page
DisableDirPage=yes
DefaultDirName={pf}\{#MyAppName}

;
DisableReadyPage=no

AppendDefaultDirName=no


[Languages]
Name: japanese; \
    MessagesFile: "compiler:\Languages\Japanese.isl,{__FILE__}\..\Messages\Japanese.isl"; \
    InfoBeforeFile: "Files\README_JP.txt"

Name: english; \
    MessagesFile: "compiler:Default.isl,{__FILE__}\..\Messages\English.isl"; \
    InfoBeforeFile: "Files\README.txt"

[Files]
Source: "Files\*"; DestDir: "{app}"; Flags: isreadme ignoreversion touch


[Types]
; disable installation type dropdown
Name: "custom"; Description: "Normal installation"; Flags: iscustom

[Components]
; ViatualBox (about 169MB)
Name: "VirtualBox"; Description: "VirtualBox"; Types: custom; ExtraDiskSpaceRequired: 177209344
; Vagrant (about 575 MB)
Name: "Vagrant";    Description: "Vagrant";    Types: custom; ExtraDiskSpaceRequired: 602931200
; Chef Development Kit (about 340MB)
Name: "ChefDK";     Description: "Chef Development Kit"; Types: custom; ExtraDiskSpaceRequired: 356515840
Name: "cygwin";     Description: "cygwin";     Types: custom;


[Code]
#include "Src\Common.iss"
#include "Src\Virtualbox.iss"

var
    ProxyPage: TWizardPage;

{ ProxyPage }
procedure CreateProxyPage;
var
    { variables }
    Page: TWizardPage;
    RegProxyEnable:   Cardinal;
    RegProxyServer:   String;
    RegProxyAddress:  String;
    RegProxyPort:     String;
    RegProxyOverride: String;

    { forms }
    UseProxyCheckBox:    TNewCheckBox;
    ProxyAddressLabel:   TNewStaticText;
    ProxyAddressTextBox: TNewEdit;
    ProxyPortLabel:      TNewStaticText;
    ProxyPortTextBox:    TNewEdit;
    AddLocalCheckBox:    TNewCheckBox;
    AddVmCheckBox:       TNewCheckBox;
    ProxyNotice:         TNewStaticText;
    LineCount:  Integer;
    LineHeight: Integer;
begin
    ProxyPage := CreateCustomPage(wpInfoBefore, CustomMessage('ProxyPageTitle'), CustomMessage('ProxyPageDesc'));
    Page := ProxyPage;

    { get current proxy registry }
    RegQueryDWordValue (HKEY_CURRENT_USER, '{#HKCU_NetKey}', 'ProxyEnable', RegProxyEnable);
    RegQueryStringValue(HKEY_CURRENT_USER, '{#HKCU_NetKey}', 'ProxyServer', RegProxyServer);
    if (Length(RegProxyServer) > 0) then
    begin
        RegProxyAddress := Copy(RegProxyServer, 1, Pos(':', RegProxyServer) -1);
        RegProxyPort    := Copy(RegProxyServer, Pos(':', RegProxyServer) + 1, Length(RegProxyServer) - Pos(':', RegProxyServer));
    end;

    { create forms }
    LineCount := 0;
    LineHeight := 24;

    UseProxyCheckBox := TNewCheckBox.Create(Page);
    with UseProxyCheckBox do
    begin
        Parent   := Page.Surface;
        if (RegProxyEnable = 1) then
        begin
        Checked  := True;
        end else
        begin
        Checked  := False;
        end;
        Top      := ScaleY(16) + LineCount * LineHeight;
        Width    := Page.SurfaceWidth;
        Caption  := CustomMessage('ProxyPageUseProxy');
    end;

    LineCount := LineCount + 1;

    ProxyAddressLabel := TNewStaticText.Create(Page);
    with ProxyAddressLabel do
    begin
        Parent   := Page.Surface;
        Top      := ScaleY(16) + LineCount * LineHeight;
        Left     := ScaleX(16);
        AutoSize := True;
        Caption  := CustomMessage('ProxyPageAddress');
    end;

    ProxyAddressTextBox := TNewEdit.Create(Page);
    with ProxyAddressTextBox do
    begin
        Parent   := Page.Surface;
        Top      := ScaleY(16) + LineCount * LineHeight;
        Left     := ScaleX(16) + ProxyAddressLabel.Width + ScaleX(8);
        Width    := Page.SurfaceWidth div 2 - ScaleX(8);
        Text     := RegProxyAddress
    end;

    LineCount := LineCount + 1;

    ProxyPortLabel := TNewStaticText.Create(Page);
    with ProxyPortLabel do
    begin
        Parent   := Page.Surface;
        Top      := ScaleY(16) + LineCount * LineHeight;
        Left     := ScaleX(16);
        AutoSize := True;
        Caption  := CustomMessage('ProxyPagePort');
    end;

    ProxyPortTextBox := TNewEdit.Create(Page);
    with ProxyPortTextBox do
    begin
        Parent   := Page.Surface;
        Top      := ScaleY(16) + LineCount * LineHeight - ScaleY(2);
        Left     := ProxyAddressTextBox.Left;
        Width    := Page.SurfaceWidth div 2 - ScaleX(8);
        Text     := RegProxyPort
    end;

    LineCount := LineCount + 1;

    AddLocalCheckBox := TNewCheckBox.Create(Page);
    with AddLocalCheckBox do
    begin
        Parent   := Page.Surface;
        Checked  := True;
        Top      := ScaleY(16) + LineCount * LineHeight;
        Left     := ScaleX(16);
        Width    := Page.SurfaceWidth;
        Caption  := CustomMessage('ProxyPageAddLocalToNoProxy');
    end;

    LineCount := LineCount + 1;

    AddVmCheckBox := TNewCheckBox.Create(Page);
    with AddVmCheckBox do
    begin
        Parent   := Page.Surface;
        Checked  := True;
        Top      := ScaleY(16) + LineCount * LineHeight;
        Left     := ScaleX(16);
        Width    := Page.SurfaceWidth;
        Caption  := CustomMessage('ProxyPageAddVmToNoProxy');
    end;

    LineCount := LineCount + 1;

    ProxyNotice := TNewStaticText.Create(Page);
    with ProxyNotice do
    begin
        Parent   := Page.Surface;
        Top      := ScaleY(16) + LineCount * LineHeight;
        Left     := ScaleX(0);
        AutoSize := True;
        Caption  := CustomMessage('ProxyPageNotice');
    end;
end;

procedure InstallSoftware();
var
  SoftwareName: String;
  ExeFileName:  String;
  Params:       String;
  InstallDir:   String;
  ResultCode:   Integer;
begin
    { prepare VirtualBox }
    if IsComponentSelected('VirtualBox') then
    begin
    end;
//  GetIniString(
//    'virtualbox',
//    'VirtualBoxDownloadUrl',
//    'bad read',
//    ExpandConstant('{#SetupIni}')
//    );
end;

procedure InitializeWizard;
var
 test: String;
begin
    { create the custom pages }
    CreateProxyPage;

end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
    case CurStep of
        ssPostInstall:
        begin
            try
                InstallSoftware;
            finally
                DelTree(ExpandConstant('{tmp}') + '\*', False, True, True);
            end;
        end;
    end;
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
    { Skip pages that shouldn't be shown }
    Result := False;
end;

