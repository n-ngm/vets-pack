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
    Result := RegKeyExists(HKEY_LOCAL_MACHINE, 'SOFTWARE\Oracle\VirtualBox');
end;

(**
 * Virtualbox_Install
 *   execute Virtualbox installer
 *)
procedure Virtualbox_Install(InstallerPath: String);
var
    SoftName:    String;
    ExecCommand: String;
    Params:      String;
begin
    SoftName    := 'VirtualBox';
    ExecCommand := InstallerPath;
    Params      := '-msiparams ALLUSERS=1';
    ExecOtherInstaller(SoftName, ExecCommand, Params);
end;
