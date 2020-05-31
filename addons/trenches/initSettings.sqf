// Settings
[QGVAR(buildFatigueFactor), "SLIDER", ["Facteur de fatigue", "Le facteur de fatigue lors de la construction de tranchées (si 0, fatigue désactivée)"], "ACE Tranchées", [0, 10, 3.5, 1], true] call CBA_Settings_fnc_init;

// Time sliders
[QGVAR(smallEnvelopeDigTime), "SLIDER", "Durée excavation petite tranchée", "ACE Tranchées", [5, 450, 25, 0], true] call CBA_Settings_fnc_init;
[QGVAR(bigEnvelopeDigTime), "SLIDER", "Durée excavation grande tranchée", "ACE Tranchées", [5, 600, 45, 0], true] call CBA_Settings_fnc_init;
