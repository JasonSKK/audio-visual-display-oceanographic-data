play{Mix.fill(10, {|i = 1| i = i * 1.0.rand; SinOsc.ar(333 * i, SinOsc.ar(i*100).range(-10, 10))}) * 0.1!2}

//noisy alternative
play{Mix.fill(10, {|i = 1| i = i * 1.0.rand; SinOsc.ar(333 * i, SinOsc.ar(i*100).range(-10, 10)) + WhiteNoise.ar(0.8)}) * 0.1!2}

s.newBusAllocators;
~vbus = Bus.audio(s, 2);

(
SynthDef("chaos", {
	|freq = 333, amp = 0.5, gate = 2, reltime = 0.1|
	var sig, env, out;
	sig = Mix.fill(10, {|i = 1| i = i * 1.0.rand;
		SinOsc.ar(freq* i, SinOsc.ar(i*(100)).range(-10, 10))+
		LPF.ar(WhiteNoise.ar(0.9), LFNoise1.ar(1).range(2000, 8800))});
	env = EnvGen.kr(Env.adsr(0.031, 0.1, releaseTime:0.01, curve:-4), Line.kr(1, 0, gate), doneAction:2);
	sig = sig*2.clip2(0.6).tanh(1.4);
	sig = Compander.ar(sig, sig, 0.82, 1, reltime);
	out = sig * env * amp * 0.9;
	Out.ar(0, Pan2.ar(out, SinOsc.ar(freq)));
	Out.ar(~vbus, [out, out] * dbamp(-25));
}).play;
)


(
play{var sig = Pan2.ar(LPF.ar(WhiteNoise.ar(1), 19000) * Pulse.ar(0.25) * 0.1);
	Out.ar(0, sig * 0.2);
	Out.ar(~vbus, sig);
});


(
play{
	var sig = In.ar(~vbus, 2);
	var temp, sum;
	sum = 0;
	10.do{
		temp = DelayC.ar(sig, 0.1, 0.1);
		temp = temp * SinOsc.ar(1000);
		temp = CombN.ar(sig, 0.2, {rrand(0.01,0.05)}!32, 2);
		temp = SplayAz.ar(2, temp, 2);
		temp = LPF.ar(temp, 6666 );//+ 10.rand);
		temp = HPF.ar(temp, 300);
		temp = AllpassN.ar(temp, 0.2, rrand(0.08, 0.105)!2);
		//temp = LeakDC.ar(temp);
		sum = temp + sum * 0.2;
	};
	Out.ar(0, Pan2.ar(sum))
}
)
