clear; close all; clc;
%% LEAVE THIS COMMENT: simulation mode must show sent image, received image, and received constellation diagram.
%% LEAVE THIS COMMENT: tx mode must show sent image.
%% LEAVE THIS COMMENT: rx mode must show received image and received constellation diagram.
%% LEAVE THIS COMMENT: each mode mush have extensive print debug information
%% LEAVE THIS COMMENT: always give the full code.
%% 4-qam link - pilot-only phase correction
% mode: 'simulation' | 'transmit' | 'receive'
MODE = 'simulation';

%% params
p.M = 4;
p.imgR = 120;
p.imgC = 160;
p.snrDb = 20;
p.scaleTx = (p.M-1)/255;
p.scaleRx = 255/(p.M-1);
p.sps = 4;
p.Fs = 520000;
p.freqOffsetHz = 40000;

pilotSeqShort = [0; 1; 2; 3];
pilotRepeat = 8;
pilotSeq = repmat(pilotSeqShort, pilotRepeat, 1);
preLen  = length(pilotSeq);
midLen  = preLen;
postLen = preLen;

dataNeeded      = p.imgR * p.imgC;
numMidambles    = floor(dataNeeded / 4800);
totalMsgLen     = dataNeeded;
padLen          = 0;
codedPayloadLen = totalMsgLen;

XCORR_SNR_THRESH      = 25;
PWR_NOISE_THRESH_DB   = -20;

% alignment / lock robustness
PEAK_RATIO_THRESH     = 1.25;
PILOT_SCORE_W_PRE     = 2.0;
PILOT_SCORE_W_MID     = 1.0;
PILOT_SCORE_W_POST    = 2.0;

% pilot validity gating
PILOT_PWR_MIN_DB      = PWR_NOISE_THRESH_DB + 8;
PILOT_RHO_MIN         = 0.65;
PILOT_MSE_MAX         = 0.60;

% OTA debug switch: scrambling disabled by default because TX/RX PRBS phase is not shared across processes
USE_SCRAMBLER          = false;

%% objects
srrc = rcosdesign(0.25, 10, p.sps, 'sqrt');
rsEnc = @(x) x;
rsDec = @(y) deal(y, zeros(size(y)));

cfc = comm.CoarseFrequencyCompensator('Modulation','QAM','SampleRate',p.Fs*p.sps);
symbolSync = comm.SymbolSynchronizer( ...
   'SamplesPerSymbol', p.sps, ...
   'TimingErrorDetector','Gardner (non-data-aided)');

idealPilotSyms = qammod(pilotSeq, p.M, 'UnitAveragePower', true);
trimSamples = 10 * p.sps;

% define PN generator, but only use if USE_SCRAMBLER=true
prbsGen = comm.PNSequence( ...
   'Polynomial', [7 6 0], ...
   'InitialConditions', ones(1,7), ...
   'SamplesPerFrame', totalMsgLen);

%% phase search grids (kept for reference)
coarseSteps = [0 45 90 135 180 225 270 315] * pi/180; %#ok<NASGU>
fineSteps   = linspace(-pi/8, pi/8, 24); %#ok<NASGU>
phaseSign   = +1; %#ok<NASGU>

%% frame segmentation
numSeg  = numMidambles + 1;
baseSeg = floor(codedPayloadLen / numSeg);
segLens = baseSeg * ones(1, numSeg);
segLens(end) = codedPayloadLen - sum(segLens(1:end-1));

txFrameSyms = preLen + codedPayloadLen + numMidambles*midLen + postLen;
segStarts = zeros(1, numSeg);
midStarts = zeros(1, numMidambles);

idx      = 1;
preStart = idx;
idx      = idx + preLen;
for s = 1:numSeg
   segStarts(s) = idx;
   idx = idx + segLens(s);
   if s <= numMidambles
       midStarts(s) = idx;
       idx = idx + midLen;
   end
end
postStart = idx;

pilotAnchors   = [preStart, midStarts, postStart];
pilotRelStarts = pilotAnchors - preStart;
pilotWeights   = [PILOT_SCORE_W_PRE, PILOT_SCORE_W_MID*ones(1,numMidambles), PILOT_SCORE_W_POST];

%% print full system config
fprintf('============================================================\n');
fprintf('[INIT] 4-QAM LINK -- MODE=%s\n', MODE);
fprintf('  M=%d-QAM | sps=%d | Fs=%.0fHz | Fs_os=%.0fHz\n', ...
   p.M, p.sps, p.Fs, p.Fs*p.sps);
