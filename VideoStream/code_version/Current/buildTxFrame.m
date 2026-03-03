% File: buildTxFrame.m
function txSyms = buildTxFrame(codedPayload, idealPilotSyms, M, numSeg, segLens, numMidambles)

codedPayload = uint8(codedPayload);
codedPayload = uint8(mod(double(codedPayload), M));

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