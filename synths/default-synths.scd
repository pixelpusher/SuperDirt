/*

Add your own instruments here.
They can be used in Tidal just as samples (ignoring the sample number, so instead of "bd:2" write "inr")

// supported parameters are e.g.
// sustain, speed, endSpeed, begin, end, pan, accelerate, offset, cps
// all instruments ought to use: out

If your SuperDirt instance is assigned to the variable ~dirt, you can livecode these synths.
*/

~lastNote = 0; // for midi synths

(

// modulated band limited impulse
(
SynthDef(\imp, { |out, sustain = 1, freq = 440, speed = 1, begin=0, end=1, pan, accelerate, offset|
	var env, sound, rate, phase;
	env = EnvGen.ar(Env.perc(0.01, 0.99, 1, -1), timeScale:sustain, doneAction:2);
	phase = Line.kr(begin, end, sustain);
	rate = (begin + 1) * (speed + Sweep.kr(1, accelerate));
	sound = Blip.ar(rate.linexp(0, 1, 1, freq) * [1, 1.25, 1.51, 1.42], ExpRand(80, 118) * phase).sum;
	OffsetOut.ar(out,
		DirtPan.ar(sound, ~dirt.numChannels, pan, env)
	)
}).add
);


// modulated phase mod sines
(
SynthDef(\psin, { |out, sustain = 1, freq = 440, speed = 1, begin=0, end=1, pan, accelerate, offset, modfreq = 40|
	var env, sound, rate, phase, amp;
	amp = AmpCompA.kr(freq);
	env = EnvGen.ar(Env.perc(0.002, sustain, 1, -1), doneAction:2);
	phase = Line.ar(begin, end, sustain);
	rate = speed + Sweep.kr(1, accelerate);
	sound = SinOsc.ar(freq, SinOsc.ar(modfreq * (1..5), 0, 1 - phase * 10 * env / (1..5), 0.5pi)).sum;
	OffsetOut.ar(out,
		DirtPan.ar(sound, ~dirt.numChannels, pan, env)
	)
}).add
);

// cursor modulated phase mod sines
(
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
}).add
);

// live audio input
(
SynthDef(\in, { |out, sustain = 1, speed = 1, begin = 0, end = 1, pan, accelerate, offset|
	var env, sound, rate, phase;
	phase = Line.ar(begin, end, sustain);
	rate = (begin + 1) * (speed + Sweep.kr(1, accelerate));
	sound = SoundIn.ar([0, 1]); // stereo in
	OffsetOut.ar(out,
		DirtPan.ar(sound, ~dirt.numChannels, pan)
	)
}).add
);

// pitch shifted live audio input
(
SynthDef(\inr, { |out, sustain = 1, freq = 440, speed = 1, begin=0, end=1, pan, accelerate, offset|
	var env, sound, rate, phase;
	phase = Line.ar(begin, end, sustain);
	rate = (begin + 1) * (speed + Sweep.kr(1, accelerate)) * freq / 440;
	sound = SoundIn.ar([0, 1]); // stereo in
	sound = PitchShift.ar(sound, 0.1, rate, 0.02, 0.01);
	OffsetOut.ar(out,
		DirtPan.ar(sound, ~dirt.numChannels, pan)
	)
}).add
);

// gabor grain
(
SynthDef(\gabor, { |out, sustain = 0.03, freq = 440, pan = 0, width = 0.3|
	var env, sound;
	sound = SinOsc.ar(freq, 0.5pi);
	env = LFGauss.ar(sustain, width, loop: 0).range(0, 1);
	OffsetOut.ar(out,
		DirtPan.ar(env * sound, ~dirt.numChannels, pan)
	)
}).add;
);

// dirac delta function approximation
(
SynthDef(\dirac, { |out, sustain = 0.03, pan = 0|
	OffsetOut.ar(out, DirtPan.ar(Impulse.ar(0), ~dirt.numChannels, pan)
  )
}).add;
);

);

