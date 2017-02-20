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
#define MyAppVersion "0.1.3"
#define MyOutputFile  StringChange(MyAppName, " ", "_") + "." + StringChange(MyAppVersion, ".", "_")

#define SetupIni     "Setup.ini"

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
ShowLanguageDialog=yes

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

[INI]
Filename: "{app}\Setup.ini"; Section: "VirtualBox";

[Types]
; disable installation type dropdown
Name: "custom"; Description: "Normal installation"; Flags: iscustom

[Components]
; VirtualBox (about 169MB)
Name: "VirtualBox"; Description: "VirtualBox"; Types: custom; ExtraDiskSpaceRequired: 177209344
; Vagrant (about 575MB)
Name: "Vagrant";    Description: "Vagrant";    Types: custom; ExtraDiskSpaceRequired: 602931200
; Chef Development Kit (about 340MB)
Name: "ChefDK";     Description: "Chef Development Kit"; Types: custom; ExtraDiskSpaceRequired: 356515840
; Cygwin
Name: "Cygwin";     Description: "cygwin";     Types: custom;

[Code]
#include "Src\Common.iss"
#include "Src\Registry.iss"
#include "Src\ProxyPage.iss"
#include "Src\Virtualbox.iss"


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
end;

procedure InitializeWizard;
begin
    { create the custom pages }
    CreateProxyPage(wpInfoBefore);

    { download starts set }
    idpDownloadAfter(wpInstalling);
end;

procedure CurPageChanged(CurPageID: Integer);
var
    SoftName:    String;
    DownloadUrl: String;
    SavedPath:   String;
begin
    if CurPageID = wpPreparing then
    begin

//        if ProxyPage.Values[0] then
//        begin
//            MsgBox('proxy set', mbConfirmation, MB_YESNO);
//        end else begin
//            MsgBox('proxy not', mbConfirmation, MB_YESNO);
//        end;

    end;

    if CurPageID = wpInstalling then
    begin
        MsgBox('after wpInstalling', mbConfirmation, MB_YESNO);
        // User can navigate to 'Ready to install' page several times, so we
        // need to clear file list to ensure that only needed files are added.
        idpClearFiles;

        SoftName := 'VirtualBox';
        if IsComponentSelected(Softname) then
        begin
            DownloadUrl := GetIniString(SoftName, SoftName + 'DownloadUrl',  '', ExpandConstant('{app}') + '/' + ExpandConstant('{#SetupIni}'));
            SavedPath   := GetIniString(SoftName, SoftName + 'SaveFileName', '', ExpandConstant('{app}') + '/' + ExpandConstant('{#SetupIni}'));
            MsgBox(DownloadUrl, mbConfirmation, MB_OK);
            MsgBox(SavedPath,   mbConfirmation, MB_OK);
            //idpAddFile(DownloadUrl, SavedPath);
        end;
    end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
    SoftName:    String;
    DownloadUrl: String;
    SavedPath:   String;
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

function NextButtonClick(CurPageID: Integer): Boolean;
begin
    case CurPageID of
        ProxyPage.ID:
        begin
            MsgBox(IntToStr(Integer(ProxyForms.UseProxyCheckBox.Checked)), mbConfirmation, MB_YESNO);
        end;
    end;
    Result := True;
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
    { Skip pages that shouldn't be shown }
    Result := False;
end;

