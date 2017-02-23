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

; Define MyApp Info
#define MyPublisher  "ClickMaker"
#define MyAppName    "Virtual Environment Installer Pack"
#define MyAppVersion "0.1.10"
#define MyOutputFile  StringChange(MyAppName, " ", "_") + "." + StringChange(MyAppVersion, ".", "_")

#define SetupIni     "Setup.ini"

; Include Inno-Setup Download Plugin
#include <idp.iss>

; inclue sources
#include "Src\Common.iss"
#include "Src\Registry.iss"
#include "Src\ProxyPage.iss"
#include "Src\Virtualbox.iss"
#include "Src\Vagrant.iss"
#include "Src\ChefDK.iss"

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
Name: "VirtualBox"; Description: "VirtualBox";           Types: custom;
Name: "Vagrant";    Description: "Vagrant";              Types: custom;
Name: "ChefDK";     Description: "Chef Development Kit"; Types: custom;
Name: "Cygwin";     Description: "cygwin";               Types: custom;

[Code]
var
    DownloadDir: String;

procedure ListUpSoftware;  forward;
procedure InstallSoftware; forward;
function  GetDownloadUrl  (SoftName: String): String; forward;
function  GetInstallerPath(SoftName: String): String; forward;

procedure InitializeWizard;
begin
    { extract setup.ini }
    ExtractTemporaryFile(ExpandConstant('{#SetupIni}'));
    DownloadDir := '{tmp}';

    { create the custom pages }
    CreateProxyPage(wpInfoBefore);

end;

procedure CurPageChanged(CurPageID: Integer);
begin
    if CurPageID = wpReady then
    begin
        { list up software to download }
        ListUpSoftware;
    end;

    if CurPageID = wpPreparing then
    begin
        { set proxy to registry }
        SetProxyToRegistry;

        { download starts set }
        idpDownloadAfter(wpPreparing);
    end;

    if CurPageID = wpInstalling then
    begin
        { install software }
        InstallSoftware;
    end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
    case CurStep of
        ssPostInstall:
        begin
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
    Result := False;
end;

procedure ListUpSoftware;
var
    SoftNames:     array of String;
    SoftName:      String;
    DownloadUrl:   String;
    InstallerPath: String;
    i: Integer;
begin
    { reset file list }
    idpClearFiles;

    SetArrayLength(SoftNames, 4);
    SoftNames[0] := 'VirtualBox';
    SoftNames[1] := 'Vagrant';
    SoftNames[2] := 'ChefDK';
    SoftNames[3] := 'Cygwin';
    { add download file list }
    for i := 0 to 3 do
    begin
        SoftName := SoftNames[i];
        if IsComponentSelected(SoftName) then
        begin
            DownloadUrl   := GetDownloadUrl(SoftName);
            InstallerPath := GetInstallerPath(SoftName);
            idpAddFile(DownloadUrl, InstallerPath);
        end;
    end;

end;


(**
 * InstallSoftware
 *   execute installers.
 *)
procedure InstallSoftware;
var
    SoftName:     String;
    ExeFileName:  String;
    Params:       String;
    InstallDir:   String;
    ResultCode:   Integer;
begin
    // install VirtualBox
    SoftName := 'VirtualBox';
    if IsComponentSelected(SoftName) then
    begin
        Virtualbox_Install(GetInstallerPath(SoftName));
    end;

    // install Vagrant
    SoftName := 'Vagrant';
    if IsComponentSelected(SoftName) then
    begin
        Vagrant_Install(GetInstallerPath(SoftName));
    end;

    // install ChefDK
    SoftName := 'ChefDK';
    if IsComponentSelected(SoftName) then
    begin
        ChefDK_Install(GetInstallerPath(SoftName));
    end;
end;

(**
 * GetDownloadUrl
 *   get download url from setup.ini
 *)
function GetDownloadUrl (SoftName: String): String;
var
    Bit: String;
begin
    Bit := '';
    if SoftName = 'Cygwin' then
    begin
        if IsWin64 then
        begin
            Bit := '64';
        end else begin
            Bit := '32';
        end;
    end;
    Result := GetIniString(SoftName, SoftName + Bit + 'DownloadUrl',  '', ExpandConstant('{tmp}\{#SetupIni}'));
end;

(**
 * GetInstallerPath
 *   get the path of downloaded installer.
 *)
function GetInstallerPath(SoftName: String): String;
var
    SaveFileName: String;
begin
    SaveFileName := GetIniString(SoftName, SoftName + 'SaveFileName', '', ExpandConstant('{tmp}\{#SetupIni}'));
    Result := ExpandConstant(DownloadDir + '\' + SaveFileName);
end;
