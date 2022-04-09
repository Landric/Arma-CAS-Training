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
//private _roads = param [5, false]; // Whether vics should be spawned on roads

if(intel >= 4) then { systemChat "Spawning OPFOR..."; };

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

		switch(_waypoint select 0) do {
			case "PAT": {
				//[_x, _waypoint select 1, _waypoint select 2] call BIS_fnc_taskPatrol; // Didn't seem to work?
				[_opfor_group] call LND_fnc_doPatrol;
			};

			case "SAD": {
				_op_waypoint = _opfor_group addWaypoint [_waypoint select 1, _waypoint select 2];
				_op_waypoint setWaypointType (_waypoint select 0);
				_opfor_group setCombatMode "RED";
			};

			case "CON": {
				// Deal with convoys below
			};

			default { 
				_op_waypoint = _opfor_group addWaypoint [_waypoint select 1, _waypoint select 2];
				_op_waypoint setWaypointType (_waypoint select 0);
				//throw format ["Unexpected waypoint provided: %1", _waypoint select 0];
			};
		};
	};

	{ //forEach units _opfor_group
		_x addEventHandler ["Killed", {
			params ["_unit", "_killer"];
			
			opfor_targets = opfor_targets - [_unit]; // Unneeded if we only count alive units; then again, this might make that count faster?
			
			if(({alive _x} count units _unit) <= 0) then {
				_t = format ["tsk%1_%2", task_counter, groupId (group _unit)];
				if(_t call BIS_fnc_taskExists) then {
					[_t, "SUCCEEDED"] call BIS_fnc_taskSetState;
				};
			}
			else{
				if(leader group _unit == _unit) then {
					//The leader is dead (long live the leader)
					[(group _unit), _unit] spawn {
						params ["_group", "_prevLeader"];
						waitUntil {
							sleep 1;
							//Checking leader...
							(leader _group != _prevLeader) or isNull _group
						};
						//A new leader has arisen!
						if(not isNull _group) then {
							_t = format ["tsk%1_%2", task_counter, groupId _group];
							if(_t call BIS_fnc_taskExists) then {
								[_t, leader _group] call BIS_fnc_taskSetDestination;
							};
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
	_p = [
		_position,				// centre
		0,						// minDist
		100,					// maxDist
		10,						// objDist
		0,						// waterMode (land)
		0.2,					// maxGrad
		0,						// shoreMode (land)
		_blacklist - ["water"]  // blacklist
	] call BIS_fnc_findSafePos;

	systemChat str _p;
	
	_v = [_p, random 360, _x, east] call BIS_fnc_spawnVehicle;
	_v = _v select 0;
	//_v setUnloadInCombat [false, false];
	
	_v addEventHandler ["Hit", {
		params ["_unit", "_source", "_damage", "_instigator"];
		private "_t";
		if(not canFire _unit and not canMove _unit) then {
			_t = format ["tsk%1_%2", task_counter, groupId (group _unit)];
			if(_t call BIS_fnc_taskExists) then {
				[_t, "SUCCEEDED"] call BIS_fnc_taskSetState;
			};
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
						_t = format ["tsk%1_%2", task_counter, groupId _group];
						if(_t call BIS_fnc_taskExists) then {
							[_t, leader _group] call BIS_fnc_taskSetDestination;
						};
					};
				};
			};
		};
		call LND_fnc_taskSuccessCheck;
	}];

	_v addEventHandler ["Killed", {
		params ["_unit", "_killer", "_instigator", "_useEffects"];
		private "_t";
		if(not canFire _unit and not canMove _unit) then {
			_t = format ["tsk%1_%2", task_counter, groupId (group _unit)];
			if(_t call BIS_fnc_taskExists) then {
				[_t, "SUCCEEDED"] call BIS_fnc_taskSetState;
			};
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
						_t = format ["tsk%1_%2", task_counter, groupId _group];
						if(_t call BIS_fnc_taskExists) then {
							[_t, leader _group] call BIS_fnc_taskSetDestination;
						};
					};
				};
			};
		};
		call LND_fnc_taskSuccessCheck;
	}];

	opfor_priorityTargets pushBack _v;

	if(intel >= 3) then {
		_task = [true, [format ["tsk%1_%2", task_counter, groupId group _v], format ["tsk%1", task_counter]], ["", "Destroy Hostiles", _position], [_v, true], "CREATED", -1, false, "destroy"] call BIS_fnc_taskCreate;
	};
} forEach _vehicles;


if(count _waypoint > 0) then {
	// if(count _waypoint != 3) then { throw format ["Unexpected waypoint passed to spawnOpfor: %1", _waypoint]};

	if((_waypoint select 0) isEqualTo "CON") then {

		private _g = createGroup east;
		{
			_x forceFollowRoad true;
			_x limitSpeed 40;
			_x setConvoySeparation 30;
			[_x] joinSilent _g;
		} forEach opfor_priorityTargets;

		_g setCombatMode "WHITE";
		_g setCombatBehaviour "SAFE";
		_g setFormation "COLUMN";

		_waypoint = _g addWaypoint [_waypoint select 1, _waypoint select 2];
		_waypoint setWaypointType "MOVE";
	};
};