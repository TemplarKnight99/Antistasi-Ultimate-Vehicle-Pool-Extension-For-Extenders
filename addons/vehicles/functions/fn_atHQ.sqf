// Evaluate dynamically so moving HQ does not leave an action at the old position.
if (!hasInterface || {isNull player} || {!alive player}) exitWith {false};
if ((missionNamespace getVariable ["AVPE_catalogue", []]) isEqualTo []) exitWith {false};
private _petros = missionNamespace getVariable ["petros", objNull];
private _side = missionNamespace getVariable ["teamPlayer", sideUnknown];
!isNull _petros && {player distance2D _petros < 35}
    && {side group player isEqualTo _side}
    && {player isEqualTo (player getVariable ["owner", player])}
