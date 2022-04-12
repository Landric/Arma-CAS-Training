scriptName "LND\functions\TaskFramework\fn_taskIntel.sqf";
/*
	Author:
		Landric

	Description:
		Generates an intel briefing (based on global LND_intel level) for the current task, displays it in sideChat, and sets the current task's description

		Intel levels are:
		0 (None) 		- Grid coordinates only, no task marker
		1 (Sparse)		- Grid coordinates, task marker, mission type
		2 (Moderate)	- As above, plus opfor composition/strength, approximate markers on AA positions
		3 (Maximal)		- As above, plus sub tasks/map markers on groups, accurate markers on AA positions
		4 (Debug)		- All of the above, plus real-time map markers for every unit, and additional debug information printed to systemChat

		// TODO: If composition is tied to difficulty, there's no (real) benefit to including it

	Parameter(s):
		Required:
			- _position - position of the task, used to generate grid coordinates
		Optional:
			- _caller 	- the desired "caller" on the radio; can be a group, or a string (e.g. "HQ", "BLU", etc.)

	Returns:
		None

	Example Usage:
		[getMarkerPos "marker_task", "HQ"] call LND_fnc_taskIntel;	
*/


LND_fnc_displayIntel = {
	params ["_intelString"];
	private _caller = param [1, "HQ"];

	{ _caller sideChat _x } forEach (_intelString splitString (toString [13,10]));

	_desc = format ["tsk%1", LND_taskCounter] call BIS_fnc_taskDescription;
	[
		format ["tsk%1", LND_taskCounter],
		[
			format ['"%1"', ((_intelString splitString (toString [13,10])) joinString "<br/>")],
			_desc select 1,
			_desc select 2
		]
	] call BIS_fnc_taskSetDescription;	
};




params ["_position", "_caller"];

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
	_calleeName = format ["%1 1-1", LND_playerCallsign];
};



_intelGrammar = createHashMapFromArray [
	["origin", format ["#greeting#,#intro# over.%1#request.capitalise# #out#.", endl]],

	["greeting", [
		format ["%1, this is %2", _calleeName, _callerName],
		format ["Hello %1, hello %1, this is %2", _calleeName, _callerName],
		format ["Hello %1", _calleeName],
		format ["%1, %2", _calleeName, _callerName]
	]],
	["intro", [
		"",
		" tasking for you,",
		" #CAS# mission for you,",
		" priority tasking for you,"
	]],
	["request", [
		format ["Requesting #CAS# at grid %1", mapGridPosition _position],
		format ["#CAS# #required# at grid %1", mapGridPosition _position]
	]],
	["CAS", ["CAS", "close air support"]],
	["required", ["required", "requested", "needed", "wanted"]],

	["out", [
		"Out",
		"Out to you"
	]]
];

if (LND_intel == 0) exitWith {
	_intelString = [_intelGrammar] call LND_fnc_parseGrammar;
	[_intelString, _caller] call LND_fnc_displayIntel;
	_intelString
};

_intelGrammar set ["origin", format ["#greeting#,#intro# over.%1#request.capitalise#. #mission.capitalise#. #smoke##out#.", endl]];

// Incorporate any task-specific information (that has previously been pushed to the task description) as part of the intel package
_intelGrammar set ["mission", (format ["tsk%1", LND_taskCounter] call BIS_fnc_taskDescription) select 0 select 0]; // Not sure why this requires two "select 0"s?!

private _smokeString = "";
if(not isNull LND_smoke) then {

	private "_smoke";
	private "_friendOrFoe";

	if(count LND_bluforUnits > 1) then {
		_smoke = LND_smokeFriendly;
		_friendOrFoe = "Friendly";
	}
	else {
		_smoke = LND_smokeHostile;
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

	_smokeString = selectRandom [
		format ["%1 positions marked with %2 - say again, %3 positions marked with %4. ", _friendOrFoe, _color, toUpper _friendOrFoe, _secondary],
		format ["Popping %1 on %2 positions. ", _color, toLower _friendOrFoe]
	];
};

_intelGrammar set ["smoke", _smokeString];

_intelString = [_intelGrammar] call LND_fnc_parseGrammar;

[_intelString, _caller] call LND_fnc_displayIntel;

_intelString