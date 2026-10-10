// Append individual categories only to the Rebel dropdown, once per rebuild.
disableSerialization;
params ["_display"];
if (isNull _display || {!(_display getVariable ["AVPE_integrated", false])}) exitWith {};
private _combo = _display getVariable ["AVPE_nativeCombo", controlNull];
if (isNull _combo || {lbSize _combo == 0}) exitWith {};
if ((_combo lbText 0) != localize "STR_antistasi_dialogs_vehicle_tab_reball") exitWith {};

private _existing = [];
private _existingLabels = [];
for "_i" from 0 to (lbSize _combo - 1) do
{
    _existing pushBack (_combo lbData _i);
    _existingLabels pushBack (_combo lbText _i);
};
private _byLabel = createHashMap;
{
    _x params ["_key", "_label"];
    private _marker = "AVPE:" + _key;
    if (!(_marker in _existing) && {_label in _existingLabels}) then
    {
        diag_log format ["[AVPE Vehicles] Category label already used by the loaded menu, skipped: %1", _label];
        continue;
    };
    _byLabel set [_label, _key];
    if !(_marker in _existing) then
    {
        private _index = _combo lbAdd _label;
        _combo lbSetData [_index, _marker];
        _combo lbSetValue [_index, 1000 + _forEachIndex];
        _existing pushBack _marker;
        _existingLabels pushBack _label;
    };
} forEach (call AVPE_fnc_categories);
_display setVariable ["AVPE_rebelLabels", _byLabel];
