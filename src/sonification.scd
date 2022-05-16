//:
//SC-meter
s.meter;
s.scope;
//:
~n = NetAddr("192.168.1.76", 57120);
//IP Address might change sometimes - CAREFULL IF ERROR
//"192.168.1.3"
~nsend = NetAddr("192.168.1.76", 12345);
//:-----------------------------------------------------------------------------------------
//Synths
b = Buffer.readChannel(s, Platform.userHomeDir +/+ "Media/SoundSamples/recordings-department-ethnomus-dig-sound-synthesis_15-6-15/pigadi_apo_poli_konta_syrsimata.wav", 2**19, -1, channels: 1);

//Initialisation
//Set counter => sum of msgs 
~counter = 0;
//Scale Phrygian B Initialisation
~scale = Scale.phrygian.degreeToFreq([0, 1, 3, 5, 7, 8, 10, 12], 59.midicps, 1);
//Bus
s.newBusAllocators;
~vbus = Bus.audio(s, 2);
//ampcontrol for melody synth
~ampmelody = 0;
//Initial value wss2 synth
~cutoffwss = 100;
//:-----------------------------------------------------------------------------------------

//Ambient
"bjor_synth".postln;
SynthDef("bjor", {
	| freq = 444, modf = 1000, amp = 0.0, cutoff = 1066, panst = -0.8, panend = 0.5|
	var sig, env, out;
	sig =
	Pluck.ar(PinkNoise.ar, Impulse.kr(0), 0.5,
		delaytime: 4/freq, //Lowerfreq more delay - extreme effects
		decaytime: 8,
		coef: 0.1);
	sig = LPF.ar(sig, cutoff);
	sig = sig.wrap2(0.666);
	//env = Env.perc(10, 6, curve:'cubed').kr(doneAction:2);
	env = Env([0, 0, 1, 0], [0.9, 4, 8], curve:7).kr(doneAction:2);
	out = sig * env * 20;
	Out.ar(0, Pan2.ar(out * amp, Line.kr(panst, panend, 7)));
	Out.ar(~vbus, out * amp * dbamp(-6))
}).add;

//GRANULATOR
"toy_grain".postln;
SynthDef("toygrain", {
	| gate, amp = 0.5, sndbuf, envbuf, pan = 0, grain=10|
	var sig, out, env;
	env = EnvGen.kr(
		Env.adsr(0.1, 0.2, 1, 9, curve: \welch), gate, doneAction:2);
	sig = GrainBuf.ar(1, Dust.kr(grain), 0.2, sndbuf,//was 10 and 0.5
		//Rate
		LFNoise1.kr(0.5).range(-0.5, -0.9),
		//Pos
		LFNoise1.kr(0.5).range(b.numFrames/3, 1559115 -1/3 * 2),
		4,
		0, envbuf); 
	sig = CombC.ar(sig, 0.2, 0.09, 2, add: sig);
	sig = sig.clip2(0.666);
	//sig = GVerb.ar(sig, 100);
	//sig = FreeVerb.ar(sig, 4.0, 20);
	pan = LFNoise1.kr(0.5).range(-0.8, 0.8);
	sig = sig * amp * env;
	sig = sig.clip2(0.9);
	Out.ar(0, Pan2.ar(sig, pan));
	//Out.ar(1, Pan2.ar(sig, 1));
	Out.ar(~vbus, sig * dbamp(-25))
}).add;

//Wave
SynthDef("wave1", {
	|freqst = 18000, freqend = 100, durf = 10, bwtst = 0.4, bwtend = 1.2, amp = 0.5, durbwt = 8, panst = 0.9, panend = -0.2, cutoff = 12000,pmf=200,modf=4|
	var sig, env, out;
	sig = Resonz.ar(
		LFNoise0.ar(10000),
		Env([freqst, freqend, freqend], [durf, 0.9], \exp).kr,
		XLine.kr(bwtst, bwtend, durbwt));
	//sig = CombC.ar(sig, 0.2, 0.1, 6, add:sig);
	sig = sig * SinOsc.ar(modf,add:-4);
	sig = sig + SinOsc.ar(freqend+200,SinOsc.ar(pmf),mul:0.7);
	sig = LPF.ar(sig, cutoff);
	sig = Compander.ar(sig, sig, 0.4, 1, 0.1, clampTime: 0.05);
	sig = sig.clip2(0.666);
	env = EnvGen.kr(Env.adsr(7, 1, 0.577, 5), Line.kr(1, 0, 7), levelScale: 0.8, doneAction:2);
	out = sig * env * amp * 0.15;
	Out.ar(0, Pan2.ar(out, Line.kr(panst, panend, 9)));
}).add;

