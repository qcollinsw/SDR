clear; close all; clc;
%% 64-qam link - configurable midambles + piecewise phase correction + stats only
% mode: 'simulation' | 'transmit' | 'receive'
% simulation: run the exact internal sim (awgn + freq offset)
% transmit: send waveform to a connected ADALM-PLUTO (no impairments)
% receive: receive waveform from a connected ADALM-PLUTO and process
MODE = 'simulation'; % <-- choose mode here

%% params
p.M = 64;
p.imgR = 120;
p.imgC = 160;
p.snrDb = 20;
p.scaleTx = (p.M-1)/255;
p.scaleRx = 255/(p.M-1);
p.sps = 4;
p.Fs = 520000;
p.freqOffsetHz = 100;

fec.n = 63;
fec.k = 51;

pilotSeq = [0; 2; 61; 35]; % used for pre/mid/post
preLen = length(pilotSeq);
midLen = preLen;
postLen = preLen;

dataNeeded = p.imgR * p.imgC;

numMidambles = floor(dataNeeded / 4800);

dataNeeded = p.imgR * p.imgC;

totalMsgLen = ceil(dataNeeded / fec.k) * fec.k;
padLen = totalMsgLen - dataNeeded;

codedPayloadLen = (totalMsgLen / fec.k) * fec.n;

%% objects
srrc = rcosdesign(0.25, 10, p.sps, 'sqrt');

rsEnc = comm.RSEncoder('CodewordLength', fec.n, 'MessageLength', fec.k);
rsDec = comm.RSDecoder('CodewordLength', fec.n, 'MessageLength', fec.k);

cfc = comm.CoarseFrequencyCompensator('Modulation','QAM','SampleRate',p.Fs*p.sps);

symbolSync = comm.SymbolSynchronizer( ...
    'SamplesPerSymbol', p.sps, ...
    'TimingErrorDetector','Gardner (non-data-aided)');

carrierSync = comm.CarrierSynchronizer( ...
    'Modulation','QAM', ...
    'SamplesPerSymbol', p.sps, ...
    'NormalizedLoopBandwidth', 5e-4, ...
    'DampingFactor', 1);

idealPilotSyms = qammod(pilotSeq, p.M, 'UnitAveragePower', true);

trimSamples = 10 * p.sps;

prbsGen = comm.PNSequence( ...
    'Polynomial', [7 6 0], ...
    'InitialConditions', ones(1,7), ...
    'SamplesPerFrame', totalMsgLen);
prbsSeq = uint8(prbsGen() * 63);

%% phase search grids
coarseSteps = [0 45 90 135 180 225 270 315] * pi/180;
fineSteps = linspace(-pi/8, pi/8, 24);
phaseSign = +1;

%% frame segmentation (coded payload split into numMidambles+1 segments)
numSeg = numMidambles + 1;
baseSeg = floor(codedPayloadLen / numSeg);
segLens = baseSeg * ones(1, numSeg);
segLens(end) = codedPayloadLen - sum(segLens(1:end-1));

% build indices within tx/rx frame (1-based symbol indexing)
txFrameSyms = preLen + codedPayloadLen + numMidambles*midLen + postLen;

segStarts = zeros(1, numSeg);
midStarts = zeros(1, numMidambles);

idx = 1; % pre starts at 1
preStart = idx;
idx = idx + preLen;

for s = 1:numSeg
    segStarts(s) = idx;
    idx = idx + segLens(s);
    if s <= numMidambles
        midStarts(s) = idx;
        idx = idx + midLen;
    end
end

postStart = idx; % postamble starts here

%% stats
totalBits = 0;
totalBitErrors = 0;
totalCorrectedSymbols = 0;
totalFrames = 0;
startTime = tic;

