function rxFrame = alignFrameByPreamble(rxData, idealPilotSyms, preLen, txFrameSyms, ~, ~)
% search everywhere the preamble could be
nSearch = length(rxData) - txFrameSyms + 1;
if nSearch < 1
    rxFrame = [];
    return;
end

% fast correlation using matched filter
xc = abs(filter(conj(idealPilotSyms(end:-1:1)), 1, rxData));
% valid region: only offsets where full frame fits
xc(1:preLen-1) = 0;
xc(nSearch+preLen:end) = 0;

[corrPeak, peakIdx] = max(xc);
bestOffset = peakIdx - preLen + 1;
fprintf('dbg-align: offset=%d/%d | corrPeak=%.3f\n', bestOffset, nSearch, corrPeak);

rxAligned = rxData(bestOffset:end);
if length(rxAligned) < txFrameSyms
    rxFrame = [];
    return;
end
rxFrame = rxAligned(1:txFrameSyms);
end