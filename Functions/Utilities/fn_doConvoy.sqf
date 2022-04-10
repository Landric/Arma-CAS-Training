scriptName "LND\functions\Utilities\fn_doConvoy.sqf";
/*
	Author:
		Landric

	Description:
		Tasks a group of vehicles to form a convoy

	Parameter(s):
		_this: parameters

			- required:
				-

			- optional:
				-

	Example:


	Returns:
*/

params ["_vehicles"];

//private _g = createGroup east;
{
	_x forceFollowRoad true;
	_x limitSpeed 40;
	_x setConvoySeparation 30;
	//[_x] joinSilent _g;
	_x setCombatMode "WHITE";
	_x setCombatBehaviour "SAFE";
	_wp = group _x addWaypoint [_waypoint select 1, _waypoint select 2];
	_wp setWaypointType "MOVE";
} forEach opfor_priorityTargets;

// _g setCombatMode "WHITE";
// _g setCombatBehaviour "SAFE";
// _g setFormation "COLUMN";

// _waypoint = _g addWaypoint [_waypoint select 1, _waypoint select 2];
// _waypoint setWaypointType "MOVE";

true