% File: sdr_init.m
function [state, io, ui] = sdr_init(p)

if abs(log2(p.M) - round(log2(p.M))) > 0
    error('M must be a power of two.');
end

state = struct();
io = struct();
ui = struct();

rs_m = log2(p.M);
state.fec.n = 2^rs_m - 1;
state.fec.k = state.fec.n - 12;

% 3-barker pilots as chips in {+1,-1}; treat as already-modulated bpsk symbols
b13 = [ 1  1  1  1  1 -1 -1  1  1 -1  1 -1  1].';
b11 = [ 1  1  1 -1 -1 -1  1 -1 -1  1 -1].';
b7  = [ 1  1  1 -1 -1  1 -1].';

state.preSeq  = b13;
state.midSeq  = b11;
state.postSeq = b7;

state.prePilot  = complex(b13, 0);
state.midPilot  = complex(b11, 0);
state.postPilot = complex(b7, 0);

state.preLen  = length(state.prePilot);
state.midLen  = length(state.midPilot);
state.postLen = length(state.postPilot);

% these are the symbols that get inserted into the tx frame and used for correlation
state.idealPreSyms   = state.prePilot(:);
state.idealMidSyms   = state.midPilot(:);
state.idealPostSyms  = state.postPilot(:);
state.idealPilotSyms = state.idealPreSyms;

state.dataNeeded = p.imgR * p.imgC;
state.numMidambles = floor(state.dataNeeded / 500);

state.totalMsgLen = ceil(state.dataNeeded / state.fec.k) * state.fec.k;
state.padLen = state.totalMsgLen - state.dataNeeded;

state.codedPayloadLen = (state.totalMsgLen / state.fec.k) * state.fec.n;

state.srrc = rcosdesign(0.25, 10, p.sps, 'sqrt');

state.rsEnc = comm.RSEncoder('CodewordLength', state.fec.n, 'MessageLength', state.fec.k);
state.rsDec = comm.RSDecoder('CodewordLength', state.fec.n, 'MessageLength', state.fec.k);

state.cfc = comm.CoarseFrequencyCompensator('Modulation','QAM', ...
    'SampleRate', p.Fs*p.sps, ...
    'FrequencyResolution', 1);

state.symbolSync = comm.SymbolSynchronizer( ...
    'SamplesPerSymbol', p.sps, ...
    'TimingErrorDetector','Gardner (non-data-aided)');

state.carrierSync = comm.CarrierSynchronizer( ...
    'Modulation','QAM', ...
    'SamplesPerSymbol', 1, ...
    'NormalizedLoopBandwidth', 0.001, ...
    'DampingFactor', 1);

state.trimSamples = 10 * p.sps;

prbsGen = comm.PNSequence( ...
    'Polynomial', [7 6 0], ...
    'InitialConditions', ones(1,7), ...
    'SamplesPerFrame', state.totalMsgLen);
state.prbsSeq = uint8(prbsGen() * (p.M - 1));

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

state.rxWarmupFrames = 8;
state.rxPrerollSamples = 200000;

samplesPerFrameCore = ((state.txFrameSyms * p.sps) + 2*state.trimSamples);
samplesPerFrame = samplesPerFrameCore + state.rxPrerollSamples;

if strcmpi(p.MODE,'transmit')
    io.plutoTx = comm.SDRTxPluto( ...
        'CenterFrequency', p.centerFreq, ...
        'BasebandSampleRate', p.Fs*p.sps, ...
        'Gain', p.txGain, ...
        'ChannelMapping', 1);

elseif strcmpi(p.MODE,'receive')
    rxGain = -10;
    if isfield(p,'rxGain'), rxGain = p.rxGain; end

    io.plutoRx = comm.SDRRxPluto( ...
        'CenterFrequency', p.centerFreq, ...
        'BasebandSampleRate', p.Fs*p.sps, ...
        'OutputDataType','double', ...
        'SamplesPerFrame', samplesPerFrame, ...
        'GainSource', 'Manual', ...
        'Gain', rxGain);
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