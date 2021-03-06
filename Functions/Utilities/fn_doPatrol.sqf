scriptName "LND\functions\Utilities\fn_doPatrol.sqf";
/*
	Author:
		Landric

	Description:
		Tasks a group with patrolling an area, in SAFE stance

	Parameter(s):
		Required:
			_group 		- the group to be sent on patrol
		Optional:
			_position 	- the position to centre the patrol around (default: group leader's position)
			_radius 	- the distance allowed to travel from _position (default: 150)
			_waypoints 	- the number of waypoints to generate (default: 5)

	Returns:
		None

	Example Usage:
		[_myGroup] call LND_fnc_doPatrol;	
*/

params ["_group"];
private _position = param [1, getPos leader _group];
private _radius = param [2, 150];
private _waypoints = param [3, 5];

_group setFormation "COLUMN";
_group setCombatMode "WHITE";
_group setCombatBehaviour "SAFE";

for "_i" from 0 to _waypoints do {
	_wp = _group addWaypoint [_position, _radius];
    _wp setWaypointType "MOVE";
    _wp setWaypointBehaviour "SAFE";
};

_wp = _group addWaypoint [getPos leader _group, 5];
_wp setWaypointType "CYCLE";
_wp setWaypointBehaviour "SAFE";

true