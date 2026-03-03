% File: alignFrameByPreamble.m
function rxFrame = alignFrameByPreamble(rxData, idealPilotSyms, preLen, txFrameSyms, ~, ~)
maxOff = length(rxData) - txFrameSyms + 1;

fprintf('dbg-align: rxLen=%d | txFrameSyms=%d | maxOff=%d | preLen=%d\n', ...
    length(rxData), txFrameSyms, maxOff, preLen);

if maxOff < 1
    fprintf('dbg-align: FAIL | rxData too short\n');
    rxFrame = [];
    return;
end

% complex correlation across all candidate offsets
bestCorrMag = 0; bestOffset = 1; bestPhase = 0;
pilotNorm = norm(idealPilotSyms);

for offset = 1:maxOff
    rxPre = rxData(offset:offset+preLen-1);
    c = rxPre(:)' * idealPilotSyms(:);  % complex dot product
    cm = abs(c);
    if cm > bestCorrMag
        bestCorrMag = cm;
        bestOffset = offset;
        bestPhase = angle(c);
    end
end

% normalize for interpretability
normCorr = bestCorrMag / (norm(rxData(bestOffset:bestOffset+preLen-1)) * pilotNorm);

fprintf('dbg-align: bestOffset=%d | bestPhase=%.4f rad (%.1f deg) | corrMag=%.4f | normCorr=%.6f\n', ...
    bestOffset, bestPhase, rad2deg(bestPhase), bestCorrMag, normCorr);

rxAligned = rxData(bestOffset:end);
if length(rxAligned) < txFrameSyms
    fprintf('dbg-align: FAIL | aligned len=%d < txFrameSyms=%d\n', length(rxAligned), txFrameSyms);
    rxFrame = [];
    return;
end

% derotate entire frame by preamble phase
rxFrame = rxAligned(1:txFrameSyms) .* exp(-1j * bestPhase);

% verify preamble after correction
correctedPre = rxFrame(1:preLen);
finalMSE = mean(abs(correctedPre(:) - idealPilotSyms(:)).^2);
finalCorr = abs(correctedPre(:)' * idealPilotSyms(:)) / (norm(correctedPre) * pilotNorm);

fprintf('dbg-align: finalMSE=%.6f | finalCorr=%.6f | frameLen=%d\n', ...
    finalMSE, finalCorr, length(rxFrame));
end