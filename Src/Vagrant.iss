[Code]
(**---------------------------
 * Vagrant functions
 * --------------------------- *)

(**
 * Vagrant_Exists
 *   check if Vagrant has already been installed
 *)
function Vagrant_Exists(): Boolean;
var
    Params:     String;
    ResultCode: Integer;
begin
    Result := True;
    Params := '--version';
    if not Exec('vagrant', Params, '', SW_SHOW, ewWaitUntilTerminated, ResultCode) then
    begin
        Result := False;
    end;
end;

(**
 * Vagrant_Install
 *   execute Vagrant installer
 *)
procedure Vagrant_Install(InstallerPath: String);
var
    SoftName:    String;
    ExecCommand: String;
    Params:      String;
begin
    SoftName    := 'Vagrant';
    ExecCommand := 'msiexec';
    Params      := '/i ' + AddQuotes(InstallerPath) + ' /qf /norestart ALLUSERS=1';
    ExecOtherInstaller(SoftName, ExecCommand, Params);

    Vagrant_Exists();  // first initialized
end;
