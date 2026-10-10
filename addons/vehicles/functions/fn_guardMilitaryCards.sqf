// Replace only the purchase callback on newly rendered extension cards.
// Preview, crew, DLC and model-hover controls remain those created upstream.
disableSerialization;
params ["_display", "_rows", "_classes", ["_categoryKey", "", [""]]];
if (isNull _display || {isNull _rows} || {count _classes == 0}) exitWith {};
{
    private _class = _x getVariable ["className", ""];
    if (_class isEqualTo "" || {!((toLower _class) in _classes)}) then {continue};
    private _parent = ctrlParentControlsGroup _x;
    if (!((ctrlParentControlsGroup _parent) isEqualTo _rows)) then {continue};
    private _catalogue = missionNamespace getVariable ["AVPE_catalogue", []];
    // Custom cards use their selected category. All Rebel uses an available membership.
    private _index = _catalogue findIf {
        toLower (_x select 0) isEqualTo toLower _class && {
            if (_categoryKey != "") then {(_x select 1) isEqualTo _categoryKey}
            else {([_x] call AVPE_fnc_availability) select 0}
        }
    };
    if (_index < 0 && {_categoryKey isEqualTo ""}) then
    {
        _index = _catalogue findIf {toLower (_x select 0) isEqualTo toLower _class};
    };
    if (_index < 0) then {continue};
    private _entry = _catalogue select _index;
    private _status = [_entry] call AVPE_fnc_availability;
    private _atHQ = call AVPE_fnc_atHQ;
    private _originalTooltip = _x getVariable ["AVPE_originalTooltip", ctrlTooltip _x];
    _x setVariable ["AVPE_originalTooltip", _originalTooltip];
    _x setVariable ["AVPE_entry", _entry];
    _x ctrlRemoveAllEventHandlers "ButtonClick";
    _x ctrlAddEventHandler ["ButtonClick", {[_this select 0] call AVPE_fnc_buyMilitaryCard;}];
    _x ctrlEnable ((_status select 0) && {_atHQ});
    _x ctrlSetTooltip ([
        _originalTooltip,
        format ["War tier %1+ | Airport required: %2", _entry select 2, ["No", "Yes"] select (_entry select 3)],
        if (_atHQ) then {_status select 1} else {"Purchase at HQ (within 35m of Petros)."}
    ] joinString (toString [10]));
} forEach (allControls _display);
