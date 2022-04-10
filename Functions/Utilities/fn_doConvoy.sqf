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

private _g = createGroup east;
{
	_x forceFollowRoad true;
	_x limitSpeed 40;
	_x setConvoySeparation 30;
	[_x] joinSilent _g;
} forEach _vehicles;

_g setCombatMode "WHITE";
_g setCombatBehaviour "SAFE";
_g setFormation "COLUMN";

_g selectLeader (_vehicles select 0);

_waypoint = _g addWaypoint [_waypoint select 1, _waypoint select 2];
_waypoint setWaypointType "MOVE";

true