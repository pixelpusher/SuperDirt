
// cycle test
// this may lead to weird effects
(
var quant = 1.0;
~dirt.receiveAction = { |e|
	var cycle = e[\cycle];
	var cps = e[\cps];
	var latency = e[\latency];
	cycle !? {
		if(cycle % quant == 0) { // set clock only quant in cycle
			TempoClock.default.beats = cycle;
		};
	};
	cps !? {
		TempoClock.default.tempo = cps;
	};
	latency !? {
		Server.default.latency = latency;
	}
}
);




MIDIClient.init;
MIDIIn.connectAll;

(
SynthDef(\sinegrain,
    { | out=0, freq=440, sustain=0.05 |
        var env;
        env = EnvGen.kr(Env.perc(0.01, sustain, 0.2), doneAction: 2);
        Out.ar(out, SinOsc.ar(freq, 0.5pi, env))
    }).add;
);

(
//remove old ones
MIDIIn.removeFuncFrom(\noteOn, ~noteOn);
MIDIIn.removeFuncFrom(\noteOff, ~noteOff);


~noteOn = {arg src, chan, num, vel;
	"num: ".post;
	num.postln;
	~playing.stop;
	~playing = Pbind(\instrument, \sinegrain, \note, Pseq([num, num+8], inf), \dur, (1/16)).play(quant: 0);
};

MIDIIn.addFuncTo(\noteOn, ~noteOn);

~noteOff = { arg src,chan,num,vel;
    //~playing.stop;
	"stop!".postln;
};

MIDIIn.addFuncTo(\noteOff, ~noteOff);
);

// stop arpeggiator
~playing.stop;


// reset to normal:
(
~dirt.receiveAction = nil;
TempoClock.default.tempo = 1;
)




(
MIDIIn.removeFuncFrom(\noteOn, ~noteOn);
MIDIIn.removeFuncFrom(\noteOff, ~noteOff);
MIDIIn.removeFuncFrom(\polytouch, ~polytouch);
MIDIIn.removeFuncFrom(\control, ~control);
MIDIIn.removeFuncFrom(\program, ~program);
MIDIIn.removeFuncFrom(\touch, ~touch);
MIDIIn.removeFuncFrom(\bend, ~bend);
MIDIIn.removeFuncFrom(\sysex, ~sysex);
MIDIIn.removeFuncFrom(\sysrt, ~sysrt);
MIDIIn.removeFuncFrom(\smpte, ~smpte);
)