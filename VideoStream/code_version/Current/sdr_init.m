% File: sdr_init.m
function [state, io, ui] = sdr_init(p)

state = struct();
io = struct();
ui = struct();

state.fec.n = 63;
state.fec.k = 51;

state.pilotSeq = [0; 2; 61; 35];
state.preLen = length(state.pilotSeq);
state.midLen = state.preLen;
state.postLen = state.preLen;

state.dataNeeded = p.imgR * p.imgC;
state.numMidambles = floor(state.dataNeeded / 4800);

state.totalMsgLen = ceil(state.dataNeeded / state.fec.k) * state.fec.k;
state.padLen = state.totalMsgLen - state.dataNeeded;

state.codedPayloadLen = (state.totalMsgLen / state.fec.k) * state.fec.n;

state.srrc = rcosdesign(0.25, 10, p.sps, 'sqrt');

state.rsEnc = comm.RSEncoder('CodewordLength', state.fec.n, 'MessageLength', state.fec.k);
state.rsDec = comm.RSDecoder('CodewordLength', state.fec.n, 'MessageLength', state.fec.k);

state.cfc = comm.CoarseFrequencyCompensator('Modulation','QAM','SampleRate',p.Fs*p.sps);

state.symbolSync = comm.SymbolSynchronizer( ...
    'SamplesPerSymbol', p.sps, ...
    'TimingErrorDetector','Gardner (non-data-aided)');

state.carrierSync = comm.CarrierSynchronizer( ...
    'Modulation','QAM', ...
    'SamplesPerSymbol', p.sps, ...
    'NormalizedLoopBandwidth', 5e-4, ...
    'DampingFactor', 1);

state.idealPilotSyms = qammod(state.pilotSeq, p.M, 'UnitAveragePower', true);

state.trimSamples = 10 * p.sps;

prbsGen = comm.PNSequence( ...
    'Polynomial', [7 6 0], ...
    'InitialConditions', ones(1,7), ...
    'SamplesPerFrame', state.totalMsgLen);
state.prbsSeq = uint8(prbsGen() * 63);

state.coarseSteps = [0 45 90 135 180 225 270 315] * pi/180;
state.fineSteps = linspace(-pi/8, pi/8, 24);
state.phaseSign = +1;

state.numSeg = state.numMidambles + 1;
baseSeg = floor(state.codedPayloadLen / state.numSeg);
state.segLens = baseSeg * ones(1, state.numSeg);
state.segLens(end) = state.codedPayloadLen - sum(state.segLens(1:end-1));

state.txFrameSyms = state.preLen + state.codedPayloadLen + state.numMidambles*state.midLen + state.postLen;

state.segStarts = zeros(1, state.numSeg);
state.midStarts = zeros(1, state.numMidambles);

idx = 1;
state.preStart = idx;
idx = idx + state.preLen;

for s = 1:state.numSeg
    state.segStarts(s) = idx;
    idx = idx + state.segLens(s);
    if s <= state.numMidambles
        state.midStarts(s) = idx;
        idx = idx + state.midLen;
    end
end

state.postStart = idx;

state.totalBits = 0;
state.totalBitErrors = 0;
state.totalCorrectedSymbols = 0;
state.totalFrames = 0;
state.startTime = tic;

io.plutoTx = [];
io.plutoRx = [];

samplesPerFrame = (state.txFrameSyms * p.sps) + 2*state.trimSamples;

if strcmpi(p.MODE,'transmit')
    io.plutoTx = comm.SDRTxPluto( ...
        'CenterFrequency', p.centerFreq, ...
        'BasebandSampleRate', p.Fs * p.sps, ...
        'Gain', p.txGain, ...
        'ChannelMapping', 1);
elseif strcmpi(p.MODE,'receive')
    io.plutoRx = comm.SDRRxPluto( ...
        'CenterFrequency', p.centerFreq, ...
        'BasebandSampleRate', p.Fs * p.sps, ...
        'OutputDataType','double', ...
        'SamplesPerFrame', samplesPerFrame, ...
        'Gain', p.rxGain);
end

global RUNNING CAM;
RUNNING = true;
state.RUNNING = true;

if strcmpi(p.MODE,'simulation') || strcmpi(p.MODE,'transmit')
    if isempty(CAM)
        try
            CAM = webcam();
        catch
            CAM = [];
        end
    end
end

ui = sdr_ui_init(p, io, state);
end