// sine wavy by obtuse pamplemousse
(
SynthDef(\sinetone, { |out, sustain = 0.1, note = 0, amp = 1, pan = 0, width = 0.5, speed = 60 up =0|
	var env, sound, freq, additiv1, additiv2, additiv3, additiv4, phase, basenote, slowsin1;

	freq = (note + up).midicps;
	slowsin1 = SinOsc.ar(freq/(4*48),0,0.5);
	additiv1 = SinOsc.ar(freq, SinOsc.kr( speed*8 ).range(0,pi),  0.25); // cancels out at half phase!

	additiv2 = SinOsc.ar(freq, slowsin1, amp*0.775);

	additiv4 = SinOsc.ar(freq/8, SinOsc.kr( speed/2).range(0,pi), amp*0.4475);

	additiv3 = SinOsc.ar(freq/2, SinOsc.kr( speed*2).range(0.05,pi+0.05),  amp*0.525);

	//additiv1 = additiv1 + FreqShift.ar(additiv1, 0, SinOsc.kr(0.5).range(0,pi));

	sound = Pan2.ar( additiv1 + additiv2 + additiv3 + additiv4 + slowsin1, 0);
	//env = LFGauss.ar(sustain, width, loop: 0);

	env = EnvGen.ar(Env.perc(0.004, sustain, amp, -1), doneAction:2);

	OffsetOut.ar(out,
		DirtPan.ar(env * sound, ~dirt.numChannels, pan, amp)
	)
}).add;
);

/*(
// mooger
SynthDef(\ffmoog, { |out, sustain = 1, note = 0, speed = 1, begin=0, end=1, pan, accelerate=0.5, amp = 1, offset=0,  velocity=1 up = 0|
	var env, env2, sound, rate, freq, modfreq;

	env = EnvGen.ar(Env.perc(0.002, sustain, amp * 0.1, -1), doneAction:2);

	freq = speed*(note + 12 + up).midicps;

	env2 = AmpCompA.kr(freq);

	rate = velocity + Sweep.kr(1, accelerate);

	sound  = MoogFF.ar(

		Mix(Saw.ar([0.99,1,1.01]*freq, env2)),

		//MouseX.kr(100,20000,\exponential), // cutoff freq.
		rate*20000,

		MouseY.kr(0.1, 4.0, \linear) //gain

		);

	OffsetOut.ar(out,
		DirtPan.ar(env*sound, ~dirt.numChannels, pan, amp)
	)
}).add;
);*/

(
//no use of gate, fixed length
SynthDef(\laserbeam,{|out, sustain = 1, freq, speed = 1, begin=0, end=1, pan, accelerate, amp = 1, offset =0, up = 0|

	var osc1, freqenv, ampenv, sound;

	//freq = speed*(note + 12 + up).midicps;

	amp = AmpCompA.kr(freq) * amp;

	//freqenv = EnvGen.ar(Env([4,0.5,1,1],[sustain,0.01,1.0]));
	freqenv = EnvGen.ar(Env.linen(0.002, 0.996, 0.002, 1,-3), timeScale:sustain, doneAction:2);

	//freqenv = EnvGen.ar(Env([4,0.5,1,1],[0.05,0.01,1.0]));

	osc1 = LFTri.ar(freq*freqenv);

	//env = EnvGen.ar(Env.adsr(0.01,0.0,1.0,0.1),gate,doneAction:2);
	//no gate, fixed envelope size
	ampenv = EnvGen.ar(Env([0,1,0.5,0.0],[0.02,0.2,0.1]),doneAction:2);

	sound  = osc1*amp;

	sound = sound + BPF.ar(sound, 521, 0.8);

	sound = RLPF.ar(sound, freq*2, 0.1);

	sound = Normalizer.ar(sound);

	OffsetOut.ar(out,
		DirtPan.ar(sound, ~dirt.numChannels, pan, ampenv)
		//DirtPan.ar(sound, ~dirt.numChannels, pan, ampenv)
	)
}).add;
);