//Noise
SynthDef("chaos", {
	|freq = 333, amp = 0.5, gate = 2, reltime = 0.01|
	var sig, env, out;
	sig = Mix.fill(10, {|i = 1| i = i * 1.0.rand;
		SinOsc.ar(freq* i, SinOsc.ar(i*(50)).range(-10, 10))+
		LPF.ar(WhiteNoise.ar(0.9), LFNoise1.ar(1).range(2000, 8800))});
	env = EnvGen.kr(Env.adsr(0.031, 0.1, releaseTime:reltime, curve:-4), Line.kr(1, 0, gate * 0.8), doneAction:2);
	sig = sig;
	sig = SplayAz.ar(2, sig, 4);
	sig = sig*2.fold2(0.4).tanh(1.9);
	sig = Compander.ar(sig, sig, 0.92, 1, reltime);
	out = sig * env * amp * 2;
	Out.ar(0, Pan2.ar(out, SinOsc.ar(freq).range(-1.0, 1.0)));	
	//Out.ar(~vbus, [out, out] * dbamp(-20));
}).add;

SynthDef("wss2", {
    |freq = 1040, amp = 0.5, pan = 0, cutoff = 1000|
    var sig, env, out;
    sig = Mix.fill(10, {Saw.ar(freq * rrand(0.99, 1.01)) * SinOsc.ar(freq/2) });
	sig = (sig * 2) + WhiteNoise.ar(0.3) +
	Mix.fill(10, {Pulse.ar(freq * rrand(1.01, 0.99), rrand(0.1, 0.9))});
	sig = Compander.ar(sig, sig, 0.8, 1, 0.1);
    env = Env.perc(1.5, 2).kr(doneAction:2);//Amp_Env
	sig = LPF.ar(sig, cutoff);
    out = sig  * amp * 0.466;
	Out.ar(0, Pan2.ar(out * env * 0.333, pan));
    Out.ar(~vbus, Pan2.ar(out * env * dbamp(3), pan));
}).add;

SynthDef("nsgate", {
    |freq = 444, amp = 0.5, pan = 0, delt = 0.1, mfreq = 333|
    var sig, env, out;
    sig = LPF.ar(
		ClipNoise.ar(1), 1888)
	* LPF.ar(GrayNoise.ar(2.5), freq * 10) * LFPulse.kr(freq /2);
    sig = BPF.ar(sig, XLine.kr(freq * 10, freq/10, 6), 0.4);
    sig = sig + (CombC.ar(Decay.ar(BPF.ar(Dust.ar(30, 10), Line.kr(freq/4, freq * 4, 6.6), 0.4), 2), 0.2, delt, 2));
    sig = sig +  CombN.ar(
		Gendy1.ar(2,3,
			minfreq:10,
			maxfreq: mfreq,
			durscale:0.5,
			initCPs: 10),0.2, rand(0.08, 0.2), 1.5, 0.333);
	sig = SplayAz.ar(2, sig, 4, center:pan);
	sig = LPF.ar(sig, 266);
    env = Env.perc(4, 4).kr(doneAction:2);
    out = sig * env * amp;
	sig = sig.clip2(0.01);
    Out.ar(0, Pan2.ar(out * 0.0666, pan));
	Out.ar(~vbus, out * dbamp(6));
}).add;

SynthDef("rezz", {
	|amp = 1.0, gate = 1|
	var rez =
	Resonz.ar(
		LFNoise1.ar([422, 666]),
		Line.kr(18000,100, 9), XLine.kr(0.1, 1.0, 8));
	rez = rez * EnvGen.kr(Env.adsr(0.05, releaseTime:8), gate, doneAction:2);
	rez = rez.clip2(0.577);
	//rez = Compander.ar(rez, rez, 0.01, 0.5);
	Out.ar(0, rez * amp * 0.85 )
}).add;

