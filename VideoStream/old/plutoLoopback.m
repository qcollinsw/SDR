% User tunable (samplesPerSymbol>=decimation)
2 samplesPerSymbol = 12; decimation = 4;
3 % Set up radio
4 tx = sdrtx(’Pluto’,’Gain’,-20);
5 rx = sdrrx(’Pluto’,’SamplesPerFrame’,1e6,’OutputDataType’,’double’);
6 % Create binary data
7 data = randi([0 1],2ˆ15,1);
8 % Create a QPSK modulator System object and modulate data
9 qpskMod = comm.QPSKModulator(’BitInput’,true); modData = qpskMod(data);
10 % Set up filters
11 rctFilt = comm.RaisedCosineTransmitFilter( ...
12 ’OutputSamplesPerSymbol’, samplesPerSymbol);
13 rcrFilt = comm.RaisedCosineReceiveFilter( ...
14 ’InputSamplesPerSymbol’, samplesPerSymbol, ...
15 ’DecimationFactor’, decimation);
16 % Pass data through radio
17 tx.transmitRepeat(rctFilt(modData)); data = rcrFilt(rx());
18 % Set up visualization and delay objects
19 VFD = dsp.VariableFractionalDelay; cd = comm.ConstellationDiagram;
20 % Process received data for timing offset
21 remainingSPS = samplesPerSymbol/decimation;
22 % Grab end of data where AGC has converged
23 data = data(end-remainingSPS*1000+1:end);
24 for index = 0:300
25 % Delay signal
26 tau_hat = index/50;delayedsig = VFD(data, tau_hat);
27 % Linear interpolation
28 o = sum(reshape(delayedsig,remainingSPS,...
29 length(delayedsig)/remainingSPS).’,2)./remainingSPS;
30 % Visualize constellation
31 cd(o); pause(0.1);
32 end