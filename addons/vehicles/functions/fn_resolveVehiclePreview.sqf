/* Resolve the configured editorPreview or an exact-class image in configured
   preview roots. Results are cached locally to this client. */
params [["_class", "", [""]]];
private _key = toLower _class;
private _cache = uiNamespace getVariable ["AVPE_previewCache", []];
private _index = _cache findIf {(_x select 0) isEqualTo _key};
if (_index >= 0) exitWith {(_cache select _index) select 1};

private _cfg = configFile >> "CfgVehicles" >> _class;
if (!isClass _cfg) exitWith {["", "missing", ""]};
private _configured = getText (_cfg >> "editorPreview");
private _candidates = [[_configured, "configured"]];
private _parts = _configured splitString "/\";
{
    private _root = _x;
    if !(_root isEqualType "" && {_root != ""}) then {continue};
    if (count _parts > 0) then
    {
        _candidates pushBack [_root + (_parts select (count _parts - 1)), "relocated"];
    };
    {
        _candidates pushBack [_root + _class + _x, "class-file"];
    } forEach [".jpg", ".JPG", ".paa", ".PAA"];
} forEach (call AVPE_fnc_previewRoots);

private _result = ["", "missing", _configured];
private _seen = [];
{
    _x params ["_path", "_source"];
    private _check = _path != "" && {!(_path in _seen)};
    _seen pushBack _path;
    if (_check && {fileExists _path}) exitWith {_result = [_path, _source, _configured];};
} forEach _candidates;
_cache pushBack [_key, _result];
uiNamespace setVariable ["AVPE_previewCache", _cache];
_result

