scriptName "LND\functions\TaskFramework\fn_spawnOpfor.sqf";
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



params ["_groups", "_vehicles", "_whitelist", "_blacklist"];
private _waypoint = param [4, []]; // Expected [Type, location, radius]

_blacklist append ["water", safeZone];

{ //forEach _groups
	// TODO: Replace with get SAFE pos
	_p = [_whitelist, _blacklist] call BIS_fnc_randomPos; 

	if (_p isEqualTo [0, 0]) then {
		throw "Invalid OPFOR position generated";
	};

	_opfor_group = [_p, east, _x] call BIS_fnc_spawnGroup;
	// TODO: Balance "Defend" missions so that player has enough time to respond before Blufor are wiped out,
	// or enable the line below
	// _opfor_group enableDynamicSimulation true;

	if(count _waypoint > 0) then {
		if(count _waypoint != 3) then { throw format ["Unexpected waypoint passed to spawnOpfor: %1", _waypoint]};

		if(_waypoint select 0 isEqualTo "PAT") then {
			//[_x, _waypoint select 1, _waypoint select 2] call BIS_fnc_taskPatrol; // Didn't seem to work?
			[_opfor_group] call LND_fnc_doPatrol;
		}
		else {
			_op_waypoint = _opfor_group addWaypoint [_waypoint select 1, _waypoint select 2];
			_op_waypoint setWaypointType (_waypoint select 0);
			if((_waypoint select 0) isEqualTo "SAD") then {
				_opfor_group setCombatMode "RED";
			};
		};
	};

	{ //forEach units _opfor_group
		_x addEventHandler ["Killed", {
			params ["_unit", "_killer"];
			
			opfor_targets = opfor_targets - [_unit]; // Unneeded if we only count alive units; then again, this might make that count faster?
			
			if(({alive _x} count units _unit) <= 0) then {
				// TODO: Add a check if this task exists?
				[format ["tsk%1_%2", task_counter, groupId (group _unit)], "SUCCEEDED"] call BIS_fnc_taskSetState;
			}
			else{
				if(leader group _unit == _unit) then {
					//The leader is dead (long live the leader)
					[group _unit, _unit] spawn {
						params ["_group", "_prevLeader"];
						waitUntil {
							sleep 1;
							//Checking leader...
							(leader _group != _prevLeader) or isNull _group
						};
						//A new leader has arisen!
						if(not isNull _group) then {
							[format ["tsk%1_%2", task_counter, groupId _group], leader _group] call BIS_fnc_taskSetDestination;
						};
						
					};
				};
			};
			call LND_fnc_taskSuccessCheck;
		}];
	} forEach units _opfor_group;
	opfor_targets append units _opfor_group;
	
	if(intel >= 3) then {
		_task = [true, [format ["tsk%1_%2", task_counter, groupId _opfor_group], format ["tsk%1", task_counter]], ["", "Destroy Hostiles", _p], [leader _opfor_group, true], "CREATED", -1, false, "destroy"] call BIS_fnc_taskCreate;
	};
} forEach _groups;

{
	// TODO: Use SAFE position
	// TODO: Add "Killed" event handlers
	_v = [_position, random 360, _x, east] call BIS_fnc_spawnVehicle;
	_v = _v select 0;
	//_v setUnloadInCombat [false, false];
	_v addEventHandler ["Hit", {
		params ["_unit", "_source", "_damage", "_instigator"];
		call LND_fnc_taskSuccessCheck;
	}];
	_v addEventHandler ["Killed", {
		params ["_unit", "_killer", "_instigator", "_useEffects"];
		call LND_fnc_taskSuccessCheck;
	}];

	opfor_priorityTargets pushBack _v;

	if(intel >= 3) then {
		_task = [true, [format ["tsk%1_%2", task_counter, groupId group _v], format ["tsk%1", task_counter]], ["", "Destroy Hostiles", _position], [_v, true], "CREATED", -1, false, "destroy"] call BIS_fnc_taskCreate;
	};
} forEach _vehicles;

