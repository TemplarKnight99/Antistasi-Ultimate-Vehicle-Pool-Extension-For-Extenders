/* Restore exact vehicle images on native purchase cards, including All Rebel.
   Runs after rendering, not from a card's own event. Purchase handlers stay put. */
disableSerialization;
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {};
private _controls = allControls _display;
// Pair pictures and buttons by their actual parent card, without copied IDCs.
{
    if ((ctrlClassName _x) isEqualTo "A3A_Picture") then
    {
        private _card = ctrlParentControlsGroup _x;
        if (!isNull _card) then {_card setVariable ["AVPE_previewPicture", _x];};
    };
} forEach _controls;

private _report = _display getVariable ["AVPE_previewRepairs", []];
{
    private _class = _x getVariable ["className", ""];
    if (_class isEqualTo "" || {_x getVariable ["AVPE_previewChecked", false]}) then {continue};
    private _card = ctrlParentControlsGroup _x;
    if (isNull _card) then {continue};
    private _picture = _card getVariable ["AVPE_previewPicture", controlNull];
    if (isNull _picture) then {continue};

    private _resolved = [_class] call AVPE_fnc_resolveVehiclePreview;
    _resolved params ["_path", "_source", "_configured"];
    _x setVariable ["AVPE_previewChecked", true];
    if (_source isEqualTo "configured") then {continue};
    if ((_report findIf {toLower (_x select 0) isEqualTo toLower _class}) < 0) then
    {
        _report pushBack [_class, _source, _configured, _path];
        diag_log format ["[AVPE Vehicles] Preview %1: %2; configured '%3'; resolved '%4'.", _class, _source, _configured, _path];
    };
    if (_path isEqualTo "") then {continue};

    // The native renderer attached model-hover handlers for the missing image.
    // Remove those two handlers so hovering cannot hide the recovered JPG/PAA.
    _x ctrlRemoveAllEventHandlers "MouseEnter";
    _x ctrlRemoveAllEventHandlers "MouseExit";
    _picture ctrlSetText _path;
    _picture ctrlShow true;
    _picture ctrlCommit 0;
} forEach _controls;
_display setVariable ["AVPE_previewRepairs", _report];