%% pluto objects (create only if needed)
plutoTx = [];
plutoRx = [];
samplesPerFrame = (txFrameSyms * p.sps) + 2*trimSamples; % safe frame size for hw
if strcmpi(MODE,'transmit')
    % transmitter object: use reasonable defaults, user can adjust later
    plutoTx = comm.SDRTxPluto( ...
        'CenterFrequency', 915e6, ...
        'BasebandSampleRate', p.Fs * p.sps, ...
        'Gain', -10, ...
        'ChannelMapping', 1);
elseif strcmpi(MODE,'receive')
    plutoRx = comm.SDRRxPluto( ...
        'CenterFrequency', 915e6, ...
        'BasebandSampleRate', p.Fs * p.sps, ...
        'OutputDataType','double', ...
        'SamplesPerFrame', samplesPerFrame, ...
        'Gain', 20);
end

%% ui
global RUNNING CAM;
RUNNING = true;
if isempty(CAM), CAM = webcam(); end

fig = figure('Name','64-QAM Monitor','NumberTitle','off','Color','w','Position',[100 100 1200 420]);
fig.CloseRequestFcn = @(src,~) closeFig(src, plutoTx, plutoRx);

tiledlayout(1,3,'Padding','compact');
nexttile; hTx = imshow(uint8(zeros(p.imgR, p.imgC))); title('tx');
nexttile; hRx = imshow(uint8(zeros(p.imgR, p.imgC))); title('rx');
nexttile; hold on;
hSc = scatter(0,0,10,'filled','MarkerFaceAlpha',0.2);
xlim([-1.6 1.6]); ylim([-1.6 1.6]); grid on; axis square;
title('constellation');

%% loop
while RUNNING && isvalid(fig)

    g = captureFrameGray(p, hTx);

    [payload, codedPayload] = makePayload(g, p, dataNeeded, padLen, prbsSeq, rsEnc);

    txSyms = buildTxFrame(codedPayload, idealPilotSyms, p.M, numSeg, segLens, numMidambles);

    % depending on mode either simulate channel, transmit on hw, or receive from hw
    switch lower(MODE)
        case 'simulation'
            rxData = txrxChain_sim(txSyms, srrc, p, trimSamples, cfc, symbolSync, carrierSync);
        case 'transmit'
            % prepare baseband waveform without impairments and send to pluto
            txWave = filter(srrc, 1, [upsample(txSyms, p.sps); zeros(trimSamples,1)]);
            % convert to single to satisfy transmitRepeat in many setups
            txWave = single(txWave);
            if isempty(plutoTx)
                error('pluto transmitter object not initialized. set MODE to ''transmit'' after creating object.');
            end
            % transmit repeatedly (non-blocking for this loop; blocks until download completes)
            try
                plutoTx.transmitRepeat(txWave);
                % for transmit mode we can still process a local copy as if received (optional)
                rxData = txWave; % treat local loopback for display (no AWGN/freq offset)
                % remove filter transient samples for downstream blocks (we expect symbol sync)
                rxData = rxData;
            catch err
                warning('pluto transmit failed: %s', err.message);
                rxData = [];
            end
        case 'receive'
            if isempty(plutoRx)
                error('pluto receiver object not initialized. set MODE to ''receive'' after creating object.');
            end
            % capture samples from hw
            try
                hwSamples = plutoRx();
                % hwSamples are baseband complex at baseband sample rate
                rxData = hwSamples;
            catch err
                warning('pluto receive failed: %s', err.message);
                rxData = [];
            end
        otherwise
            error('unknown MODE: %s', MODE);
    end

    if isempty(rxData)
        pause(0.01);
        continue;
    end

    % for simulation path rxData is already symbol-rate synchronized after sync objects
    % for hw receive path we must perform matched filtering and synchronizers
    if ~strcmpi(MODE,'simulation')
        % apply matched filter and coarse freq compensation + symbol & carrier sync
        rxMF = filter(srrc, 1, rxData);
        if length(rxMF) <= trimSamples
            continue;
        end
        try
            rxCFC = cfc(rxMF(trimSamples+1:end));
            rxTimed = symbolSync(rxCFC);
            rxData_proc = carrierSync(rxTimed);
        catch
            continue;
        end
    else
        rxData_proc = rxData;
    end

    if length(rxData_proc) < txFrameSyms, continue; end

    rxFrame = alignFrameByPreamble(rxData_proc, idealPilotSyms, preLen, txFrameSyms, coarseSteps, fineSteps);
    if isempty(rxFrame), continue; end

    phaseVec = estimatePiecewisePhase(rxFrame, idealPilotSyms, preLen, ...
        preStart, midStarts, postStart, numMidambles, coarseSteps, fineSteps, txFrameSyms);

    rxFrame = rxFrame .* exp(1j * phaseSign * phaseVec);

    rxPay = extractPayload(rxFrame, segStarts, segLens, numSeg);

    rxDemod = qamdemod(rxPay, p.M, 'UnitAveragePower', true);

    try
        [imgU8, bitErrors, nBits, nCorrSyms] = decodeAndMeasure( ...
            rxDemod, rsDec, prbsSeq, dataNeeded, payload, p);

        totalCorrectedSymbols = totalCorrectedSymbols + nCorrSyms;

        set(hRx, 'CData', reshape(imgU8, p.imgR, p.imgC));

        totalBitErrors = totalBitErrors + bitErrors;
        totalBits = totalBits + nBits;
        totalFrames = totalFrames + 1;

    catch
        continue;
    end

    elapsed = toc(startTime);
    fps = totalFrames / elapsed;
    ber = totalBitErrors / max(totalBits,1);

    title(sprintf('constellation | fps=%.2f | ber=%.3e | mids=%d | mode=%s', ...
        fps, ber, numMidambles, MODE));

    set(hSc, 'XData', real(rxPay(1:min(2000,end))), ...
             'YData', imag(rxPay(1:min(2000,end))));
    drawnow limitrate;
