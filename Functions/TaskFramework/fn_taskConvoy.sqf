scriptName "LND\functions\TaskFramework\fn_taskConvoy.sqf";
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

// Get road closest to position
// Spawn vehicles - softskin trucks for easy, mraps for medium, apcs for hard
// Pick another point several kilometers away - road (or town?)
// Assign waypoint
// Task fails if convoy ever gets to that waypoint - although I doubt it will