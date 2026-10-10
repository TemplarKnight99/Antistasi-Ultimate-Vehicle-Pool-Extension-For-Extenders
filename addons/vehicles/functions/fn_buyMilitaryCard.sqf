// Recheck requirements at the moment of purchase; native code takes payment.
disableSerialization;
params ["_button"];
if (isNull _button) exitWith {};
if (!call AVPE_fnc_atHQ) exitWith {hint "Military vehicles must be purchased at HQ.";};
private _entry = _button getVariable ["AVPE_entry", []];
if (count _entry < 4) exitWith {};
private _status = [_entry] call AVPE_fnc_availability;
if (!(_status select 0)) exitWith
{
    hint (_status select 1);
    // Do not rebuild/delete the card from its own ButtonClick event.
    _button ctrlEnable false;
};
closeDialog 2;
[_entry select 0] spawn A3A_fnc_addFIAveh;
