/*

Add your own instruments here.
They can be used in Tidal just as samples (ignoring the sample number, so instead of "bd:2" write "inr")

// supported parameters are e.g.
// sustain, speed, endSpeed, begin, end, pan, accelerate, offset, cps
// all instruments ought to use: out

If your SuperDirt instance is assigned to the variable ~dirt, you can livecode these synths.
*/

(

// modulated band limited impulse
SynthDef(\imp, { |out, sustain = 1, freq = 440, speed = 1, begin=0, end=1, pan, accelerate, amp = 1, offset|
	var env, sound, rate, phase;
	env = EnvGen.ar(Env.perc(0.01, 0.99, amp * 0.1, -1), timeScale:sustain, doneAction:2);
	phase = Line.kr(begin, end, sustain);
	rate = (begin + 1) * (speed + Sweep.kr(1, accelerate));
	sound = Blip.ar(rate.linexp(0, 1, 1, freq) * [1, 1.25, 1.51, 1.42], ExpRand(80, 118) * phase).sum;
	OffsetOut.ar(out,
		DirtPan.ar(sound, ~dirt.numChannels, pan, env)
	)
}).add;

// cursor modulated phase mod sines
SynthDef(\pmsin, { |out, sustain = 1, freq = 440, speed = 1, begin=0, end=1, pan, accelerate, offset|
	var env, sound, rate, phase, modfreq, amp;
	freq = (MouseX.kr(30, 80).round + freq);
	modfreq = MouseY.kr(1, 200, 1);
	amp = AmpCompA.kr(freq);
	env = EnvGen.ar(Env.perc(0.002, sustain, 1, -1), doneAction:2);
	phase = Line.ar(begin, end, sustain);
	rate = speed + Sweep.kr(1, accelerate);
	sound = SinOsc.ar(freq, SinOsc.ar(modfreq * (1..5), 0, 1 - phase * 10 * env / (1..5), 0.5pi)).sum;
	OffsetOut.ar(out,
		DirtPan.ar(sound, ~dirt.numChannels, pan, env)
	)
}).add;

// live audio input
SynthDef(\in, { |out, sustain = 1, speed = 1, begin = 0, end = 1, pan, accelerate, amp = 1, offset|
	var env, sound, rate, phase;
	phase = Line.ar(begin, end, sustain);
	rate = (begin + 1) * (speed + Sweep.kr(1, accelerate));
	sound = SoundIn.ar([0, 1]); // stereo in
	OffsetOut.ar(out,
		DirtPan.ar(sound, ~dirt.numChannels, pan, amp)
	)
}).add;

// pitch shifted live audio input
SynthDef(\inr, { |out, sustain = 1, freq = 440, speed = 1, begin=0, end=1, pan, accelerate, amp = 1, offset|
	var env, sound, rate, phase;
	phase = Line.ar(begin, end, sustain);
	rate = (begin + 1) * (speed + Sweep.kr(1, accelerate)) * freq / 440;
	sound = SoundIn.ar([0, 1]); // stereo in
	sound = PitchShift.ar(sound, 0.1, rate, 0.02, 0.01);
	OffsetOut.ar(out,
		DirtPan.ar(sound, ~dirt.numChannels, pan, amp)
	)
}).add;

// gabor grain
(
SynthDef(\gabor, { |out, sustain = 0.03, freq = 440, amp = 1, pan = 0, width = 0.3|
	var env, sound;
	sound = SinOsc.ar(freq, 0.5pi);
	env = LFGauss.ar(sustain, width, loop: 0).range(0, 1);
	OffsetOut.ar(out,
		DirtPan.ar(env * sound, ~dirt.numChannels, pan, amp)
	)
}).add;
);

// dirac delta function approximation
(
SynthDef(\dirac, { |out, sustain = 0.03, amp = 1, pan = 0|
	OffsetOut.ar(out,
		DirtPan.ar(Impulse.ar(0), ~dirt.numChannels, pan, amp)
  )
}).add;
);

);

// sine wavy by obtuse pamplemousse
(
SynthDef(\sinetone, { |out, sustain = 0.1, note = 0, amp = 1, pan = 0, width = 0.5, speed = 60|
	var env, sound, freq, additiv1, additiv2, additiv3, additiv4, phase, basenote, slowsin1;

	freq = (note + 0).midicps;
	slowsin1 = SinOsc.ar(freq/(4*48),0,0.025);
	basenote = 261.63*3; //middle

	additiv1 = SinOsc.ar(freq, SinOsc.kr( speed*8 ).range(0,pi),  0.015); // cancels out at half phase!

	additiv2 = SinOsc.ar(freq, slowsin1, 0.0275);

	additiv4 = SinOsc.ar(freq/8, SinOsc.kr( speed/2).range(0,pi), 0.0475);

	additiv3 = SinOsc.ar(freq/2, SinOsc.kr( speed*2).range(0.05,pi+0.05),  0.025);

	//additiv1 = additiv1 + FreqShift.ar(additiv1, 0, SinOsc.kr(0.5).range(0,pi));

	sound = Pan2.ar( additiv1 + additiv2 + additiv3 + additiv4 + slowsin1, 0);
	//env = LFGauss.ar(sustain, width, loop: 0);

	env = EnvGen.ar(Env.perc(0.002, sustain, amp * 0.1, -1), doneAction:2);

	OffsetOut.ar(out,
		DirtPan.ar(env * sound, ~dirt.numChannels, pan, amp)
	)
}).add;
);

