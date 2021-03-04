// =====================================================================
// SuperCollider Workspace
// =====================================================================


b = Buffer.readChannel(s,"/Users/jsk/Media/SoundSamples/Recordings_THMO_DigitalSoundSynthesis_15-6-15/pigadi_apo_poli_konta_syrsimata.wav", 2**19,  - 1 , channels: 0)
//:
b = Buffer.readChannel(s,"/Users/jsk/Media/SoundSamples/Recordings_THMO_DigitalSoundSynthesis_15-6-15/kagela_stilo.wav", 2**18, 2**19, channels: 0)

//:

var winenv;
winenv = Env([0, 1, 0], [1, 1], [8, -8]);
z = Buffer.sendCollection(s, winenv.discretize, 1);

SynthDef("toygrain", {
	| gate = 1, amp = 0.5, sndbuf, envbuf |
	var sig, out, env;
	env = EnvGen.kr(
		Env.adsr(0.1, 0.2, 1, 9, curve: \welch), gate, doneAction:2
	);
	sig = GrainBuf.ar(1, Dust.kr(10), 0.5, sndbuf,
		//Rate
		LFNoise1.kr(0.5).range(0.1, -0.1),
		//Pos
		LFNoise1.kr(0.5).range(0.0, b.numFrames -1),
		4,
		0, envbuf) ; //* env ;
	sig = CombC.ar(sig, 0.2, 0.09, 2, add: sig);
	//sig = GVerb.ar(sig, 100);
	sig = FreeVerb.ar(sig, 4.0, 20);
	sig = sig * amp * env;
	Out.ar(0, [sig, sig] );
}).add;

x = Synth("toygrain", [\sndbuf, b, \envbuf, -1])
//:
x.set(\envbuf, z)
play{PlayBuf.ar(1, b)}
//:
x.set(\gate, 0)
//:

