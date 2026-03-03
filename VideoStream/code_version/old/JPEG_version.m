
clear; close all; clc;

%% 64-qam link - jpeg compression + bit-to-symbol mapping
% mode: 'simulation' | 'transmit' | 'receive'
MODE = 'simulation'; 

%% params
p.M = 64;
p.bps = log2(p.M); % bits per symbol (6)
p.imgR = 240; % resolution
p.imgC = 320; 
p.jpegQuality = 40; % 1-100
p.snrDb = 40;
p.sps = 4;
p.Fs = 520000;
p.freqOffsetHz = 0;

% capacity for the jpeg byte stream (8-bit bytes)
p.maxByteLen = 4000; 
dataNeeded8bit = p.maxByteLen + 2; % +2 for length header

% calculate how many 6-bit symbols we need to carry those 8-bit bytes
totalBits = dataNeeded8bit * 8;
dataNeeded6bit = ceil(totalBits / p.bps);

% fec params (operating on 6-bit symbols)
fec.n = 63; 
fec.k = 53;

numCodewords = ceil(dataNeeded6bit / fec.k);
totalMsgLen = numCodewords * fec.k;
padLen = totalMsgLen - dataNeeded6bit;
codedPayloadLen = numCodewords * fec.n;

pilotSeq = [0; 2; 61; 35]; 
preLen = length(pilotSeq);
midLen = preLen;
postLen = preLen;

%% objects
srrc = rcosdesign(0.25, 10, p.sps, 'sqrt');
rsEnc = comm.RSEncoder('CodewordLength', fec.n, 'MessageLength', fec.k);
rsDec = comm.RSDecoder('CodewordLength', fec.n, 'MessageLength', fec.k);
cfc = comm.CoarseFrequencyCompensator('Modulation','QAM','SampleRate',p.Fs*p.sps);
symbolSync = comm.SymbolSynchronizer('SamplesPerSymbol', p.sps);
carrierSync = comm.CarrierSynchronizer('Modulation','QAM','SamplesPerSymbol', p.sps);

idealPilotSyms = qammod(pilotSeq, p.M, 'UnitAveragePower', true);
trimSamples = 10 * p.sps;

% prbs for scrambling 6-bit symbols
prbsGen = comm.PNSequence('Polynomial', [7 6 0], 'InitialConditions', ones(1,7), 'SamplesPerFrame', totalMsgLen);
prbsSeq = uint8(prbsGen() * (p.M-1));

%% phase search grids
coarseSteps = [0 90 180 270] * pi/180;
fineSteps = linspace(-pi/8, pi/8, 12);

%% segmentation
numMidambles = floor(codedPayloadLen / 2000);
numSeg = numMidambles + 1;
baseSeg = floor(codedPayloadLen / numSeg);
segLens = baseSeg * ones(1, numSeg);
segLens(end) = codedPayloadLen - sum(segLens(1:end-1));

txFrameSyms = preLen + codedPayloadLen + numMidambles*midLen + postLen;
segStarts = zeros(1, numSeg);
midStarts = zeros(1, numMidambles);
idx = 1 + preLen;
for s = 1:numSeg
    segStarts(s) = idx;
    idx = idx + segLens(s);
    if s <= numMidambles
        midStarts(s) = idx;
        idx = idx + midLen;
    end
end
preStart = 1; postStart = idx;

%% hardware setup
totalFrames = 0; startTime = tic;
plutoTx = []; plutoRx = [];
samplesPerFrame = (txFrameSyms * p.sps) + 2*trimSamples;

if strcmpi(MODE,'transmit')
    plutoTx = comm.SDRTxPluto('CenterFrequency', 915e6, 'BasebandSampleRate', p.Fs * p.sps);
elseif strcmpi(MODE,'receive')
    plutoRx = comm.SDRRxPluto('CenterFrequency', 915e6, 'BasebandSampleRate', p.Fs * p.sps, 'SamplesPerFrame', samplesPerFrame);
end