(
// mooger
SynthDef(\ffmoog, { |out, sustain = 1, note = 0, speed = 1, begin=0, end=1, pan, accelerate, amp = 1, offset=0,  up = 0|
	var env, sound, rate, phase, freq, modfreq;

	env = EnvGen.ar(Env.perc(0.002, sustain, amp * 0.1, -1), doneAction:2);

	freq = (note + 16 + up).midicps;

	amp = AmpCompA.kr(freq) * amp;

	rate = speed + Sweep.kr(1, accelerate);

	sound  = MoogFF.ar(

		Mix(Saw.ar([0.99,1,1.01]*freq, amp)),

		//MouseX.kr(100,20000,\exponential), // cutoff freq.
		rate*20000,

		MouseY.kr(0.1, 4.0, \linear) //gain

		);


	OffsetOut.ar(out,
		DirtPan.ar(sound, ~dirt.numChannels, pan, env)
	)
}).add;
);

(
//no use of gate, fixed length
SynthDef(\laserbeam,{|out, sustain = 1, note = 0, speed = 1, begin=0, end=1, pan, accelerate, amp = 1, offset =0, up = 0|

	var osc1, freqenv, ampenv, freq, sound;

	freq = speed*(note + 16 + up).midicps;

	amp = AmpCompA.kr(freq) * amp;

	freqenv = EnvGen.ar(Env([4,0.5,1,1],[sustain,0.01,1.0]));

	//freqenv = EnvGen.ar(Env([4,0.5,1,1],[0.05,0.01,1.0]));

	osc1 = LFTri.ar(freq*freqenv);

	//env = EnvGen.ar(Env.adsr(0.01,0.0,1.0,0.1),gate,doneAction:2);
	//no gate, fixed envelope size
	ampenv = EnvGen.ar(Env([0,1,0.5,0.0],[0.02,0.2,0.1]),doneAction:2);


	OffsetOut.ar(out,
		DirtPan.ar(osc1*amp, ~dirt.numChannels, pan, ampenv)
		//DirtPan.ar(sound, ~dirt.numChannels, pan, ampenv)
	)
}).add;
);



(
// from bgold
// vibraphone simulator, adapted with some help from Kevin Larke's thesis Real Time Vibraphone Pitch and Timbre Classification
SynthDef(\supervibe, {|out, speed=1, sustain=1, decay=0, pan, freq, accelerate=0, velocity=1, modamp=1, modfreq=7.0  up = 0|
	// most envelope shaping is done with XLines later, this envelope is just to clean up overall
    var env = EnvGen.ar(Env.linen(0.001, 0.998, 0.001), timeScale:sustain, doneAction:2);
    var sound, mod, freqs, hifreqs, decays;
	freq = freq + up;
    freqs = freq * Line.kr(1, 1+accelerate, sustain) * [1, 4, 10, 13.75];
    hifreqs = freq * Line.kr(1, 1+accelerate, sustain) * [19.2, 20, 21.2];
    mod = SinOsc.kr(modfreq, Rand(0,2pi)).range(1-([0.5,0.3,0.3,0.5]*modamp),1);
    sound = 0.3 * [1, 1.1*velocity, 0.6*velocity*velocity, 0.5*velocity] * SinOsc.ar(freqs);
    decays = [1, 0.7*exp(-1.0*decay), 0.5*exp(-1.0*decay), 0.4*exp(-1.0*decay)]; // use `decay` to damp harmonics
    sound = XLine.ar(1e-6, 1, 1/freqs) * XLine.ar(1, 1e-6, decays*4*sustain) * sound * mod; // main attacks and decays
    sound = (XLine.ar(0.3*(velocity+1e-6),1e-6,0.02) * SinOsc.ar(hifreqs)).sum + sound.sum; // hi frequency onset
    OffsetOut.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, env));
}).add;
);




(
SynthDef(\profit5,{|out=0 speed=1.0 accelerate = 0.33 freq = 440 velocity = 1.0 gate = 1 lforate = 10 lfowidth = 0.5 cutfreq = 12000 rq = 0.5 pan = 0.0 sustain = 0.25 up = 0|

	var lfo, pulse, filter, clip, env, sound;

	freq = freq + up;

	lfo = LFCub.kr(lforate*[1,1.01],Rand(0,0.5)!2);

	pulse = PulseDPW.ar((freq)*speed*[1,1.01],lfo*lfowidth+0.5);

	filter = RLPF.ar(pulse,cutfreq,rq);

	//clip = Clip.ar (filter, lo: -0.95, hi: 0.95);

	env = EnvGen.ar(Env.adsr(accelerate,0.0,0.95,sustain),gate,doneAction:2);

	sound = Pan2.ar(Mix(filter)*env*velocity*0.25,pan);

	OffsetOut.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, env));
}).add
)


// (
// Pbind(
// 	\instrument,\prophet5pwmstrings,
// 	\midinote,Pseq([0,1,3,7,5,1,7,3]+64,inf),
// 	\dur,Pseq((0.5!2) ++ (0.25!4) ++ (0.125!4),inf),
// 	\lfowidth,Pn(Pseries(0.0,0.025,7),inf),
// 	\lforate,Pn(Pseries(2,1,11),inf),
// 	\cutoff, Pn(Pseries(400,12000,8),inf),
// 	\rq,Pn(Pseries(0.4,0.1,5),inf)
// ).play
// )