SynthDef.new("wave",{
    arg freq = 440, amp = 1, gate = 0, pan = -0.6;
    var s, env;
    s = SinOsc.ar(freq*2,SinOsc.kr(9,0.2,0.8),Pulse.ar(2,0.5,0.8));
    env = EnvGen.kr(Env.adsr(0.2,0.2,0.5,1,curve:-4.0), Line.kr(1,0, 0.2), doneAction:0);
    s = HPF.ar(LPF.ar(s,2000),400);
    s = s * env * amp * 0.12;
	s = FreeVerb.ar(s, 0.32, 100) * Env.perc(0.2, 3).kr(doneAction:2);
    Out.ar(0, Pan2.ar(s , pan));
	//Out.ar(~vbus, Pan2.ar(s, pan))
}).add;

SynthDef("liq", {
    |amp = 0.5, pan = 0, delt = 0.1, freq = 2222|
    var sig, sig1, env, out, out1;
    sig = LFCub.ar( LFNoise2.kr(1).range(0.5, 2) * 1222, LFNoise1.kr(1).range(0.4, 0.6), Impulse.kr(rrand(3, 6)));
    sig = sig + SinOsc.ar( LFNoise2.kr(1).range(0.5, 2) * 1822, LFNoise1.kr(1).range(0.4, 0.6), mul: Dust.kr(rrand(3, 6)));
    env = Env.perc(2, 5, curve:-4).kr(doneAction:2);
    sig = CombC.ar(CombN.ar(Decay.ar(sig, 1.5, LPF.ar(WhiteNoise.ar, freq), sig), 0.2, 0.1, 4.6));
    out = sig * env * amp * 0.09125;
    out = LPF.ar(out, 3333);
    Out.ar(0, Pan2.ar(out, pan))
}).add;

SynthDef("bright", {
	|freq = 444, amp = 0.5, pan = 0, modp|
	var sig, env, out;
	sig = Mix(
		Pulse.ar(
			freq *
			[1, 1.01, 0.99, 3.069444, 3.090277, 3.020833, 3.090277 ]/2)  );
	sig = LPF.ar(sig, Line.kr(10000, 3333, 0.6));
	env = Env.perc(3, 5, 0.1, -4).kr(doneAction:2);
	out = sig * env * amp * SinOsc.ar(freq/4);
	out = HPF.ar(out, 96);
	out = out.clip2(0.77);
	Out.ar(0, Pan2.ar(out, SinOsc.kr(modp).range(-0.233, 0.833)));
	Out.ar(~vbus, out);
}).add;

//Reverb
"reverb".postln;
SynthDef("reverb",{
	var sig = In.ar(~vbus, 2);
	var temp, sum;
	sum = 0;
	10.do{
		temp = DelayL.ar(sig, 0.5, 0.4);
		temp = temp * SinOsc.ar(1000);
		temp = CombN.ar(sig, 0.2, {rrand(0.005,0.02)}!32, 4);
		temp = SplayAz.ar(2, temp, 1);
		temp = LPF.ar(temp, 6666 );//+ 10.rand);
		temp = HPF.ar(temp, 500);
		temp = AllpassC.ar(temp, 0.2, rrand(0.02, 0.005)!2);
		temp = LeakDC.ar(temp);
		sum = temp + sum * 0.2;
	};
	Out.ar(0, Pan2.ar(sum))
}).play;


//:-----------------------------------------------------------------------------------------


//s.record("~/Desktop/waves.wav");

