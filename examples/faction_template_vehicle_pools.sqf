/*
OPTIONAL: example lines for YOUR OWN Antistasi rebel faction template.
This file is not automatically executed.
_fnc_saveToTemplate is provided by Antistasi while loading that template.
Use these registrations inside that context; do not run them from init.sqf.
If a key is already saved, update its existing pool/registration instead.
Vanilla classnames below demonstrate the format; substitute your own classes.
*/
private _myIFVs = ["B_APC_Wheeled_01_cannon_F"];
private _myTanks = ["B_MBT_01_cannon_F"];
private _myTransportHelis = ["B_Heli_Transport_01_F"];
private _myHeavyTransportVTOLs = ["B_T_VTOL_01_vehicle_F"];
private _myCASVTOLs = ["B_T_VTOL_01_armed_F"];

["vehiclesIFV", _myIFVs] call _fnc_saveToTemplate;
["vehiclesTank", _myTanks] call _fnc_saveToTemplate;
["vehiclesMilitaryHeliTransport", _myTransportHelis] call _fnc_saveToTemplate;
["vehiclesMilitaryVTOLHeavyTransport", _myHeavyTransportVTOLs] call _fnc_saveToTemplate;
["vehiclesMilitaryVTOLCAS", _myCASVTOLs] call _fnc_saveToTemplate;

