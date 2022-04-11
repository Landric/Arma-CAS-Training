scriptName "LND\functions\TaskFramework\fn_taskIntel.sqf";
/*
	Author:
		Landric

	Description:
		Generates an intel briefing (based on global LND_intel level) for the current task
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


LND_fnc_displayIntel = {
	params ["_intelStrings"];
	private _caller = param [1, [west, "HQ"]];

	{ _caller sideChat _x } forEach _intelStrings;

	_desc = format ["tsk%1", LND_taskCounter] call BIS_fnc_taskDescription;
	[
		format ["tsk%1", LND_taskCounter],
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

if (LND_intel == 0) exitWith {
	_intelStrings set [(count _intelStrings)-1, (_intelStrings select ((count _intelStrings)-1)) + (selectRandom [" Out.", " Out to you."])];
	[_intelStrings, _caller] call LND_fnc_displayIntel;
	_intelStrings
};


// Incorporate any task-specific information (that has previously been pushed to the task description)
// as part of the intel package
_desc = (format ["tsk%1", LND_taskCounter] call BIS_fnc_taskDescription) select 0 select 0; // Not sure why this requires two "select 0"s?!
if(_desc isNotEqualTo "") then {
	_intelStrings pushback _desc;
};



// TODO: This is probably massively over-complicated for very little benefit - might as well just pass in the required line
// tbh this whole function is massively over-complicated for very little benefit....
if(not isNull LND_smoke) then {

	private "_LND_smoke";
	private "_friendOrFoe";

	if(count LND_bluforUnits > 1) then {
		_LND_smoke = LND_smokeFriendly;
		_friendOrFoe = "Friendly";
	}
	else {
		_LND_smoke = LND_smokeHostile;
		_friendOrFoe = "Hostile";
	};

	private "_color";
	private "_secondary";
	// TODO: Account for any other colours of smoke

	switch(_LND_smoke) do {
		case "LND_smokeShellBlue_Infinite": {
			_color = "blue LND_smoke";
			_secondary = "BLUE LND_smoke";
		};
		case "LND_smokeShellRed_Infinite": {
			_color = "red LND_smoke";
			_secondary = "RED LND_smoke";
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


[_intelStrings, _caller] call LND_fnc_displayIntel;


_intelStrings