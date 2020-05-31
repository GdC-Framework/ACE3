#include "script_component.hpp"
/*
 * Author: Garth 'L-H' de Wet, Ruthberg, edited by commy2 for better MP and eventual AI support, esteldunedain
 * Continue process of digging trench.
 *
 * Arguments:
 * 0: trench <OBJECT>
 * 1: unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [TrenchObj, ACE_player] call ace_trenches_fnc_continueDiggingTrench
 *
 * Public: No
 */

params ["_trench", "_unit"];
TRACE_2("continueDiggingTrench",_trench,_unit);

private _actualProgress = _trench getVariable [QGVAR(progress), 1];
if(_actualProgress == 1) exitWith {};

// Mark trench as being worked on
_trench setVariable [QGVAR(digging), true, true];

private _digTime = missionNamespace getVariable [getText (configFile >> "CfgVehicles" >> (typeof _trench) >> QGVAR(diggingDuration)), 20];
private _digTimeLeft = _digTime * (1 - _actualProgress);

private _placeData = _trench getVariable [QGVAR(placeData), [[], []]];
_placeData params ["_basePos", "_vecDirAndUp"];

private _trenchId = _unit getVariable [QGVAR(isDiggingId), -1];
if(_trenchId < 0) then {
    _trenchId = GVAR(trenchId);
    _unit setVariable [QGVAR(isDiggingId), _trenchId, true];
    GVAR(trenchId) = GVAR(trenchId) + 1;
};

// Create progress bar
private _fnc_onFinish = {
    (_this select 0) params ["_unit", "_trench"];
    _unit setVariable [QGVAR(isDiggingId), -1, true];
    _trench setVariable [QGVAR(digging), false, true];

    // Save progress global
    private _progress = _trench getVariable [QGVAR(progress), 0];
    _trench setVariable [QGVAR(progress), _progress, true];

    // Reset animation
    [_unit, "", 1] call EFUNC(common,doAnimation);
};
private _fnc_onFailure = {
    (_this select 0) params ["_unit", "_trench"];
    _unit setVariable [QGVAR(isDiggingId), -1, true];
    _trench setVariable [QGVAR(digging), false, true];

    // Save progress global
    private _progress = _trench getVariable [QGVAR(progress), 0];
    _trench setVariable [QGVAR(progress), _progress, true];

    // Reset animation
    [_unit, "", 1] call EFUNC(common,doAnimation);
};
private _fnc_condition = {
    (_this select 0) params ["_unit"];
    if (EGVAR(advanced_fatigue,anReserve) <= 0) exitWith {false};
    "ACE_EntrenchingTool" in (_unit call EFUNC(common,uniqueItems))
};
[(_digTimeLeft + 0.5), [_unit, _trench], _fnc_onFinish, _fnc_onFailure, localize LSTRING(DiggingTrench), _fnc_condition] call EFUNC(common,progressBar);

if(_actualProgress == 0) then {
    [_unit, _trench, _trenchId, _basePos vectorDiff [0, 0, 1.0], _vecDirAndUp, _actualProgress] call FUNC(setTrenchPlacement);

    //Remove grass
    {
        private _trenchGrassCutter = createVehicle ["Land_ClutterCutter_medium_F", [0, 0, 0], [], 0, "NONE"];
        private _cutterPos = AGLToASL (_trench modelToWorld _x);
        _cutterPos set [2, getTerrainHeightASL _cutterPos];
        _trenchGrassCutter setPosASL _cutterPos;
        deleteVehicle _trenchGrassCutter;
    } foreach getArray (configFile >> "CfgVehicles" >> (typeof _trench) >> QGVAR(grassCuttingPoints));
};

private _progressLeft = (_actualProgress * 10) + 1;

for "_i" from _progressLeft to 10 do {
    private _vectorDiffZ = 1 - (_i / 10);
    private _delay = _digTime * ((_i / 10) - _actualProgress);
    private _progress = _i / 10;
    [DFUNC(setTrenchPlacement), [_unit, _trench, _trenchId, _basePos vectorDiff [0, 0, _vectorDiffZ], _vecDirAndUp, _progress], _delay] call CBA_fnc_waitAndExecute;
};

// Add management of fatigue
[{
    params ["_args", "_handle"];
    _args params ["_trench", "_unit", "_digTime"];
    
    private _actualProgress = _trench getVariable [QGVAR(progress), 0];

    if (
        !(_trench getVariable [QGVAR(digging), false])
    ) exitWith {
        [_handle] call CBA_fnc_removePerFrameHandler;
        _trench setVariable [QGVAR(digging), false, true];
    };

    if (_actualProgress >= 1) exitWith {
        [_handle] call CBA_fnc_removePerFrameHandler;
    };

    //Fatigue impact - inherited from GRAD Trenches mod
    //EGVAR(advanced_fatigue,anReserve) = (EGVAR(advanced_fatigue,anReserve) - ((_digTime/12) * GVAR(buildFatigueFactor))) max 0;
    //EGVAR(advanced_fatigue,anFatigue) = (EGVAR(advanced_fatigue,anFatigue) + (((_digTime/12) * GVAR(buildFatigueFactor))/1200)) min 1;
    EGVAR(advanced_fatigue,anReserve) = (EGVAR(advanced_fatigue,anReserve) - (2 * GVAR(buildFatigueFactor))) max 0;
    EGVAR(advanced_fatigue,anFatigue) = (EGVAR(advanced_fatigue,anFatigue) + ((2 * GVAR(buildFatigueFactor))/1200)) min 1;


    // Stop PerFrameHandler when fatigue = 0
    if (EGVAR(advanced_fatigue,anReserve) <= 0) exitWith {
        [_handle] call CBA_fnc_removePerFrameHandler;
        _unit setVariable [QGVAR(isDiggingId), -1, true];
        _trench setVariable [QGVAR(digging), false, true];

        // Save progress global
        private _progress = _trench getVariable [QGVAR(progress), 0];
        _trench setVariable [QGVAR(progress), _progress, true];

        // Reset animation
        [_unit, "", 1] call EFUNC(common,doAnimation);
    };
}, 0.1, [_trench, _unit, _digTime]] call CBA_fnc_addPerFrameHandler;

// Play animation
[_unit, "AinvPknlMstpSnonWnonDnon_medic4"] call EFUNC(common,doAnimation);
