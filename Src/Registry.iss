{ --- Registry Utility Functions --- }
[Code]
function RegStringPosition(RootKey: Integer; SubKeyName: String; TargetKey: String; TargetValue: String; Delimiter: String): Integer;
var
    OrigValue: String;
begin
    if not RegQueryStringValue(RootKey, SubKeyName, TargetKey, OrigValue) then
    begin
        Result := 0;
        exit;
    end;
    // Pos() returns 0 if not found
    Result := Pos(Delimiter + TargetValue + Delimiter, Delimiter + OrigValue + Delimiter) ;
end;

function RegAddStringValue(RootKey: Integer; SubKeyName: String; TargetKey: String; TargetValue: String; Delimiter: String): Boolean;
var
    OrigValue: String;
begin
    { if already set, then return true }
    if (RegStringPosition(RootKey, SubKeyName, TargetKey, TargetValue, Delimiter) > 0) then
    begin
        Result := True;
        exit;
    end;
    { if query failed, create }
    if not RegQueryStringValue(RootKey, SubKeyName, TargetKey, OrigValue) then
    begin
        Result := RegWriteStringValue(RootKey, SubKeyName, TargetKey, TargetValue);
        exit;
    end;
    { add string value }
    Result := RegWriteStringValue(RootKey, SubKeyName, TargetKey, ExpandConstant(OrigValue + Delimiter + TargetValue));
end;

function RegRemoveStringValue(RootKey: Integer; SubKeyName: String; TargetKey: String; TargetValue: String; Delimiter: String): Boolean;
var
    OrigValue: String;
begin
    { if query failed, then return false }
    if not RegQueryStringValue(RootKey, SubKeyName, TargetKey, OrigValue) then
    begin
        Result := False;
        exit;
    end;
    { if not exists, then return true }
    if (RegStringPosition(RootKey, SubKeyName, TargetKey, TargetValue, Delimiter) = 0) then
    begin
        Result := True;
        exit;
    end;

    StringChange(OrigValue, TargetValue, '' );
    StringChange(OrigValue, Delimiter + Delimiter, Delimiter);
    Result := RegWriteStringValue(RootKey, SubKeyName, TargetKey, OrigValue);
end;

function NeedsAddPath(Param: String): boolean;
begin
    Result := RegStringPosition(HKEY_LOCAL_MACHINE, '{#HKLM_EnvKey}', 'Path', Param, ';') = 0;
end;

