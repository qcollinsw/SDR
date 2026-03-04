% File: sdr_image_link_main.m
clear; close all; clc;
%% LEAVE THIS COMMENT: must have 3 modes: simulate, transmit, and receive
%% LEAVE THIS COMMENT: simulation mode must only show sent image, received image, and received constellation diagram.
%% LEAVE THIS COMMENT: simulation mode has rf impairments and an awgn channel
%% LEAVE THIS COMMENT: tx mode must only show sent image.
%% LEAVE THIS COMMENT: rx mode must only show received image and received constellation diagram.
%% LEAVE THIS COMMENT: each mode mush have extensive print debug information
%% LEAVE THIS COMMENT: always give the full code.
%% 4-qam link - pilot-only phase correction
% mode: 'simulation' | 'transmit' | 'receive'
MODE = 'receive';
M = 16;

p = sdr_params_default();
p.MODE = MODE;
p.M = M;

% keep scaling consistent if user changes modulation order
p.scaleTx = (p.M-1)/255;
p.scaleRx = 255/(p.M-1);

[state, io, ui] = sdr_init(p);

fprintf('start | mode=%s\n', p.MODE);
fprintf('M=%d | sps=%d | Fs(sym)=%.0f | Fs(samp)=%.0f\n', p.M, p.sps, p.Fs, p.Fs*p.sps);
fprintf('img=%dx%d | snrDb=%.1f | freqOffsetHz=%g\n', p.imgR, p.imgC, p.snrDb, p.freqOffsetHz);
fprintf('frame: pre=%d mid=%d x%d post=%d | txFrameSyms=%d\n', state.preLen, state.midLen, state.numMidambles, state.postLen, state.txFrameSyms);
fprintf('coding: rs(%d,%d) | totalMsgLen=%d | codedPayloadLen=%d\n\n', state.fec.n, state.fec.k, state.totalMsgLen, state.codedPayloadLen);
m_bits = log2(p.M);
fprintf('dbg-config: scaleTx=%.6f | scaleRx=%.6f\n', m_bits, p.scaleTx, p.scaleRx);
fprintf('dbg-config: rs field=GF(2^%d) | rs n=%d | rs k=%d  | max_qam_idx=%d\n', ...
     state.fec.n, state.fec.k, p.M - 1);



while state.RUNNING && isvalid(ui.fig)
%% generate message
    if strcmpi(p.MODE,'simulation') || strcmpi(p.MODE,'transmit')
        g = captureFrameGray(p, ui.hTx);
        [payload, codedPayload] = makePayload(g, p, state.dataNeeded, state.padLen, state.prbsSeq, state.rsEnc);
        fprintf('dbg-payload-tx: min=%d max=%d unique=%d | coded min=%d max=%d\n', ...
        min(payload), max(payload), numel(unique(payload)), min(codedPayload), max(codedPayload));
        if max(codedPayload) >= p.M
            fprintf('*** WARNING: coded symbol %d exceeds M-1=%d, will wrap in qammod ***\n', max(codedPayload), p.M-1);
        end
        txSyms = buildTxFrame(codedPayload, state.idealPilotSyms, p.M, state.numSeg, state.segLens, state.numMidambles);
    else
        txSyms = [];
        payload = [];
    end
%% transmit and receive
    switch lower(p.MODE)
        case 'simulation'
            rxData = txrxChain_sim(txSyms, state.srrc, p, state.trimSamples, state.cfc, state.symbolSync, state.carrierSync);
        case 'transmit'
            rxData = sdr_tx_only(txSyms, state.srrc, p, state.trimSamples, io.plutoTx);
        case 'receive'
            rxData = sdr_rx_only(io.plutoRx);
        otherwise
            error('unknown MODE: %s', p.MODE);
    end

    if isempty(rxData)
        pause(0.01);
        continue;
    end

    if ~strcmpi(p.MODE,'simulation')
        rxData_proc = sdr_frontend_rx(rxData, state.srrc, state.trimSamples, state.cfc, state.symbolSync, state.carrierSync);
    else
        rxData_proc = rxData;
    end

    if strcmpi(p.MODE,'transmit')
        drawnow limitrate;
        continue;
    end

    if length(rxData_proc) < state.txFrameSyms
        fprintf('dbg: rx too short after sync | have=%d need=%d\n', length(rxData_proc), state.txFrameSyms);
        continue;
    end

    fprintf('dbg-pre-align: rxLen=%d | need=%d | pwr=%.4g\n', ...
    length(rxData_proc), state.txFrameSyms, mean(abs(rxData_proc).^2));


