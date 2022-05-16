// =====================================================================
// SuperCollider Workspace
// =====================================================================

~n = NetAddr("10.253.255.40", 57120);
//IP Address might change sometimes - CAREFULL IF ERROR
//"192.168.1.3"
~nsend = NetAddr("10.253.255.40", 12345);

//Scale
~scale = Scale.phrygian.degreeToFreq([0, 1, 3, 5, 7, 8, 10, 12], 59.midicps, 1);
//:
SynthDef("sin", {
	| freq = 444, modf = 1, amp = 0.5, cutoff = 1066, pan = 0, gate = 1|
	var sig, env, out;
	sig = Pulse.ar(freq) * SinOsc.ar(modf);
	sig = BPF.ar(sig, cutoff, 0.1) * 2;
	env = EnvGen.kr(Env.adsr(0.2), gate, doneAction:2);
	//env = Env.perc.kr();
	out = sig * env * amp;
	Out.ar(0, Pan2.ar(out, pan));
}).add;

//:
~synth1 = Synth("sin");
s.scope;
//o.set(\gate, 0)
//:
OSCdef(\temp, {
	| msg, modf | 
	var temp;
	//POST-ALL
	[msg[1], msg[2], msg[4], msg[7], msg[8], msg[9]].postln;
	//
	temp = msg[4].asFloat;
	temp = temp.linlin(18.96, 26.71, 1, 1000); 
	modf = temp.linlin(1, 1000, 1, 10);

	~synth1.set(\modf, modf);
	
	//////////////////////////////////////////////////////////////HEY
	//send OSC msg to Open Frameworks
	~nsend.sendMsg('/waves/temp',  temp);
	/////////////////////////////////////////////////////////////HERE

}, '/send'
);

//SIGN HEIGHT FOR NON PITCH SYNTHS - PERC OR GRANULATORS
OSCdef(\sign_height,
	{
		| msg, amp = 0.0| 
		var temp;
		temp = msg[7].asFloat;
        //msg[7].postln;
        temp = temp.linlin(0.020, 0.880, 1, 1000);
		amp = temp.linlin(1, 1000, 0.1, 0.9);

		~synth1.set(\amp, amp);
		
		//send OSC msg to Open Frameworks
		~nsend.sendMsg('/waves/sign_height',  temp);
		/////////////////////////////////////////////////////////////HERE
			//if((~counter == 19), {Synth("chaos")});
	}, '/send' 
);

OSCdef(\zero_upcrossing,
	{
		| msg, freq | 
		var temp, even;
		temp = msg[8].asFloat;
        temp = temp.linlin(3.2, 8.7, 1, 1000);
		
		if(temp <= 125, {freq = ~scale[0]});
	if((temp > 125) && (temp <= 250), {
		freq = ~scale[1]});
	if((temp > 250) && (temp <=370), {
		freq = ~scale[2]});
	if((temp > 370) && (temp <= 500), {
		freq = ~scale[3]});
	if((temp > 500) && (temp <= 625), {
		freq = ~scale[4]});
	if((temp > 625) && (temp <= 750), {
		freq = ~scale[5]});
	if((temp > 750) && (temp <= 875), {
		freq = ~scale[6]});
	if((temp > 875), {freq = ~scale[7]});

		~synth1.set(\freq, freq);
		//////////////////////////////////////////////////////////////HEY
		//send OSC msg to Open Frameworks
		~nsend.sendMsg('/waves/zero_upcrossing',  temp);
		/////////////////////////////////////////////////////////////HERE

				
	}, '/send' 
);

OSCdef(\max_height,
	{
		| msg, cutoff | 
		var temp;
		temp = msg[9].asFloat;
        //msg[9].postln;
        temp = temp.linlin(0.025, 1.300, 1, 1000);
		cutoff = temp.linlin(1, 1000, 100, 20000);
		
		~synth1.set(\cutoff, cutoff.lag(0.5));
		//////////////////////////////////////////////////////////////HEY
		//send OSC msg to Open Frameworks
		~nsend.sendMsg('/waves/max_height',  temp);
		/////////////////////////////////////////////////////////////HERE
		
	}, '/send' // OSCmessage name
);
