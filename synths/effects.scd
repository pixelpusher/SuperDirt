
(
{
	var numChannels = ~dirt.numChannels;

	// Sonic Pi's krush
	// moified a bit so krush "0" is the same as dry signal
	~dirt.addModule('krush', { |dirtEvent| dirtEvent.sendSynth("dirt_krush" ++ ~dirt.numChannels,
		[krush: ~krush, kcutoff: ~kcutoff, out: ~out])}, { ~krush.notNil});
	SynthDef("dirt_krush" ++ ~dirt.numChannels, {|out, krush, kcutoff|
		var orig, signal, freq;
		freq = Select.kr(kcutoff > 0, [DC.kr(4000), kcutoff]);
		orig = In.ar(out, ~dirt.numChannels);
		signal = (orig.squared + (krush*orig)) / (orig.squared + (orig.abs * (krush-1.0)) + 1.0);
		signal = RLPF.ar(signal, clip(freq, 20, 10000), 1);
		signal = SelectX.ar(krush*2.0, [orig, signal]);
		ReplaceOut.ar(out, signal);
	}).add;

	// ringmod
	~dirt.addModule('ring', { |dirtEvent| dirtEvent.sendSynth("dirt_ring" ++ ~dirt.numChannels,
		[ring: ~ring, ringf: ~ringf, out: ~out])}, { ~ring.notNil});
	SynthDef("dirt_ring" ++ ~dirt.numChannels, {|out, ring=0, ringf=0|
		var signal, mod;
		signal = In.ar(out, ~dirt.numChannels);
		mod = ring * SinOsc.ar(clip(ringf, 2, 20000));
		signal = ring1(signal, mod);
		ReplaceOut.ar(out, signal);
	}).add;

	// Sonic Pi's octaver
	~dirt.addModule('octer', { |dirtEvent| dirtEvent.sendSynth("dirt_octer" ++ ~dirt.numChannels,
		[octer: ~octer, octersub: ~octersub, octersubsub: ~octersubsub, out: ~out])},
	{ ~octer.notNil or: {~octersub.notNil } or: {~osctersubsub.notNil}});
	SynthDef("dirt_octer" ++ ~dirt.numChannels, {|out, octer, octersub, octersubsub|
		var signal, oct1, oct2, oct3, sub;
		signal = In.ar(out, ~dirt.numChannels);
		oct1 = 2.0 * LeakDC.ar( abs(signal) );
		sub = LPF.ar(signal, 440);
		oct2 = ToggleFF.ar(sub);
		oct3 = ToggleFF.ar(oct2);
		signal = SelectX.ar(octer, [signal, octer*oct1, DC.ar(0)]);
		signal = signal + (octersub * oct2 * sub) + (octersubsub * oct3 * sub);
		ReplaceOut.ar(out, signal);
	}).add;

	// trying a limiter/depopper/shaper
	~dirt.addModule('wall', { |dirtEvent| dirtEvent.sendSynth("dirt_wall" ++ ~dirt.numChannels,
		[wall: ~wall, walllev: ~walllev, out: ~out])}, { ~wall.notNil});
	SynthDef("dirt_wall" ++ ~dirt.numChannels, {|out, wall=0, walllev=0.5|
		var signal, mod;
		signal = In.ar(out, ~dirt.numChannels);
		mod = signal - signal.clip2(walllev/2+0.5);
		signal = signal.clip2(walllev/2+0.5) + ((1.0-wall)*mod);
		ReplaceOut.ar(out, signal);
	}).add;

	// add envelope to lpf
	~dirt.addModule('lpf',{ |dirtEvent| dirtEvent.sendSynth("dirt_lpf" ++ ~dirt.numChannels,
		[cutoff: ~cutoff, resonance: ~resonance, out: ~out, fattack:~fattack, fhold:~fhold, frelease:~frelease,
			fenv:~fenv, flfo:~flfo, flfof:~flfof])}, { ~cutoff.notNil });
	SynthDef("dirt_lpf" ++ numChannels, { |out, cutoff = 440, resonance = 0, fattack=0, fhold=1, frelease=0, fenv=0, flfo,flfof,sustain|
		var signal = In.ar(out, numChannels);
		var env = Lag.ar(EnvGen.ar(Env.linen(fattack, fhold, frelease, 1, 0)), 0.01);
		var lfo = flfo * SinOsc.kr(flfof,0) + 1;
		// signal = RLPF.ar(signal, clip(cutoff+(env*fenv),2,20000), resonance.linexp(0, 1, 1, 0.001));
		signal = BLowPass4.ar(signal, clip(lfo*(cutoff + (env*fenv)), 2, 20000), resonance.linexp(0,1,1,0.001));
		ReplaceOut.ar(out, signal)
	}, [\ir, \ir, \ir]).add;

	// delightfully crunchy
	~dirt.addModule('distort', { |dirtEvent| dirtEvent.sendSynth("dirt_distort" ++ ~dirt.numChannels,
		[distort: ~distort, out: ~out])}, { ~distort.notNil});
	SynthDef("dirt_distort" ++ ~dirt.numChannels, {|out, distort=0|
		var signal, mod ;
		signal = In.ar(out, ~dirt.numChannels);
		mod = CrossoverDistortion.ar(signal, amp:0.2, smooth:0.01);
		mod = mod + (0.1 * distort * DynKlank.ar(`[[60,61,240,3000+SinOsc.ar(62,mul:100)],nil,[0.1, 0.1, 0.05, 0.01]], signal));
		mod = (mod.cubed * 8).softclip * 0.5;
		mod = SelectX.ar(distort, [signal, mod]);
		ReplaceOut.ar(out, mod);
	}).add;

	// this compressor is per-voice, so no memory from one sample to the next, would need a global effect for that
	~dirt.addModule('comp', { |dirtEvent|
		dirtEvent.sendSynth("dirt_comp" ++ ~dirt.numChannels,
			[comp: ~comp, compa: ~compa, compr: ~compr, out: ~out])},
	{ ~comp.notNil});
	SynthDef("dirt_comp" ++ ~dirt.numChannels, {|out, comp=0, compa=0, compr=0|
		var signal, mod, inlev, cgain;
		signal = In.ar(out, ~dirt.numChannels);
		inlev = Amplitude.ar(HPF.ar(signal, 600, 1.5), 0.01+compa, 0.02+compr);
		mod = signal / max( inlev, 0.1) * 0.3;
		mod = SelectX.ar(comp, [signal, mod]);
		ReplaceOut.ar(out, mod);
	}).add;

	// fm with a sine wave
	~dirt.addModule('fm', { |dirtEvent|
		dirtEvent.sendSynth('dirt_fm' ++ ~dirt.numChannels,
			[fm: ~fm,	fmf: ~fmf,  out: ~out	]
		)
	}, { ~fm.notNil or: { ~fmf.notNil } }); // play synth only if at least one of the two was given
	SynthDef("dirt_fm" ++ numChannels, { |out, fm, fmf |
		var signal, mod;
		signal = In.ar(out, numChannels);
		mod = SinOsc.ar(fmf * (1.0 + fm * signal), mul:fm);
		ReplaceOut.ar(out, mod + (1.0-fm)*signal);
	}).add;
}.value;
)