%% barker code and frame sync
%% barker code and frame sync (instrumented + rebuild mids to prevent drift + robust cfo anchors)

% ---- frame schedule rebuild (must match tx) ----
preLen  = state.preLen;
midLen  = state.preLen;
postLen = state.preLen;

numMids = 38;
numSeg  = numMids + 1;

codedPayloadLen = 96000;

padLen = mod(-codedPayloadLen, numSeg);          % 0..numSeg-1
codedPayloadLenEff = codedPayloadLen + padLen;   % used for scheduling
segLen = codedPayloadLenEff / numSeg;            % integer by construction
segLens = segLen * ones(numSeg, 1);

midStarts = zeros(numMids, 1);
idx = preLen + 1;                                % payload starts right after preamble
for m = 1:numMids
    idx = idx + segLens(m);                      % payload segment m
    midStarts(m) = idx;                          % midamble m start
    idx = idx + midLen;                          % midamble itself
end
state.midStarts = midStarts;

postStart = preLen + codedPayloadLenEff + numMids*midLen + 1;
state.postStart = postStart;

state.txFrameSyms = preLen + codedPayloadLenEff + numMids*midLen + postLen;

allMidStarts = state.midStarts(:);
ms1 = state.midStarts(1);
ms2 = state.midStarts(2);
ps  = state.postStart;

% ---- choose longest available buffer ----
rxLong = rxData_proc;  % replace with your longest raw buffer if different

% ---- normalize long buffer ----
rxPwr = mean(abs(rxLong).^2);
rxDen = max(sqrt(rxPwr), 1e-12);
rxLongN = rxLong / rxDen;

fprintf('dbg-norm-long: rxLen=%d | rxPwr=%.6g | denom=%.6g | postPwr=%.6g | postMax=%.6g | postDc=%.6g%+.6gj\n', ...
    length(rxLongN), rxPwr, rxDen, mean(abs(rxLongN).^2), max(abs(rxLongN)), real(mean(rxLongN)), imag(mean(rxLongN)));

maxStart = length(rxLongN) - state.txFrameSyms + 1;
fprintf('dbg-align-long: maxStart=%d | needFrameSyms=%d\n', maxStart, state.txFrameSyms);
if maxStart < 1
    fprintf('dbg-align-long: too short | have=%d need=%d\n', length(rxLongN), state.txFrameSyms);
    continue;
end

pilot  = state.idealPilotSyms(:);
pilotN = norm(pilot) + 1e-12;