end

%% helper functions

function g = captureFrameGray(p, hTx)
global CAM;
raw = snapshot(CAM);
g = rgb2gray(imresize(raw, [p.imgR, p.imgC]));
set(hTx, 'CData', g);
end

function [payload, codedPayload] = makePayload(g, p, dataNeeded, padLen, prbsSeq, rsEnc)
payload = uint8(round(double(g(:)) * p.scaleTx));
payload = [payload; zeros(padLen,1,'uint8')];
payloadScr = bitxor(payload, prbsSeq);
codedPayload = rsEnc(payloadScr);
end

function txSyms = buildTxFrame(codedPayload, idealPilotSyms, M, numSeg, segLens, numMidambles)
txPaySyms = qammod(double(codedPayload), M, 'UnitAveragePower', true);
txSyms = idealPilotSyms;
pidx = 1;
for s = 1:numSeg
    txSyms = [txSyms; txPaySyms(pidx:pidx+segLens(s)-1)]; %#ok<AGROW>
    pidx = pidx + segLens(s);
    if s <= numMidambles
        txSyms = [txSyms; idealPilotSyms]; %#ok<AGROW>
    end
end
txSyms = [txSyms; idealPilotSyms];
end

function rxData = txrxChain_sim(txSyms, srrc, p, trimSamples, cfc, symbolSync, carrierSync)
txSig = filter(srrc, 1, [upsample(txSyms, p.sps); zeros(trimSamples,1)]);
n = (0:length(txSig)-1).';
txImp = txSig .* exp(1j*(2*pi*(p.freqOffsetHz/(p.Fs*p.sps))*n));
rxSig = awgn(txImp, p.snrDb, 'measured');
rxMF = filter(srrc, 1, rxSig);
rxCFC = cfc(rxMF(trimSamples+1:end));
rxTimed = symbolSync(rxCFC);
rxData = carrierSync(rxTimed);
end

function rxFrame = alignFrameByPreamble(rxData, idealPilotSyms, preLen, txFrameSyms, coarseSteps, fineSteps)
bestMSE = inf; bestOffset = 1; bestPhase = 0;
maxOff = min(400, length(rxData)-preLen+1);

