scriptName "LND\functions\TaskFramework\fn_taskSuccessCheck.sqf";
/*
	Author:
		Landric

	Description:
		Determines if the requirements of the current task have been met;
		Requirements are:
			100% of vehicles (LND_opforPriorityTargets) must be disabled (i.e. gun kill, mobility kill, etc.)
			80% of infantry (LND_opforTargets) must be neutralised

	Parameter(s):
		None

	Returns:
		None

	Example Usage:
		call LND_fnc_taskSuccessCheck;	
*/

if(LND_intel >=4) then {
	systemChat "Checking task success...";
	systemChat format ["%1 priority targets still active, %2/%3 other targets still active", { (canFire _x || canMove _x) and ({alive _x} count crew _x) > 0} count LND_opforPriorityTargets, ({alive _x} count LND_opforTargets), LND_totalTargets];
};

if( {(canFire _x || canMove _x) and ({alive _x} count crew _x) > 0} count LND_opforPriorityTargets <= 0) then {

	// Combining these if statements doesn't stop the other from being evaluated (i.e. it will still give a divide-by-zero error)
	if (LND_totalTargets == 0) exitWith {
		["SUCCEEDED"] call LND_fnc_taskCleanup;
	};

	if ( ({alive _x} count LND_opforTargets) / LND_totalTargets < (100-LND_completionPercent)/100 ) exitWith {
		["SUCCEEDED"] call LND_fnc_taskCleanup;
	};
};