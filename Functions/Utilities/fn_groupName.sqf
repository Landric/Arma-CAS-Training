scriptName "LND\functions\Utilities\fn_groupName.sqf";
/*
	Author:
		Landric

	Description:
		Returns a group's name, truncating the side information

	Parameter(s):
		_this: parameters [group]

			- required:
				-

			- optional:
				-

	Example:
		[group player] call LND_fnc_groupName;

	Returns:
		String - group name
*/


params ["_group"];

[format ["%1", _group], 2] call BIS_fnc_trimString