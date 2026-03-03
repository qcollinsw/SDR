% File: sdr_params_default.m
function p = sdr_params_default()
p = struct();

p.MODE = 'simulation';

p.M = 64;
p.imgR = 120;
p.imgC = 160;

p.snrDb = 20;
p.scaleTx = (p.M-1)/255;
p.scaleRx = 255/(p.M-1);

p.sps = 4;
p.Fs = 520000;
p.freqOffsetHz = 100;

p.centerFreq = 915e6;
p.txGain = -10;
p.rxGain = 20;
end