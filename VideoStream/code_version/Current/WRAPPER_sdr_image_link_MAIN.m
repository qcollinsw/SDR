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

    % power normalization
    rxPwr = mean(abs(rxData_proc).^2);
    rxData_proc = rxData_proc / max(sqrt(rxPwr), 1e-12);
    fprintf('dbg-norm: rxPwr=%.4f | after=%.4f\n', rxPwr, mean(abs(rxData_proc).^2));

    % xcorr for debug reference only
    xcSpan = min(5000, length(rxData_proc));
    xc = abs(xcorr(rxData_proc(1:xcSpan), state.idealPilotSyms));
    xcSorted = sort(xc, 'descend');
    xcPeak = xcSorted(1);
    xc2 = xcSorted(min(2, numel(xcSorted)));
    fprintf('dbg-sync: span=%d | peak=%.3f | 2nd=%.3f | ratio=%.2f | median=%.3f | peak/med=%.1f\n', ...
        xcSpan, xcPeak, xc2, xcPeak/max(xc2,1e-12), median(xc), xcPeak/max(median(xc),1e-12));

    % exhaustive start search (only ~2011 candidates); score multiple far-apart anchors
    maxStart = length(rxData_proc) - state.txFrameSyms + 1;
    if maxStart < 1
        fprintf('dbg: rx too short after sync | have=%d need=%d\n', length(rxData_proc), state.txFrameSyms);
        continue;
    end

    corrPilot = @(seg) abs((seg(:)' * state.idealPilotSyms(:)) / state.preLen);

    ms1 = state.midStarts(1);
    ms2 = state.midStarts(2);
    msL = state.midStarts(state.numMidambles);
    ps  = state.postStart;

    bestScore = -inf;
    bestStart = 1;
    bestPre = 0; bestM1 = 0; bestM2 = 0; bestML = 0; bestPost = 0;

    % strict gating to kill false locks
    gatePre  = 0.95;
    gateM1   = 0.90;
    gateM2   = 0.80;

    for s0 = 1:maxStart
        preSeg  = rxData_proc(s0 : s0+state.preLen-1);
        cPre = corrPilot(preSeg);
        if cPre < gatePre
            continue;
        end

        mid1Seg = rxData_proc(s0+ms1-1 : s0+ms1-1+state.preLen-1);
        cM1 = corrPilot(mid1Seg);
        if cM1 < gateM1
            continue;
        end

        mid2Seg = rxData_proc(s0+ms2-1 : s0+ms2-1+state.preLen-1);
        cM2 = corrPilot(mid2Seg);
        if cM2 < gateM2
            continue;
        end

        midLSeg = rxData_proc(s0+msL-1 : s0+msL-1+state.preLen-1);
        cML = corrPilot(midLSeg);

        postSeg = rxData_proc(s0+ps-1  : s0+ps-1 +state.preLen-1);
        cPost = corrPilot(postSeg);

        % emphasize consistency across anchors; require all of pre/mid1/mid2, reward tail if present
        score = 3*(cPre^2) + 3*(cM1^2) + 2*(cM2^2) + 1*(cML^2) + 1*(cPost^2);

        if score > bestScore
            bestScore = score;
            bestStart = s0;
            bestPre = cPre; bestM1 = cM1; bestM2 = cM2; bestML = cML; bestPost = cPost;
        end
    end

    if ~isfinite(bestScore)
        fprintf('dbg: frame align failed (no candidate passed gates pre>=%.2f mid1>=%.2f mid2>=%.2f)\n', gatePre, gateM1, gateM2);
        continue;
    end

    rxFrame = rxData_proc(bestStart : bestStart+state.txFrameSyms-1);
    fprintf('dbg-align: offset=%d/%d | pre=%.3f mid1=%.3f mid2=%.3f midL=%.3f post=%.3f\n', ...
        bestStart-1, maxStart, bestPre, bestM1, bestM2, bestML, bestPost);

    % raw pilot correlations for debug (same style as before)
    fprintf('dbg-raw-pre:  pos=%d | rawCorr=%.4f\n', 1, bestPre);
    fprintf('dbg-raw-mid1: pos=%d | rawCorr=%.4f\n', ms1, bestM1);
    fprintf('dbg-raw-mid2: pos=%d | rawCorr=%.4f\n', ms2, bestM2);

    for m = max(1,state.numMidambles-2):state.numMidambles
        ms = state.midStarts(m);
        midSeg = rxFrame(ms:ms+state.preLen-1);
        fprintf('dbg-raw-mid%d: pos=%d | rawCorr=%.4f\n', m, ms, corrPilot(midSeg));
    end
    fprintf('dbg-raw-post: pos=%d | rawCorr=%.4f\n', ps, corrPilot(rxFrame(ps:ps+state.preLen-1)));

    % fix rotation ambiguity: try all 4 quadrants, pick best preamble match (tie-break by mse)
    pre = rxFrame(1:state.preLen);
    bestMatch = -1;
    bestRot = 0;
    bestMSE = inf;
    for rot = [0, pi/2, pi, 3*pi/2]
        testPre = pre .* exp(-1j * rot);
        testDemod = qamdemod(testPre, p.M, 'UnitAveragePower', true);
        m = sum(testDemod == double(state.pilotSeq));
        mse = mean(abs(testPre - state.idealPilotSyms).^2);
        if (m > bestMatch) || (m == bestMatch && mse < bestMSE)
            bestMatch = m;
            bestRot = rot;
            bestMSE = mse;
        end
    end
    rxFrame = rxFrame .* exp(-1j * bestRot);
    fprintf('dbg-quadrant: bestRot=%.3f (%.0f deg) | match=%d/%d\n', ...
        bestRot, bestRot*180/pi, bestMatch, state.preLen);

    % fine phase correction after quadrant snap
    pre = rxFrame(1:state.preLen);
    finePhase = angle(pre(:)' * state.idealPilotSyms(:));
    rxFrame = rxFrame .* exp(-1j * finePhase);
    fprintf('dbg-fine-phase: %.4f rad (%.1f deg)\n', finePhase, finePhase*180/pi);

    % verify preamble after corrections
    preCorrected = rxFrame(1:state.preLen);
    preDemod = qamdemod(preCorrected, p.M, 'UnitAveragePower', true);
    pilotMatch = sum(preDemod == double(state.pilotSeq));
    preMSE = mean(abs(preCorrected - state.idealPilotSyms).^2);
    fprintf('dbg-preamble: match=%d/%d | mse=%.4f | evm=%.4f\n', ...
        pilotMatch, state.preLen, preMSE, sqrt(preMSE));
    fprintf('dbg-pre-expected: %s\n', mat2str(double(state.pilotSeq(1:10))'));
    fprintf('dbg-pre-received: %s\n', mat2str(preDemod(1:10)'));

    if pilotMatch < 110
        fprintf('dbg: poor preamble match, skipping frame\n');
        continue;
    end

    % residual frequency offset correction using only robust early anchors
    anchorPositions = zeros(1, 3);
    anchorPhases = zeros(1, 3);
    anchorCorrs = zeros(1, 3);

    % preamble
    anchorPositions(1) = 1 + floor(state.preLen/2);
    preSeg = rxFrame(1:state.preLen);
    c = (preSeg(:)' * state.idealPilotSyms(:)) / state.preLen;
    anchorPhases(1) = angle(c);
    anchorCorrs(1)  = abs(c);

    % mid1
    midSeg = rxFrame(ms1:ms1+state.preLen-1);
    c = (midSeg(:)' * state.idealPilotSyms(:)) / state.preLen;
    anchorPositions(2) = ms1 + floor(state.preLen/2);
    anchorPhases(2) = angle(c);
    anchorCorrs(2)  = abs(c);

    % mid2
    midSeg = rxFrame(ms2:ms2+state.preLen-1);
    c = (midSeg(:)' * state.idealPilotSyms(:)) / state.preLen;
    anchorPositions(3) = ms2 + floor(state.preLen/2);
    anchorPhases(3) = angle(c);
    anchorCorrs(3)  = abs(c);

    anchorPhases = unwrap(anchorPhases);

    fprintf('dbg-anchors: corr first3=[%.3f %.3f %.3f] last3=[%.3f %.3f %.3f]\n', ...
        anchorCorrs(1), anchorCorrs(2), anchorCorrs(3), ...
        anchorCorrs(1), anchorCorrs(2), anchorCorrs(3));
    fprintf('dbg-anchors: phase first3=[%.3f %.3f %.3f] last3=[%.3f %.3f %.3f]\n', ...
        anchorPhases(1), anchorPhases(2), anchorPhases(3), ...
        anchorPhases(1), anchorPhases(2), anchorPhases(3));
    fprintf('dbg-anchors: pos first3=[%d %d %d] last3=[%d %d %d]\n', ...
        anchorPositions(1), anchorPositions(2), anchorPositions(3), ...
        anchorPositions(1), anchorPositions(2), anchorPositions(3));

    x = double(anchorPositions(:));
    y = double(anchorPhases(:));
    w = double(anchorCorrs(:));
    w = (w / max(w)) .^ 4;
    w = max(w, 1e-6);

    A = [ones(size(x)) x];
    theta = (A.'*(w.*A)) \ (A.'*(w.*y));
    b = theta(2);

    % sanity check: apply only if it does not hurt mid1 pilot match
    mid1Seg0 = rxFrame(ms1:ms1+state.preLen-1);
    m1Before = sum(qamdemod(mid1Seg0, p.M, 'UnitAveragePower', true) == double(state.pilotSeq));

    n = (1:state.txFrameSyms).';
    phaseCorr = b * (n - anchorPositions(1));
    rxFrameTest = rxFrame .* exp(-1j * phaseCorr);

    mid1Seg1 = rxFrameTest(ms1:ms1+state.preLen-1);
    m1After = sum(qamdemod(mid1Seg1, p.M, 'UnitAveragePower', true) == double(state.pilotSeq));

    if m1After + 2 < m1Before
        b = 0;
        rxFrameTest = rxFrame;
    end

    rxFrame = rxFrameTest;

    totalDrift = b * (state.txFrameSyms - anchorPositions(1));
    fprintf('dbg-freq: usedAnchors=%d/%d | b=%.6g rad/sym | totalDrift=%.4f rad (%.1f deg)\n', ...
        3, 3, b, totalDrift, totalDrift*180/pi);

    % verify preamble after freq correction
    preFinal = rxFrame(1:state.preLen);
    preFinalDemod = qamdemod(preFinal, p.M, 'UnitAveragePower', true);
    preMatchFinal = sum(preFinalDemod == double(state.pilotSeq));
    fprintf('dbg-pre-post-freq: match=%d/%d | mse=%.4f\n', ...
        preMatchFinal, state.preLen, mean(abs(preFinal - state.idealPilotSyms).^2));

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