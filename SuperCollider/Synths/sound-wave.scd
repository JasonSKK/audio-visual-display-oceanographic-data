//Kool sound Nick Collins
//:
{Resonz.ar(LFNoise1.ar(400),Line.kr(10000,100,10), Line.kr(0.1, 1.0, 8))!2}.play;
//:
(SynthDef("wave1", {
|freqst = 10000, freqend = 100, durf = 10, bwtst = 0.4, bwtend = 1.2, amp = 0.5, durbwt = 8, panst = 0.9, panend = -0.2|
	var sig, env, out;
	sig = Resonz.ar(LFNoise0.ar(10000), Env([freqst, freqend*2, freqend], [durf, 0.9], \exp).kr, XLine.kr(bwtst, bwtend, durbwt));
	//sig = CombC.ar(sig, 0.2, 0.1, 6, add:sig);
	sig = LPF.ar(sig, 12000);
	sig = Compander.ar(sig, sig, 0.6, clampTime: 0.05);
	env = EnvGen.kr(Env.adsr(7, 1, 0.577, 5), Line.kr(1, 0, 7), levelScale: 0.8, doneAction:2);
	out = sig * env * amp;
	Out.ar(0, Pan2.ar(out, Line.kr(panst, panend, 6)));
}).play
)
//:

b = Buffer.readChannel(s, "C:/Users/Flud666/Documents/Jason SK/Sound Samples/Recordings_THMO_DigitalSoundSynthesis_15-6-15/aircondition_industrial_exoteriko.wav", channels:1); //Prefer MONO
play{PlayBuf.ar(2, b)}
(
var winenv;

//b = Buffer.read(s, Platform.resourceDir +/+ "sounds/sxara_me_xylo.wav");
// a custom envelope
winenv = Env([0, 1, 0], [0.5, 0.5], [8, -8]);
z = Buffer.sendCollection(s, winenv.discretize, 1);
//winenv.plot;
SynthDef(\buf_grain_test, { |out, gate, amp = 1, sndbuf, envbuf, trigfreq = 10| //trig range 10-100
    var sig, pan, env, freqdev;

	pan = LFNoise1.kr(0.5).range(-1.0, 1.0);//MouseX.kr(-1, 1);

	sig = GrainBuf.ar(2, Impulse.kr(trigfreq), 0.2, sndbuf, LFNoise1.kr(1).range(-10.0, 10.25),
            LFNoise2.kr(0.2).range(0, 1), 2, pan, envbuf);

	sig = CombC.ar(sig, 0.2, LFNoise1.kr(0.4).range(0.07, 0.2), 5, add:sig);
	sig = AllpassC.ar(sig, 0.2, 0.1, 5, LFNoise1.kr(0.2).range(0.3, 1.0), add:sig);
	sig = LPF.ar(sig, 1900);

	env = EnvGen.kr(Env.adsr(10, 2, 0.666, 6), gate, doneAction:2);/*EnvGen.kr(
        Env([0, 1, 0], [1, 1], \sin, 1),
        gate,
        levelScale: amp,
        doneAction: Done.freeSelf);*/

	sig = sig * env ;//* Env.perc.kr(doneAction:2);
	    Out.ar(out,sig)
}).add;

)

x.set(\envbuf, z)
x.set(\envbuf, -1);
x = Synth(\buf_grain_test, [\sndbuf, b, \envbuf, -1, \gate, 1])
x.set(\gate, 0)

x.free