(
SynthDef(\kalimba, {
	|out, sustain = 1, freq = 440, speed = 1, begin=0, end=1, pan, accelerate, offset, mix=0.1, cutfreq=1600|
    var snd, click;
    var line = Line.ar(begin, end, sustain, doneAction:2);
    var env = Env([0.03, 1, 0.1], [0.03, 1], curve:-3);

    // Basic tone is a SinOsc
	var envGen = IEnvGen.ar(env, line*env.times.sum*abs(speed));
    //snd = SinOsc.ar(freq*speed);
	//snd = SinOsc.ar(freq) * EnvGen.ar( Env.perc(0.03, Rand(3.0, 4.0), 1, -7), doneAction: 2);
	snd = (SinOsc.ar(freq*[1.0001,0.9999]*abs(speed))*2).tanh;
	//snd = (SinOsc.ar(freq*[1.0001,0.9999]*abs(speed)));

	snd = HPF.ar( LPF.ar(snd, 380), 120);
    // The "clicking" sounds are modeled with a bank of resonators excited by enveloped white noise
	click = DynKlank.ar(`[
        // the resonant frequencies are randomized a little to add variation
        // there are two high resonant freqs and one quiet "bass" freq to give it some depth
        [240*ExpRand(0.97, 1.02), 2020*ExpRand(0.97, 1.02), 3151*ExpRand(0.97, 1.02)],
        [-9, 0, -5].dbamp,
        [0.8, 0.07, 0.08]
	], BPF.ar(PinkNoise.ar, 6500, 0.1) * EnvGen.ar(Env.perc(0.001, 0.01))) * 0.1;
	snd = MoogFF.ar(snd, SinOsc.kr(0.08, 0.5, cutfreq/2, cutfreq), 3, 0);

	snd = (snd*mix) + (click*(1-mix));
	snd = 1.5*Mix( snd );
	Out.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, envGen));
}).add;


SynthDef(\donk, {
    |out, sustain = 1, freq = 440, speed = 1, begin=0, end=1, pan, accelerate, offset|
    var line = Line.ar(begin, end, sustain, doneAction:2);
    var env = Env([0, 1, 0], [0.01, 1], curve:-3);
    var envGen = IEnvGen.ar(env, line*env.times.sum*abs(speed));
    var modulator = (SinOsc.ar(freq*[1.0001,0.9999]*abs(speed))*2).tanh;
    var carrier = (SinOsc.ar((freq/4)+(modulator*1000*envGen))*0.8).tanh;
    var sound = DirtPan.ar(carrier, ~dirt.numChannels, pan, envGen);
    Out.ar(out, sound);
}).add;

SynthDef(\wub, {
  |out, sustain = 1, freq = 440, speed = 1, begin=0, end=1, pan, accelerate, offset|
  var line = Line.ar(begin, end, sustain, doneAction:2);
  var env = Env([0, 1, 0],[1,5], curve:2);
  var envGen = IEnvGen.ar(env, line*env.times.sum*abs(speed));
  // --- //
  var speedFreq = freq*abs(speed)/4;
  var mod = Latch.ar((SinOsc.ar(speedFreq*[7,11,13,5])*5).tanh*2000*envGen, Saw.ar(21000*envGen));
  var car =  Latch.ar(((SinOsc.ar(speedFreq+mod)*10)+(SinOsc.ar(speedFreq)!2)).tanh, Saw.ar(21000*envGen));
  var sound = LPF.ar(car, DC.ar(20000)*envGen+DC.ar(10))*(-11.dbamp);
  Out.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, envGen));
}).add;

SynthDef(\sawpluck, {
  |out, sustain = 1, freq = 440, speed = 1, begin=0, end=1, pan, accelerate, offset|
  var line = Line.ar(begin, end, sustain, doneAction:2);
  var env = Env([0, 1, 0.333, 0],[5, 70, 1000]);
  var envGen = IEnvGen.ar(env, line*env.times.sum*abs(speed));
  var sound = Saw.ar(freq*abs(speed));
  Out.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, envGen));
}).add;

SynthDef(\vibsawpluck, {
  |out, sustain = 1, freq = 440, speed = 1, begin=0, end=1, pan, accelerate, offset|
  var line = Line.ar(begin, end, sustain, doneAction:2);
  var env = Env([0, 1, 0.333, 0],[5, 70, 1000]);
  var envGen = IEnvGen.ar(env, line*env.times.sum*abs(speed));
  var sound = Saw.ar(freq*abs(speed)+(SinOsc.ar(10)*(freq*0.06)*line*line));
  sound = RLPF.ar(sound, Clip.ar(envGen*freq*48, 0, 20000), 0.5);
  Out.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, envGen));
}).add;

SynthDef(\wob, {
  |out, sustain = 1, freq = 440, speed = 1, begin=0, end=1, pan, accelerate, offset|
  var line = Line.ar(begin, end, sustain, doneAction:2);
  var env = Env([0, 1, 0],[1, 1]);
  var envGen = IEnvGen.ar(env, line*env.times.sum*abs(speed));
  // --- //
  var speedFreq = freq*abs(speed)/4;
  var mod = Latch.ar((SinOsc.ar(speedFreq*[7,11,13,5])*5).tanh*2000*envGen, Saw.ar(21000*envGen));
  var car =  Latch.ar(((SinOsc.ar(speedFreq+mod)*10)+(SinOsc.ar(speedFreq)!2)).tanh, Saw.ar(21000*envGen));
  var sound = car*(-10.dbamp);
  Out.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, envGen));
}).add;

SynthDef(\noisebuild, {
  |out, sustain = 1, freq = 440, speed = 1, begin=0, end=1, pan, accelerate, offset|
  var line = Line.ar(begin, end, sustain, doneAction:2);
  var env = Env([0, 1, 0],[127, 1],curve:4);
  var envGen = IEnvGen.ar(env, line*env.times.sum*abs(speed));
  // --- //
  var sound = HPF.ar(BPF.ar(WhiteNoise.ar()*envGen, 10+(20000*envGen), 0.8), 1000);
  Out.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, envGen));
}).add;


// from bgold https://github.com/bgold-cosmos/SuperDirt-extra/blob/master/Tidal4.scd
// maybe turn into a nice pad and rename
SynthDef(\superdub5, {|out, sustain=1, pan, freq, accelerate=0, pitch1=4, voice=0,lfo=0|
	var sound, basefreq, aenv, fenv, menv, ind, m1, m2, filtrange;
	aenv = EnvGen.ar(Env.linen(0.05, 0.9, 0.05, 1, 'lin'), timeScale:sustain, doneAction:2);
	menv = EnvGen.ar(Env.linen(0.3, 0.2, 0.5), timeScale:sustain);
	basefreq = freq * Line.kr(1, 1+accelerate, sustain);
	m1 = SinOsc.ar(basefreq*2) * basefreq/8;
	m2 = SinOsc.ar(basefreq + m1*4) * basefreq*2 * menv;
	sound = Splay.ar(VarSaw.ar(basefreq+m2 * [0.99,1,1.01], 0, 0.2*menv+0.1));
	sound = (sound*(50*voice+5)).clip(-1,1)*0.5;
	sound = HPF.ar(LeakDC.ar(sound), 60);
	sound = 0.5*LFTri.ar(basefreq) + sound;
	sound = sin(2*sound);
	filtrange = clip(menv*basefreq*12+1200, 2, 20000);
	sound = LPF.ar(sound, LFTri.kr(pitch1).range(filtrange*(1-lfo), filtrange));
	OffsetOut.ar(out, DirtPan.ar(sound*aenv, ~dirt.numChannels, pan, 1))
}).add;
)