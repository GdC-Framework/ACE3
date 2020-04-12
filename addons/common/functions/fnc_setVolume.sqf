#include "script_component.hpp"
/*
 * Author: Glowbal
 * Sets the volume of the game, including third party radio modifications such as TFAR and ACRE.
 *
 * Arguments:
 * 0: setVolume (default: false) <BOOL>
 *
 * Return Value:
 * None
 *
 * Example:
 * [true] call ace_common_fnc_setVolume
 *
 * Public: Yes
 *
 * Note: Uses player
 */

#define MUTED_LEVEL  0.2
#define NORMAL_LEVEL 1
#define NO_SOUND     0

params [
    ["_setVolume", false],
    ["_unit", player]
];

if (_setVolume) then {
    // Vanilla Game
    2 fadeSound NORMAL_LEVEL;

    // TFAR
    _unit setVariable ["tf_voiceVolume", NORMAL_LEVEL, true];
    _unit setVariable ["tf_globalVolume", NORMAL_LEVEL];
    _unit setVariable ["tf_unable_to_use_radio", false];

    // ACRE2
    if (!isNil "acre_api_fnc_setGlobalVolume") then { [NORMAL_LEVEL^0.33] call acre_api_fnc_setGlobalVolume; };
    _unit setVariable ["acre_sys_core_isDisabled", false, true];
    
    // CPC UPDATE
    private ["_player_radios", "_player_radios_config"];
    _player_radios_config = _unit getVariable ["cpc_playerRadiosConfig", []];
    if (count _player_radios_config  == 0) then {
        // No radio config found. Two possibilites : bug or player doesn't have radio. Force everything to 1.
        _player_radios =  [] call acre_api_fnc_getCurrentRadioList;
        {
            // TODO: pour la version ACRE 2.7
            //[_x, 1] call acre_api_fnc_setRadioVolume;
            // Fix pour la version ACRE 2.6
            [_x, 1] call acre_sys_radio_fnc_setRadioVolume;
        } forEach _player_radios;
    } else {
        // Standard behavior, apply previously saved configuration
        {        
            // TODO: pour la version ACRE 2.7
            //[_x select 0, _x select 1] call acre_api_fnc_setRadioVolume;
            // Fix pour la version ACRE 2.6
            [_x select 0, _x select 1] call acre_sys_radio_fnc_setRadioVolume;
        } forEach _player_radios_config;
    };
} else {
    // Vanilla Game
    2 fadeSound MUTED_LEVEL;

    // TFAR
    _unit setVariable ["tf_voiceVolume", NO_SOUND, true];
    _unit setVariable ["tf_globalVolume", MUTED_LEVEL];
    _unit setVariable ["tf_unable_to_use_radio", true];

    // ACRE2
    if (!isNil "acre_api_fnc_setGlobalVolume") then { [MUTED_LEVEL^0.33] call acre_api_fnc_setGlobalVolume; };
    _unit setVariable ["acre_sys_core_isDisabled", true, true];

    // CPC UPDATE
    private ["_player_radios", "_player_radios_config"];
    _player_radios_config = [];
    _player_radios =  [] call acre_api_fnc_getCurrentRadioList;
    {
        // TODO: pour la version ACRE 2.7 !
        // _player_radios_config pushBack [_x, [_x] call acre_api_fnc_getRadioVolume];
        // Fix pour la version ACRE 2.6
        _player_radios_config pushBack [_x, ([_x] call acre_sys_radio_fnc_getRadioVolume) ^ (1/3)];
        //[_x, ([_x] call acre_api_fnc_getRadioVolume) / 4.5] call acre_api_fnc_setRadioVolume;
        // TODO: pour la version ACRE 2.7
        //[_x, 0] call acre_api_fnc_setRadioVolume;
        // Fix pour la version ACRE 2.6
        [_x, 0] call acre_sys_radio_fnc_setRadioVolume;
    } forEach _player_radios;
    // Save radio config on the player
    _unit setVariable ["cpc_playerRadiosConfig", _player_radios_config];
};