%% ui
global RUNNING CAM;
RUNNING = true;
if isempty(CAM), CAM = webcam(); end
fig = figure('Name','JPEG 64-QAM Link','Color','w','Position',[100 100 1200 420]);
fig.CloseRequestFcn = @(src,~) closeFig(src, plutoTx, plutoRx);
tiledlayout(1,3,'Padding','compact');
nexttile; hTx = imshow(uint8(zeros(p.imgR, p.imgC))); title('tx (raw)');
nexttile; hRx = imshow(uint8(zeros(p.imgR, p.imgC))); title('rx (jpeg)');
nexttile; hold on; hSc = scatter(0,0,10,'filled','MarkerFaceAlpha',0.2);
xlim([-1.6 1.6]); ylim([-1.6 1.6]); grid on; axis square;

%% loop
while RUNNING && isvalid(fig)
    % 1. capture and compress
    raw = snapshot(CAM);
    g = rgb2gray(imresize(raw, [p.imgR, p.imgC]));
    set(hTx, 'CData', g);
    
    [payload6bit, codedPayload, jpgLen] = makePayload(g, p, dataNeeded8bit, padLen, prbsSeq, rsEnc);
    txSyms = buildTxFrame(codedPayload, idealPilotSyms, p.M, numSeg, segLens, numMidambles);
    
    % 2. channel
    if strcmpi(MODE, 'simulation')
        rxData_proc = txrxChain_sim(txSyms, srrc, p, trimSamples, cfc, symbolSync, carrierSync);
    else
        if strcmpi(MODE, 'transmit')
            txWave = single(filter(srrc, 1, upsample(txSyms, p.sps)));
            plutoTx.transmitRepeat(txWave); rxData_proc = txSyms;
        else
            hw = plutoRx();
            rxMF = filter(srrc, 1, hw);
            try
                rxCFC = cfc(rxMF(trimSamples:end));
                rxTimed = symbolSync(rxCFC);
                rxData_proc = carrierSync(rxTimed);
            catch, continue; end
        end
    end
    
    if length(rxData_proc) < txFrameSyms, continue; end
    
    % 3. sync & phase
    rxFrame = alignFrameByPreamble(rxData_proc, idealPilotSyms, preLen, txFrameSyms, coarseSteps, fineSteps);
    if isempty(rxFrame), continue; end
    
    pVec = estimatePiecewisePhase(rxFrame, idealPilotSyms, preLen, preStart, midStarts, postStart, numMidambles, coarseSteps, fineSteps, txFrameSyms);
    rxFrame = rxFrame .* exp(1j * pVec);
    
    % 4. decode
    rxPay = extractPayload(rxFrame, segStarts, segLens, numSeg);
    rxDemod = qamdemod(rxPay, p.M, 'UnitAveragePower', true);
    
    try
        [imgU8, nCorr] = decodeAndMeasure(rxDemod, rsDec, prbsSeq, p, dataNeeded8bit);
        set(hRx, 'CData', imgU8);
        totalFrames = totalFrames + 1;
        title(sprintf('fps=%.1f | corr=%d | bytes=%d', totalFrames/toc(startTime), nCorr, jpgLen));
    catch
        continue; 
    end
    
    set(hSc, 'XData', real(rxPay(1:min(1200,end))), 'YData', imag(rxPay(1:min(1200,end))));
    drawnow limitrate;
end

