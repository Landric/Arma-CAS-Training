scriptName "LND\functions\Utilities\fn_createRect.sqf";
/*
	Author:
		Landric

	Description:
		Creates a line of a given thickness, between two points
		Code inspired by rübe - https://forums.bohemia.net/forums/topic/145174-arma-3-drawline-command-finding-a-method-to-the-madness/

	Parameter(s):
		_this: parameters (start, end, width)

			- required:
				-

			- optional:
				-

	Example:
		[getPos player, getmarkerPos "marker_location", 100] call LND_fnc_createRect;

	Returns:
		[_centre, [_width, _dist, _angle, true]]
*/


params ["_start", "_end", "_width"];

// Calculate line
_dist = sqrt(((_end select 0)-(_start select 0))^2+((_end select 1)-(_start select 1))^2) * 0.5;
_angle = ((_end select 0)-(_start select 0)) atan2 ((_end select 1)-(_start select 1));
_centre = [(_start select 0)+sin(_angle)*_dist,(_start select 1)+cos(_angle)*_dist];

[_centre, [_width, _dist, _angle, true]]
