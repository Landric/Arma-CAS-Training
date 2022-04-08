scriptName "LND\functions\Utilities\fn_garrisonBuilding.sqf";
/*
	Author:
		Landric

	Description:
		Garrisons a given building, with a given selection of units

	Parameter(s):
		_this: parameters [location, side, array]

			- required:
				-

			- optional:
				-

	Example:
		[] call LND_fnc_garrisonBuilding;

	Returns:

*/

params ["_building", "_units"];

private _side = param [2, east];


private _positions = _building buildingPos -1;

if(count _positions <= 0) then {
	throw "Not a building, or not enterable!";
};

