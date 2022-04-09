scriptName "LND\functions\TaskFramework\fn_taskSuccessCheck.sqf";
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

if({canFire _x || canMove _x} count opfor_priorityTargets <= 0 and (({alive _x} count opfor_targets) / totalTargets < (100-completionPercent)/100)) then {
	["SUCCEEDED"] call LND_fnc_taskCleanup;
};