(
SynthDef(\profit5,{|out=0, speed=1.0, accelerate = 0.1, freq = 440, velocity = 1.0, begin=0, end=1, gate = 1, lforate = 10, lfowidth = 0.5, cutfreq = 12000, rq = 0.5, pan = 0.0, sustain = 0.25, up = 0|

	var lfo, pulse, filter, clip, env, line, envGen, sound;

	freq = freq + up;

	lfo = LFCub.kr(lforate*[1,1.01],Rand(0,0.5)!2);

	pulse = PulseDPW.ar((freq)*speed*[1,1.01],lfo*lfowidth+0.5);

	filter = RLPF.ar(pulse,cutfreq,rq);

	//clip = Clip.ar (filter, lo: -0.95, hi: 0.95);

	//env = EnvGen.ar(Env.adsr(accelerate,0.0,0.95,sustain),gate,doneAction:2);

	line = Line.ar(begin, end, sustain, doneAction:2);
	env = Env([0, 1, 0],[0.2,5], curve:2);
	envGen = IEnvGen.ar(env, line*env.times.sum*abs(speed));

	sound = Pan2.ar(Mix(filter)*envGen*velocity*0.25,pan);

	OffsetOut.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, envGen));
}).add
);

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

(
//no use of gate, fixed length
SynthDef(\moogbasstone,{|out= 0 speed = 1.0 accelerate = 0.1 freq = 440 begin=0 end=0 velocity = 0.8 gate=1 cutfreq= 1000 gain=1.0 sustain = 0.01 pan=0.0 up = 0|

	var osc, filter, env, filterenv, sound, envGen, line, env2, chorus;

	//osc = Mix(VarSaw.ar(freq.lag(sustain)*[1.0,1.001,2.0],Rand(0.0,1.0)!3,Rand(0.5,0.75)!3,0.33));

	//alternative: richer source: see moogbasstone2 below
	osc = Mix(Pulse.ar(freq.lag(sustain)*[1.0,1.001,2.0]),Rand(0.45,0.5)!3,0.33);
	env = Env([1, 1, 0],[0.1,5], curve:3);
	line = Line.ar(begin, end, sustain, doneAction:2);
	envGen = IEnvGen.ar(env, line*env.times.sum*abs(speed));

//	filterenv = EnvGen.ar(Env.adsr(0.2,0.0,1.0,0.2),gate,doneAction:2);

	filter =  MoogFF.ar(osc,cutfreq*(1.0+(0.5*envGen)),gain);

//	env = EnvGen.ar(Env.adsr(0.001,0.3,0.9,0.2),gate,doneAction:2);

	//sound = Pan2.ar(Mix(filter)*envGen*velocity*0.25,pan);

	sound = Pan2.ar((0.7*filter+(0.3*filter.distort))*envGen*velocity*1.5,pan);

	//env2 = Line.kr(gate, 0.1, 1, 0.1, 2);

	chorus= Mix.fill(7, {
		var maxdelaytime= rrand(0.005,0.02);

		DelayC.ar(sound, maxdelaytime,LFNoise1.kr(Rand(4.5,10.5),0.25*maxdelaytime,0.75*maxdelaytime) )
	});


// with compression

   chorus= Splay.ar(Array.fill(4,{
		var maxdelaytime= rrand(0.005,0.02);

		DelayC.ar(sound[0], maxdelaytime,LFNoise1.kr(Rand(0.1,0.6),0.25*maxdelaytime,0.75*maxdelaytime) )
	}));

	chorus = Compander.ar(4*(sound + chorus),sound,0.4,1,4);

	OffsetOut.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, envGen));


}).add;
);


