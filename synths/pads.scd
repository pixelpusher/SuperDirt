(

(
SynthDef(\ChicagoPad2, { |out, freq, note, note2=48, note3=44, cutfreq=500, velocity = 0.2, gate=1, speed=1, sustain=0.8, decay=0.5, pan, begin=0, end=1, up = 0 |

    var freq2,freq3,snd, env, envGen, line;

	// freq = (note + up).midicps;
	freq2 = (note2 + up).midicps;
	freq3 = (note3 + up).midicps;

	//freq = note;
	//freq2 = note2;
	//freq3 = note3;

	freq = freq + SinOsc.kr(freq*1/2, 0, freq/2, 0);
    snd = Saw.ar([freq, freq+1, freq-1, freq2, freq3] * [0.99,1])*0.1;
    snd = snd + VarSaw.ar(0.99*[freq, freq+1, freq-1, freq2, freq3, freq2+1, freq3+1],0, LFTri.kr(7.13).range(0.00,0.1))*0.1;

    snd = Mix(snd);
    snd = FreeVerb.ar(snd, 0.51,10,0.1)*2;
    snd = snd * 8;
    snd = RLPF.ar(snd, SinOsc.kr([0.1,4.2], 0, [1700,480], [4000,700,5000])/[20.51,20], SinOsc.ar(0.1,1.5*pi)+1.05)/3;
    snd = Mix(snd);

    snd = MoogFF.ar(snd, SinOsc.kr(0.08, 0.5, cutfreq/10, cutfreq), 3, 0);

	line = Line.ar(begin, end, sustain, doneAction:2);
	env = Env([0, 1, 0],[1,5], curve:2);
	envGen = IEnvGen.ar(env, line*env.times.sum*abs(speed));

	//env = EnvGen.ar(Env.adsr(0.4, 0.01,sustain,0.4), gate, doneAction:2);

	//snd = snd * envGen;
    //snd = snd * EnvGen.ar(Env.adsr(0.4, 0.01,0.8,0.4), gate, doneAction:2);

    snd = [snd , AllpassC.ar(snd, decay, 0.05+SinOsc.ar(0.11).range(0,0.045), 0.3)];
	//snd = snd.tanh*2;

	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, envGen));
}).add;
);


(
SynthDef(\pad2, { |out, freq, cutfreq=500, velocity = 0.2, gate=1, speed=1, sustain=0.8, decay=2, pan, begin=0, end=1, up = 0 |

    var freq2,freq3,snd, env, envGen, line;

	// freq = (note + up).midicps;
	freq2 = freq*0.5;
	freq3 = freq/2;

	freq = freq + SinOsc.kr(freq2, 0, freq3, 0);
    snd = Saw.ar([freq, freq2, freq3] * [0.99,1]);
    snd = snd + VarSaw.ar(0.99*[freq, freq+1, freq-1],0, LFTri.kr(7.13).range(0.00,0.1))*0.1;

	snd = Mix(snd);
    snd = FreeVerb.ar(snd, 0.51,10,0.1)*2;
    snd = snd * 8;
    snd = RLPF.ar(snd, SinOsc.kr([0.1,4.2], 0, [1700,480], [4000,700,5000])/[20.51,20], SinOsc.ar(0.1,1.5*pi)+1.05)/3;
    snd = Mix(snd);

    snd = MoogFF.ar(snd, SinOsc.kr(0.08, 0.5, cutfreq/10, cutfreq), 3, 0);


	line = Line.ar(begin, end, sustain, doneAction:2);
	env = Env([0, 1, 0],[1,5], curve:2);
	envGen = IEnvGen.ar(env, line*env.times.sum*abs(speed));

    snd = [snd , AllpassC.ar(snd, decay, 0.05+SinOsc.ar(0.11).range(0,0.045), 0.3)];
//	snd = snd.tanh;

	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, envGen));
}).add;
)

)