%% functions
function [payload6bit, codedPayload, jpgLen] = makePayload(g, p, dataNeeded8bit, padLen, prbsSeq, rsEnc)
    % compress to jpeg bytes (8-bit)
    tmp = [tempname '.jpg']; imwrite(g, tmp, 'jpg', 'Quality', p.jpegQuality);
    fid = fopen(tmp,'r'); jpgBytes = uint8(fread(fid, inf)); fclose(fid); delete(tmp);
    
    jpgLen = min(numel(jpgBytes), p.maxByteLen);
    raw8bit = zeros(dataNeeded8bit, 1, 'uint8');
    raw8bit(1) = floor(jpgLen/256); raw8bit(2) = mod(jpgLen, 256);
    raw8bit(3:2+jpgLen) = jpgBytes(1:jpgLen);
    
    % convert 8-bit to 6-bit symbols
    bits = de2bi(raw8bit, 8, 'left-msb');
    bitsFlat = reshape(bits', [], 1);
    % ensure length is multiple of 6 for 64-qam
    remBits = mod(numel(bitsFlat), 6);
    if remBits > 0, bitsFlat = [bitsFlat; zeros(6-remBits, 1)]; end
    
    symbols6bit = bi2de(reshape(bitsFlat, 6, [])', 'left-msb');
    payload6bit = [uint8(symbols6bit); zeros(padLen, 1, 'uint8')];
    
    % scramble and encode
    payloadScr = bitxor(payload6bit, prbsSeq);
    codedPayload = rsEnc(payloadScr);
end

function [imgU8, nCorrSyms] = decodeAndMeasure(rxDemod, rsDec, prbsSeq, p, dataNeeded8bit)
    [decPayloadScr, err] = rsDec(uint8(rxDemod));
    nCorrSyms = sum(err);
    decSymbols = bitxor(decPayloadScr, prbsSeq);
    
    % convert 6-bit symbols back to 8-bit bytes
    bits = de2bi(double(decSymbols), 6, 'left-msb');
    bitsFlat = reshape(bits', [], 1);
    dec8bit = bi2de(reshape(bitsFlat(1:dataNeeded8bit*8), 8, [])', 'left-msb');
    
    % parse jpeg
    jpgLen = double(dec8bit(1))*256 + double(dec8bit(2));
    if jpgLen <= 0 || jpgLen > p.maxByteLen, error('bad header'); end
    
    tmp = [tempname '.jpg']; fid = fopen(tmp,'w');
    fwrite(fid, uint8(dec8bit(3:2+jpgLen))); fclose(fid);
    try
        imgU8 = imread(tmp);
        if size(imgU8,1) ~= p.imgR, imgU8 = imresize(imgU8, [p.imgR, p.imgC]); end
    catch
        imgU8 = uint8(zeros(p.imgR, p.imgC));
    end
    delete(tmp);
end

% ... [rest of helper functions buildTxFrame, txrxChain_sim, etc. remain the same] ...
function txSyms = buildTxFrame(codedPayload, idealPilotSyms, M, numSeg, segLens, numMidambles)
    txPaySyms = qammod(double(codedPayload), M, 'UnitAveragePower', true);
    txSyms = idealPilotSyms; pidx = 1;
    for s = 1:numSeg
        txSyms = [txSyms; txPaySyms(pidx:pidx+segLens(s)-1)]; %#ok<AGROW>
        pidx = pidx + segLens(s);
        if s <= numMidambles, txSyms = [txSyms; idealPilotSyms]; end
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
    bestMSE = inf; bestOffset = 1; 
    maxOff = min(400, length(rxData)-preLen+1);
    for offset = 1:maxOff
        rxPre = rxData(offset:offset+preLen-1);
        for cp = coarseSteps
            for fp = fineSteps
                tp = cp + fp;
                mse = mean(abs(rxPre*exp(1j*tp)-idealPilotSyms).^2);
                if mse < bestMSE, bestMSE = mse; bestOffset = offset; end
            end
        end
    end
    rxAligned = rxData(bestOffset:end);
    if length(rxAligned) < txFrameSyms, rxFrame = []; return; end
    rxFrame = rxAligned(1:txFrameSyms);
end

function phaseVec = estimatePiecewisePhase(rxFrame, idealPilotSyms, preLen, preStart, midStarts, postStart, numMidambles, coarseSteps, fineSteps, txFrameSyms)
    phases = zeros(1, numMidambles + 2);
    anchors = [preStart, midStarts, postStart];
    for a = 1:numel(anchors)
        rxPil = rxFrame(anchors(a):anchors(a)+preLen-1);
        phases(a) = estPhase(rxPil, idealPilotSyms, coarseSteps, fineSteps);
    end
    phaseVec = interp1(anchors, unwrap(phases), 1:txFrameSyms, 'linear', 'extrap').';
end

function ph = estPhase(rxPil, idealPil, coarseSteps, fineSteps)
    bestMSE = inf; ph = 0;
    for cp = coarseSteps
        for fp = fineSteps
            tp = cp + fp;
            mse = mean(abs(rxPil*exp(1j*tp)-idealPil).^2);
            if mse < bestMSE, bestMSE = mse; ph = tp; end
        end
    end
end

function rxPay = extractPayload(rxFrame, segStarts, segLens, numSeg)
    rxPay = complex([]);
    for s = 1:numSeg
        rxPay = [rxPay; rxFrame(segStarts(s):segStarts(s)+segLens(s)-1)];
    end
end

function closeFig(src, tx, rx)
    global RUNNING; RUNNING = false;
    if ~isempty(tx), release(tx); end
    if ~isempty(rx), release(rx); end
    delete(src);
end