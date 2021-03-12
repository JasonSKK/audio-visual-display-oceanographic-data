~n = NetAddr("192.168.1.7", 57110);


//~asy = [~amp, ~freq, ~lfo];
~sum = 0;
SynthDef("test", {
	|freq = 444, amp = 0.5|
	var sig;
	sig = SinOsc.ar(freq) * amp;
	Out.ar([0,1],sig)
}).add;
~x = Synth("test", [\freq, 244]);
~x.set(\freq, 200)
//:
(OSCdef("acc",
    {
        |msg, time, addr, port|
		var temp;
		temp = msg[5].asFloat;
		~freq =
		temp.linexp(23.00, 25.00, 100, 1000);
		//		temp.linexp(23.00, 25.00, 100, 1000);
		//~sum = ~sum + 1; //for test
       x.set(\freq, ~freq )
    }, '/temp'
//WAS SMTH LIKE AXYC... check what touchosc sends
));
//:
"works".postln;
//:
~sum.postln;

//:
~x = Synth("test", [\freq, 244]);

~a = OSCdef(\oscTest,
	{
		| msg | 
		var temp;
		temp = msg[4].asFloat;
		temp = temp.linlin(10.0, 37.0, 100, 1000);
		temp.postln;
		//msg[6].postln;
		msg.postln;
		~x.set(\freq, temp, \amp, 0.1);
		//~muons = msg [0] [1..];
		//~muons.postln;



		// use the osc messages (msg) for the frequency
	},
	'/temp' // OSCmessage name
);

