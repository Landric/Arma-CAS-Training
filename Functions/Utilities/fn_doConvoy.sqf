scriptName "LND\functions\Utilities\fn_doConvoy.sqf";
/*
	Author:
		Landric

	Description:
		Tasks an array of vehicles, groups them together, and attempts to force them along the closest road
		NOTE: This is an extremely naive implementation, and is suitable for CAS strikes, but probably not much else

	Parameter(s):
		_vehicles 	- array of vehicles

	Returns:
		None

	Example Usage:
		_v1 = [getMarkerPos "marker_v1", 100, "O_Truck_03_fuel_F", east] call BIS_fnc_spawnVehicle select 0;
		_v1 = [getMarkerPos "marker_v2", 100, "O_Truck_02_Ammo_F", east] call BIS_fnc_spawnVehicle select 0;
		[_v1, _v2] call LND_fnc_doConvoy;
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
