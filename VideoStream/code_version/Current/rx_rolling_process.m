function [state, gotFrame, rxPayloadSyms] = rx_rolling_process(rxChunk, state, p)

gotFrame = false;
rxPayloadSyms = complex(zeros(0,1));

rxChunk = rxChunk(:);
if isempty(rxChunk)
    return;
end

if ~isfield(state, 'rxRoll') || isempty(state.rxRoll)
    state.rxRoll = complex(zeros(0,1));
end
if ~isfield(state, 'rollMaxSyms') || isempty(state.rollMaxSyms)
    state.rollMaxSyms = max(4*state.txFrameSyms, state.txFrameSyms + 12000);
end
if ~isfield(state, 'dbg') || isempty(state.dbg)
    state.dbg = false;
end

% rebuild schedule once (or when key params change)
needRebuild = false;
if ~isfield(state, 'sched_valid') || ~state.sched_valid
    needRebuild = true;
end
if ~isfield(state, 'codedPayloadLenEff') || ~isfield(state, 'padLen_eff')
    needRebuild = true;
end
if needRebuild
    preLen  = state.preLen;
    midLen  = state.preLen;
    postLen = state.preLen;

    numMids = state.numMidambles;
    if isempty(numMids) || numMids < 1
        numMids = 38;
    end
    numSeg  = numMids + 1;

    codedPayloadLen = state.codedPayloadLen;

    padLen = mod(-codedPayloadLen, numSeg);
    codedPayloadLenEff = codedPayloadLen + padLen;

    segLen = codedPayloadLenEff / numSeg;
    segLens = segLen * ones(numSeg,1);

    midStarts = zeros(numMids,1);
    idx = preLen + 1;
    for m = 1:numMids
        idx = idx + segLens(m);
        midStarts(m) = idx;
        idx = idx + midLen;
    end

    postStart = preLen + codedPayloadLenEff + numMids*midLen + 1;
    txFrameSyms = preLen + codedPayloadLenEff + numMids*midLen + postLen;

    state.midStarts = midStarts(:);
    state.postStart = postStart;
    state.txFrameSyms = txFrameSyms;

    state.numMidambles = numMids;
    state.numSeg = numSeg;
    state.segLens_eff = segLens(:);
    state.codedPayloadLenEff = codedPayloadLenEff;
    state.padLen_eff = padLen;

    state.sched_valid = true;
end

% append to rolling buffer and cap length
state.rxRoll = [state.rxRoll; rxChunk];
if length(state.rxRoll) > state.rollMaxSyms
    state.rxRoll = state.rxRoll(end-state.rollMaxSyms+1:end);
end

L = length(state.rxRoll);
if L < state.txFrameSyms
    return;
end

pilot  = state.idealPilotSyms(:);
pilotN = norm(pilot) + 1e-12;
preLen = state.preLen;

% normalize rolling buffer (power-based)
pwr = mean(abs(state.rxRoll).^2);
den = max(sqrt(pwr), 1e-12);
rxN = state.rxRoll / den;