//vvvvvvvvv Must evaluate seperately (SynthDef) otherwise (SynthDef toy grain not found)
~s4 = Synth("toygrain", [\sndbuf, b, \envbuf, -1, \amp, 0.0]);
//Initialisation
~ampcounter = 0.0; 
OSCdef(\temp,
	{
		| msg, freq | 
		var temp;
		~counter.postln;
		//POST-ALL
		[msg[1], msg[2], msg[4], msg[7], msg[8], msg[9]].postln;
		//
		
		temp = msg[4].asFloat;
		temp = temp.linlin(18.96, 26.71, 1, 1000); 






		
		//////////////////////////////////////////////////////////////HEY
		//send OSC msg to Open Frameworks
		~nsend.sendMsg('/waves/temp',  temp);
		/////////////////////////////////////////////////////////////HERE








		
		//temp.postln;
		//msg[4].postln;
		//Counter ONLY HERE
		///////////////////////////
		~counter = ~counter + 1;///
		//~counter.postln;        /// (should be 2388)
		///////////////////////////

		//frequecny-scale
		///////////////////////////
		//1000 max freq value (so 1000 / 8 = 125 for 8 notes Ionian)
		if(temp <= 125, {freq = [~scale[0], ~scale[7]].choose});
		if((temp > 125) && (temp <= 250), {
			freq = [~scale[1], ~scale[3], ~scale[5]].choose});
		if((temp > 250) && (temp <=370), {
			freq = [~scale[2], ~scale[4], ~scale[6]].choose});
		if((temp > 370) && (temp <= 500), {
			freq = [~scale[3], ~scale[5], ~scale[7]].choose});
		if((temp > 500) && (temp <= 625), {
			freq = [~scale[4], ~scale[6], ~scale[1]*2].choose});
		if((temp > 625) && (temp <= 750), {
			freq = [~scale[5], ~scale[7], ~scale[2]*2].choose});
		if((temp > 750) && (temp <= 875), {
			freq = [~scale[6], ~scale[1]*2, ~scale[3]*2].choose});
		if((temp > 875), {freq = [~scale[7], ~scale[1] *2].choose});
		
		///////////////////////////
		//ambience start
		if (~counter < 50,{
			~ampcounter = ~ampcounter + 0.05;
			//~ampcounter.postln;
			if ((~counter <= 10) && (~counter.even), {
				~s2 = Synth("bjor", [
					\amp, ~ampcounter * 2,
					\freq, temp/10,
					\panst, -1,
					\panend, 0.95])//Waves
			});
			if((~counter > 10) && (~counter <= 50), {//>5 OFFICIAL
				~s1 = Synth("bjor", [ //Ambient
					\amp, ~ampcounter * 2,
					\freq, freq,
					\cutoff, freq * 2,
					\panst, [-1, -0.5].choose,
					\panend, [1, 0.5].choose]);
				~s11 = Synth("bjor", [ //Some Ambient more 
					\amp, ~ampcounter * 2,
					\freq, freq,
					\cutoff, freq * 2,
					\panst, [0.9, -0.5].choose,
					\panend, [-0.9, 0.5].choose]);
				
				~s2 = Synth("bjor", [ //Waves
					\amp, ~ampcounter * 0.5,
					\freq, temp/10,
					\panst, 1, //opposide pan  
					\panend, -1]);//here
			});		
		});
		
		//HERE Ambieence stops
		if((~counter >50) && (~counter <=60), {
			~s11 = Synth("bjor", [ //Ambient 
				\amp, ~ampcounter * 2,
				\freq, freq * 2,
				\cutoff, freq * 2,
				\panst, [0.9, -0.5].choose,
				\panend, [-0.9, 0.5].choose])});
		

		if((~counter > 70) && (~counter <= 100), {
			~s11 = Synth("bjor", [ //Ambient 
				\amp, ~ampcounter * 2,
				\freq, freq,
				\cutoff, freq * 6,
				\panst, [0.9, -0.5].choose,
				\panend, [-0.9, 0.5].choose])
		});

		if((~counter > 100) && (~counter < 150), {
			"bjor100".postln;
			~s11 = Synth("bjor", [ //Ambient 
				\amp, ~ampcounter * 2,
				\freq, freq,
				\cutoff, freq * 6,
				\panst, [0.9, -0.5].choose,
				\panend, [-0.9, 0.5].choose])
		});
		
		
	}, '/send' // OSCmessage name
);

//Synth("bjor", [\freq, 444, \cutoff, 10000, \amp, 1])
//freq = 444, modf = 100, amp = 0.0, cutoff = 1066, panst = -0.8, panend = 0.5|

