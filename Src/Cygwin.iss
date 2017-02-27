[Files]
Source: "Src\CygwinAliasSet.sh"; DestDir: "{tmp}";
Source: "Src\chef-zero.bat"; DestDir: "{tmp}";

[Code]
(**---------------------------
 * Cygwin functions
 * --------------------------- *)

(**
 * Cygwin_Exists
 *   check if Cygwin has already been installed
 *)
function Cygwin_Exists(): Boolean;
begin
    Result := RegKeyExists(HKEY_LOCAL_MACHINE, 'SOFTWARE\Cygwin');
end;

(**
 * Cygwin_Install
 *   execute Cygwin installer
 *)
procedure Cygwin_Install(InstallerPath: String);
var
    SoftName:    String;
    ExecCommand: String;
    Params:      String;
    LocalRoot:   String;
begin
    SoftName  := 'Cygwin';
    LocalRoot := ExpandConstant('{pf}\cygwin');

    CreateDir(LocalRoot);
    ExecCommand := LocalRoot + '\cygwinsetup.exe';
    FileCopy(InstallerPath, ExecCommand, False);

    // quiet mode
    // Params  := Params + ' -q';

    // proxy
    if ProxyForms.UseProxyCheckBox.Checked then
    begin
        Params := Params + ' -p ' + ProxyForms.ProxyAddressTextBox.Text + ':' + ProxyForms.ProxyPortTextBox.Text;
    end;

    // packages
    Params := Params + ' -P "rsync,openssh"';

    // repository
    Params := Params + ' -s ' + GetIniString(SoftName, SoftName + 'RepositoryUrl', '', ExpandConstant('{tmp}\{#SetupIni}'));

    // local pacakge dir
    // Params := Params + ' -l "' +  LocalRoot  + '"';

    // execute
    ExecOtherInstaller(SoftName, ExecCommand, Params);
end;

procedure Cygwin_PathSet;
var
    InstalledDir: String;
    ResultCode:   Integer;
begin
    if RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\Cygwin\setup', 'rootdir', InstalledDir) then
    begin
        // set path to use cygwin command in ms-dos prompt
        RegAddEnvironment('Path', InstalledDir, ';');
        RegAddEnvironment('Path', ExpandConstant(InstalledDir + '\bin'), ';');

        // set cdrive symbolyc link
        // Exec(InstalledDir + '\bin\run.exe', InstalledDir + '\bin\bash -l -c "ln -snf /cygdrive/c /c;"', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);

        // set alias to use chef commands in cygwin
        if Exec(ExpandConstant('{sys}\where.exe'), 'chef.bat', '', SW_SHOW, ewWaitUntilTerminated, ResultCode)  then
        begin
            if ResultCode = 0 then
            begin
                ExtractTemporaryFile(ExpandConstant('CygwinAliasSet.sh'));
                FileCopy(ExpandConstant('{tmp}\CygwinAliasSet.sh'), InstalledDir + '\tmp\CygwinAliasSet.sh', False);

                ExtractTemporaryFile(ExpandConstant('chef-zero.bat'));
                FileCopy(ExpandConstant('{tmp}\chef-zero.bat'), InstalledDir + '\tmp\chef-zero.bat', False);

                Exec(InstalledDir + '\bin\run.exe', InstalledDir + '\bin\bash -l /tmp/CygwinAliasSet.sh', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);

            end;
        end;
    end;
end;