(
//
// rough noise
//
SynthDef(\rough, {|out, speed=4, sustain=1, decay=0, pan, gate=1, freq, accelerate=0, velocity=0.8, modfreq=1.0  up = 0|
    var sound, swr, son, sweep, trig, env;

	// most envelope shaping is done with XLines later, this envelope is just to clean up overall
    //env = EnvGen.ar(Env.adsr(0.2,0.0,1.0,0.2),gate,doneAction:2);

	//perc (attackTime: 0.01, releaseTime: 1, level: 1, curve: -4)

	env = EnvGen.kr(Env.perc(0.01, sustain, 0.8, -3), 1, doneAction:2);

	//Env.perc(0.01, 1, 1, -3).test.plot;

	freq = freq + up;

	swr = freq*(1.499);
	trig = Impulse.kr(speed);

	sweep = LFTri.ar(swr).exprange(80, 2000);

	son = LFSaw.ar(freq * [0.99, 1, 1.01]).sum;
	son = LPF.ar(son, sweep);

	son = son + BPF.ar(son, modfreq*(2*freq)*FSinOsc.kr(0.1,0.0,0.4), 0.5);

	son = Normalizer.ar(son);

	son = son + BPF.ar(son, 1500, 2);

	son = RLPF.ar(son + SinOsc.ar(freq,0,LFTri.ar(swr,mul:2,add:1)).tanh, freq*4, 0.4);

	//////// special flavours:
	// hi manster
	//son = Select.ar(TRand.kr(trig: trig) < 0.8, [son, HPF.ar(son, 2000) * 4]);
	// sweep manster
	//son = Select.ar(TRand.kr(trig: trig) < 0.5, [son, HPF.ar(son, sweep*0.5) * 4]);
	// decimate
	//son = Select.ar(TRand.kr(trig: trig) < 0.2, [son, son.round(0.2)]);

	son = son + GVerb.ar(son, 9, 0.1, 0.7, mul: 0.1);
	son = (son * 2).clip2;

	// comment this out?
	//son = 0.5*son + 0.7*RLPF.ar(son + SinOsc.ar(freq,0,LFTri.ar(swr,mul:2,add:1)).tanh, freqspeed *4, 0.4);

	sound = FreeVerb.ar(((son*velocity)).tanh, 0.3, 0.65)*0.8;

    OffsetOut.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, env));
}).add;
);

// shepard on a cycle
(
SynthDef(\cyclo, { |out, freq, sustain = 1, speed = 1, begin = 0, end = 1, pan, accelerate, cycle, ratio = 1|
	var env, sound, rate, phase;

	env = EnvGen.ar(Env.perc(0.01, 0.99, 1, -1), timeScale:sustain, doneAction:2);
	phase = Line.kr(begin, 1 - end, sustain);
	rate = (begin + 1) * (speed + Sweep.kr(1, accelerate));

	freq = (cycle * speed) % ((1..16) * ratio + phase) + 1 * freq * rate;

	sound = SinOsc.ar(freq).mean;
	OffsetOut.ar(out,
		DirtPan.ar(sound, ~dirt.numChannels, pan, env)
	)
}).add
);