for offset = 1:maxOff
    rxPre = rxData(offset:offset+preLen-1);
    for cp = coarseSteps
        for fp = fineSteps
            tp = cp + fp;
            mse = mean(abs(rxPre*exp(1j*tp)-idealPilotSyms).^2);
            if mse < bestMSE
                bestMSE = mse;
                bestOffset = offset;
                bestPhase = tp;
            end
        end
    end
end

rxAligned = rxData(bestOffset:end);
if length(rxAligned) < txFrameSyms
    rxFrame = [];
    return;
end
rxFrame = rxAligned(1:txFrameSyms);
end

function phaseVec = estimatePiecewisePhase(rxFrame, idealPilotSyms, preLen, preStart, midStarts, postStart, numMidambles, coarseSteps, fineSteps, txFrameSyms)
phases = zeros(1, numMidambles + 2);
anchors = zeros(1, numMidambles + 2);

anchors(1) = preStart;
for m = 1:numMidambles
    anchors(m+1) = midStarts(m);
end
anchors(end) = postStart;

for a = 1:numel(anchors)
    st = anchors(a);
    rxPil = rxFrame(st:st+preLen-1);
    phases(a) = estPhase(rxPil, idealPilotSyms, coarseSteps, fineSteps);
end

phaseVec = zeros(txFrameSyms,1);
for a = 1:(numel(anchors)-1)
    a0 = anchors(a);
    a1 = anchors(a+1);
    i0 = a0;
    i1 = a1 - 1;
    if i1 < i0, continue; end
    phaseVec(i0:i1) = linspace(phases(a), phases(a+1), i1-i0+1).';
end
phaseVec(anchors(end):txFrameSyms) = linspace(phases(end-1), phases(end), txFrameSyms-anchors(end)+1).';
end

function rxPay = extractPayload(rxFrame, segStarts, segLens, numSeg)
rxPay = complex([]);
for s = 1:numSeg
    st = segStarts(s);
    rxPay = [rxPay; rxFrame(st:st+segLens(s)-1)]; %#ok<AGROW>
end
end

function [imgU8, bitErrors, nBits, nCorrSyms] = decodeAndMeasure(rxDemod, rsDec, prbsSeq, dataNeeded, payload, p)
[decPayloadScr, err] = rsDec(uint8(rxDemod));
nCorrSyms = sum(err);
decPayload = bitxor(decPayloadScr, prbsSeq);
imgBytes = decPayload(1:dataNeeded);
imgU8 = uint8(double(imgBytes) * p.scaleRx);
rxBits = de2bi(double(imgBytes),8,'left-msb');
txBits = de2bi(double(payload(1:dataNeeded)),8,'left-msb');
bitErrors = sum(rxBits(:) ~= txBits(:));
nBits = numel(rxBits);
end

function phaseHat = estPhase(rxPil, idealPil, coarseSteps, fineSteps)
bestMSE = inf; phaseHat = 0;
for cp = coarseSteps
    for fp = fineSteps
        tp = cp + fp;
        mse = mean(abs(rxPil*exp(1j*tp)-idealPil).^2);
        if mse < bestMSE
            bestMSE = mse;
            phaseHat = tp;
        end
    end
end
rxCoarse = rxPil * exp(1j*phaseHat);
qm = zeros(1,4);
for qi = 1:4
    qm(qi) = mean(abs(rxCoarse*exp(1j*(qi-1)*pi/2)-idealPil).^2);
end
[~,bq] = min(qm);
phaseHat = phaseHat + (bq-1)*pi/2;
end

function closeFig(src, plutoTx, plutoRx)
assignin('base','RUNNING',false);
try
    if ~isempty(plutoTx), release(plutoTx); end
    if ~isempty(plutoRx), release(plutoRx); end
catch
end
delete(src);
end