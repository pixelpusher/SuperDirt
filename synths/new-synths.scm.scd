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
)