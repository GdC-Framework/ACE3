#include "script_component.hpp"
/*
 * Author: BaerMitUmlaut
 * Triggers the pain effect (single flash).
 *
 * Arguments:
 * 0: Enable <BOOL>
 * 1: Intensity <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [true, 0.5] call ace_medical_feedback_fnc_effectPain
 *
 * Public: No
 */

params ["_enable", "_intensity"];

if (!_enable || {_intensity == 0}) exitWith {
    GVAR(ppPain) ppEffectEnable false;
//    GVAR(ppPainBlur) ppEffectEnable false;
    GVAR(ppPainCPC) ppEffectEnable false;
    GVAR(ppPainCPCDB) ppEffectEnable false;
};
GVAR(ppPain) ppEffectEnable true;
//GVAR(ppPainBlur) ppEffectEnable true;

// Trigger effect every 2s
private _showNextTick = missionNamespace getVariable [QGVAR(showPainNextTick), true];
GVAR(showPainNextTick) = !_showNextTick;
if (_showNextTick) exitWith {};

//private _blurIntensity = linearConversion [0.8, 1, _intensity, 0, 1, true];
//GVAR(ppPainBlur) ppEffectAdjust [_blurIntensity];
//GVAR(ppPainBlur) ppEffectCommit 0.1;

if (GVAR(painEffectType) == FX_PAIN_ONLY_BASE) exitWith {};

private _initialAdjust = [];
private _delayedAdjust = [];

if (GVAR(painEffectType) == FX_PAIN_CPC) then {   
    private["_cpcPainShout", "_cpcRun", "_cpcStart", "_cpcPainCoeff", "_cpcVarTime", "_cpcRandomPainShout"];
    _cpcRun = ACE_player getVariable [QGVAR(cpcRun), false];
    if (!_cpcRun) then {
        // Launch our AWESOME CPC PAIN EFFECT
        ACE_player setVariable [QGVAR(cpcRun), true];
        ACE_player setVariable [QGVAR(cpcStart), CBA_missionTime];
        nul = [_intensity] spawn {
            //hint format["STRENGHT : %1", (_this select 0)];sleep 2.0;
            private["_cpcStrengthIterations", "_cpcWaitRandom"];
            _cpcStrengthIterations = 1;
            if ((_this select 0) >= 0.5) then {
                _cpcStrengthIterations = floor(random 3) + 1;
            };
            
            // Execute one time and 1 or 2 supp if pain > 0.5
            while {_cpcStrengthIterations > 0} do {
                //hint format["_cpcStrengthIterations : %1", _cpcStrengthIterations];sleep 2.0;
                //"dynamicBlur" ppEffectEnable true;
                GVAR(ppPainCPCDB) ppEffectEnable true;
                GVAR(ppPainCPC) ppEffectEnable true;
                //"dynamicBlur" ppEffectAdjust [(_this select 0) * 25];
                //"dynamicBlur" ppEffectCommit 2;
                GVAR(ppPainCPCDB) ppEffectAdjust [(_this select 0) * 25];
                GVAR(ppPainCPCDB) ppEffectCommit 2;
                GVAR(ppPainCPC) ppEffectAdjust [1, 1, 0, [1, 1, 1, 0], [1, 1, 1, 0], [0.1, 0.1, 0.1, 0]];
                GVAR(ppPainCPC) ppEffectCommit 0.5;
                
                // Wait a little...
                sleep 0.9;

                //"dynamicBlur" ppEffectAdjust [0];            
                //"dynamicBlur" ppEffectCommit 1;
                GVAR(ppPainCPCDB) ppEffectAdjust [0];
                GVAR(ppPainCPCDB) ppEffectCommit 1;
                GVAR(ppPainCPC) ppEffectAdjust [1, 1, 0, [1, 1, 1, 0], [1, 1, 1, 1], [0, 0, 0, 0]];
                GVAR(ppPainCPC) ppEffectCommit 1;
                sleep 1.0;
                //"dynamicBlur" ppEffectEnable false;
                GVAR(ppPainCPCDB) ppEffectEnable false;
                GVAR(ppPainCPC) ppEffectEnable false;
                
                if (_cpcStrengthIterations > 1) then {
                    _cpcWaitRandom = floor(random 3);
                    //hint format["_cpcWaitRandom : %1", _cpcWaitRandom];sleep 2.0;
                    sleep _cpcWaitRandom;
                };
                _cpcStrengthIterations = _cpcStrengthIterations - 1;
                //hint format["_cpcStrengthIterations : %1", _cpcStrengthIterations];sleep 2.0;
            };
            // echelon 15/30/45 secondes selon la douleur (+ ou - 5s)
            _cpcPainCoeff = 3;
            if ((_this select 0) > 0.60) then {
                _cpcPainCoeff = _cpcPainCoeff - 1;
            };
            if ((_this select 0) > 0.33) then {
                _cpcPainCoeff = _cpcPainCoeff - 1;
            };
            _cpcVarTime = (15 * _cpcPainCoeff) + floor(random(10)-5);
            //hint format["_cpcVarTime : %1 - _cpcPainCoeff : %2", _cpcVarTime, _cpcPainCoeff];sleep 2.0;
            ACE_player setVariable [QGVAR(cpcVarTime), _cpcVarTime];
        };
    } else {
        // CPC effect is running, check if time is ok to launch another effect
        _cpcStart = ACE_player getVariable [QGVAR(cpcStart), CBA_missionTime];
        _cpcVarTime = ACE_player getVariable [QGVAR(cpcVarTime), 60.0];
        if (CBA_missionTime > (_cpcStart + _cpcVarTime)) then {
            ACE_player setVariable [QGVAR(cpcRun), false];
        };
    };
} else {
    switch (GVAR(painEffectType)) do {
        case FX_PAIN_WHITE_FLASH: {
            _intensity     = linearConversion [0, 1, _intensity, 0, 0.6, true];
            _initialAdjust = [1, 1, 0, [1, 1, 1, _intensity      ], [1, 1, 1, 1], [0.33, 0.33, 0.33, 0], [0.55, 0.5, 0, 0, 0, 0, 4]];
            _delayedAdjust = [1, 1, 0, [1, 1, 1, _intensity * 0.3], [1, 1, 1, 1], [0.33, 0.33, 0.33, 0], [0.55, 0.5, 0, 0, 0, 0, 4]];
        };
        case FX_PAIN_PULSATING_BLUR: {
            _intensity     = linearConversion [0, 1, _intensity, 0, 0.008, true];
            _initialAdjust = [_intensity      , _intensity      , 0.15, 0.15];
            _delayedAdjust = [_intensity * 0.2, _intensity * 0.2, 0.25, 0.25];
        };
        case FX_PAIN_CHROMATIC_ABERRATION: {
            _intensity     = linearConversion [0, 1, _intensity, 0, 0.06, true];
            _initialAdjust = [_intensity       , _intensity       , true];
            _delayedAdjust = [_intensity * 0.15, _intensity * 0.15, true];
        };
    };

    GVAR(ppPain) ppEffectAdjust _initialAdjust;
    GVAR(ppPain) ppEffectCommit FX_PAIN_FADE_IN;
    [{
        params ["_adjust", "_painEffectType"];
        if (GVAR(painEffectType) != _painEffectType) exitWith {TRACE_1("Effect type changed",_this);};
        GVAR(ppPain) ppEffectAdjust _adjust;
        GVAR(ppPain) ppEffectCommit FX_PAIN_FADE_OUT;
    }, [_delayedAdjust, GVAR(painEffectType)], FX_PAIN_FADE_IN] call CBA_fnc_waitAndExecute;
};
