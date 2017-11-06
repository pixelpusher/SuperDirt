/*(

MIDIClient.init;
MIDIIn.connectAll;

(
SynthDef(\gooey, { arg freq=440,formfreq=100,gate=0.0,bwfreq=800;
    var x;
    x = Formant.ar(
        SinOsc.kr(0.02, 0, 10, freq),
        formfreq,
        bwfreq
    );
    x = EnvGen.kr(Env.adsr, gate,Latch.kr(gate,gate)) * x;
    Out.ar(0, x);
}).add;
);

(
x = Synth(\gooey);

//set the action:

~noteOn = {arg src, chan, num, vel;
	"source: ".post;
	src.postln;
    x.set(\freq, num.midicps / 4.0);
    x.set(\gate, vel / 200 );
    x.set(\formfreq, vel / 127 * 1000);
};
MIDIIn.addFuncTo(\noteOn, ~noteOn);

~noteOff = { arg src,chan,num,vel;
    x.set(\gate, 0.0);
};
MIDIIn.addFuncTo(\noteOff, ~noteOff);

~bend = { arg src,chan,val;
    //(val * 0.048828125).postln;
    x.set(\bwfreq, val * 0.048828125 );
};
MIDIIn.addFuncTo(\bend, ~bend);
);

);
*/