//SIGN HEIGHT FOR NON PITCH SYNTHS - PERC OR GRANULATORS
OSCdef(\sign_height,
	{
		| msg, amp = 0.0| 
		var temp;
		temp = msg[7].asFloat;
        //msg[7].postln;
        temp = temp.linlin(0.020, 0.880, 1, 1000);
		amp = temp.linlin(0.020, 0.880, 0.1, 0.2);



		//////////////////////////////////////////////////////////////HEY
		//send OSC msg to Open Frameworks
		~nsend.sendMsg('/waves/sign_height',  temp);
		/////////////////////////////////////////////////////////////HERE

		
		if ( (~counter > 30) && (~counter <= 46),
			{
				amp = amp + 0.01;
				~s4.set(\gate, 0);
				~s4.set(\gate, 1, \amp, amp, \grain, temp.linlin(1, 1000, 5, 20));
			});

		if((~counter >= 40) && (~counter < 44) && (~counter.even), {
			Synth("wave1",[\modf, temp.linlin(1,1000,5,20), \pmf, temp.linlin(1,1000,100,600)]);
		});
		if(~counter == 47,{~s4.set(\gate, 0)} );
		//HERE AMBIENCE STOPS
		if(~counter == 50, {

			~s6 = Synth("rezz", [\amp, 1.0]);
			//			~s6.set(\amp, 0.0)
			
			
		});
		if((~counter >= 49) && (~counter < 54) && (~counter.even), {
			Synth("wave1", [\cutoff, 800, \amp, 1, \modf, temp.linlin(1,1000,5,20), \pmf, temp.linlin(1,1000,100,600)]);
		});

		
		
		//if(~counter == 201){~s5.set(\amp, 0.0)}
		//noisy explosion		
		//if((~counter == 19), {Synth("chaos")});
	}, '/send' 
);

OSCdef(\zero_upcrossing,
	{
		| msg, freq | 
		var temp, even;
		temp = msg[8].asFloat;
        temp = temp.linlin(3.2, 8.7, 1, 1000);
		even = temp.round(1);
		even = even.asInt;


		//////////////////////////////////////////////////////////////HEY
		//send OSC msg to Open Frameworks
		~nsend.sendMsg('/waves/zero_upcrossing',  temp);
		/////////////////////////////////////////////////////////////HERE

		
		//even.postln;
		//4th or 5th
		/*
		if(temp <= 125, {freq = [~scale[3], ~scale[4]].choose});
		if((temp > 125) && (temp <= 250), {
			freq = [~scale[4], ~scale[5]].choose});
		if((temp > 250) && (temp <=370), {
			freq = [~scale[5], ~scale[6]].choose});
		if((temp > 370) && (temp <= 500), {
			freq = [~scale[6], ~scale[7]].choose});
		if((temp > 500) && (temp <= 625), {
			freq = [~scale[7], ~scale[0]*2].choose});
		if((temp > 625) && (temp <= 750), {
			freq = [~scale[0], ~scale[1]].choose});
		if((temp > 750) && (temp <= 875), {
			freq = [~scale[1], ~scale[2]*2].choose});
		if((temp > 875), {freq = [~scale[2], ~scale[3] *2].choose});
		*/
		
		if(~counter == 65, {~s5 = Synth("chaos", [\freq, temp]);
			//////////////////////////////////////////////////////////////HEY
			//send OSC msg to Open Frameworks
			~nsend.sendMsg('/waves/noisea',  1);
			/////////////////////////////////////////////////////////////HERE
		});
		
			if(~counter == 66, {
			//////////////////////////////////////////////////////////////HEY
			//send OSC msg to Open Frameworks
			~nsend.sendMsg('/waves/noisea',  0);
			/////////////////////////////////////////////////////////////HERE
			});
		
		if(~counter == 71, {~s5 = Synth("chaos", [\freq, temp]);	
			//////////////////////////////////////////////////////////////HEY
			//send OSC msg to Open Frameworks
			~nsend.sendMsg('/waves/noisea',  1);
			/////////////////////////////////////////////////////////////HERE
		});

			if(~counter == 72, {
			//////////////////////////////////////////////////////////////HEY
			//send OSC msg to Open Frameworks
			~nsend.sendMsg('/waves/noisea',  0);
			/////////////////////////////////////////////////////////////HERE
		});
		
		if((~counter > 74) && (~counter < 90), {~ampmelody = ~ampmelody + 0.01;});
		//Melody
		if((~counter > 74) && (~counter <= 100) && (~counter.even), {
			"wss2-74-100".postln;
			Synth("wss2", [
				\freq, freq,
				\pan, [temp.linlin(1, 1000, 0.45, 0.666), temp.linlin(1, 1000, 0.45, 0.666).neg].choose,
				\amp, ~ampmelody * temp.linlin(1.0, 1000, 0.7, 1.0) ]);
			
			if (even.even, {
				Synth("wss2", [
					\freq, freq/2,
					\pan,  [temp.linlin(1, 1000, 0.45, 0.666), temp.linlin(1, 1000, 0.45, 0.666).neg].choose,
					\amp, ~ampmelody * temp.linlin(1.0, 1000, 0.5, 1.0) ]);
				
				if ((even > 500) && (~counter < 110),{
					play{
						var pan = temp.linlin(1, 1000, -1.0, -0.888);
						var sig2 = ClipNoise.ar(0.8) + BrownNoise.ar(0.7);
						var envcl =
						Env.circle([0, 1, 0.001, 0], [0.001, 0.015, 1], -8).kr(doneAction:2);
						sig2 = BPF.ar(sig2, 2000, 0.5) * envcl;
						sig2 =
						sig2 * EnvGen.kr(Env.adsr(releaseTime:5), Line.kr(1,0,8), doneAction:2);
						sig2 = FreeVerb.ar(sig2, 0.33, 100);
						sig2 = sig2.clip2(0.888);
						Out.ar(0, Pan2.ar(sig2, [pan, pan.neg].choose));
					};
				})
			}.defer(0.5));
			
		});

		
		if ((~counter >= 115) && (~counter <= 140) &&
			(~counter.even) && (0.777.coin == true),{
				"clicking110-140".postln;
				play{
					var pan = temp.linlin(1, 1000, -1.0, -0.888);
					var sig2 = ClipNoise.ar(0.8) + BrownNoise.ar(0.7);
					var envcl =
					Env.circle(
						[0, 1, 0.001, 0],
						[0.001, 0.015, 1] *
						[0.125 ,0.25, 0.06].choose, -8).kr(doneAction:2);
					sig2 = BPF.ar(sig2, 2000, 0.5) * envcl;
					sig2 =
					sig2 * EnvGen.kr(Env.adsr(releaseTime:5), Line.kr(1,0,8), doneAction:2);
					sig2 = FreeVerb.ar(sig2, 0.33, 100);
					sig2 = sig2.clip2(0.888);
					Out.ar(0, Pan2.ar(sig2, [pan, pan.neg].choose));
				};
				
			});


		if((~counter >= 100) && (~counter < 106) && (~counter.even), {
			~cutoffwss = ~cutoffwss + (~cutoffwss/2);
			~cutoffwss.postln});
		
		if((~counter >= 100)
			&& (~counter <= 130)
			&& (~counter.even)
			&& (0.8.coin == true), {
				"wss2-100-130".postln;
				Synth("wss2", [
					\freq, freq,
					\pan, [
						temp.linlin(1, 1000, 0.25, 0.666),
						temp.linlin(1, 1000, 0.25, 0.666).neg].choose,
					\amp, ~ampmelody * 2 *  temp.linlin(1.0, 1000, 0.5, 1.0),
					\cutoff, ~cutoffwss])//cutoffwss]);
			});

		if(~counter == 173, {~s5 = Synth("chaos", [\freq, temp]);
			//////////////////////////////////////////////////////////////HEY
			//send OSC msg to Open Frameworks
			~nsend.sendMsg('/waves/noisea',  1);
			/////////////////////////////////////////////////////////////HERE			
		});
				if(~counter == 174, {
			//////////////////////////////////////////////////////////////HEY
			//send OSC msg to Open Frameworks
			~nsend.sendMsg('/waves/noisea',  0);
			/////////////////////////////////////////////////////////////HERE			
		});
		
	}, '/send' 
);

