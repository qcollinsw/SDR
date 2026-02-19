%% 64-qam link - configurable midambles + piecewise phase correction + stats only
clear; close all; clc;

%% params
p.M = 64;
p.imgR = 120;
p.imgC = 160;
p.snrDb = 20;
p.scaleTx = (p.M-1)/255;
p.scaleRx = 255/(p.M-1);
p.sps = 4;
p.Fs = 1000;
p.freqOffsetHz = 0.15;

fec.n = 63;
fec.k = 51;

pilotSeq = [0; 2; 61; 35]; % used for pre/mid/post
preLen = length(pilotSeq);
midLen = preLen;
postLen = preLen;

numMidambles = 3; % set to 0,1,2,3,...

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

%% ui
global RUNNING CAM;
RUNNING = true;
if isempty(CAM), CAM = webcam(); end

fig = figure('Name','64-QAM Monitor','NumberTitle','off','Color','w','Position',[100 100 1200 420]);
fig.CloseRequestFcn = @(src,~) closeFig(src);

tiledlayout(1,3,'Padding','compact');
nexttile; hTx = imshow(uint8(zeros(p.imgR, p.imgC))); title('tx');
nexttile; hRx = imshow(uint8(zeros(p.imgR, p.imgC))); title('rx (rs decoded)');
nexttile; hold on;
hSc = scatter(0,0,10,'filled','MarkerFaceAlpha',0.2);
xlim([-1.6 1.6]); ylim([-1.6 1.6]); grid on; axis square;
title('constellation');

%% loop
while RUNNING && isvalid(fig)

    raw = snapshot(CAM);
    g = rgb2gray(imresize(raw, [p.imgR, p.imgC]));
    set(hTx, 'CData', g);

    payload = uint8(round(double(g(:)) * p.scaleTx));
    payload = [payload; zeros(padLen,1,'uint8')];

    payloadScr = bitxor(payload, prbsSeq);
    codedPayload = rsEnc(payloadScr);
    txPaySyms = qammod(double(codedPayload), p.M, 'UnitAveragePower', true);

    % build tx frame: pre | seg1 | mid1 | ... | segN | post
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

    txSig = filter(srrc, 1, [upsample(txSyms, p.sps); zeros(trimSamples,1)]);
    n = (0:length(txSig)-1).';
    txImp = txSig .* exp(1j*(2*pi*(p.freqOffsetHz/(p.Fs*p.sps))*n));
    rxSig = awgn(txImp, p.snrDb, 'measured');

    rxMF = filter(srrc, 1, rxSig);
    rxCFC = cfc(rxMF(trimSamples+1:end));
    rxTimed = symbolSync(rxCFC);
    rxData = carrierSync(rxTimed);

    if length(rxData) < txFrameSyms, continue; end

    % preamble search
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
    if length(rxAligned) < txFrameSyms, continue; end
    rxFrame = rxAligned(1:txFrameSyms);

    % estimate phase at anchors: pre, each mid, post
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

    % piecewise-linear phase vector across entire frame
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

    rxFrame = rxFrame .* exp(1j * phaseSign * phaseVec);

    % extract payload segments, skipping all pilots
    rxPay = complex([]);
    for s = 1:numSeg
        st = segStarts(s);
        rxPay = [rxPay; rxFrame(st:st+segLens(s)-1)]; %#ok<AGROW>
    end

    rxDemod = qamdemod(rxPay, p.M, 'UnitAveragePower', true);

    try
        [decPayloadScr, err] = rsDec(uint8(rxDemod));
        totalCorrectedSymbols = totalCorrectedSymbols + sum(err);

        decPayload = bitxor(decPayloadScr, prbsSeq);
        imgBytes = decPayload(1:dataNeeded);

        imgU8 = uint8(double(imgBytes) * p.scaleRx);
        set(hRx, 'CData', reshape(imgU8, p.imgR, p.imgC));

        rxBits = de2bi(double(imgBytes),8,'left-msb');
        txBits = de2bi(double(payload(1:dataNeeded)),8,'left-msb');

        bitErrors = sum(rxBits(:) ~= txBits(:));
        totalBitErrors = totalBitErrors + bitErrors;
        totalBits = totalBits + numel(rxBits);
        totalFrames = totalFrames + 1;

    catch
        continue;
    end

    elapsed = toc(startTime);
    fps = totalFrames / elapsed;
    ber = totalBitErrors / max(totalBits,1);

    title(sprintf('constellation | fps=%.2f | ber=%.3e | mids=%d', ...
        fps, ber, numMidambles));

    set(hSc, 'XData', real(rxPay(1:min(2000,end))), ...
             'YData', imag(rxPay(1:min(2000,end))));
    drawnow limitrate;
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

function closeFig(src)
assignin('base','RUNNING',false);
delete(src);
end