corrPilot  = @(seg) abs((seg(:)' * pilot) / preLen);
corrPilotN = @(seg) abs(seg(:)' * pilot) / ((norm(seg(:)) + 1e-12) * pilotN);
segPwr     = @(seg) mean(abs(seg(:)).^2);

gatePre = 0.90;

% ---- coarse-to-fine start search ----
step = 4;
bestScore = -inf; bestStart = 1;
best_cPre = NaN; best_cPreN = NaN; best_prePwr = NaN;
best_cM1  = NaN; best_cM1N  = NaN; best_m1Pwr  = NaN;
best_cM2  = NaN; best_cM2N  = NaN; best_m2Pwr  = NaN;

prePass = 0; preFail = 0;
maxPre = -inf; argMaxPre = 1; maxPreN = -inf;

for s0 = 1:step:maxStart
    preSeg = rxLongN(s0 : s0+preLen-1);
    cPre  = corrPilot(preSeg);
    cPreN = corrPilotN(preSeg);

    if cPre > maxPre
        maxPre = cPre; argMaxPre = s0; maxPreN = cPreN;
    end

    if cPre < gatePre
        preFail = preFail + 1;
        continue;
    end
    prePass = prePass + 1;

    m1Seg = rxLongN(s0+ms1-1 : s0+ms1-1+preLen-1);
    m2Seg = rxLongN(s0+ms2-1 : s0+ms2-1+preLen-1);

    cM1 = corrPilot(m1Seg);
    cM2 = corrPilot(m2Seg);

    score = 3*(cPre^2) + 2*(cM1^2) + 1*(cM2^2);

    if score > bestScore
        bestScore = score;
        bestStart = s0;

        best_cPre = cPre; best_cPreN = cPreN; best_prePwr = segPwr(preSeg);
        best_cM1  = cM1;  best_cM1N  = corrPilotN(m1Seg); best_m1Pwr  = segPwr(m1Seg);
        best_cM2  = cM2;  best_cM2N  = corrPilotN(m2Seg); best_m2Pwr  = segPwr(m2Seg);
    end
end

fprintf('dbg-align-long: step=%d | gatePre=%.3f | prePass=%d preFail=%d | maxPre=%.3f maxPreN=%.3f at s0=%d\n', ...
    step, gatePre, prePass, preFail, maxPre, maxPreN, argMaxPre);

if ~isfinite(bestScore)
    fprintf('dbg-align-long: gate blocked; best preamble anywhere is maxPre=%.3f maxPreN=%.3f at s0=%d\n', ...
        maxPre, maxPreN, argMaxPre);
    continue;
end

if step > 1
    win = 4*step*10;
    sLo = max(1, bestStart - win);
    sHi = min(maxStart, bestStart + win);

    bestScoreFine = -inf; bestStartFine = bestStart;
    for s0 = sLo:sHi
        preSeg = rxLongN(s0 : s0+preLen-1);
        cPre = corrPilot(preSeg);
        if cPre < gatePre, continue; end

        m1Seg = rxLongN(s0+ms1-1 : s0+ms1-1+preLen-1);
        m2Seg = rxLongN(s0+ms2-1 : s0+ms2-1+preLen-1);

        cM1 = corrPilot(m1Seg);
        cM2 = corrPilot(m2Seg);

        score = 3*(cPre^2) + 2*(cM1^2) + 1*(cM2^2);
        if score > bestScoreFine
            bestScoreFine = score;
            bestStartFine = s0;
        end
    end

    fprintf('dbg-align-long-refine: win=±%d | coarseStart=%d | fineStart=%d | fineScore=%.6g\n', ...
        win, bestStart, bestStartFine, bestScoreFine);

    bestStart = bestStartFine;
end

fprintf('dbg-align-best-long: s0=%d | score=%.6g | pre c=%.3f cN=%.3f pwr=%.6g | m1 c=%.3f cN=%.3f pwr=%.6g | m2 c=%.3f cN=%.3f pwr=%.6g\n', ...
    bestStart, bestScore, best_cPre, best_cPreN, best_prePwr, best_cM1, best_cM1N, best_m1Pwr, best_cM2, best_cM2N, best_m2Pwr);

rxFrame = rxLongN(bestStart : bestStart + state.txFrameSyms - 1);
fprintf('dbg-frame-long: extracted | len=%d | pwr=%.6g | max=%.6g | dc=%.6g%+.6gj\n', ...
    length(rxFrame), mean(abs(rxFrame).^2), max(abs(rxFrame)), real(mean(rxFrame)), imag(mean(rxFrame)));

% ---- timing drift probe ----
dWin = 16;
for m = 1:length(allMidStarts)
    ms = allMidStarts(m);
    bestLocal = -inf; bestD = 0; bestLocalN = -inf;

    for d = -dWin:dWin
        ii = ms + d;
        if ii < 1 || (ii + preLen - 1) > length(rxFrame), continue; end
        seg = rxFrame(ii : ii + preLen - 1);
        c  = corrPilot(seg);
        cN = corrPilotN(seg);
        if c > bestLocal
            bestLocal = c;
            bestLocalN = cN;
            bestD = d;
        end
    end

    fprintf('dbg-timing: mid%02d | ms=%d | bestD=%+d | corr=%.3f | corrN=%.3f\n', ...
        m, ms, bestD, bestLocal, bestLocalN);
end

% ---- rotation ambiguity ----
pre = rxFrame(1:preLen);

fprintf('dbg-rot: start | preSeg pwr=%.6g max=%.6g dc=%.6g%+.6gj\n', ...
    mean(abs(pre).^2), max(abs(pre)), real(mean(pre)), imag(mean(pre)));

bestMatch = -1;
bestRot = 0;
for rot = [0, pi/2, pi, 3*pi/2]
    testPre = pre .* exp(-1j * rot);
    testDemod = qamdemod(testPre, p.M, 'UnitAveragePower', true);
    m = sum(testDemod == double(state.pilotSeq));
    fprintf('dbg-rot: rot=%.0fdeg | match=%d/%d\n', rot*180/pi, m, preLen);
    if m > bestMatch
        bestMatch = m;
        bestRot = rot;
    end
end
fprintf('dbg-rot: chosen rot=%.0fdeg | bestMatch=%d/%d\n', bestRot*180/pi, bestMatch, preLen);

rxFrame = rxFrame .* exp(-1j * bestRot);

% ---- fine phase snap ----
pre = rxFrame(1:preLen);
dotPre = pre(:)' * pilot;
finePhase = angle(dotPre);

fprintf('dbg-phase: dotPre=%.6g%+.6gj | abs=%.6g | ang=%.3fdeg | corrGate=%.3f | corrNorm=%.3f\n', ...
    real(dotPre), imag(dotPre), abs(dotPre), finePhase*180/pi, abs(dotPre)/preLen, abs(dotPre)/((norm(pre)+1e-12)*pilotN));

rxFrame = rxFrame .* exp(-1j * finePhase);

preDemod = qamdemod(rxFrame(1:preLen), p.M, 'UnitAveragePower', true);
pilotMatch = sum(preDemod == double(state.pilotSeq));
fprintf('dbg-precheck: match=%d/%d\n', pilotMatch, preLen);

if pilotMatch < 100
    fprintf('dbg: poor preamble match (%d/%d), skipping\n', pilotMatch, preLen);
    preNow = rxFrame(1:preLen);
    mseNow = mean(abs(preNow - pilot).^2);
    cNow   = abs(preNow(:)'*pilot)/preLen;
    cNowN  = abs(preNow(:)'*pilot)/((norm(preNow)+1e-12)*pilotN);
    fprintf('dbg-precheck-detail: mse=%.6g | corr=%.3f | corrN=%.3f | prePwr=%.6g\n', ...
        mseNow, cNow, cNowN, mean(abs(preNow).^2));
    continue;
end

%% residual frequency offset correction (robust anchors + collapse stop), using rebuilt mids

numPotential = 1 + numMids + 1;

ap    = zeros(numPotential, 1);
aph   = zeros(numPotential, 1);
ac    = zeros(numPotential, 1);
corrN = zeros(numPotential, 1);

anchor_meas = @(seg) deal( ...
    (seg(:)'*pilot)/preLen, ...
    abs((seg(:)'*pilot)/preLen), ...
    angle((seg(:)'*pilot)/preLen), ...
    abs(seg(:)'*pilot)/((norm(seg(:))+1e-12)*pilotN), ...
    mean(abs(seg(:)).^2) );

k = 1;
preSeg = rxFrame(1:preLen);
[cC, cAbs, cAng, cN, ~] = anchor_meas(preSeg);
ap(k)    = 1 + floor(preLen/2);
aph(k)   = cAng;
ac(k)    = cAbs;
corrN(k) = cN;

fprintf('dbg-freq-anch: pre | ap=%d | c=%.6g%+.6gj | abs=%.6g | ang=%.3fdeg | corrN=%.3f\n', ...
    ap(k), real(cC), imag(cC), cAbs, cAng*180/pi, cN);

for m = 1:numMids
    k = k + 1;
    ms = allMidStarts(m);
    seg = rxFrame(ms : ms + midLen - 1);
    [cC, cAbs, cAng, cN, ~] = anchor_meas(seg);

    ap(k)    = ms + floor(midLen/2);
    aph(k)   = cAng;
    ac(k)    = cAbs;
    corrN(k) = cN;

    fprintf('dbg-freq-anch: mid%02d | ms=%d ap=%d | abs=%.6g | ang=%.3fdeg | corrN=%.3f\n', ...
        m, ms, ap(k), cAbs, cAng*180/pi, cN);
end

k = k + 1;
postSeg = rxFrame(ps : ps + postLen - 1);
[cC, cAbs, cAng, cN, ~] = anchor_meas(postSeg);

ap(k)    = ps + floor(postLen/2);
aph(k)   = cAng;
ac(k)    = cAbs;
corrN(k) = cN;

fprintf('dbg-freq-anch: post | ps=%d ap=%d | abs=%.6g | ang=%.3fdeg | corrN=%.3f\n', ...
    ps, ap(k), cAbs, cAng*180/pi, cN);

ampThr  = 0.4 * ac(1);
corrThr = 0.985;
validBase = (ac >= ampThr) & (corrN >= corrThr);

stopIdx = numPotential;
badRun = 0;
for ii = 2:(numPotential-1)
    if corrN(ii) < 0.95
        badRun = badRun + 1;
    else
        badRun = 0;
    end
    if badRun >= 2
        stopIdx = ii - 1;
        break;
    end
end

validIdx = validBase;
if stopIdx < numPotential
    validIdx((stopIdx+1):end) = false;
end

fprintf('dbg-freq-gate: ampThr=%.6g (0.4*preAbs) corrThr=%.3f | stopIdx=%d/%d | valid=%d/%d\n', ...
    ampThr, corrThr, stopIdx, numPotential, sum(validIdx), numPotential);
fprintf('dbg-freq-gate: corrN[min,med,max]=[%.3f, %.3f, %.3f]\n', min(corrN), median(corrN), max(corrN));

if sum(validIdx) >= 2
    x = double(ap(validIdx));
    y = unwrap(double(aph(validIdx)));
    y = y - y(1);

    w = (ac(validIdx) / (max(ac(validIdx)) + 1e-12)).^4;
    w = w / (max(w) + 1e-12);

    A  = [ones(size(x)) x];
    Aw = A .* sqrt(w);
    yw = y .* sqrt(w);
    theta = (Aw.'*Aw) \ (Aw.'*yw);

    a = theta(1);
    b = theta(2);

    yhat = A*theta;
    wrmse = sqrt(sum(w .* (y - yhat).^2) / (max(sum(w), 1e-12)));
    driftDeg = (b * double(state.txFrameSyms)) * 180/pi;

    fprintf('dbg-freq-fit: a=%.6g rad | b=%.6g rad/sym | drift=%.3f deg over %d syms | cond(AtWA)=%.3g | wrmse=%.6g rad\n', ...
        a, b, driftDeg, state.txFrameSyms, cond(Aw.'*Aw), wrmse);
    fprintf('dbg-freq-fit: x[min,max]=[%d,%d] | y[min,max]=[%.6g,%.6g] rad | w[min,max]=[%.6g,%.6g]\n', ...
        round(min(x)), round(max(x)), min(y), max(y), min(w), max(w));

    n = (1:state.txFrameSyms).';
    rxFrame = rxFrame .* exp(-1j * (a + b*double(n)));

    fprintf('dbg-freq: anchors=%d/%d | drift=%.3f deg\n', sum(validIdx), numPotential, driftDeg);
else
    fprintf('dbg-freq: insufficient anchors after gating, skipping\n');
end

% ---- post-correction verification ----
preFinal = rxFrame(1:preLen);
preFinalDemod = qamdemod(preFinal, p.M, 'UnitAveragePower', true);
preMatchFinal = sum(preFinalDemod == double(state.pilotSeq));

cFinal  = abs(preFinal(:)'*pilot)/preLen;
cFinalN = abs(preFinal(:)'*pilot)/((norm(preFinal)+1e-12)*pilotN);
mseFinal = mean(abs(preFinal - pilot).^2);
prePwrFinal = mean(abs(preFinal).^2);

fprintf('dbg-align-final: match=%d/%d | mse=%.6g | corr=%.6g | corrN=%.3f | prePwr=%.6g\n', ...
    preMatchFinal, preLen, mseFinal, cFinal, cFinalN, prePwrFinal);

m1SegF = rxFrame(ms1:ms1+preLen-1);
m2SegF = rxFrame(ms2:ms2+preLen-1);

cM1F  = abs(m1SegF(:)'*pilot)/preLen;
cM1FN = abs(m1SegF(:)'*pilot)/((norm(m1SegF)+1e-12)*pilotN);
cM2F  = abs(m2SegF(:)'*pilot)/preLen;
cM2FN = abs(m2SegF(:)'*pilot)/((norm(m2SegF)+1e-12)*pilotN);

fprintf('dbg-mid-final: m1 corr=%.6g corrN=%.3f pwr=%.6g | m2 corr=%.6g corrN=%.3f pwr=%.6g\n', ...
    cM1F, cM1FN, mean(abs(m1SegF).^2), cM2F, cM2FN, mean(abs(m2SegF).^2));

% ---- payload extraction consistent with rebuilt schedule ----
payloadStart = preLen + 1;
payloadEnd   = preLen + codedPayloadLenEff + numMids*midLen;

rawPayload = rxFrame(payloadStart:payloadEnd);

mask = true(size(rawPayload));
for m = 1:numMids
    ms = allMidStarts(m);
    midRel = ms - payloadStart + 1;
    mask(midRel:midRel+midLen-1) = false;
end
rxPayloadSyms = rawPayload(mask);

if length(rxPayloadSyms) ~= codedPayloadLenEff
    fprintf('dbg-payload: unexpected len=%d expected=%d\n', length(rxPayloadSyms), codedPayloadLenEff);
else
    fprintf('dbg-payload: extracted payload len=%d (padLen=%d)\n', codedPayloadLenEff, padLen);
end

if padLen > 0 && length(rxPayloadSyms) >= codedPayloadLen
    rxPayloadSyms = rxPayloadSyms(1:codedPayloadLen);
end
%% demod and decode
    rxPay = extractPayload(rxFrame, state.segStarts, state.segLens, state.numSeg);
    rxDemod = qamdemod(rxPay, p.M, 'UnitAveragePower', true);
    fprintf('dbg-demod: len=%d | mod63=%d\n', length(rxDemod), mod(length(rxDemod), 63));
    fprintf('dbg-demod-rx: min=%d max=%d unique=%d\n', min(rxDemod), max(rxDemod), numel(unique(rxDemod)));

    try
        [imgU8, bitErrors, nBits, nCorrSyms] = decodeAndMeasure(rxDemod, state.rsDec, state.prbsSeq, state.dataNeeded, payload, p);
        fprintf('dbg-pre-decode: rxDemod len=%d | mod(len,fec.n)=%d | mod(len,fec.k)=%d\n', ...
        length(rxDemod), mod(length(rxDemod), state.fec.n), mod(length(rxDemod), state.fec.k));

        state.totalCorrectedSymbols = state.totalCorrectedSymbols + nCorrSyms;
        set(ui.hRx, 'CData', reshape(imgU8, p.imgR, p.imgC));

        state.totalBitErrors = state.totalBitErrors + bitErrors;
        state.totalBits = state.totalBits + nBits;
        state.totalFrames = state.totalFrames + 1;

    catch err
        fprintf('dbg-decode: %s at line %d | func=%s\n', err.message, err.stack(1).line, err.stack(1).name);
        continue;
    end

    elapsed = toc(state.startTime);
    fps = state.totalFrames / max(elapsed, 1e-9);
    ber = state.totalBitErrors / max(state.totalBits, 1);

    if ~isempty(ui.hSc) && isgraphics(ui.hSc)
        set(ui.hSc, 'XData', real(rxPay(1:min(2000,end))), 'YData', imag(rxPay(1:min(2000,end))));
    end

    title(ui.axSc, sprintf('constellation | fps=%.2f | ber=%.3e | mids=%d | mode=%s', fps, ber, state.numMidambles, p.MODE));

    fprintf('dbg: frame=%d | fps=%.2f | ber=%.3e | rsCorrSyms=%d\n', state.totalFrames, fps, ber, nCorrSyms);

    drawnow limitrate;
end