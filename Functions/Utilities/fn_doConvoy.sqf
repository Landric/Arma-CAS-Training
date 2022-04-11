scriptName "LND\functions\Utilities\fn_doConvoy.sqf";
/*
	Author:
		Landric

	Description:
		Tasks an array of (ungrouped) vehicles to form a convoy with a random destination
*/

params ["_vehicles"];

private _g = group (_vehicles select 0);
{
	_x forceFollowRoad true;
	_x limitSpeed 40;
	_x setConvoySeparation 30;
	[_x] joinSilent _g;
} forEach _vehicles;

_g setCombatMode "WHITE";
_g setCombatBehaviour "SAFE";
_g setFormation "COLUMN";

_prevRoad = [getPos leader _g] call BIS_fnc_nearestRoad;
private "_connectedRoad";
private _forceNext = false;
for "_i" from 0 to 1000 do {
	if(count (roadsConnectedTo _prevRoad) > 1) then {
		if ((roadsConnectedTo _prevRoad) select 1 != _prevRoad) then {
			_connectedRoad = (roadsConnectedTo _prevRoad) select 1;
		}
		else{
			_connectedRoad = (roadsConnectedTo _prevRoad) select 0;
		};
		_prevRoad = _connectedRoad;

		if(_i % 50 == 0 || _forceNext) then {
			_waypoint = _g addWaypoint [getPos _connectedRoad, 0];
			_waypoint setWaypointType "MOVE";
			_waypoint setWaypointBehaviour "SAFE";
		};
		_forceNext = count (roadsConnectedTo _prevRoad) > 2;
	}
	else {
		_waypoint = _g addWaypoint [getPos _connectedRoad, 0];
		_waypoint setWaypointType "MOVE";
		_waypoint setWaypointBehaviour "SAFE";
		break
	};
};
