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

	private _convoyWaypoints = waypoints (group (LND_opforPriorityTargets select 0));
	
	private _intelString = format ["Enemy convoy moving through the area. Final destination believed to be in the vicinity of grid %1. Engage and destroy.",
		mapGridPosition (getWPPos (_convoyWaypoints select ((count _convoyWaypoints)-1)))
	];

	private _desc = format ["tsk%1", LND_taskCounter] call BIS_fnc_taskDescription;
	[
		format ["tsk%1", LND_taskCounter],
		[
			_intelString,
			_desc select 1,
			_desc select 2
		]
	] call BIS_fnc_taskSetDescription;	
};

params ["_position"];

if(LND_intel >= 4) then { systemChat "Task type: Convoy" ; };

private _taskIcon = if(LND_intel > 0) then { "destroy" } else { "" };
private _taskTitle = if(LND_intel > 0) then { "Destroy Hostile Convoy" } else { "Close Air Support" };
_task = [true, format ["tsk%1", LND_taskCounter], ["", _taskTitle, _position],  objNull, true, -1, true, _taskIcon] call BIS_fnc_taskCreate;

private _vehicles = [selectRandom LND_opforVehiclesHeavy];
for "_i" from 0 to 4 do {
	// TODO: Base vics on difficulty
	_vehicles pushback (selectRandom LND_opforVehiclesUnarmed);
};


_vehicles = [];
switch(LND_convoyDifficulty) do {
	// Disabled
	case 0: { throw "Convoy tasks are disabled - why are we generating one?!"; };
	// Easy - unarmed only
	case 1: { for "_i" from 0 to 2 do {	_vehicles pushback (selectRandom LND_opforVehiclesUnarmed); }; };
	// Medium - unarmed supported by light escort
	case 2: {
		_vehicles pushback selectRandom LND_opforVehiclesLight;
		for "_i" from 0 to 2 do {	_vehicles pushback (selectRandom LND_opforVehiclesUnarmed); };
		_vehicles pushback selectRandom LND_opforVehiclesLight;
	};
	// Hard - armoured convoy
	case 3: { for "_i" from 0 to 3 do {	_vehicles pushback (selectRandom LND_opforVehiclesMedium); }; };
	// Extreme - armoured convoy, led by heavy armour, with AAA support
	case 4: {
		_vehicles pushback selectRandom LND_opforVehiclesHeavy;
		for "_i" from 0 to 2 do {	_vehicles pushback (selectRandom LND_opforVehiclesMedium); };
		_mobileAAA = LND_opforAAA select { not (_x isKindOf "Turret") };
		if((count _mobileAAA > 0) and (LND_aaaThread > 0)) then {
			_vehicles pushback (selectRandom _mobileAAA);
		}
		else{
			_vehicles pushback selectRandom LND_opforVehiclesHeavy;
		};
	};
	default { throw format ["Unexpected Convoy task difficulty: %1", LND_convoyDifficulty]; };
};


_convoyStartPos = getPos ([_position, 20000] call BIS_fnc_nearestRoad);
[
	[],							// no units
	_vehicles,	 				// vehicles
	[[_convoyStartPos, 20]],	// position whitelist 
	[],							// position blacklist
	["CON", objNull, 0],		// waypoint
	true						// spawnOnRoad
] call LND_fnc_spawnOpfor;


if(LND_intel >= 1) then {
	[format ["tsk%1", LND_taskCounter], [LND_opforPriorityTargets select 0], true] call BIS_fnc_taskSetDestination;
	call LND_fnc_generateIntel;
};