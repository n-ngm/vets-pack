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
#define MyAppVersion "0.1.4"
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

; Show License Page
;LicenseFile=""

; Show Password Page
;Password=

; Show Infomation Page
;InfoBeforeFile=""

; Show UserInfo Page
UserInfoPage=no

; Show Install Dir Page
DisableDirPage=yes
DefaultDirName={pf}\{#MyAppName}

; Show Ready Page
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
Source: "Files\Setup.ini"; DestDir: "{app}";

[Types]
; Disable dropdown of installation type
Name: "custom"; Description: "Normal installation"; Flags: iscustom

[Components]
; TODO use idp comp
Name: "VirtualBox"; Description: "VirtualBox";           Types: custom; ExtraDiskSpaceRequired: 177209344
Name: "Vagrant";    Description: "Vagrant";              Types: custom; ExtraDiskSpaceRequired: 602931200
Name: "ChefDK";     Description: "Chef Development Kit"; Types: custom; ExtraDiskSpaceRequired: 356515840
Name: "Cygwin";     Description: "cygwin";               Types: custom;

[Code]
#include "Src\Common.iss"
#include "Src\Registry.iss"
#include "Src\ProxyPage.iss"
#include "Src\Virtualbox.iss"

procedure InstallSoftware(); forward;

procedure InitializeWizard;
begin
    { extract setup.ini }
    ExtractTemporaryFile(ExpandConstant('{#SetupIni}'));

    { create the custom pages }
    CreateProxyPage(wpInfoBefore);

    { download starts set }
    idpDownloadAfter(wpInstalling);
    idpSetDetailedMode(True);
end;

procedure CurPageChanged(CurPageID: Integer);
var
    SoftName:     String;
    DownloadUrl:  String;
    SaveFileName: String;
begin
    if CurPageID = wpInstalling then
    begin
        { reset file list }
        idpClearFiles;

        SoftName := 'VirtualBox';
        if IsComponentSelected(Softname) then
        begin
            DownloadUrl  := GetIniString(SoftName, SoftName + 'DownloadUrl',  '', ExpandConstant('{tmp}\{#SetupIni}'));
            SaveFileName := GetIniString(SoftName, SoftName + 'SaveFileName', '', ExpandConstant('{tmp}\{#SetupIni}'));
            idpAddFile(DownloadUrl, ExpandConstant('{app}\') + SaveFileName);
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
            { set proxy to registry }
            SetProxyToRegistry;

            InstallSoftware;

            //DelTree(ExpandConstant('{tmp}') + '\*', False, True, True);
        end;
    end;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
    case CurPageID of
        ProxyPage.ID:
        begin
        end;
    end;
    Result := True;
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
    { Skip pages that shouldn't be shown }
    Result := False;
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
end;

