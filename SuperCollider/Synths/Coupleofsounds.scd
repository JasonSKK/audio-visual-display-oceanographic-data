// =====================================================================
// SuperCollider Workspace
// =====================================================================

play{
	Pulse.ar(200 + ((1..30) * [-1, 1].choose).normalizeSum, SinOsc.ar(200, Line.kr(pi/8, pi, 4))) * 0.01!2
}
//:
play{CombC.ar(PinkNoise.ar(0.2), 0.5, SinOsc.ar(
	Env([0.25, 3, 30, 100], [2, 2, 2]).kr)
	.range(0.005, 0.009)) * 0.2!2}
//:
play{Mix(VarSaw.ar(288 + [884, 890, 870, 890])) * 1 * Env.perc(0.001, 2, 0.1, -4).kr(doneAction:2)!2}