corrPilot  = @(seg) abs((seg(:)' * pilot) / preLen);
corrPilotN = @(seg) abs(seg(:)' * pilot) / ((norm(seg(:)) + 1e-12) * pilotN);

ms1 = state.midStarts(1);
ms2 = state.midStarts(2);

maxStart = length(rxN) - state.txFrameSyms + 1;
if maxStart < 1
    return;
end

gatePre = 0.90;
step = 4;

bestScore = -inf;
bestStart = 1;

for s0 = 1:step:maxStart
    preSeg = rxN(s0:s0+preLen-1);
    cPre = corrPilot(preSeg);
    if cPre < gatePre
        continue;
    end

    m1Seg = rxN(s0+ms1-1:s0+ms1-1+preLen-1);
    m2Seg = rxN(s0+ms2-1:s0+ms2-1+preLen-1);

    cM1 = corrPilot(m1Seg);
    cM2 = corrPilot(m2Seg);

    score = 3*(cPre^2) + 2*(cM1^2) + 1*(cM2^2);
    if score > bestScore
        bestScore = score;
        bestStart = s0;
    end
end

if ~isfinite(bestScore)
    return;
end

if step > 1
    win = 4*step*10;
    sLo = max(1, bestStart - win);
    sHi = min(maxStart, bestStart + win);

    bestScoreFine = -inf;
    bestStartFine = bestStart;

    for s0 = sLo:sHi
        preSeg = rxN(s0:s0+preLen-1);
        cPre = corrPilot(preSeg);
        if cPre < gatePre
            continue;
        end

        m1Seg = rxN(s0+ms1-1:s0+ms1-1+preLen-1);
        m2Seg = rxN(s0+ms2-1:s0+ms2-1+preLen-1);

        cM1 = corrPilot(m1Seg);
        cM2 = corrPilot(m2Seg);

        score = 3*(cPre^2) + 2*(cM1^2) + 1*(cM2^2);
        if score > bestScoreFine
            bestScoreFine = score;
            bestStartFine = s0;
        end
    end

    bestStart = bestStartFine;
end

if (bestStart + state.txFrameSyms - 1) > length(rxN)
    return;
end

rxFrame = rxN(bestStart:bestStart+state.txFrameSyms-1);

% rotation ambiguity
pre = rxFrame(1:preLen);
bestMatch = -1;
bestRot = 0;
for rot = [0, pi/2, pi, 3*pi/2]
    testPre = pre .* exp(-1j*rot);
    testDemod = qamdemod(testPre, p.M, 'UnitAveragePower', true);
    m = sum(testDemod == double(state.pilotSeq));
    if m > bestMatch
        bestMatch = m;
        bestRot = rot;
    end
end
rxFrame = rxFrame .* exp(-1j*bestRot);

% fine phase snap
pre = rxFrame(1:preLen);
dotPre = pre(:)' * pilot;
finePhase = angle(dotPre);
rxFrame = rxFrame .* exp(-1j*finePhase);

% preamble verify
preDemod = qamdemod(rxFrame(1:preLen), p.M, 'UnitAveragePower', true);
pilotMatch = sum(preDemod == double(state.pilotSeq));
if pilotMatch < max(100, floor(0.8*preLen))
    % advance buffer a bit to avoid getting stuck on same false peak
    drop = min(bestStart + floor(preLen/2), length(state.rxRoll));
    state.rxRoll = state.rxRoll(drop+1:end);
    return;
end

% residual cfo correction via gated weighted regression on anchors
numMids = state.numMidambles;
allMidStarts = state.midStarts(:);
ps = state.postStart;
midLen = state.midLen;
postLen = state.postLen;

numPotential = 1 + numMids + 1;
ap  = zeros(numPotential,1);
aph = zeros(numPotential,1);
ac  = zeros(numPotential,1);
cN  = zeros(numPotential,1);

anchor_meas = @(seg) deal( ...
    (seg(:)'*pilot)/preLen, ...
    abs((seg(:)'*pilot)/preLen), ...
    angle((seg(:)'*pilot)/preLen), ...
    abs(seg(:)'*pilot)/((norm(seg(:))+1e-12)*pilotN) );

k = 1;
seg = rxFrame(1:preLen);
[~, aAbs, aAng, aN] = anchor_meas(seg);
ap(k) = 1 + floor(preLen/2);
aph(k) = aAng;
ac(k) = aAbs;
cN(k) = aN;

for m = 1:numMids
    k = k + 1;
    ms = allMidStarts(m);
    if (ms < 1) || (ms+midLen-1 > length(rxFrame))
        ac(k) = 0; cN(k) = 0; aph(k) = 0; ap(k) = ms;
        continue;
    end
    seg = rxFrame(ms:ms+midLen-1);
    [~, aAbs, aAng, aN] = anchor_meas(seg);
    ap(k) = ms + floor(midLen/2);
    aph(k) = aAng;
    ac(k) = aAbs;
    cN(k) = aN;
end

k = k + 1;
if (ps >= 1) && (ps+postLen-1 <= length(rxFrame))
    seg = rxFrame(ps:ps+postLen-1);
    [~, aAbs, aAng, aN] = anchor_meas(seg);
    ap(k) = ps + floor(postLen/2);
    aph(k) = aAng;
    ac(k) = aAbs;
    cN(k) = aN;
else
    ap(k) = ps;
    aph(k) = 0;
    ac(k) = 0;
    cN(k) = 0;
end

ampThr  = 0.4 * ac(1);
corrThr = 0.985;
validBase = (ac >= ampThr) & (cN >= corrThr);

stopIdx = numPotential;
badRun = 0;
for ii = 2:(numPotential-1)
    if cN(ii) < 0.95
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

if sum(validIdx) >= 2
    x = double(ap(validIdx));
    y = unwrap(double(aph(validIdx)));
    y = y - y(1);

    w = (ac(validIdx) / (max(ac(validIdx)) + 1e-12)).^4;
    w = w / (max(w) + 1e-12);

    A = [ones(size(x)) x];
    Aw = A .* sqrt(w);
    yw = y .* sqrt(w);
    theta = (Aw.'*Aw) \ (Aw.'*yw);

    a = theta(1);
    b = theta(2);

    n = (1:state.txFrameSyms).';
    rxFrame = rxFrame .* exp(-1j * (a + b*double(n)));
end

% payload extraction consistent with rebuilt schedule
codedPayloadLen = state.codedPayloadLen;
codedPayloadLenEff = state.codedPayloadLenEff;
padLen = state.padLen_eff;

payloadStart = preLen + 1;
payloadEnd   = preLen + codedPayloadLenEff + numMids*midLen;

if payloadEnd > length(rxFrame)
    drop = min(bestStart + floor(preLen/2), length(state.rxRoll));
    state.rxRoll = state.rxRoll(drop+1:end);
    return;
end

rawPayload = rxFrame(payloadStart:payloadEnd);

mask = true(size(rawPayload));
for m = 1:numMids
    ms = allMidStarts(m);
    midRel = ms - payloadStart + 1;
    if midRel >= 1 && (midRel + midLen - 1) <= length(mask)
        mask(midRel:midRel+midLen-1) = false;
    end
end

rxPayloadSymsEff = rawPayload(mask);
if length(rxPayloadSymsEff) ~= codedPayloadLenEff
    drop = min(bestStart + floor(preLen/2), length(state.rxRoll));
    state.rxRoll = state.rxRoll(drop+1:end);
    return;
end

if padLen > 0
    rxPayloadSymsEff = rxPayloadSymsEff(1:codedPayloadLen);
end

rxPayloadSyms = rxPayloadSymsEff;
gotFrame = true;

% consume buffer through end of frame so next call searches forward
drop = min(bestStart + state.txFrameSyms - 1, length(state.rxRoll));
state.rxRoll = state.rxRoll(drop+1:end);

if state.dbg
    fprintf('dbg-roll: gotFrame=1 | pilotMatch=%d/%d | rollRem=%d | bestStart=%d\n', ...
        pilotMatch, preLen, length(state.rxRoll), bestStart);
end
end