function [rxFrame, rxPay, payloadChunks, anchorPhase, anchorCorr, bestPrePos, bestPostPos, success] = ...
    barker_frame_hunter(rxData_proc, state, verbose_debug)
% Hunt for a 3-barker frame, rotate+fine-phase, midamble search, piecewise phase
% correction, and assemble payload. Returns success=false on any failure.

% initialize outputs (important!)
rxFrame = [];
rxPay = [];
payloadChunks = {};
anchorPhase = [];
anchorCorr = [];
bestPrePos = [];
bestPostPos = [];
success = false;

if nargin < 3
    verbose_debug = false;
end

prePilot  = state.prePilot(:);   preLen  = length(prePilot);  preN  = norm(prePilot);
midPilot  = state.midPilot(:);   midLen  = length(midPilot);  midN  = norm(midPilot);
postPilot = state.postPilot(:);  postLen = length(postPilot); postN = norm(postPilot);

rxLong = rxData_proc(:);
if isempty(rxLong)
    if verbose_debug, fprintf('barker_hunter: empty input\n'); end
    return;
end

rxPwr  = mean(abs(rxLong).^2);
rxLong = rxLong / max(sqrt(rxPwr), 1e-12);

% expected total frame length in symbols (pilot symbols are separate from qam payload)
expFrameLen = preLen + state.codedPayloadLen + state.numMidambles*midLen + postLen;

if verbose_debug
    fprintf('dbg-hunt: rxLen=%d | pre=%d mid=%d post=%d | numMid=%d | codedPay=%d | expFrame=%d\n', ...
        length(rxLong), preLen, midLen, postLen, state.numMidambles, state.codedPayloadLen, expFrameLen);
end

% safe correlation that returns 0 if the requested window is out of bounds
corrNorm = @(buf, pos, ref, refN) safe_corr_norm(buf, pos, ref, refN);

% ============================================================
% step 1: find a preamble that has a matching postamble at the expected offset
% ============================================================
thrPre  = 0.80;
thrPost = 0.80;

bestScore  = -inf;
bestPrePos = [];

maxStart = length(rxLong) - expFrameLen + 1;
if maxStart < 1
    if verbose_debug, fprintf('dbg-hunt: buffer too short for expected frame\n'); end
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
    if verbose_debug, fprintf('dbg-hunt: no valid pre+post pair found\n'); end
    return;
end

bestPostPos = bestPrePos + expFrameLen - postLen;

if verbose_debug
    fprintf('dbg-hunt: bestPre=%d bestPost=%d score=%.3f\n', bestPrePos, bestPostPos, bestScore);
end

% ============================================================
% step 2: resolve 90-degree rotation and fine phase using barker preamble correlation
% ============================================================
% bounds check for preSeg
if bestPrePos + preLen - 1 > length(rxLong)
    if verbose_debug, fprintf('dbg-hunt: preamble would index past buffer\n'); end
    return;
end
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

if verbose_debug
    fprintf('dbg-hunt: rot=%d deg | preCorr=%.3f\n', round(bestRot*180/pi), bestMetric);
end

if bestMetric < 0.85
    if verbose_debug, fprintf('dbg-hunt: weak preamble correlation after rotation (%.3f)\n', bestMetric); end
    return;
end

% apply rotation and fine phase (ensure we have enough samples for expFrameLen)
if bestPrePos + expFrameLen - 1 > length(rxLong)
    if verbose_debug, fprintf('dbg-hunt: not enough samples following bestPrePos for full frame\n'); end
    return;
end
rxRot = rxLong(bestPrePos:bestPrePos+expFrameLen-1) .* exp(-1j*bestRot);

finePhase = angle(bestDot);
rxRot = rxRot .* exp(-1j*finePhase);
if verbose_debug
    fprintf('dbg-hunt: finePhase=%.2f deg\n', finePhase*180/pi);
end

