scriptName "LND\functions\TaskFramework\fn_taskIntel.sqf";
/*
	Author:
		Landric

	Description:
		Generates an intel briefing (based on global intel level) for the current task
		Intel levels are:
		0 (None) 		- Grid coordinates only, no task marker
		1 (Sparse)		- Grid coordinates, task marker, mission type
		2 (Moderate)	- As above, plus opfor composition/strength, approximate markers on AA positions
		3 (Maximal)		- As above, plus sub tasks/map markers on groups, accurate markers on AA positions
		4 (Debug)		- All of the above, plus precise opfor composition and strength, and real-time map markers for every unit

	Parameter(s):
		_this: parameters

			- required:
				-

			- optional:
				-

	Example:
		

	Returns:		
*/


LND_fnc_intelToTaskDesc = {
	params ["_intelStrings"];
	_desc = format ["tsk%1", task_counter] call BIS_fnc_taskDescription;
	[
		format ["tsk%1", task_counter],
		[
			format ['"%1"', _intelStrings joinString "<br/>"],
			_desc select 1,
			_desc select 2
		]
	] call BIS_fnc_taskSetDescription;	
};




params ["_position", "_caller"];

private _mission = param [2, ""];

private _intelStrings = [];

private "_callerName";
if(typeName _caller isEqualTo "GROUP") then {
	_callerName = _caller call LND_fnc_groupName;
	_caller = leader _caller;
}
else {
	_callerName = switch(_caller) do {
		case "HQ":    {"Crossroad"};
		case "BLU":   {"Broadway"};
		case "OPF":   {"Griffin"};
		case "IND":   {"Phalanx"};
		case "IND_G": {"Slingshot"};
		default       {"Unknown"};
	};
	_caller = [west, _caller];
};

private "_calleeName";
if(isMultiplayer) then {
	_calleeName = format ["%1-Wing", LND_playerCallsign];
}
else {
	_calleeName = format ["%1 1-1", LND_playerCallsign]; // group player call LND_fnc_groupName;
};


_intelStrings pushback (
	(selectRandom [
		format ["%1, this is %2,", _calleeName, _callerName],
		format ["Hello %1, hello %1, this is %2,", _calleeName, _callerName],
		format ["Hello %1,", _calleeName],
		format ["%1, %2,", _calleeName, _callerName]
	]) +
	(selectRandom [
		"",
		" tasking for you,",
		" CAS mission for you,",
		" priority tasking for you,"
	]) +
	" over."
);

_intelStrings pushBack format ["Requesting CAS at grid %1.", mapGridPosition _position];

if (intel == 0) exitWith {
	_intelStrings set [(count _intelStrings)-1, (_intelStrings select ((count _intelStrings)-1)) + (selectRandom [" Out.", " Out to you."])];
	{ _caller sideChat _x } forEach _intelStrings;
	[_intelStrings] call LND_fnc_intelToTaskDesc;
	_intelStrings
};

// if _taskType = DEFEND
if(count blufor_units > 0) then {
	_intelStrings pushback "Friendly troops in need of support.";
}
else{
	private "_s";
	if (count opfor_targets > count opfor_priorityTargets) then {
		_s = "Large concentration of enemy infantry.";
	}
	else {
		_s = "Enemy convoy moving through the area.";
	};

	_intelStrings pushback _s;
};




 



// TODO: This is probably massively over-complicated for very little benefit - might as well just pass in the required line
// tbh this whole function is massively over-complicated for very little benefit....
if(not isNull smoke) then {

	private "_smoke";
	private "_friendOrFoe";

	if(count blufor_units > 1) then {
		_smoke = smokeFriendly;
		_friendOrFoe = "Friendly";
	}
	else {
		_smoke = smokeHostile;
		_friendOrFoe = "Hostile";
	};

	private "_color";
	private "_secondary";
	// TODO: Account for any other colours of smoke

	switch(_smoke) do {
		case "SmokeShellBlue_Infinite": {
			_color = "blue smoke";
			_secondary = "BLUE smoke";
		};
		case "SmokeShellRed_Infinite": {
			_color = "red smoke";
			_secondary = "RED smoke";
		};
		case "B_IRStrobe": {
			_color = "IR strobes";
			_secondary = "strobes";
		};
	};

	_intelStrings pushback (selectRandom [
		format ["%1 positions marked with %2 - say again, %3 positions marked with %4.", _friendOrFoe, _color, toUpper _friendOrFoe, _secondary],
		format ["Popping %1 on %2 positions.", _color, toLower _friendOrFoe]
	]);
};

_intelStrings set [(count _intelStrings)-1, (_intelStrings select ((count _intelStrings)-1)) + (selectRandom [" Out.", " Out to you."])];


{ _caller sideChat _x } forEach _intelStrings;
[_intelStrings] call LND_fnc_intelToTaskDesc;


_intelStrings