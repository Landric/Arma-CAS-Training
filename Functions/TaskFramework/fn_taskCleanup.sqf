scriptName "LND\functions\TaskFramework\fn_taskCleanup.sqf";
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

params ["_state"];

if(!isServer) exitWith { }; // TODO: is this needed? Does it hinder?

if (not (format ["tsk%1", task_counter] call BIS_fnc_taskCompleted)) then {

	[format ["tsk%1", task_counter], _state] call BIS_fnc_taskSetState;	

	{ if(!isPlayer _x) then {deleteVehicle _x }; } forEach allUnits;
	{ deleteVehicle _x } forEach allDead;
	{ if(not (_x in synchronizedObjects v_respawn)) then { deleteVehicle _x; }; } forEach vehicles;
	if(not isNull smoke) then {	deleteVehicle smoke; };

	{
		private "_a";
		_a = toArray _x;
		_a resize 9;
		if (toString _a isEqualTo "marker_aa") then {
			deleteMarker _x;
		};
	} forEach allMapMarkers;

	opfor_targets = [];
	opfor_priorityTargets = [];
	blufor_units = [];

	[] spawn {
		sleep 3;
		call LND_fnc_newTask;
	};
};