preCheckMetric = abs(rxRot(1:preLen)'*prePilot) / (norm(rxRot(1:preLen))*preN + 1e-12);
postCheckMetric = abs(rxRot(expFrameLen-postLen+1:expFrameLen)'*postPilot) / ...
    (norm(rxRot(expFrameLen-postLen+1:expFrameLen))*postN + 1e-12);
if verbose_debug
    fprintf('dbg-hunt: verify preCorr=%.3f postCorr=%.3f\n', preCheckMetric, postCheckMetric);
end

if preCheckMetric < 0.85 || postCheckMetric < 0.85
    if verbose_debug, fprintf('dbg-hunt: pilot verify failed\n'); end
    return;
end

% ============================================================
% step 3: midamble hunt and chunk extraction
% ============================================================
searchHalfWin = max(16, floor(0.15*midLen));
payloadChunks = cell(state.numSeg, 1);

numAnch = state.numMidambles + 2;
anchorPhase = zeros(numAnch, 1);
anchorCorr  = zeros(numAnch, 1);

% anchor 1 is the preamble
dpre = rxRot(1:preLen)' * prePilot;
anchorPhase(1) = angle(dpre);
anchorCorr(1)  = abs(dpre) / (norm(rxRot(1:preLen))*preN + 1e-12);

cur = preLen + 1;
for s = 1:state.numSeg
    n = state.segLens(s);
    if cur + n - 1 > length(rxRot)
        if verbose_debug, fprintf('dbg-hunt: segment %d would index past rxRot\n', s); end
        return;
    end
    payloadChunks{s} = rxRot(cur:cur+n-1);
    cur = cur + n;

    if s <= state.numMidambles
        expMidPos = cur;
        lo = max(1, expMidPos - searchHalfWin);
        hi = min(length(rxRot) - midLen + 1, expMidPos + searchHalfWin);
        if lo > hi
            if verbose_debug, fprintf('dbg-hunt: empty mid search window for mid %d\n', s); end
            return;
        end

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
            if verbose_debug, fprintf('dbg-hunt: midamble %d not found (win empty)\n', s); end
            return;
        end

        cur = bestMidPos + midLen;
        anchorPhase(s+1) = angle(bestMidDot);
        anchorCorr(s+1)  = bestMidCorr;

        if verbose_debug
            fprintf('dbg-hunt: mid%d pos=%d corr=%.3f\n', s, bestMidPos, bestMidCorr);
        end
    end
end

% last anchor is the postamble
postStart = expFrameLen - postLen + 1;
dpost = rxRot(postStart:postStart+postLen-1)' * postPilot;
anchorPhase(end) = angle(dpost);
anchorCorr(end)  = abs(dpost) / (norm(rxRot(postStart:postStart+postLen-1))*postN + 1e-12);

if verbose_debug
    fprintf('dbg-hunt: post corr=%.3f\n', anchorCorr(end));
end

% ============================================================
% step 4: piecewise phase correction using pilot anchors
% ============================================================
useThr = 0.80;
useFlag = anchorCorr >= useThr;
useFlag(1) = true;

if verbose_debug
    fprintf('dbg-phase: usable anchors=%d/%d\n', sum(useFlag), numAnch);
end

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
    if isempty(chunk) || all(chunk == 0)
        % treat empty chunk as OK (no symbols)
        continue;
    end

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
if verbose_debug
    fprintf('dbg-hunt: assembled payload len=%d | expected=%d\n', length(rxPayloadSyms), state.codedPayloadLen);
end

if length(rxPayloadSyms) > state.codedPayloadLen
    rxPayloadSyms = rxPayloadSyms(1:state.codedPayloadLen);
elseif length(rxPayloadSyms) < state.codedPayloadLen
    deficit = state.codedPayloadLen - length(rxPayloadSyms);
    if verbose_debug, fprintf('dbg-hunt: SHORT by %d, zero-padding\n', deficit); end
    rxPayloadSyms = [rxPayloadSyms; zeros(deficit, 1)];
end

rxFrame = rxRot(1:expFrameLen);
rxPay   = rxPayloadSyms;

if verbose_debug
    fprintf('dbg-hunt: done | payLen=%d | pwr=%.4g\n', length(rxPay), mean(abs(rxPay).^2));
end

success = true;
return;

end

%% helper: safe correlation (returns 0 if out-of-bounds)
function c = safe_corr_norm(buf, pos, ref, refN)
c = 0;
len = length(ref);
if pos < 1 || (pos + len - 1) > length(buf)
    return;
end
seg = buf(pos:pos+len-1);
c = abs(seg(:)' * ref) / (norm(seg) * max(refN, 1e-12) + 1e-12);
end