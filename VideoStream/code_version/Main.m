%% 64-qam link - snap-to-grid tilt correction (diagonal aware)
%clear; close all; clc;
%% 1. params
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
preamble = [0; 2; 61; 35];
dataNeeded = p.imgR * p.imgC;
totalMsgLen = ceil((dataNeeded + length(preamble)) / fec.k) * fec.k;
padLen = totalMsgLen - (dataNeeded + length(preamble));
%% 2. system objects
srrc = rcosdesign(0.25, 10, p.sps, 'sqrt');
rsEnc = comm.RSEncoder('CodewordLength', fec.n, 'MessageLength', fec.k);
rsDec = comm.RSDecoder('CodewordLength', fec.n, 'MessageLength', fec.k);
cfc = comm.CoarseFrequencyCompensator('Modulation','QAM','SampleRate',p.Fs*p.sps);
symbolSync = comm.SymbolSynchronizer('SamplesPerSymbol',p.sps,'TimingErrorDetector','Gardner (non-data-aided)');
carrierSync = comm.CarrierSynchronizer('Modulation','QAM','SamplesPerSymbol',8,...
    'NormalizedLoopBandwidth', 0.001, 'DampingFactor', 1);
idealPreambleSyms = qammod(preamble, p.M, 'UnitAveragePower', true);
trimSamples = 10 * p.sps;
prbsGen = comm.PNSequence('Polynomial', [7 6 0], 'InitialConditions', ones(1,7), 'SamplesPerFrame', totalMsgLen);
prbsSeq = uint8(prbsGen() * 63);
frameCount = 0;
prevFinalPhase = 0;     
prevRsOk = false;       
dbg.maxFrames = 200;
dbg.finalPhase = nan(1, dbg.maxFrames);
dbg.gridMSE = nan(1, dbg.maxFrames);
dbg.bestQ = nan(1, dbg.maxFrames);
dbg.quadMSE = nan(4, dbg.maxFrames);
dbg.rsOk = false(1, dbg.maxFrames);
dbg.searchMode = nan(1, dbg.maxFrames); 
%% 3. ui
global RUNNING CAM;
RUNNING = true;
try
    if isempty(CAM), CAM = webcam(); end
catch
    error('no webcam');
end
fig = figure('Name','64-QAM Monitor','NumberTitle','off','Color','w','Position',[100 100 1200 400]);
fig.CloseRequestFcn = @(src,~) closeFig(src);
tiledlayout(1,3,'Padding','compact');
nexttile; hTx = imshow(uint8(zeros(p.imgR, p.imgC))); title('tx');
nexttile; hRx = imshow(uint8(zeros(p.imgR, p.imgC))); title('rx (fec)');
nexttile; hold on;
hSc = scatter(0,0,10,'filled','MarkerFaceAlpha',0.2);
xlim([-1.6 1.6]); ylim([-1.6 1.6]); grid on; axis square;
title('constellation');
fprintf('\n--- starting link ---\n');
%% 4. loop
while RUNNING && isvalid(fig)
    frameCount = frameCount + 1;
    fi = mod(frameCount-1, dbg.maxFrames) + 1;
    raw = snapshot(CAM);
    g = rgb2gray(imresize(raw, [p.imgR, p.imgC]));
    set(hTx, 'CData', g);
    msg = [preamble; double(g(:)) * p.scaleTx; zeros(padLen, 1)];
    msgS = msg;
    msgS(length(preamble)+1:end) = double(bitxor(uint8(round(msg(length(preamble)+1:end))), prbsSeq(length(preamble)+1:end)));
    txSyms = qammod(double(rsEnc(uint8(round(msgS)))), p.M, 'UnitAveragePower', true);
    txSig = filter(srrc, 1, [upsample(txSyms, p.sps); zeros(trimSamples, 1)]);
    n = (0:length(txSig)-1).';
    txImp = txSig .* exp(1j*(2*pi*(p.freqOffsetHz/(p.Fs*p.sps))*n));
    rxSig = awgn(txImp, p.snrDb, 'measured');
    rxMF = filter(srrc, 1, rxSig);
    rxCFC = cfc(rxMF(trimSamples+1:end));
    rxTimed = symbolSync(rxCFC);
    rxData = carrierSync(rxTimed);
    preLen = length(preamble);
    searchLen = min(100, length(rxData) - preLen);
    bestMSE = inf;
    bestTotalPhase = 0;
    searchMode = 2; 
    
    % add 45 degree tilt to the search candidates
    % coarseSteps now covers both axis-aligned and diagonal-aligned
    coarseSteps = [0, 45, 90, 135, 180, 225, 270, 315] * pi/180;
    fineSteps = linspace(-pi/8, pi/8, 24);
    
    for offset = 1:searchLen
        rxPre = rxData(offset:offset+preLen-1);
        for cp = coarseSteps
            for fp = fineSteps
                tp = cp + fp;
                mse = mean(abs(rxPre * exp(1j * tp) - idealPreambleSyms).^2);
                if mse < bestMSE
                    bestMSE = mse;
                    bestTotalPhase = tp;
                end
            end
        end
    end
    
    rxDataCorrected = rxData * exp(1j * bestTotalPhase);
    rxPre = rxDataCorrected(1:preLen); % simplified offset for demo
    quadMSE = zeros(1,4);
    for qi = 1:4
        quadMSE(qi) = mean(abs(rxPre * exp(1j*(qi-1)*pi/2) - idealPreambleSyms).^2);
    end
    [~, bestQ] = min(quadMSE);
    bestTotalPhase = bestTotalPhase + (bestQ-1)*pi/2;
    rxDataCorrected = rxData * exp(1j * bestTotalPhase);
    
    % update debug
    dbg.gridMSE(fi) = bestMSE;
    dbg.finalPhase(fi) = rad2deg(bestTotalPhase);
    dbg.bestQ(fi) = bestQ;
    dbg.quadMSE(:,fi) = quadMSE(:);
    
    % decode
    rxDemod = qamdemod(rxDataCorrected, p.M, 'UnitAveragePower', true);
    expectedLen = (totalMsgLen/fec.k) * fec.n;
    rsOk = false;
    if length(rxDemod) >= expectedLen
        try
            [decMsg, ~] = rsDec(uint8(rxDemod(1:expectedLen)));
            decMsg(preLen+1:end) = bitxor(decMsg(preLen+1:end), prbsSeq(preLen+1:end));
            imgData = decMsg(preLen+1 : preLen+dataNeeded);
            set(hRx, 'CData', reshape(uint8(double(imgData) * p.scaleRx), p.imgR, p.imgC));
            rsOk = true;
        catch
        end
    end
    
    % update plots
    set(hSc, 'XData', real(rxDataCorrected(1:min(1000,end))), 'YData', imag(rxDataCorrected(1:min(1000,end))));
    drawnow limitrate;
end
function closeFig(src), assignin('base', 'RUNNING', false); delete(src); end