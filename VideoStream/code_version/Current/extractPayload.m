% File: extractPayload.m
function rxPay = extractPayload(rxFrame, segStarts, segLens, numSeg)
rxPay = complex([]);
for s = 1:numSeg
    st = segStarts(s);
    rxPay = [rxPay; rxFrame(st:st+segLens(s)-1)];
end
end