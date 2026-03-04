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
        guardLen = 5000;
        txSyms = [txSyms; zeros(guardLen, 1)];
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

%% frame sync — multi-candidate preamble + chunk-wise pilot hunt

pilot = state.idealPilotSyms(:);
pilotLen = length(pilot);
pilotN = norm(pilot);
pilotSeqU8 = double(state.pilotSeq(:));

% normalize rx buffer
rxLong = rxData_proc;
rxPwr = mean(abs(rxLong).^2);
rxLong = rxLong / max(sqrt(rxPwr), 1e-12);

fprintf('dbg-hunt: rxLen=%d | pilotLen=%d | numMids=%d | numSeg=%d | codedPayloadLen=%d\n', ...
    length(rxLong), pilotLen, state.numMidambles, state.numSeg, state.codedPayloadLen);

corrAt = @(buf, pos) abs(buf(pos:pos+pilotLen-1)' * pilot) / ...
    (norm(buf(pos:pos+pilotLen-1)) * pilotN + 1e-12);

% ============================================================
%  step 1: find ALL preamble candidates, pick best by midamble score
% ============================================================
maxSearch = length(rxLong) - state.txFrameSyms + 1;
if maxSearch < 1
    fprintf('dbg-hunt: buffer too short | have=%d need=%d\n', length(rxLong), state.txFrameSyms);
    continue;
end

% coarse scan — collect all positions above threshold
step = 4;
candidates = zeros(0, 2);
for s0 = 1:step:maxSearch
    c = corrAt(rxLong, s0);
    if c > 0.90
        candidates(end+1,:) = [s0, c]; %#ok<AGROW>
    end
end

if isempty(candidates)
    fprintf('dbg-hunt: no preamble candidates found, skipping\n');
    continue;
end

% fine-tune each candidate
for ci = 1:size(candidates,1)
    sLo = max(1, candidates(ci,1) - step*4);
    sHi = min(maxSearch, candidates(ci,1) + step*4);
    for s1 = sLo:sHi
        c2 = corrAt(rxLong, s1);
        if c2 > candidates(ci,2)
            candidates(ci,:) = [s1, c2];
        end
    end
end

% deduplicate candidates within 100 samples of each other
dedupCands = candidates(1,:);
for ci = 2:size(candidates,1)
    if all(abs(candidates(ci,1) - dedupCands(:,1)) > 100)
        dedupCands(end+1,:) = candidates(ci,:); %#ok<AGROW>
    else
        % keep the stronger one
        [~, idx] = min(abs(candidates(ci,1) - dedupCands(:,1)));
        if candidates(ci,2) > dedupCands(idx,2)
            dedupCands(idx,:) = candidates(ci,:);
        end
    end
end
candidates = dedupCands;

fprintf('dbg-hunt: found %d preamble candidates\n', size(candidates,1));

% score each candidate by consecutive good midambles
checkMids = min(state.numMidambles, 10);
bestScore = -1;
bestPrePos = 1;
bestPreCorr = 0;

for ci = 1:size(candidates,1)
    s0 = candidates(ci,1);
    score = 0;
    cur = s0 + pilotLen;
    for seg = 1:checkMids
        expMid = round(cur + state.segLens(seg));
        sLo2 = max(expMid - 20, cur + 1);
        sHi2 = min(expMid + 20, length(rxLong) - pilotLen + 1);
        if sHi2 <= sLo2, break; end
        bestC = 0;
        for s = sLo2:sHi2
            if s + pilotLen - 1 > length(rxLong), break; end
            c = corrAt(rxLong, s);
            if c > bestC, bestC = c; end
        end
        if bestC > 0.85
            score = score + 1;
            cur = expMid + pilotLen;
        else
            break;
        end
    end
    fprintf('dbg-hunt: candidate %d | pos=%d | corrN=%.4f | goodMids=%d/%d\n', ...
        ci, candidates(ci,1), candidates(ci,2), score, checkMids);
    if score > bestScore || (score == bestScore && candidates(ci,2) > bestPreCorr)
        bestScore = score;
        bestPrePos = candidates(ci,1);
        bestPreCorr = candidates(ci,2);
    end
end

fprintf('dbg-hunt: selected preamble at %d | corrN=%.4f | goodMids=%d/%d\n', ...
    bestPrePos, bestPreCorr, bestScore, checkMids);

if bestPreCorr < 0.80
    fprintf('dbg-hunt: preamble too weak (%.3f), skipping\n', bestPreCorr);
    continue;
end

% ============================================================
%  step 2: resolve 90-degree rotation using preamble
% ============================================================
preSeg = rxLong(bestPrePos : bestPrePos + pilotLen - 1);
bestRot = 0;
bestMatch = 0;
for rot = [0, pi/2, pi, 3*pi/2]
    d = qamdemod(preSeg .* exp(-1j*rot), p.M, 'UnitAveragePower', true);
    m = sum(double(d) == pilotSeqU8);
    if m > bestMatch
        bestMatch = m;
        bestRot = rot;
    end
end
fprintf('dbg-hunt: rotation=%d deg | match=%d/%d\n', round(bestRot*180/pi), bestMatch, pilotLen);

if bestMatch < pilotLen - 2
    fprintf('dbg-hunt: poor rotation match (%d/%d), skipping\n', bestMatch, pilotLen);
    continue;
end

% apply rotation from preamble onward
rxRot = rxLong(bestPrePos:end) .* exp(-1j * bestRot);

% fine phase snap
preFine = rxRot(1:pilotLen);
dotPre = preFine(:)' * pilot;
finePhase = angle(dotPre);
rxRot = rxRot .* exp(-1j * finePhase);
fprintf('dbg-hunt: finePhase=%.2f deg\n', finePhase * 180/pi);

% verify
preCheck = qamdemod(rxRot(1:pilotLen), p.M, 'UnitAveragePower', true);
preMatch = sum(double(preCheck) == pilotSeqU8);
fprintf('dbg-hunt: post-correction preamble match=%d/%d\n', preMatch, pilotLen);

if preMatch < pilotLen - 4
    fprintf('dbg-hunt: preamble verify failed (%d/%d), skipping\n', preMatch, pilotLen);
    continue;
end

% ============================================================
%  step 3: hunt for each midamble, extract payload chunks
% ============================================================
ternary = @(cond, a, b) subsref({b, a}, struct('type','{}','subs',{{cond+1}}));
huntWin = 20;

corrAtR = @(pos) abs(rxRot(pos:pos+pilotLen-1)' * pilot) / ...
    (norm(rxRot(pos:pos+pilotLen-1)) * pilotN + 1e-12);

anchorPos = zeros(state.numMidambles + 2, 1);
anchorCorr = zeros(state.numMidambles + 2, 1);
anchorPhase = zeros(state.numMidambles + 2, 1);

anchorPos(1) = 1;
anchorCorr(1) = 1.0;
anchorPhase(1) = 0;

payloadChunks = cell(state.numSeg, 1);
cursor = pilotLen + 1;
hitBoundary = false;

for seg = 1:state.numSeg
    if hitBoundary
        payloadChunks{seg} = zeros(state.segLens(seg), 1);
        continue;
    end

    expectedMidPos = round(cursor + state.segLens(seg));

    if seg <= state.numMidambles
        % hunt for midamble
        searchLo = max(expectedMidPos - huntWin, cursor + 1);
        searchHi = min(expectedMidPos + huntWin, length(rxRot) - pilotLen + 1);

        bestMidCorr = -1;
        bestMidPos = expectedMidPos;

        for s = searchLo:searchHi
            if s + pilotLen - 1 > length(rxRot), break; end
            c = corrAtR(s);
            if c > bestMidCorr
                bestMidCorr = c;
                bestMidPos = s;
            end
        end

        payEnd = bestMidPos - 1;
        actualLen = payEnd - cursor + 1;
        expectedLen = state.segLens(seg);

        if bestMidCorr > 0.85 && abs(actualLen - expectedLen) <= 20
            % strong match — trust hunt
            payloadChunks{seg} = rxRot(cursor : payEnd);
            nextCursor = bestMidPos + pilotLen;
        else
            % boundary or noise — zero-fill this and all remaining
            fprintf('dbg-hunt: seg%02d | boundary detected (corrN=%.3f), zero-filling rest\n', seg, bestMidCorr);
            for fillSeg = seg:state.numSeg
                payloadChunks{fillSeg} = zeros(state.segLens(fillSeg), 1);
            end
            for fillAnch = (seg+1):(state.numMidambles+2)
                anchorCorr(fillAnch) = 0;
                anchorPhase(fillAnch) = 0;
            end
            hitBoundary = true;
            continue;
        end

        % pad/trim to exact length
        if length(payloadChunks{seg}) < expectedLen
            deficit = expectedLen - length(payloadChunks{seg});
            payloadChunks{seg} = [payloadChunks{seg}; zeros(deficit, 1)];
        elseif length(payloadChunks{seg}) > expectedLen
            payloadChunks{seg} = payloadChunks{seg}(1:expectedLen);
        end

        % measure phase
        anchorIdx = seg + 1;
        midSeg = rxRot(bestMidPos : min(bestMidPos + pilotLen - 1, length(rxRot)));
        if length(midSeg) == pilotLen
            midDot = midSeg(:)' * pilot;
            midPhase = angle(midDot);
            midCorrN = abs(midDot) / ((norm(midSeg) + 1e-12) * pilotN);
        else
            midPhase = 0; midCorrN = 0;
        end

        anchorPos(anchorIdx) = bestMidPos;
        anchorCorr(anchorIdx) = midCorrN;
        anchorPhase(anchorIdx) = midPhase;

        fprintf('dbg-hunt: seg%02d | midFound=%d | corrN=%.3f | phase=%.2f deg | chunkLen=%d (expect %d) | drift=%+d | mode=%s\n', ...
            seg, bestMidPos, midCorrN, midPhase*180/pi, actualLen, expectedLen, actualLen - expectedLen, ...
            ternary(bestMidCorr > 0.85 && abs(actualLen - expectedLen) <= 20, 'lock', 'det'));

        cursor = nextCursor;

    else
        % last segment — hunt for postamble
        searchLo = max(expectedMidPos - huntWin, cursor + 1);
        searchHi = min(expectedMidPos + huntWin, length(rxRot) - pilotLen + 1);

        bestPostCorr = -1;
        bestPostPos = min(expectedMidPos, length(rxRot) - pilotLen + 1);

        for s = searchLo:searchHi
            if s + pilotLen - 1 > length(rxRot), break; end
            c = corrAtR(s);
            if c > bestPostCorr
                bestPostCorr = c;
                bestPostPos = s;
            end
        end

        expectedLen = state.segLens(seg);
        payEnd = bestPostPos - 1;
        actualLen = payEnd - cursor + 1;

        if bestPostCorr > 0.85 && abs(actualLen - expectedLen) <= 20
            payloadChunks{seg} = rxRot(cursor : payEnd);
        else
            payloadChunks{seg} = zeros(expectedLen, 1);
            fprintf('dbg-hunt: seg%02d (last) | boundary detected (corrN=%.3f), zero-filled\n', seg, bestPostCorr);
        end

        if length(payloadChunks{seg}) < expectedLen
            deficit = expectedLen - length(payloadChunks{seg});
            payloadChunks{seg} = [payloadChunks{seg}; zeros(deficit, 1)];
        elseif length(payloadChunks{seg}) > expectedLen
            payloadChunks{seg} = payloadChunks{seg}(1:expectedLen);
        end

        if bestPostCorr > 0.85 && bestPostPos + pilotLen - 1 <= length(rxRot)
            postSeg = rxRot(bestPostPos : bestPostPos + pilotLen - 1);
            postDot = postSeg(:)' * pilot;
            postPhase = angle(postDot);
            postCorrN = abs(postDot) / ((norm(postSeg) + 1e-12) * pilotN);
        else
            postPhase = 0; postCorrN = 0;
        end

        anchorPos(end) = bestPostPos;
        anchorCorr(end) = postCorrN;
        anchorPhase(end) = postPhase;

        fprintf('dbg-hunt: seg%02d (last) | postFound=%d | corrN=%.3f | phase=%.2f deg | chunkLen=%d (expect %d) | drift=%+d\n', ...
            seg, bestPostPos, postCorrN, postPhase*180/pi, actualLen, expectedLen, actualLen - expectedLen);
    end
end

% ============================================================
%  step 4: piecewise phase correction
% ============================================================
numAnch = state.numMidambles + 2;
phRaw = anchorPhase(1:numAnch);

useThr = 0.80;
useFlag = anchorCorr(1:numAnch) >= useThr;
useFlag(1) = true;

fprintf('dbg-phase: usable anchors=%d/%d\n', sum(useFlag), numAnch);

phUnwrap = phRaw;
if sum(useFlag) >= 2
    idxU = find(useFlag);
    phUnwrap(idxU) = unwrap(phRaw(idxU));

    % nearest-neighbor fill for unusable anchors
    for k = 1:numAnch
        if ~useFlag(k)
            dists = abs(k - idxU);
            [~, nearest] = min(dists);
            phUnwrap(k) = phUnwrap(idxU(nearest));
        end
    end
end

for seg = 1:state.numSeg
    chunk = payloadChunks{seg};
    if isempty(chunk) || all(chunk == 0), continue; end

    leftAnch = seg;
    rightAnch = seg + 1;

    ph0 = phUnwrap(leftAnch);
    ph1 = phUnwrap(rightAnch);
    n = length(chunk);
    ramp = linspace(ph0, ph1, n).';
    payloadChunks{seg} = chunk .* exp(-1j * ramp);
end

% ============================================================
%  step 5: assemble payload
% ============================================================
rxPayloadSyms = vertcat(payloadChunks{:});

fprintf('dbg-hunt: assembled payload len=%d | expected=%d\n', ...
    length(rxPayloadSyms), state.codedPayloadLen);

if length(rxPayloadSyms) > state.codedPayloadLen
    rxPayloadSyms = rxPayloadSyms(1:state.codedPayloadLen);
elseif length(rxPayloadSyms) < state.codedPayloadLen
    deficit = state.codedPayloadLen - length(rxPayloadSyms);
    fprintf('dbg-hunt: SHORT by %d, zero-padding\n', deficit);
    rxPayloadSyms = [rxPayloadSyms; zeros(deficit, 1)];
end

rxFrame = rxRot;
rxPay = rxPayloadSyms;

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