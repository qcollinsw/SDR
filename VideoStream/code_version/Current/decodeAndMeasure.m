% File: decodeAndMeasure.m
function [imgU8, bitErrors, nBits, nCorrSyms] = decodeAndMeasure(rxDemod, rsDec, prbsSeq, dataNeeded, payload, p)
[decPayloadScr, err] = rsDec(uint8(rxDemod));
nCorrSyms = sum(err);
decPayload = bitxor(decPayloadScr, prbsSeq);
imgBytes = decPayload(1:dataNeeded);
imgU8 = uint8(double(imgBytes) * p.scaleRx);

if isempty(payload)
    bitErrors = 0;
    nBits = 0;
else
    rxBits = de2bi(double(imgBytes),8,'left-msb');
    txBits = de2bi(double(payload(1:dataNeeded)),8,'left-msb');
    bitErrors = sum(rxBits(:) ~= txBits(:));
    nBits = numel(rxBits);
end
end