fprintf('  image: %dx%d = %d pixels\n', p.imgR, p.imgC, dataNeeded);
fprintf('  scaleTx=%.6f  scaleRx=%.6f\n', p.scaleTx, p.scaleRx);
fprintf('  pilotLen=%d (repeat=%d x %d)\n', preLen, pilotRepeat, length(pilotSeqShort));
fprintf('  numMidambles=%d | numSeg=%d\n', numMidambles, numSeg);
fprintf('  segLens=[%s] sum=%d\n', num2str(segLens), sum(segLens));
fprintf('  txFrameSyms=%d\n', txFrameSyms);
fprintf('  preStart=%d | midStarts=[%s] | postStart=%d\n', ...
   preStart, num2str(midStarts), postStart);
fprintf('  trimSamples=%d\n', trimSamples);
fprintf('  freqOffsetHz=%.0f (sim only)\n', p.freqOffsetHz);
fprintf('  xcorrSNR_thresh=%.1fdB | peakRatio_thresh=%.2f\n', XCORR_SNR_THRESH, PEAK_RATIO_THRESH);
fprintf('  pwr_noise_thresh=%.1fdB | pilot_pwr_min=%.1fdB | pilot_rho_min=%.2f | pilot_mse_max=%.2f\n', ...
   PWR_NOISE_THRESH_DB, PILOT_PWR_MIN_DB, PILOT_RHO_MIN, PILOT_MSE_MAX);
fprintf('  xcorr pilot weights: ['); fprintf('%.1f ', pilotWeights); fprintf(']\n');
fprintf('  USE_SCRAMBLER=%d (0 disables PRBS XOR; required for OTA unless you sync PRBS phase)\n', USE_SCRAMBLER);

samplesPerFrame = ceil(txFrameSyms * p.sps * 2.2) + 2*trimSamples;
samplesPerFrame = samplesPerFrame + mod(samplesPerFrame, 2);
fprintf('  samplesPerFrame=%d (%.1f%% margin)\n', ...
   samplesPerFrame, (samplesPerFrame/(txFrameSyms*p.sps)-1)*100);

fprintf('\n  idealPilotSyms (first 8 of %d):\n  ', preLen);
for k = 1:min(8,preLen)
   fprintf('  [%d] %.4f%+.4fi', k, real(idealPilotSyms(k)), imag(idealPilotSyms(k)));
end
fprintf('\n');

