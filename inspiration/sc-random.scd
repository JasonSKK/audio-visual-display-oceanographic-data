// =====================================================================
// SuperCollider Workspace
// =====================================================================

a = {{
	Mix.fill(10, {
		LFTri.ar(222 + gauss(0.0, 1.0), gauss(pi, 1.0) )}
	) * 0.01 
}!2};
a.play
//:
play{
	var trig;
	trig = TDuty.kr(Dseq([0.1, 0.2, 0.4, 0.3] * 1, inf));
	WhiteNoise.ar(0.1).dup * Env.perc.kr(gate: trig)
}
//:

//Might Be usefull????
  
// 26 Nov 2020 11:34
// from: http://sccode.org/1-5ec#c941
// A.Broz: Waves & Surf (2020-10-29)
//:
/*
	_.====.._
	,:._       ~-_
	`\        ~-_
	| _  _  |  `.
	,/ /_)/ | |    ~-_
    -..__..-''  \_ \_\ `_      ~~--..__...----...
*/
(
~waves = {
	var noise = { WhiteNoise.ar(0.04 + LFNoise1.kr(0.3, 0.03)) };
	var motion = { LFNoise1.kr(0.2).exprange(100, 2000) };
	var hps = { HPF.ar(noise.value, 50) };
	var wave = { LPF.ar(hps.value, motion.value).tanh };
	var sig = wave!10;
	sig = Splay.ar(sig, 0.6).tanh;
	sig = sig * Line.kr(0, 1, 10); // fade in
	LeakDC.ar(sig);
}.play;
)
//:
~waves release: 10;