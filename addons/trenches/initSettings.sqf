// Trenches dig/remove durations
[
    QGVAR(smallEnvelopeDigDuration), 
    "TIME", 
    [LSTRING(SmallEnvelopeDigDuration_DisplayName), LSTRING(SmallEnvelopeDigDuration_Description)],
    LSTRING(Category),
    [5, 600, 20], 
    true
] call CBA_fnc_addSetting;

[
    QGVAR(smallEnvelopeRemoveDuration), 
    "TIME", 
    [LSTRING(SmallEnvelopeRemoveDuration_DisplayName), LSTRING(SmallEnvelopeRemoveDuration_Description)],
    LSTRING(Category),
    [5, 600, 12], 
    true
] call CBA_fnc_addSetting;

[
    QGVAR(bigEnvelopeDigDuration), 
    "TIME", 
    [LSTRING(BigEnvelopeDigDuration_DisplayName), LSTRING(BigEnvelopeDigDuration_Description)],
    LSTRING(Category),
    [5, 600, 25], 
    true
] call CBA_fnc_addSetting;

[
    QGVAR(bigEnvelopeRemoveDuration), 
    "TIME", 
    [LSTRING(BigEnvelopeRemoveDuration_DisplayName), LSTRING(BigEnvelopeRemoveDuration_Description)],
    LSTRING(Category),
    [5, 600, 15], 
    true
] call CBA_fnc_addSetting;

// Settings
[
    QGVAR(buildFatigueFactor), 
    "SLIDER", 
    ["Facteur de fatigue", "Le facteur de fatigue lors de la construction de tranchées (si 0, fatigue désactivée)"], 
    LSTRING(Category),
    [0, 10, 3.5, 1], 
    true
 ] call CBA_fnc_addSetting;
