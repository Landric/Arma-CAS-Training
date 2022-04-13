scriptName "LND\functions\TaskFramework\fn_spawnOpfor.sqf";
/*
	Author:
		Landric

	Description:
		Spawns a provided set of OPFOR units around a particular position, and optionally provides them a (custom) (set of) waypoint(s)

	Parameter(s):
		Required:
			_groups		- array of infantry group configs
			_vehicles	- array of vehicle classnames
			_whitelist	- array of allowed areas e.g. [center, radius] or [center, [a, b, angle, rect]]
			_blacklist	- array of disallowed areas
		Optional:
			_waypoint 	- array of [waypoint type, location, radius]; type can also include "PAT" (for patrols) or "CON" (for convoys)
			_spawnOnRoad- bool indicating whether vehicles should only be spawned on roads
	
	Returns:
		None

	Example Usage:
		[
			[(configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "Infantry" >> "OIA_InfAssault")],
			["O_LSV_02_armed_F", "O_LSV_02_armed_F"],
			[[getMarkerPos "marker_opfor", 200]],
			[[getPos player, 200]],
			["PAT", getMarkerPos "marker_opfor", 250]
		] call LND_fnc_spawnOpfor;
*/

params ["_groups", "_vehicles", "_whitelist", "_blacklist"];
private _waypoint = param [4, []]; // Expected [type, location, radius]
private _spawnOnRoad = param [5, false]; // Whether vics should be spawned on roads

if(LND_intel >= 4) then { systemChat "Spawning OPFOR..."; };

_blacklist append ["water", LND_safeZone];

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
				[_opfor_group, _waypoint select 1, _waypoint select 2] call LND_fnc_doPatrol;
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
			
			if(LND_intel >=4) then { systemChat format ["Unit %1 KILLED by %2", _unit, _killer]; };

			LND_opforTargets = LND_opforTargets - [_unit]; // Unneeded if we only count alive units; then again, this might make that count faster?
			
			if(({alive _x} count units _unit) <= 0) then {
				_t = format ["tsk%1_%2", LND_taskCounter, groupId (group _unit)];
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
							_t = format ["tsk%1_%2", LND_taskCounter, groupId _group];
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
	LND_opforTargets append units _opfor_group;
	
	if(LND_intel >= 3) then {
		_task = [true, [format ["tsk%1_%2", LND_taskCounter, groupId _opfor_group], format ["tsk%1", LND_taskCounter]], ["", "Destroy Hostiles", _p], [leader _opfor_group, true], "CREATED", -1, false, "destroy"] call BIS_fnc_taskCreate;
	};
} forEach _groups;


private "_roadStart";
if(_spawnOnRoad) then {
	_nearRoads = (getPos ((_whitelist select 0) call BIS_fnc_nearestRoad)) nearRoads 200;
	if(count _nearRoads > 0) then
	{
		_roadStart = _nearRoads select 0;
	}
	else {
		throw "No nearby road found!";
	};
};

private _usedRoadSegments = [];
{   // forEach _vehicles;
	private "_spawnPos";
	private "_spawnDir";
	if(_spawnOnRoad) then {

		_road = _roadStart;
		_connectedRoad = (roadsConnectedTo _road) select 0;
		while {_road in _usedRoadSegments} do {
			if(count (roadsConnectedTo _road) <= 1) then {
				throw "Not enough road!";
			};
			_road = _connectedRoad;
			_connectedRoad = (roadsConnectedTo _road) select 0;
		};
		
		_usedRoadSegments pushBack _road;
		_spawnPos = getPos _road;
		_spawnDir = [_connectedRoad, _road] call BIS_fnc_DirTo;
	}
	else {
		_centre = (_whitelist select 0) select 0;
		_maxDist = (_whitelist select 0) select 1;
		_spawnPos = [
			_centre,				// centre
			0,						// minDist
			_maxDist,				// maxDist
			10,						// objDist
			0,						// waterMode (land)
			0.2,					// maxGrad
			0,						// shoreMode (land)
			_blacklist - ["water"]  // blacklist
		] call BIS_fnc_findSafePos;
		_spawnDir = random 360;
	};

	_v = [_spawnPos, _spawnDir, _x, east] call BIS_fnc_spawnVehicle;
	_v = _v select 0;
	//_v setUnloadInCombat [false, false];
	
	_v addEventHandler ["Hit", {
		params ["_unit", "_source", "_damage", "_instigator"];

		if(LND_intel >=4) then { systemChat format ["Vehicle %1 HIT by %2", _unit, _instigator]; };
		[_unit] spawn {
			params ["_unit"];
			sleep 3; // Wait a moment to see if the vehicle is disabled
			if(LND_intel >=4) then { systemChat "Checking if disabled...."; };
			if((not canFire _unit) or (not canMove _unit) or {alive _x} count crew _unit <= 0 ) then {
				if(LND_intel >=4) then { systemChat "Vehicle disabled!"; };
				private _t = format ["tsk%1_%2", LND_taskCounter, _unit];
				if(_t call BIS_fnc_taskExists) then {
					[_t, "SUCCEEDED"] call BIS_fnc_taskSetState;
				};
				call LND_fnc_taskSuccessCheck;
			}
			else{
				if(LND_intel >=4) then { systemChat "Vehicle not disabled!"; };
			};
		};
	}];

	_v addEventHandler ["Killed", {
		params ["_unit", "_killer", "_instigator", "_useEffects"];
		if(LND_intel >=4) then { systemChat format ["Vehicle %1 KILLED by %2", _unit, _killer]; };
		private	_t = format ["tsk%1_%2", LND_taskCounter, _unit];
		if(_t call BIS_fnc_taskExists) then {
			[_t, "SUCCEEDED"] call BIS_fnc_taskSetState;
		};
		call LND_fnc_taskSuccessCheck;
	}];

	LND_opforPriorityTargets pushBack _v;

	// While convoys are unpredictable, force task markers for all vehicles in convoy at all but the lowest intel level
	// TODO: Remove once fixed
	if(LND_intel >= 3 or (LND_intel >= 1 and ((_waypoint select 0) isEqualTo "CON"))) then {
		_task = [true, [format ["tsk%1_%2", LND_taskCounter, _v], format ["tsk%1", LND_taskCounter]], ["", "Destroy Hostiles", _position], [_v, true], "CREATED", -1, false, "destroy"] call BIS_fnc_taskCreate;
	};

	if(count _waypoint > 0) then {
		if((_waypoint select 0) isEqualTo "SAD") then {
			_op_waypoint = _x addWaypoint [_waypoint select 1, _waypoint select 2];
			_op_waypoint setWaypointType (_waypoint select 0);
			_x setCombatMode "RED";
		};
	};
} forEach _vehicles;

if(count _waypoint > 0) then {
	if((_waypoint select 0) isEqualTo "CON") then {
		[LND_opforPriorityTargets] call LND_fnc_doConvoy;
	};
};