OSCdef(\max_height,
	{
		| msg, freq| 
		var temp;
		temp = msg[9].asFloat;
        //msg[9].postln;
        temp = temp.linlin(0.025, 1.300, 1, 1000);



		//////////////////////////////////////////////////////////////HEY
		//send OSC msg to Open Frameworks
		~nsend.sendMsg('/waves/max_height',  temp);
		/////////////////////////////////////////////////////////////HERE

		

		//7th and 11th
		///////////////////////////
		//1000 max freq value (so 1000 / 8 = 125 for 8 notes Ionian)
		
		if(temp <= 125, {freq = [~scale[6], ~scale[3]].choose});
		if((temp > 125) && (temp <= 250), {
			freq = [~scale[7], ~scale[4]].choose});
		if((temp > 250) && (temp <=370), {
			freq = [~scale[0], ~scale[5]].choose});
		if((temp > 370) && (temp <= 500), {
			freq = [~scale[1], ~scale[6]].choose});
		if((temp > 500) && (temp <= 625), {
			freq = [~scale[2], ~scale[7]].choose});
		if((temp > 625) && (temp <= 750), {
			freq = [~scale[3]*2, ~scale[0]*2].choose});
		if((temp > 750) && (temp <= 875), {
			freq = [~scale[4]*2, ~scale[1]*2].choose});
		if((temp > 875), {freq = [~scale[7], ~scale[1] *2].choose});
		
		
		if((~counter > 100) && (~counter < 150) && (~counter.even), {
			"nsgate-goes-in".postln;
			Synth("nsgate", [
				\freq, freq,
				\mfreq, temp * [1, 2, 4].choose,
			    \pan, temp.linlin(1, 1000, 0.9, 1.0) * [-1, 1].choose,
				\amp, temp.linlin(1, 1000, 0.5, 1.0)]);
			
			Synth("wave", [\freq, freq,
				\amp, temp.linlin(1, 1000, 0.666, 1.0) * [1, 0, 1].choose,
				\pan, temp.linlin(1,1000, -0.9, -0.5)])
			
		});
		

		if((~counter > 155) && (~counter < 170) && (~counter.even), {
			Synth("liq", [\freq, freq,
				\pan, temp.linlin(1, 1000, -0.666, 0.666) * [1, -1].choose]);
		});
		//temp.postln;
		//msg.postln;

		if((~counter > 175) && (~counter < 200) && (~counter.even), {
			Synth("bright", [\freq, freq,
				\pan, temp.linlin(1, 1000, -0.366, 0.366) * [1, -1].choose,
				\modp, 2]);
			if(0.555.coin == true,{//2nd note
				Synth("bright", [\freq, freq,
					\pan, temp.linlin(1, 1000, -0.366, 0.366) * [1, -1].choose,
					\modp, 8, \amp, temp.linlin(1, 1000, 0.333, 0.666)],
				);
			}.defer(0.333));
		});
		//~counter = 198;
			if(~counter == 205){
				~s6.set(\gate, 0);
				/*	
				play{
				var sig = Pulse.ar(200 + ((1..30) * [-1, 1].choose).normalizeSum, SinOsc.ar(100, Line.kr(pi/8, pi, 4))) * 0.01 * Line.kr(1, 0, 15).clip2(0.666)!2;
				sig = LPF.ar(sig, Line.kr(10000, 4444, 1));
				sig = Compander.ar(sig, sig, 0.666, 1.0, 0.1);
			}
					/*
				play{
	var sig = Pulse.ar(210 + ((1..30) * [-1, 1].choose).normalizeSum, SinOsc.ar(100, Line.kr(pi/8, pi, 4))) * 0.014 * Line.kr(1, 0, 15).clip2(0.666)!2;
					sig = LPF.ar(sig, Line.kr(10000, 4444, 1));
				sig = Compander.ar(sig, sig, 0.666, 1.0, 0.1);
							}*/ */
				//		Synth("chaos", [\amp, 0.6, \reltime, 14.25]);
			};

		if(~counter == 205){
				play{
				BPF.ar([BPF.ar(PinkNoise.ar(3), Line.kr(6666, 666, 10), 1.5).clip2(0.7), LPF.ar(WhiteNoise.ar(0.333), 10000).clip2(0.777)] + LPF.ar(WhiteNoise.ar(1.0), 222), XLine.kr(15999, 100, 11)) * Env([0, 0.3, 1, 0],[3.7, 5, 10], curve:-4).kr(doneAction:2)}
			
		};

		if(~counter == 205){
			Synth("chaos", [\amp, 0.6, \reltime, 16.25]);
		};


		if((~counter >= 205) && (~counter <= 215)){

				//////////////////////////////////////////////////////////////HEY
			//send OSC msg to Open Frameworks
			~nsend.sendMsg('/waves/noisea',  2);
			/////////////////////////////////////////////////////////////HERE
};


		
		if(~counter == 218){
				//////////////////////////////////////////////////////////////HEY
			//send OSC msg to Open Frameworks
			~nsend.sendMsg('/waves/noisea',  0);
			/////////////////////////////////////////////////////////////HERE
		};

		//STOP EVERYTHING
		if(~counter == 222){
			CmdPeriod.removeAll; s.freeAll; OSCdef.freeAll;
		};
		//STOP EVERYTHING
		
	}, '/send' // OSCmessage name
);

/*
~s6 = Synth("rezz", [\gate, 1]);
~ampmelody = 2;
~counter = 192;
~ampmelody = 1;
~cutoffwss = 100;
*/

//:-------------------------------------------------------------------------------



