% File: WRAPPER_sdr_image_link_MAIN.m
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
        txSyms = buildTxFrame(codedPayload, idealPreSyms, idealMidSyms, idealPostSyms, M, numSeg, segLens, numMidambles);
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

%% 3-barker frame sync and phase stitching
%% idea: use three distinct bpsk barker pilots (pre/mid/post) and do all sync by complex correlation,
%% then use pilot dot-products as phase anchors to stitch a piecewise phase ramp across payload chunks.

prePilot  = state.prePilot(:);   preLen  = length(prePilot);  preN  = norm(prePilot);
midPilot  = state.midPilot(:);   midLen  = length(midPilot);  midN  = norm(midPilot);
postPilot = state.postPilot(:);  postLen = length(postPilot); postN = norm(postPilot);

rxLong = rxData_proc;
rxPwr  = mean(abs(rxLong).^2);
rxLong = rxLong / max(sqrt(rxPwr), 1e-12);

% expected total frame length in symbols (pilot symbols are separate from qam payload)
expFrameLen = preLen + state.codedPayloadLen + state.numMidambles*midLen + postLen;

fprintf('dbg-hunt: rxLen=%d | pre=%d mid=%d post=%d | numMid=%d | codedPay=%d | expFrame=%d\n', ...
    length(rxLong), preLen, midLen, postLen, state.numMidambles, state.codedPayloadLen, expFrameLen);

