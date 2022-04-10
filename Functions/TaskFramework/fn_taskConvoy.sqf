scriptName "LND\functions\TaskFramework\fn_taskConvoy.sqf";
/*
	Author:
		Landric

	Description:
		Creates a task suitable for CAS

	Parameter(s):
		_this: parameters

			- required:
				-

			- optional:
				-

	Example:
		

	Returns:
		
*/

LND_fnc_generateIntel = {
	
	private _intel = "Enemy convoy moving through the area. Engage and destroy.";

	private _desc = format ["tsk%1", task_counter] call BIS_fnc_taskDescription;
	[
		format ["tsk%1", task_counter],
		[
			_intel,
			_desc select 1,
			_desc select 2
		]
	] call BIS_fnc_taskSetDescription;	
};

params ["_position"];
_position = getPos ([_position] call BIS_fnc_nearestRoad);

if(intel >= 4) then { systemChat "Task type: Convoy" ; };

private _taskIcon = if(intel > 0) then { "destroy" } else { "" };
private _taskTitle = if(intel > 0) then { "Destroy Hostile Convoy" } else { "Close Air Support" };
_task = [true, format ["tsk%1", task_counter], ["", _taskTitle, _position],  objNull, true, -1, true, _taskIcon] call BIS_fnc_taskCreate;

private _vehicles = [];
for "_i" from 0 to 4 do {
	// TODO: Base vics on difficulty
	_vehicles pushback (selectRandom opfor_vehicles_unarmed);
};

_dest = getPos ([[[[_position, 8000]], [[_position, 2000]]] call BIS_fnc_randomPos] call BIS_fnc_nearestRoad);
[
	[],					// no units
	_vehicles, 			// vehicles
	[[_position, 20]],	// position whitelist 
	[],					// position blacklist
	["CON", _dest, 0]	// waypoint		
] call LND_fnc_spawnOpfor;


if(intel >= 2) then { call LND_fnc_generateIntel; };