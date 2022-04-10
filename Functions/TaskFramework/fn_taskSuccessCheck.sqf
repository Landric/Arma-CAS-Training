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

if(intel >=4) then {
	systemChat "Checking task success...";
	systemChat format ["%1 priority targets still active, %2/%3 other targets still active", {canFire _x || canMove _x} count opfor_priorityTargets, ({alive _x} count opfor_targets), totalTargets];
};

if( ({canFire _x || canMove _x} count opfor_priorityTargets <= 0) and ( ({alive _x} count opfor_targets) / totalTargets < (100-completionPercent)/100 ) ) then {
	["SUCCEEDED"] call LND_fnc_taskCleanup;
};