% File: sdr_params_default.m
function p = sdr_params_default()
p = struct();

p.MODE = 'simulation';

p.M = 16;
p.imgR = 120;
p.imgC = 160;

p.snrDb = 20;

p.sps = 4;
p.Fs = 100000;
p.freqOffsetHz = 100;

p.centerFreq = 2.45e9;
p.txGain = -10;
p.rxGain = 20;

p.modType = 'qam';     % 'qam' or 'psk'

p.bitsPerSym = log2(p.M);

p.scaleTx = (p.M-1)/255;
p.scaleRx = 255/(p.M-1);
end