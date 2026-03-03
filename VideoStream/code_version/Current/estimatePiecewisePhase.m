% File: estimatePiecewisePhase.m
function phaseVec = estimatePiecewisePhase(rxFrame, idealPilotSyms, preLen, preStart, midStarts, postStart, numMidambles, coarseSteps, fineSteps, txFrameSyms)
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
end