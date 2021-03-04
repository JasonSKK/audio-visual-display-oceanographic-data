//:
(SynthDef("bs-mod", {
	| freq = 2444, modf = 222, panst = -1.0, panen = 0.2 amp = 0.5 |
	var sig, env, out, sum, temp, sigdry, sigwet;
	sum = 0;
	temp = 30.do{
		temp = SinOsc.ar(freq + [20.rand, (-1) * 20.rand].choose);
		temp = temp * Mix.ar(SinOsc.ar([freq * rrand(0.5, 1.0), freq * rand(0.8, 0.9)] ));
		sum = sum + temp * 0.5;
	};
	// sum = HPF.ar(sum, Line.kr(8888, 1000, 1, doneAction:0), 1); //Not both LFP & HPF together
	sum = LPF.ar(sum , 9999); // Not together (LPF & HPF)
	sig = sum;
	sig = Compander.ar(sig, sig,
        thresh: 0.3,
        slopeBelow: 1,
        slopeAbove: 0.5,
        clampTime:  0.01,
        relaxTime:  0.01
    );
	sig = CombC.ar(sig, 0.2, 0.2, 5, add: sig);
	//sigdry = sig;


		//sig = DelayN.ar(sig, 0.03, 0.03);
		//sig = CombN.ar(sig, 0.1, {Rand(0.01,0.099)}!32, 4);
		//sig = SplayAz.ar(2, sig);
		//sigwet = LPF.ar(sig, 9000);
		//5.do{sigwet = AllpassN.ar(sigwet, 0.1, {Rand(0.01,0.099)}!2, 3)};
		//sigwet = LPF.ar(sigwet, 6000);
	    // sig = LeakDC.ar(sig);

	//sig = Mix.ar([sigwet * 0.2, sigdry]);

	sig = Env.perc(1, 5).kr(doneAction:0) * sig;
	env = Env.perc(1, 7).kr(doneAction:2);
	out = sig * env * amp * 0.4;
	Out.ar(0, Pan2.ar(out, Line.kr(panst, panen)));
}).play;
)


//:Ambient
(
SynthDef("bjor", {
	| freq = 444, modf = 100, amp = 0.5, cutoff = 1066|
	var sig, env, out;
	modf = freq * (0.25);
	sig =
		Pluck.ar(PinkNoise.ar, Impulse.kr(0), 0.5,
			delaytime: 4/freq, //Lowerfreq more delay - extreme effects
		decaytime: 8,
			coef: 0.2);
	sig = LPF.ar(sig, cutoff);
	env = Env.perc(6, 6, curve:7).kr(doneAction:2);
	out = sig * env * 28 ;
	Out.ar(0, Pan2.ar(out, 0))
}).add;
)

Synth("bjor", [\cutoff, 10000, \freq, 6]) //Lowerfreq more delay - extreme effects
Synth("bjor", [\cutoff, 10000, \freq, 100])

(
Pbind(
	\instrument,
	\bjor,
	\dur, 0.5,
	\note, Pseq([0, 7, 5, 0, 12, 8],inf),
	\octave, 5,
).play
)
//



