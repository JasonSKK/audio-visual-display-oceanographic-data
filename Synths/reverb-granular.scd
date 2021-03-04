b = Buffer.readChannel(s, "/Users/jsk/Media/SoundSamples/SuperMarketRecordingAndrew/7. fridgeNoise.wav", 60000,  100000, channels: [0]);

c = Buffer.readChannel(s, "/Users/jsk/Media/SoundSamples/Recordings_THMO_DigitalSoundSynthesis_15-6-15/kagela_stilo.wav", 0,  200000, channels: [0])

c.play
b.numFrames
//:
(
Ndef(\rev2, {
	| sndbuf |
	var input, output, sig, delrd, deltimes;
	

	//~wenva = Env([0, 1, 0.666 , 1, 0], [0.001, 0.01, 0.1, 1.5]);
	//~bnew = Buffer.sendCollection(s, ~wenva.discretize, 1);

	//input = SoundIn.ar([0,1]);
	input = Pan2.ar(PlayBuf.ar(1, b, LFNoise1.kr( 4).range(0.25, 0.33), loop: 1), 0) * 2;
	//input = SoundIn.ar([0,1]);
	delrd = LocalIn.ar(4);

	output = input + delrd[[0,1]];
	
	sig = [output[0] + output[1], output[0] - output[1], delrd[2] + delrd[3], delrd[2]-delrd[3]];

	sig = [sig[0] + sig[2], sig[1] + sig[3], sig[0]-sig[2], sig[1]-sig[3]];
	

	sig = sig * [0.25, 0.35, 0.4, 0.2] * 0.6;
	
	deltimes = [101, 143, 165, 177] * 0.001- ControlDur.ir;

	
	LocalOut.ar(DelayN.ar(sig, deltimes, deltimes));

		output =  output * GrainBuf.ar(1, Impulse.kr(10), 1, c, 1, 1, 4, 0);
	output = output  * SinOsc.ar(
		400 + LFNoise1.kr(0.5).range(-200, 200));
		output = output+ GrainIn.ar(1, Dust.kr(100), 0.01, SinOsc.ar);
	
	LocalOut.ar(DelayC.ar(sig, deltimes, deltimes));
	
	output 
	
}).play
)


//:

//And here's an alternative way of doing exactly the same thing, this time using a matrix to represent the cross-mixing of the delayed streams. The single matrix replaces all those plusses and minusses so it's a neat way to represent the mixing - see which you find most readable.

(
Ndef(\verb, {	
	var input, output, delrd, sig, deltimes;
	
	// Choose which sort of input you want by (un)commenting these lines:
	input = Pan2.ar(PlayBuf.ar(1, b, loop: 0), -0.5); // buffer playback, panned halfway left
	//input = SoundIn.ar([0,1]); // TAKE CARE of feedback - use headphones
	//input = Dust2.ar([0.1, 0.01]); // Occasional clicks
	
	// Read our 4-channel delayed signals back from the feedback loop
	delrd = LocalIn.ar(4);
	
	// This will be our eventual output, which will also be recirculated
	output = input + delrd[[0,1]];
	
	sig = output ++ delrd[[2,3]];
	// Cross-fertilise the four delay lines with each other:
	sig = ([ [1, 1, 1, 1],
	 [1, -1, 1, -1],
	 [1, 1, -1, -1],
	 [1, -1, -1, 1]] * sig).sum;
	// Attenutate the delayed signals so they decay:
	sig = sig * [0.4, 0.37, 0.333, 0.3];
	
	// Here we give delay times in milliseconds, convert to seconds,
	// then compensate with ControlDur for the one-block delay
	// which is always introduced when using the LocalIn/Out fdbk loop
	deltimes = [101, 143, 165, 177] * 0.001 - ControlDur.ir;
	
	// Apply the delays and send the signals into the feedback loop
	LocalOut.ar(DelayC.ar(sig, deltimes, deltimes));
	
	// Now let's hear it:
	output
	
}).play
)

// To stop it:
Ndef(\verb).free;