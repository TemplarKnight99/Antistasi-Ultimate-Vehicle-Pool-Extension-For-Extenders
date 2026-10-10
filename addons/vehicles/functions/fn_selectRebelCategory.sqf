// Use the current upstream card renderer with a category supplied by our adapter.
disableSerialization;
params ["_display", "_key"];
if (isNull _display || {!(_display getVariable ["AVPE_integrated", false])}) exitWith {};
private _panel = _display displayCtrl 7191;
private _rows = _display displayCtrl 7192;
if (isNull _panel || {isNull _rows}) exitWith {};

_panel ctrlShow false;
// The selector is a dropdown outside this group. Never delete a calling card.
{
    if ((ctrlParentControlsGroup _x) isEqualTo _rows) then {ctrlDelete _x;};
} forEach (allControls _display);
["vehicles", [7191, 7192, "AVPE:" + _key]] call A3A_fnc_buyVehicleTabs;
[_display] call AVPE_fnc_repairVehiclePreviews;
private _classes = (missionNamespace getVariable ["AVPE_catalogue", []]) select {(_x select 1) isEqualTo _key};
[_display, _rows, _classes apply {toLower (_x select 0)}, _key] call AVPE_fnc_guardMilitaryCards;

{_x ctrlShow false;} forEach (_display getVariable ["AVPE_nativePanels", []]);
private _preview = _display getVariable ["AVPE_nativePreview", controlNull];
if (!isNull _preview) then {_preview ctrlShow false;};
_display setVariable ["AVPE_selectedRebelCategory", _key];
_panel ctrlShow true;