constPts = qammod((0:p.M-1)', p.M, 'UnitAveragePower', true);
fprintf('  QAM constellation (UnitAveragePower=true):\n');
for k = 1:p.M
   fprintf('    sym %d --> %.6f %+.6fi\n', k-1, real(constPts(k)), imag(constPts(k)));
end
fprintf('============================================================\n\n');

%% stats
totalBits              = 0;
totalBitErrors         = 0;
totalCorrectedSymbols  = 0;
totalFrames            = 0;
totalDropped           = 0;
totalNoiseDrop         = 0;
totalStradDrop         = 0;
startTime              = tic;
tCapAcc=0; tMfAcc=0; tCfcAcc=0; tSsAcc=0; tXcorrAcc=0; tEqAcc=0;

%% pluto objects
plutoTx = [];
plutoRx = [];
if strcmpi(MODE,'transmit')
   fprintf('[INIT] creating plutoTx...\n');
   plutoTx = comm.SDRTxPluto( ...
       'CenterFrequency', 915e6, ...
       'BasebandSampleRate', p.Fs * p.sps, ...
       'Gain', -10, ...
       'ChannelMapping', 1);
   fprintf('[INIT] plutoTx ready | fc=915MHz | fs=%.0fHz | gain=-10dB\n\n', p.Fs*p.sps);
elseif strcmpi(MODE,'receive')
   fprintf('[INIT] creating plutoRx...\n');
   plutoRx = comm.SDRRxPluto( ...
       'CenterFrequency', 915e6, ...
       'BasebandSampleRate', p.Fs * p.sps, ...
       'OutputDataType','double', ...
       'GainSource', 'Manual', ...
       'Gain', 30, ...
       'SamplesPerFrame', samplesPerFrame);
   fprintf('[INIT] plutoRx ready | samplesPerFrame=%d | gain=30dB fixed\n\n', samplesPerFrame);
end

%% webcam
global RUNNING CAM;
RUNNING = true;
isReceiveMode  = strcmpi(MODE,'receive');
isTransmitMode = strcmpi(MODE,'transmit');
if ~isReceiveMode
   if isempty(CAM), CAM = webcam(); end
end

%% ui
fig = figure('Name',sprintf('4-QAM [%s]',MODE),'NumberTitle','off', ...
   'Color','w','Position',[100 100 1200 420]);
fig.CloseRequestFcn = @(src,~) closeFig(src, plutoTx, plutoRx);

if isReceiveMode
   tiledlayout(1,2,'Padding','compact');
   hTx = [];
   nexttile; hRx = imshow(uint8(zeros(p.imgR, p.imgC))); title('rx image');
   nexttile; hold on;
   hAx = gca;
   hSc = scatter(hAx, 0,0,10,'filled','MarkerFaceAlpha',0.3);
   xlim([-2 2]); ylim([-2 2]); grid on; axis square; title('constellation');
elseif isTransmitMode
   tiledlayout(1,1,'Padding','compact');
   nexttile; hTx = imshow(uint8(zeros(p.imgR, p.imgC))); title('tx image (transmitting)');
   hRx = [];
   hAx = [];
   hSc = [];
else % simulation
   tiledlayout(1,3,'Padding','compact');
   nexttile; hTx = imshow(uint8(zeros(p.imgR, p.imgC))); title('tx');
   nexttile; hRx = imshow(uint8(zeros(p.imgR, p.imgC))); title('rx');
   nexttile; hold on;
   hAx = gca;
   hSc = scatter(hAx, 0,0,10,'filled','MarkerFaceAlpha',0.3);
   xlim([-2 2]); ylim([-2 2]); grid on; axis square; title('constellation');
end

%% main loop
loopIter = 0;
while RUNNING && isvalid(fig)
   loopIter = loopIter + 1;
   tLoopStart = tic;
   rxPwr = -999;

   fprintf('------------------------------------------------------------\n');
   fprintf('[iter %d] START | elapsed=%.1fs | frames=%d dropped=%d\n', ...
       loopIter, toc(startTime), totalFrames, totalDropped);

   if isReceiveMode
       %% ---- receive path ----
       t0 = tic;
       try
           rxData = plutoRx();
       catch err
           fprintf('[iter %d] ERROR capture: %s\n', loopIter, err.message);
           pause(0.01); continue;
       end
       tCap = toc(t0); tCapAcc = tCapAcc + tCap;

       rxPwr     = 10*log10(mean(abs(rxData).^2)+eps);
       rxPwrPeak = 20*log10(max(abs(rxData))+eps);
       rxDC      = abs(mean(rxData));
       rxIQimbal = std(real(rxData))/(std(imag(rxData))+eps);
       fprintf('[iter %d] CAPTURE: t=%.3fs | len=%d | pwr=%.2fdB | peak=%.2fdB\n', ...
           loopIter, tCap, length(rxData), rxPwr, rxPwrPeak);
       fprintf('[iter %d]          dc=%.5f | iq_imbal=%.4f\n', loopIter, rxDC, rxIQimbal);

       if rxPwr < -25
           fprintf('[iter %d]          *** VERY LOW POWER ***\n', loopIter);
       elseif rxPwr < PWR_NOISE_THRESH_DB
           fprintf('[iter %d]          *** LOW POWER (likely noise) ***\n', loopIter);
       elseif rxPwr > 0
           fprintf('[iter %d]          *** NEAR SATURATION ***\n', loopIter);
       end

       t0 = tic;
       rxMF = filter(srrc, 1, rxData);
       tMf = toc(t0); tMfAcc = tMfAcc + tMf;
       fprintf('[iter %d] MF: t=%.3fs | out_pwr=%.2fdB\n', ...
           loopIter, tMf, 10*log10(mean(abs(rxMF).^2)+eps));

       if length(rxMF) <= trimSamples
           fprintf('[iter %d] SKIP: mf too short\n', loopIter);
           totalDropped = totalDropped+1; continue;
       end

       rxMF_trim = rxMF(trimSamples+1:end);

       t0 = tic;
       try
           rxCFC = cfc(rxMF_trim);
       catch e
           fprintf('[iter %d] ERROR cfc: %s\n', loopIter, e.message);
           totalDropped = totalDropped+1; continue;
       end
       tCfc = toc(t0); tCfcAcc = tCfcAcc + tCfc;
       fprintf('[iter %d] CFC: t=%.3fs | out_pwr=%.2fdB\n', ...
           loopIter, tCfc, 10*log10(mean(abs(rxCFC).^2)+eps));

       t0 = tic;
       try
           rxTimed = symbolSync(rxCFC);
       catch e
           fprintf('[iter %d] ERROR symbolSync: %s\n', loopIter, e.message);
           totalDropped = totalDropped+1; continue;
       end
       tSs = toc(t0); tSsAcc = tSsAcc + tSs;
       fprintf('[iter %d] SYMBOL SYNC: t=%.3fs | out=%d (need>=%d) | pwr=%.2fdB | amp_cv=%.3f\n', ...
           loopIter, tSs, length(rxTimed), txFrameSyms, ...
           10*log10(mean(abs(rxTimed).^2)+eps), std(abs(rxTimed))/(mean(abs(rxTimed))+eps));

       if length(rxTimed) < txFrameSyms
           fprintf('[iter %d] SKIP: not enough symbols\n', loopIter);
           totalDropped = totalDropped+1; continue;
       end

       rxData_proc = rxTimed;
       payload = [];

   else
       %% ---- transmit / simulation path ----
       t0 = tic;
       g = captureFrameGray(p, hTx);
       tCap = toc(t0);

       imgMean = mean(double(g(:)));
       imgStd  = std(double(g(:)));
       fprintf('[iter %d] WEBCAM: t=%.3fs | img mean=%.1f std=%.1f min=%d max=%d\n', ...
           loopIter, tCap, imgMean, imgStd, min(g(:)), max(g(:)));

       prbsSeq = makePrbsSeq(prbsGen, totalMsgLen, p.M, USE_SCRAMBLER);
       fprintf('[iter %d] PRBS: use=%d preview(first 16): ', loopIter, USE_SCRAMBLER);
       fprintf('%d ', prbsSeq(1:16)); fprintf('\n');

       [payload, codedPayload] = makePayload(g, p, dataNeeded, padLen, prbsSeq, rsEnc, USE_SCRAMBLER);

       payMin = min(double(payload)); payMax = max(double(payload));
       payMean = mean(double(payload));
       fprintf('[iter %d] PAYLOAD BUILD: len=%d | sym range=[%d,%d] mean=%.2f (expected 0-%d)\n', ...
           loopIter, length(payload), payMin, payMax, payMean, p.M-1);

       txSyms = buildTxFrame(codedPayload, idealPilotSyms, p.M, numSeg, segLens, numMidambles);
       fprintf('[iter %d] TX FRAME STRUCTURE: total_syms=%d (expected=%d)\n', ...
           loopIter, length(txSyms), txFrameSyms);

       t0 = tic;
       txWave = filter(srrc, 1, [upsample(txSyms, p.sps); zeros(trimSamples,1)]);
       tMf = toc(t0);

       txWavePwr  = 10*log10(mean(abs(txWave).^2)+eps);
       txWavePeak = 20*log10(max(abs(txWave))+eps);
       txWavePAPR = txWavePeak - txWavePwr;
       fprintf('[iter %d] PULSE SHAPE: t=%.3fs | wave_len=%d | pwr=%.2fdB | peak=%.2fdB | PAPR=%.2fdB\n', ...
           loopIter, tMf, length(txWave), txWavePwr, txWavePeak, txWavePAPR);

       if isTransmitMode
           txWaveSingle = single(txWave);
           t0 = tic;
           try
               plutoTx.transmitRepeat(txWaveSingle);
               tTx = toc(t0);
               fprintf('[iter %d] TRANSMIT: t=%.3fs | wave_len=%d | dtype=%s\n', ...
                   loopIter, tTx, length(txWaveSingle), class(txWaveSingle));
               fprintf('[iter %d]           single(wave) pwr=%.2fdB peak=%.2fdB\n', ...
                   loopIter, 10*log10(mean(abs(txWaveSingle).^2)+eps), ...
                   20*log10(max(abs(txWaveSingle))+eps));
           catch err
               fprintf('[iter %d] ERROR transmit: %s\n', loopIter, err.message);
           end
           totalFrames = totalFrames + 1;
           fprintf('[iter %d] DONE: frames_queued=%d elapsed=%.1fs loop=%.3fs\n\n', ...
               loopIter, totalFrames, toc(startTime), toc(tLoopStart));
           continue;
       end

       rxData_proc = txrxChain_sim(txSyms, srrc, p, trimSamples, cfc, symbolSync);
       tCfc = 0; tSs = 0; tCap = tMf;
   end

   %% ---- xcorr frame alignment (receive + simulation) ----
   if length(rxData_proc) < txFrameSyms
       fprintf('[iter %d] SKIP: too short (%d < %d)\n', loopIter, length(rxData_proc), txFrameSyms);
       totalDropped = totalDropped+1; continue;
   end

   t0 = tic;
   [rxFrame, bestOffset, xcorrPeak, xcorrNoise, corrProfile, bestRot, secondPeak, peakRatio] = alignFrameByXcorr( ...
       rxData_proc, idealPilotSyms, preLen, txFrameSyms, pilotRelStarts, pilotWeights);
   tXcorr = toc(t0); tXcorrAcc = tXcorrAcc + tXcorr;

   xcorrSNR = 20*log10(xcorrPeak/(xcorrNoise+eps));
   fprintf('[iter %d] XCORR: t=%.3fs | offset=%d/%d (%.1f%%) | rot=%dx90\n', ...
       loopIter, tXcorr, bestOffset, length(corrProfile), bestOffset/length(corrProfile)*100, bestRot);
   fprintf('[iter %d]        peak=%.4f noise=%.4f xcorrSNR=%.2fdB\n', ...
       loopIter, xcorrPeak, xcorrNoise, xcorrSNR);
   fprintf('[iter %d]        2nd=%.4f ratio=%.2f | frame [%d,%d] margin=%d\n', ...
       loopIter, secondPeak, peakRatio, bestOffset, bestOffset+txFrameSyms-1, ...
       length(rxData_proc)-(bestOffset+txFrameSyms-1));

   if isempty(rxFrame)
       fprintf('[iter %d] SKIP: frame extraction failed\n', loopIter);
       totalDropped = totalDropped+1; continue;
   end

   if (xcorrSNR < XCORR_SNR_THRESH) || (peakRatio < PEAK_RATIO_THRESH)
       if rxPwr < PWR_NOISE_THRESH_DB
           fprintf('[iter %d] SKIP: NOISE -- resetting DSP\n', loopIter);
           reset(symbolSync); reset(cfc);
           totalNoiseDrop = totalNoiseDrop+1;
       else
           if peakRatio < PEAK_RATIO_THRESH
               fprintf('[iter %d] SKIP: AMBIGUOUS XCORR (ratio %.2f < %.2f) -- keeping DSP\n', ...
                   loopIter, peakRatio, PEAK_RATIO_THRESH);
           else
               fprintf('[iter %d] SKIP: STRADDLED -- keeping DSP\n', loopIter);
           end
           totalStradDrop = totalStradDrop+1;
       end
       totalDropped = totalDropped+1; continue;
   end

   %% pilot checks + equalization (complex gain)
   fprintf('[iter %d] PILOT CHECKS (least-squares complex gain fit):\n', loopIter);

   anchorPwrDb = zeros(1, numel(pilotAnchors));
   anchorRho   = zeros(1, numel(pilotAnchors));
   anchorMse   = zeros(1, numel(pilotAnchors));
   anchorG     = complex(zeros(1, numel(pilotAnchors)));

   for ai = 1:numel(pilotAnchors)
       a0 = pilotAnchors(ai);
       rxPil = rxFrame(a0:a0+preLen-1);
       [gHat, mseHat, rhoHat, pwrHat] = estPilotGain(rxPil, idealPilotSyms);
       anchorPwrDb(ai) = pwrHat;
       anchorRho(ai)   = rhoHat;
       anchorMse(ai)   = mseHat;
       anchorG(ai)     = gHat;

       tag = 'OK';
       if (pwrHat < PILOT_PWR_MIN_DB) || (rhoHat < PILOT_RHO_MIN) || (mseHat > PILOT_MSE_MAX)
           tag = 'BAD';
       end

       if ai == 1
           fprintf('[iter %d]   pre : pwr=%.2fdB rho=%.3f mse=%.4f | |g|=%.3f ang=%.1fdeg [%s]\n', ...
               loopIter, pwrHat, rhoHat, mseHat, abs(gHat), angle(gHat)*180/pi, tag);
       elseif ai == numel(pilotAnchors)
           fprintf('[iter %d]   post: pwr=%.2fdB rho=%.3f mse=%.4f | |g|=%.3f ang=%.1fdeg [%s]\n', ...
               loopIter, pwrHat, rhoHat, mseHat, abs(gHat), angle(gHat)*180/pi, tag);
       else
           fprintf('[iter %d]   mid%-2d: pwr=%.2fdB rho=%.3f mse=%.4f | |g|=%.3f ang=%.1fdeg [%s]\n', ...
               loopIter, ai-1, pwrHat, rhoHat, mseHat, abs(gHat), angle(gHat)*180/pi, tag);
       end
   end

   if (anchorPwrDb(1) < PILOT_PWR_MIN_DB) || (anchorRho(1) < PILOT_RHO_MIN) || (anchorMse(1) > PILOT_MSE_MAX)
       fprintf('[iter %d] SKIP: PRE PILOT INVALID (pwr=%.2f rho=%.3f mse=%.4f) -- false lock likely\n', ...
           loopIter, anchorPwrDb(1), anchorRho(1), anchorMse(1));
       totalDropped = totalDropped+1; continue;
   end

   t0 = tic;
   [gVec, gAnchors, validMask] = estimatePiecewiseGain(rxFrame, idealPilotSyms, preLen, ...
       preStart, midStarts, postStart, numMidambles, ...
       PILOT_PWR_MIN_DB, PILOT_RHO_MIN, PILOT_MSE_MAX, txFrameSyms);
   tEq = toc(t0); tEqAcc = tEqAcc + tEq;

   gMag = abs(gVec);
   gPh  = unwrap(angle(gVec));
   fprintf('[iter %d] EQ: t=%.3fs | valid_anchors=%d/%d | |g| range=[%.3f,%.3f] | phase range=[%.1f,%.1f]deg\n', ...
       loopIter, tEq, sum(validMask), numel(validMask), min(gMag), max(gMag), min(gPh)*180/pi, max(gPh)*180/pi);
   fprintf('[iter %d]     anchors(valid=1): ', loopIter);
   fprintf('%d ', validMask); fprintf('\n');

   rxFrame_corr = rxFrame .* gVec;

   [~, msePre2, rhoPre2, pwrPre2] = estPilotGain(rxFrame_corr(preStart:preStart+preLen-1), idealPilotSyms);
   fprintf('[iter %d]     post-eq pre pilot: pwr=%.2fdB rho=%.3f mse=%.6f\n', loopIter, pwrPre2, rhoPre2, msePre2);

   %% demod + descramble (scrambler optional)
   rxPay   = extractPayload(rxFrame_corr, segStarts, segLens, numSeg);
   rxDemod = qamdemod(rxPay, p.M, 'UnitAveragePower', true);

   idealConstPts = qammod(rxDemod, p.M, 'UnitAveragePower', true);
   evm = sqrt(mean(abs(rxPay-idealConstPts).^2)) / sqrt(mean(abs(idealConstPts).^2)) * 100;

   symCounts = histcounts(rxDemod, -0.5:1:p.M-0.5);
   symFrac   = symCounts / sum(symCounts);
   chi2stat  = sum((symCounts-mean(symCounts)).^2 / (mean(symCounts)+eps));
   fprintf('[iter %d] PAYLOAD: amp_cv=%.3f | EVM=%.2f%% | IQ_bal=%.4f\n', ...
       loopIter, std(abs(rxPay))/(mean(abs(rxPay))+eps), evm, ...
       mean(real(rxPay).^2)/(mean(imag(rxPay).^2)+eps));
   fprintf('[iter %d] HIST: [%s] fracs=[%.3f %.3f %.3f %.3f] chi2=%.2f\n', ...
       loopIter, num2str(symCounts), symFrac(1), symFrac(2), symFrac(3), symFrac(4), chi2stat);

   prbsSeq = makePrbsSeq(prbsGen, totalMsgLen, p.M, USE_SCRAMBLER);
   fprintf('[iter %d] PRBS: use=%d preview(first 16): ', loopIter, USE_SCRAMBLER);
   fprintf('%d ', prbsSeq(1:16)); fprintf('\n');

   try
       [imgU8, bitErrors, nBits, nCorrSyms] = decodeAndMeasure( ...
           rxDemod, rsDec, prbsSeq, dataNeeded, payload, p, isReceiveMode, USE_SCRAMBLER);
       totalCorrectedSymbols = totalCorrectedSymbols + nCorrSyms;
       totalFrames = totalFrames + 1;
       if ~isReceiveMode
           totalBitErrors = totalBitErrors + bitErrors;
           totalBits = totalBits + nBits;
       end
       if ~isempty(hRx), set(hRx, 'CData', reshape(imgU8, p.imgR, p.imgC)); end
       fprintf('[iter %d] DECODE: corrected=%d | img mean=%.1f std=%.1f min=%d max=%d\n', ...
           loopIter, nCorrSyms, mean(double(imgU8)), std(double(imgU8)), min(imgU8), max(imgU8));
       if ~isReceiveMode
           fprintf('[iter %d]         iter BER=%.4e (%d/%d errors)\n', ...
               loopIter, bitErrors/max(nBits,1), bitErrors, nBits);
       end
   catch decErr
       fprintf('[iter %d] ERROR decode: %s\n', loopIter, decErr.message);
       totalDropped = totalDropped+1; continue;
   end

   fps = totalFrames / toc(startTime);
   fprintf('[iter %d] DONE: frames=%d dropped=%d fps=%.2f loop=%.3fs\n', ...
       loopIter, totalFrames, totalDropped, fps, toc(tLoopStart));
   fprintf('[iter %d]       timing: cap=%.3f mf=%.3f cfc=%.3f ss=%.3f xcorr=%.3f eq=%.3f\n\n', ...
       loopIter, tCap, tMf, tCfc, tSs, tXcorr, tEq);

   if isReceiveMode
       title(sprintf('rx | fps=%.2f EVM=%.1f%% xcorrSNR=%.1fdB ratio=%.2f chi2=%.1f', ...
           fps, evm, xcorrSNR, peakRatio, chi2stat));
   else
       title(sprintf('sim | fps=%.2f BER=%.3e EVM=%.1f%%', ...
           fps, totalBitErrors/max(totalBits,1), evm));
   end

   if ~isempty(hSc) && isgraphics(hSc)
       set(hSc, 'XData', real(rxPay(1:min(2000,end))), ...
                'YData', imag(rxPay(1:min(2000,end))));
   end
   drawnow limitrate;
end

%% helpers
function out = ternary(cond, a, b)
if cond, out = a; else, out = b; end
end

function g = captureFrameGray(p, hTx)
global CAM;
raw = snapshot(CAM);
g = rgb2gray(imresize(raw, [p.imgR, p.imgC]));
if ~isempty(hTx), set(hTx, 'CData', g); end
end

function prbsSeq = makePrbsSeq(prbsGen, totalMsgLen, M, useScr)
if ~useScr
    prbsSeq = zeros(totalMsgLen,1,'uint8');
    return;
end
reset(prbsGen);
prbsSeq = uint8(prbsGen() * (M-1));
end

function [payload, codedPayload] = makePayload(g, p, dataNeeded, padLen, prbsSeq, rsEnc, useScr)
gNorm = double(g(:));
gNorm = (gNorm - min(gNorm)) / (max(gNorm) - min(gNorm) + eps);
payload = uint8(round(gNorm * (p.M - 1)));
payload = [payload; zeros(padLen,1,'uint8')];

if useScr
    payloadScr = bitxor(payload, prbsSeq);
else
    payloadScr = payload;
end

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

function rxData = txrxChain_sim(txSyms, srrc, p, trimSamples, cfc, symbolSync)
guardSyms = 300;
guardPad  = qammod(randi([0 p.M-1], guardSyms, 1), p.M, 'UnitAveragePower', true);
txPadded  = [guardPad; txSyms; guardPad];
txSig = filter(srrc, 1, [upsample(txPadded, p.sps); zeros(trimSamples,1)]);
n     = (0:length(txSig)-1).';
txImp = txSig .* exp(1j*(2*pi*(p.freqOffsetHz/(p.Fs*p.sps))*n));
rxSig = awgn(txImp, p.snrDb, 'measured');
rxMF  = filter(srrc, 1, rxSig);
rxCFC = cfc(rxMF(trimSamples+1:end));
rxData = symbolSync(rxCFC);
end

function [rxFrame, bestOffset, peakVal, noiseFloor, scoreProfile, bestRot, secondPeak, peakRatio] = alignFrameByXcorr(rxData, idealPilotSyms, preLen, txFrameSyms, pilotRelStarts, pilotWeights)
rxFrame = [];
bestOffset = 1;
peakVal = 0;
noiseFloor = 0;
scoreProfile = [];
bestRot = 0;
secondPeak = 0;
peakRatio = inf;

if length(rxData) < txFrameSyms, return; end

maxSearchLen = length(rxData) - txFrameSyms + 1;
idx0 = (1:maxSearchLen).';

bestScoreVec = zeros(maxSearchLen, 1);

for rot = 0:3
   template = idealPilotSyms * exp(1j*rot*pi/2);
   c = abs(conv(rxData, conj(flipud(template)), 'valid'));

   s = zeros(maxSearchLen,1);
   for k = 1:numel(pilotRelStarts)
       s = s + pilotWeights(k) * c(idx0 + pilotRelStarts(k));
   end

   if max(s) > peakVal
       [peakVal, bestOffset] = max(s);
       bestScoreVec = s;
       bestRot = rot;
   end
end

scoreProfile = bestScoreVec;

guard = max(4, preLen);
mask = true(size(bestScoreVec));
lo = max(1, bestOffset-guard);
hi = min(length(bestScoreVec), bestOffset+guard);
mask(lo:hi) = false;

if any(mask)
    noiseFloor = median(bestScoreVec(mask));
    secondPeak = max(bestScoreVec(mask));
else
    noiseFloor = median(bestScoreVec);
    secondPeak = 0;
end

peakRatio = peakVal/(secondPeak+eps);

rxFrame = rxData(bestOffset : bestOffset+txFrameSyms-1);
end

function [gHat, mseHat, rhoHat, pwrDb] = estPilotGain(rxPil, idealPil)
pwrDb = 10*log10(mean(abs(rxPil).^2)+eps);
den = (rxPil' * rxPil) + eps;
num = (rxPil' * idealPil);
gHat = num / den;
mseHat = mean(abs(rxPil*gHat - idealPil).^2);
rhoHat = abs(num) / (sqrt(den * ((idealPil' * idealPil)+eps)) + eps);
end

function [gVec, gAnchors, validMask] = estimatePiecewiseGain(rxFrame, idealPilotSyms, preLen, preStart, midStarts, postStart, numMidambles, pwrMinDb, rhoMin, mseMax, txFrameSyms)
anchors = [preStart, midStarts, postStart];
K = numel(anchors);
gAnchors = complex(nan(1,K));
validMask = false(1,K);

pwrDb = nan(1,K);
rho   = nan(1,K);
mse   = nan(1,K);

for k = 1:K
   rxPil = rxFrame(anchors(k):anchors(k)+preLen-1);
   [gHat, mseHat, rhoHat, pwrHat] = estPilotGain(rxPil, idealPilotSyms);
   gAnchors(k) = gHat;
   pwrDb(k) = pwrHat;
   rho(k)   = rhoHat;
   mse(k)   = mseHat;
   validMask(k) = (pwrHat > pwrMinDb) && (rhoHat > rhoMin) && (mseHat < mseMax);
end

validIdx = find(validMask);
if isempty(validIdx)
   gVec = ones(txFrameSyms,1);
   return;
end

pos = anchors(validIdx).';
g   = gAnchors(validIdx).';

magA = abs(g);
phA  = unwrap(angle(g));

magV = magA(1) * ones(txFrameSyms,1);
phV  = phA(1)  * ones(txFrameSyms,1);

for i = 1:(numel(pos)-1)
   i0 = pos(i);
   i1 = pos(i+1)-1;
   if i1 < i0, continue; end
   magV(i0:i1) = linspace(magA(i), magA(i+1), i1-i0+1).';
   phV(i0:i1)  = linspace(phA(i),  phA(i+1),  i1-i0+1).';
end

magV(pos(end):txFrameSyms) = magA(end);
phV(pos(end):txFrameSyms)  = phA(end);

gVec = magV .* exp(1j*phV);
end

function rxPay = extractPayload(rxFrame, segStarts, segLens, numSeg)
rxPay = complex([]);
for s = 1:numSeg
   rxPay = [rxPay; rxFrame(segStarts(s):segStarts(s)+segLens(s)-1)]; %#ok<AGROW>
end
end

function [imgU8, bitErrors, nBits, nCorrSyms] = decodeAndMeasure(rxDemod, rsDec, prbsSeq, dataNeeded, payload, p, isReceiveMode, useScr)
[decPayloadScr, err] = rsDec(uint8(rxDemod));
nCorrSyms  = sum(err);

if useScr
    decPayload = bitxor(decPayloadScr, prbsSeq);
else
    decPayload = decPayloadScr;
end

imgBytes   = decPayload(1:dataNeeded);
imgU8      = uint8(double(imgBytes) * p.scaleRx);

if isReceiveMode || isempty(payload)
   bitErrors = 0; nBits = 0;
else
   rxBits = de2bi(double(imgBytes),8,'left-msb');
   txBits = de2bi(double(payload(1:dataNeeded)),8,'left-msb');
   bitErrors = sum(rxBits(:) ~= txBits(:));
   nBits = numel(rxBits);
end
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


