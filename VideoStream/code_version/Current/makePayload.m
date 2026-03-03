% File: makePayload.m
function [payload, codedPayload] = makePayload(g, p, dataNeeded, padLen, prbsSeq, rsEnc)
payload = uint8(round(double(g(:)) * p.scaleTx));
payload = [payload; zeros(padLen,1,'uint8')];
payloadScr = bitxor(payload, prbsSeq);
codedPayload = rsEnc(payloadScr);
end