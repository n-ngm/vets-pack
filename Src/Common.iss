[Code]
function StrContain(SearchText: String; TargetText: String; Delimiter: String): Integer;
begin
    Result := Pos(Delimiter + SearchText + Delimiter, Delimiter + TargetText + Delimiter);
end;

function GetInstallerSavedPath(FileName: String): String;
begin
    Result := ExpandConstant('{app}') + '\' + ExpandConstant(FileName);
end;

procedure DownloadFile(Url: String; FileName: String; AfterID: Integer);
var
    SavePath: String;
begin
    SavePath := GetInstallerSavedPath(FileName);
    if not FileExists(SavePath) then
    begin
        idpAddFile(Url, ExpandConstant(SavePath));
        idpDownloadAfter(AfterID);
    end;
end;