(
//
// rough noise
//
SynthDef(\rough2, {|out, speed=4, sustain=1, decay=0, pan, gate=1, freq, accelerate=0, velocity=0.8, modfreq=1500.0  up = 0|
    var sound, swr, son, sweep, trig, env;

	env = EnvGen.kr(Env.perc(0.01, sustain, 0.8, -3), 1, doneAction:2);

	freq = freq + up;
	swr = [0.5, 1, 2, 3, 4, 6].choose; // random number from list
	sweep = LFTri.ar(swr).exprange(40, 3000);
	son = Blip.ar(freq * swr * LFSaw.ar(freq * [0.99, 1, 1.01]), 200).sum;

	son = LPF.ar(son, sweep);
	son = Normalizer.ar(son);
	son = son + BPF.ar(son, modfreq, 2); //arbitrary

//////// special flavours:
// hi manster
son = Select.ar(TRand.kr(trig: env) < 0.4, [son, HPF.ar(son, 2000) * 4]);

// sweep manster
son = Select.ar(TRand.kr(trig: env) < 0.5, [son, HPF.ar(son, sweep*0.5) * 4]);

// decimate
son = Select.ar(TRand.kr(trig: env) < 0.2, [son, son.round(0.2)]);
	son = son + GVerb.ar(son, 9, 0.1, 0.7, mul: 0.1);
	son = (son * 2).clip2;

	// comment this out?
	//son = 0.5*son + 0.7*RLPF.ar(son + SinOsc.ar(freq,0,LFTri.ar(swr,mul:2,add:1)).tanh, freqspeed *4, 0.4);

	sound = FreeVerb.ar(((son*velocity)).tanh, 0.3, 0.65)*0.8;

    OffsetOut.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, env));
}).add;
);


(
//
// another bass drum stolen from somewhere...
// works best at freq 40 Hz or so
//
SynthDef(\bdsynth, {|out, speed=1, sustain=0.25, decay=0, pan, freq, gate=1, accelerate=0, velocity=2.5, modfreq=1.0  up = 0|
	var sound, bd, sd, bassenv;

	// funkier...
	//bassenv = EnvGen.ar(Env.perc(0.001, sustain, 1, 0.2), 4, doneAction:2);

	bassenv = Decay.ar(T2A.ar(Impulse.kr(0)),sustain*3);

	freq = (freq + up.midicps)/12;

	//bd = FreeVerb.ar( SinOsc.ar(freq+(bassenv**2*freq*modfreq*3),0,7*bassenv).clip2 + SinOsc.ar(freq+(bassenv**2*freq*modfreq),0,0.8*bassenv).clip2);

	bd = FreeVerb.ar(SinOsc.ar(freq+(bassenv**2*freq),0,velocity*bassenv).clip2, 0.3, 0.5, 0.2);
	sound = bd.tanh*2;
	sound = FreeVerb.ar(sound, 0.3, 0.65);

	OffsetOut.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, bassenv));
}).add;
);




(
//
// another bass drum stolen from somewhere...
// works best at freq 40 Hz or so
//
SynthDef(\dubby, {|out, speed=1, sustain=0.25, pan, freq, gate=1, accelerate=0, up = 0|
	var sound, son, swr, sweep, sus;

	//freq = (freq + up.midicps);

	//swr = Demand.kr(Impulse.kr(0), 0, Drand(sustain*[0.5, 1, 2, 3, 4, 6]));
	son = LFSaw.ar(freq * [0.99, 1, 1.01]).sum;
	sus = Select.kr(TRand.kr()*5, sustain*[0.5, 1, 2, 3, 4, 6]);
	swr = Decay.kr(Impulse.kr(0),sus);
	sweep = LFTri.ar(swr).exprange(40, 3000);

	son = LPF.ar(son, sweep);
	son = Normalizer.ar(son);
	son = son + BPF.ar(son, 1500, 2);


	//////// special flavours:
	// hi manster

	son = Select.ar(TRand.kr() < 0.4, [son, HPF.ar(son, 2000) * 4]);

	// sweep manster

	son = Select.ar(TRand.kr() < 0.5, [son, HPF.ar(son, sweep*0.5) * 4]);

	// decimate
	son = Select.ar(TRand.kr() < 0.2, [son, son.round(0.2)]);

	son = son + GVerb.ar(son, 9, 0.1, 0.7, mul: 0.1);
	son = (son * 2).clip2;

	son = son*0.5 + 1.25*RLPF.ar(son + SinOsc.ar(freq,0,LFTri.ar(swr,mul:2,add:1)), freq*4, 0.8);

	sound = FreeVerb.ar(((son*0.5)).tanh, 0.3, 0.65);

	OffsetOut.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, swr));
}).add;
);