corrNorm = @(buf, pos, ref, refN) abs(buf(pos:pos+length(ref)-1)'*ref) / ...
    (norm(buf(pos:pos+length(ref)-1))*refN + 1e-12);

% ============================================================
% step 1: find a preamble that has a matching postamble at the expected offset
% ============================================================
thrPre  = 0.80;
thrPost = 0.80;

bestScore  = -inf;
bestPrePos = [];

maxStart = length(rxLong) - expFrameLen + 1;
if maxStart < 1
    fprintf('dbg-hunt: buffer too short for expected frame\n');
    return;
end

for pos = 1:maxStart
    cpre = corrNorm(rxLong, pos, prePilot, preN);
    if cpre < thrPre, continue; end

    postPos = pos + expFrameLen - postLen;
    cpost = corrNorm(rxLong, postPos, postPilot, postN);
    if cpost < thrPost, continue; end

    score = cpre + cpost;
    if score > bestScore
        bestScore  = score;
        bestPrePos = pos;
    end
end

if isempty(bestPrePos)
    fprintf('dbg-hunt: no valid pre+post pair found\n');
    return;
end

bestPostPos = bestPrePos + expFrameLen - postLen;
fprintf('dbg-hunt: bestPre=%d bestPost=%d score=%.3f\n', bestPrePos, bestPostPos, bestScore);

% ============================================================
% step 2: resolve 90-degree rotation and fine phase using barker preamble correlation
% ============================================================
preSeg = rxLong(bestPrePos : bestPrePos + preLen - 1);

bestRot   = 0;
bestMetric = -inf;
bestDot    = 0;

for rot = [0, pi/2, pi, 3*pi/2]
    x = preSeg .* exp(-1j*rot);
    d = x(:)' * prePilot;
    m = abs(d) / (norm(x)*preN + 1e-12);
    if m > bestMetric
        bestMetric = m;
        bestRot    = rot;
        bestDot    = d;
    end
end

fprintf('dbg-hunt: rot=%d deg | preCorr=%.3f\n', round(bestRot*180/pi), bestMetric);

if bestMetric < 0.85
    fprintf('dbg-hunt: weak preamble correlation after rotation (%.3f)\n', bestMetric);
    return;
end

rxRot = rxLong(bestPrePos:end) .* exp(-1j*bestRot);

finePhase = angle(bestDot);
rxRot = rxRot .* exp(-1j*finePhase);
fprintf('dbg-hunt: finePhase=%.2f deg\n', finePhase*180/pi);

preCheckMetric = abs(rxRot(1:preLen)'*prePilot) / (norm(rxRot(1:preLen))*preN + 1e-12);
postCheckMetric = abs(rxRot(expFrameLen-postLen+1:expFrameLen)'*postPilot) / ...
    (norm(rxRot(expFrameLen-postLen+1:expFrameLen))*postN + 1e-12);
fprintf('dbg-hunt: verify preCorr=%.3f postCorr=%.3f\n', preCheckMetric, postCheckMetric);

if preCheckMetric < 0.85 || postCheckMetric < 0.85
    fprintf('dbg-hunt: pilot verify failed\n');
    return;
end

% ============================================================
% step 3: midamble hunt and chunk extraction
% ============================================================
% we assume you already computed state.numSeg and state.segLens (payload symbol lengths per chunk).
% we do a local search around each expected midamble start to tolerate drift.
searchHalfWin = max(16, floor(0.15*midLen));

payloadChunks = cell(state.numSeg, 1);

numAnch = state.numMidambles + 2;
anchorPhase = zeros(numAnch, 1);
anchorCorr  = zeros(numAnch, 1);

% anchor 1 is the preamble at rxRot(1:preLen)
dpre = rxRot(1:preLen)' * prePilot;
anchorPhase(1) = angle(dpre);
anchorCorr(1)  = abs(dpre) / (norm(rxRot(1:preLen))*preN + 1e-12);

cur = preLen + 1;
for s = 1:state.numSeg
    n = state.segLens(s);
    payloadChunks{s} = rxRot(cur:cur+n-1);
    cur = cur + n;

    if s <= state.numMidambles
        expMidPos = cur;
        lo = max(1, expMidPos - searchHalfWin);
        hi = min(length(rxRot) - midLen + 1, expMidPos + searchHalfWin);

        bestMidPos = [];
        bestMidCorr = -inf;
        bestMidDot  = 0;

        for pos = lo:hi
            seg = rxRot(pos:pos+midLen-1);
            d = seg(:)' * midPilot;
            c = abs(d) / (norm(seg)*midN + 1e-12);
            if c > bestMidCorr
                bestMidCorr = c;
                bestMidPos  = pos;
                bestMidDot  = d;
            end
        end

        if isempty(bestMidPos)
            fprintf('dbg-hunt: midamble %d not found (win empty)\n', s);
            continue;
        end

        % if the best midamble is not exactly where we expected, slide the cursor accordingly
        cur = bestMidPos + midLen;

        anchorPhase(s+1) = angle(bestMidDot);
        anchorCorr(s+1)  = bestMidCorr;

        fprintf('dbg-hunt: mid%d pos=%d corr=%.3f\n', s, bestMidPos, bestMidCorr);
    end
end

% last anchor is the postamble at the expected end of the frame
postStart = expFrameLen - postLen + 1;
dpost = rxRot(postStart:postStart+postLen-1)' * postPilot;
anchorPhase(end) = angle(dpost);
anchorCorr(end)  = abs(dpost) / (norm(rxRot(postStart:postStart+postLen-1))*postN + 1e-12);

fprintf('dbg-hunt: post corr=%.3f\n', anchorCorr(end));

% ============================================================
% step 4: piecewise phase correction using pilot phase anchors
% ============================================================
useThr = 0.80;
useFlag = anchorCorr >= useThr;
useFlag(1) = true;

fprintf('dbg-phase: usable anchors=%d/%d\n', sum(useFlag), numAnch);

phUnwrap = anchorPhase;
if sum(useFlag) >= 2
    idxU = find(useFlag);
    phUnwrap(idxU) = unwrap(anchorPhase(idxU));

    for k = 1:numAnch
        if ~useFlag(k)
            [~, ii] = min(abs(k - idxU));
            phUnwrap(k) = phUnwrap(idxU(ii));
        end
    end
end

for seg = 1:state.numSeg
    chunk = payloadChunks{seg};
    if isempty(chunk) || all(chunk == 0), continue; end

    leftAnch  = seg;
    rightAnch = seg + 1;

    ph0 = phUnwrap(leftAnch);
    ph1 = phUnwrap(rightAnch);
    n   = length(chunk);

    ramp = linspace(ph0, ph1, n).';
    payloadChunks{seg} = chunk .* exp(-1j*ramp);
end

% ============================================================
% step 5: assemble payload to codedPayloadLen
% ============================================================
rxPayloadSyms = vertcat(payloadChunks{:});

fprintf('dbg-hunt: assembled payload len=%d | expected=%d\n', length(rxPayloadSyms), state.codedPayloadLen);

if length(rxPayloadSyms) > state.codedPayloadLen
    rxPayloadSyms = rxPayloadSyms(1:state.codedPayloadLen);
elseif length(rxPayloadSyms) < state.codedPayloadLen
    deficit = state.codedPayloadLen - length(rxPayloadSyms);
    fprintf('dbg-hunt: SHORT by %d, zero-padding\n', deficit);
    rxPayloadSyms = [rxPayloadSyms; zeros(deficit, 1)];
end

rxFrame = rxRot(1:expFrameLen);
rxPay   = rxPayloadSyms;

fprintf('dbg-hunt: done | payLen=%d | pwr=%.4g\n', length(rxPay), mean(abs(rxPay).^2));





%% demod and decode
rxDemod = qamdemod(rxPay, p.M, 'UnitAveragePower', true);
fprintf('dbg-demod: len=%d | mod63=%d\n', length(rxDemod), mod(length(rxDemod), 63));
fprintf('dbg-demod-rx: min=%d max=%d unique=%d\n', min(rxDemod), max(rxDemod), numel(unique(rxDemod)));

% additional demod distribution debug
u = unique(rxDemod);
fprintf('dbg-demod-uniq: ');
fprintf('%d ', u(1:min(16,end)));
fprintf('\n');
counts = histcounts(double(rxDemod), -0.5:1:(double(p.M)-0.5));
fprintf('dbg-demod-hist: ');
fprintf('%d ', counts);
fprintf('\n');

try
    % keep your original call
    [imgU8, bitErrors, nBits, nCorrSyms] = decodeAndMeasure(rxDemod, state.rsDec, state.prbsSeq, state.dataNeeded, payload, p);

    fprintf('dbg-pre-decode: rxDemod len=%d | mod(len,fec.n)=%d | mod(len,fec.k)=%d\n', ...
        length(rxDemod), mod(length(rxDemod), state.fec.n), mod(length(rxDemod), state.fec.k));

    % extra decode-side debug without changing behavior
    fprintf('dbg-measure: bitErrors=%d nBits=%d nCorrSyms=%d\n', bitErrors, nBits, nCorrSyms);

    if ~isempty(imgU8)
        fprintf('dbg-img: len=%d | min=%d max=%d unique=%d\n', ...
            length(imgU8), min(imgU8), max(imgU8), numel(unique(imgU8)));
        fprintf('dbg-img-head: ');
        fprintf('%d ', imgU8(1:min(16,end)));
        fprintf('\n');
    end

    state.totalCorrectedSymbols = state.totalCorrectedSymbols + nCorrSyms;
    set(ui.hRx, 'CData', reshape(imgU8, p.imgR, p.imgC));

    state.totalBitErrors = state.totalBitErrors + bitErrors;
    state.totalBits = state.totalBits + nBits;
    state.totalFrames = state.totalFrames + 1;

catch err
    fprintf('dbg-decode: %s at line %d | func=%s\n', err.message, err.stack(1).line, err.stack(1).name);
    if ~isempty(err.stack)
        nst = min(5, numel(err.stack));
        fprintf('dbg-decode-stack:\n');
        for ii = 1:nst
            fprintf('  #%d %s:%d (%s)\n', ii, err.stack(ii).file, err.stack(ii).line, err.stack(ii).name);
        end
    end
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