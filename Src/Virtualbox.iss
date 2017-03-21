[Code]
(**---------------------------
 * VirtualBox functions
 * --------------------------- *)

(**
 * Virtualbox_Exists
 *   check if VirtualBox has already been installed
 *)
function Virtualbox_Exists(): Boolean;
begin
    Result := RegKeyExists(GetHKLM, 'SOFTWARE\Oracle\VirtualBox');
end;

(**
 * Virtualbox_Install
 *   execute Virtualbox installer
 *)
procedure Virtualbox_Install(InstallerPath: String);
var
    SoftName:      String;
    InstallerFile: String;
    ExtractDir:    String;
    ExtractFile:   String;

    ExecCommand:   String;
    Params:        String;

    ResultCode:    Integer;
begin
    SoftName    := 'VirtualBox';

    if CustomizeForms.AutoInstallCheckBox.Checked then
    begin
        InstallerFile := ExtractFileName(InstallerPath);
        ExtractDir    := ExpandConstant('{tmp}\VirtualBox');
        ExtractFile   := RegexReplace(InstallerFile, '-r$1-MultiArch_x86.msi', '-([0-9]+)-Win.exe$', True);

        if not DirExists(ExtractDir) then
        begin
            CreateDir(ExtractDir);
        end;
        ExecOtherInstaller(SoftName, InstallerPath, '--silent --extract -path "' + ExtractDir +'"');

        if FileExists(ExtractDir + '\' + ExtractFile) then
        begin
        DebugBox('aruyo');
            ExecCommand := 'msiexec';
            Params      := '/i ' + AddQuotes(ExtractDir + '\' + ExtractFile) + '/passive /norestart ALLUSERS=1';
        end else begin
            ExecCommand := InstallerPath;
            Params      := '--silent -msiparams ALLUSERS=1';
        end;
    end else begin
        ExecCommand := InstallerPath;
        Params      := '-msiparams ALLUSERS=1';
    end;

    ExecOtherInstaller(SoftName, ExecCommand, Params);
end;
